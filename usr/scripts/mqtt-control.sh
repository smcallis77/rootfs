#!/bin/sh

. /usr/scripts/common_functions.sh
. ${CONFIG_PATH}/mqtt.conf

killall ${SDCARDBIN_PATH}/mosquitto_sub 2> /dev/null

${SDCARDBIN_PATH}/mosquitto_sub -v -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t cmnd/"${TOPIC}"/#  ${MOSQUITTOOPTS} | while read -r line ; do
  case $line in
    "${TOPIC}/set help")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/help ${MOSQUITTOOPTS} -m "possible commands: configured topic + Yellow_LED/set on/off, configured topic + Blue_LED/set on/off, configured topic + set with the following commands: status, $(grep \)$ ${WWW_PATH}/cgi-bin/action.cgi | grep -v '[=*]' | sed -e "s/ //g" | grep -v -E '(osd|setldr|settz|showlog)' | sed -e "s/)//g")"
    ;;

    "${TOPIC}/set status")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/ ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(${SCRIPT_PATH}/mqtt-status.sh)"
    ;;

    "${TOPIC}/leds/blue")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/blue ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(blue_led status)"
    ;;

    "${TOPIC}/leds/blue/set ON")
      blue_led on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/blue ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(blue_led status)"
    ;;

    "${TOPIC}/leds/blue/set OFF")
      blue_led off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/blue ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS}  -m "$(blue_led status)"
    ;;

    "${TOPIC}/leds/yellow")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/yellow ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(yellow_led status)"
    ;;

    "${TOPIC}/leds/yellow/set ON")
      yellow_led on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/yellow ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(yellow_led status)"
    ;;

    "${TOPIC}/leds/yellow/set OFF")
      yellow_led off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/yellow ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(yellow_led status)"
    ;;

    "${TOPIC}/leds/ir")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/ir ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ir_led status)"
    ;;

    "${TOPIC}/leds/ir/set ON")
      ir_led on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/ir ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ir_led status)"
    ;;

    "${TOPIC}/leds/ir/set OFF")
      ir_led off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/leds/ir ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ir_led status)"
    ;;

    "${TOPIC}/ir_cut")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/ir_cut ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ir_cut status)"
    ;;

    "${TOPIC}/ir_cut/set ON")
      ir_cut on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/ir_cut ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ir_cut status)"
    ;;

    "${TOPIC}/ir_cut/set OFF")
      ir_cut off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/ir_cut ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ir_cut status)"
    ;;

    "${TOPIC}/brightness")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/brightness ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(ldr status)"
    ;;

    "${TOPIC}/rtsp_h264_server")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/rtsp_h264_server ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(rtsp_h264_server status)"
    ;;

    "${TOPIC}/rtsp_h264_server/set ON")
      rtsp_h264_server on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/rtsp_h264_server ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(rtsp_h264_server status)"
    ;;

    "${TOPIC}/rtsp_h264_server/set OFF")
      rtsp_h264_server off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/rtsp_h264_server ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(rtsp_h264_server status)"
    ;;

    "${TOPIC}/rtsp_mjpeg_server")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/rtsp_mjpeg_server ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(rtsp_mjpeg_server status)"
    ;;

    "${TOPIC}/rtsp_mjpeg_server/set ON")
      rtsp_mjpeg_server on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/rtsp_mjpeg_server ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(rtsp_mjpeg_server status)"
    ;;

    "${TOPIC}/rtsp_mjpeg_server/set OFF")
      rtsp_mjpeg_server off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/rtsp_mjpeg_server ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(rtsp_mjpeg_server status)"
    ;;

    "${TOPIC}/night_mode")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/night_mode ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(night_mode status)"
    ;;

    "${TOPIC}/night_mode/set ON")
      night_mode on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/night_mode ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(night_mode status)"
    ;;

    "${TOPIC}/night_mode/set OFF")
      night_mode off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/night_mode ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(night_mode status)"
    ;;

    "${TOPIC}/night_mode/auto")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/night_mode/auto ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(auto_night_mode status)"
    ;;

    "${TOPIC}/night_mode/auto/set ON")
      auto_night_mode on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/night_mode/auto ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(auto_night_mode status)"
    ;;

    "${TOPIC}/night_mode/auto/set OFF")
      auto_night_mode off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/night_mode/auto ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(auto_night_mode status)"
    ;;

    "${TOPIC}/motion/detection")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/detection ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_detection status)"
    ;;

    "${TOPIC}/motion/detection/set ON")
      motion_detection on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/detection ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_detection status)"
    ;;

    "${TOPIC}/motion/detection/set OFF")
      motion_detection off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/detection ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_detection status)"
    ;;

   "${TOPIC}/motion/send_mail")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/send_mail ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_send_mail status)"
    ;;

    "${TOPIC}/motion/send_mail/set ON")
      motion_send_mail on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/send_mail ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_send_mail status)"
    ;;

    "${TOPIC}/motion/send_mail/set OFF")
      motion_send_mail off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/send_mail ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_send_mail status)"
    ;;

   "${TOPIC}/motion/send_telegram")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/send_telegram ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_send_telegram status)"
    ;;

    "${TOPIC}/motion/send_telegram/set ON")
      motion_send_telegram on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/send_telegram ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_send_telegram status)"
    ;;

    "${TOPIC}/motion/send_telegram/set OFF")
      motion_send_telegram off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/send_telegram ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_send_telegram status)"
    ;;

    "${TOPIC}/motion/tracking")
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/tracking ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_tracking status)"
    ;;

    "${TOPIC}/motion/tracking/set ON")
      motion_tracking on
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/tracking ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_tracking status)"
    ;;

    "${TOPIC}/motion/tracking/set OFF")
      motion_tracking off
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/tracking ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motion_tracking status)"
    ;;

    "${TOPIC}/motors/vertical/set up")
      motor up
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motors/vertical ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motor status vertical)"
    ;;

    "${TOPIC}/motors/vertical/set down")
      motor down
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motors/vertical ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motor status vertical)"
    ;;

    "${TOPIC}/motors/vertical/set "*)
      COMMAND=$(echo "$line" | awk '{print $2}')
      MOTORSTATE=$(motor status vertical)
      if [ -n "$COMMAND" ] && [ "$COMMAND" -eq "$COMMAND" ] 2>/dev/null; then
        echo Changing motor from $MOTORSTATE to $COMMAND
        TARGET=$(${BIN_PATH}/busybox expr $COMMAND - $MOTORSTATE)
        echo Moving $TARGET
        if [ "$TARGET" -lt 0 ]; then
          motor down $(${BIN_PATH}/busybox expr $TARGET \* -1)
        else
          motor up $TARGET
        fi
      else
        echo Requested $COMMAND is not a number
      fi
    ;;
    "${TOPIC}/motors/horizontal/set left")
      motor left
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motors/horizontal ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motor status horizontal)"
    ;;

    "${TOPIC}/motors/horizontal/set right")
      motor right
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motors/horizontal ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(motor status horizontal)"
    ;;

    "${TOPIC}/set "*)
      COMMAND=$(echo "$line" | awk '{print $2}')
      #echo "$COMMAND"
      curl -k -m 2 ${CURLOPTS} -s https://127.0.0.1/cgi-bin/action.cgi\?cmd="${COMMAND}" -o /dev/null 2>/dev/null
      if [ $? -eq 0 ]; then
        ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}/${COMMAND}" ${MOSQUITTOOPTS} -m "OK (this means: action.cgi invoke with parameter ${COMMAND}, nothing more, nothing less)"
      else
        ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}/error" ${MOSQUITTOOPTS} -m "An error occured when executing ${line}"
      fi
      # Publish updated states
      ${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}" ${MOSQUITTOPUBOPTS} ${MOSQUITTOOPTS} -m "$(${SCRIPT_PATH}/mqtt-status.sh)"
    ;;
  esac
done
