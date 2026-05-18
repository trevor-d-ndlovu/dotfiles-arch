# Omarchy Customizations

## Shield ASCII Art on Lock & Shutdown Screens

Converted `branding/screensaver.txt` (shield ASCII art) for use across two screens:

### 1. hyprlock (lock screen)
- **File**: `~/.config/hypr/hyprlock.conf`
- Added a `label` block that reads `~/.config/omarchy/branding/screensaver.txt`
- Renders the ASCII art above the password input field in JetBrainsMono Nerd Font

### 2. Plymouth (shutdown/reboot splash)
- Converted the ASCII art to a PNG image via Pillow
- **Theme**: `omarchy-ascii` at `/usr/share/plymouth/themes/omarchy-ascii/`
- Set as active via `plymouth-set-default-theme omarchy-ascii`
- Based on original omarchy theme, only the `logo.png` was replaced
