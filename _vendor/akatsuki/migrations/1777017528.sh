echo "Show battery status notification on right-click of the waybar battery icon"

if ! grep -q 'akatsuki-battery-status' ~/.config/waybar/config.jsonc; then
  sed -i '/"on-click": "akatsuki-menu power",/a\    "on-click-right": "notify-send -u low \\"$(akatsuki-battery-status)\\"",' ~/.config/waybar/config.jsonc
  akatsuki-restart-waybar
fi
