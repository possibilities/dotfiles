#!/usr/bin/env bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

# Get mouse position
eval $(xdotool getmouselocation --shell)
MOUSE_X=$X
MOUSE_Y=$Y

# Check if any scratchpad is currently open
current_scratchpad=$(hc get_attr my_scratchpad_current 2>/dev/null || echo "")
if [[ -z "$current_scratchpad" ]]; then
    exit 0
fi

# Check if click is inside any scratchpad monitor
click_inside_scratchpad=false

for i in {1..8}; do
    monitor_name="scratchpad_$i"
    
    # Get monitor geometry if it exists
    geometry=$(hc monitor_rect "$monitor_name" 2>/dev/null || echo "")
    
    if [[ -n "$geometry" ]]; then
        # Parse geometry: "x y width height"
        read -r mon_x mon_y mon_width mon_height <<< "$geometry"
        
        # Calculate boundaries
        mon_x_end=$((mon_x + mon_width))
        mon_y_end=$((mon_y + mon_height))
        
        # Check if mouse is inside this monitor
        if [[ $MOUSE_X -ge $mon_x ]] && [[ $MOUSE_X -le $mon_x_end ]] && \
           [[ $MOUSE_Y -ge $mon_y ]] && [[ $MOUSE_Y -le $mon_y_end ]]; then
            click_inside_scratchpad=true
            break
        fi
    fi
done

# If click was outside all scratchpads, close them
if [[ "$click_inside_scratchpad" == "false" ]]; then
    "$HOME/code/dotfiles/bin/scratchpad-close-all.sh"
fi