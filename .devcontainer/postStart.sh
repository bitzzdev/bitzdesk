#!/bin/bash
set -e

echo "========================================"
echo " BitzDesk Startup Repair"
echo "========================================"

mkdir -p "$HOME/.vnc"
mkdir -p "$HOME/bin"

# Recreate xstartup if missing
if [ ! -f "$HOME/.vnc/xstartup" ]; then
    cat > "$HOME/.vnc/xstartup" <<'EOT'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

exec dbus-launch --exit-with-session startxfce4
EOT

    chmod +x "$HOME/.vnc/xstartup"
    echo "✓ Recreated xstartup"
fi

# Ensure desktop launcher exists
if [ ! -f "$HOME/bin/desktop" ]; then
cat > "$HOME/bin/desktop" <<'EOT'
#!/bin/bash
bash .devcontainer/scripts/start-vnc.sh
EOT
chmod +x "$HOME/bin/desktop"
fi

# Ensure PATH
grep -qxF 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' ~/.bashrc || \
echo 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Repair Brave launcher
bash .devcontainer/scripts/patch-brave.sh >/dev/null 2>&1 || true

echo "✓ Startup checks completed"
