#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      BitzDesk VNC Setup                ${NC}"
echo -e "${BLUE}========================================${NC}"

mkdir -p ~/.vnc

cat > ~/.vnc/xstartup <<'EOT'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

if command -v dbus-launch >/dev/null 2>&1; then
    exec dbus-launch --exit-with-session startxfce4
else
    exec startxfce4
fi
EOT

chmod +x ~/.vnc/xstartup

mkdir -p ~/.config/xfce4

touch ~/.Xauthority

rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

echo -e "${GREEN}✓ VNC configuration repaired.${NC}"
