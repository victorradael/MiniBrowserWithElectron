#!/bin/bash

# Mini Browser Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/main/scripts/install.sh | bash

set -e

REPO="victorradael/MiniBrowserWithElectron"
APP_NAME="mini-browser"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

# Check dependencies
for cmd in curl jq wget; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

echo "Fetching latest release information..."
RELEASE_DATA=$(curl -s $GITHUB_API)
VERSION=$(echo "$RELEASE_DATA" | jq -r .tag_name)

if [ "$VERSION" == "null" ]; then
    echo "Error: Could not find any releases for $REPO."
    exit 1
fi

echo "Latest version found: $VERSION"

# Get download URLs
DEB_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url')
APPIMAGE_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url')

if [ -n "$DEB_URL" ]; then
    echo "Found .deb package."
    INSTALL_TYPE="deb"
elif [ -n "$APPIMAGE_URL" ]; then
    echo "Found .AppImage package."
    INSTALL_TYPE="appimage"
else
    echo "Error: No suitable Linux binaries (.deb or .AppImage) found in the latest release."
    exit 1
fi

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if [ "$INSTALL_TYPE" == "deb" ]; then
    echo "Downloading and installing .deb package..."
    wget -q --show-progress "$DEB_URL" -O mini-browser.deb
    sudo apt-get update && sudo apt-get install -y ./mini-browser.deb
elif [ "$INSTALL_TYPE" == "appimage" ]; then
    echo "Downloading and setting up .AppImage..."
    wget -q --show-progress "$APPIMAGE_URL" -O MiniBrowser.AppImage
    chmod +x MiniBrowser.AppImage
    
    sudo mkdir -p /opt/mini-browser
    sudo mv MiniBrowser.AppImage /opt/mini-browser/mini-browser
    
    # Create Desktop Entry
    cat <<EOF > mini-browser.desktop
[Desktop Entry]
Name=Mini Browser
Exec=/opt/mini-browser/mini-browser --no-sandbox
Icon=mini-browser
Type=Application
Categories=Utility;
EOF
    mkdir -p ~/.local/share/applications
    mv mini-browser.desktop ~/.local/share/applications/
    
    echo "AppImage installed to /opt/mini-browser/ and shortcut created."
fi

rm -rf "$TEMP_DIR"
echo "Mini Browser $VERSION installed successfully!"
