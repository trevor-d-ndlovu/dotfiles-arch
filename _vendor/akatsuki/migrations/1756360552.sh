echo "Move Akatsuki Package Repository after Arch core/extra/multilib and remove AUR"

akatsuki-refresh-pacman
sudo pacman -Syu --noconfirm
