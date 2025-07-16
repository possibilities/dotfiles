#!/bin/bash
set -e

echo "install sqlitestudio"

SQLITESTUDIO_VERSION="3.4.4"

cd ~/src
mkdir -p ~/src/sqlitestudio
wget \
  --output-document ${HOME}/src/sqlitestudio/install.run \
  https://github.com/pawelsalawa/sqlitestudio/releases/download/${SQLITESTUDIO_VERSION}/SQLiteStudio-${SQLITESTUDIO_VERSION}-linux-x64-installer.run
chmod +x ${HOME}/src/sqlitestudio/install.run

echo RUN THIS TO INSTALL SQLITE UI ${HOME}/src/sqlitestudio/install.run