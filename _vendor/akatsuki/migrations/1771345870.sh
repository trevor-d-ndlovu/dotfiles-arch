echo "Switch lmstudio -> lmstudio-bin"

if pacman -Q lmstudio &>/dev/null; then
  akatsuki-pkg-drop lmstudio
  akatsuki-pkg-add lmstudio-bin
fi
