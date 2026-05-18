echo "Add new matte black theme"

if [[ ! -L $HOME/.config/akatsuki/themes/matte-black ]]; then
  ln -snf ~/.local/share/akatsuki/themes/matte-black ~/.config/akatsuki/themes/
fi
