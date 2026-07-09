#!/bin/bash
set -e

echo "========================================"
echo " BitzDesk Post Create"
echo "========================================"

export DEBIAN_FRONTEND=noninteractive

mkdir -p "$HOME/bin"
mkdir -p "$HOME/.vnc"
mkdir -p "$HOME/.local/share/applications"

echo 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

echo
echo "[1/7] Installing AI CLIs..."

if command -v npm >/dev/null 2>&1; then
    npm install -g @openai/codex
    npm install -g @google/gemini-cli
else
    echo "Node.js not found. Skipping Codex and Gemini."
fi

echo
echo "[2/7] Installing OpenCode..."

curl -fsSL https://opencode.ai/install | bash || true

echo
echo "[3/7] Installing Antigravity..."

curl -fsSL https://antigravity.google/cli/install.sh | bash || true

echo
echo "[4/7] Creating VNC startup..."

cat > "$HOME/.vnc/xstartup" <<'EOT'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

exec dbus-launch --exit-with-session startxfce4
EOT

chmod +x "$HOME/.vnc/xstartup"

echo
echo "[5/7] Installing desktop launcher..."

cat > "$HOME/bin/desktop" <<'EOT'
#!/bin/bash
bash .devcontainer/scripts/start-vnc.sh
EOT

chmod +x "$HOME/bin/desktop"

echo
echo "[6/7] Patching Brave..."

bash .devcontainer/scripts/patch-brave.sh || true

echo
echo "[7/7] Running health check..."

bash .devcontainer/scripts/healthcheck.sh || true

echo
echo "========================================"
echo " Setup complete!"
echo
echo "Start the desktop with:"
echo
echo "desktop"
echo
echo "========================================"

# Install BitzDesk CLI
mkdir -p "$HOME/bin"

cp .devcontainer/scripts/bitzdesk "$HOME/bin/bitzdesk"

chmod +x "$HOME/bin/bitzdesk"

grep -qxF 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" || \
echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"

echo "✓ BitzDesk CLI installed."
