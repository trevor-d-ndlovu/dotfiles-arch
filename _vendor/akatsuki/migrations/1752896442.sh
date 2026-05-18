echo "Replace volume control GUI with a TUI"

if akatsuki-cmd-missing wiremix; then
  akatsuki-pkg-add wiremix
  akatsuki-pkg-drop pavucontrol
  akatsuki-refresh-applications
  akatsuki-refresh-waybar
fi
