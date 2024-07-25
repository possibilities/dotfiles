#!/bin/sh

set -e

echo "set zsh as default shell for user"

sudo chsh -s $(which zsh) mike

echo "link dot files into ~"

for file in home/*
do
  file_name=`basename $file`
  echo "   * $file -> ~/.$file_name"
  ln -sfT $PWD/$file $HOME/.$file_name
done

echo "link config files into ~/.config"

mkdir -p ${HOME}/.config

for file in config/*
do
  file_name=`basename $file`
  echo "   * $file -> ~/.config/$file_name"
  ln -sfT $PWD/$file $HOME/.config/$file_name
done

echo "link ssh files into ~/.ssh"

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh

for file in ssh/*
do
  file_name=`basename $file`
  echo "   * $file -> ~/.ssh/$file_name"
  ln -sfT $PWD/$file $HOME/.ssh/$file_name
done

echo "link scripts into /usr/local/bin"

for file in bin/*
do
  file_name=`basename $file`
  echo "   * $file -> /usr/local/bin/$file_name"
  sudo ln -sfT $PWD/$file /usr/local/bin/$file_name
done

#echo "setup vim backup dir"
#
#mkdir -p ${HOME}/.vim/backups
#
#echo "configure qutebrowser"
#
#rm -rf /home/mike/src/nord-qutebrowser
#git clone https://github.com/Linuus/nord-qutebrowser.git /home/mike/src/nord-qutebrowser
#ln -sfT /home/mike/src/nord-qutebrowser/nord-qutebrowser.py /home/mike/.config/qutebrowser/nord-qutebrowser.py
#
#sudo update-alternatives \
#  --install \
#  /usr/bin/x-www-browser \
#  x-www-browser \
#  /usr/local/bin/qutebrowser \
#  199
#
echo "done installing dotfiles."
