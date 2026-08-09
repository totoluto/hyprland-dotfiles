#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DO_REPO=true
DO_SYSTEM=true
DRY_RUN=false
ASSUME_YES=false

LEGACY_PACKAGES=(
  waybar
  swaync
  rofi
  blueman
  network-manager-applet
)

NEW_PACKAGES=(
  quickshell
  brightnessctl
  upower
  bluez
  bluez-utils
)

usage() {
  cat <<'USAGE'
Usage: migration/migrate-to-quickshell.sh [options]

Migrates this dotfiles repo and the current Arch/CachyOS installation from
Waybar/Rofi/SwayNC/Blueman/nm-applet to the Quickshell implementation.

Options:
  --repo-only     Only migrate files in the repository.
  --system-only   Only migrate the current machine.
  --dry-run       Print system-changing commands without executing them.
                  Repository changes are also skipped.
  -y, --yes       Do not ask for confirmation.
  -h, --help      Show this help.

Default: migrate both repository and current machine.
USAGE
}

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if $DRY_RUN; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

while (($#)); do
  case "$1" in
    --repo-only)
      DO_REPO=true
      DO_SYSTEM=false
      ;;
    --system-only)
      DO_REPO=false
      DO_SYSTEM=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    -y|--yes)
      ASSUME_YES=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
  shift
done

validate_repo() {
  [[ -f "$REPO_DIR/install.sh" ]] || die "install.sh not found in repo root: $REPO_DIR"
  [[ -f "$REPO_DIR/hypr/hyprland.conf" ]] || die "hypr/hyprland.conf not found"
  [[ -f "$REPO_DIR/quickshell/shell.qml" ]] || die \
    "quickshell/shell.qml is missing. Copy the finished Quickshell folder into the repo before running this migration."
}

write_new_install_script() {
  local target="$REPO_DIR/install.sh"

  if $DRY_RUN; then
    log "Would replace install.sh with the Quickshell-based installer"
    return
  fi

  cat > "$target" <<'INSTALL_SCRIPT'
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting setup..."

# ----------------------------
# Install needed packages
# ----------------------------

# AUR-only dependency used by the bundled GTK theme.
if command -v paru >/dev/null 2>&1; then
  paru -S --needed --noconfirm --skipreview \
    gtk-engine-murrine
else
  echo "WARNING: paru not found; gtk-engine-murrine was not installed."
fi

sudo pacman -S --needed --noconfirm \
  quickshell \
  brightnessctl \
  upower \
  bluez \
  bluez-utils \
  ttf-jetbrains-mono-nerd \
  flameshot \
  grim \
  slurp \
  hyprpicker \
  xdg-desktop-portal-hyprland \
  hyprlock \
  hyprpaper \
  networkmanager \
  nautilus \
  exfatprogs \
  gvfs \
  gvfs-smb \
  samba \
  smbclient \
  zsh \
  git

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

# ----------------------------
# Zsh + Oh My Zsh + p10k
# ----------------------------

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

if [ -f "$SCRIPT_DIR/.zshrc" ]; then
  cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
fi

if [ -f "$HOME/.zshrc" ]; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
fi

if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

# ----------------------------
# Copy/link configuration
# ----------------------------

echo "Installing configuration files..."
mkdir -p "$HOME/.config"

for dir in fastfetch flameshot hypr kitty; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    rm -rf "$HOME/.config/$dir"
    cp -a "$SCRIPT_DIR/$dir" "$HOME/.config/$dir"
  fi
done

# Keep Quickshell directly linked to the dotfiles repo. This also means
# locally installed dashboard plugins stay in the gitignored plugins folder.
if [ -d "$SCRIPT_DIR/quickshell" ]; then
  rm -rf "$HOME/.config/quickshell"
  ln -s "$SCRIPT_DIR/quickshell" "$HOME/.config/quickshell"
fi

# ----------------------------
# Install GTK Theme (system-wide)
# ----------------------------

if [ -d "$SCRIPT_DIR/Tokyonight-Moon" ]; then
  echo "Installing GTK theme system-wide..."
  sudo mkdir -p /usr/share/themes
  sudo rm -rf /usr/share/themes/Tokyonight-Moon
  sudo cp -a "$SCRIPT_DIR/Tokyonight-Moon" /usr/share/themes/
fi

gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Moon"

# ----------------------------
# Install system-wide fonts
# ----------------------------

if [ -d "$SCRIPT_DIR/hypr/fonts" ]; then
  echo "Installing fonts system-wide..."
  sudo mkdir -p /usr/share/fonts/TTF
  sudo cp -a "$SCRIPT_DIR/hypr/fonts/." /usr/share/fonts/TTF/
  sudo fc-cache -f
fi

echo "Setup complete."
echo "Quickshell is available at ~/.config/quickshell."
echo "Restart the Hyprland session or run: quickshell"
INSTALL_SCRIPT

  chmod +x "$target"
}

patch_hypr_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  if $DRY_RUN; then
    log "Would patch $file"
    return
  fi

  # App launcher: Quickshell Shell Hub replaces Rofi.
  sed -Ei \
    's#^\$menu[[:space:]]*=.*#$menu = qs ipc call hub toggle#' \
    "$file"

  # Quickshell replaces Waybar and nm-applet. Preserve hyprpaper and the
  # existing Octopi notifier from the old configuration.
  sed -Ei \
    '/^exec-once[[:space:]]*=.*(waybar|nm-applet)/c\exec-once = quickshell & hyprpaper & octopi-notifier' \
    "$file"
}

migrate_repo() {
  validate_repo
  log "Migrating repository: $REPO_DIR"

  if [[ -d "$REPO_DIR/.git" ]] && [[ -n "$(git -C "$REPO_DIR" status --porcelain 2>/dev/null || true)" ]]; then
    warn "Repository has uncommitted changes. The migration will not commit anything automatically."
  fi

  for dir in rofi swaync waybar; do
    if [[ -e "$REPO_DIR/$dir" ]]; then
      if $DRY_RUN; then
        log "Would remove repo directory: $dir/"
      else
        rm -rf "$REPO_DIR/$dir"
      fi
    fi
  done

  # Obsolete compatibility service from the SwayNC phase, if it still exists.
  if [[ -e "$REPO_DIR/quickshell/services/SwayncBridge.qml" ]]; then
    if $DRY_RUN; then
      log "Would remove quickshell/services/SwayncBridge.qml"
    else
      rm -f "$REPO_DIR/quickshell/services/SwayncBridge.qml"
    fi
  fi

  patch_hypr_file "$REPO_DIR/hypr/hyprland.conf"
  write_new_install_script

  if ! $DRY_RUN; then
    log "Repository migration complete"
    printf '\nRepository changes:\n'
    printf '  - removed rofi/, swaync/, waybar/\n'
    printf '  - removed obsolete SwayncBridge.qml when present\n'
    printf '  - changed Super+D launcher to Quickshell IPC\n'
    printf '  - changed autostart to Quickshell + hyprpaper + octopi-notifier\n'
    printf '  - replaced install.sh with Quickshell dependencies\n'
  fi
}

backup_path_if_present() {
  local source="$1"
  local backup_root="$2"

  [[ -e "$source" || -L "$source" ]] || return 0

  local name
  name="$(basename "$source")"

  run mkdir -p "$backup_root"
  run cp -aL "$source" "$backup_root/$name"
}

migrate_system() {
  command -v pacman >/dev/null 2>&1 || die \
    "System migration is intended for Arch/CachyOS and requires pacman. Use --repo-only elsewhere."

  validate_repo

  log "System packages to install: ${NEW_PACKAGES[*]}"
  log "Legacy packages to remove when installed: ${LEGACY_PACKAGES[*]}"

  local timestamp backup_root
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_root="$HOME/.local/state/hyprland-dotfiles-migration/$timestamp"

  log "Backing up replaced user configuration to: $backup_root"
  backup_path_if_present "$HOME/.config/rofi" "$backup_root"
  backup_path_if_present "$HOME/.config/swaync" "$backup_root"
  backup_path_if_present "$HOME/.config/waybar" "$backup_root"
  backup_path_if_present "$HOME/.config/quickshell" "$backup_root"
  backup_path_if_present "$HOME/.config/hypr/hyprland.conf" "$backup_root"

  # Install backends/new shell before removing the old frontends.
  run sudo pacman -S --needed --noconfirm "${NEW_PACKAGES[@]}"
  run sudo systemctl enable --now NetworkManager
  run sudo systemctl enable --now bluetooth

  # Stop old shell/UI processes first. Failure is harmless when they are not running.
  if ! $DRY_RUN; then
    pkill waybar 2>/dev/null || true
    pkill swaync 2>/dev/null || true
    pkill rofi 2>/dev/null || true
    pkill nm-applet 2>/dev/null || true
    pkill blueman-applet 2>/dev/null || true
  else
    log "Would stop waybar/swaync/rofi/nm-applet/blueman-applet"
  fi

  local installed_legacy=()
  local pkg
  for pkg in "${LEGACY_PACKAGES[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      installed_legacy+=("$pkg")
    fi
  done

  if ((${#installed_legacy[@]})); then
    log "Removing replaced packages: ${installed_legacy[*]}"
    run sudo pacman -Rns --noconfirm "${installed_legacy[@]}"
  else
    log "No replaced packages are currently installed"
  fi

  # Remove the old UI configurations after backup.
  run rm -rf \
    "$HOME/.config/rofi" \
    "$HOME/.config/swaync" \
    "$HOME/.config/waybar"

  # The repo is the source of truth for Quickshell.
  run mkdir -p "$HOME/.config"
  run rm -rf "$HOME/.config/quickshell"
  run ln -s "$REPO_DIR/quickshell" "$HOME/.config/quickshell"

  # Deploy the migrated Hyprland config without replacing unrelated Hypr files.
  run mkdir -p "$HOME/.config/hypr"
  run cp -a "$REPO_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"

  if ! $DRY_RUN && command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || warn "hyprctl reload failed; reload Hyprland manually"
  fi

  # exec-once does not run again on a normal config reload, so start Quickshell
  # now when the migration is being performed from an active Hyprland session.
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    if $DRY_RUN; then
      log "Would start quickshell for the current Hyprland session"
    elif ! pgrep -x quickshell >/dev/null 2>&1; then
      nohup quickshell >"$backup_root/quickshell-start.log" 2>&1 &
      disown || true
      log "Started Quickshell"
    fi
  fi

  log "System migration complete"
  log "Backup: $backup_root"
}

if ! $ASSUME_YES && ! $DRY_RUN; then
  printf '\nThis migration will'
  $DO_REPO && printf '\n  - modify the current dotfiles repository'
  $DO_SYSTEM && printf '\n  - install Quickshell/backends and remove replaced desktop UI packages'
  printf '\n\nContinue? [y/N] '
  read -r answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 0
fi

$DO_REPO && migrate_repo
$DO_SYSTEM && migrate_system

printf '\nMigration finished.\n'
if $DO_REPO && ! $DRY_RUN; then
  printf 'Review with: git status && git diff\n'
fi
