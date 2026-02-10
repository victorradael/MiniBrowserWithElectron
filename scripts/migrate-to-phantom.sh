#!/bin/bash

# Migration script from mini-browser to phantom
# This script will be used in the future when we decide to fully migrate to "phantom" naming
# For now, this is a reference implementation for future use

set -e

echo "========================================="
echo "  Mini Browser → Phantom Migration"
echo "========================================="
echo ""

# Check if old version is installed
OLD_INSTALLED=false
if dpkg -l 2>/dev/null | grep -q mini-browser; then
    OLD_INSTALLED=true
elif [ -d "/opt/mini-browser" ]; then
    OLD_INSTALLED=true
fi

if [ "$OLD_INSTALLED" = false ]; then
    echo "No old Mini Browser installation found."
    echo "Nothing to migrate. You can proceed with a fresh Phantom installation."
    exit 0
fi

echo "Old Mini Browser installation detected."
echo "This script will:"
echo "  1. Backup your settings (if any)"
echo "  2. Remove the old Mini Browser installation"
echo "  3. Install the new Phantom version"
echo ""
read -p "Continue with migration? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 0
fi

# Backup user data (if any)
echo ""
echo "[1/4] Backing up user data..."
if [ -d "$HOME/.config/mini-browser" ]; then
    cp -r "$HOME/.config/mini-browser" "$HOME/.config/phantom"
    echo "✓ Settings backed up to ~/.config/phantom"
else
    echo "✓ No user data to backup"
fi

# Uninstall old version
echo ""
echo "[2/4] Removing old Mini Browser installation..."
if dpkg -l 2>/dev/null | grep -q mini-browser; then
    sudo apt-get remove -y mini-browser
    echo "✓ Package removed"
fi

# Clean old paths
echo ""
echo "[3/4] Cleaning up old files..."
[ -d "/opt/mini-browser" ] && sudo rm -rf "/opt/mini-browser" && echo "✓ Removed /opt/mini-browser"
[ -f "/usr/bin/mini-browser" ] && sudo rm -f "/usr/bin/mini-browser" && echo "✓ Removed /usr/bin/mini-browser"
[ -f "/usr/local/bin/mini-browser" ] && sudo rm -f "/usr/local/bin/mini-browser" && echo "✓ Removed /usr/local/bin/mini-browser"
[ -f "$HOME/.local/share/applications/mini-browser.desktop" ] && rm -f "$HOME/.local/share/applications/mini-browser.desktop" && echo "✓ Removed old desktop entry"

# Install new version
echo ""
echo "[4/4] Installing Phantom..."
REPO="victorradael/MiniBrowserWithElectron"
curl -fsSL "https://raw.githubusercontent.com/$REPO/master/scripts/install.sh" | bash

echo ""
echo "========================================="
echo "  Migration Complete! 🎉"
echo "========================================="
echo ""
echo "You can now launch Phantom from your application menu."
echo "Your settings have been preserved in ~/.config/phantom"
echo ""
echo "Note: The command 'mini-browser' is no longer available."
echo "Use 'phantom' instead (when fully migrated)."
echo ""
