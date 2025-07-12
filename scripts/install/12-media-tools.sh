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

echo "setup modprobe for obs virtual camera"
sudo apt install --yes v4l2loopback-dkms
echo v4l2loopback | sudo tee /etc/modules-load.d/v4l2loopback.conf