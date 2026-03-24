#!/bin/bash

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "📦 Syncing your dotfiles into $DOTFILES_DIR..."

# 1. Config directories (Added missing visuals and themes)
configs=(
    "hypr"
    "rofi"
    "waybar"
    "swaync"
    "wlogout"
    "kitty"
    "scripts"
    "eww"
    "fastfetch"
    "dunst"
    "btop"
    "cava"
    "wal"
    "gtk-3.0"
    "qt5ct"
    "qt6ct"
)

# Sync configs (using rsync with --delete to remove files not in source)
mkdir -p "$DOTFILES_DIR/config"
for config in "${configs[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        echo " - Syncing $config..."
        rsync -av --delete "$CONFIG_DIR/$config/" "$DOTFILES_DIR/config/$config/"
    fi
done

# 2. Sync home dotfiles (Critical shell/git/vim configs)
echo " - Syncing root dotfiles..."
cp "$HOME/.zshrc" "$DOTFILES_DIR/zshrc" 2>/dev/null
cp "$HOME/.zshenv" "$DOTFILES_DIR/zshenv" 2>/dev/null
cp "$HOME/.gitconfig" "$DOTFILES_DIR/gitconfig" 2>/dev/null
cp "$HOME/.vimrc" "$DOTFILES_DIR/vimrc" 2>/dev/null

# Sync single files from .config
rsync -av "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/" 2>/dev/null

# 3. Sync wallpapers
echo " - Syncing wallpapers..."
mkdir -p "$DOTFILES_DIR/wallpapers"
rsync -av --delete "$HOME/wallpapers/" "$DOTFILES_DIR/wallpapers/"

# 4. Export package lists (Crucial for restoration)
echo " - Exporting package lists..."
pacman -Qqe > "$DOTFILES_DIR/pkglist.txt"
if command -v paru &> /dev/null; then
    paru -Qqe > "$DOTFILES_DIR/aur_pkglist.txt"
elif command -v yay &> /dev/null; then
    yay -Qqe > "$DOTFILES_DIR/aur_pkglist.txt"
fi

echo "✅ Done! Your dotfiles and package lists are now backed up."
echo "You can now commit and push to your repository."
