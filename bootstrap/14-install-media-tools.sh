#!/bin/bash
set -e

echo "setup modprobe for obs virtual camera"
sudo apt install --yes v4l2loopback-dkms
echo v4l2loopback | sudo tee /etc/modules-load.d/v4l2loopback.conf