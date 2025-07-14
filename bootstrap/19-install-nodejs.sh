#!/bin/bash

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