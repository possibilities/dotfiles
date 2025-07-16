#!/bin/bash
set -e

echo "install lab"

curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | sudo bash

echo "install jq"

JQ_VERSION="1.7.1"

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