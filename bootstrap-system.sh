#!/bin/sh

# TODO
# * Screenshots
# * Notifications
# * Time/weather
# * Prevent qute browser quickstart from opening first time
# * Prevent fetching gitstatus for zsh when opening shell for the first time
# * Restore
#   * Ssh key
#   * zsh_history
#   * Gist creds
#   * Slack creds
#   * Browser meta

set -e

ALACRITTY_VERSION="v0.10.1"
NEOVIM_VERSION="v0.7.0"
HERBSTLUFTWM_VERSION="v0.9.4"
TMUX_VERSION="3.2a"
NODE_VERSION="14"
QUTEBROWSER_VERSION="v2.5.1"

echo "update apt"

sudo apt update

echo "configure basics"

mkdir -p /home/mike/src

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
sudo apt install libpam-systemd

echo "install open-vm-tools"
sudo apt install -y open-vm-tools;
sudo mkdir -p /mnt/hgfs;
sudo systemctl enable open-vm-tools
sudo systemctl start open-vm-tools

echo "remove cron"
dpkg --list \
  | awk '{ print $2 }' \
  | grep 'cron' \
  | sudo xargs apt -y purge;

echo "remove linux-headers"
dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | sudo xargs apt -y purge;

echo "remove specific Linux kernels, such as linux-image-4.9.0-13-amd64 but keeps the current kernel and does not touch the virtual packages"
dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-[234].*' \
    | grep -v `uname -r` \
    | sudo xargs apt -y purge;

echo "remove linux-source package"
dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | sudo xargs apt -y purge;

echo "remove all development packages"
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-dev\(:[a-z0-9]\+\)\?$' \
    | sudo xargs apt -y purge;

echo "remove X11 libraries"
sudo apt -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6;

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

echo "whiteout root"

count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
sudo dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
sudo rm /tmp/whitespace

echo "whiteout /boot"

count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
sudo dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
sudo rm /boot/whitespace

echo "cleanup misc"

set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    /sbin/swapoff "$swappart" || true;
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    /sbin/mkswap -U "$swapuuid" "$swappart";
fi

sync;

echo "install misc tools"

sudo apt install --yes \
  htop \
  tree \
  curl \
  zsh \
  dmenu \
  git

echo "install node"

curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -
sudo apt install -y nodejs

echo "install yarn"

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee -a /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install --yes --no-install-recommends yarn

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
  xterm

rm -rf /home/mike/src/herbstluftwm
git clone https://github.com/herbstluftwm/herbstluftwm.git /home/mike/src/herbstluftwm
cd /home/mike/src/herbstluftwm
git checkout ${HERBSTLUFTWM_VERSION}
mkdir build && cd build
cmake ..
make
sudo make prefix=/usr/local install

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
  libasound-dev

mkdir -p /home/mike/src/
rm -rf /home/mike/src/qutebrowser
git clone https://github.com/qutebrowser/qutebrowser.git /home/mike/src/qutebrowser
cd /home/mike/src/qutebrowser
git checkout ${QUTEBROWSER_VERSION}
python3 scripts/mkvenv.py --skip-smoke-test

echo "install neovim"

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

rm -rf /home/mike/src/neovim
git clone https://github.com/neovim/neovim.git /home/mike/src/neovim
cd /home/mike/src/neovim
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

rm -rf /home/mike/src/tmux
git clone https://github.com/tmux/tmux.git /home/mike/src/tmux
cd /home/mike/src/tmux
git checkout ${TMUX_VERSION}
sh autogen.sh
./configure && make
sudo make install

echo "install alacritty"

sudo apt install --yes \
  cmake \
  python3 \
  pkg-config \
  libfreetype6-dev \
  libfontconfig1-dev \
  libxcb-xfixes0-dev \
  libxkbcommon-dev

curl https://sh.rustup.rs -sSf | sudo sh -s -- -y
sudo /root/.cargo/bin/rustup override set stable
sudo /root/.cargo/bin/rustup update stable

rm -rf /home/mike/src/alacritty
git clone https://github.com/alacritty/alacritty.git /home/mike/src/alacritty
cd /home/mike/src/alacritty
git checkout ${ALACRITTY_VERSION}
sudo /root/.cargo/bin/cargo build --release
sudo cp target/release/alacritty /usr/local/bin
mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
mkdir -p /home/mike/.zsh_functions
echo 'fpath+=/home/mike/.zsh_functions' >> /home/mike/.zshrc
cp extra/completions/_alacritty /home/mike/.zsh_functions/_alacritty
sudo /root/.cargo/bin/rustup self uninstall -y

echo "install slack"

rm -rf /home/mike/src/slack
mkdir /home/mike/src/slack
cd /home/mike/src/slack
wget https://ftp.us.debian.org/debian/pool/main/libi/libindicator/libindicator3-7_0.5.0-4_amd64.deb
wget https://ftp.us.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb
sudo apt install --yes ./libindicator3-7_0.5.0-4_amd64.deb
sudo apt install --yes ./libappindicator3-1_0.4.92-7_amd64.deb
wget https://downloads.slack-edge.com/releases/linux/4.26.1/prod/x64/slack-desktop-4.26.1-amd64.deb
sudo apt install --yes ./slack-desktop-*.deb

if [ ! -d "/home/mike/code/dotfiles" ]; then
  wget -O - https://raw.githubusercontent.com/possibilities/dotfiles-next/main/bootstrap-dotfiles.sh | sh
fi
