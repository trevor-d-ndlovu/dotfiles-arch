echo "Install Impala as new wifi selection TUI"

if akatsuki-cmd-missing impala; then
  akatsuki-pkg-add impala
  akatsuki-refresh-waybar
fi
