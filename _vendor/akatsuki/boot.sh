#!/bin/bash

# Set install mode to online since boot.sh is used for curl installations
export OMARCHY_ONLINE_INSTALL=true

ansi_art='                 ▄▄▄
 ▄█████▄    ▄███████████▄    ▄███████   ▄███████   ▄███████   ▄█   █▄    ▄█   █▄
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   █▀   ███   ███  ███   ███
███   ███  ███   ███   ███ ▄███▄▄▄███ ▄███▄▄▄██▀  ███       ▄███▄▄▄███▄ ███▄▄▄███
███   ███  ███   ███   ███ ▀███▀▀▀███ ▀███▀▀▀▀    ███      ▀▀███▀▀▀███  ▀▀▀▀▀▀███
███   ███  ███   ███   ███  ███   ███ ██████████  ███   █▄   ███   ███  ▄██   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
 ▀█████▀    ▀█   ███   █▀   ███   █▀   ███   ███  ███████▀   ███   █▀    ▀█████▀
                                       ███   █▀                                  '

clear
echo -e "\n$ansi_art\n"

# Use custom branch if instructed, otherwise default to master
OMARCHY_REF="${OMARCHY_REF:-master}"

# Set mirror based on branch
if [[ $OMARCHY_REF == "dev" ]]; then
  export OMARCHY_MIRROR=edge
  echo 'Server = https://mirror.akatsuki.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
elif [[ $OMARCHY_REF == "rc" ]]; then
  export OMARCHY_MIRROR=rc
  echo 'Server = https://rc-mirror.akatsuki.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
else
  export OMARCHY_MIRROR=stable
  echo 'Server = https://stable-mirror.akatsuki.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
fi

sudo pacman -Syu --noconfirm --needed git

# Use custom repo if specified, otherwise default to basecamp/akatsuki
OMARCHY_REPO="${OMARCHY_REPO:-basecamp/akatsuki}"

echo -e "\nCloning Akatsuki from: https://github.com/${OMARCHY_REPO}.git"
rm -rf ~/.local/share/akatsuki/
git clone "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/akatsuki >/dev/null

echo -e "\e[32mUsing branch: $OMARCHY_REF\e[0m"
cd ~/.local/share/akatsuki
git fetch origin "${OMARCHY_REF}" && git checkout "${OMARCHY_REF}"
cd -

echo -e "\nInstallation starting..."
source ~/.local/share/akatsuki/install.sh
