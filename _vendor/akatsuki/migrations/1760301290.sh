echo "Add the new Flexoki Light theme"

if [[ ! -L ~/.config/akatsuki/themes/flexoki-light ]]; then
  ln -nfs ~/.local/share/akatsuki/themes/flexoki-light ~/.config/akatsuki/themes/
fi
