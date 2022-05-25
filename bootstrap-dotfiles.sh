#!/bin/sh -eux

set -e

rm -rf /home/mike/code/dotfiles
git clone https://github.com/possibilities/dotfiles-next /home/mike/code/dotfiles
cd /home/mike/code/dotfiles
git remote remove origin
git remote add origin git@github.com:possibilities/dotfiles-next.git
zsh && ./install-dotfiles.sh
sudo reboot
