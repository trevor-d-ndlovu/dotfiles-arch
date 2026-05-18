echo "Install swayOSD to show volume status"

if akatsuki-cmd-missing swayosd-server; then
  akatsuki-pkg-add swayosd
  setsid uwsm-app -- swayosd-server &>/dev/null &
fi
