#!/bin/bash

# Mini Browser Deinstallation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/master/scripts/uninstall.sh | bash

echo "Starting uninstallation of Mini Browser..."

# Check if installed via apt
if dpkg -l | grep -q mini-browser; then
    echo "Removing .deb package..."
    sudo apt-get remove -y mini-browser
fi

# Check for AppImage installation and icons
if [ -d "/opt/mini-browser" ]; then
    echo "Removing Mini Browser files and icons from /opt..."
    sudo rm -rf /opt/mini-browser
fi

# Check for Desktop Entry
if [ -f "$HOME/.local/share/applications/mini-browser.desktop" ]; then
    echo "Removing desktop entry..."
    rm "$HOME/.local/share/applications/mini-browser.desktop"
fi

echo "Mini Browser has been uninstalled."
