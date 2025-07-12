#!/bin/bash

set -e

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
  rsnapshot \
  dnsmasq \
  nginx

echo "install keychain"

sudo apt install --yes keychain

echo "install dunst"

sudo apt install --yes dunst libnotify-bin