#!/bin/bash

# Phantom Deinstallation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/master/scripts/uninstall.sh | bash

echo "Starting uninstallation of Phantom (formerly Mini Browser)..."

# Check if installed via apt
if dpkg -l | grep -q mini-browser; then
    echo "Removing .deb package..."
    sudo apt-get remove -y mini-browser
fi

# Check for various installation paths and icons
echo "Cleaning up files and icons..."
[ -d "/opt/mini-browser" ] && sudo rm -rf "/opt/mini-browser"
[ -d "/opt/Mini Browser" ] && sudo rm -rf "/opt/Mini Browser"
sudo rm -f /usr/bin/mini-browser

# Check for Desktop Entries (both old and new names)
echo "Removing desktop entries..."
rm -f "$HOME/.local/share/applications/mini-browser.desktop"
rm -f "$HOME/.local/share/applications/phantom.desktop"
# We don't remove system-wide ones as they should be handled by apt remove,
# but we ensure our overrides are gone.

echo "Phantom has been uninstalled."
