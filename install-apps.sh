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
  sudo flatpak install ${FLATPAK_NAME} --assumeyes
  sudo flatpak update ${FLATPAK_NAME} --assumeyes
  # flatpak override --user --filesystem=home ${FLATPAK_NAME}
  flatpak override --user --filesystem=/steam ${FLATPAK_NAME}
  sudo ln -sf /var/lib/flatpak/exports/bin/${FLATPAK_NAME} /usr/local/bin/${APP_NAME}
}

install_flatpak warehouse io.github.flattool.Warehouse
install_flatpak keyboard org.cubocore.CoreKeyboard
install_flatpak flipclock one.alynx.FlipClock
install_flatpak clock org.kde.kclock
install_flatpak calculator org.gnome.Calculator
install_flatpak brave com.brave.Browser
install_flatpak tor org.torproject.torbrowser-launcher
install_flatpak peek com.uploadedlobster.peek
install_flatpak slack com.slack.Slack
install_flatpak discord com.discordapp.Discord
install_flatpak obs com.obsproject.Studio
install_flatpak spotify com.spotify.Client
install_flatpak hexchat io.github.Hexchat
install_flatpak flameshot org.flameshot.Flameshot
install_flatpak chrome com.google.Chrome
install_flatpak chromium org.chromium.Chromium
install_flatpak chrome-dev com.google.ChromeDev
install_flatpak vscode com.visualstudio.code
install_flatpak vlc org.videolan.VLC
install_flatpak firefox org.mozilla.firefox
install_flatpak gimp org.gimp.GIMP
install_flatpak audacity org.audacityteam.Audacity
install_flatpak avidemux org.avidemux.Avidemux

echo "done installing apps."
