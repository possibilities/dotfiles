#!/usr/bin/env bash

tag="${1:-1}"

if [[ ! "$tag" =~ ^[1-5]$ ]]; then
    echo "Error: Scratchpad name must be 1-5" >&2
    exit 1
fi

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

mrect=( $(hc monitor_rect 0) )

width=${mrect[2]}
height=${mrect[3]}

rect=(
    $((width/2))
    $((height/2))
    $((${mrect[0]}+(width/4)))
    $((${mrect[1]}+(height/4)))
)

scratchpad_tag="scratchpad$tag"
monitor_name="scratchpad_$tag"

hc chain , add "$scratchpad_tag" , set_attr tags.by-name."$scratchpad_tag".at_end true

if ! hc add_monitor $(printf "%dx%d%+d%+d" "${rect[@]}") \
                    "$scratchpad_tag" "$monitor_name" 2>/dev/null ; then
    echo "Error: Failed to create scratchpad monitor" >&2
    exit 1
fi

hc silent new_attr string my_scratchpad_current ""
hc set_attr my_scratchpad_current "$tag"

hc lock
hc raise_monitor "$monitor_name"
hc focus_monitor "$monitor_name"
hc unlock
hc lock_tag "$monitor_name"