echo "Rename lock screen command in Hypridle config"

if grep -q 'akatsuki-lock-screen' ~/.config/hypr/hypridle.conf; then
  sed -i 's/akatsuki-lock-screen/akatsuki-system-lock/g' ~/.config/hypr/hypridle.conf
  akatsuki-restart-hypridle
fi
