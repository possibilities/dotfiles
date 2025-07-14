#!/bin/bash

echo "install misc tools"

sudo apt install --yes \
  tree \
  curl \
  zsh \
  git \
  xclip \
  gnome-disk-utility \
  rsync \
  p7zip-full \
  imagemagick \
  ffmpeg \
  slop \
  scrot \
  xdotool \
  wipe \
  rsnapshot

mkdir -p ~/.local/bin/