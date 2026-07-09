#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}       BitzDesk Desktop Shutdown        ${NC}"
echo -e "${BLUE}========================================${NC}"

if vncserver -list | grep -q ":1"; then
    echo "Stopping VNC session..."
    vncserver -kill :1
else
    echo "No VNC session running."
fi

rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

pkill -f Xtigervnc >/dev/null 2>&1 || true
pkill -f Xvnc >/dev/null 2>&1 || true
pkill -f startxfce4 >/dev/null 2>&1 || true

echo
echo -e "${GREEN}Desktop stopped successfully.${NC}"
