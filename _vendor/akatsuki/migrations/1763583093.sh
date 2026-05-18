echo "Make ethereal available as new theme"

if [[ ! -L ~/.config/akatsuki/themes/ethereal ]]; then
  rm -rf ~/.config/akatsuki/themes/ethereal
  ln -nfs ~/.local/share/akatsuki/themes/ethereal ~/.config/akatsuki/themes/
fi
