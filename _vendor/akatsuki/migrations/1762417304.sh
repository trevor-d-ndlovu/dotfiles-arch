echo "Replace bluetooth GUI with TUI"

akatsuki-pkg-add bluetui
akatsuki-pkg-drop blueberry

if ! grep -q "akatsuki-launch-bluetooth" ~/.config/waybar/config.jsonc; then
  sed -i 's/blueberry/akatsuki-launch-bluetooth/' ~/.config/waybar/config.jsonc
fi
