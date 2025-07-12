#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting system bootstrap..."

# Run all install scripts in order
for script in "$SCRIPT_DIR"/scripts/install/*.sh; do
    if [ -f "$script" ]; then
        echo ""
        echo "======================================"
        echo "Running: $(basename "$script")"
        echo "======================================"
        bash "$script"
    fi
done

echo ""
echo "======================================"
echo "Running setup scripts..."
echo "======================================"

echo "setup dark mode"
${SCRIPT_DIR}/scripts/setup/setup-dark-mode.sh

echo "setup nginx with mkcert"
${SCRIPT_DIR}/scripts/setup/setup-nginx-mkcert.sh

echo "done bootstrapping system."
