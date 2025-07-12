#!/usr/bin/env bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

for i in {1..5}; do
    monitor_name="scratchpad_$i"
    hc silent remove_monitor "$monitor_name"
done

hc silent set_attr my_scratchpad_current ""