echo "Update fastfetch config with new Akatsuki logo"

akatsuki-refresh-config fastfetch/config.jsonc

mkdir -p ~/.config/akatsuki/branding
cp $AKATSUKI_PATH/icon.txt ~/.config/akatsuki/branding/about.txt
