#!/bin/bash

set -euo pipefail

CONTROL_MARKER="$HOME/.dotfiles-control-machine"
CACHE_FILE="/tmp/.dotfiles-control-machine-cache"

# Check if this machine is the control machine
if [ ! -f "$CONTROL_MARKER" ]; then
    echo "This machine ($(hostname)) is not the control machine"
    exit 1
fi

echo "Removing control machine designation from $(hostname)..."
rm -f "$CONTROL_MARKER"

# Clear cache since control machine has changed
rm -f "$CACHE_FILE"

echo "Done! This machine is no longer the control machine"
echo ""
echo "Remember to designate another machine as control if needed:"
echo "  set-control-machine.sh"