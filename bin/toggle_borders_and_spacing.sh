#!/bin/bash

STATE_FILE="$HOME/.config/herbstluftwm/border_state"

enable_border() {
    herbstclient attr theme.active.inner_color 'white'
    echo "enabled" > "$STATE_FILE"
}

disable_border() {
    herbstclient attr theme.active.inner_color 'black'
    echo "disabled" > "$STATE_FILE"
}

if [ ! -f "$STATE_FILE" ]; then
    enable_border
else
    STATE=$(cat "$STATE_FILE")
    if [ "$STATE" = "enabled" ]; then
        disable_border
    else
        enable_border
    fi
fi

