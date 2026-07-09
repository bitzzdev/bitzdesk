#!/usr/bin/env bash
set -e

vncserver -kill :1 >/dev/null 2>&1 || true

pkill Xtigervnc >/dev/null 2>&1 || true
pkill xfce4-session >/dev/null 2>&1 || true
pkill dbus-daemon >/dev/null 2>&1 || true

rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

echo "VNC stopped."