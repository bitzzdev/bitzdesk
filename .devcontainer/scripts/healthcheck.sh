#!/usr/bin/env bash
set -Eeuo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

PASS=0
FAIL=0
WARN=0

ok() {
    echo -e "${GREEN}✓${NC} $1"
    PASS=$((PASS+1))
}

warn() {
    echo -e "${YELLOW}!${NC} $1"
    WARN=$((WARN+1))
}

bad() {
    echo -e "${RED}✗${NC} $1"
    FAIL=$((FAIL+1))
}

check_cmd() {
    local cmd="$1"
    local name="${2:-$1}"

    if command -v "$cmd" >/dev/null 2>&1; then
        ok "$name"
    else
        bad "$name"
    fi
}

echo
echo "========================================"
echo "      BitzDesk Health Check"
echo "========================================"
echo

########################################
# Codespaces
########################################

if [ "${CODESPACES:-}" = "true" ]; then
    ok "GitHub Codespaces detected"
else
    warn "Not running inside GitHub Codespaces"
fi

########################################
# Recovery container
########################################

if [ "${CODESPACES_RECOVERY_CONTAINER:-}" = "true" ]; then
    bad "Recovery container detected"
    echo
    echo "Delete the Codespace and create a new one."
else
    ok "Devcontainer active"
fi

########################################
# OS
########################################

if grep -qi ubuntu /etc/os-release; then
    ok "Ubuntu detected"
else
    warn "Ubuntu not detected"
fi

########################################
# Core packages
########################################

check_cmd vncserver "TigerVNC"
check_cmd Xvnc "Xvnc"
check_cmd xfce4-session "XFCE"
check_cmd dbus-launch "DBus"
check_cmd xauth "Xauthority"
check_cmd curl "curl"
check_cmd git "Git"
check_cmd gh "GitHub CLI"

########################################
# Browsers
########################################

if command -v brave >/dev/null 2>&1 || command -v brave-browser >/dev/null 2>&1; then
    ok "Brave Browser"
else
    bad "Brave Browser"
fi

if command -v chromium >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1; then
    ok "Chromium"
else
    warn "Chromium"
fi

########################################
# AI CLIs
########################################

check_cmd codex "OpenAI Codex CLI"
check_cmd gemini "Gemini CLI"
check_cmd opencode "OpenCode CLI"
check_cmd agy "Antigravity CLI"

########################################
# VNC files
########################################

if [ -f "$HOME/.vnc/xstartup" ]; then
    ok "xstartup exists"
else
    bad "Missing xstartup"
fi

if [ -f "$HOME/.vnc/passwd" ]; then
    ok "VNC password"
else
    bad "Missing VNC password"
fi

########################################
# Port
########################################

if ss -ltn 2>/dev/null | grep -q ":5901"; then
    ok "VNC listening on port 5901"
else
    warn "VNC server not currently running"
fi

########################################
# DISPLAY
########################################

if [ -n "${DISPLAY:-}" ]; then
    ok "DISPLAY=$DISPLAY"
else
    warn "DISPLAY not set"
fi

########################################
# Xauthority
########################################

if [ -f "$HOME/.Xauthority" ]; then
    ok ".Xauthority"
else
    warn ".Xauthority missing"
fi

########################################
# Disk space
########################################

FREE=$(df -h / | awk 'NR==2{print $4}')
ok "Free disk space: $FREE"

########################################
# Summary
########################################

echo
echo "========================================"

echo -e "${GREEN}Passed : $PASS${NC}"
echo -e "${YELLOW}Warnings: $WARN${NC}"
echo -e "${RED}Failed : $FAIL${NC}"

echo "========================================"

if [ "$FAIL" -eq 0 ]; then
    echo
    echo -e "${GREEN}✓ BitzDesk is ready.${NC}"
    exit 0
else
    echo
    echo -e "${RED}Some required components are missing.${NC}"
    echo
    echo "Run:"
    echo
    echo "    bitzdesk setup"
    echo
    echo "or rebuild the Codespace if you're in the recovery container."
    exit 1
fi