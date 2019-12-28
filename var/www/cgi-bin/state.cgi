#!/bin/sh

# A very light-weight interface just for responsive ui to get states

source ./func.cgi
source /usr/scripts/common_functions.sh


echo "Content-type: text"
echo "Pragma: no-cache"
echo "Cache-Control: max-age=0, no-store, no-cache"
echo ""

if [ -n "$F_cmd" ]; then
  case "$F_cmd" in
  blue_led)
    echo $(blue_led status)
    ;;

  yellow_led)
    echo $(yellow_led status)
    ;;

  ir_led)
    echo $(ir_led status)
    ;;

  ir_cut)
    echo $(ir_cut status)
    ;;

  rtsp_h264)
    echo $(rtsp_h264_server status)
    ;;

  rtsp_mjpeg)
    echo $(rtsp_mjpeg_server status)
    ;;

  auto_night_detection)
    echo $(auto_night_mode status)
    ;;

  auto_night_detection_mode)
    if [ -f ${CONFIG_PATH}/autonight.conf ];
      then night_mode=$(cat ${CONFIG_PATH}/autonight.conf);
    else
      night_mode="HW";
    fi
    echo $night_mode
    ;;

  mqtt_status)
    if [ -f ${RUN_PATH}/mqtt-status.pid ];
      then mqtt_status="ON";
    else
      mqtt_status="OFF";
    fi
    echo $mqtt_status
    ;;

  mqtt_control)
    if [ -f ${RUN_PATH}/mqtt-control.pid ];
      then mqtt_control="ON";
    else
      mqtt_control="OFF";
    fi
    echo $mqtt_control
    ;;

  sound_on_startup)
    if [ -f ${CONFIG_PATH}/autostart/sound-on-startup ];
      then sound_on_startup="ON";
    else
      sound_on_startup="OFF";
    fi
    echo $sound_on_startup
    ;;

  motion_detection)
    echo $(motion_detection status)
    ;;

  motion_tracking)
    echo $(motion_tracking status)
    ;;

  motion_mail)
    . ${CONFIG_PATH}/motion.conf 2> /dev/null
    if [ "$sendemail" == "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;

  motion_telegram)
    . ${CONFIG_PATH}/motion.conf 2> /dev/null
    if [ "$send_telegram" == "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;

  motion_led)
    . ${CONFIG_PATH}/motion.conf 2> /dev/null
    if [ "$motion_trigger_led" == "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;

  motion_snapshot)
    . ${CONFIG_PATH}/motion.conf 2> /dev/null
    if [ "$save_snapshot" == "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;

  motion_mqtt)
    . ${CONFIG_PATH}/motion.conf 2> /dev/null
    if [ "$publish_mqtt_message" == "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;

  motion_mqtt_snapshot)
    . ${CONFIG_PATH}/motion.conf 2> /dev/null
    if [ "$publish_mqtt_snapshot" == "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;

  hostname)
    echo $(hostname);
    ;;

  version)
    echo $(cat /.lastCommitDate);
    ;;

  *)
    echo "Unsupported command '$F_cmd'"
    ;;

  esac
  fi

exit 0
