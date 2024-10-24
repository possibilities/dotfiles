#!/bin/bash

set -e

get_latest_version() {
    local REDIRECTED_RELEASE_URL
    REDIRECTED_RELEASE_URL=$(curl -s -L -o /dev/null -w "%{url_effective}" "https://github.com/$1/releases/latest")
    local VERSION
    VERSION=$(echo $REDIRECTED_RELEASE_URL | awk -F'/' '{print $NF}' | awk -F'v' '{print $2}')
    echo $VERSION
}

NVM_VERSION=$(get_latest_version nvm-sh/nvm)
ALACRITTY_VERSION=$(get_latest_version alacritty/alacritty)
NEOVIM_VERSION=$(get_latest_version neovim/neovim)

HERBSTLUFTWM_VERSION="v0.9.5"
TMUX_VERSION="3.5"
JQ_VERSION="1.7.1"
ROFI_VERSION="1.7.5"
VERACRYPT_VERSION="1.26.15"
SQLITESTUDIO_VERSION="3.4.4"

echo "install sqlitestudio"

cd ~/src
mkdir -p ~/src/sqlitestudio
wget \
  --output-document ${HOME}/src/sqlitestudio/install.run \
  https://github.com/pawelsalawa/sqlitestudio/releases/download/${SQLITESTUDIO_VERSION}/SQLiteStudio-${SQLITESTUDIO_VERSION}-linux-x64-installer.run
chmod +x ${HOME}/src/sqlitestudio/install.run

echo "update apt"

sudo apt update

echo "autoremove apt"

sudo apt autoremove --yes

echo "create dirs"

mkdir -p ${HOME}/src
mkdir -p ${HOME}/local/bin

echo "install misc tools"

sudo apt install --yes \
  tree \
  curl \
  zsh \
  git \
  xclip \
  gnome-disk-utility \
  rsync \
  p7zip-full \
  imagemagick \
  ffmpeg \
  slop \
  scrot \
  xdotool \
  wipe \
  rsnapshot \
  golang


echo "install termdbms"
go install github.com/mathaou/termdbms@latest

echo "install scrcpy"
sudo apt install \
  ffmpeg \
  libsdl2-2.0-0 \
  adb \
  wget \
  gcc \
  git \
  pkg-config \
  meson \
  ninja-build \
  libsdl2-dev \
  libavcodec-dev \
  libavdevice-dev \
  libavformat-dev \
  libavutil-dev \
  libswresample-dev \
  libusb-1.0-0 \
  libusb-1.0-0-dev

rm -rf ${HOME}/src/scrcpy
cd ~/src
git clone https://github.com/Genymobile/scrcpy
cd scrcpy
./install_release.sh

echo "install rclone"
curl https://rclone.org/install.sh | sudo bash | true

echo "install pipx"

sudo apt install pipx
pipx ensurepath
sudo pipx ensurepath

echo "install python stack"

sudo apt install --yes \
  python3 \
  python3-pip \
  python3-venv

pipx install poetry
pipx install deadcode

echo "install teamocil"

sudo gem install teamocil

echo "install docker"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install --yes docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker || true
sudo usermod -aG docker $USER || true

echo "install dunst"

sudo apt install --yes dunst libnotify-bin

echo "install nordvpn"

sh <(curl -ssf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER

echo "setup modprobe for obs virtual camera"
sudo apt install --yes v4l2loopback-dkms
echo v4l2loopback | sudo tee /etc/modules-load.d/v4l2loopback.conf

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

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
. ${HOME}/.nvm/nvm.sh

# Load NVM so we can use it right away
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 18
nvm install 20
nvm alias default 20

echo "install yarn"

sudo apt --yes install gnupg2

echo " - install yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --yes --no-install-recommends yarn

echo "install nodemon"

nvm use 18
npm install --global nodemon
nvm use 20
npm install --global nodemon

 echo "install serve"

sudo apt install --yes xsel
nvm use 18
npm install --global serve
nvm use 20
npm install --global serve

echo "install neovim"

npm install --global tree-sitter

# For telescope
sudo apt install --yes ripgrep

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
git checkout v${NEOVIM_VERSION}
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

echo "install alacritty"

rm -rf ${HOME}/src/alacritty
git clone https://github.com/alacritty/alacritty.git ${HOME}/src/alacritty
cd ${HOME}/src/alacritty
git checkout v${ALACRITTY_VERSION}

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
git checkout ${ROFI_VERSION}
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
wget https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb
sudo apt install --yes ./veracrypt*.deb

echo RUN THIS TO INSTALL SQLITE UI ${HOME}/src/sqlitestudio/install.run

echo "done bootstrapping system."

