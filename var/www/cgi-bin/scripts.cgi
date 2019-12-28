#!/bin/sh

source /usr/scripts/common_functions.sh

source ${WWW_PATH}/cgi-bin/func.cgi

echo "Pragma: no-cache"
echo "Cache-Control: max-age=0, no-store, no-cache"

if [ -n "$F_script" ]; then
  script="${F_script##*/}"
  if [ -e "$CONTROLSCRIPT_PATH/$script" ]; then
    case "$F_cmd" in
      start)
        echo "Content-type: text/html"
        echo ""

        echo "<p>Running script "$script"...</p>"
        echo "<pre>$("$CONTROLSCRIPT_PATH/$script" 2>&1)</pre>"
        ;;
      disable)
        rm "${CONFIG_PATH}/autostart/$script"
        echo "Content-type: application/json"
        echo ""
        echo "{\"status\": \"ok\"}"
        ;;
      stop)
        echo "Content-type: text/html"
        echo ""
        status='unknown'
        echo "<p>Stopping script "$script"...</p>"
        echo "<pre>"
        "$CONTROLSCRIPT_PATH/$script" stop 2>&1 && echo "OK" || echo "NOK"
        echo "</pre>"
        ;;
      enable)
        echo "#!/bin/sh" > "${CONFIG_PATH}/autostart/$script"
        echo ${CONTROLSCRIPT_PATH}/$script >> "${CONFIG_PATH}/autostart/$script"
        echo "<pre>$(chmod 744 "${CONFIG_PATH}/autostart/$script" 2>&1) </pre>"
        echo "Content-type: application/json"
        echo ""
        echo "{\"status\": \"ok\"}"
        ;;
      view)
        echo "Content-type: text/html"
        echo ""
        echo "<p>Contents of script "$script":</p>"
        echo "<pre>$(cat "$CONTROLSCRIPT_PATH/$script" 2>&1)</pre>"
        ;;
      *)
        echo "Content-type: text/html"
        echo ""
        echo "<p>Unsupported command '$F_cmd'</p>"
        ;;
    esac
  else
    echo "Content-type: text/html"
    echo ""
    echo "<p>$F_script is not a valid script!</p>"
  fi
  return
fi

echo "Content-type: text/html"
echo ""

if [ ! -d "$CONTROLSCRIPT_PATH" ]; then
  echo "<p>No scripts.cgi found in $CONTROLSCRIPT_PATH</p>"
else
  SCRIPTS=$(ls -A "$CONTROLSCRIPT_PATH")

  for i in $SCRIPTS; do
    # Card - start
    echo "<div class='card script_card'>"
    # Header
    echo "<header class='card-header'><p class='card-header-title'>"
    # echo "<div class='card-content'>"
    if [ -x "$CONTROLSCRIPT_PATH/$i" ]; then
      if grep -q "^status()" "$CONTROLSCRIPT_PATH/$i"; then
        status=$("$CONTROLSCRIPT_PATH/$i" status)
        if [ $? -eq 0 ]; then
          if [ -n "$status" ]; then
            badge="";
          else
            badge="is-badge-warning";
          fi
        else
          badge="is-badge-danger"
          status="NOK"
        fi
        echo "<span class='badge $badge' data-badge='$status'>$i</span>"
      else
        echo "$i"
      fi
      # echo "</div>"
      echo "</p></header>"

      # Footer
      echo "<footer class='card-footer'>"
      echo "<span class='card-footer-item'>"

      # Start / Stop / Run buttons
      echo "<div class='buttons'>"
      if grep -q "^start()" "$CONTROLSCRIPT_PATH/$i"; then
        echo "<button data-target='cgi-bin/scripts.cgi?cmd=start&script=$i' class='button is-link script_action_start' data-script='$i' "
        if [ ! -z "$status" ]; then
          echo "disabled"
        fi
        echo ">Start</button>"
      else
        echo "<button data-target='cgi-bin/scripts.cgi?cmd=start&script=$i' class='button is-link script_action_start' data-script='$i' "
        echo ">Run</button>"
      fi

      if grep -q "^stop()" "$CONTROLSCRIPT_PATH/$i"; then
        echo "<button data-target='cgi-bin/scripts.cgi?cmd=stop&script=$i' class='button is-danger script_action_stop' data-script='$i' "
        if [ ! -n "$status" ]; then
          echo "disabled"
        fi
        echo ">Stop</button>"
      fi
      echo "</div>"
      echo "</span>"

      # Autostart Switch
      echo "<span class='card-footer-item'>"
      echo "<input type='checkbox' id='autorun_$i' name='autorun_$i' class='switch is-rtl autostart' data-script='$i' "
        echo " data-unchecked='cgi-bin/scripts.cgi?cmd=disable&script=$i'"
        echo " data-checked='cgi-bin/scripts.cgi?cmd=enable&script=$i'"
      if [ -f "${CONFIG_PATH}/autostart/$i" ]; then
        echo " checked='checked'"
      fi
      echo "'>"
      echo "<label for='autorun_$i'>Autorun</label>"
      echo "</span>"

      # View link
      echo "<a href='cgi-bin/scripts.cgi?cmd=view&script=$i' class='card-footer-item view_script' data-script="$i">View</a>"
      echo "</footer>"
    fi
    # Card - End
    echo "</div>"
  done
fi

script=$(cat ${WWW_PATH}/scripts/scripts.cgi.js)
echo "<script>$script</script>"
