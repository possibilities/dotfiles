#!/bin/bash

set -euo pipefail

CONTROL_MARKER="$HOME/.dotfiles-control-machine"
CACHE_FILE="/tmp/.dotfiles-control-machine-cache"
CACHE_VALIDITY=3600  # Cache for 1 hour

# Check if this machine is the control machine
if [ -f "$CONTROL_MARKER" ]; then
    hostname
    exit 0
fi

# Check cache
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ "$CACHE_AGE" -lt "$CACHE_VALIDITY" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Try to find control machine via meshnet peers
if command -v nordvpn &> /dev/null && nordvpn account &> /dev/null 2>&1; then
    # Get list of meshnet peers
    PEERS=$(nordvpn meshnet peer list 2>/dev/null | grep -A50 "Local Peers:" | grep -E "^IP:" | awk '{print $2}')
    
    for peer_ip in $PEERS; do
        # Try to check if peer has the control marker
        if timeout 3 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes "$peer_ip" \
            "test -f ~/.dotfiles-control-machine" 2>/dev/null; then
            # Get the hostname of the control machine
            CONTROL_HOST=$(timeout 3 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes \
                "$peer_ip" "hostname" 2>/dev/null)
            if [ -n "$CONTROL_HOST" ]; then
                echo "$CONTROL_HOST" > "$CACHE_FILE"
                echo "$CONTROL_HOST"
                exit 0
            fi
        fi
    done
fi

# Fallback: try common hostnames from /etc/hosts
for host in $(grep -v '^#' /etc/hosts | awk '{for(i=2;i<=NF;i++) print $i}' | sort -u); do
    if timeout 3 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes "$host" \
        "test -f ~/.dotfiles-control-machine" 2>/dev/null; then
        echo "$host" > "$CACHE_FILE"
        echo "$host"
        exit 0
    fi
done

# No control machine found
exit 1