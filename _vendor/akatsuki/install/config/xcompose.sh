# Set default XCompose that is triggered with CapsLock
tee ~/.XCompose >/dev/null <<EOF
# Run akatsuki-restart-xcompose to apply changes

# Include fast emoji access
include "%H/.local/share/akatsuki/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$AKATSUKI_USER_NAME"
<Multi_key> <space> <e> : "$AKATSUKI_USER_EMAIL"
EOF
