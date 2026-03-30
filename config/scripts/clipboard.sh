#!/bin/bash
# Clipboard Manager using cliphist and rofi
# Shows clipboard history with preview and allows selection/deletion

# Get clipboard history and format for rofi
history=$(cliphist list)

if [ -z "$history" ]; then
    notify-send "Clipboard" "History is empty"
    exit 0
fi

# Show in rofi with custom options
selected=$(echo "$history" | rofi -dmenu -i \
    -p "Clipboard History" \
    -mesg "Enter: Paste | Alt+D: Delete | Alt+C: Clear All" \
    -kb-custom-1 "Alt+d" \
    -kb-custom-2 "Alt+c" \
    -lines 10 \
    -width 60)

exit_code=$?

# Handle actions
case $exit_code in
    0)  # Normal selection - paste it
        if [ -n "$selected" ]; then
            echo "$selected" | cliphist decode | wl-copy
            notify-send "Clipboard" "Copied to clipboard"
        fi
        ;;
    10) # Alt+D - Delete entry
        if [ -n "$selected" ]; then
            echo "$selected" | cliphist delete
            notify-send "Clipboard" "Entry deleted"
        fi
        ;;
    11) # Alt+C - Clear all history
        if cliphist wipe; then
            notify-send "Clipboard" "History cleared"
        fi
        ;;
esac
