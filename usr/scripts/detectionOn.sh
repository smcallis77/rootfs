#!/bin/sh

. /usr/scripts/common_functions.sh
# Source your custom motion configurations
. ${CONFIG_PATH}/motion.conf

include ${CONFIG_PATH}/telegram.conf

# Turn on the amber led
if [ "$motion_trigger_led" = true ] ; then
	yellow_led on
fi

# Save a snapshot
if [ "$save_snapshot" = true ] ; then
	pattern="${save_file_date_pattern:-+%d-%m-%Y_%H.%M.%S}"
	filename=$(date $pattern).jpg
	if [ ! -d "$save_dir" ]; then
		mkdir -p "$save_dir"
	fi
	{
		# Limit the number of snapshots
		if [ "$(ls "$save_dir" | wc -l)" -ge "$max_snapshots" ]; then
			rm -f "$save_dir/$(ls -ltr "$save_dir" | awk 'NR==2{print $9}')"
		fi
	} &
	${SDCARDBIN_PATH}/getimage > "$save_dir/$filename" &
fi

# Publish a mqtt message
if [ "$publish_mqtt_message" = true ] ; then
	. ${CONFIG_PATH}/mqtt.conf
	${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion ${MOSQUITTOOPTS} ${MOSQUITTOPUBOPTS} -m "ON"
fi

# The MQTT publish uses a separate image from the "save_snapshot" to keep things simple
if [ "$publish_mqtt_snapshot" = true ] ; then
	${SDCARDBIN_PATH}/getimage > /tmp/last_image.jpg
	${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion/snapshot ${MOSQUITTOOPTS} ${MOSQUITTOPUBOPTS} -f /tmp/last_image.jpg
	rm /tmp/last_image.jpg
fi

# Send emails ...
if [ "$send_email" = true ] ; then
    ${SCRIPT_PATH}/sendPictureMail.sh&
fi

# Send a telegram message
if [ "$send_telegram" = true ]; then
	if [ "$telegram_alert_type" = "text" ] ; then
		${SDCARDBIN_PATH}/telegram m "Motion detected"
	else
		if [ "$save_snapshot" = true ] ; then
			${SDCARDBIN_PATH}/telegram p "$save_dir/$filename"
		else
			${SDCARDBIN_PATH}/getimage > "/tmp/telegram_image.jpg"
	 		${SDCARDBIN_PATH}/telegram p "/tmp/telegram_image.jpg"
	 		rm "/tmp/telegram_image.jpg"
		fi
	fi
fi

# Run any user scripts.
for i in ${CONFIG_PATH}/userscripts/motiondetection/*; do
    if [ -x "$i" ]; then
        echo "Running: $i on $save_dir/$filename"
        $i on "$save_dir/$filename" &
    fi
done
