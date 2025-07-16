#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

echo "install neovim"

npm install --global tree-sitter

# For telescope
sudo apt install --yes ripgrep

NEOVIM_VERSION=$(get_latest_version neovim/neovim)

current_nvim_version=""
if command -v nvim &> /dev/null; then
    current_nvim_version=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
fi

if [ "$current_nvim_version" = "$NEOVIM_VERSION" ]; then
    echo "Neovim v$NEOVIM_VERSION is already installed"
else
    echo "Installing Neovim v$NEOVIM_VERSION (current: ${current_nvim_version:-none})"
    
    sudo apt --yes install \
      ninja-build \
      gettext \
      libtool \
      libtool-bin \
      autoconf \
      automake \
      cmake \
      g++ \
      pkg-config \
      unzip \
      doxygen

    rm -rf ${HOME}/src/neovim
    git clone https://github.com/neovim/neovim.git ${HOME}/src/neovim
    cd ${HOME}/src/neovim
    git checkout v${NEOVIM_VERSION}
    make CMAKE_BUILD_TYPE=Release
    sudo make install
fi