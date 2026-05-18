echo "Use Akatsuki UWSM session without graphical.target startup wait"

sudo mkdir -p /usr/local/share/wayland-sessions
sudo cp "$AKATSUKI_PATH/default/wayland-sessions/akatsuki.desktop" /usr/local/share/wayland-sessions/akatsuki.desktop

if [[ -f /etc/sddm.conf.d/autologin.conf ]]; then
  sudo sed -i 's/^Session=hyprland-uwsm$/Session=akatsuki/' /etc/sddm.conf.d/autologin.conf
fi
