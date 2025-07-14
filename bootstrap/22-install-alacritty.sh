#!/bin/bash

echo "install alacritty"

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