echo "Add sample low battery notification hook"

mkdir -p ~/.config/akatsuki/hooks/battery-low.d

if [[ ! -f ~/.config/akatsuki/hooks/battery-low.d/play-warning-sound.sample ]]; then
  cp "$AKATSUKI_PATH/config/akatsuki/hooks/battery-low.d/play-warning-sound.sample" ~/.config/akatsuki/hooks/battery-low.d/play-warning-sound.sample
fi
