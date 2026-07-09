#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/setup-vnc.sh"

export DISPLAY=:1
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"

echo
echo "Starting Xvfb..."

Xvfb :1 \
-screen 0 1920x1080x24 \
-ac \
+extension GLX \
+render \
-noreset &

sleep 2

echo
echo "Starting XFCE..."

dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &

sleep 5

echo
echo "Starting x11vnc..."

x11vnc \
-display :1 \
-rfbauth "$HOME/.vnc/passwd" \
-forever \
-shared \
-rfbport 5901 \
-bg

echo
echo "========================================"
echo "Desktop Ready"
echo
echo "Display :1"
echo "Port    :5901"
echo
echo "Run:"
echo
echo "bitzdesk tunnel"
echo
echo "========================================"