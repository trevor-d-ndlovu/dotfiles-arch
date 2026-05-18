echo "Rename screen recording command"

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"

if [[ -f $WAYBAR_CONFIG ]] && grep -q 'akatsuki-capture-screencording' "$WAYBAR_CONFIG"; then
  sed -i 's/akatsuki-capture-screencording/akatsuki-capture-screenrecording/g' "$WAYBAR_CONFIG"
  akatsuki-restart-waybar
fi
