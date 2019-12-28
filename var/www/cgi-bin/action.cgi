#!/bin/sh

echo "Content-type: text/html"
echo "Pragma: no-cache"
echo "Cache-Control: max-age=0, no-store, no-cache"
echo ""

. /usr/scripts/common_functions.sh
. ${WWW_PATH}/cgi-bin/func.cgi

if [ -n "$F_cmd" ]; then
  if [ -z "$F_val" ]; then
    F_val=100
  fi
  case "$F_cmd" in
    showlog)
      echo "<pre>"
      case "${F_logname}" in
        "" | 1)
          echo "Summary of all log files:<br/>"
          tail ${LOG_PATH}/*
          ;;

        2)
          echo "Content of dmesg<br/>"
          /bin/dmesg
          ;;

        3)
          echo "Content of logcat<br/>"
          ${BIN_PATH}/logcat -d # FIXME: logcat not yet part of rootfs
          ;;

        4)
          echo "Content of v4l2rtspserver-master.log<br/>"
          cat ${LOG_PATH}/v4l2rtspserver-master.log
          ;;

        5)
          echo "Content of update.log <br/>"
          cat ${LOG_PATH}/update.log
          ;;

      esac
      echo "</pre>"
      return
    ;;
    clearlog)
      echo "<pre>"
      case "${F_logname}" in
        "" | 1)
          echo "Summary of all log files cleared<br/>"
          for i in ${LOG_PATH}/*
          do
              echo -n "" > $i
          done
          ;;
        2)
          echo "Content of dmesg cleared<br/>"
          /bin/dmesg -c > /dev/null
          ;;
        3)
          echo "Content of logcat cleared<br/>"
          ${BIN_PATH}/logcat -c
          ;;
        4)
          echo "Content of v4l2rtspserver-master.log cleared<br/>"
          echo -n "" > ${LOG_PATH}/v4l2rtspserver-master.log
          ;;
        5)
          echo "Content of update.log cleared <br/>"
          echo -n "" > ${LOG_PATH}/update.log
         ;;
      esac
      echo "</pre>"
      return
    ;;
    reboot)
      echo "Rebooting device..."
      /sbin/reboot
      return
    ;;

    shutdown)
      echo "Shutting down device.."
      /sbin/halt
      return
    ;;

    blue_led_on)
      blue_led on
    ;;

    blue_led_off)
      blue_led off
    ;;

    yellow_led_on)
      yellow_led on
    ;;

    yellow_led_off)
      yellow_led off
    ;;

    ir_led_on)
      ir_led on
    ;;

    ir_led_off)
      ir_led off
    ;;

    ir_cut_on)
      ir_cut on
    ;;

    ir_cut_off)
      ir_cut off
    ;;

    motor_left)
      motor left $F_val
    ;;

    motor_right)
      motor right $F_val
    ;;

    motor_up)
      motor up $F_val
    ;;

    motor_down)
      motor down $F_val
    ;;

    motor_calibrate)
      motor reset_pos_count $F_val
    ;;

    motor_PTZ)
      ${SCRIPT_PATH}/PTZpresets.sh $F_x_axis $F_y_axis
    ;;

    audio_test)
      F_audioSource=$(printf '%b' "${F_audioSource//%/\\x}")
      if [ "$F_audioSource" == "" ]; then
        F_audioSource="/media/police.wav"
      fi
      ${BIN_PATH}/busybox nohup ossplay $F_audioSource -g$F_audiotestVol &
      echo  "Play $F_audioSource at volume $F_audiotestVol"
      return
    ;;

    h264_start)
      ${CONTROLSCRIPT_PATH}/rtsp-h264 start
    ;;

    h264_noseg_start)
      ${CONTROLSCRIPT_PATH}/rtsp-h264 start
    ;;

    mjpeg_start)
      ${CONTROLSCRIPT_PATH}/rtsp-mjpeg start
    ;;

    h264_nosegmentation_start)
      ${CONTROLSCRIPT_PATH}/rtsp-h264 start
    ;;

    rtsp_stop)
      ${CONTROLSCRIPT_PATH}/rtsp-mjpeg stop
      ${CONTROLSCRIPT_PATH}/rtsp-h264 stop
    ;;

    settz)
       ntp_srv=$(printf '%b' "${F_ntp_srv//%/\\x}")
       #read ntp_serv.conf
       conf_ntp_srv=$(cat ${CONFIG_PATH}/ntp_srv.conf)

      if [ $conf_ntp_srv != "$ntp_srv" ]; then
        echo "<p>Setting NTP Server to '$ntp_srv'...</p>"
        echo "$ntp_srv" > ${CONFIG_PATH}/ntp_srv.conf
        echo "<p>Syncing time on '$ntp_srv'...</p>"
        if ${BIN_PATH}/busybox ntpd -q -n -p "$ntp_srv" > /dev/null 2>&1; then
          echo "<p>Success</p>"
        else
          echo "<p>Failed</p>"
        fi
      fi

      tz=$(printf '%b' "${F_tz//%/\\x}")
      if [ "$(cat /etc/TZ)" != "$tz" ]; then
        echo "<p>Setting TZ to '$tz'...</p>"
        echo "$tz" > /etc/TZ
        echo "<p>Syncing time...</p>"
        if ${BIN_PATH}/busybox ntpd -q -n -p "$ntp_srv" > /dev/null 2>&1; then
          echo "<p>Success</p>"
        else echo "<p>Failed</p>"
        fi
      fi
      hst=$(printf '%b' "${F_hostname//%/\\x}")
      if [ "$(cat ${CONFIG_PATH}/hostname)" != "$hst" ]; then
        echo "<p>Setting hostname to '$hst'...</p>"
        echo "$hst" > ${CONFIG_PATH}/hostname
        if hostname "$hst"; then
          echo "<p>Success</p>"
        else echo "<p>Failed</p>"
        fi
      fi
      return
    ;;

    set_http_password)
      password=$(printf '%b' "${F_password//%/\\x}")
      echo "<p>Setting http password to : $password</p>"
      http_password "$password"
    ;;

    osd)
      enabled=$(printf '%b' "${F_OSDenable}")
      axis_enable=$(printf '%b' "${F_AXISenable}")
      position=$(printf '%b' "${F_Position}")
      osdtext=$(printf '%b' "${F_osdtext//%/\\x}")
      osdtext=$(echo "$osdtext" | sed -e "s/\\+/ /g")
      fontName=$(printf '%b' "${F_fontName//%/\\x}")
      fontName=$(echo "$fontName" | sed -e "s/\\+/ /g")

      if [ ! -z "$axis_enable" ];then
        update_axis
        osdtext="${osdtext} ${AXIS}"
        echo "DISPLAY_AXIS=true" > ${CONFIG_PATH}/osd.conf
        echo DISPLAY_AXIS enable
      else
        echo "DISPLAY_AXIS=false" > ${CONFIG_PATH}/osd.conf
        echo DISPLAY_AXIS disable
      fi

      if [ ! -z "$enabled" ]; then
        ${SDCARDBIN_PATH}/setconf -k o -v "$osdtext"
        echo "OSD=\"${osdtext}\"" | sed -r 's/[ ]X=.*"/"/' >> ${CONFIG_PATH}/osd.conf
        echo "OSD set"
      else
        echo "OSD removed"
        ${SDCARDBIN_PATH}/setconf -k o -v ""
        echo "OSD=\"\" " >> ${CONFIG_PATH}/osd.conf
      fi

      echo "COLOR=${F_color}" >> ${CONFIG_PATH}/osd.conf
      ${SDCARDBIN_PATH}/setconf -k c -v "${F_color}"

      echo "SIZE=${F_OSDSize}" >> ${CONFIG_PATH}/osd.conf
      ${SDCARDBIN_PATH}/setconf -k s -v "${F_OSDSize}"

      echo "POSY=${F_posy}" >> ${CONFIG_PATH}/osd.conf
      ${SDCARDBIN_PATH}/setconf -k x -v "${F_posy}"

      echo "FIXEDW=${F_fixedw}" >> ${CONFIG_PATH}/osd.conf
      ${SDCARDBIN_PATH}/setconf -k w -v "${F_fixedw}"

      echo "SPACE=${F_spacepixels}" >> ${CONFIG_PATH}/osd.conf
      ${SDCARDBIN_PATH}/setconf -k p -v "${F_spacepixels}"

      echo "FONTNAME=${fontName}" >> ${CONFIG_PATH}/osd.conf
      ${SDCARDBIN_PATH}/setconf -k e -v "${fontName}"
      return
    ;;

    setldravg)
      ldravg=$(printf '%b' "${F_avg/%/\\x}")
      ldravg=$(echo "$ldravg" | sed "s/[^0-9]//g")
      echo AVG="$ldravg" > ${CONFIG_PATH}/ldr-average.conf
      echo "Average set to $ldravg iterations."
      return
    ;;

    auto_night_mode_start)
      ${CONTROLSCRIPT_PATH}/auto-night-detection start
    ;;

    auto_night_mode_stop)
      ${CONTROLSCRIPT_PATH}/auto-night-detection stop
    ;;

    toggle-rtsp-nightvision-on)
      ${SDCARDBIN_PATH}/setconf -k n -v 1
    ;;

    toggle-rtsp-nightvision-off)
      ${SDCARDBIN_PATH}/setconf -k n -v 0
    ;;

    flip-on)
      rewrite_config ${CONFIG_PATH}/rtspserver.conf FLIP "ON"
      ${SDCARDBIN_PATH}/setconf -k f -v 1
    ;;

    flip-off)
      rewrite_config ${CONFIG_PATH}/rtspserver.conf FLIP "OFF"
      ${SDCARDBIN_PATH}/setconf -k f -v 0
    ;;

    motion_detection_on)
        motion_sensitivity=4
        if [ -f ${CONFIG_PATH}/motion.conf ]; then
            source ${CONFIG_PATH}/motion.conf
        fi
        if [ $motion_sensitivity -eq -1 ]; then
             motion_sensitivity=4
        fi
        ${SDCARDBIN_PATH}/setconf -k m -v $motion_sensitivity
        rewrite_config ${CONFIG_PATH}/motion.conf motion_sensitivity $motion_sensitivity
    ;;

    motion_detection_off)
      ${SDCARDBIN_PATH}/setconf -k m -v -1
    ;;

    set_video_size)
      video_size=$(echo "${F_video_size}"| sed -e 's/+/ /g')
      video_format=$(printf '%b' "${F_video_format/%/\\x}")
      brbitrate=$(printf '%b' "${F_brbitrate/%/\\x}")
      videopassword=$(printf '%b' "${F_videopassword//%/\\x}")
      videouser=$(printf '%b' "${F_videouser//%/\\x}")
      videoport=$(echo "${F_videoport}"| sed -e 's/+/ /g')
      frmRateDen=$(printf '%b' "${F_frmRateDen/%/\\x}")
      frmRateNum=$(printf '%b' "${F_frmRateNum/%/\\x}")

      rewrite_config ${CONFIG_PATH}/rtspserver.conf RTSPH264OPTS "\"$video_size\""
      rewrite_config ${CONFIG_PATH}/rtspserver.conf RTSPMJPEGOPTS "\"$video_size\""
      rewrite_config ${CONFIG_PATH}/rtspserver.conf BITRATE "$brbitrate"
      rewrite_config ${CONFIG_PATH}/rtspserver.conf VIDEOFORMAT "$video_format"
      rewrite_config ${CONFIG_PATH}/rtspserver.conf USERNAME "$videouser"
      rewrite_config ${CONFIG_PATH}/rtspserver.conf USERPASSWORD "$videopassword"
      rewrite_config ${CONFIG_PATH}/rtspserver.conf PORT "$videoport"
      if [ "$frmRateDen" != "" ]; then
        rewrite_config ${CONFIG_PATH}/rtspserver.conf FRAMERATE_DEN "$frmRateDen"
      fi
      if [ "$frmRateNum" != "" ]; then
        rewrite_config ${CONFIG_PATH}/rtspserver.conf FRAMERATE_NUM "$frmRateNum"
      fi

      echo "Video resolution set to $video_size<br/>"
      echo "Bitrate set to $brbitrate<br/>"
      echo "FrameRate set to $frmRateDen/$frmRateNum <br/>"
      ${SDCARDBIN_PATH}/setconf -k d -v "$frmRateNum,$frmRateDen" 2>/dev/null
      echo "Video format set to $video_format<br/>"

      if [ "$(rtsp_h264_server status)" = "ON" ]; then
        rtsp_h264_server off
        rtsp_h264_server on
      fi
      if [ "$(rtsp_mjpeg_server status)" = "ON" ]; then
        rtsp_mjpeg_server off
        rtsp_mjpeg_server on
      fi
      return
    ;;

    set_region_of_interest)
        rewrite_config ${CONFIG_PATH}/motion.conf region_of_interest "${F_x0},${F_y0},${F_x1},${F_y1}"
        rewrite_config ${CONFIG_PATH}/motion.conf motion_sensitivity "${F_motion_sensitivity}"
        rewrite_config ${CONFIG_PATH}/motion.conf motion_indicator_color "${F_motion_indicator_color}"
        rewrite_config ${CONFIG_PATH}/motion.conf motion_timeout "${F_motion_timeout}"
        if [ "${F_motion_tracking}X" == "X" ]; then
          rewrite_config ${CONFIG_PATH}/motion.conf motion_tracking off
          ${SDCARDBIN_PATH}/setconf -k t -v off
        else
          rewrite_config ${CONFIG_PATH}/motion.conf motion_tracking on
          ${SDCARDBIN_PATH}/setconf -k t -v on
        fi

        ${SDCARDBIN_PATH}/setconf -k r -v ${F_x0},${F_y0},${F_x1},${F_y1}
        ${SDCARDBIN_PATH}/setconf -k m -v ${F_motion_sensitivity}
        ${SDCARDBIN_PATH}/setconf -k z -v ${F_motion_indicator_color}
        ${SDCARDBIN_PATH}/setconf -k u -v ${F_motion_timeout}

        # Changed the detection region, need to restart the server
        if [ ${F_restart_server} == "1" ]
        then
            if [ "$(rtsp_h264_server status)" == "ON" ]; then
                rtsp_h264_server off
                rtsp_h264_server on
            fi
            if [ "$(rtsp_mjpeg_server status)" == "ON" ]; then
                rtsp_mjpeg_server off
                rtsp_mjpeg_server on
            fi
        fi

        echo "Motion Configuration done"
        return
    ;;

    autonight_sw)
      if [ ! -f ${CONFIG_PATH}/autonight.conf ]; then
        echo "-S" > ${CONFIG_PATH}/autonight.conf
      fi
      current_setting=$(sed 's/-S *//g' ${CONFIG_PATH}/autonight.conf)
      echo "-S" $current_setting > ${CONFIG_PATH}/autonight.conf
    ;;

    autonight_hw)
      if [ -f ${CONFIG_PATH}/autonight.conf ]; then
        sed -i 's/-S *//g' ${CONFIG_PATH}/autonight.conf
      fi
    ;;

    get_sw_night_config)
      cat ${CONFIG_PATH}/autonight.conf
      exit
    ;;

    save_sw_night_config)
      #This also enables software mode
      night_mode_conf=$(echo "${F_val}"| sed "s/+/ /g" | sed "s/%2C/,/g")
      echo $night_mode_conf > ${CONFIG_PATH}/autonight.conf
      echo Saved $night_mode_conf
    ;;

    offDebug)
      ${CONTROLSCRIPT_PATH}/debug-on-osd stop
    ;;

    onDebug)
      ${CONTROLSCRIPT_PATH}/debug-on-osd start
    ;;

    conf_timelapse)
      tlinterval=$(printf '%b' "${F_tlinterval/%/\\x}")
      tlinterval=$(echo "$tlinterval" | sed "s/[^0-9\.]//g")
      if [ "$tlinterval" ]; then
        rewrite_config ${CONFIG_PATH}/timelapse.conf TIMELAPSE_INTERVAL "$tlinterval"
        echo "Timelapse interval set to $tlinterval seconds."
      else
        echo "Invalid timelapse interval"
      fi
      tlduration=$(printf '%b' "${F_tlduration/%/\\x}")
      tlduration=$(echo "$tlduration" | sed "s/[^0-9\.]//g")
      if [ "$tlduration" ]; then
        rewrite_config ${CONFIG_PATH}/timelapse.conf TIMELAPSE_DURATION "$tlduration"
        echo "Timelapse duration set to $tlduration minutes."
      else
        echo "Invalid timelapse duration"
      fi
      return
    ;;

    conf_audioin)
       audioinFormat=$(printf '%b' "${F_audioinFormat/%/\\x}")
       audioinBR=$(printf '%b' "${F_audioinBR/%/\\x}")
       audiooutBR=$(printf '%b' "${F_audiooutBR/%/\\x}")

       if [ "$audioinBR" == "" ]; then
            audioinBR="8000"
       fi
       if [ "$audiooutBR" == "" ]; then
           audioOutBR = audioinBR
       fi
       if [ "$audioinFormat" == "OPUS" ]; then
            audioOutBR="48000"
       fi
       if [ "$audioinFormat" == "PCM" ]; then
            audioOutBR = audioinBR
       fi
       if [ "$audioinFormat" == "PCMU" ]; then
           audioOutBR = audioinBR
       fi

       rewrite_config ${CONFIG_PATH}/rtspserver.conf AUDIOFORMAT "$audioinFormat"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf AUDIOINBR "$audioinBR"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf AUDIOOUTBR "$audiooutBR"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf FILTER "$F_audioinFilter"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf HIGHPASSFILTER "$F_HFEnabled"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf AECFILTER "$F_AECEnabled"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf HWVOLUME "$F_audioinVol"
       rewrite_config ${CONFIG_PATH}/rtspserver.conf SWVOLUME "-1"

       echo "Audio format $audioinFormat <BR>"
       echo "In audio bitrate $audioinBR <BR>"
       echo "Out audio bitrate $audiooutBR <BR>"
       echo "Filter $F_audioinFilter <BR>"
       echo "High Pass Filter $F_HFEnabled <BR>"
       echo "AEC Filter $F_AECEnabled <BR>"
       echo "Volume $F_audioinVol <BR>"
       ${SDCARDBIN_PATH}/setconf -k q -v "$F_audioinFilter" 2>/dev/null
       ${SDCARDBIN_PATH}/setconf -k l -v "$F_HFEnabled" 2>/dev/null
       ${SDCARDBIN_PATH}/setconf -k a -v "$F_AECEnabled" 2>/dev/null
       ${SDCARDBIN_PATH}/setconf -k h -v "$F_audioinVol" 2>/dev/null
       return
     ;;
     update)
        processId=$(ps | grep autoupdate.sh | grep -v grep)
        if [ "$processId" == "" ]
        then
            echo "===============" >> ${LOG_PATH}/update.log
            date >> ${LOG_PATH}/update.log
            if [ "$F_login" != "" ]; then
                ${BIN_PATH}/busybox nohup /usr/scripts/autoupdate.sh -s -v -f -u $F_login  >> "${LOG_PATH}/update.log" &
            else
                ${BIN_PATH}/busybox nohup /usr/scripts/autoupdate.sh -s -v -f >> "${LOG_PATH}/update.log" &
            fi
            processId=$(ps | grep autoupdate.sh | grep -v grep)
        fi
        echo $processId
        return
      ;;
     show_updateProgress)
        processId=$(ps | grep autoupdate.sh | grep -v grep)
        if [ "$processId" == "" ]
        then
            echo -n -1
        else
            if [ -f /tmp/progress ] ; then
                cat /tmp/progress
            else
                echo -n 0
            fi
        fi
        return
        ;;
     motion_detection_mail_on)
         rewrite_config ${CONFIG_PATH}/motion.conf sendemail "true"
         return
         ;;
     motion_detection_mail_off)
          rewrite_config ${CONFIG_PATH}/motion.conf sendemail "false"
          return
          ;;

     motion_detection_telegram_on)
          rewrite_config ${CONFIG_PATH}/motion.conf send_telegram "true"
          return
          ;;

     motion_detection_telegram_off)
          rewrite_config ${CONFIG_PATH}/motion.conf send_telegram "false"
          return
          ;;

     motion_detection_led_on)
          rewrite_config ${CONFIG_PATH}/motion.conf motion_trigger_led "true"
          return
          ;;
     motion_detection_led_off)
          rewrite_config ${CONFIG_PATH}/motion.conf motion_trigger_led "false"
          return
          ;;
     motion_detection_snapshot_on)
          rewrite_config ${CONFIG_PATH}/motion.conf save_snapshot "true"
          return
          ;;
     motion_detection_snapshot_off)
          rewrite_config ${CONFIG_PATH}/motion.conf save_snapshot "false"
          return
          ;;
     motion_detection_mqtt_publish_on)
          rewrite_config ${CONFIG_PATH}/motion.conf publish_mqtt_message "true"
          return
          ;;
     motion_detection_mqtt_publish_off)
          rewrite_config ${CONFIG_PATH}/motion.conf publish_mqtt_message "false"
          return
          ;;
     motion_detection_mqtt_snapshot_on)
          rewrite_config ${CONFIG_PATH}/motion.conf publish_mqtt_snapshot "true"
          return
          ;;

     motion_detection_mqtt_snapshot_off)
          rewrite_config ${CONFIG_PATH}/motion.conf publish_mqtt_snapshot "false"
          return
          ;;

     *)
        echo "Unsupported command '$F_cmd'"
        ;;

  esac
fi

echo "<hr/>"
echo "<button title='Return to status page' onClick=\"window.location.href='status.cgi'\">Back</button>"
