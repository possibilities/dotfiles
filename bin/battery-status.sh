#!/bin/bash

# Check if any battery exists
if [ ! -d /sys/class/power_supply/ ] || ! ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    echo "No battery found"
    exit 1
fi

# Get battery information
for battery in /sys/class/power_supply/BAT*; do
    if [ -f "$battery/capacity" ] && [ -f "$battery/status" ]; then
        battery_name=$(basename "$battery")
        capacity=$(cat "$battery/capacity")
        status=$(cat "$battery/status")
        
        # Get additional info if available
        if [ -f "$battery/energy_now" ] && [ -f "$battery/energy_full" ]; then
            energy_now=$(cat "$battery/energy_now")
            energy_full=$(cat "$battery/energy_full")
            energy_percentage=$(awk "BEGIN {printf \"%.1f\", ($energy_now/$energy_full)*100}")
        fi
        
        # Get power draw if available
        if [ -f "$battery/power_now" ]; then
            power_now=$(cat "$battery/power_now")
            power_watts=$(awk "BEGIN {printf \"%.2f\", $power_now/1000000}")
        fi
        
        # Determine battery icon based on capacity
        if [ "$capacity" -ge 90 ]; then
            icon="🔋"
        elif [ "$capacity" -ge 60 ]; then
            icon="🔋"
        elif [ "$capacity" -ge 30 ]; then
            icon="🪫"
        elif [ "$capacity" -ge 10 ]; then
            icon="🪫"
        else
            icon="❗"
        fi
        
        # Determine status icon
        case "$status" in
            "Charging")
                status_icon="⚡"
                ;;
            "Discharging")
                status_icon="↓"
                ;;
            "Full")
                status_icon="✓"
                ;;
            *)
                status_icon=""
                ;;
        esac
        
        # Calculate time remaining if discharging
        if [ "$status" = "Discharging" ] && [ -f "$battery/energy_now" ] && [ -f "$battery/power_now" ] && [ "$power_now" -gt 0 ]; then
            hours_remaining=$(awk "BEGIN {printf \"%.1f\", $energy_now/$power_now}")
            hours=$(echo "$hours_remaining" | cut -d. -f1)
            minutes=$(awk "BEGIN {printf \"%02d\", ($hours_remaining - $hours) * 60}")
            time_remaining="${hours}h ${minutes}m"
        elif [ "$status" = "Charging" ] && [ -f "$battery/energy_now" ] && [ -f "$battery/energy_full" ] && [ -f "$battery/power_now" ] && [ "$power_now" -gt 0 ]; then
            energy_needed=$((energy_full - energy_now))
            hours_remaining=$(awk "BEGIN {printf \"%.1f\", $energy_needed/$power_now}")
            hours=$(echo "$hours_remaining" | cut -d. -f1)
            minutes=$(awk "BEGIN {printf \"%02d\", ($hours_remaining - $hours) * 60}")
            time_remaining="${hours}h ${minutes}m"
        else
            time_remaining=""
        fi
        
        # Output battery status
        echo -n "$battery_name: $icon $capacity% $status_icon $status"
        
        if [ ! -z "$power_watts" ] && [ "$power_watts" != "0.00" ]; then
            echo -n " (${power_watts}W)"
        fi
        
        if [ ! -z "$time_remaining" ]; then
            echo -n " - $time_remaining remaining"
        fi
        
        echo
    fi
done

# Check AC adapter status
if [ -f /sys/class/power_supply/AC*/online ] || [ -f /sys/class/power_supply/ADP*/online ]; then
    for ac in /sys/class/power_supply/AC* /sys/class/power_supply/ADP*; do
        if [ -f "$ac/online" ]; then
            ac_status=$(cat "$ac/online")
            if [ "$ac_status" = "1" ]; then
                echo "AC: 🔌 Connected"
            else
                echo "AC: ❌ Disconnected"
            fi
            break
        fi
    done
fi