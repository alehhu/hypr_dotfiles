#!/bin/bash

# Configuration
ROFI_CONF="$HOME/.config/rofi/config.rasi"

# Icons
ICON_MODE="🦇"
ICON_DESK="🚀"
ICON_LAB="🧪"
ICON_POWER="⚡"
ICON_RADIO="📡"
ICON_THEME="🎨"
ICON_DICT="📖"
ICON_CLIP="📋"
ICON_TRANS="🌐"
ICON_COLOR="🖌️"
ICON_OCR="🔍"
ICON_BOOT="⚙️"
ICON_EYE="👁️"
ICON_AI="🤖"
ICON_FILE="📂"
ICON_DEV="💻"
ICON_DOCKER="🐳"

# Options List
options=(
    "$ICON_MODE  SERVER MODE"
    "$ICON_DESK  DESKTOP MODE"
    "$ICON_AI    AI Quick Ask (Selected Text)"
    "$ICON_FILE  Fuzzy File Search"
    "$ICON_DEV   Kill Local Port (Rofi)"
    "$ICON_DOCKER Docker Clean (Prune)"
    "$ICON_DEV   Prettify JSON (Clipboard)"
    "$ICON_EYE   Night Shift (Toggle)"
    "$ICON_BOOT  Boot to CLI"
    "$ICON_BOOT  Boot to GUI"
    "$ICON_TRANS Translate Selection (-> IT)"
    "$ICON_OCR   Extract Text (OCR)"
    "$ICON_COLOR Pick Color (Hex)"
    "$ICON_DICT  Define Word"
    "$ICON_LAB   Lab UP"
    "$ICON_LAB   Lab DOWN"
    "$ICON_POWER Power Save"
    "$ICON_POWER Max Performance"
    "$ICON_RADIO Radio ON"
    "$ICON_RADIO Radio OFF"
    "$ICON_THEME Change Wallpaper & Theme"
    "$ICON_CLIP  Clipboard History"
)

# Show Rofi Menu
choice=$(printf "%s\n" "${options[@]}" | rofi -dmenu -i -p "󱐌 Quick Actions" -config "$ROFI_CONF")

# Handle Choice
case "$choice" in
    *"SERVER MODE"*)
        notify-send "System" "Activating Server Mode..."
        sudo systemctl isolate multi-user.target &
        sudo rfkill block bluetooth &
        minikube stop &
        sudo systemctl stop docker &
        sudo systemctl start tlp &
        notify-send "System" "🦇 Server Mode Active"
        ;;
    *"DESKTOP MODE"*)
        notify-send "System" "Activating Desktop Mode..."
        sudo systemctl start tlp &
        sudo systemctl stop tlp &
        sudo rfkill unblock bluetooth wifi &
        sudo systemctl isolate graphical.target &
        notify-send "System" "🚀 Desktop Mode Active"
        ;;
    *"Kill Local Port"*)
        # List ports and the process using them
        port_list=$(sudo lsof -i -P -n | grep LISTEN | awk '{print $9 " (" $1 " - PID: " $2 ")"}' | sort -u)
        if [ -z "$port_list" ]; then
            notify-send "Dev Tools" "No active local ports found."
        else
            selected_port=$(echo "$port_list" | rofi -dmenu -p "💀 Kill Port" -config "$ROFI_CONF")
            if [ -n "$selected_port" ]; then
                pid=$(echo "$selected_port" | grep -oP "PID: \K\d+")
                sudo kill -9 "$pid" && notify-send "Dev Tools" "Terminated process $pid on $selected_port"
            fi
        fi
        ;;
    *"Docker Clean"*)
        notify-send "Docker" "Pruning containers, networks, and images..."
        docker system prune -f && notify-send "Docker" "✨ Docker System Cleaned!"
        ;;
    *"Prettify JSON"*)
        json_content=$(wl-paste)
        if echo "$json_content" | jq . > /dev/null 2>&1; then
            echo "$json_content" | jq . | wl-copy
            notify-send "Dev Tools" "JSON formatted and copied to clipboard!"
        else
            notify-send "Error" "Clipboard does not contain valid JSON"
        fi
        ;;
    *"AI Quick Ask"*)
        ~/.config/scripts/ai-ask.sh
        ;;
    *"Fuzzy File Search"*)
        ~/.config/scripts/file-browser.sh
        ;;
    *"Night Shift"*)
        pkill gammastep || gammastep -O 3500 & notify-send "Night Shift" "Warm colors active"
        ;;
    *"Boot to CLI"*)
        sudo systemctl set-default multi-user.target && notify-send "Boot" "Next boot: CLI (Headless)"
        ;;
    *"Boot to GUI"*)
        sudo systemctl set-default graphical.target && notify-send "Boot" "Next boot: GUI (Desktop)"
        ;;
    *"Translate"*)
        word=$(wl-paste -p 2>/dev/null || wl-paste 2>/dev/null)
        if [ -n "$word" ]; then
            translation=$(trans -b :it "$word")
            notify-send "Translation (IT)" "$translation" -i accessories-dictionary
        else
            notify-send "Error" "No text selected to translate"
        fi
        ;;
    *"Extract Text"*)
        notify-send "OCR" "Select an area to extract text..."
        text=$(grim -g "$(slurp)" - | tesseract stdin stdout -l eng+ita 2>/dev/null)
        if [ -n "$text" ]; then
            echo "$text" | wl-copy
            notify-send "OCR" "Text copied to clipboard!"
        fi
        ;;
    *"Pick Color"*)
        color=$(hyprpicker -a)
        if [ -n "$color" ]; then
            notify-send "Color Picker" "Picked: $color"
        fi
        ;;
    *"Lab UP"*)
        notify-send "Lab" "Starting Docker and Minikube..."
        sudo systemctl start docker && minikube start && notify-send "Lab" "⚡ Lab Online!"
        ;;
    *"Lab DOWN"*)
        notify-send "Lab" "Stopping Lab..."
        minikube stop && sudo systemctl stop docker && notify-send "Lab" "💤 Lab Offline."
        ;;
    *"Change Wallpaper"*)
        ~/.config/scripts/theme.sh
        ;;
    *"Define Word"*)
        word=$(wl-paste -p 2>/dev/null || echo "")
        input=$(echo "$word" | rofi -dmenu -p "📖 Define" -config "$ROFI_CONF")
        if [ -n "$input" ]; then
            ~/.config/scripts/define.sh "$input"
        fi
        ;;
    *"Clipboard History"*)
        cliphist list | rofi -dmenu -p "📋 Clipboard" -config "$ROFI_CONF" | cliphist decode | wl-copy
        ;;
esac
