#!/bin/bash
set -e

echo "install yamlfmt"

/usr/local/go/bin/go install github.com/google/yamlfmt/cmd/yamlfmt@latest

echo "install termdbms"
/usr/local/go/bin/go install github.com/mathaou/termdbms@latest