#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

echo "install alacritty"

ALACRITTY_VERSION=$(get_latest_version alacritty/alacritty)

current_alacritty_version=""
if command -v alacritty &> /dev/null; then
    current_alacritty_version=$(alacritty --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
fi

if [ "$current_alacritty_version" = "$ALACRITTY_VERSION" ]; then
    echo "Alacritty v$ALACRITTY_VERSION is already installed"
else
    echo "Installing Alacritty v$ALACRITTY_VERSION (current: ${current_alacritty_version:-none})"
    
    rm -rf ${HOME}/src/alacritty
    git clone https://github.com/alacritty/alacritty.git ${HOME}/src/alacritty
    cd ${HOME}/src/alacritty
    git checkout v${ALACRITTY_VERSION}

    ${HOME}/.cargo/bin/cargo build --release
    sudo ln -sfT ${HOME}/src/alacritty/target/release/alacritty /usr/local/bin/alacritty

    sudo mkdir -p /usr/local/share/man/man1
    gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null

    mkdir -p ${HOME}/.zsh_functions
    cp extra/completions/_alacritty ${HOME}/.zsh_functions/_alacritty
fi