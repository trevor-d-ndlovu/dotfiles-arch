echo "Update Waybar for new Akatsuki menu"

if ! grep -q "" ~/.config/waybar/config.jsonc; then
  akatsuki-refresh-waybar
fi
