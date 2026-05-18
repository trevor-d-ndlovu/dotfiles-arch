echo "Make new Osaka Jade theme available as new default"

if [[ ! -L ~/.config/akatsuki/themes/osaka-jade ]]; then
  rm -rf ~/.config/akatsuki/themes/osaka-jade
  git -C ~/.local/share/akatsuki checkout -f themes/osaka-jade
  ln -nfs ~/.local/share/akatsuki/themes/osaka-jade ~/.config/akatsuki/themes/osaka-jade
fi
