echo "Migrate to proper packages for localsend and asdcontrol"

if akatsuki-pkg-present localsend-bin; then
  akatsuki-pkg-drop localsend-bin
  akatsuki-pkg-add localsend
fi

if akatsuki-pkg-present asdcontrol-git; then
  akatsuki-pkg-drop asdcontrol-git
  akatsuki-pkg-add asdcontrol
fi
