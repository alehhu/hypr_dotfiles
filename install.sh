#!/bin/bash

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🚀 Starting Portable Dotfiles Installation..."

# 1. Install Dependencies from Package Lists
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
    echo "📦 Installing core packages from pkglist.txt..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist.txt"
fi

if [ -f "$DOTFILES_DIR/aur_pkglist.txt" ]; then
    if command -v paru &> /dev/null; then
        echo "📦 Installing AUR packages using paru..."
        paru -S --needed --noconfirm - < "$DOTFILES_DIR/aur_pkglist.txt"
    elif command -v yay &> /dev/null; then
        echo "📦 Installing AUR packages using yay..."
        yay -S --needed --noconfirm - < "$DOTFILES_DIR/aur_pkglist.txt"
    fi
fi

# Enable System Services
echo "⚙️ Enabling system services..."
sudo systemctl enable --now docker 2>/dev/null
sudo systemctl enable --now tlp 2>/dev/null

# 2. Backup existing configs
echo "💾 Backing up existing configs..."
BACKUP_NAME="$HOME/.dotfiles-backup-$(date +%s)"
mkdir -p "$BACKUP_NAME"

configs=(
    "hypr" "rofi" "waybar" "swaync" "wlogout" 
    "kitty" "scripts" "eww" "fastfetch" 
    "dunst" "btop" "cava" "wal" "gtk-3.0" "qt5ct" "qt6ct"
    "zsh"
)

for config in "${configs[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        mv "$CONFIG_DIR/$config" "$BACKUP_NAME/" 2>/dev/null
    fi
done

# Backup root dotfiles
cp "$HOME/.zshenv" "$BACKUP_NAME/zshenv" 2>/dev/null
cp "$HOME/.gitconfig" "$BACKUP_NAME/gitconfig" 2>/dev/null
cp "$HOME/.vimrc" "$BACKUP_NAME/vimrc" 2>/dev/null

# 3. Apply new configs
echo "📝 Applying configuration files..."
mkdir -p "$CONFIG_DIR"
# Copy each directory from dotfiles/config to ~/.config/
cp -r "$DOTFILES_DIR/config/"* "$CONFIG_DIR/"
# Sync wallpapers folder to ~/wallpapers
cp -r "$DOTFILES_DIR/wallpapers" "$HOME/"

# Restore ROS2 Docker Workspace scripts
echo "🐳 Restoring ROS2 Docker Workspace..."
mkdir -p "$HOME/ros2-workspace/src"
cp "$DOTFILES_DIR/ros2/Dockerfile" "$HOME/ros2-workspace/" 2>/dev/null
cp "$DOTFILES_DIR/ros2/docker-compose.yml" "$HOME/ros2-workspace/" 2>/dev/null

# Restore root dotfiles
cp "$DOTFILES_DIR/zshenv" "$HOME/.zshenv" 2>/dev/null
cp "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig" 2>/dev/null
cp "$DOTFILES_DIR/vimrc" "$HOME/.vimrc" 2>/dev/null

# Make scripts executable
chmod +x "$CONFIG_DIR/scripts/"* 2>/dev/null

# 4. Generate initial colors
echo "🎨 Generating initial colors..."
THEME_SCRIPT="$CONFIG_DIR/scripts/theme.sh"
if [ -f "$THEME_SCRIPT" ]; then
    # Use Snoopy.jpg if available, else use a random one from the folder
    if [ -f "$HOME/wallpapers/Snoopy.jpg" ]; then
        "$THEME_SCRIPT" "$HOME/wallpapers/Snoopy.jpg"
    else
        RANDOM_WALLPAPER=$(find "$HOME/wallpapers" -type f | shuf -n 1)
        if [ -n "$RANDOM_WALLPAPER" ]; then
            "$THEME_SCRIPT" "$RANDOM_WALLPAPER"
        fi
    fi
fi

echo "✨ Installation Complete! Log out and back in to apply changes."
