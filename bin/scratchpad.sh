#!/usr/bin/env bash

# herbstluftwm scratchpad for dropdown terminals
# Based on the official herbstluftwm scratchpad.sh

tag="${1:-scratchpad}"
hc() { herbstclient "$@" ;}

mrect=( $(hc monitor_rect "") )

width=${mrect[2]}
height=${mrect[3]}

# Configure scratchpad size (60% width, 40% height, centered)
rect=(
    $((width*60/100))
    $((height*40/100))
    $((${mrect[0]}+(width*20/100)))
    $((${mrect[1]}+20))
)

hc chain , add "$tag" , set_attr tags.by-name."$tag".at_end true

monitor=scratchpad

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
    hc lock
    hc raise_monitor "$monitor"
    hc focus_monitor "$monitor"
    hc unlock
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