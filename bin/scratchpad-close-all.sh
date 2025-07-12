#!/usr/bin/env bash

exclude="${1:-}"

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

for i in {1..8}; do
    if [[ "$i" != "$exclude" ]]; then
        monitor_name="scratchpad_$i"
        hc silent remove_monitor "$monitor_name"
    fi
done

if [[ -z "$exclude" ]]; then
    hc silent set_attr my_scratchpad_current ""
fi