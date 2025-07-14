#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

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

UV_VERSION=$(get_latest_version astral-sh/uv)

# Download and install uv
curl -LsSf https://github.com/astral-sh/uv/releases/download/v${UV_VERSION}/uv-installer.sh | sh