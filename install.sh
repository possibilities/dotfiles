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
  git-secret \
  python3 \
  awscli \
  python3-pip \
  gnupg2 \
  pass

# TODO install hub in some way, doesn't work on ubuntu vm

# install neovim from ppa
sudo add-apt-repository ppa:neovim-ppa/unstable --yes
sudo apt-get update
sudo apt-get install neovim --yes

# install git from ppa
sudo add-apt-repository ppa:git-core/ppa --yes
sudo apt update
sudo apt install git --yes

# For puppeteer
sudo apt-get install --yes \
  gconf-service \
  libasound2 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libc6 \
  libcairo2 \
  libcups2 \
  libdbus-1-3 \
  libexpat1 \
  libfontconfig1 \
  libgcc1 \
  libgconf-2-4 \
  libgdk-pixbuf2.0-0 \
  libglib2.0-0 \
  libgtk-3-0 \
  libnspr4 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libstdc++6 \
  libx11-6 \
  libx11-xcb1 \
  libxcb1 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxi6 \
  libxrandr2 \
  libxrender1 \
  libxss1 \
  libxtst6 \
  ca-certificates \
  fonts-liberation \
  libappindicator1 \
  libnss3 \
  lsb-release \
  xdg-utils \
  libgbm-dev \
  wget

mkdir -p ${HOME}/.vim/backups

chsh -s $(which zsh)

if ! [ -x "$(command -v lab)" ]; then
  curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | sudo bash
else
  echo " - lab already installed"
fi

if [ -d "${HOME}/.nvm" ] 
then
  echo " - nvm already installed"
else
  echo " - installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  source ~/.nvm/nvm.sh
  nvm install 12 --lts
  nvm install 14 --lts
fi

if ! [ -x "$(command -v tmuxp)" ]; then
  echo " - installing tmuxp"
  pip3 install --quiet --user tmuxp
else
  echo " - tmuxp already installed"
fi

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn

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


echo " - deal with vim plugins"

if [ -d "${HOME}/.powerlevel10k" ]
then
  echo " - power level 10k already installed"
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
fi

if [ -f "${HOME}/.vim/autoload/plug.vim" ]
then
  echo " - vim plug already installed"
else
  curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

vim +'PlugInstall --sync' +qa

echo
echo ALL DONE, COMPLETE, OK, NICE, WORD, HAVE FUN SUCKA
