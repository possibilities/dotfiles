#!/bin/bash

set -e

echo "install ruby"

sudo apt install --yes ruby-full

echo "install teamocil"

sudo gem install teamocil

echo "install gist"

sudo gem install gist