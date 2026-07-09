#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " BitzDesk Startup"
echo "========================================"

mkdir -p "$HOME/bin"
mkdir -p "$HOME/.vnc"

# Paths are now handled globally in /etc/bash.bashrc and /etc/zsh/zshrc
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"

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

# CLI is now pre-installed in the Dockerfile
# Ensure symlink in user bin for legacy compatibility
mkdir -p "$HOME/bin"
ln -sf "/usr/local/bin/bitzdesk" "$HOME/bin/bitzdesk"

bash "$SCRIPT_DIR/scripts/patch-brave.sh" >/dev/null 2>&1 || true

# Always run bitzdesk setup to ensure everything is installed/updated
echo "Running bitzdesk setup..."
bitzdesk setup || true

echo
echo "Running bitzdesk doctor..."
if ! bitzdesk doctor; then
    echo
    echo "⚠  Doctor still reported issues after setup."
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
    # Refresh PATH in case it was just updated
    export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"
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

# ──────────────────────────────────────────
# Auto-start VNC server on Codespace startup
# ──────────────────────────────────────────
if ! ss -ltn 2>/dev/null | grep -q ":5901"; then
    echo "Starting VNC server..."
    # Use absolute path to ensure it works even if PATH is being refreshed
    /usr/local/bin/bitzdesk start >/tmp/bitzdesk-startup-vnc.log 2>&1 &
    disown
    echo "✓ VNC server started in background"
fi

echo
echo "✓ Startup checks completed"