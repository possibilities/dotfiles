#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

NODE_VERSION=22

echo "install nvm"

NVM_VERSION=$(get_latest_version nvm-sh/nvm)

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

# Load NVM so we can use it right away
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install ${NODE_VERSION}
nvm alias default ${NODE_VERSION}

echo "install global npm packages"

echo "install nodemon (auto-restarts node apps on file changes)"
npm install --global nodemon

echo "install serve (static file server)"
# xsel is required by serve for clipboard functionality
sudo apt install --yes xsel
npm install --global serve

echo "install pnpm (fast, disk space efficient package manager)"
npm install --global pnpm