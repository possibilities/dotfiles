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

echo "link npm packages with bin entries"

CODE_DIR="$HOME/code"

if [ -d "$CODE_DIR" ]; then
  for package_json in $(find "$CODE_DIR" -maxdepth 2 -name "package.json" -not -path "*/node_modules/*"); do
    if command -v jq >/dev/null 2>&1; then
      if jq -e '.bin' "$package_json" >/dev/null 2>&1; then
        dir=$(dirname "$package_json")
        package_name=$(jq -r '.name // "unknown"' "$package_json")
        echo "   * linking npm package: $package_name from $dir"
        (cd "$dir" && npm link) || echo "   ! failed to link $package_name"
      fi
    else
      echo "   ! jq not installed, checking $package_json manually"
      if grep -q '"bin"' "$package_json"; then
        dir=$(dirname "$package_json")
        echo "   * linking npm package from $dir"
        (cd "$dir" && npm link) || echo "   ! failed to link from $dir"
      fi
    fi
  done
else
  echo "   ! $CODE_DIR directory not found, skipping npm link"
fi

echo "done installing dotfiles."
