echo "Uniquely identify terminal apps with custom app-ids using akatsuki-launch-tui"

# Replace terminal -e calls with akatsuki-launch-tui in bindings
sed -i 's/\$terminal -e \([^ ]*\)/akatsuki-launch-tui \1/g' ~/.config/hypr/bindings.conf

# Update waybar to use akatsuki-launch-or-focus with akatsuki-launch-tui for TUI apps
sed -i 's|xdg-terminal-exec btop|akatsuki-launch-or-focus-tui btop|' ~/.config/waybar/config.jsonc
sed -i 's|xdg-terminal-exec --app-id=com\.akatsuki\.Wiremix -e wiremix|akatsuki-launch-or-focus-tui wiremix|' ~/.config/waybar/config.jsonc
