#!/bin/bash
set -e

echo "install misc tools"

sudo apt install --yes \
  tree \
  curl \
  zsh \
  git \
  gnome-disk-utility \
  rsync \
  p7zip-full \
  imagemagick \
  ffmpeg \
  slop \
  scrot \
  xdotool \
  wipe \
  rsnapshot \
  mosh \
  btop

mkdir -p ~/.local/bin/
