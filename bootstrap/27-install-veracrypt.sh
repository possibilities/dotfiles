#!/bin/bash
set -e

echo "install veracrypt"

VERACRYPT_VERSION="1.26.14"

cd ${HOME}/src
wget "https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb"
sudo apt install --yes ./veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb