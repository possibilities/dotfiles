#!/bin/sh -eux

set -e

echo "install flatpak"

sudo apt install flatpak --yes
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "install desktop apps"

install_flatpak () {
  APP_NAME=${1}
  FLATPAK_NAME=${2}
  echo "install ${APP_NAME}"
  if flatpak list | grep -q ${FLATPAK_NAME}; then
    echo "${APP_NAME} already installed, updating..."
    sudo flatpak update ${FLATPAK_NAME} --assumeyes
  else
    sudo flatpak install ${FLATPAK_NAME} --assumeyes
  fi
  flatpak override --user --filesystem=/steam ${FLATPAK_NAME}
  flatpak override --user --socket=x11 ${FLATPAK_NAME}
  flatpak override --user --talk-name=org.freedesktop.portal.Desktop ${FLATPAK_NAME}
  sudo ln -sf /var/lib/flatpak/exports/bin/${FLATPAK_NAME} /usr/local/bin/${APP_NAME}
}

install_flatpak_from_url () {
  APP_NAME=${1}
  URL=${2}
  FLATPAK_NAME=${3}
  echo "install ${APP_NAME} from URL"
  if flatpak list | grep -q ${FLATPAK_NAME}; then
    echo "${APP_NAME} already installed, skipping download and install..."
  else
    wget -O "/tmp/${APP_NAME}.flatpak" "${URL}"
    sudo flatpak install "/tmp/${APP_NAME}.flatpak" --assumeyes
    rm "/tmp/${APP_NAME}.flatpak"
  fi
  flatpak override --user --filesystem=/steam ${FLATPAK_NAME}
  flatpak override --user --socket=x11 ${FLATPAK_NAME}
  flatpak override --user --talk-name=org.freedesktop.portal.Desktop ${FLATPAK_NAME}
  sudo ln -sf /var/lib/flatpak/exports/bin/${FLATPAK_NAME} /usr/local/bin/${APP_NAME}
}

install_flatpak_from_url distill "https://utils.distill.io/electron/download/beta/linux/flatpak/latest" io.distill.distill
install_flatpak trayscale dev.deedles.Trayscale
install_flatpak blanket com.rafaelmardojai.Blanket
install_flatpak obsidian md.obsidian.Obsidian
install_flatpak androidstudio com.google.AndroidStudio
install_flatpak connections org.gnome.Connections
install_flatpak shotwell org.gnome.Shotwell
install_flatpak xnview com.xnview.XnViewMP
install_flatpak warehouse io.github.flattool.Warehouse
install_flatpak flipclock one.alynx.FlipClock
install_flatpak clock org.kde.kclock
install_flatpak calculator org.gnome.Calculator
install_flatpak brave com.brave.Browser
install_flatpak tor org.torproject.torbrowser-launcher
install_flatpak slack com.slack.Slack
install_flatpak discord com.discordapp.Discord
install_flatpak obs com.obsproject.Studio
install_flatpak spotify com.spotify.Client
install_flatpak hexchat io.github.Hexchat
install_flatpak flameshot org.flameshot.Flameshot
install_flatpak chrome com.google.Chrome
install_flatpak chromium org.chromium.Chromium
install_flatpak chrome-dev com.google.ChromeDev
install_flatpak vlc org.videolan.VLC
install_flatpak firefox org.mozilla.firefox
install_flatpak gimp org.gimp.GIMP
install_flatpak audacity org.audacityteam.Audacity
install_flatpak avidemux org.avidemux.Avidemux
install_flatpak kdiskmark io.github.jonmagon.kdiskmark
install_flatpak steam com.valvesoftware.Steam

echo "done installing apps."
