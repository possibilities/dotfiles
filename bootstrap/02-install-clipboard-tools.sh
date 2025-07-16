#!/bin/bash
set -e

echo "Install X11 clipboard utilities"

sudo apt install --yes xclip xsel

echo "Install greenclip"

if [ ! -f ~/.local/bin/greenclip ]; then
    mkdir -p ~/src/greenclip
    cd ~/src/greenclip
    wget https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    chmod +x ./greenclip
    cp ./greenclip ~/.local/bin/greenclip
else
    echo "greenclip already installed, skipping"
fi