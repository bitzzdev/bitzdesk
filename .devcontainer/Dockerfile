FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        xfce4 \
        xfce4-goodies \
        xvfb \
        x11vnc \
        dbus-x11 \
        xterm \
        xauth \
        curl \
        wget \
        lsof \
        net-tools \
        ca-certificates \
        gnupg \
        mesa-utils \
        libgl1-mesa-dri \
        libgl1 \
        fonts-dejavu \
        unzip \
        zip && \
    # ──────────────────────────────────────────
    # Firefox (Mozilla APT Repository)
    # ──────────────────────────────────────────
    install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' | tee /etc/apt/preferences.d/mozilla > /dev/null && \
    # ──────────────────────────────────────────
    # Brave Browser
    # ──────────────────────────────────────────
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        > /etc/apt/sources.list.d/brave-browser-release.list && \
    # ──────────────────────────────────────────
    # Install Browsers
    # ──────────────────────────────────────────
    apt-get update && \
    apt-get install -y \
        firefox \
        brave-browser && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────
# Bake BitzDesk CLI into the image
# ──────────────────────────────────────────
# Path relative to context (repo root)
COPY .devcontainer/scripts/bitzdesk /usr/local/bin/bitzdesk
RUN chmod +x /usr/local/bin/bitzdesk

# ──────────────────────────────────────────
# Global PATH configuration
# ──────────────────────────────────────────
RUN echo 'export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"' >> /etc/bash.bashrc && \
    (mkdir -p /etc/zsh && echo 'export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"' >> /etc/zsh/zshrc || true)
