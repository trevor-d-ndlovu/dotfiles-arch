# Place in each assistant's global skills directory so the Akatsuki skill is available on first install
mkdir -p ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills
ln -sfn "$AKATSUKI_PATH/default/akatsuki-skill" ~/.agents/skills/akatsuki
ln -sfn "$AKATSUKI_PATH/default/akatsuki-skill" ~/.claude/skills/akatsuki
ln -sfn "$AKATSUKI_PATH/default/akatsuki-skill" ~/.codex/skills/akatsuki
ln -sfn "$AKATSUKI_PATH/default/akatsuki-skill" ~/.pi/agent/skills/akatsuki
