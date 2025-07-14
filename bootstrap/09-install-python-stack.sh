#!/bin/bash

echo "install pipx"

sudo apt --yes install pipx
pipx ensurepath
sudo pipx ensurepath

echo "install python stack"

sudo apt install --yes \
  python3 \
  python3-pip \
  python3-venv

pipx install deadcode

echo "install uv"

# Download and install uv
curl -LsSf https://github.com/astral-sh/uv/releases/download/v${UV_VERSION}/uv-installer.sh | sh