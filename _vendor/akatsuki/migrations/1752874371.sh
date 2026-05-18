echo "Add Catppuccin Latte light theme"

if [[ ! -L $HOME/.config/akatsuki/themes/catppuccin-latte ]]; then
  ln -snf ~/.local/share/akatsuki/themes/catppuccin-latte ~/.config/akatsuki/themes/
fi
