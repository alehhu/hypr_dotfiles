#!/bin/bash

# Dynamic Workspace Module with App Icons and Hover Reveal
# Usage: ./workspaces.sh

declare -A ICONS
ICONS=(
    ["firefox"]="󰈹"
    ["kitty"]="󰆍"
    ["discord"]="󰙯"
    ["steam"]="󰓓"
    ["spotify"]="󰝚"
    ["thunar"]="󰉋"
    ["vscodium"]="󰨞"
    ["default"]="󰄰"
    ["empty"]="󰄯"
)

workspaces() {
    # Get active workspace ID safely
    local active_ws
    active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    
    # Get all clients
    local clients
    clients=$(hyprctl clients -j)
    
    # Start the Eww widget string (Must be a single line for literal)
    local output="(box :class \"workspaces-pill\" :spacing 12 :space-evenly false"
    
    for i in {1..10}; do
        # Find if any client exists in this workspace
        local ws_client
        ws_client=$(echo "$clients" | jq -r ".[] | select(.workspace.id == $i) | .class" | head -n 1 | tr '[:upper:]' '[:lower:]' | xargs)
        
        # Determine visibility
        local show=false
        if (( i <= 5 )); then
            show=true
        elif [[ "$i" == "$active_ws" ]]; then
            show=true
        elif [[ -n "$ws_client" && "$ws_client" != "null" ]]; then
            show=true
        fi

        if [[ "$show" == "true" ]]; then
            local class="workspace-btn"
            [[ "$i" == "$active_ws" ]] && class="workspace-btn active"
            
            # Pick icon safely
            local icon="${ICONS["default"]}"
            if [[ -n "$ws_client" && "$ws_client" != "null" ]]; then
                if [[ ${ICONS[$ws_client]+_} ]]; then
                    icon="${ICONS[$ws_client]}"
                fi
            elif [[ "$i" == "$active_ws" ]]; then
                icon="${ICONS["empty"]}"
            fi

            # Reveal logic: show icon when show_numbers is false, show number when true
            # Fix: Use 'revealer' instead of 'reveal'
            output="$output (button :class \"$class\" :onclick \"hyprctl dispatch workspace $i\" (box :space-evenly false (revealer :transition \"slideright\" :reveal {!show_numbers} :duration \"300ms\" (label :class \"ws-icon\" :text \"$icon\")) (revealer :transition \"slideleft\" :reveal {show_numbers} :duration \"300ms\" (label :class \"ws-num\" :text \"$i\"))))"
        fi
    done
    
    output="$output)"
    echo "$output"
}

# Initial output
workspaces

# Listen for Hyprland events
socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
    case "$line" in
        workspace*|focusedmon*|openwindow*|closewindow*|movewindow*|activewindow*)
            sleep 0.1
            workspaces
            ;;
    esac
done
