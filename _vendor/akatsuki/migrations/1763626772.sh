echo "Make hackerman available as new theme"

if [[ ! -L ~/.config/akatsuki/themes/hackerman ]]; then
  rm -rf ~/.config/akatsuki/themes/hackerman
  ln -nfs ~/.local/share/akatsuki/themes/hackerman ~/.config/akatsuki/themes/
fi
