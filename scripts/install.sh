#!/bin/bash

# Phantom Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/phantom/master/scripts/install.sh | bash

set -e

REPO="victorradael/phantom"
APP_NAME="phantom"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it and try again."
    exit 1
fi

# IMPROVEMENT: Check if already installed (Phantom or Legacy Mini Browser) and uninstall if necessary
echo "Checking for existing installation..."
ALREADY_INSTALLED=false

# Check for Legacy Mini Browser
if dpkg -l | grep -q mini-browser || [ -d "/opt/mini-browser" ]; then
    echo "Legacy 'Mini Browser' detected. Uninstalling to upgrade to Phantom v3.0.0..."
    # Try to run the uninstaller if it exists locally or download it
    # Since we are upgrading, we can interpret 'uninstall.sh' from the current repo (which handles both)
    curl -fsSL "https://raw.githubusercontent.com/$REPO/master/scripts/uninstall.sh" | bash || {
         echo "Warning: Uninstallation script encountered an error. Attempting to continue..."
    }
fi

# Check for previous Phantom installation
if dpkg -l | grep -q phantom || [ -d "/opt/phantom" ]; then
    ALREADY_INSTALLED=true
fi

if [ "$ALREADY_INSTALLED" = true ]; then
    echo "Existing Phantom installation detected. Running uninstaller before proceeding..."
    curl -fsSL "https://raw.githubusercontent.com/$REPO/master/scripts/uninstall.sh" | bash || {
        echo "Warning: Uninstallation script encountered an error. Attempting to continue installation anyway..."
    }
fi

# Function to parse JSON without jq (using python3)
parse_json() {
    local type=$1
    if command -v jq &> /dev/null; then
        case $type in
            tag) echo "$RELEASE_DATA" | jq -r ".tag_name" ;;
            deb) echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | test("\\.deb$"; "i")) | .browser_download_url' | head -n 1 ;;
            appimage) echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | test("\\.appimage$"; "i")) | .browser_download_url' | head -n 1 ;;
        esac
    elif command -v python3 &> /dev/null; then
        case $type in
            tag) echo "$RELEASE_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tag_name', ''))" ;;
            deb) echo "$RELEASE_DATA" | python3 -c "import sys, json; print(next((a['browser_download_url'] for a in json.load(sys.stdin).get('assets', []) if a['name'].lower().endswith('.deb')), ''))" 2>/dev/null ;;
            appimage) echo "$RELEASE_DATA" | python3 -c "import sys, json; print(next((a['browser_download_url'] for a in json.load(sys.stdin).get('assets', []) if a['name'].lower().endswith('.appimage')), ''))" 2>/dev/null ;;
        esac
    fi
}

echo "Fetching latest release information..."
RELEASE_RESPONSE=$(curl -s -L -w "%{http_code}" "$GITHUB_API")
HTTP_CODE="${RELEASE_RESPONSE:${#RELEASE_RESPONSE}-3}"
RELEASE_DATA="${RELEASE_RESPONSE:0:${#RELEASE_RESPONSE}-3}"

if [ "$HTTP_CODE" -eq 404 ]; then
    echo "Error: No releases found for $REPO."
    echo "Please ensure you have created at least one release on GitHub."
    exit 1
elif [ "$HTTP_CODE" -ne 200 ]; then
    echo "Error: GitHub API returned status code $HTTP_CODE."
    exit 1
fi

VERSION=$(parse_json "tag")

if [ -z "$VERSION" ] || [ "$VERSION" == "null" ]; then
    echo "Error: Could not extract version from GitHub API response."
    exit 1
fi

echo "Latest version found: $VERSION"

# Get download URLs
APPIMAGE_URL=$(parse_json "appimage")
DEB_URL=$(parse_json "deb")

if [ -n "$APPIMAGE_URL" ]; then
    echo "Found AppImage package."
    INSTALL_TYPE="appimage"
    DOWNLOAD_URL="$APPIMAGE_URL"
elif [ -n "$DEB_URL" ]; then
    echo "Found .deb package."
    INSTALL_TYPE="deb"
    DOWNLOAD_URL="$DEB_URL"
else
    echo "Error: No suitable Linux binaries found in the latest release."
    exit 1
fi

TEMP_DIR=$(mktemp -d)
chmod 755 "$TEMP_DIR"
cd "$TEMP_DIR"

if [ "$INSTALL_TYPE" == "appimage" ]; then
    echo "Downloading and setting up AppImage..."
    curl -L "$DOWNLOAD_URL" -o phantom.AppImage
    chmod +x phantom.AppImage
    sudo mkdir -p /opt/phantom
    sudo mv phantom.AppImage /opt/phantom/phantom
else
    echo "Downloading and installing .deb package..."
    curl -L "$DOWNLOAD_URL" -o phantom.deb
    sudo apt-get update && sudo apt-get install -y ./phantom.deb
fi

# ICON AND DESKTOP ENTRY (Unified for both types to ensure correct icon)
echo "Setting up application icon and menu shortcut..."
sudo mkdir -p /opt/phantom
ICON_URL="https://raw.githubusercontent.com/$REPO/master/resources/icon.png"
sudo curl -s -L "$ICON_URL" -o /opt/phantom/icon.png

cat <<EOF > phantom.desktop
[Desktop Entry]
Name=Phantom
Comment=A silent, focused browser for the shadows
Exec=phantom --no-sandbox
Icon=/opt/phantom/icon.png
Terminal=false
Type=Application
StartupWMClass=Phantom
Categories=Utility;Network;WebBrowser;
EOF

# Use a standard bin link for appimage
if [ "$INSTALL_TYPE" == "appimage" ]; then
    sudo ln -sf /opt/phantom/phantom /usr/local/bin/phantom
fi

mkdir -p ~/.local/share/applications
mv phantom.desktop ~/.local/share/applications/phantom.desktop

# Force database update
[ -x "$(command -v update-desktop-database)" ] && update-desktop-database ~/.local/share/applications || true

rm -rf "$TEMP_DIR"
echo "Phantom $VERSION installed successfully!"
