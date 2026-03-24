#!/bin/bash

# Configuration
ROFI_CONF="$HOME/.config/rofi/config.rasi"

# If no argument is passed, it means we're starting the script
if [ -z "$1" ]; then
  # Show Rofi with 'drun', 'window', and a custom 'Files' mode
  # Note: Rofi 2.0 uses 'modes' instead of 'modi'
  rofi -show combi -combi-modes "drun,window,Files:/home/ale/.config/scripts/spotlight.sh files" -modes "combi" -config "$ROFI_CONF" -p "Spotlight"
  exit
fi

# If 'files' argument is passed, generate the list of files
if [ "$1" == "files" ]; then
    # List files in specific directories, excluding hidden ones
    # Limit depth for speed and relevance
    find "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/Music" "$HOME/Desktop" \
         -maxdepth 2 -not -path '*/.*' -type f 2>/dev/null | \
         sed "s|$HOME/||"
fi

# Note: Rofi's combi mode for custom scripts can be tricky.
# If the user selects a file, we want it to open.
# But combi mode usually launches the script with the selection.
# Since we handle 'files' in the same script, we can check for file existence
if [ -f "$HOME/$1" ]; then
    xdg-open "$HOME/$1" &
    exit
fi
