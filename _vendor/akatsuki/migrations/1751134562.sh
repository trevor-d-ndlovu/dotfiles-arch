echo "Ensure all indexes and packages are up to date"

akatsuki-update-keyring
akatsuki-refresh-pacman
sudo pacman -Syu --noconfirm
