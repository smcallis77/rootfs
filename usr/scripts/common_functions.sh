#!/bin/sh

# This file is supposed to bundle some frequently used functions
# so they can be easily improved in one place and be reused all over the place

# Common paths (means less variations between firmware_mod and the open source version rootfs
WWW_PATH='/var/www';export WWW_PATH;                      # path to lighttpd files
SCRIPT_PATH='/usr/scripts';export SCRIPT_PATH;               # path to scripts
CONTROLSCRIPT_PATH='/usr/controlscripts'; export CONTROLSCRIPT_PATH; # path to control scripts
LOG_PATH='/var/log'; export LOG_PATH;                      # path to log file directory
BIN_PATH='/bin'; export BIN_PATH;                             # path to standard binaries
CONFIG_PATH='/etc'; export CONFIG_PATH;                # path to configuration files
SDCARDBIN_PATH='/usr/bin';export SDCARDBIN_PATH;                # path to custom binaries
RUN_PATH='/var/run';export RUN_PATH;                                    # path to run directory for PID files

include () {
    [[ -f "$1" ]] && source "$1"
}
# Set motor range
MAX_X=2600
MAX_Y=700
MIN_X=0
MIN_Y=0
STEP=100

# Initialize  gpio pin
init_gpio(){
  GPIOPIN=$1
  echo "$GPIOPIN" > /sys/class/gpio/export
  case $2 in
    in)
      echo "in" > "/sys/class/gpio/gpio$GPIOPIN/direction"
      ;;
    *)
      echo "out" > "/sys/class/gpio/gpio$GPIOPIN/direction"
      ;;
  esac
  echo 0 > "/sys/class/gpio/gpio$GPIOPIN/active_low"
}

# Read a value from a gpio pin
getgpio(){
  GPIOPIN=$1
  cat /sys/class/gpio/gpio"$GPIOPIN"/value
}

# Write a value to gpio pin
setgpio() {
  GPIOPIN=$1
  echo "$2" > "/sys/class/gpio/gpio$GPIOPIN/value"
}

# Replace the old value of a config_key at the cfg_path with new_value
# Don't rewrite commented lines
rewrite_config(){
  cfg_path=$1
  cfg_key=$2
  new_value=$3

  # Check if the value exists (without comment), if not add it to the file
  $(grep -v '^[[:space:]]*#' $1  | grep -q $2)
  ret="$?"
  if [ "$ret" == "1" ] ; then
      echo "$2=$3" >> $1
  else
        sed -i -e "/\\s*#.*/!{/""$cfg_key""=/ s/=.*/=""$new_value""/}" "$cfg_path"
  fi
}

# Control the blue led
blue_led(){
  case "$1" in
  on)
    setgpio 39 0
    ;;
  off)
    setgpio 39 1
    ;;
  status)
    status=$(getgpio 39)
    case $status in
      0)
        echo "ON"
        ;;
      1)
        echo "OFF"
      ;;
    esac
  esac
}

# Control the yellow led
yellow_led(){
  case "$1" in
  on)
    setgpio 38 0
    ;;
  off)
    setgpio 38 1
    ;;
  status)
    status=$(getgpio 38)
    case $status in
      0)
        echo "ON"
        ;;
      1)
        echo "OFF"
      ;;
    esac
  esac
}

# Control the infrared led
ir_led(){
  case "$1" in
  on)
    setgpio 49 0
    ;;
  off)
    setgpio 49 1
    ;;
  status)
    status=$(getgpio 49)
    case $status in
      0)
        echo "ON"
        ;;
      1)
        echo "OFF"
      ;;
    esac
  esac
}

# Control the infrared filter
ir_cut(){
  case "$1" in
  on)
    setgpio 25 0
    setgpio 26 1
    sleep 1
    setgpio 26 0
    echo "1" > ${RUN_PATH}/ircut
    ;;
  off)
    setgpio 26 0
    setgpio 25 1
    sleep 1
    setgpio 25 0
    echo "0" > ${RUN_PATH}/ircut
    ;;
  status)
    status=$(cat ${RUN_PATH}/ircut)
    case $status in
      1)
        echo "ON"
        ;;
      0)
        echo "OFF"
      ;;
    esac
  esac
}

# Calibrate and control the motor
# use like: motor up 100
motor(){
  if [ -z "$2" ]
  then
    steps=$STEP
  else
    steps=$2
  fi
  case "$1" in
  up)
    ${SDCARDBIN_PATH}/motor -d u -s "$steps"
    update_motor_pos $steps
    ;;
  down)
    ${SDCARDBIN_PATH}/motor -d d -s "$steps"
    update_motor_pos $steps
    ;;
  left)
    ${SDCARDBIN_PATH}/motor -d l -s "$steps"
    update_motor_pos $steps
    ;;
  right)
    ${SDCARDBIN_PATH}/motor -d r -s "$steps"
    update_motor_pos $steps
    ;;
  reset_pos_count)
    ${SDCARDBIN_PATH}/motor -d v -s "$steps"
    update_motor_pos $steps
    ;;
  status)
    if [ "$2" = "horizontal" ]; then
        ${SDCARDBIN_PATH}/motor -d u -s 0 | grep "x:" | awk  '{print $2}'
    else
        ${SDCARDBIN_PATH}/motor -d u -s 0 | grep "y:" | awk  '{print $2}'
    fi
    ;;
  esac

}

update_motor_pos(){
  # Waiting for the motor to run.
  SLEEP_NUM=$(awk -v a="$1" 'BEGIN{printf ("%f",a*1.3/1000)}')
  sleep ${SLEEP_NUM//-/}
  # Display AXIS to OSD
  update_axis
  ${SDCARDBIN_PATH}/setconf -k o -v "$OSD"
}

# Read the light sensor
ldr(){
  case "$1" in
  status)
    brightness=$(dd if=/dev/jz_adc_aux_0 count=20 2> /dev/null |  sed -e 's/[^\.]//g' | wc -m)
    echo "$brightness"
  esac
}

# Control the http server
http_server(){
  case "$1" in
  on)
    ${SDCARDBIN_PATH}/lighttpd -f ${CONFIG_PATH}/lighttpd.conf
    ;;
  off)
    killall lighttpd
    ;;
  restart)
    killall lighttpd
    ${SDCARDBIN_PATH}/lighttpd -f ${CONFIG_PATH}/lighttpd.conf
    ;;
  status)
    if pgrep lighttpd &> /dev/null
      then
        echo "ON"
    else
        echo "OFF"
    fi
    ;;
  esac
}

# Set a new http password
http_password(){
  user="root" # by default root until we have proper user management
  realm="all" # realm is defined in the lightppd.conf
  pass=$1
  hash=$(echo -n "$user:$realm:$pass" | md5sum | cut -b -32)
  echo "$user:$realm:$hash" > ${CONFIG_PATH}/lighttpd.user
}

# Control the RTSP h264 server
rtsp_h264_server(){
  case "$1" in
  on)
    ${CONTROLSCRIPT_PATH}/rtsp-h264 start
    ;;
  off)
    ${CONTROLSCRIPT_PATH}/rtsp-h264 stop
    ;;
  status)
    if ${CONTROLSCRIPT_PATH}/rtsp-h264 status | grep -q "PID"
      then
        echo "ON"
    else
        echo "OFF"
    fi
    ;;
  esac
}

# Control the RTSP mjpeg server
rtsp_mjpeg_server(){
  case "$1" in
  on)
    ${CONTROLSCRIPT_PATH}/rtsp-mjpeg start
    ;;
  off)
    ${CONTROLSCRIPT_PATH}/rtsp-mjpeg stop
    ;;
  status)
    if ${CONTROLSCRIPT_PATH}/rtsp-mjpeg status | grep -q "PID"
    then
        echo "ON"
    else
        echo "OFF"
    fi
    ;;
  esac
}

# Control the motion detection function
motion_detection(){
  case "$1" in
  on)
    ${SDCARDBIN_PATH}/setconf -k m -v 4
    ;;
  off)
    ${SDCARDBIN_PATH}/setconf -k m -v -1
    ;;
  status)
    status=$(${SDCARDBIN_PATH}/setconf -g m 2>/dev/null)
    case $status in
      -1)
        echo "OFF"
        ;;
      *)
        echo "ON"
        ;;
    esac
  esac
}

# Control the motion detection mail function
motion_send_mail(){
  case "$1" in
  on)
    rewrite_config ${CONFIG_PATH}/motion.conf send_email "true"
    ;;
  off)
    rewrite_config ${CONFIG_PATH}/motion.conf send_email "false"
    ;;
  status)
    status=$(awk '/send_email/' ${CONFIG_PATH}/motion.conf |cut -f2 -d \=)
    case $status in
      false)
        echo "OFF"
        ;;
      true)
        echo "ON"
        ;;
    esac
  esac
}

# Control the motion detection Telegram function
motion_send_telegram(){
  case "$1" in
  on)
    rewrite_config ${CONFIG_PATH}/motion.conf send_telegram "true"
    ;;
  off)
    rewrite_config ${CONFIG_PATH}/motion.conf send_telegram "false"
    ;;
  status)
    status=$(awk '/send_telegram/' ${CONFIG_PATH}/motion.conf |cut -f2 -d \=)
    case $status in
      true)
        echo "ON"
        ;;
      *)
        echo "OFF"
        ;;
    esac
  esac
}

# Control the motion tracking function
motion_tracking(){
  case "$1" in
  on)
    ${SDCARDBIN_PATH}/setconf -k t -v on
    ;;
  off)
    ${SDCARDBIN_PATH}/setconf -k t -v off
    ;;
  status)
    status=$(${SDCARDBIN_PATH}/setconf -g t 2>/dev/null)
    case $status in
      true)
        echo "ON"
        ;;
      *)
        echo "OFF"
        ;;
    esac
  esac
}

# Control the night mode
night_mode(){
  case "$1" in
  on)
    ${SDCARDBIN_PATH}/setconf -k n -v 1
    ir_led on
    ir_cut off
    ;;
  off)
    ir_led off
    ir_cut on
    ${SDCARDBIN_PATH}/setconf -k n -v 0
    ;;
  status)
    status=$(${SDCARDBIN_PATH}/setconf -g n)
    case $status in
      0)
        echo "OFF"
        ;;
      1)
        echo "ON"
        ;;
    esac
  esac
}

# Control the auto night mode
auto_night_mode(){
  case "$1" in
    on)
      ${CONTROLSCRIPT_PATH}/auto-night-detection start
      ;;
    off)
      ${CONTROLSCRIPT_PATH}/auto-night-detection stop
      ;;
    status)
      if [ -f /${RUN_PATH}/auto-night-detection.pid ]; then
        echo "ON";
      else
        echo "OFF"
      fi
  esac
}

# Take a snapshot
snapshot(){
    filename="/tmp/snapshot.jpg"
    ${SDCARDBIN_PATH}/getimage > "$filename" &
    sleep 1
}

# Update axis
update_axis(){
  . ${CONFIG_PATH}/osd.conf > /dev/null 2>/dev/null
  AXIS=$(${SDCARDBIN_PATH}/motor -d s | sed '3d' | awk '{printf ("%s ",$0)}' | awk '{print "X="$2,"Y="$4}')
  if [ "$DISPLAY_AXIS" == "true" ]; then
    OSD="${OSD} ${AXIS}"
  fi
}

# Reboot the System
reboot_system() {
  /sbin/reboot
}

# Re-Mount the SD Card
remount_sdcard() {
  mount -o remount,rw /system/sdcard
}
