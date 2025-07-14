#!/bin/bash

set -e

get_latest_version() {
    local REDIRECTED_RELEASE_URL
    REDIRECTED_RELEASE_URL=$(curl -s -L -o /dev/null -w "%{url_effective}" "https://github.com/$1/releases/latest")
    local VERSION
    VERSION=$(echo $REDIRECTED_RELEASE_URL | awk -F'/' '{print $NF}' | awk -F'v' '{print $2}')
    echo $VERSION
}

export NVM_VERSION=$(get_latest_version nvm-sh/nvm)
export ALACRITTY_VERSION=$(get_latest_version alacritty/alacritty)
export NEOVIM_VERSION=$(get_latest_version neovim/neovim)
export UV_VERSION=$(get_latest_version astral-sh/uv)

export HERBSTLUFTWM_VERSION="v0.9.5"
export TMUX_VERSION="3.5"
export JQ_VERSION="1.7.1"
export ROFI_VERSION="1.7.5"
export VERACRYPT_VERSION="1.26.14"
export SQLITESTUDIO_VERSION="3.4.4"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${SCRIPT_DIR}/bootstrap"

for script in "${BOOTSTRAP_DIR}"/*.sh; do
    if [ -f "$script" ]; then
        echo "Running $(basename "$script")..."
        source "$script"
    fi
done

echo "done bootstrapping system."