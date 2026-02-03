#!/bin/bash
# Screen recording script for Sway

DIR="$HOME/Videos/Recordings"
mkdir -p "$DIR"

PIDFILE="/tmp/wf-recorder.pid"

if [ -f "$PIDFILE" ]; then
    # Stop recording
    PID=$(cat "$PIDFILE")
    kill -SIGINT "$PID"
    rm "$PIDFILE"
    notify-send "Screen Recording" "Recording stopped"
else
    # Start recording
    FILENAME="$DIR/screencast_$(date +%Y%m%d_%H%M%S).mp4"
    
    # Ask user what to record
    CHOICE=$(echo -e "Full Screen\nSelect Area\nCancel" | rofi -dmenu -p "Record:")
    
    case "$CHOICE" in
        "Full Screen")
            wf-recorder -f "$FILENAME" &
            echo $! > "$PIDFILE"
            notify-send "Screen Recording" "Recording full screen..."
            ;;
        "Select Area")
            GEOMETRY=$(slurp)
            if [ -n "$GEOMETRY" ]; then
                wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
                echo $! > "$PIDFILE"
                notify-send "Screen Recording" "Recording selected area..."
            fi
            ;;
        *)
            exit 0
            ;;
    esac
fi