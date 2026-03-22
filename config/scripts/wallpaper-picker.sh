#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/wallpapers"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

# Ensure the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Error" "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Generate the list for Rofi (Name \0 icon \x1f path)
# This lets Rofi show the actual image as the icon
list_wallpapers() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | while read -r wall; do
        name=$(basename "$wall")
        echo -en "$name\0icon\x1f$wall\n"
    done
}

# Show Rofi picker
selected=$(list_wallpapers | rofi -dmenu -i -p "󰸉 Wallpapers" -theme "$ROFI_THEME")

# If an image was selected, apply it
if [ -n "$selected" ]; then
    wall_path="$WALLPAPER_DIR/$selected"
    if [ -f "$wall_path" ]; then
        ~/.config/scripts/theme.sh "$wall_path"
    fi
fi
