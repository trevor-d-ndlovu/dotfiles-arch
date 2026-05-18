if [[ $(plymouth-set-default-theme) != "akatsuki" ]]; then
  sudo cp -r "$HOME/.local/share/akatsuki/default/plymouth" /usr/share/plymouth/themes/akatsuki/
  sudo plymouth-set-default-theme akatsuki
fi
