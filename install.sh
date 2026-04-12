#!/bin/bash

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🚀 Starting Portable Dotfiles Installation..."

# 1. Install Dependencies from Package Lists (The most accurate way)
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

# 2. Backup existing configs (Matches setup.sh list)
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
cp -r "$DOTFILES_DIR/config/"* "$CONFIG_DIR/"
cp -r "$DOTFILES_DIR/wallpapers" "$HOME/"

# Restore root dotfiles
cp "$DOTFILES_DIR/zshenv" "$HOME/.zshenv" 2>/dev/null
cp "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig" 2>/dev/null
cp "$DOTFILES_DIR/vimrc" "$HOME/.vimrc" 2>/dev/null

# Make scripts executable
chmod +x "$CONFIG_DIR/scripts/"* 2>/dev/null

# 4. Generate initial colors (using your theme script)
echo "🎨 Generating initial colors..."
if [ -f "$HOME/wallpapers/Snoopy.jpg" ] && [ -f "$CONFIG_DIR/scripts/theme.sh" ]; then
    "$CONFIG_DIR/scripts/theme.sh" "$HOME/wallpapers/Snoopy.jpg"
fi

echo "✨ Installation Complete! Log out and back in to apply changes."
