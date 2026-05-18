echo "Change to openai-codex instead of openai-codex-bin"

if akatsuki-pkg-present openai-codex-bin; then
    akatsuki-pkg-drop openai-codex-bin
    akatsuki-pkg-add openai-codex
fi
