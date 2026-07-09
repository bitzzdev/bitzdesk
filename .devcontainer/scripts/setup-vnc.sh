#!/usr/bin/env bash
set -Eeuo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}"
echo "========================================"
echo " BitzDesk X11VNC Setup"
echo "========================================"
echo -e "${NC}"

mkdir -p "$HOME/.vnc"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.cache"

########################################
# Kill old sessions
########################################

pkill Xvfb 2>/dev/null || true
pkill x11vnc 2>/dev/null || true
pkill xfce4-session 2>/dev/null || true
pkill dbus-daemon 2>/dev/null || true

rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

########################################
# Password
########################################

if [ ! -f "$HOME/.vnc/passwd" ]; then
    echo
    echo "Create a VNC password:"
    x11vnc -storepasswd
fi

chmod 600 "$HOME/.vnc/passwd"

########################################
# Runtime
########################################

export DISPLAY=:1
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"

mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

touch "$HOME/.Xauthority"

########################################
# Check dependencies
########################################

for BIN in Xvfb x11vnc startxfce4 dbus-launch
do
    command -v "$BIN" >/dev/null || {
        echo -e "${RED}Missing $BIN${NC}"
        exit 1
    }
done

echo
echo -e "${GREEN}✓ X11VNC configured${NC}"