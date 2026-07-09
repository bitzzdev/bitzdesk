#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/setup-vnc.sh"

echo
echo "========================================"
echo " Starting TigerVNC"
echo "========================================"
echo

# Already running?
if pgrep -x Xtigervnc >/dev/null 2>&1; then
    echo "TigerVNC is already running."
    echo
    vncserver -list
    exit 0
fi

# Clean stale lock files
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Start VNC
vncserver :1 \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost yes \
    -PasswordFile "$HOME/.vnc/passwd"

echo
echo "Waiting for desktop..."

sleep 3

if pgrep -x Xtigervnc >/dev/null 2>&1; then

    echo
    echo "========================================"
    echo " ✓ BitzDesk Desktop Ready"
    echo "========================================"
    echo

    vncserver -list

    echo
    echo "Display :1"
    echo "Port    :5901"
    echo
    echo "From Termux:"
    echo
    echo "    bitzdesk tunnel"
    echo
    exit 0
fi

echo
echo "========================================"
echo " ✗ TigerVNC failed"
echo "========================================"
echo

find "$HOME/.vnc" -name "*.log" -exec tail -100 {} \;

exit 1