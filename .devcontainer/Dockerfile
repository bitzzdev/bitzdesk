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
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        > /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && \
    apt-get install -y brave-browser && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*