#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/setup-vnc.sh"

echo
echo "Starting TigerVNC..."

vncserver :1 -geometry 1920x1080 -depth 24

sleep 3

if ! vncserver -list | grep -q ":1"
then
    echo
    echo "VNC failed to start."
    echo
    tail -50 ~/.vnc/*.log || true
    exit 1
fi

echo
echo "========================================"
echo "VNC running!"
echo
echo "Display :1"
echo "Port    :5901"
echo
echo "Run from Termux:"
echo
echo "bitzdesk tunnel"
echo
echo "========================================"