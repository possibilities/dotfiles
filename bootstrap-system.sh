#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${SCRIPT_DIR}/bootstrap"

source "${BOOTSTRAP_DIR}/helpers.sh"

for script in "${BOOTSTRAP_DIR}"/*.sh; do
    if [ -f "$script" ] && [ "$(basename "$script")" != "helpers.sh" ]; then
        echo "Running $(basename "$script")..."
        source "$script"
    fi
done

echo "done bootstrapping system."