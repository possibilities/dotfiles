#!/usr/bin/env bash

tag="${1:-1}"

if [[ ! "$tag" =~ ^[1-5]$ ]]; then
    echo "Error: Scratchpad name must be 1-5" >&2
    exit 1
fi

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

hc silent new_attr string my_scratchpad_current ""
hc silent new_attr string my_scratchpad_original_focus ""

current_scratchpad=$(hc get_attr my_scratchpad_current 2>/dev/null || echo "")

if [[ -n "$current_scratchpad" ]]; then
    if [[ "$current_scratchpad" == "$tag" ]]; then
        "$HOME/code/dotfiles/bin/scratchpad-close-all.sh"
        
        original_focus=$(hc get_attr my_scratchpad_original_focus 2>/dev/null || echo "")
        if [[ -n "$original_focus" ]]; then
            hc focus_monitor "$original_focus"
        fi
        
        hc set_attr my_scratchpad_original_focus ""
    else
        "$HOME/code/dotfiles/bin/scratchpad-toggle.sh" "$tag"
    fi
else
    current_monitor=$(hc get_attr monitors.focus.index)
    hc set_attr my_scratchpad_original_focus "$current_monitor"
    
    "$HOME/code/dotfiles/bin/scratchpad-show.sh" "$tag"
fi