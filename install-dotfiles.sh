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

echo "generate meshnet SSH config"

mkdir -p $HOME/.ssh/config.d
chmod 700 $HOME/.ssh/config.d

# Generate meshnet SSH config (this will fail if nordvpn is not installed/logged in)
$PWD/bin/generate-meshnet-ssh-config

echo "generate meshnet hosts entries"

# Generate meshnet hosts entries (this will fail if nordvpn is not installed/logged in)
$PWD/bin/generate-meshnet-hosts

echo "link scripts into /usr/local/bin"

for file in bin/*
do
  # Create a link with extension, TODO remove
  file_name=`basename $file`
  echo "   * $file -> /usr/local/bin/$file_name"
  sudo ln -sfT $PWD/$file /usr/local/bin/$file_name

  # Create a link without extension
  file_name_no_ext="${file_name%.*}"
  echo "   * $file -> /usr/local/bin/$file_name_no_ext"
  sudo ln -sfT $PWD/$file /usr/local/bin/$file_name_no_ext
done

echo "copy cronjobs into /etc/cron.d/"

for file in cron/*
do
  file_name=`basename $file`
  echo "   * $file -> /etc/cron.d/$file_name"
  sudo rm -rf /etc/cron.d/$file_name
  echo "# COPIED FROM DOTFILES DONT EDIT" | sudo tee -a /etc/cron.d/$file_name > /dev/null
  echo "" | sudo tee -a /etc/cron.d/$file_name > /dev/null
  sudo cat $PWD/$file |  sudo tee -a /etc/cron.d/$file_name > /dev/null
done

echo "copy X11 configuration files into /etc/X11/xorg.conf.d/"

sudo mkdir -p /etc/X11/xorg.conf.d

for file in xorg/xorg.conf.d/*
do
  file_name=`basename $file`
  echo "   * $file -> /etc/X11/xorg.conf.d/$file_name"
  sudo cp -f $PWD/$file /etc/X11/xorg.conf.d/$file_name
done

echo "setup wildcard DNS for hostname"

# Check if resolvconf needs to be configured first
if dpkg -l resolvconf 2>/dev/null | grep -q "^iF"; then
    echo "Completing resolvconf configuration..."
    sudo chattr -i /etc/resolv.conf 2>/dev/null || true
    sudo dpkg --configure resolvconf || true
fi

$PWD/scripts/setup/setup-wildcard-dns.sh

echo "setup nginx port forwarding"

$PWD/scripts/setup/setup-nginx-port-forward.sh

echo "setup nginx SSL"

$PWD/scripts/setup/setup-nginx-mkcert.sh

echo "done installing dotfiles."
