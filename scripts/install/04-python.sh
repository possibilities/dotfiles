#!/bin/bash

set -e

get_latest_version() {
    local REDIRECTED_RELEASE_URL
    REDIRECTED_RELEASE_URL=$(curl -s -L -o /dev/null -w "%{url_effective}" "https://github.com/$1/releases/latest")
    local VERSION
    VERSION=$(echo $REDIRECTED_RELEASE_URL | awk -F'/' '{print $NF}' | awk -F'v' '{print $2}')
    echo $VERSION
}

UV_VERSION=$(get_latest_version astral-sh/uv)

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