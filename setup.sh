#!/bin/bash

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "📦 Syncing your dotfiles into $DOTFILES_DIR..."

# List of config directories to include
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
)

# Sync configs (using rsync with --delete to remove files not in source)
mkdir -p "$DOTFILES_DIR/config"
for config in "${configs[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        echo " - Syncing $config..."
        rsync -av --delete "$CONFIG_DIR/$config/" "$DOTFILES_DIR/config/$config/"
    fi
done

# Sync single files
rsync -av "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/" 2>/dev/null

# Sync wallpapers
echo " - Syncing wallpapers..."
mkdir -p "$DOTFILES_DIR/wallpapers"
rsync -av --delete "$HOME/wallpapers/" "$DOTFILES_DIR/wallpapers/"

echo "✅ Done! Your dotfiles are now a perfect mirror of your setup."
echo "You can now commit and push to your repository."
