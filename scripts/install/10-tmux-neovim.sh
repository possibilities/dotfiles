#!/bin/bash

set -e

get_latest_version() {
    local REDIRECTED_RELEASE_URL
    REDIRECTED_RELEASE_URL=$(curl -s -L -o /dev/null -w "%{url_effective}" "https://github.com/$1/releases/latest")
    local VERSION
    VERSION=$(echo $REDIRECTED_RELEASE_URL | awk -F'/' '{print $NF}' | awk -F'v' '{print $2}')
    echo $VERSION
}

NEOVIM_VERSION=$(get_latest_version neovim/neovim)
TMUX_VERSION="3.5"

echo "install neovim"

# For telescope
sudo apt install --yes ripgrep

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

echo "install tmux"

sudo apt install --yes \
  libevent-dev \
  libncurses-dev \
  autotools-dev \
  automake \
  bison

rm -rf ${HOME}/src/tmux
git clone https://github.com/tmux/tmux.git ${HOME}/src/tmux
cd ${HOME}/src/tmux
git checkout ${TMUX_VERSION}
sh autogen.sh
./configure && make
sudo make install