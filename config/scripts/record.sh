#!/bin/bash

# Configuration
SAVE_DIR="$HOME/screen-recordings"
PID_FILE="$HOME/.cache/recording.pid"

# Ensure save directory exists
mkdir -p "$SAVE_DIR"

# Function to stop recording
stop_recording() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            kill -SIGINT "$PID"
            rm "$PID_FILE"
            notify-send "Screen Recording" "Recording stopped and saved to $SAVE_DIR" -i camera-video
            exit 0
        fi
        rm "$PID_FILE"
    fi
}

# Function to start recording
start_recording() {
    FILENAME="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    
    # Check for area selection
    GEOMETRY=""
    if [ "$1" == "--area" ]; then
        notify-send "Screen Recording" "Select an area to record..." -i camera-video
        GEOMETRY=$(slurp)
        if [ -z "$GEOMETRY" ]; then
            notify-send "Screen Recording" "Cancelled area selection" -i camera-video
            exit 0
        fi
    fi

    # notify-send "Screen Recording" "Starting recording..." -i camera-video
    
    # wf-recorder command
    # -a: include audio
    # -f: output file
    if [ -n "$GEOMETRY" ]; then
        wf-recorder -a -g "$GEOMETRY" -f "$FILENAME" > /dev/null 2>&1 &
    else
        wf-recorder -a -f "$FILENAME" > /dev/null 2>&1 &
    fi
    
    REC_PID=$!
    echo $REC_PID > "$PID_FILE"
    notify-send "Screen Recording" "Recording started..." -i camera-video
}

# Main logic: Toggle
if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null; then
    stop_recording
else
    start_recording "$1"
fi
