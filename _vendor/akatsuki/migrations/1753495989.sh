echo "Allow updating of timezone by right-clicking on the clock (or running akatsuki-cmd-tzupdate)"

if akatsuki-cmd-missing tzupdate; then
  bash "$AKATSUKI_PATH/install/config/timezones.sh"
  akatsuki-refresh-waybar
fi
