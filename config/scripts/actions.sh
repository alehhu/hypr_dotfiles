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

# Options List
options=(
    "$ICON_MODE  SERVER MODE (Kill GUI, Save Power)"
    "$ICON_DESK  DESKTOP MODE (All Systems Go)"
    "$ICON_BOOT  Boot to CLI (Next Restart)"
    "$ICON_BOOT  Boot to GUI (Next Restart)"
    "$ICON_TRANS Translate Selection (-> IT)"
    "$ICON_OCR   Extract Text from Area (OCR)"
    "$ICON_COLOR Pick Color (Hex)"
    "$ICON_DICT  Define Word (Clipboard/Input)"
    "$ICON_LAB   Lab UP (Docker & Minikube)"
    "$ICON_LAB   Lab DOWN (Save Battery)"
    "$ICON_POWER Power Save (TLP On)"
    "$ICON_POWER Max Performance (TLP Off)"
    "$ICON_RADIO Radio ON (Wi-Fi & BT)"
    "$ICON_RADIO Radio OFF (Airplane Mode)"
    "$ICON_THEME Change Wallpaper & Theme"
    "$ICON_CLIP  Clipboard History"
)

# Show Rofi Menu
choice=$(printf "%s\n" "${options[@]}" | rofi -dmenu -i -p "󱐌 Quick Actions" -config "$ROFI_CONF")

# Handle Choice
case "$choice" in
    *"SERVER MODE"*)
        notify-send "System" "Activating Server Mode..."
        # Logic from server-mode alias
        sudo systemctl isolate multi-user.target &
        sudo rfkill block bluetooth &
        minikube stop &
        sudo systemctl stop docker &
        sudo systemctl start tlp &
        notify-send "System" "🦇 Server Mode Active"
        ;;
    *"DESKTOP MODE"*)
        notify-send "System" "Activating Desktop Mode..."
        # Logic from desktop-mode alias
        sudo systemctl start tlp & # ensure tlp logic is handled or stopped
        sudo systemctl stop tlp &
        sudo rfkill unblock bluetooth wifi &
        sudo systemctl isolate graphical.target &
        notify-send "System" "🚀 Desktop Mode Active"
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
    *"Power Save"*)
        sudo systemctl start tlp && notify-send "Power" "🍃 TLP Enabled"
        ;;
    *"Max Performance"*)
        sudo systemctl stop tlp && notify-send "Power" "🔥 Performance Mode"
        ;;
    *"Radio ON"*)
        sudo rfkill unblock bluetooth wifi && notify-send "Radio" "📡 Radios Active"
        ;;
    *"Radio OFF"*)
        sudo rfkill block bluetooth wifi && notify-send "Radio" "📡 Airplane Mode"
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
