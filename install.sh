#!/bin/bash

set -e

# include hidden files when globbing
shopt -s dotglob

sudo apt-get update
sudo apt-get install --yes \
  unzip \
  git \
  jq \
  tree \
  watch \
  python \
  curl \
  wget \
  tmux \
  zsh \
  uuid \
  xclip \
  whois \
  uuid \
  vim-gtk \
  git-secret \
  python3 \
  awscli \
  python3-pip

chsh -s $(which zsh)

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 12 --lts

pip3 install --quiet --user tmuxp

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn

yarn global add nodemon serve

# we need directories

echo " - linking dot files into \$HOME"

for file in home/*
do
  file_name=`basename $file`
  echo "   * link $file to \$HOME/.$file_name"
  rm -rf $HOME/.$file_name
  ln -sf $PWD/$file $HOME/.$file_name
done

echo " - linking ssh files into \$HOME/.ssh"

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh

for file in ssh/*
do
  file_name=`basename $file`
  echo "   * link $file to \$HOME/.ssh/$file_name"
  rm -rf $HOME/.ssh/$file_name
  ln -sf $PWD/$file $HOME/.ssh/$file_name
done

echo " - linking binaries into \$HOME/local/bin"

mkdir -p $HOME/local/bin

for file in bin/*
do
  file_name=`basename $file`
  echo "   * link $file to \$HOME/local/bin/$file_name"
  rm -rf $HOME/local/bin/$file_name
  ln -sf $PWD/$file $HOME/local/bin/$file_name
done

echo " - deal with vim plugins"
./install-vim-plugins.sh || true

echo done
