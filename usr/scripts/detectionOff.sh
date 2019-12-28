#!/bin/sh

. /usr/scripts/common_functions.sh
# Source your custom motion configurations
. ${CONFIG_PATH}/motion.conf

# Turn off the amber LED
if [ "$motion_trigger_led" = true ] ; then
	yellow_led off
fi

# Publish a mqtt message
if [ "$publish_mqtt_message" = true ] ; then
	. ${CONFIG_PATH}/mqtt.conf
	${SDCARDBIN_PATH}/mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion ${MOSQUITTOOPTS} ${MOSQUITTOPUBOPTS} -m "OFF"
fi

# Run any user scripts.
for i in ${CONFIG_PATH}/userscripts/motiondetection/*; do
    if [ -x $i ]; then
        echo "Running: $i off"
        $i off
    fi
done
