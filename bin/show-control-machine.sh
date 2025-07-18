#!/bin/bash

set -euo pipefail

CONTROL_MARKER="$HOME/.dotfiles-control-machine"

# Check if this machine is the control machine
if [ -f "$CONTROL_MARKER" ]; then
    echo "This machine ($(hostname)) is the control machine"
    exit 0
fi

# Try to find the control machine
echo -n "Looking for control machine... "
CONTROL_MACHINE=$(get-control-machine.sh 2>/dev/null)

if [ -n "$CONTROL_MACHINE" ]; then
    echo "found: $CONTROL_MACHINE"
else
    echo "no control machine found"
    echo ""
    echo "To designate a control machine, run on the desired machine:"
    echo "  touch ~/.dotfiles-control-machine"
fi