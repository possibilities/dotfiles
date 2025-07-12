#!/usr/bin/env bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

for i in {1..8}; do
    scratchpad_tag="scratchpad$i"
    monitor_name="scratchpad_$i"
    
    # First, close all clients on this tag (this will kill most applications)
    hc foreach CLIENT clients. \
        sprintf WINIDATTR '%c.winid' CLIENT \
        sprintf TAGATTR '%c.tag' CLIENT \
        and \
        , compare TAGATTR = "$scratchpad_tag" \
        , close WINIDATTR
    
    # Remove the monitor
    hc silent remove_monitor "$monitor_name"
    
    # Remove the tag itself - this ensures no clients remain
    hc silent merge_tag "$scratchpad_tag"
    
    # Reset initialization flag
    hc silent set_attr "my_scratchpad_initialized_$i" false 2>/dev/null || true
done

hc silent set_attr my_scratchpad_current ""