#!/usr/bin/env bash

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
        *)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
    esac
done

if [[ ! "$tag" =~ ^[1-5]$ ]]; then
    echo "Error: Scratchpad number must be 1-5" >&2
    exit 1
fi

if [[ -n "$initial_command" ]]; then
    "$HOME/code/dotfiles/bin/scratchpad-show.sh" -n "$tag" -w "$width_percent" -h "$height_percent" --initial "$initial_command"
else
    "$HOME/code/dotfiles/bin/scratchpad-show.sh" -n "$tag" -w "$width_percent" -h "$height_percent"
fi
"$HOME/code/dotfiles/bin/scratchpad-close-all.sh" "$tag"