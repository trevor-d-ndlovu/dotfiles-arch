echo "Replace wofi with walker as the default launcher"

if akatsuki-cmd-missing walker; then
  akatsuki-pkg-add walker-bin libqalculate

  akatsuki-pkg-drop wofi
  rm -rf ~/.config/wofi

  mkdir -p ~/.config/walker
  cp -r ~/.local/share/akatsuki/config/walker/* ~/.config/walker/
fi
