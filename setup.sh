#!/bin/bash

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "📦 Packing your dotfiles into $DOTFILES_DIR..."

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

# Copy configs
for config in "${configs[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        echo " - Copying $config..."
        cp -r "$CONFIG_DIR/$config" "$DOTFILES_DIR/config/"
    fi
done

# Copy single files
cp "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/" 2>/dev/null

# Copy wallpapers
echo " - Copying wallpapers..."
cp -r "$HOME/wallpapers" "$DOTFILES_DIR/"

echo "✅ Done! Your configs are now in $DOTFILES_DIR."
echo "You can now 'git init' in that folder and push to GitHub."
