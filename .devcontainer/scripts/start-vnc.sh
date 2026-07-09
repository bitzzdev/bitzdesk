#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}        BitzDesk Desktop Launcher       ${NC}"
echo -e "${BLUE}========================================${NC}"

# Check dependencies
for cmd in vncserver Xvnc dbus-launch startxfce4; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Missing dependency:${NC} $cmd"
        exit 1
    fi
done

mkdir -p "$HOME/.vnc"

# Recreate xstartup if missing
if [ ! -f "$HOME/.vnc/xstartup" ]; then
cat > "$HOME/.vnc/xstartup" <<'EOT'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
EOT
chmod +x "$HOME/.vnc/xstartup"
fi

# Remove stale locks
rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

# Already running?
if vncserver -list | grep -q ":1"; then
    echo -e "${GREEN}Desktop already running.${NC}"
    vncserver -list
    exit 0
fi

echo
echo "Starting TigerVNC..."

vncserver :1 -xstartup "$HOME/.vnc/xstartup"

sleep 3

if ! vncserver -list | grep -q ":1"; then
    echo -e "${RED}VNC failed to start.${NC}"
    echo
    echo "Log:"
    tail -50 "$HOME/.vnc/"*.log || true
    exit 1
fi

if command -v ss >/dev/null 2>&1; then
    if ss -ltn | grep -q ":5901"; then
        echo -e "${GREEN}Port 5901 is listening.${NC}"
    fi
fi

echo
echo -e "${GREEN}Desktop started successfully.${NC}"
echo
vncserver -list

echo
echo "Connect using:"
echo "localhost:5901"
echo
