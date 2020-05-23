const { app, BrowserWindow, globalShortcut, webContents } = require("electron");
const { url } = require("./config");

let window;

function createWindow() {
  window = new BrowserWindow({
    width: 800,
    heigh: 600,
    titleBarStyle: "hidden",
    autoHideMenuBar: true,
    alwaysOnTop: true,
    backgroundColor: "#333",
    darkTheme: true,
    webPreferences: {
      nodeIntegration: true,
    },
  });
  // window.loadFile("./index.html");
  window.loadURL(url);
  0;
}

function toggleDevTolls() {
  window.webContents.openDevTools();
}

function createShortcuts() {
  globalShortcut.register("CmdOrCtrl+J", toggleDevTolls);
}

app.whenReady().then(createWindow).then(createShortcuts);

app.on("window-all-closed", () => {
  if (process.platform === "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
