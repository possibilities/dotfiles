#!/usr/bin/env bash

# herbstluftwm scratchpad for multiple independent scratchpads
# Usage: scratchpad.sh [tag] [width%] [height%]

tag="${1:-scratchpad}"
width_percent="${2:-60}"
height_percent="${3:-40}"

hc() { herbstclient "$@" ;}

mrect=( $(hc monitor_rect "0") )

width=${mrect[2]}
height=${mrect[3]}

# Calculate scratchpad geometry
rect=(
    $((width*width_percent/100))
    $((height*height_percent/100))
    $((${mrect[0]}+(width*(100-width_percent)/200)))
    $((${mrect[1]}+20))
)

hc chain , add "$tag" , set_attr tags.by-name."$tag".at_end true

# Use unique monitor name based on tag
monitor="scratchpad_${tag}"

exists=false
if ! hc add_monitor $(printf "%dx%d%+d%+d" "${rect[@]}") \
                    "$tag" $monitor 2> /dev/null ; then
    exists=true
else
    # remember which monitor was focused previously
    hc chain \
        , new_attr string monitors.by-name."$monitor".my_prev_focus \
        , substitute M monitors.focus.index \
            set_attr monitors.by-name."$monitor".my_prev_focus M
fi

show() {
    # Lock to prevent visual updates during changes
    hc lock
    
    # Hide all other scratchpads
    for i in {1..5}; do
        other_monitor="scratchpad_scratch${i}"
        if [ "$other_monitor" != "$monitor" ]; then
            hc remove_monitor "$other_monitor" 2>/dev/null
        fi
    done
    
    # Show the new scratchpad
    hc raise_monitor "$monitor"
    
    # Unlock before focusing to ensure proper focus handling
    hc unlock
    
    # Now focus the monitor and lock the tag
    hc focus_monitor "$monitor"
    hc lock_tag "$monitor"
}

hide() {
    # if scratchpad still is focused, then focus the previously focused monitor
    hc substitute M monitors.by-name."$monitor".my_prev_focus \
        and + compare monitors.focus.name = "$monitor" \
            + focus_monitor M
    hc remove_monitor "$monitor"
}

[ $exists = true ] && hide || show