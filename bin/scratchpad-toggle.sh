#!/usr/bin/env bash

tag=1
width_percent=50
height_percent=50
x_percent=50
y_percent=50
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
        --x)
            x_percent="$2"
            shift 2
            ;;
        --y)
            y_percent="$2"
            shift 2
            ;;
        --initial)
            initial_command="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
    esac
done

if [[ ! "$tag" =~ ^[1-8]$ ]]; then
    echo "Error: Scratchpad number must be 1-8" >&2
    exit 1
fi

if [[ -n "$initial_command" ]]; then
    "$HOME/code/dotfiles/bin/scratchpad-show.sh" -n "$tag" -w "$width_percent" -h "$height_percent" --x "$x_percent" --y "$y_percent" --initial "$initial_command"
else
    "$HOME/code/dotfiles/bin/scratchpad-show.sh" -n "$tag" -w "$width_percent" -h "$height_percent" --x "$x_percent" --y "$y_percent"
fi
"$HOME/code/dotfiles/bin/scratchpad-close-all.sh" "$tag"