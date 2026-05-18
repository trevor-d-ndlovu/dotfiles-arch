# Akatsuki Customizations

## Shield ASCII Art on Lock & Shutdown Screens

Converted `branding/screensaver.txt` (shield ASCII art) for use across two screens:

### 1. hyprlock (lock screen)
- **File**: `~/.config/hypr/hyprlock.conf`
- Added a `label` block that reads `~/.config/akatsuki/branding/screensaver.txt`
- Renders the ASCII art above the password input field in JetBrainsMono Nerd Font

### 2. Plymouth (shutdown/reboot splash)
- Converted the ASCII art to a PNG image via Pillow
- **Theme**: `akatsuki-ascii` at `/usr/share/plymouth/themes/akatsuki-ascii/`
- Set as active via `plymouth-set-default-theme akatsuki-ascii`
- Based on original akatsuki theme, only the `logo.png` was replaced
