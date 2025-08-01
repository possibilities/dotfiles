#!/usr/bin/env bash

tag=1
width_percent=50
height_percent=50
x_percent=50
y_percent=50
initial_command=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--number)
            tag="$2"
            shift 2
            ;;
        -w|--width)
            width_percent="$2"
            shift 2
            ;;
        -h|--height)
            height_percent="$2"
            shift 2
            ;;
        --x)
            x_percent="$2"
            shift 2
            ;;
        --y)
            y_percent="$2"
            shift 2
            ;;
        --initial)
            initial_command="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
    esac
done

if [[ ! "$tag" =~ ^[1-8]$ ]]; then
    echo "Error: Scratchpad number must be 1-8" >&2
    exit 1
fi

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

mrect=( $(hc monitor_rect 0) )

monitor_width=${mrect[2]}
monitor_height=${mrect[3]}

scratchpad_width=$((monitor_width * width_percent / 100))
scratchpad_height=$((monitor_height * height_percent / 100))

center_x=$(( ${mrect[0]} + monitor_width * x_percent / 100 ))
center_y=$(( ${mrect[1]} + monitor_height * y_percent / 100 ))

x_offset=$(( center_x - scratchpad_width / 2 ))
y_offset=$(( center_y - scratchpad_height / 2 ))

rect=(
    $scratchpad_width
    $scratchpad_height
    $x_offset
    $y_offset
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

initialized_attr="my_scratchpad_initialized_$tag"
hc silent new_attr bool "$initialized_attr" false

if [[ -n "$initial_command" ]] && hc compare "$initialized_attr" = false 2>/dev/null; then
    hc set_attr "$initialized_attr" true
    hc rule once tag="$scratchpad_tag" focus=off
    eval "hc spawn $initial_command"
fi

hc lock
hc raise_monitor "$monitor_name"
hc focus_monitor "$monitor_name"
hc unlock
hc lock_tag "$monitor_name"