#!/bin/bash
set -e

echo "Install golang"

latest_version=$(curl -s https://go.dev/dl/ | grep -Eo 'go[0-9]+(\.[0-9]+)*\.linux-amd64\.tar\.gz' | head -n 1 | sed 's/\.linux-amd64\.tar\.gz//')
if [ -z "$latest_version" ]; then
    echo "Error: Could not determine the latest Go version."
    exit 1
fi

current_version=""
if [ -x "/usr/local/go/bin/go" ]; then
    current_version=$(/usr/local/go/bin/go version | awk '{print $3}')
fi

if [ "$current_version" = "$latest_version" ]; then
    echo "Go $latest_version is already installed"
else
    echo "Installing Go $latest_version (current: ${current_version:-none})"
    sudo rm -rf /usr/local/go
    download_url="https://go.dev/dl/${latest_version}.linux-amd64.tar.gz"
    wget "$download_url"
    if [ ! -f "${latest_version}.linux-amd64.tar.gz" ]; then
        echo "Error: Download failed."
        exit 1
    fi
    sudo tar -C /usr/local -xzf "${latest_version}.linux-amd64.tar.gz"
    rm "${latest_version}.linux-amd64.tar.gz"
fi