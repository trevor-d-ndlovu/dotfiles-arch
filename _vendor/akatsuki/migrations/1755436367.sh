echo "Add minimal starship prompt to terminal"

if akatsuki-cmd-missing starship; then
  akatsuki-pkg-add starship
  cp $AKATSUKI_PATH/config/starship.toml ~/.config/starship.toml
fi
