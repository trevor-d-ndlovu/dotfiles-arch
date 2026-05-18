echo "Use interactive background selector menu"

mkdir -p ~/.config/elephant/menus
ln -snf $AKATSUKI_PATH/default/elephant/akatsuki_background_selector.lua ~/.config/elephant/menus/akatsuki_background_selector.lua
akatsuki-restart-walker
