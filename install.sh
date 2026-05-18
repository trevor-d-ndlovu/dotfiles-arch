#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

info()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m[ OK ]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
die()   { printf "\033[1;31m[FAIL]\033[0m %s\n" "$*"; exit 1; }

run_step() {
  local n=$1; shift
  info "[$n/8] $*"
}

header() {
  cat <<'EOF'
  ____        _   __ _       _
 |  _ \  ___ | |_/ _(_) ___| |__
 | | | |/ _ \| __| |_| |/ __| '_ \
 | |_| | (_) | |_|  _| | (__| | | |
 |____/ \___/ \__|_| |_|\___|_| |_|

EOF
  echo "    Dotfiles Installer — trevor-d-ndlovu/dotfiles-arch"
  echo ""
}

# ──────────────────────────────────────────────
# STEP 1 — System Detection & Prerequisites
# ──────────────────────────────────────────────
step1_prereqs() {
  if [[ "$(uname)" != "Linux" ]]; then
    die "This system is not Linux. This config targets Arch Linux."
  fi

  if [[ ! -f /etc/arch-release ]]; then
    die "Not running Arch Linux (or derivative). Aborting."
  fi

  if [[ $EUID -eq 0 ]]; then
    die "Do not run this script as root."
  fi

  # Install yay if not present
  if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    local tmpdir; tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    ok "yay installed."
  fi

  ok "System: Arch Linux"
  echo "    Host:  $(uname -n)"
  echo "    User:  $USER"
  echo "    Date:  $(date)"
  echo "    Repo:  $DOTFILES_DIR"
}

# ──────────────────────────────────────────────
# STEP 2 — Install Packages
# ──────────────────────────────────────────────
step2_packages() {
  # Official repo packages
  if [[ -f "$DOTFILES_DIR/packages-repo.txt" ]]; then
    info "Installing official repo packages..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/packages-repo.txt" || {
      warn "Some packages failed to install. Check the list and retry."
    }
    ok "Official repo packages installed."
  else
    warn "packages-repo.txt not found — skipping official packages."
  fi

  # AUR packages
  if [[ -f "$DOTFILES_DIR/packages-aur.txt" ]]; then
    info "Installing AUR packages..."
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/packages-aur.txt" || {
      warn "Some AUR packages failed to install. You may need to install them manually."
    }
    ok "AUR packages installed."
  else
    warn "packages-aur.txt not found — skipping AUR packages."
  fi
}

# ──────────────────────────────────────────────
# STEP 3 — Omarchy
# ──────────────────────────────────────────────
step3_omarchy() {
  if command -v omarchy &>/dev/null; then
    info "Omarchy is already installed."
    return
  fi

  info "Installing Omarchy..."

  if [[ -d /usr/share/omarchy ]]; then
    warn "Omarchy sources found at /usr/share/omarchy but CLI is missing."
    info "Try: sudo omarchy install"
    return
  fi

  cat <<'EOF'
Omarchy is an Arch Linux distribution with Hyprland.
To install it on bare Arch Linux, visit:
  https://omarchy.org/install

After installing Omarchy, re-run this script to apply configs.
EOF
}

# ──────────────────────────────────────────────
# STEP 4 — Backup Existing Configs
# ──────────────────────────────────────────────
step4_backup() {
  info "Backing up existing configs to: $BACKUP_DIR"

  local items=()
  while IFS= read -r -d '' f; do
    local rel="${f#$DOTFILES_DIR/}"
    local target="$HOME/$rel"
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
      items+=("$rel")
    fi
  done < <(find "$DOTFILES_DIR" -not -path '*/.git/*' -not -path '*/.git' -type f -print0)

  if [[ ${#items[@]} -eq 0 ]]; then
    ok "No existing configs to back up."
    return
  fi

  mkdir -p "$BACKUP_DIR"
  for item in "${items[@]}"; do
    local target="$HOME/$item"
    local backup="$BACKUP_DIR/$item"
    mkdir -p "$(dirname "$backup")"
    cp -a "$target" "$backup"
  done
  ok "Backed up ${#items[@]} files to $BACKUP_DIR"
}

# ──────────────────────────────────────────────
# STEP 5 — Symlink Configs
# ──────────────────────────────────────────────
step5_symlink() {
  info "Symlinking config files..."

  # files to symlink from repo root (e.g., .bashrc, .zshrc, .profile)
  while IFS= read -r -d '' f; do
    local rel="${f#$DOTFILES_DIR/}"
    local target="$HOME/$rel"

    # Skip if it's already pointing to our file
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$f" ]]; then
      continue
    fi

    # Backup existing file/dir
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
      rm -rf "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$f" "$target"
  done < <(find "$DOTFILES_DIR" -maxdepth 1 -type f -name '.*' -print0)

  # .config directory — symlink each item individually
  if [[ -d "$DOTFILES_DIR/.config" ]]; then
    while IFS= read -r -d '' f; do
      local rel="${f#$DOTFILES_DIR/.config/}"
      local target="$HOME/.config/$rel"

      if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$f" ]]; then
        continue
      fi

      if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        rm -rf "$target"
      fi

      mkdir -p "$(dirname "$target")"
      ln -sf "$f" "$target"
    done < <(find "$DOTFILES_DIR/.config" -print0)
  fi

  ok "Config files symlinked."
}

# ──────────────────────────────────────────────
# STEP 6 — Enable System Services
# ──────────────────────────────────────────────
step6_services() {
  info "Enabling system services..."

  local system_services=(
    systemd-networkd
    systemd-resolved
    systemd-timesyncd
    sddm
    bluetooth
    docker
    cups
    avahi-daemon
    iwd
    power-profiles-daemon
    thermald
    ufw
  )

  for svc in "${system_services[@]}"; do
    if systemctl list-unit-files "$svc.service" &>/dev/null; then
      sudo systemctl enable --now "$svc" 2>/dev/null || true
      ok "  $svc enabled"
    fi
  done

  info "Enabling user services..."

  local user_services=(
    pipewire.socket
    pipewire-pulse.socket
    wireplumber.service
    elephant.service
    swayosd-server.service
    omarchy-recover-internal-monitor.service
    omarchy-battery-monitor.timer
  )

  for svc in "${user_services[@]}"; do
    if systemctl --user list-unit-files "$svc" &>/dev/null; then
      systemctl --user enable --now "$svc" 2>/dev/null || true
      ok "  $svc enabled"
    fi
  done
}

# ──────────────────────────────────────────────
# STEP 7 — Apply Theme & Post-Config
# ──────────────────────────────────────────────
step7_theme() {
  if command -v omarchy &>/dev/null; then
    info "Applying Omarchy theme: gruvbox..."
    omarchy theme set gruvbox 2>/dev/null && ok "Theme applied." || warn "Could not set theme. Try: omarchy theme set gruvbox"
  else
    warn "Omarchy not installed — theme files are in place but won't be active until Omarchy is installed."
  fi

  # Apply wallpaper
  if command -v swaybg &>/dev/null; then
    local wallpaper="$HOME/.config/omarchy/backgrounds/gruvbox/vaga2.png"
    if [[ -f "$wallpaper" ]]; then
      info "Wallpaper is symlinked and ready."
    fi
  fi
}

# ──────────────────────────────────────────────
# STEP 8 — Post-Install Notes
# ──────────────────────────────────────────────
step8_finish() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║                Installation Complete!                    ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""

  cat <<'NOTES'
  ⚡ What's installed:
     • Shell configs       (.bashrc, .zshrc, .profile, .XCompose)
     • Hyprland WM         (window manager + keybindings + monitors)
     • Waybar              (status bar)
     • Mako                (notifications)
     • Walker              (app launcher)
     • Kitty, Ghostty, Alacritty (terminals)
     • Omarchy custom      (theme, backgrounds, branding)
     • Neovim              (LazyVim config)
     • GTK, fonts, tmux, btop, fastfetch, cava, swayosd
     • Git config, starship prompt, fish shell

  ⚡ Post-install tasks:
     [ ] The Plymouth shutdown theme was customized — if desired, run:
           sudo plymouth-set-default-theme omarchy-ascii

     [ ] If you use the Windows VM via Docker, check:
           ~/.config/windows/docker-compose.yml

     [ ] Reboot to pick up all services:
           systemctl reboot

     [ ] If OpenCode is your editor agent, run:
           opencode init

     [ ] To restore old configs from backup:
           ~/dotfiles-backup-*

  ⚡ Common keybindings:
     Super+Q          Close window
     Super+Return     Open terminal
     Super+D          App launcher (walker)
     Super+E          File manager
     Super+Space      Switch keyboard layout
     Super+Shift+E    Exit Hyprland

NOTES
}

# ──────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────
main() {
  header

  if [[ $# -eq 1 && "$1" == "--help" ]]; then
    echo "Usage: ./install.sh"
    echo ""
    echo "Installs the dotfiles-arch configuration on a fresh Arch Linux system."
    echo "This will:"
    echo "  1. Install all required packages (repo + AUR)"
    echo "  2. Backup any existing configs"
    echo "  3. Symlink all dotfiles to ~/"
    echo "  4. Enable system and user services"
    echo "  5. Apply the theme"
    exit 0
  fi

  run_step 1 "Checking prerequisites..."
  step1_prereqs
  echo ""

  run_step 2 "Installing packages (this may take a while)..."
  step2_packages
  echo ""

  run_step 3 "Setting up Omarchy..."
  step3_omarchy
  echo ""

  run_step 4 "Backing up your existing configs..."
  step4_backup
  echo ""

  run_step 5 "Symlinking dotfiles..."
  step5_symlink
  echo ""

  run_step 6 "Enabling system services..."
  step6_services
  echo ""

  run_step 7 "Applying theme..."
  step7_theme
  echo ""

  run_step 8 "Finalizing..."
  step8_finish
}

main "$@"
