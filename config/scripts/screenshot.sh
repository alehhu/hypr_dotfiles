#!/bin/bash
# Enhanced Screenshot Script with Annotation and OCR
# Supports: Full screen, area selection, annotation, OCR text extraction

MODE="${1:-full}"
OUTPUT_DIR="$HOME/screenshots"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
TEMP_FILE="/tmp/screenshot_$TIMESTAMP.png"
FINAL_FILE="$OUTPUT_DIR/screenshot_$TIMESTAMP.png"

case "$MODE" in
    full)
        # Full screenshot
        grim "$TEMP_FILE"
        ;;
    area)
        # Area selection
        grim -g "$(slurp)" "$TEMP_FILE"
        ;;
    ocr)
        # Screenshot area and extract text with OCR
        grim -g "$(slurp)" "$TEMP_FILE"
        
        if [ -f "$TEMP_FILE" ]; then
            # Extract text with tesseract
            text=$(tesseract "$TEMP_FILE" - 2>/dev/null)
            
            if [ -n "$text" ]; then
                # Copy to clipboard
                echo "$text" | wl-copy
                notify-send "OCR Complete" "Text copied to clipboard" -i "$TEMP_FILE"
                
                # Save text file alongside image
                echo "$text" > "$OUTPUT_DIR/screenshot_$TIMESTAMP.txt"
                mv "$TEMP_FILE" "$FINAL_FILE"
            else
                notify-send "OCR Failed" "No text detected" -i "$TEMP_FILE"
                rm "$TEMP_FILE"
            fi
        fi
        exit 0
        ;;
    *)
        notify-send "Screenshot" "Invalid mode: $MODE"
        exit 1
        ;;
esac

# If screenshot was taken, open in satty for annotation
if [ -f "$TEMP_FILE" ]; then
    # Open satty for annotation (non-blocking)
    satty --filename "$TEMP_FILE" --output-filename "$FINAL_FILE" --early-exit &
    
    # Wait a moment then check if file was saved
    sleep 0.5
    
    # Satty saves on its own, notify user
    notify-send "Screenshot" "Opening annotation tool" -i "$TEMP_FILE"
fi
