#!/bin/bash
set -e

echo "install cargo"

if [ -x "${HOME}/.cargo/bin/rustc" ]; then
    echo "Rust is already installed ($(${HOME}/.cargo/bin/rustc --version))"
    ${HOME}/.cargo/bin/rustup update stable
else
    echo "Installing Rust toolchain"
    
    sudo apt install --yes \
      cmake \
      python3 \
      pkg-config \
      libfreetype6-dev \
      libfontconfig1-dev \
      libxcb-xfixes0-dev \
      libxkbcommon-dev

    curl https://sh.rustup.rs -sSf | sh -s -- -y
    ${HOME}/.cargo/bin/rustup override set stable
    ${HOME}/.cargo/bin/rustup update stable
fi