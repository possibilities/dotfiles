#!/bin/sh -eux

set -e

mkdir -p /home/mike/.trash

src_dir="/home/mike/code/dotfiles"
dest_dir="/home/mike/.trash/dotfiles"

[ -d "$src_dir" ] && mv "$src_dir" "$dest_dir"

git clone https://github.com/possibilities/dotfiles-next /home/mike/code/dotfiles
cd /home/mike/code/dotfiles
git remote remove origin
git remote add origin git@github.com:possibilities/dotfiles-next.git
zsh && ./install-dotfiles.sh
sudo reboot
