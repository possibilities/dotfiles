#!/bin/bash

check_nordvpn_status() {
    nordvpn status | grep -q "Status: Connected"
}

echo "waiting for vpn"

while ! check_nordvpn_status; do
    sleep 0.5
done

echo "vpn connected"

nordvpn status
