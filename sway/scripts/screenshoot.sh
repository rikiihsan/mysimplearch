#!/bin/bash
# Screenshot script for Sway

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILENAME="$DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

case "$1" in
    full)
        # Full screen
        grim "$FILENAME"
        ;;
    select)
        # Select area
        grim -g "$(slurp)" "$FILENAME"
        ;;
    window)
        # Current window
        grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" "$FILENAME"
        ;;
    *)
        echo "Usage: $0 {full|select|window}"
        exit 1
        ;;
esac

if [ -f "$FILENAME" ]; then
    # Copy to clipboard
    wl-copy < "$FILENAME"
    
    # Show notification
    notify-send "Screenshot" "Saved to $FILENAME" -i "$FILENAME"
    
    # Optional: open in swappy for editing
    # swappy -f "$FILENAME"
fi