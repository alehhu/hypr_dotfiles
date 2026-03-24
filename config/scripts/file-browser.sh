#!/bin/bash

# Configuration
ROFI_CONF="$HOME/.config/rofi/config.rasi"
SEARCH_DIR="$HOME"

# Find files (excluding hidden ones for cleaner look)
# Limit to common user directories for speed
selected=$(find "$SEARCH_DIR/Documents" "$SEARCH_DIR/Downloads" "$SEARCH_DIR/Pictures" "$SEARCH_DIR/Music" -maxdepth 2 -not -path '*/.*' 2>/dev/null | \
    sed "s|$HOME/||" | \
    rofi -dmenu -i -p "󰈞 Find File" -config "$ROFI_CONF")

# If a file was selected, open it with the default app
if [ -n "$selected" ]; then
    xdg-open "$HOME/$selected" &
fi
