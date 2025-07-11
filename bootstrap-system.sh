#!/bin/bash

set -e

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
  dnsmasq \
  nginx

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
UV_VERSION=$(get_latest_version astral-sh/uv)

HERBSTLUFTWM_VERSION="v0.9.5"
TMUX_VERSION="3.5"
JQ_VERSION="1.7.1"
ROFI_VERSION="1.7.5"
VERACRYPT_VERSION="1.26.14"
SQLITESTUDIO_VERSION="3.4.4"

mkdir -p ~/.local/bin/

echo "Install greenclip"

if [ ! -f ~/.local/bin/greenclip ]; then
    mkdir -p ~/src/greenclip
    cd ~/src/greenclip
    wget https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    chmod +x ./greenclip
    cp ./greenclip ~/.local/bin/greenclip
else
    echo "greenclip already installed, skipping"
fi

echo "Install golang"

sudo rm -rf /usr/local/go
latest_version=$(curl -s https://go.dev/dl/ | grep -Eo 'go[0-9]+(\.[0-9]+)*\.linux-amd64\.tar\.gz' | head -n 1 | sed 's/\.linux-amd64\.tar\.gz//')
if [ -z "$latest_version" ]; then
    echo "Error: Could not determine the latest Go version."
    exit 1
fi
download_url="https://go.dev/dl/${latest_version}.linux-amd64.tar.gz"
wget "$download_url"
if [ ! -f "${latest_version}.linux-amd64.tar.gz" ]; then
    echo "Error: Download failed."
    exit 1
fi
sudo tar -C /usr/local -xzf "${latest_version}.linux-amd64.tar.gz"
rm "${latest_version}.linux-amd64.tar.gz"

echo "Installing GitLab CLI"

/usr/local/go/bin/go install "gitlab.com/gitlab-org/cli/cmd/glab@latest"

echo "Installing GitHub CLI"

sudo mkdir -p -m 755 /etc/apt/keyrings
out=$(mktemp)
wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg
cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh --yes

echo "install yamlfmt"

/usr/local/go/bin/go install github.com/google/yamlfmt/cmd/yamlfmt@latest

echo "install sqlitestudio"

cd ~/src
mkdir -p ~/src/sqlitestudio
wget \
  --output-document ${HOME}/src/sqlitestudio/install.run \
  https://github.com/pawelsalawa/sqlitestudio/releases/download/${SQLITESTUDIO_VERSION}/SQLiteStudio-${SQLITESTUDIO_VERSION}-linux-x64-installer.run
chmod +x ${HOME}/src/sqlitestudio/install.run

echo "install termdbms"
/usr/local/go/bin/go install github.com/mathaou/termdbms@latest

echo "install scrcpy"
sudo apt install --yes \
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

sudo apt --yes install pipx
pipx ensurepath
sudo pipx ensurepath

echo "install python stack"

sudo apt install --yes \
  python3 \
  python3-pip \
  python3-venv

pipx install deadcode

echo "install uv"

# Download and install uv
curl -LsSf https://github.com/astral-sh/uv/releases/download/v${UV_VERSION}/uv-installer.sh | sh

echo "install ruby"

sudo apt install --yes ruby-full

echo "install teamocil"

sudo gem install teamocil

echo "install docker"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install --yes ca-certificates curl
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

echo "configure nordvpn firewall rules for local nginx access"

# Allow local nginx access when using NordVPN
# This permits browser connections to localhost nginx while VPN is active
# Note: NordVPN uses iptables-nft, so we use iptables commands
# These rules must be inserted before the drop rule, so we insert at position 1
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 127.0.0.1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 127.0.0.1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 192.168.0.0/16 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 192.168.0.0/16 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 172.16.0.0/12 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 172.16.0.0/12 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 10.0.0.0/8 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 10.0.0.0/8 -p tcp --dport 443 -j ACCEPT

# Make rules persistent using iptables-save
sudo iptables-save > /tmp/iptables.rules
sudo cp /tmp/iptables.rules /etc/iptables/rules.v4 2>/dev/null || true
rm /tmp/iptables.rules

echo "setup modprobe for obs virtual camera"
sudo apt install --yes v4l2loopback-dkms
echo v4l2loopback | sudo tee /etc/modules-load.d/v4l2loopback.conf

echo "install fira font"

sudo apt install --yes fonts-firacode

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

nvm install 22
nvm alias default 22

echo "install nodemon"

nvm use 22
npm install --global nodemon

 echo "install serve"

sudo apt install --yes xsel
nvm use 22
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

sudo mkdir -p /usr/local/share/man/man1
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

echo "install rofi"

sudo apt install --yes rofi

echo "install keychain"

sudo apt install --yes keychain

echo "install audio dependencies"

sudo apt-get remove --purge --yes alsa-utils pulseaudio
sudo apt-get install --yes pulseaudio
sudo apt-get install --yes alsa-utils

echo "install veracrypt"

cd ${HOME}/src
wget "https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb"
sudo apt install --yes ./veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb

echo RUN THIS TO INSTALL SQLITE UI ${HOME}/src/sqlitestudio/install.run

echo "setup dark mode"
${HOME}/code/dotfiles/setup-dark-mode.sh

echo "setup nginx with mkcert"
${HOME}/code/dotfiles/setup-nginx-mkcert.sh

echo "done bootstrapping system."
