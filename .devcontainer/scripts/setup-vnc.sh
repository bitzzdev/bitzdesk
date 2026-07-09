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

# Ensure Mozilla APT repo is present for Firefox
if ! [ -f /etc/apt/sources.list.d/mozilla.list ]; then
    echo "Configuring Mozilla APT repository..."
    sudo install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo -e 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    sudo apt-get update
fi

# Ensure Brave APT repo is present
if ! [ -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
    echo "Configuring Brave APT repository..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
    sudo apt-get update
fi

for BIN in Xvfb x11vnc startxfce4 dbus-launch firefox brave-browser
do
    if ! command -v "$BIN" >/dev/null 2>&1; then
        echo -e "${RED}Missing $BIN — attempting installation...${NC}"
        # Map binary names to package names if different
        PKG="$BIN"
        [ "$BIN" == "brave-browser" ] || [ "$BIN" == "brave" ] && PKG="brave-browser"
        
        sudo apt-get install -y "$PKG" || {
            echo -e "${RED}Failed to install $PKG${NC}"
            # Don't exit 1 for browsers, just warn
            [ "$BIN" == "firefox" ] || [ "$BIN" == "brave-browser" ] || exit 1
        }
    fi
done

echo
echo -e "${GREEN}✓ X11VNC configured${NC}"