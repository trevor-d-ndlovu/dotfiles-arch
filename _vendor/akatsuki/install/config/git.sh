# Set identification from install inputs
if [[ -n ${AKATSUKI_USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$AKATSUKI_USER_NAME"
fi

if [[ -n ${AKATSUKI_USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$AKATSUKI_USER_EMAIL"
fi
