#!/bin/bash
set -e

echo
echo "========================================"
echo " BitzDesk Tunnel Helper"
echo "========================================"
echo

if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI not installed."
    exit 1
fi

echo "Opening SSH tunnel..."

gh codespace ssh -- -L 5901:localhost:5901
