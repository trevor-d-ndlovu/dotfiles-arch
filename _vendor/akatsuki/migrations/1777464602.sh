echo "Update Waybar screen recording command"

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"

if [[ -f $WAYBAR_CONFIG ]] && grep -q 'akatsuki-cmd-screenrecord' "$WAYBAR_CONFIG"; then
  sed -i 's/akatsuki-cmd-screenrecord/akatsuki-capture-screenrecording/g' "$WAYBAR_CONFIG"
  akatsuki-restart-waybar
fi
