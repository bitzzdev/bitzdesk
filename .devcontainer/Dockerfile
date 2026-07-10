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
        zip \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Global PATH configuration
RUN echo 'export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"' >> /etc/bash.bashrc && \
    (mkdir -p /etc/zsh && echo 'export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"' >> /etc/zsh/zshrc || true)
