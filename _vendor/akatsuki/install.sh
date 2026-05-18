#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Akatsuki locations
export AKATSUKI_PATH="$HOME/.local/share/akatsuki"
export OMARCHY_INSTALL="$AKATSUKI_PATH/install"
export OMARCHY_INSTALL_LOG_FILE="/var/log/akatsuki-install.log"
export PATH="$AKATSUKI_PATH/bin:$PATH"

# Install
source "$OMARCHY_INSTALL/helpers/all.sh"
source "$OMARCHY_INSTALL/preflight/all.sh"
source "$OMARCHY_INSTALL/packaging/all.sh"
source "$OMARCHY_INSTALL/config/all.sh"
source "$OMARCHY_INSTALL/login/all.sh"
source "$OMARCHY_INSTALL/post-install/all.sh"
