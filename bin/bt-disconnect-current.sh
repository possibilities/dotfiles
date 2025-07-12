#!/bin/bash

connected_devices=$(bluetoothctl devices Connected)

if [ -z "$connected_devices" ]; then
    dunstify --timeout=3000 "Bluetooth" "No connected devices"
    exit 0
fi

disconnected_devices=""

while IFS= read -r line; do
    mac_address=$(echo "$line" | awk '{print $2}')
    device_name=$(echo "$line" | cut -d' ' -f3-)
    
    if bluetoothctl disconnect "$mac_address"; then
        if [ -z "$disconnected_devices" ]; then
            disconnected_devices="$device_name"
        else
            disconnected_devices="${disconnected_devices}, ${device_name}"
        fi
    fi
done <<< "$connected_devices"

if [ -n "$disconnected_devices" ]; then
    dunstify --timeout=3000 "Bluetooth" "Disconnected from: ${disconnected_devices}"
else
    dunstify --timeout=3000 "Bluetooth" "Failed to disconnect devices"
fi