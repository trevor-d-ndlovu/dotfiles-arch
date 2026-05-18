echo "Add sample post-boot hook"

mkdir -p ~/.config/akatsuki/hooks/post-boot.d

if [[ ! -f ~/.config/akatsuki/hooks/post-boot.d/weather.sample ]]; then
  cp "$AKATSUKI_PATH/config/akatsuki/hooks/post-boot.d/weather.sample" ~/.config/akatsuki/hooks/post-boot.d/weather.sample
fi
