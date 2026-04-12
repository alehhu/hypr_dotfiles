#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/wallpapers"
CACHE_DIR="$HOME/.cache/wal"
HYPR_CONF="$HOME/.config/hypr/colors.conf"

# Select wallpaper backend (swww renamed to awww)
if command -v awww >/dev/null 2>&1; then
    WALLPAPER_CMD="awww"
    if command -v awww-daemon >/dev/null 2>&1; then
        DAEMON_CMD="awww-daemon"
        DAEMON_NAME="awww-daemon"
    elif command -v swww-daemon >/dev/null 2>&1; then
        DAEMON_CMD="swww-daemon"
        DAEMON_NAME="swww-daemon"
    else
        notify-send "Error" "awww found but no daemon (awww-daemon/swww-daemon)."
        exit 1
    fi
elif command -v swww >/dev/null 2>&1; then
    WALLPAPER_CMD="swww"
    DAEMON_CMD="swww-daemon"
    DAEMON_NAME="swww-daemon"
else
    notify-send "Error" "Neither awww nor swww found. Install one to set wallpapers."
    exit 1
fi

# Ensure daemon is running
if ! pgrep -x "$DAEMON_NAME" > /dev/null; then
    "$DAEMON_CMD" &
    sleep 1
fi

# Pick a wallpaper
if [ -z "$1" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
else
    WALLPAPER="$1"
fi

# Apply wallpaper
"$WALLPAPER_CMD" img "$WALLPAPER" --transition-type grow --transition-pos "$(hyprctl cursorpos | tr -d ' ')" --transition-step 90

# Generate colors with wal
wal -i "$WALLPAPER" -q -t

# Generate Hyprland colors
{
    echo "\$wallpaper = $WALLPAPER"
    echo "\$background = rgb($(cat "$CACHE_DIR/colors" | sed -n '1p' | sed 's/#//'))"
    echo "\$foreground = rgb($(cat "$CACHE_DIR/colors" | sed -n '16p' | sed 's/#//'))"
    echo "\$color0 = rgb($(cat "$CACHE_DIR/colors" | sed -n '1p' | sed 's/#//'))"
    echo "\$color1 = rgb($(cat "$CACHE_DIR/colors" | sed -n '2p' | sed 's/#//'))"
    echo "\$color2 = rgb($(cat "$CACHE_DIR/colors" | sed -n '3p' | sed 's/#//'))"
    echo "\$color3 = rgb($(cat "$CACHE_DIR/colors" | sed -n '4p' | sed 's/#//'))"
    echo "\$color4 = rgb($(cat "$CACHE_DIR/colors" | sed -n '5p' | sed 's/#//'))"
    echo "\$color5 = rgb($(cat "$CACHE_DIR/colors" | sed -n '6p' | sed 's/#//'))"
    echo "\$color6 = rgb($(cat "$CACHE_DIR/colors" | sed -n '7p' | sed 's/#//'))"
    echo "\$color7 = rgb($(cat "$CACHE_DIR/colors" | sed -n '8p' | sed 's/#//'))"
    echo "\$color8 = rgb($(cat "$CACHE_DIR/colors" | sed -n '9p' | sed 's/#//'))"
    echo "\$color9 = rgb($(cat "$CACHE_DIR/colors" | sed -n '10p' | sed 's/#//'))"
    echo "\$color10 = rgb($(cat "$CACHE_DIR/colors" | sed -n '11p' | sed 's/#//'))"
    echo "\$color11 = rgb($(cat "$CACHE_DIR/colors" | sed -n '12p' | sed 's/#//'))"
    echo "\$color12 = rgb($(cat "$CACHE_DIR/colors" | sed -n '13p' | sed 's/#//'))"
    echo "\$color13 = rgb($(cat "$CACHE_DIR/colors" | sed -n '14p' | sed 's/#//'))"
    echo "\$color14 = rgb($(cat "$CACHE_DIR/colors" | sed -n '15p' | sed 's/#//'))"
    echo "\$color15 = rgb($(cat "$CACHE_DIR/colors" | sed -n '16p' | sed 's/#//'))"
} > "$HYPR_CONF"

# Reload SwayNC
swaync-client -rs

# Reload Waybar (if running)
killall -USR2 waybar

# Reload Eww (if running)
if pgrep -x "eww" > /dev/null; then
    eww reload
else
    eww daemon
    sleep 1
    eww open bar
fi

# Send notification
notify-send "Theme Updated" "Wallpaper: $(basename "$WALLPAPER")" -i "$WALLPAPER"
