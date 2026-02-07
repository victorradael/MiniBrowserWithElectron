#!/bin/bash

# Mini Browser Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/master/scripts/install.sh | bash

set -e

REPO="victorradael/MiniBrowserWithElectron"
APP_NAME="mini-browser"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it and try again."
    exit 1
fi

# IMPROVEMENT: Check if already installed and uninstall if necessary
echo "Checking for existing installation..."
ALREADY_INSTALLED=false
if dpkg -l | grep -q mini-browser; then
    ALREADY_INSTALLED=true
elif [ -d "/opt/mini-browser" ]; then
    ALREADY_INSTALLED=true
fi

if [ "$ALREADY_INSTALLED" = true ]; then
    echo "Existing installation detected. Running uninstaller before proceeding..."
    # Download and run the uninstaller directly from the repo to ensure it's up to date
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
    curl -L "$DOWNLOAD_URL" -o mini-browser.AppImage
    chmod +x mini-browser.AppImage
    sudo mkdir -p /opt/mini-browser
    sudo mv mini-browser.AppImage /opt/mini-browser/mini-browser
else
    echo "Downloading and installing .deb package..."
    curl -L "$DOWNLOAD_URL" -o mini-browser.deb
    sudo apt-get update && sudo apt-get install -y ./mini-browser.deb
fi

# ICON AND DESKTOP ENTRY (Unified for both types to ensure correct icon)
echo "Setting up application icon and menu shortcut..."
sudo mkdir -p /opt/mini-browser
ICON_URL="https://raw.githubusercontent.com/$REPO/master/resources/icon.png"
sudo curl -s -L "$ICON_URL" -o /opt/mini-browser/icon.png

cat <<EOF > mini-browser-custom.desktop
[Desktop Entry]
Name=Mini Browser
Comment=A minimal browser for focused work
Exec=mini-browser --no-sandbox
Icon=/opt/mini-browser/icon.png
Terminal=false
Type=Application
StartupWMClass=Mini Browser
Categories=Utility;Network;WebBrowser;
EOF

# Use a standard bin link for appimage
if [ "$INSTALL_TYPE" == "appimage" ]; then
    sudo ln -sf /opt/mini-browser/mini-browser /usr/local/bin/mini-browser
fi

mkdir -p ~/.local/share/applications
mv mini-browser-custom.desktop ~/.local/share/applications/mini-browser.desktop

# Force database update
[ -x "$(command -v update-desktop-database)" ] && update-desktop-database ~/.local/share/applications || true

rm -rf "$TEMP_DIR"
echo "Mini Browser $VERSION installed successfully!"
