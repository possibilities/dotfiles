#!/bin/bash
set -e

echo "update apt"

sudo apt update

echo "autoremove apt"

sudo apt autoremove --yes

echo "create dirs"

mkdir -p ${HOME}/src