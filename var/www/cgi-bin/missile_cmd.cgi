#!/bin/sh

source /usr/scripts/common_functions.sh

source ./func.cgi
export LD_LIBRARY_PATH=/system/sdcard/lib
CMD=$F_cmd

${SDCARDBIN_PATH}/USBMissileLauncherUtils "$CMD" -S 200

echo "Content-type: text/html"
echo ""
