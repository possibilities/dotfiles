#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

NODE_VERSION=22

# Load NVM if it exists
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Check if NVM is installed
if ! command -v nvm &> /dev/null; then
    echo "install nvm"
    NVM_VERSION=$(get_latest_version nvm-sh/nvm)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
    
    # Load NVM after installation
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
    echo "nvm already installed ($(nvm --version))"
fi

# Check if Node.js version is installed
if ! nvm ls ${NODE_VERSION} &> /dev/null; then
    echo "install node.js v${NODE_VERSION}"
    nvm install ${NODE_VERSION}
    nvm alias default ${NODE_VERSION}
else
    echo "node.js v${NODE_VERSION} already installed"
    nvm use ${NODE_VERSION}
fi

echo "install global npm packages"

echo "install nodemon (auto-restarts node apps on file changes)"
npm install --global nodemon

echo "install serve (static file server)"
# xsel is required by serve for clipboard functionality
sudo apt install --yes xsel
npm install --global serve

echo "install pnpm (fast, disk space efficient package manager)"
npm install --global pnpm