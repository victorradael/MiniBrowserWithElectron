import { app, shell, BrowserWindow, ipcMain, session, dialog, Menu } from 'electron'
import * as electron from 'electron' // Import all for safely using electron.Menu if needed or just use destructured
import { join, basename } from 'path'
import { electronApp, optimizer, is } from '@electron-toolkit/utils'
import icon from '../../resources/icon.png?asset'
import Store from 'electron-store'
import fs from 'fs'

const store = new Store()

// Suppress some noisy Electron/Chromium logs on Linux
app.commandLine.appendSwitch('log-level', '3')
app.commandLine.appendSwitch('disable-gpu-process-crash-log')

// Allow Electron to decide the best platform (Wayland vs X11) automatically
// app.commandLine.appendSwitch('ozone-platform-hint', 'auto')

// Set the application name clearly for the window manager (helpful for GNOME)
app.setName('Mini Browser')

// Linux: Explicitly link to the desktop file for icon association in dev mode
if (is.dev && process.platform === 'linux') {
    app.setDesktopName('mini-browser-dev.desktop')
}

function createWindow() {
    // Create the browser window.
    const iconPath = join(__dirname, '../../resources/icon.png')
    const mainWindow = new BrowserWindow({
        width: 900,
        height: 670,
        show: false,
        autoHideMenuBar: true,
        frame: false, // Make the window frameless
        alwaysOnTop: true, // Default to true based on user requirement
        icon: electron.nativeImage.createFromPath(iconPath),
        webPreferences: {
            preload: join(__dirname, '../preload/index.js'),
            sandbox: false,
            contextIsolation: true,
            webviewTag: true // Enable webview tag for the browser functionality
        }
    })

    // Better Wayland compatibility for visible on all workspaces
    mainWindow.setVisibleOnAllWorkspaces(true, {
        visibleOnFullScreen: true,
        skipTransformProcessType: true
    })

    mainWindow.on('ready-to-show', () => {
        console.log('Window ready-to-show event fired')
        mainWindow.show()

        // Wayland sometimes needs a small delay after show to respect alwaysOnTop
        setTimeout(() => {
            mainWindow.setAlwaysOnTop(true)
        }, 200)
    })



    mainWindow.webContents.setWindowOpenHandler((details) => {
        shell.openExternal(details.url)
        return { action: 'deny' }
    })


    // HMR for renderer base on electron-vite cli.
    // Load the remote URL for development or the local html file for production.
    if (is.dev && process.env['ELECTRON_RENDERER_URL']) {
        mainWindow.loadURL(process.env['ELECTRON_RENDERER_URL'])
    } else {
        mainWindow.loadFile(join(__dirname, '../renderer/index.html'))
    }

    // Always on top toggle IPC
    ipcMain.handle('toggle-always-on-top', () => {
        const isAlwaysOnTop = mainWindow.isAlwaysOnTop()
        const newState = !isAlwaysOnTop

        mainWindow.setAlwaysOnTop(newState)

        return newState
    })

    ipcMain.handle('get-always-on-top', () => {
        return mainWindow.isAlwaysOnTop()
    })

    // Persistence IPC
    ipcMain.handle('get-urls', () => {
        return store.get('urls') || []
    })

    ipcMain.handle('save-urls', (_, urls) => {
        store.set('urls', urls)
        return true
    })

    // App Version IPC
    ipcMain.handle('get-app-version', () => {
        return app.getVersion()
    })

    // App Quit IPC
    ipcMain.handle('quit-app', () => {
        app.quit()
    })
}

// Global Context Menu (Keep for general usability)
app.on('web-contents-created', (_, contents) => {
    contents.on('context-menu', (_, params) => {
        const menu = Menu.buildFromTemplate([
            { label: 'Cut', role: 'cut' },
            { label: 'Copy', role: 'copy' },
            { label: 'Paste', role: 'paste' },
            { type: 'separator' },
            { label: 'Inspect Element', click: () => contents.inspectElement(params.x, params.y) }
        ])
        menu.popup()
    })
})

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
    // Set app user model id for windows
    electronApp.setAppUserModelId('com.victorradael.minibrowser')

    // Default open or close DevTools by F12 in development
    // and ignore CommandOrControl + R in production.
    // see https://github.com/alex8088/electron-toolkit/tree/master/packages/utils
    app.on('browser-window-created', (_, window) => {
        optimizer.watchWindowShortcuts(window)
    })

    createWindow()

    app.on('activate', function () {
        // On macOS it's common to re-create a window in the app when the
        // dock icon is clicked and there are no other windows open.
        if (BrowserWindow.getAllWindows().length === 0) createWindow()
    })

    console.log('App ready, createWindow called')
})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit()
    }
})
