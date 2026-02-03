#!/bin/bash

# Mini Browser Deinstallation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/master/scripts/uninstall.sh | bash

echo "Starting uninstallation of Mini Browser..."

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

# Check for Desktop Entries (both custom and system)
echo "Removing desktop entries..."
rm -f "$HOME/.local/share/applications/mini-browser.desktop"
# We don't remove system-wide ones as they should be handled by apt remove,
# but we ensures our override is gone.

echo "Mini Browser has been uninstalled."
