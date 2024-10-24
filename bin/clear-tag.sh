#!/bin/bash

set -e

current_tag=$(herbstclient attr tags.focus.name)

clients=$(herbstclient list_clients)

for client in $clients; do
    client_tag=$(herbstclient attr clients.$client.tag)
    if [ "$client_tag" == "$current_tag" ]; then
        herbstclient close $client
    fi
done

herbstclient load '(clients max:0)'
