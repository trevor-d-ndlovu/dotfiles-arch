#!/bin/bash

# Ensure Walker service is started automatically on boot
mkdir -p ~/.config/autostart/
cp $AKATSUKI_PATH/default/walker/walker.desktop ~/.config/autostart/

# And is restarted if it crashes or is killed
mkdir -p ~/.config/systemd/user/app-walker@autostart.service.d/
cp $AKATSUKI_PATH/default/walker/restart.conf ~/.config/systemd/user/app-walker@autostart.service.d/restart.conf

# Create pacman hook to restart walker after updates
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/walker-restart.hook > /dev/null << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = walker
Target = walker-debug
Target = elephant*

[Action]
Description = Restarting Walker services after system update
When = PostTransaction
Exec = $AKATSUKI_PATH/bin/akatsuki-restart-walker
EOF

# Link the visual theme menu config
mkdir -p ~/.config/elephant/menus
ln -snf $AKATSUKI_PATH/default/elephant/akatsuki_themes.lua ~/.config/elephant/menus/akatsuki_themes.lua
ln -snf $AKATSUKI_PATH/default/elephant/akatsuki_background_selector.lua ~/.config/elephant/menus/akatsuki_background_selector.lua
ln -snf $AKATSUKI_PATH/default/elephant/akatsuki_unlocks.lua ~/.config/elephant/menus/akatsuki_unlocks.lua
