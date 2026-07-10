#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " BitzDesk Post Create"
echo "========================================"

export DEBIAN_FRONTEND=noninteractive
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"

mkdir -p "$HOME/bin"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.vnc"

echo
echo "[1/4] Installing AI CLIs..."
if command -v npm >/dev/null 2>&1; then
    npm install -g @openai/codex @google/gemini-cli || true
fi

echo
echo "[2/4] Installing OpenCode & Antigravity..."
curl -fsSL https://opencode.ai/install | bash || true
curl -fsSL https://antigravity.google/cli/install.sh | bash || true

echo
echo "[3/4] Setting up VNC..."
bash "$SCRIPT_DIR/scripts/setup-vnc.sh"

echo
echo "[4/4] Finalizing CLI..."
# Ensure the baked CLI is available and has correct permissions
sudo chmod +x /usr/local/bin/bitzdesk || true
ln -sf /usr/local/bin/bitzdesk "$HOME/bin/bitzdesk" || true

echo
echo "========================================"
echo " BitzDesk Post Create Finished"
echo "========================================"
