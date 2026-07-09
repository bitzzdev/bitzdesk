#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      BitzDesk Browser Patcher          ${NC}"
echo -e "${BLUE}========================================${NC}"

BRAVE_BIN=""

for candidate in \
    /usr/bin/brave-browser \
    /usr/bin/brave \
    /opt/brave.com/brave/brave-browser
do
    if [ -x "$candidate" ]; then
        BRAVE_BIN="$candidate"
        break
    fi
done

if [ -z "$BRAVE_BIN" ]; then
    echo -e "${YELLOW}Brave not installed. Skipping.${NC}"
    exit 0
fi

echo "Found Brave: $BRAVE_BIN"

sudo tee /usr/local/bin/brave >/dev/null <<EOT
#!/bin/bash
exec $BRAVE_BIN \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --disable-software-rasterizer \
  --disable-features=UseChromeOSDirectVideoDecoder \
  --user-data-dir=/tmp/brave \
  "\$@"
EOT

sudo chmod +x /usr/local/bin/brave

if [ -f /usr/share/applications/brave-browser.desktop ]; then

sudo sed -i \
's|^Exec=.*|Exec=/usr/local/bin/brave %U|' \
/usr/share/applications/brave-browser.desktop

mkdir -p ~/.local/share/applications

cp /usr/share/applications/brave-browser.desktop \
~/.local/share/applications/

fi

if command -v chromium >/dev/null 2>&1; then

sudo tee /usr/local/bin/chromium-fixed >/dev/null <<'EOT'
#!/bin/bash
exec chromium \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --user-data-dir=/tmp/chromium \
  "$@"
EOT

sudo chmod +x /usr/local/bin/chromium-fixed

fi

echo
echo -e "${GREEN}Browser patch complete.${NC}"
