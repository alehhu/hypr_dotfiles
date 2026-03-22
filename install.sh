#!/bin/bash

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# --- CATEGORIZED PACKAGES ---

# 1. Core Desktop Environment (The "Unixporn" base)
CORE_DE=(
    "hyprland" "hyprlock" "hyprpicker" "waybar" "swaync" "wlogout" "swww" 
    "rofi-wayland" "kitty" "starship" "yazi" "python-pywal" "jq" 
    "grim" "slurp" "wl-clipboard" "tesseract" "tesseract-data-eng" "tesseract-data-ita"
    "translate-shell" "brightnessctl" "pavucontrol" "nm-connection-editor"
    "ttf-jetbrains-mono-nerd" "papirus-icon-theme" "xdotool" "rofimoji"
    "eww" "fastfetch" "btop" "cava"
)

# 2. Daily Driver Apps
APPS=(
    "firefox" "discord" "spotify-launcher" "steam" "thunar" "gvfs" "thunar-archive-plugin"
)

# 3. Development Tools (From your aliases)
DEV_TOOLS=(
    "docker" "docker-compose" "minikube" "kubectl" "vim" "git" "base-devel" "tlp"
)

ALL_PACKAGES=("${CORE_DE[@]}" "${APPS[@]}" "${DEV_TOOLS[@]}")

echo "🚀 Starting Portable Dotfiles Installation..."

# Install Dependencies
if command -v paru &> /dev/null; then
    echo "📦 Installing everything using paru..."
    paru -S --needed --noconfirm "${ALL_PACKAGES[@]}"
elif command -v yay &> /dev/null; then
    echo "📦 Installing everything using yay..."
    yay -S --needed --noconfirm "${ALL_PACKAGES[@]}"
else
    echo "📦 No AUR helper found. Using pacman (will skip AUR-only pkgs like spotify)..."
    sudo pacman -S --needed --noconfirm "${ALL_PACKAGES[@]}"
fi

# Enable System Services
echo "⚙️ Enabling system services..."
sudo systemctl enable --now docker
sudo systemctl enable --now tlp

# Create Config directory if missing
mkdir -p "$CONFIG_DIR"

# Backup existing configs
echo "💾 Backing up existing configs..."
BACKUP_NAME="$HOME/.dotfiles-backup-$(date +%s)"
mkdir -p "$BACKUP_NAME"
configs=("hypr" "rofi" "waybar" "swaync" "wlogout" "kitty" "scripts" "eww" "fastfetch")
for config in "${configs[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        mv "$CONFIG_DIR/$config" "$BACKUP_NAME/"
    fi
done

# Copy new configs
echo "📝 Applying configuration files..."
cp -r "$DOTFILES_DIR/config/"* "$CONFIG_DIR/"
cp -r "$DOTFILES_DIR/wallpapers" "$HOME/"
cp "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/" 2>/dev/null

# Make scripts executable
chmod +x "$CONFIG_DIR/scripts/"*

# Generate initial colors
echo "🎨 Generating initial colors..."
if [ -f "$HOME/wallpapers/Snoopy.jpg" ]; then
    "$CONFIG_DIR/scripts/theme.sh" "$HOME/wallpapers/Snoopy.jpg"
fi

echo "✨ Installation Complete! Log out and back in to Hyprland."
