echo "Add UWSM env"

export AKATSUKI_PATH="$HOME/.local/share/akatsuki"
export PATH="$AKATSUKI_PATH/bin:$PATH"

mkdir -p "$HOME/.config/uwsm/"
cat <<EOF | tee "$HOME/.config/uwsm/env"
export AKATSUKI_PATH=$HOME/.local/share/akatsuki
export PATH=$AKATSUKI_PATH/bin/:$PATH
EOF

# Ensure we have the latest repos and are ready to pull
akatsuki-update-keyring
akatsuki-refresh-pacman
sudo systemctl restart systemd-timesyncd
sudo pacman -Sy # Normally not advisable, but we'll do a full -Syu before finishing

mkdir -p ~/.local/state/akatsuki/migrations
touch ~/.local/state/akatsuki/migrations/1751134560.sh

# Remove old AUR packages to prevent a super lengthy build on old Akatsuki installs
akatsuki-pkg-drop zoom qt5-remoteobjects wf-recorder wl-screenrec

# Get rid of old AUR packages
bash $AKATSUKI_PATH/migrations/1756060611.sh
touch ~/.local/state/akatsuki/migrations/1756060611.sh

bash akatsuki-update-perform
