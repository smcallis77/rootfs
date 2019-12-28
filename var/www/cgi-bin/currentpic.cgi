#!/bin/sh

source /usr/scripts/common_functions.sh

echo "Content-type: image/jpeg"
echo ""
${SDCARDBIN_PATH}/getimage
