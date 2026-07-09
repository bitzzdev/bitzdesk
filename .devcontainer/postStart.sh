#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " BitzDesk Startup Repair"
echo "========================================"

mkdir -p "$HOME/bin"
mkdir -p "$HOME/.vnc"

grep -qxF 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || \
echo 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

if [ ! -f "$HOME/.vnc/xstartup" ]; then
    bash "$SCRIPT_DIR/scripts/setup-vnc.sh"
    echo "✓ Recreated xstartup"
fi

if [ ! -f "$HOME/.vnc/passwd" ]; then
    mkdir -p "$HOME/.vnc"
    printf "bitzdesk\nbitzdesk\nn\n" | vncpasswd >/dev/null
    echo "✓ Created VNC password"
fi

if [ ! -f "$HOME/bin/desktop" ]; then
cat > "$HOME/bin/desktop" <<EOF
#!/usr/bin/env bash
exec bash "$SCRIPT_DIR/scripts/start-vnc.sh"
EOF
chmod +x "$HOME/bin/desktop"
fi

if [ ! -f "$HOME/bin/bitzdesk" ]; then
install -Dm755 \
"$SCRIPT_DIR/scripts/bitzdesk" \
"$HOME/bin/bitzdesk"
fi

bash "$SCRIPT_DIR/scripts/patch-brave.sh" >/dev/null 2>&1 || true

bash "$SCRIPT_DIR/scripts/healthcheck.sh" >/dev/null 2>&1 || true

echo
echo "✓ Startup checks completed"