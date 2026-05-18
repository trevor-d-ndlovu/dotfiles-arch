echo "Use explicit timezone selector when right-clicking on clock"

sed -i 's/akatsuki-cmd-tzupdate/akatsuki-launch-floating-terminal-with-presentation akatsuki-tz-select/g' ~/.config/waybar/config.jsonc
