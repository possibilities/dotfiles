#!/bin/bash

echo "update apt"

sudo apt update

echo "autoremove apt"

sudo apt autoremove --yes

echo "create dirs"

mkdir -p ${HOME}/src
mkdir -p ${HOME}/local/bin