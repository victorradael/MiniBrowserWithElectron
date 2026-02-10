# Phantom Deinstallation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/phantom/master/scripts/uninstall.sh | bash

echo "Starting uninstallation of Phantom..."

# 1. Remove .deb package (phantom)
if dpkg -l | grep -q phantom; then
    echo "Removing Phantom .deb package..."
    sudo apt-get remove -y phantom
fi

# 2. Remove Legacy .deb package (mini-browser)
if dpkg -l | grep -q mini-browser; then
    echo "Removing Legacy Mini Browser .deb package..."
    sudo apt-get remove -y mini-browser
fi

# 3. Clean up Phantom files
echo "Cleaning up Phantom files..."
[ -d "/opt/phantom" ] && sudo rm -rf "/opt/phantom"
sudo rm -f /usr/local/bin/phantom
sudo rm -f /usr/bin/phantom
rm -f "$HOME/.local/share/applications/phantom.desktop"

# 4. Clean up Legacy Mini Browser files (if any remain)
echo "Cleaning up legacy files..."
[ -d "/opt/mini-browser" ] && sudo rm -rf "/opt/mini-browser"
[ -d "/opt/Mini Browser" ] && sudo rm -rf "/opt/Mini Browser"
sudo rm -f /usr/local/bin/mini-browser
sudo rm -f /usr/bin/mini-browser
rm -f "$HOME/.local/share/applications/mini-browser.desktop"

echo "Phantom (and legacy components) have been uninstalled."
