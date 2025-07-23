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

echo "link application files into ~/.local/share/applications"

mkdir -p ${HOME}/.local/share/applications

for file in applications/*
do
  file_name=`basename $file`
  echo "   * $file -> ~/.local/share/applications/$file_name"
  ln -sfT $PWD/$file $HOME/.local/share/applications/$file_name
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

echo "link user scripts into ~/bin"

mkdir -p $HOME/bin

for file in bin/*
do
  file_name=`basename $file`
  echo "   * $file -> ~/bin/$file_name"
  ln -sfT $PWD/$file $HOME/bin/$file_name
  
  # Create a link without extension
  file_name_no_ext="${file_name%.*}"
  echo "   * $file -> ~/bin/$file_name_no_ext"
  ln -sfT $PWD/$file $HOME/bin/$file_name_no_ext
done

echo "done installing dotfiles."
