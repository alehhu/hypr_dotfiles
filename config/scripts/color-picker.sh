#!/bin/bash
# Advanced Color Picker with History
# Uses hyprpicker and stores color history

HISTORY_FILE="$HOME/.cache/color_picker_history"
MAX_HISTORY=20

# Ensure history file exists
touch "$HISTORY_FILE"

# If argument provided, show history instead of picking
if [ "$1" = "--history" ]; then
    if [ ! -s "$HISTORY_FILE" ]; then
        notify-send "Color Picker" "No colors in history"
        exit 0
    fi
    
    # Show history with rofi and color preview
    selected=$(cat "$HISTORY_FILE" | rofi -dmenu -i \
        -p "Color History" \
        -mesg "Select a color to copy" \
        -theme-str 'listview { columns: 1; }' \
        -lines 10)
    
    if [ -n "$selected" ]; then
        echo -n "$selected" | wl-copy
        notify-send "Color Picker" "Copied: $selected"
    fi
    exit 0
fi

# Pick a color
COLOR=$(hyprpicker -a -f hex)

if [ -n "$COLOR" ]; then
    # Add to history (remove duplicates, keep recent)
    grep -v "^$COLOR$" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" 2>/dev/null || true
    echo "$COLOR" > "$HISTORY_FILE"
    cat "$HISTORY_FILE.tmp" >> "$HISTORY_FILE" 2>/dev/null || true
    rm -f "$HISTORY_FILE.tmp"
    
    # Keep only last MAX_HISTORY entries
    tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
    mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    
    # Copy to clipboard and notify
    echo -n "$COLOR" | wl-copy
    notify-send "Color Picker" "Picked: $COLOR\n(Already copied to clipboard)"
fi
