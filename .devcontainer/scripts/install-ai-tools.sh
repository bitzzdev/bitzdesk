#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      BitzDesk AI Tool Installer        ${NC}"
echo -e "${BLUE}========================================${NC}"

install_npm() {
    local package="$1"
    local binary="$2"

    echo
    echo "Installing $package..."

    if npm install -g "$package"; then
        if command -v "$binary" >/dev/null 2>&1; then
            echo -e "${GREEN}$binary installed.${NC}"
        else
            echo -e "${YELLOW}$binary not found in PATH.${NC}"
        fi
    else
        echo -e "${RED}Failed installing $package${NC}"
    fi
}

install_script() {
    local name="$1"
    local url="$2"
    local binary="$3"

    echo
    echo "Installing $name..."

    if curl -fsSL "$url" | bash; then
        if command -v "$binary" >/dev/null 2>&1; then
            echo -e "${GREEN}$name installed.${NC}"
        else
            echo -e "${YELLOW}$binary not found.${NC}"
        fi
    else
        echo -e "${RED}$name installation failed.${NC}"
    fi
}

if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}Node.js not installed.${NC}"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo -e "${RED}NPM not installed.${NC}"
    exit 1
fi

install_npm "@openai/codex" "codex"

install_npm "@google/gemini-cli" "gemini"

install_script \
"OpenCode" \
"https://opencode.ai/install" \
"opencode"

install_script \
"Antigravity" \
"https://antigravity.google/cli/install.sh" \
"agy"

echo
echo -e "${GREEN}AI tool installation complete.${NC}"
