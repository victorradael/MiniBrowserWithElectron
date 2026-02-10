# Installation & Distribution Guide

This document describes how to generate the Phantom installers and how to install it on Linux systems.

## ⬇️ Download and Installation (Recommended)

The easiest way to install is by downloading the latest version from the GitHub **Releases** page:

👉 **[Download latest version (Releases)](https://github.com/victorradael/MiniBrowserWithElectron/releases/latest)**

1. Download the `.deb` file (for installation) or `.AppImage` (for direct execution).
2. Follow the installation instructions below.

---

## 🛠️ Generating Installers Locally (Development)

## 📦 Installation (Ubuntu/Debian)

If you generated or downloaded a `.deb` file, you can install it via terminal:

### Install:
```bash
# Navigate to the download/dist folder and install the package
sudo dpkg -i dist/mini-browser_*.deb
# If dependencies are missing:
sudo apt-get install -f
```

### Uninstall:
```bash
sudo apt remove mini-browser
```

---

## 🚀 AppImage Execution

The `AppImage` format does not require installation. Just grant execution permission:

1. Right-click on the `dist/mini-browser_*.AppImage` file.
2. Go to **Properties** > **Permissions** > Check **Allow executing file as program**.
3. Or via terminal:
   ```bash
   chmod +x dist/mini-browser_*.AppImage
   ./dist/mini-browser_*.AppImage
   ```

---

## 🧹 Cleanup (Development)

To remove temporary build files:
```bash
rm -rf dist/ out/
```

---

## 🔄 Update Flow

### Automated Script
The `install.sh` script (linked in the README) automatically detects if Phantom (or Mini Browser) is already present on the system. If it finds a previous version, it automatically runs the uninstaller before applying the new version, ensuring a clean transition.

### In-App Notifications
Phantom now periodically checks for new releases on GitHub. When a newer version is detected:
1. An elegant **Blue Steel** notification appears in the corner of the screen.
2. Clicking "Update Now" opens the release link and copies the quick install command to your clipboard for convenience.

---

## 🐧 Troubleshooting (Linux Sandbox)

If the application fails to start with a "SUID sandbox helper" error, you can:

1. **Run without sandbox (Quick)**:
   Add `--no-sandbox` to the execution command.

2. **Enable in Kernel (Recommended)**:
   ```bash
   sudo sysctl -w kernel.unprivileged_userns_clone=1
   ```

3. **Check Limits and AppArmor**:
   *   Ensure `user.max_user_namespaces` is not 0.
   *   If on Ubuntu 24.04+, you might need:
       ```bash
       sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
       ```

---

## 🔐 Security Considerations

When using the above commands to resolve Linux sandbox issues, be aware of the implications:

| Command / Flag | Risk | Recommendation |
| :--- | :--- | :--- |
| `--no-sandbox` | Removes isolation between web content and your system. | Use only for development and with trusted URLs. |
| `unprivileged_userns_clone` | Increases attack surface for Kernel exploits. | Required for Docker/Flatpak; keep enabled if using these tools. |
| `apparmor_restrict_unprivileged_userns` | Removes a specific Ubuntu lock against privilege exploits. | Prefer enabling specific AppArmor profiles if in a production environment. |

> [!IMPORTANT]
> The sandbox is the browser's primary defense against malicious sites. Never browse unknown sites with the `--no-sandbox` flag active.
