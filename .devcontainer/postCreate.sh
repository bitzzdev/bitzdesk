#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " BitzDesk Post Create"
echo "========================================"

export DEBIAN_FRONTEND=noninteractive

mkdir -p "$HOME/bin"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.vnc"

# Paths are now handled globally in /etc/bash.bashrc and /etc/zsh/zshrc
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"

echo
echo "[1/7] Installing AI CLIs..."

if command -v npm >/dev/null 2>&1; then
    command -v codex >/dev/null 2>&1 || npm install -g @openai/codex
    command -v gemini >/dev/null 2>&1 || npm install -g @google/gemini-cli
else
    echo "Node.js not found. Skipping Codex and Gemini."
fi

echo
echo "[2/7] Installing OpenCode..."

command -v opencode >/dev/null 2>&1 || \
curl -fsSL https://opencode.ai/install | bash || true

echo
echo "[3/7] Installing Antigravity..."

command -v agy >/dev/null 2>&1 || \
curl -fsSL https://antigravity.google/cli/install.sh | bash || true

echo
echo "[4/7] Setting up VNC..."

bash "$SCRIPT_DIR/scripts/setup-vnc.sh"

echo
echo "[5/7] Installing desktop launcher..."

cat > "$HOME/bin/desktop" <<EOF
#!/usr/bin/env bash
exec bash "$SCRIPT_DIR/scripts/start-vnc.sh"
EOF

chmod +x "$HOME/bin/desktop"

echo
echo "[6/7] Patching Brave..."

bash "$SCRIPT_DIR/scripts/patch-brave.sh" || true

echo
echo "[7/7] Running health check..."

bash "$SCRIPT_DIR/scripts/healthcheck.sh" || true

echo
# CLI is now pre-installed in the Dockerfile
# Ensure symlink in user bin for legacy compatibility
mkdir -p "$HOME/bin"
ln -sf "/usr/local/bin/bitzdesk" "$HOME/bin/bitzdesk"

echo
echo "========================================"
echo " BitzDesk installed successfully!"
echo
echo "Available commands:"
echo "  desktop"
echo "  bitzdesk"
echo
echo "========================================"