#!/bin/sh

set -e

sudo apt install --yes wireless-tools network-manager

## TODO use sed to replace "main contrib\n" to "main contrib non-free\n" or similar
# echo "deb http://deb.debian.org/debian stretch main contrib non-free" | sudo tee /etc/apt/sources.list
# echo "deb-src http://deb.debian.org/debian stretch main contrib non-free" | sudo tee -a /etc/apt/sources.list
# echo "deb http://security.debian.org/debian-security/ stretch/updates main" | sudo tee -a /etc/apt/sources.list
# echo "deb-src http://security.debian.org/debian-security/ stretch/updates main" | sudo tee -a /etc/apt/sources.list
# echo "deb http://deb.debian.org/debian stretch-updates main" | sudo tee -a /etc/apt/sources.list
# echo "deb-src http://deb.debian.org/debian stretch-updates main" | sudo tee -a /etc/apt/sources.list

sudo apt update
sudo apt install firmware-iwlwifi
