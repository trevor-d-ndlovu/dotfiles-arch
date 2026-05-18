echo "Add the new ristretto theme as an option"

if [[ ! -L ~/.config/akatsuki/themes/ristretto ]]; then
  ln -nfs ~/.local/share/akatsuki/themes/ristretto ~/.config/akatsuki/themes/
fi
