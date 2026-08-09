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
