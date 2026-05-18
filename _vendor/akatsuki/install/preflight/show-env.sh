# Show installation environment variables
gum log --level info "Installation Environment:"

env | grep -E "^(AKATSUKI_CHROOT_INSTALL|AKATSUKI_ONLINE_INSTALL|AKATSUKI_USER_NAME|AKATSUKI_USER_EMAIL|USER|HOME|AKATSUKI_REPO|AKATSUKI_REF|AKATSUKI_PATH)=" | sort | while IFS= read -r var; do
  gum log --level info "  $var"
done
