#!/bin/bash

paired_devices=$(bluetoothctl devices Paired)

if [ -z "$paired_devices" ]; then
    dunstify --timeout=3000 "Bluetooth" "No paired devices found"
    exit 1
fi

device_menu=""
while IFS= read -r line; do
    mac_address=$(echo "$line" | awk '{print $2}')
    device_name=$(echo "$line" | cut -d' ' -f3-)
    device_menu="${device_menu}${device_name} (${mac_address})\n"
done <<< "$paired_devices"

device_menu=$(echo -e "$device_menu" | sed '/^$/d')

selected=$(echo -e "$device_menu" | rofi -dmenu -i -p "Connect to Bluetooth device:")

if [ -z "$selected" ]; then
    exit 0
fi

mac_address=$(echo "$selected" | grep -oP '\(([0-9A-F]{2}:){5}[0-9A-F]{2}\)' | tr -d '()')
device_name=$(echo "$selected" | sed 's/ ([^)]*)$//')

dunstify --timeout=2000 "Bluetooth" "Connecting to ${device_name}..."

if bluetoothctl connect "$mac_address"; then
    dunstify --timeout=3000 "Bluetooth" "Connected to ${device_name}"
else
    dunstify --timeout=3000 "Bluetooth" "Failed to connect to ${device_name}"
    exit 1
fi