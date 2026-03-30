#!/bin/bash
# Window Swallower for Hyprland
# Hides terminal windows when GUI apps are launched from them

# Monitor window open events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    # Parse window open events
    if echo "$line" | grep -q "^openwindow>>"; then
        # Extract window address
        addr=$(echo "$line" | cut -d'>' -f3 | cut -d',' -f1)
        
        # Get window info
        window_info=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$addr\")")
        class=$(echo "$window_info" | jq -r '.class')
        pid=$(echo "$window_info" | jq -r '.pid')
        
        # List of GUI apps that should swallow terminals
        swallow_apps="mpv|vlc|zathura|feh|sxiv|imv|gimp|inkscape|firefox|chromium|brave"
        
        if echo "$class" | grep -qE "$swallow_apps"; then
            # Get parent process (terminal)
            parent_pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
            
            # Check if parent is a terminal
            parent_class=$(hyprctl clients -j | jq -r ".[] | select(.pid == $parent_pid) | .class")
            
            if echo "$parent_class" | grep -qE "kitty|alacritty|foot|wezterm|st"; then
                # Get terminal window address
                term_addr=$(hyprctl clients -j | jq -r ".[] | select(.pid == $parent_pid) | .address")
                
                # Hide terminal
                hyprctl dispatch movetoworkspacesilent special:swallowed,address:$term_addr
                
                # Store mapping for later restoration
                echo "$addr:$term_addr" >> /tmp/hypr_swallowed_windows
            fi
        fi
    fi
    
    # Restore terminal when GUI app closes
    if echo "$line" | grep -q "^closewindow>>"; then
        closed_addr=$(echo "$line" | cut -d'>' -f3)
        
        # Check if this window had a swallowed terminal
        if [ -f /tmp/hypr_swallowed_windows ]; then
            term_addr=$(grep "^$closed_addr:" /tmp/hypr_swallowed_windows | cut -d':' -f2)
            
            if [ -n "$term_addr" ]; then
                # Restore terminal to current workspace
                current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
                hyprctl dispatch movetoworkspacesilent "$current_ws,address:$term_addr"
                
                # Remove from swallowed list
                sed -i "/^$closed_addr:/d" /tmp/hypr_swallowed_windows
            fi
        fi
    fi
done
