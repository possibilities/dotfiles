#!/bin/bash

is_paused=$(dunstctl is-paused)

if [[ $is_paused == *"false"* ]]; then
  dunstctl close-all
  dunstify --timeout=2000 "notifications disabled"
  sleep 2.1
  dunstctl set-paused true
else
  dunstctl set-paused false
  dunstify --timeout=2000 "notifications enabled"
fi

