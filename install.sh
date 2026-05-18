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
    die "Not running Arch Linux. Aborting."
  fi

  if [[ $EUID -eq 0 ]]; then
    die "Do not run this script as root."
  fi

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
  if [[ -f "$DOTFILES_DIR/packages-repo.txt" ]]; then
    info "Installing official repo packages..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/packages-repo.txt" || {
      warn "Some packages failed. You may need to install them manually."
    }
    ok "Official repo packages installed."
  else
    warn "packages-repo.txt not found — skipping official packages."
  fi

  if [[ -f "$DOTFILES_DIR/packages-aur.txt" ]]; then
    info "Installing AUR packages..."
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/packages-aur.txt" || {
      warn "Some AUR packages failed. You may need to install them manually."
    }
    ok "AUR packages installed."
  else
    warn "packages-aur.txt not found — skipping AUR packages."
  fi
}

# ──────────────────────────────────────────────
# STEP 3 — Deploy Vendored Omarchy Files
# ──────────────────────────────────────────────
step3_vendor_omarchy() {
  info "Deploying vendored Omarchy runtime files..."

  local vendor_bin="$DOTFILES_DIR/_vendor/omarchy/bin"
  local vendor_default="$DOTFILES_DIR/_vendor/omarchy/default"
  local vendor_apps="$DOTFILES_DIR/_vendor/omarchy/applications"
  local vendor_config="$DOTFILES_DIR/_vendor/omarchy/config"
  local vendor_extra="$DOTFILES_DIR/_vendor/omarchy/version"

  local omarchy_path="$HOME/.local/share/omarchy"

  if [[ -d "$vendor_default" ]]; then
    mkdir -p "$omarchy_path/default"
    cp -a "$vendor_default/." "$omarchy_path/default/"
    ok "Default configs deployed to $omarchy_path/default/"
  fi

  if [[ -d "$vendor_bin" ]]; then
    mkdir -p "$omarchy_path/bin"
    cp -a "$vendor_bin/." "$omarchy_path/bin/"
    chmod +x "$omarchy_path/bin/omarchy-"* 2>/dev/null || true
    ok "Omarchy CLI scripts deployed to $omarchy_path/bin/"
  fi

  if [[ -d "$vendor_apps" ]]; then
    mkdir -p "$omarchy_path/applications"
    cp -a "$vendor_apps/." "$omarchy_path/applications/"
    ok "Applications deployed."
  fi

  if [[ -d "$vendor_config" ]]; then
    mkdir -p "$omarchy_path/config"
    cp -a "$vendor_config/." "$omarchy_path/config/"
    ok "Config deployed."
  fi

  if [[ -f "$vendor_extra" ]]; then
    cp "$vendor_extra" "$omarchy_path/"
    ok "Version/branding files deployed."
  fi

  # Deploy env scripts
  if [[ -f "$DOTFILES_DIR/.local/bin/env" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$DOTFILES_DIR/.local/bin/env" "$HOME/.local/bin/env"
    chmod +x "$HOME/.local/bin/env"
    ok "env script deployed to ~/.local/bin/"
  fi

  if [[ -f "$DOTFILES_DIR/.local/bin/env.fish" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$DOTFILES_DIR/.local/bin/env.fish" "$HOME/.local/bin/env.fish"
    ok "env.fish script deployed to ~/.local/bin/"
  fi
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
  done < <(find "$DOTFILES_DIR" \
    -not -path '*/.git/*' \
    -not -path '*/.git' \
    -not -path '*/_vendor/*' \
    -not -path '*/_vendor' \
    -type f -print0)

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

  # files from repo root (e.g., .bashrc, .zshrc, .profile, .XCompose)
  while IFS= read -r -d '' f; do
    local rel="${f#$DOTFILES_DIR/}"
    local target="$HOME/$rel"

    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$f" ]]; then
      continue
    fi

    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
      rm -rf "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$f" "$target"
  done < <(find "$DOTFILES_DIR" -maxdepth 1 -type f -name '.*' -print0)

  # .config directory — symlink each item
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
# STEP 7 — Apply Theme
# ──────────────────────────────────────────────
step7_theme() {
  local omarchy_bin="$HOME/.local/share/omarchy/bin"
  local theme_name="gruvbox"

  if [[ -f "$omarchy_bin/omarchy-theme-set" ]]; then
    info "Applying theme: $theme_name..."
    if bash "$omarchy_bin/omarchy-theme-set" "$theme_name" 2>/dev/null; then
      ok "Theme '$theme_name' applied."
    else
      warn "Theme command had issues. Theme files are in place."
    fi
  fi

  if command -v swaybg &>/dev/null; then
    local wallpaper="$HOME/.config/omarchy/current/background"
    if [[ -L "$wallpaper" ]] || [[ -f "$wallpaper" ]]; then
      ok "Wallpaper link is in place."
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
     • Omarchy runtime     (vendored — CLI, defaults, apps)
     • Gruvbox theme       (applied via vendored omarchy-theme-set)
     • Neovim              (LazyVim config)
     • GTK, fonts, tmux, btop, fastfetch, cava, swayosd
     • Git config, starship prompt, fish shell

  ⚡ Post-install tasks:
     [ ] Log out and select "Hyprland (Omarchy)" from SDDM
     [ ] If Plymouth shutdown screen is desired, run:
           sudo plymouth-set-default-theme omarchy-ascii
           sudo mkinitcpio -P
     [ ] Windows VM via Docker (if needed):
           ~/.config/windows/docker-compose.yml
     [ ] Reboot:
           systemctl reboot
     [ ] Old configs backed up to:
           ~/dotfiles-backup-*

  ⚡ Keybindings:
     Super+Q          Close window
     Super+Return     Terminal
     Super+D          App launcher (walker)
     Super+E          File manager
     Super+B          Browser
     Super+Space      Switch keyboard layout
     Super+Shift+E    Exit Hyprland
     Super+Alt+Space  Omarchy menu
     Super+L          Lock screen

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
    echo "Installs dotfiles on a fresh Arch Linux system."
    echo "This will:"
    echo "  1. Install all required packages (repo + AUR)"
    echo "  2. Deploy vendored Omarchy runtime files"
    echo "  3. Backup any existing configs"
    echo "  4. Symlink all dotfiles to ~/"
    echo "  5. Enable system and user services"
    echo "  6. Apply the theme"
    exit 0
  fi

  run_step 1 "Checking prerequisites..."
  step1_prereqs
  echo ""

  run_step 2 "Installing packages (this may take a while)..."
  step2_packages
  echo ""

  run_step 3 "Deploying vendored Omarchy runtime..."
  step3_vendor_omarchy
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
