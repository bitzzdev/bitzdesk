#!/usr/bin/env bash
set -Eeuo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}"
echo "========================================"
echo "      BitzDesk VNC Setup"
echo "========================================"
echo -e "${NC}"

mkdir -p "$HOME/.vnc"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.cache"

########################################
# Clean stale VNC sessions
########################################

vncserver -kill :1 >/dev/null 2>&1 || true
pkill Xtigervnc >/dev/null 2>&1 || true
pkill Xvnc >/dev/null 2>&1 || true
pkill xfce4-session >/dev/null 2>&1 || true
pkill dbus-daemon >/dev/null 2>&1 || true

rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

########################################
# Xauthority
########################################

touch "$HOME/.Xauthority"

########################################
# VNC password
########################################

if [ ! -f "$HOME/.vnc/passwd" ]; then
printf "bitzdesk\nbitzdesk\nn\n" | vncpasswd >/dev/null
chmod 600 "$HOME/.vnc/passwd"
fi

echo
echo "Configuring VNC password..."

mkdir -p "$HOME/.vnc"

if [ ! -f "$HOME/.vnc/passwd" ]; then
    echo
    echo "No VNC password found."
    echo "Please create one now."
    echo

    vncpasswd

    chmod 600 "$HOME/.vnc/passwd"

    echo
    echo "✓ Password saved."
else
    echo "✓ Existing VNC password found."
fi


########################################
# xstartup
########################################

cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

if command -v dbus-launch >/dev/null 2>&1; then
    exec dbus-launch --exit-with-session startxfce4
else
    exec startxfce4
fi
EOF

chmod +x "$HOME/.vnc/xstartup"

########################################
# XFCE defaults
########################################

mkdir -p "$HOME/.config/xfce4"

########################################
# Verify required binaries
########################################

REQUIRED=(
vncserver
Xvnc
xfce4-session
dbus-launch
)

FAILED=0

for BIN in "${REQUIRED[@]}"
do
    if ! command -v "$BIN" >/dev/null 2>&1
    then
        echo -e "${RED}Missing:${NC} $BIN"
        FAILED=1
    fi
done

if [ "$FAILED" -eq 1 ]
then
    echo
    echo "One or more required packages are missing."
    exit 1
fi

echo
echo -e "${GREEN}✓ VNC repaired successfully${NC}"