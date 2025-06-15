#!/bin/bash

# Get current mouse coordinates
coordinates=$(xdotool getmouselocation --shell | grep 'X\|Y')

# Extract X and Y values
echo $coordinates
x=$(echo $coordinates | awk -F'=' '{print $2}' | awk '{print $1}')
y=$(echo $coordinates | awk -F'=' '{print $3}')

# Format the coordinates
formatted_coordinates="$x $y"
echo $formatted_coordinates

# Copy coordinates to clipboard
echo -n $formatted_coordinates | xclip -selection c

# Notify user
notify-send -t 12000 "Mouse coordinates copied to clipboard: $formatted_coordinates"
