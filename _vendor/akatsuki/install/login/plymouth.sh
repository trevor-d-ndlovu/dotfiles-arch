if command -v plymouth-set-default-theme &>/dev/null; then
  if [[ $(plymouth-set-default-theme) != "akatsuki" ]]; then
    sudo cp -r "$AKATSUKI_PATH/default/plymouth" /usr/share/plymouth/themes/akatsuki/
    sudo plymouth-set-default-theme akatsuki
  fi
fi
