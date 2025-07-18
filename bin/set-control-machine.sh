#!/bin/bash

set -euo pipefail

CONTROL_MARKER="$HOME/.dotfiles-control-machine"
CACHE_FILE="/tmp/.dotfiles-control-machine-cache"

# Check if already control machine
if [ -f "$CONTROL_MARKER" ]; then
    echo "This machine ($(hostname)) is already the control machine"
    exit 0
fi

# Find current control machine
echo -n "Checking for existing control machine... "
CURRENT_CONTROL=$(get-control-machine.sh 2>/dev/null)

if [ -n "$CURRENT_CONTROL" ]; then
    echo "found: $CURRENT_CONTROL"
    echo ""
    echo "WARNING: $CURRENT_CONTROL is currently the control machine."
    echo "Setting this machine as control will not remove the marker from $CURRENT_CONTROL."
    echo "You should manually remove ~/.dotfiles-control-machine from $CURRENT_CONTROL"
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
else
    echo "none found"
fi

# Set this machine as control
echo "Setting $(hostname) as the control machine..."
touch "$CONTROL_MARKER"

# Clear cache since control machine has changed
rm -f "$CACHE_FILE"

echo "Done! This machine ($(hostname)) is now the control machine"
echo ""
echo "Screenshots from other machines will now sync here."