echo "Add opencode with system theming"

akatsuki-pkg-add opencode

# Add config using akatsuki theme by default
if [[ ! -f ~/.config/opencode/opencode.json ]]; then
  mkdir -p ~/.config/opencode
  cp $AKATSUKI_PATH/config/opencode/opencode.json ~/.config/opencode/opencode.json
fi
