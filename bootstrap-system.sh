#!/bin/bash

set -e

ALACRITTY_VERSION="v0.10.1"
NEOVIM_VERSION="v0.7.0"
HERBSTLUFTWM_VERSION="v0.9.4"
TMUX_VERSION="3.3a"
QUTEBROWSER_VERSION="v2.5.2"
DUPLICITY_VERSION="rel.0.8.23"
NVM_VERSION="v0.39.1"
JQ_VERSION="1.6"
ROFI_VERSION="1.7.3"
VERACRYPT_VERSION="1.25.9"


DIST=$(lsb_release -is)

echo "update apt"

sudo apt update

echo "create dirs"

mkdir -p ${HOME}/src
mkdir -p ${HOME}/local/bin

echo "install misc tools"

sudo apt install --yes \
  htop \
  tree \
  curl \
  zsh \
  git \
  xclip \
  gnome-disk-utility \
  rsync \
  p7zip-full

echo "setup modprobe for obs virtual camera"
sudo apt install --yes v4l2loopback-dkms
echo v4l2loopback | sudo tee /etc/modules-load.d/v4l2loopback.conf

echo install btm

rm -rf ${HOME}/src/btm
mkdir -p ${HOME}/src/btm
curl -L -o ${HOME}/src/btm/bottom_0.8.0_amd64.deb https://github.com/ClementTsang/bottom/releases/download/0.8.0/bottom_0.8.0_amd64.deb
sudo dpkg -i ${HOME}/src/btm/bottom_0.8.0_amd64.deb

echo "install rmtp server"

sudo apt install --yes \
  build-essential \
  libpcre3 \
  libpcre3-dev \
  libssl-dev \
  nginx-full \
  libnginx-mod-rtmp \
  ffmpeg


echo "install virtual manager"

sudo apt install --yes \
  virt-manager \
  qemu-system \
  libvirt-daemon-system \
  qemu-kvm \
  libvirt-clients \
  libvirt-daemon-system \
  bridge-utils \
  virtinst \
  libvirt-daemon
sudo virsh net-start default || true
sudo virsh net-autostart default || true
sudo modprobe vhost_net
sudo usermod -aG libvirt mike
sudo usermod -aG libvirt-qemu mike
sudo usermod -aG kvm mike
sudo usermod -aG input mike
sudo usermod -aG disk mike

echo "install fira font"

sudo apt install fonts-firacode

echo "install cargo"

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

echo "install xorg"

sudo apt install --yes \
  xinit \
  xserver-xorg-video-all \
  xserver-xorg-core

echo "install herbstluftwm"

sudo apt install --yes \
  libxfixes-dev \
  asciidoc \
  cmake \
  debhelper \
  docbook-xml \
  docbook-xsl \
  libfreetype6-dev \
  libx11-dev \
  libxinerama-dev \
  libxml2-utils \
  libxft-dev \
  libxrandr-dev \
  python3 \
  pkg-config \
  python3-ewmh \
  python3-pytest \
  python3-pytest-xdist \
  python3-pytest-xvfb \
  python3-xlib \
  x11-utils \
  x11-xserver-utils \
  xdotool \
  xserver-xephyr \
  xsltproc \
  xdg-desktop-portal-gtk \
  xterm

rm -rf ${HOME}/src/herbstluftwm
git clone https://github.com/herbstluftwm/herbstluftwm.git ${HOME}/src/herbstluftwm
cd ${HOME}/src/herbstluftwm
git checkout ${HERBSTLUFTWM_VERSION}
mkdir build && cd build
cmake ..
make
sudo make prefix=/usr/local install

echo "install nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
. ${HOME}/.nvm/nvm.sh

# Load NVM so we can use it right away
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 14
nvm install 16
nvm alias default 16

echo "install yarn"

sudo apt --yes install gnupg2

echo " - install yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --yes --no-install-recommends yarn

echo "install nodemon"

nvm use 14
npm install --global nodemon
nvm use 16
npm install --global nodemon

echo "install serve"

sudo apt install --yes xsel
nvm use 14
npm install --global serve
nvm use 16
npm install --global serve

echo "install tmuxp"

sudo apt install --yes python3-pip
sudo pip3 install tmuxp

echo "install aws cli"

sudo pip3 install awscli

echo "install qutebrowser"

sudo apt --yes --no-install-recommends install \
  ca-certificates \
  python3 \
  python3-venv \
  asciidoc \
  libglib2.0-0 \
  libgl1 \
  libfontconfig1 \
  libxcb-icccm4 \
  libxcb-image0 \
  libxcb-keysyms1 \
  libxcb-randr0 \
  libxcb-render-util0 \
  libxcb-shape0 \
  libxcb-xfixes0 \
  libxcb-xinerama0 \
  libxcb-xkb1 \
  libxkbcommon-x11-0 \
  libdbus-1-3 \
  libyaml-dev \
  gcc \
  python3-dev \
  libnss3 \
  libasound2

mkdir -p ${HOME}/src/
rm -rf ${HOME}/src/qutebrowser
git clone https://github.com/qutebrowser/qutebrowser.git ${HOME}/src/qutebrowser
cd ${HOME}/src/qutebrowser
git checkout ${QUTEBROWSER_VERSION}
python3 scripts/mkvenv.py --skip-smoke-test

echo "install neovim"

npm install --global tree-sitter

# For telescope
if [ "$DIST" = "Ubuntu" ]; then
  sudo snap install ripgrep
else
  sudo apt install --yes ripgrep
fi

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
git checkout ${NEOVIM_VERSION}
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

echo "install nord tmux theme"

rm -rf ${HOME}/.tmux/themes/nord-tmux
git clone https://github.com/arcticicestudio/nord-tmux.git ${HOME}/.tmux/themes/nord-tmux
git checkout master

echo "install alacritty"

rm -rf ${HOME}/src/alacritty
git clone https://github.com/alacritty/alacritty.git ${HOME}/src/alacritty
cd ${HOME}/src/alacritty
git checkout ${ALACRITTY_VERSION}

${HOME}/.cargo/bin/cargo build --release
sudo ln -sfT ${HOME}/src/alacritty/target/release/alacritty /usr/local/bin/alacritty

mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null

mkdir -p ${HOME}/.zsh_functions
cp extra/completions/_alacritty ${HOME}/.zsh_functions/_alacritty

echo "install lab"

curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | sudo bash

echo "install gist"

sudo gem install gist

echo "install duplicity"

sudo apt install --yes librsync-dev python3-pip gettext

sudo rm -rf ${HOME}/src/duplicity
git clone https://gitlab.com/duplicity/duplicity.git ${HOME}/src/duplicity
cd ${HOME}/src/duplicity
git checkout ${DUPLICITY_VERSION}
pip3 install --upgrade pip
pip3 install -r requirements.txt
sudo python3 setup.py install

echo "install jq"

sudo apt --yes install libonig-dev

rm -rf ${HOME}/src/jq*
wget \
  --output-document ${HOME}/src/jq.tar.gz \
  https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-${JQ_VERSION}.tar.gz

cd ${HOME}/src
tar xzvf jq.tar.gz
cd ${HOME}/src/jq-${JQ_VERSION}

./configure
make
sudo make install

echo "install gist"

sudo gem install gist

echo "install nord dircolors"

rm -rf ${HOME}/src/nord-dircolors
git clone https://github.com/arcticicestudio/nord-dircolors.git ${HOME}/src/nord-dircolors
cd ${HOME}/src/nord-dircolors
ln -sfr "${HOME}/src/nord-dircolors/src/dir_colors" ${HOME}/.dir_colors

echo "install rofi"

sudo apt install --yes \
  libglib2.0-dev \
  flex \
  libxcb-xkb-dev \
  libxcb-ewmh-dev \
  libxcb-ewmh2 \
  libxcb-icccm4-dev \
  libxcb-randr0-dev \
  libxcb-util0-dev \
  libxcb-xkb1 \
  libxcb-xrm0 \
  libxcb1 \
  libxkbcommon-x11-dev \
  libxcb-cursor-dev \
  libxcb-xinerama0-dev \
  libcairo2-dev \
  libpango1.0-dev \
  libstartup-notification0-dev \
  libgdk-pixbuf2.0-dev \
  check

rm -rf ${HOME}/src/rofi
git clone https://github.com/davatorium/rofi.git ${HOME}/src/rofi
cd ${HOME}/src/rofi
git checkout ${rofi_version}
git submodule update --init
autoreconf -i
mkdir build && cd build
../configure
make
sudo make prefix=/usr/local install

echo "install keychain"

sudo apt install --yes keychain

echo "install audio dependencies"

sudo apt-get remove --purge --yes alsa-utils pulseaudio
sudo apt-get install --yes pulseaudio
sudo apt-get install --yes alsa-utils

echo "install veracrypt"

cd ${HOME}/src
wget https://launchpad.net/veracrypt/trunk/1.25.9/+download/veracrypt-1.25.9-Debian-11-amd64.deb
sudo apt install --yes ./veracrypt*.deb

echo "start cleanup process"

arch="`uname -r | sed 's/^.*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\(-[0-9]\{1,2\}\)-//'`"
debian_version="`lsb_release -r | awk '{print $2}'`";
major_version="`echo $debian_version | awk -F. '{print $1}'`";

# Disable systemd apt timers/services
sudo systemctl stop apt-daily.timer;
sudo systemctl stop apt-daily-upgrade.timer;
sudo systemctl disable apt-daily.timer;
sudo systemctl disable apt-daily-upgrade.timer;
sudo systemctl mask apt-daily.service;
sudo systemctl mask apt-daily-upgrade.service;
sudo systemctl daemon-reload;

# Disable periodic activities of apt
cat <<EOF | sudo tee -a /etc/apt/apt.conf.d/10periodic;
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

sudo apt -y upgrade linux-image-$arch;
sudo apt -y install linux-headers-`uname -r`;

echo "configure networking"

# Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" | sudo tee -a /etc/network/interfaces

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=751636
sudo apt install --yes libpam-systemd

echo "install open-vm-tools"
sudo apt install -y open-vm-tools;
sudo mkdir -p /mnt/hgfs;
sudo systemctl enable open-vm-tools
sudo systemctl start open-vm-tools

echo "remove cron"
sudo apt -y purge cron;

echo "remove obsolete networking packages"
sudo apt -y purge ppp pppconfig pppoeconf;

echo "remove popularity-contest package"
sudo apt -y purge popularity-contest;

echo "remove installation-report package"
sudo apt -y purge installation-report;

echo "autoremoving packages and cleaning apt data"
sudo apt -y autoremove;
sudo apt -y clean;

echo "remove /var/cache"
sudo find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
sudo find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
sudo truncate -s 0 /etc/machine-id

echo "remove the contents of /tmp and /var/tmp"
sudo rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
sudo rm -f /var/lib/systemd/random-seed

echo "clear the history so our install isn't there"
sudo rm -f /root/.wget-hsts
export HISTSIZE=0

if [ ! -n "$SKIP_POST_BOOTSTRAP" ]; then
  echo "bootstrap apps"
  wget -O - https://raw.githubusercontent.com/possibilities/dotfiles-next/main/install-apps.sh | sh

  if [ ! -d "${HOME}/code/dotfiles" ]; then
    echo "bootstrap dotfiles"
    wget -O - https://raw.githubusercontent.com/possibilities/dotfiles-next/main/bootstrap-dotfiles.sh | sh
  else
    echo "skip bootstrap dotfiles"
  fi
else
  echo "skip post bootstrap"
fi

echo "done bootstrapping system."
