#!/bin/bash

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