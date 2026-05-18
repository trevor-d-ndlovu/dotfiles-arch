echo "Add right-click terminal action to waybar akatsuki menu icon"

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"

if [[ -f $WAYBAR_CONFIG ]] && ! grep -A5 '"custom/akatsuki"' "$WAYBAR_CONFIG" | grep -q '"on-click-right"'; then
  sed -i '/"on-click": "akatsuki-menu",/a\    "on-click-right": "akatsuki-launch-terminal",' "$WAYBAR_CONFIG"
fi
