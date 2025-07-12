#!/bin/bash

set -e

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

echo "install termdbms"
/usr/local/go/bin/go install github.com/mathaou/termdbms@latest