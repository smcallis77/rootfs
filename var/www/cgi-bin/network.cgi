#!/bin/sh

echo "Content-type: text/html"
echo "Pragma: no-cache"
echo "Cache-Control: max-age=0, no-store, no-cache"
echo ""

source /usr/scripts/common_functions.sh

source ${WWW_PATH}/cgi-bin/func.cgi
if [ -e "/etc/fang_hacks.cfg" ]; then source /etc/fang_hacks.cfg; fi
PATH="/bin:/sbin:/usr/bin:${BIN_PATH}"

cat << EOF
Information:
<pre>Interfaces:<br/>$(ifconfig; iwconfig)</pre>
<pre>Routes:<br/>$(route)</pre>
<pre>DNS:<br/>$(cat /etc/resolv.conf)</pre>
</body>
</html>
EOF


