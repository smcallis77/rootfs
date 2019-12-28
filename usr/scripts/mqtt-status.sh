#!/bin/sh
. /usr/scripts/common_functions.sh
. ${CONFIG_PATH}/mqtt.conf

## Uptime
uptime=$(${BIN_PATH}/busybox uptime)

## Wifi
ssid=$(${BIN_PATH}/iwconfig 2>/dev/null | grep ESSID | sed -e "s/.*ESSID:\"//" | sed -e "s/\".*//") # FIXME: iwconfig not on rootfs
bitrate=$(${BIN_PATH}/iwconfig 2>/dev/null | grep "Bit R" | sed -e "s/   S.*//" | sed -e "s/.*\\://")
quality=$(${BIN_PATH}/iwconfig 2>/dev/null | grep "Quali" | sed -e "s/  *//")
noise_level=$(echo "$quality" | awk '{ print $6}' | sed -e 's/.*=//' | sed -e 's/\/100/\%/')
link_quality=$(echo "$quality" | awk '{ print $2}' | sed -e 's/.*=//' | sed -e 's/\/100/\%/')
signal_level=$(echo "$quality" | awk '{ print $4}' | sed -e 's/.*=//' | sed -e 's/\/100/\%/')

echo "{\"uptime\":\"$uptime\",  \"ssid\":\"$ssid\", \"bitrate\":\"$bitrate\", \"signal_level\":\"$signal_level\", \"link_quality\":\"$link_quality\", \"noise_level\":\"$noise_level\" }"
