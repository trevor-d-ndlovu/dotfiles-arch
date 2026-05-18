#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Akatsuki locations
export AKATSUKI_PATH="$HOME/.local/share/akatsuki"
export AKATSUKI_INSTALL="$AKATSUKI_PATH/install"
export AKATSUKI_INSTALL_LOG_FILE="/var/log/akatsuki-install.log"
export PATH="$AKATSUKI_PATH/bin:$PATH"

# Install
source "$AKATSUKI_INSTALL/helpers/all.sh"
source "$AKATSUKI_INSTALL/preflight/all.sh"
source "$AKATSUKI_INSTALL/packaging/all.sh"
source "$AKATSUKI_INSTALL/config/all.sh"
source "$AKATSUKI_INSTALL/login/all.sh"
source "$AKATSUKI_INSTALL/post-install/all.sh"
