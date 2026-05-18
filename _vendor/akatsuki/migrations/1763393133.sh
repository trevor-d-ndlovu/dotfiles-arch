echo "Link new theme picker config"

mkdir -p ~/.config/elephant/menus
ln -snf $AKATSUKI_PATH/default/elephant/akatsuki_themes.lua ~/.config/elephant/menus/akatsuki_themes.lua
sed -i '/"menus",/d' ~/.config/walker/config.toml
akatsuki-restart-walker
