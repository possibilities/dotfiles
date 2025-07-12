#!/usr/bin/env bash

print_usage() {
    cat << EOF
Usage: scratchpad.sh [OPTIONS]
Toggle a floating scratchpad window.

Options:
  -n, --number NUM    Scratchpad number (1-8, default: 1)
  -w, --width PCT     Width percentage (10-100, default: 50)
  -h, --height PCT    Height percentage (10-100, default: 50)
  --initial CMD       Command to run when scratchpad is first created
  --help              Show this help message

Examples:
  scratchpad.sh                              # Toggle scratchpad 1 with default size
  scratchpad.sh -n 2                         # Toggle scratchpad 2 with default size
  scratchpad.sh -w 80 -h 60                  # Toggle scratchpad 1 with 80% width, 60% height
  scratchpad.sh -n 3 -w 30 -h 40             # Toggle scratchpad 3 with custom size
  scratchpad.sh -n 1 --initial "alacritty"   # Launch alacritty in scratchpad 1
  scratchpad.sh -n 2 --initial "alacritty -e htop"  # Launch htop in scratchpad 2
EOF
}

tag=1
width_percent=50
height_percent=50
initial_command=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--number)
            tag="$2"
            shift 2
            ;;
        -w|--width)
            width_percent="$2"
            shift 2
            ;;
        -h|--height)
            height_percent="$2"
            shift 2
            ;;
        --initial)
            initial_command="$2"
            shift 2
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            print_usage >&2
            exit 1
            ;;
    esac
done

if [[ ! "$tag" =~ ^[1-8]$ ]]; then
    echo "Error: Scratchpad number must be 1-8" >&2
    exit 1
fi

if [[ ! "$width_percent" =~ ^[0-9]+$ ]] || [[ "$width_percent" -lt 10 ]] || [[ "$width_percent" -gt 100 ]]; then
    echo "Error: Width percentage must be between 10-100" >&2
    exit 1
fi

if [[ ! "$height_percent" =~ ^[0-9]+$ ]] || [[ "$height_percent" -lt 10 ]] || [[ "$height_percent" -gt 100 ]]; then
    echo "Error: Height percentage must be between 10-100" >&2
    exit 1
fi

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

hc silent new_attr string my_scratchpad_current ""
hc silent new_attr string my_scratchpad_original_focus ""

current_scratchpad=$(hc get_attr my_scratchpad_current 2>/dev/null || echo "")

if [[ -n "$current_scratchpad" ]]; then
    if [[ "$current_scratchpad" == "$tag" ]]; then
        "$HOME/code/dotfiles/bin/scratchpad-close-all.sh"
        
        original_focus=$(hc get_attr my_scratchpad_original_focus 2>/dev/null || echo "")
        if [[ -n "$original_focus" ]]; then
            hc focus_monitor "$original_focus"
        fi
        
        hc set_attr my_scratchpad_original_focus ""
    else
        if [[ -n "$initial_command" ]]; then
            "$HOME/code/dotfiles/bin/scratchpad-toggle.sh" -n "$tag" -w "$width_percent" -h "$height_percent" --initial "$initial_command"
        else
            "$HOME/code/dotfiles/bin/scratchpad-toggle.sh" -n "$tag" -w "$width_percent" -h "$height_percent"
        fi
    fi
else
    current_monitor=$(hc get_attr monitors.focus.index)
    hc set_attr my_scratchpad_original_focus "$current_monitor"
    
    if [[ -n "$initial_command" ]]; then
        "$HOME/code/dotfiles/bin/scratchpad-show.sh" -n "$tag" -w "$width_percent" -h "$height_percent" --initial "$initial_command"
    else
        "$HOME/code/dotfiles/bin/scratchpad-show.sh" -n "$tag" -w "$width_percent" -h "$height_percent"
    fi
fi