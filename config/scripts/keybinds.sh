#!/bin/bash

# Configuration
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# Ensure the file exists
if [ ! -f "$HYPR_CONF" ]; then
    notify-send "Error" "Hyprland config not found"
    exit 1
fi

# Extract keybindings and format them
# This handles: bind, binde, bindm, bindl, bindle, etc.
# It also translates $mod to SUPER and formats the output for Rofi
keybinds=$(grep -P '^bind[a-z]*\s*=' "$HYPR_CONF" | \
    sed -E 's/^bind[a-z]*\s*=\s*//' | \
    sed -E 's/\$mod/SUPER/g' | \
    awk -F, '{
        # Clean up whitespace
        gsub(/^[ \t]+|[ \t]+$/, "", $1);
        gsub(/^[ \t]+|[ \t]+$/, "", $2);
        gsub(/^[ \t]+|[ \t]+$/, "", $3);
        
        # Build the key combo
        combo = "";
        if ($1 != "") combo = $1 " + ";
        combo = combo $2;
        
        # Action is everything after the 3rd comma
        action = "";
        for(i=4; i<=NF; i++) {
            if (i > 4) action = action ",";
            action = action $i;
        }
        gsub(/^[ \t]+|[ \t]+$/, "", action);
        
        # Clean up common commands for better display
        gsub(/^exec,/, "", action);
        gsub(/^\[.*\]/, "", action);
        
        printf "%-25s ->  %s\n", combo, action
    }' | sort)

# Show in Rofi
selected=$(echo -e "$keybinds" | rofi -dmenu -i -p "󰌌 Keybinds" -config ~/.config/rofi/config.rasi)

# Optional: If a keybind is selected, we could try to execute it, 
# but for now, it's just a reference tool.
