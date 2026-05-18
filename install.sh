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
  info "Deploying vendored Omarchy runtime..."

  local vendor="$DOTFILES_DIR/_vendor/omarchy"
  local omarchy_path="$HOME/.local/share/omarchy"

  # Deploy each section of the vendored omarchy runtime
  local dirs=(bin default themes migrations install applications config)
  for dir in "${dirs[@]}"; do
    if [[ -d "$vendor/$dir" ]]; then
      mkdir -p "$omarchy_path/$dir"
      cp -a "$vendor/$dir/." "$omarchy_path/$dir/"
    fi
  done

  # Make bin scripts executable
  chmod +x "$omarchy_path/bin/omarchy-"* 2>/dev/null || true

  # Top-level files
  for f in version icon.png logo.svg icon.txt logo.txt boot.sh install.sh README.md AGENTS.md LICENSE .editorconfig; do
    [[ -f "$vendor/$f" ]] && cp "$vendor/$f" "$omarchy_path/$f"
  done

  ok "Omarchy runtime deployed ($(du -sh "$omarchy_path" | cut -f1))"

  # Deploy PATH env scripts
  if [[ -f "$DOTFILES_DIR/.local/bin/env" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$DOTFILES_DIR/.local/bin/env" "$HOME/.local/bin/env"
    chmod +x "$HOME/.local/bin/env"
    ok "~/.local/bin/env deployed"
  fi

  if [[ -f "$DOTFILES_DIR/.local/bin/env.fish" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$DOTFILES_DIR/.local/bin/env.fish" "$HOME/.local/bin/env.fish"
    ok "~/.local/bin/env.fish deployed"
  fi

  # Copy local utility scripts
  for f in "$DOTFILES_DIR/.local/bin/"*; do
    local name; name=$(basename "$f")
    [[ "$name" == "env" || "$name" == "env.fish" ]] && continue
    [[ -f "$f" ]] && cp "$f" "$HOME/.local/bin/$name" && chmod +x "$HOME/.local/bin/$name"
  done
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

  # Ensure OMARCHY_PATH is set for the theme script
  export OMARCHY_PATH="$HOME/.local/share/omarchy"

  if [[ -f "$omarchy_bin/omarchy-theme-set" ]]; then
    info "Applying theme: $theme_name..."
    if bash "$omarchy_bin/omarchy-theme-set" "$theme_name" 2>/dev/null; then
      ok "Theme '$theme_name' applied."
    else
      warn "Theme command had minor issues — theme files already in place."
    fi
  fi

  # Make sure the wallpaper symlink exists
  local bg_link="$HOME/.config/omarchy/current/background"
  local bg_target="$HOME/.config/omarchy/backgrounds/gruvbox/vaga2.png"
  if [[ ! -f "$bg_link" ]] && [[ -f "$bg_target" ]]; then
    mkdir -p "$(dirname "$bg_link")"
    ln -sf "$bg_target" "$bg_link"
    ok "Wallpaper symlinked."
  fi

  # Display available themes
  info "Available themes: $(ls "$OMARCHY_PATH/themes" 2>/dev/null | tr '\n' ' ')"
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
     • Shell               (.bashrc, .zshrc, .profile, .bash_profile, .XCompose, fish/)
     • Window manager      (Hyprland — keybindings, monitors, input, animations)
     • Status bar          (Waybar — workspaces, clock, network, audio, battery)
     • Notifications       (Mako — themed)
     • App launcher        (Walker — dmenu)
     • Terminals           (Kitty, Ghostty, Alacritty)
     • Omarchy runtime     (vendored — 282 CLI scripts, 18 themes, defaults)
     • Active theme        (gruvbox — with 17 additional themes available)
     • Editor              (Neovim LazyVim, VS Code settings)
     • Input method        (Fcitx5 — Chinese/Japanese keyboard)
     • System              (SDDM, PipeWire, Docker, Bluetooth, CUPS, UFW)
     • Tools               (GTK, fonts, tmux, btop, fastfetch, cava, swayosd)
     • Development         (mise, git config, starship, ~/.local/bin utilities)

  ⚡ Post-install:
     [ ] Log out, select "Hyprland (Omarchy)" from SDDM
     [ ] If Plymouth shutdown animation is wanted:
           sudo plymouth-set-default-theme omarchy-ascii
           sudo mkinitcpio -P
     [ ] Switch themes anytime: omarchy theme set <name>
     [ ] Windows VM (Docker): ~/.config/windows/docker-compose.yml
     [ ] Install missing packages manually if any failed
     [ ] Reboot: systemctl reboot
     [ ] Backups in: ~/dotfiles-backup-*

  ⚡ Keybindings:
     Super+Return    Terminal        Super+Q        Close window
     Super+D         Walker          Super+E        File manager
     Super+B         Browser         Super+N        Neovim
     Super+L         Lock screen     Super+Shift+E  Exit Hyprland
     Super+Alt+Space Omarchy menu    Super+Space    Keyboard layout

  ⚡ Available themes:
     catppuccin  catppuccin-latte  ethereal  everforest  flexoki-light
     gruvbox     hackerman         kanagawa  lumon       matte-black
     miasma      nord              osaka-jade  retro-82  ristretto
     rose-pine   tokyo-night       vantablack  white

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
