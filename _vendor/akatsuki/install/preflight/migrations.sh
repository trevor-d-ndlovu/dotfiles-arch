OMARCHY_MIGRATIONS_STATE_PATH=~/.local/state/akatsuki/migrations
mkdir -p $OMARCHY_MIGRATIONS_STATE_PATH

for file in ~/.local/share/akatsuki/migrations/*.sh; do
  touch "$OMARCHY_MIGRATIONS_STATE_PATH/$(basename "$file")"
done
