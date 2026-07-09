#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " BitzDesk Startup"
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
    echo "Installing BitzDesk CLI..."
    install -Dm755 \
        "$SCRIPT_DIR/scripts/bitzdesk" \
        "$HOME/bin/bitzdesk"
    echo "✓ BitzDesk CLI installed"
fi

bash "$SCRIPT_DIR/scripts/patch-brave.sh" >/dev/null 2>&1 || true

# ──────────────────────────────────────────
# Health check — run bitzdesk doctor
# If doctor reports failures, run bitzdesk setup
# ──────────────────────────────────────────
echo
echo "Running bitzdesk doctor..."
if ! "$HOME/bin/bitzdesk" doctor; then
    echo
    echo "⚠  Doctor reported issues — running bitzdesk setup..."
    "$HOME/bin/bitzdesk" setup || true
    echo
    echo "Re-running bitzdesk doctor after setup..."
    "$HOME/bin/bitzdesk" doctor || true
fi

# ──────────────────────────────────────────
# Install SSH → VNC auto-start hook
# Injects a snippet into ~/.bashrc that starts VNC
# automatically whenever an interactive SSH session opens.
# ──────────────────────────────────────────
VNC_HOOK_MARKER="# bitzdesk-vnc-autostart"
if ! grep -qF "$VNC_HOOK_MARKER" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'BASHRC_HOOK'

# bitzdesk-vnc-autostart
# Auto-start VNC when connecting via SSH (interactive sessions only)
if [ -n "${SSH_CONNECTION:-}" ] && [ -z "${BITZDESK_VNC_STARTED:-}" ]; then
    export BITZDESK_VNC_STARTED=1
    if ! ss -ltn 2>/dev/null | grep -q ":5901"; then
        echo "[bitzdesk] Starting VNC desktop..."
        bash "$HOME/bin/desktop" >/tmp/bitzdesk-vnc-autostart.log 2>&1 &
        disown
        sleep 3
        if ss -ltn 2>/dev/null | grep -q ":5901"; then
            echo "[bitzdesk] ✓ VNC is running on port 5901"
            echo "[bitzdesk]   Run: bitzdesk tunnel"
        else
            echo "[bitzdesk] ⚠  VNC may still be starting — check: tail -f /tmp/bitzdesk-vnc-autostart.log"
        fi
    else
        echo "[bitzdesk] ✓ VNC already running on port 5901"
    fi
fi
BASHRC_HOOK
    echo "✓ SSH → VNC auto-start hook installed in ~/.bashrc"
fi

echo
echo "✓ Startup checks completed"