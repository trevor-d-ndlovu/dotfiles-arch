echo "Add Logout option to system menu"

akatsuki-refresh-sddm

if [[ -f /etc/sddm.conf.d/autologin.conf ]]; then
  sudo sed -i 's/^Current=.*/Current=akatsuki/' /etc/sddm.conf.d/autologin.conf
fi
