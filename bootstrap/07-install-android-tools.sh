#!/bin/bash
set -e

echo "install scrcpy"
sudo apt install --yes \
  ffmpeg \
  libsdl2-2.0-0 \
  adb \
  wget \
  gcc \
  git \
  pkg-config \
  meson \
  ninja-build \
  libsdl2-dev \
  libavcodec-dev \
  libavdevice-dev \
  libavformat-dev \
  libavutil-dev \
  libswresample-dev \
  libusb-1.0-0 \
  libusb-1.0-0-dev

rm -rf ${HOME}/src/scrcpy
cd ~/src
git clone https://github.com/Genymobile/scrcpy
cd scrcpy
./install_release.sh