#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass=0
fail=0
warn=0

check_cmd() {
    local cmd="$1"
    local name="$2"

    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "[${GREEN}PASS${NC}] $name"
        ((pass++))
    else
        echo -e "[${RED}FAIL${NC}] $name"
        ((fail++))
    fi
}

check_file() {
    local file="$1"
    local name="$2"

    if [ -f "$file" ]; then
        echo -e "[${GREEN}PASS${NC}] $name"
        ((pass++))
    else
        echo -e "[${RED}FAIL${NC}] $name"
        ((fail++))
    fi
}

check_port() {
    local port="$1"

    if command -v ss >/dev/null 2>&1; then
        if ss -ltn | grep -q ":$port "; then
            echo -e "[${GREEN}PASS${NC}] Port $port listening"
            ((pass++))
        else
            echo -e "[${YELLOW}WARN${NC}] Port $port not listening"
            ((warn++))
        fi
    fi
}

echo
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}       BitzDesk Health Check            ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

check_cmd bash "Bash"
check_cmd git "Git"
check_cmd gh "GitHub CLI"
check_cmd node "Node.js"
check_cmd npm "NPM"
check_cmd python3 "Python"
check_cmd java "Java"

check_cmd vncserver "TigerVNC"
check_cmd Xvnc "Xvnc"

check_cmd startxfce4 "XFCE"
check_cmd dbus-launch "DBus"

check_cmd brave "Brave Wrapper"
check_cmd brave-browser "Brave Browser"

check_cmd codex "OpenAI Codex CLI"
check_cmd gemini "Gemini CLI"

check_cmd opencode "OpenCode CLI"
check_cmd agy "Antigravity CLI"

check_file ~/.vnc/xstartup "VNC xstartup"

check_port 5901

echo
echo "========================================"
echo "Passed : $pass"
echo "Warnings: $warn"
echo "Failed : $fail"
echo "========================================"

if [ "$fail" -eq 0 ]; then
    echo
    echo -e "${GREEN}Environment looks healthy.${NC}"
else
    echo
    echo -e "${YELLOW}Some components are missing.${NC}"
    echo "Run:"
    echo
    echo "bash .devcontainer/postCreate.sh"
fi
