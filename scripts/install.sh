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

# Function to parse JSON without jq (using python3)
parse_json() {
    local key=$1
    if command -v jq &> /dev/null; then
        echo "$RELEASE_DATA" | jq -r "$key"
    elif command -v python3 &> /dev/null; then
        echo "$RELEASE_DATA" | python3 -c "import sys, json; print(eval('json.load(sys.stdin)' + '$key'.replace('.', '[\"').replace('[]', '').replace('AssetKey', ''))) " 2>/dev/null
        # Simplified Python parser for specific fields needed
        if [[ "$key" == ".tag_name" ]]; then
            echo "$RELEASE_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])"
        elif [[ "$key" == ".assets[] | select(.name | endswith(\".deb\")) | .browser_download_url" ]]; then
            echo "$RELEASE_DATA" | python3 -c "import sys, json; print(next((a['browser_download_url'] for a in json.load(sys.stdin)['assets'] if a['name'].endswith('.deb')), ''))"
        elif [[ "$key" == ".assets[] | select(.name | endswith(\".AppImage\")) | .browser_download_url" ]]; then
            echo "$RELEASE_DATA" | python3 -c "import sys, json; print(next((a['browser_download_url'] for a in json.load(sys.stdin)['assets'] if a['name'].endswith('.AppImage')), ''))"
        fi
    else
        echo "Error: Neither 'jq' nor 'python3' is installed. One of them is required to parse GitHub API data." >&2
        exit 1
    fi
}

echo "Fetching latest release information..."
RELEASE_RESPONSE=$(curl -s -w "%{http_code}" $GITHUB_API)
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

VERSION=$(parse_json ".tag_name")

if [ -z "$VERSION" ] || [ "$VERSION" == "null" ]; then
    echo "Error: Could not extract version from GitHub API response."
    exit 1
fi

echo "Latest version found: $VERSION"

# Get download URLs
DEB_URL=$(parse_json ".assets[] | select(.name | endswith(\".deb\")) | .browser_download_url")
APPIMAGE_URL=$(parse_json ".assets[] | select(.name | endswith(\".AppImage\")) | .browser_download_url")

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
    curl -L "$DEB_URL" -o mini-browser.deb
    sudo apt-get update && sudo apt-get install -y ./mini-browser.deb
elif [ "$INSTALL_TYPE" == "appimage" ]; then
    echo "Downloading and setting up .AppImage..."
    curl -L "$APPIMAGE_URL" -o MiniBrowser.AppImage
    chmod +x MiniBrowser.AppImage
    
    sudo mkdir -p /opt/mini-browser
    sudo mv MiniBrowser.AppImage /opt/mini-browser/mini-browser

    # Download icon
    ICON_URL="https://raw.githubusercontent.com/$REPO/master/resources/icon.png"
    echo "Downloading application icon..."
    sudo curl -L "$ICON_URL" -o /opt/mini-browser/icon.png
    
    # Create Desktop Entry
    cat <<EOF > mini-browser.desktop
[Desktop Entry]
Name=Mini Browser
Exec=/opt/mini-browser/mini-browser --no-sandbox
Icon=/opt/mini-browser/icon.png
Type=Application
Categories=Utility;
EOF
    mkdir -p ~/.local/share/applications
    mv mini-browser.desktop ~/.local/share/applications/
    
    echo "AppImage installed to /opt/mini-browser/ and shortcut created."
fi

rm -rf "$TEMP_DIR"
echo "Mini Browser $VERSION installed successfully!"
