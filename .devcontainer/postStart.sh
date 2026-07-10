#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"

echo "========================================"
echo " BitzDesk Startup"
echo "========================================"

# Ensure directories exist
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.vnc"

# Ensure bitzdesk is in the PATH for this session
if [ -f "/usr/local/bin/bitzdesk" ]; then
    BITZDESK="/usr/local/bin/bitzdesk"
elif [ -f "$SCRIPT_DIR/scripts/bitzdesk" ]; then
    BITZDESK="$SCRIPT_DIR/scripts/bitzdesk"
    sudo install -Dm755 "$BITZDESK" "/usr/local/bin/bitzdesk" || true
else
    echo "⚠  bitzdesk CLI not found!"
    exit 1
fi

# Ensure desktop command is present
if [ ! -f "$HOME/bin/desktop" ]; then
    cat > "$HOME/bin/desktop" <<EOF
#!/usr/bin/env bash
exec bash "$SCRIPT_DIR/scripts/start-vnc.sh"
EOF
    chmod +x "$HOME/bin/desktop"
fi

# Run setup (includes Firefox/Brave installation)
echo "Running bitzdesk setup..."
"$BITZDESK" setup || true

# Patch browsers
bash "$SCRIPT_DIR/scripts/patch-brave.sh" >/dev/null 2>&1 || true

# Start VNC in background
if ! ss -ltn 2>/dev/null | grep -q ":5901"; then
    echo "Starting VNC server..."
    "$BITZDESK" start >/tmp/bitzdesk-startup-vnc.log 2>&1 &
    disown
fi

# Run doctor
echo "Running bitzdesk doctor..."
"$BITZDESK" doctor || true

# SSH hook
VNC_HOOK_MARKER="# bitzdesk-vnc-autostart"
if ! grep -qF "$VNC_HOOK_MARKER" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'BASHRC_HOOK'

# bitzdesk-vnc-autostart
if [ -n "${SSH_CONNECTION:-}" ] && [ -z "${BITZDESK_VNC_STARTED:-}" ]; then
    export BITZDESK_VNC_STARTED=1
    export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"
    if ! ss -ltn 2>/dev/null | grep -q ":5901"; then
        echo "[bitzdesk] Starting VNC desktop..."
        /home/vscode/bin/desktop >/tmp/bitzdesk-vnc-autostart.log 2>&1 &
        disown
        sleep 2
    fi
fi
BASHRC_HOOK
fi

echo "✓ Startup completed"
