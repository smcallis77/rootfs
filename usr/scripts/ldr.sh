#!/bin/sh

. /usr/scripts/common_functions.sh

while true; do
  if [ -f ${CONFIG_PATH}/ldr-average.conf ]; then
    . ${CONFIG_PATH}/ldr-average.conf 2>/dev/null
    #read config in every iteration, so we can change the average online
  fi

  if [ -z "$AVG" ]; then AVG=1; fi
  # if no config availabe, use 1 as average

  dd if=/dev/jz_adc_aux_0 count=20  |  sed -e 's/[^\.]//g' | wc -m >> ${RUN_PATH}/ldr
  # Add new line to file with measurements

  tail -n $AVG ${RUN_PATH}/ldr > ${RUN_PATH}/ldr-temp
  mv ${RUN_PATH}/ldr-temp  ${RUN_PATH}/ldr
  # cut ${RUN_PATH}/ldr to desired number of lines

  LINES=$(wc -l < ${RUN_PATH}/ldr)
  if [ "$LINES" -lt "$AVG" ]; then AVG=$LINES; fi
  # to avoid slow switching when starting up, use the number of lines when there are less than the average
  # this may cause some flickering when starting up

  SUM=$(awk '{s+=$1} END {printf "%.0f", s}' ${RUN_PATH}/ldr)
  [[ ! $SUM -eq 0 || ! $AVG -eq 0 ]] && AVGMEASUREMENT=$(($SUM/$AVG)) || AVGMEASUREMENT=0 # calculate the average


  if [ "$AVGMEASUREMENT" -lt 50 ]; then  # Light detected
    night_mode off
  else # nothing in Buffer -> no light
    night_mode on
  fi
  sleep 10
done
