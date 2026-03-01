#!/bin/bash

set -e  # stop script if something fails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting setup..."

# ----------------------------
# Install needed packages
# ----------------------------
paru -S --needed --noconfirm --skipreview \
  ttf-jetbrains-mono-nerd \

sudo pacman -S --needed --noconfirm \
  flameshot \
  gtk-engine-murrine \
  hyprpicker \
  xdg-desktop-portal-hyprland \
  hyprlock \
  hyprpaper \
  rofi \
  swaync \
  waybar \
  blueman \
  networkmanager network-manager-applet \
  nautilus \
  exfatprogs \
  gvfs gvfs-smb samba smbclient \
  zsh \
  git
  
sudo systemctl enable --now NetworkManager

# ----------------------------
# Zsh + Oh My Zsh + p10k
# ----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

if [ -f "$HOME/.zshrc" ]; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
fi

if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

# ----------------------------
# Copy configuration folders
# ----------------------------
echo "Copying configuration files..."
mkdir -p "$HOME/.config"
for dir in fastfetch flameshot hypr kitty rofi swaync waybar; do
  [ -d "$SCRIPT_DIR/$dir" ] && cp -r "$SCRIPT_DIR/$dir" "$HOME/.config/"
done

# ----------------------------
# Install GTK Theme (system-wide)
# ----------------------------
if [ -d "$SCRIPT_DIR/Tokyonight-Moon" ]; then
    echo "Installing GTK theme system-wide..."
    sudo mkdir -p /usr/share/themes
    sudo cp -r "$SCRIPT_DIR/Tokyonight-Moon" /usr/share/themes/
fi

gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Moon"

echo "Setup complete."
echo "Restart your session or run: exec zsh"