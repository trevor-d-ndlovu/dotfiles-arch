echo "Fix JetBrains font setting"

if [[ $(akatsuki-font-current) == JetBrains* ]]; then
  akatsuki-font-set "JetBrainsMono Nerd Font"
fi
