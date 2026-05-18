# Install all base packages
mapfile -t packages < <(grep -v '^#' "$OMARCHY_INSTALL/akatsuki-base.packages" | grep -v '^$')
akatsuki-pkg-add "${packages[@]}"
