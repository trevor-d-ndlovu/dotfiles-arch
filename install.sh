#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
AKATSUKI_PATH="$HOME/.local/share/akatsuki"
OMARCHY_INSTALL="$AKATSUKI_PATH/install"
export PATH="$AKATSUKI_PATH/bin:$PATH"

info()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m[ OK ]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
die()   { printf "\033[1;31m[FAIL]\033[0m %s\n" "$*"; exit 1; }

run_step() {
  local n=$1; shift
  info "[$n/11] $*"
}

run_vendored() {
  local script="$OMARCHY_INSTALL/$1"
  if [[ -f "$script" ]]; then
    info "  → $1"
    bash "$script" 2>&1 | sed 's/^/    /' || warn "  → $1 had non-fatal issues"
  else
    warn "  → $1 not found, skipping"
  fi
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

# ── STEP 1 — Prereqs ──
step1_prereqs() {
  if [[ "$(uname)" != "Linux" ]]; then
    die "This system is not Linux."
  fi
  if [[ ! -f /etc/arch-release ]]; then
    die "Not running Arch Linux."
  fi
  if [[ $EUID -eq 0 ]]; then
    die "Do not run as root."
  fi

  if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    local tmpdir; tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    ok "yay installed"
  fi

  ok "System: Arch Linux ($(uname -n))"
}

# ── STEP 2 — Install Packages ──
step2_packages() {
  if [[ -f "$DOTFILES_DIR/packages-repo.txt" ]]; then
    info "Installing official repo packages..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/packages-repo.txt" || {
      warn "Some repo packages failed — check packages-repo.txt for issues"
    }
    ok "Official repo packages installed"
  fi

  if [[ -f "$DOTFILES_DIR/packages-aur.txt" ]]; then
    info "Installing AUR packages..."
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/packages-aur.txt" || {
      warn "Some AUR packages failed — check packages-aur.txt for issues"
    }
    ok "AUR packages installed"
  fi
}

# ── STEP 3 — Deploy Vendored Runtime ──
step3_deploy() {
  info "Deploying vendored runtime..."
  local vendor="$DOTFILES_DIR/_vendor/akatsuki"

  local dirs=(bin default themes migrations install applications config)
  for dir in "${dirs[@]}"; do
    if [[ -d "$vendor/$dir" ]]; then
      mkdir -p "$AKATSUKI_PATH/$dir"
      cp -a "$vendor/$dir/." "$AKATSUKI_PATH/$dir/"
    fi
  done

  chmod +x "$AKATSUKI_PATH/bin/akatsuki-"* 2>/dev/null || true

  for f in version icon.png logo.svg icon.txt logo.txt boot.sh install.sh README.md AGENTS.md LICENSE .editorconfig; do
    [[ -f "$vendor/$f" ]] && cp "$vendor/$f" "$AKATSUKI_PATH/$f"
  done

  ok "Runtime deployed ($(du -sh "$AKATSUKI_PATH" | cut -f1))"

  if [[ -f "$DOTFILES_DIR/.local/bin/env" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$DOTFILES_DIR/.local/bin/env" "$HOME/.local/bin/env"
    chmod +x "$HOME/.local/bin/env"
  fi
  if [[ -f "$DOTFILES_DIR/.local/bin/env.fish" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$DOTFILES_DIR/.local/bin/env.fish" "$HOME/.local/bin/env.fish"
  fi
  for f in "$DOTFILES_DIR/.local/bin/"*; do
    local name; name=$(basename "$f")
    [[ "$name" == "env" || "$name" == "env.fish" ]] && continue
    [[ -f "$f" ]] && cp "$f" "$HOME/.local/bin/$name" && chmod +x "$HOME/.local/bin/$name"
  done
  ok "~/.local/bin utilities deployed"
}

# ── STEP 4 — System Setup ──
step4_system_setup() {
  info "Running system configuration..."

  run_vendored "config/docker.sh"
  run_vendored "config/input-group.sh"
  run_vendored "config/increase-file-watchers.sh"
  run_vendored "config/increase-fd-limit.sh"
  run_vendored "config/increase-sudo-tries.sh"
  run_vendored "config/increase-lockout-limit.sh"
  run_vendored "config/ssh-flakiness.sh"
  run_vendored "config/timezones.sh"
  run_vendored "config/user-dirs.sh"
  run_vendored "config/mimetypes.sh"
  # kernel-modules-hook.sh needs chrootable_systemctl_enable from vendored helpers
  if systemctl list-unit-files linux-modules-cleanup.service &>/dev/null; then
    sudo systemctl enable linux-modules-cleanup.service 2>/dev/null || true
  fi
  run_vendored "config/localdb.sh"
  run_vendored "config/fast-shutdown.sh"
  run_vendored "config/unmount-fuse.sh"
  run_vendored "config/plocate-ac-only.sh"
  run_vendored "config/walker-elephant.sh"
  run_vendored "config/powerprofilesctl-rules.sh"
  run_vendored "config/wifi-powersave-rules.sh"

  run_vendored "config/hardware/network.sh"
  run_vendored "config/hardware/set-wireless-regdom.sh"
  run_vendored "config/hardware/bluetooth.sh"
  run_vendored "config/hardware/printer.sh"
  run_vendored "config/hardware/usb-autosuspend.sh"
  run_vendored "config/hardware/ignore-power-button.sh"

  run_vendored "config/hardware/intel/video-acceleration.sh"
  run_vendored "config/hardware/intel/lpmd.sh"
  run_vendored "config/hardware/intel/thermald.sh"
  run_vendored "config/hardware/intel/sof-firmware.sh"
}

# ── STEP 5 — Login Setup ──
step5_login() {
  info "Setting up display manager..."
  run_vendored "login/plymouth.sh"
  run_vendored "login/sddm.sh"
  run_vendored "login/default-keyring.sh"
}

# ── STEP 6 — Backup ──
step6_backup() {
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
    ok "No existing configs to back up"
    return
  fi

  mkdir -p "$BACKUP_DIR"
  for item in "${items[@]}"; do
    local target="$HOME/$item"
    local backup="$BACKUP_DIR/$item"
    mkdir -p "$(dirname "$backup")"
    cp -a "$target" "$backup"
  done
  ok "Backed up ${#items[@]} files"
}

# ── STEP 7 — Symlink User Dotfiles ──
step7_symlink() {
  info "Symlinking user dotfiles..."

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

  ok "Dotfiles symlinked"
}

# ── STEP 8 — Services ──
step8_services() {
  info "Enabling system services..."
  local system_services=(
    systemd-networkd systemd-resolved systemd-timesyncd
    sddm bluetooth docker cups avahi-daemon iwd
    power-profiles-daemon thermald ufw
  )
  for svc in "${system_services[@]}"; do
    if systemctl list-unit-files "$svc.service" &>/dev/null; then
      sudo systemctl enable --now "$svc" 2>/dev/null || true
    fi
  done
  ok "System services enabled"

  info "Enabling user services..."
  local user_services=(
    pipewire.socket pipewire-pulse.socket wireplumber.service
    elephant.service swayosd-server.service
    akatsuki-recover-internal-monitor.service akatsuki-battery-monitor.timer
  )
  for svc in "${user_services[@]}"; do
    if systemctl --user list-unit-files "$svc" &>/dev/null; then
      systemctl --user enable "$svc" 2>/dev/null || true
    fi
  done
  ok "User services enabled (will start on next login)"
}

# ── STEP 9 — First-Run Setup ──
step9_firstrun() {
  info "Running first-time setup..."
  run_vendored "first-run/dns-resolver.sh"
  run_vendored "first-run/firewall.sh"
  run_vendored "first-run/battery-monitor.sh"
  run_vendored "first-run/swayosd.sh"
  run_vendored "first-run/elephant.sh"
  run_vendored "first-run/gtk-primary-paste.sh"
}

# ── STEP 10 — Theme ──
step10_theme() {
  local theme_name="gruvbox"

  if [[ -f "$AKATSUKI_PATH/bin/akatsuki-theme-set" ]]; then
    info "Applying theme '$theme_name'..."
    bash "$AKATSUKI_PATH/bin/akatsuki-theme-set" "$theme_name" 2>/dev/null || {
      warn "Theme command had minor issues — files may already be in place"
    }
  fi

  local bg_link="$HOME/.config/akatsuki/current/background"
  local bg_target="$HOME/.config/akatsuki/backgrounds/gruvbox/vaga2.png"
  if [[ ! -f "$bg_link" ]] && [[ -f "$bg_target" ]]; then
    mkdir -p "$(dirname "$bg_link")"
    ln -sf "$bg_target" "$bg_link"
  fi

  ok "Theme '$theme_name' applied"
  info "Available themes: $(ls "$AKATSUKI_PATH/themes" 2>/dev/null | tr '\n' ' ')"
}

# ── STEP 11 — Finish ──
step11_finish() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║            Installation Complete!                        ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""

  cat <<'NOTES'
  ⚡ What's installed:
     • Shell               (.bashrc, .zshrc, .profile, .bash_profile, .XCompose)
     • Window manager      (Hyprland — keybindings, monitors, input, animations)
     • Status bar          (Waybar — workspaces, clock, network, audio, battery)
     • Notifications       (Mako — themed)
     • App launcher        (Walker — dmenu)
     • Terminals           (Kitty, Ghostty, Alacritty)
     • Akatsuki runtime    (vendored — 282 CLI scripts, 18 themes, defaults)
     • Active theme        (gruvbox — with 17 additional themes available)
     • Editor              (Neovim LazyVim, VS Code settings)
     • Input method        (Fcitx5 — Chinese/Japanese keyboard)
     • System              (SDDM, PipeWire, Docker, Bluetooth, CUPS, UFW)
     • Tools               (GTK, fonts, tmux, btop, fastfetch, cava, swayosd)
     • Development         (mise, git config, starship, ~/.local/bin utilities)

  ⚡ Post-install:
     [ ] Reboot: systemctl reboot
     [ ] Select "Hyprland" from SDDM
     [ ] If Plymouth shutdown animation is wanted:
           sudo plymouth-set-default-theme akatsuki
           sudo mkinitcpio -P
     [ ] Switch themes: akatsuki theme set <name>
     [ ] Backups in: ~/dotfiles-backup-*

  ⚡ Keybindings:
     Super+Return    Terminal        Super+Q        Close window
     Super+D         Walker          Super+E        File manager
     Super+B         Browser         Super+N        Neovim
     Super+L         Lock screen     Super+Shift+E  Exit Hyprland
     Super+Alt+Space Akatsuki menu   Super+Space    Keyboard layout

NOTES
}

# ── Main ──
main() {
  header

  if [[ $# -eq 1 && "$1" == "--help" ]]; then
    echo "Usage: ./install.sh"
    echo ""
    echo "Full-system dotfiles installer for Arch Linux."
    echo "Replicates trevor-d-ndlovu's complete desktop environment."
    echo ""
    echo "Steps:"
    echo "  1.  Prerequisites (yay, Arch check)"
    echo "  2.  Install all packages (370+ repo + 6 AUR)"
    echo "  3.  Deploy vendored Akatsuki runtime"
    echo "  4.  System setup (Docker, input group, limits, hardware)"
    echo "  5.  Login manager (SDDM, Plymouth, keyring)"
    echo "  6.  Backup existing configs"
    echo "  7.  Symlink user dotfiles"
    echo "  8.  Enable system/user services"
    echo "  9.  First-run setup (firewall, DNS, battery monitor)"
    echo " 10.  Apply theme (gruvbox)"
    echo " 11.  Finish"
    exit 0
  fi

  run_step 1 "Checking prerequisites..."
  step1_prereqs
  echo ""

  run_step 2 "Installing packages (this takes a while)..."
  step2_packages
  echo ""

  run_step 3 "Deploying vendored Akatsuki runtime..."
  step3_deploy
  echo ""

  run_step 4 "Configuring system..."
  step4_system_setup
  echo ""

  run_step 5 "Setting up login manager..."
  step5_login
  echo ""

  run_step 6 "Backing up your existing configs..."
  step6_backup
  echo ""

  run_step 7 "Symlinking dotfiles..."
  step7_symlink
  echo ""

  run_step 8 "Enabling services..."
  step8_services
  echo ""

  run_step 9 "Running first-time setup..."
  step9_firstrun
  echo ""

  run_step 10 "Applying theme..."
  step10_theme
  echo ""

  run_step 11 "Finalizing..."
  step11_finish
}

main "$@"
