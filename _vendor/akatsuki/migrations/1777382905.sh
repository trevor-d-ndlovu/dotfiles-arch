echo "Use interactive unlock (Plymouth) selector menu"

mkdir -p ~/.config/elephant/menus
ln -snf $AKATSUKI_PATH/default/elephant/akatsuki_unlocks.lua ~/.config/elephant/menus/akatsuki_unlocks.lua
akatsuki-restart-walker
