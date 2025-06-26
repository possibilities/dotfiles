#!/bin/bash

# Default screenshot directory
SCREENSHOT_DIR="$HOME/screenshots"

# Create directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Check if this is for fullscreen or gui
MODE="${1:-gui}"

# Generate filename with timestamp
if [ "$MODE" = "screen" ]; then
    FILENAME="$(date +%Y-%m-%d_%H-%M-%S)_fullscreen.png"
else
    FILENAME="$(date +%Y-%m-%d_%H-%M-%S)_screenshot.png"
fi
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Take screenshot
if [ "$MODE" = "screen" ]; then
    flameshot screen --raw > "$FILEPATH"
else
    flameshot gui --raw > "$FILEPATH"
fi

# Check if screenshot was taken (file is not empty)
if [ -s "$FILEPATH" ]; then
    # Copy filepath to clipboard
    echo -n "$FILEPATH" | xclip -selection clipboard
    
    # Always notify about local save
    notify-send "Screenshot saved" "Saved to $FILEPATH (path copied to clipboard)"
    
    # If we're on smallbird, also copy to fatbird
    if [ "$(hostname)" = "smallbird" ]; then
        # Sync in background but with proper handling
        (
            # Try to find a working SSH agent socket
            for socket in $(find /tmp -type s -name "agent.*" 2>/dev/null | head -5); do
                if SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1; then
                    export SSH_AUTH_SOCK="$socket"
                    break
                fi
            done
            
            # If no working socket found, try the default locations
            if ! ssh-add -l >/dev/null 2>&1; then
                for socket in /run/user/1000/openssh_agent /run/user/1000/keyring/ssh; do
                    if [ -S "$socket" ] && SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1; then
                        export SSH_AUTH_SOCK="$socket"
                        break
                    fi
                done
            fi
            
            # Add a small delay
            sleep 1
            
            # Create remote directory if needed
            ssh -o ConnectTimeout=10 -o PasswordAuthentication=no -o BatchMode=yes fatbird "mkdir -p ~/screenshots" 2>/dev/null
            
            # Copy the file with connection options
            scp -o ConnectTimeout=10 -o PasswordAuthentication=no -o BatchMode=yes "$FILEPATH" "fatbird:~/screenshots/" 2>/dev/null
            SCP_RESULT=$?
            
            if [ $SCP_RESULT -eq 0 ]; then
                notify-send "Screenshot synced" "Successfully copied to fatbird"
            else
                # Log error for debugging with more details
                {
                    echo "$(date): SCP failed with exit code $SCP_RESULT for $FILEPATH"
                    echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
                    echo "ssh-add -l output:"
                    ssh-add -l 2>&1
                } >> /tmp/flameshot-sync-errors.log
                notify-send "Sync failed" "Could not copy to fatbird (check /tmp/flameshot-sync-errors.log)"
            fi
        ) &
    fi
else
    # Remove empty file if screenshot was cancelled
    rm -f "$FILEPATH"
fi