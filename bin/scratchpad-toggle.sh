#!/usr/bin/env bash

tag="${1:-1}"

if [[ ! "$tag" =~ ^[1-5]$ ]]; then
    echo "Error: Scratchpad name must be 1-5" >&2
    exit 1
fi

"$HOME/code/dotfiles/bin/scratchpad-close-all.sh"
"$HOME/code/dotfiles/bin/scratchpad-show.sh" "$tag"