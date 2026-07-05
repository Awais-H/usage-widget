import { app, BrowserWindow, Tray, Menu, nativeImage, shell, ipcMain } from 'electron'
import { join } from 'node:path'
import { readCursorCredentials } from './cursor/credentials'
import { fetchUsageSnapshot } from './cursor/usage'
import type { UsageSnapshot } from '@shared/types'

const PANEL_WIDTH = 320
const PANEL_HEIGHT = 420
const REFRESH_INTERVAL_MS = 60_000

let tray: Tray | null = null
let panel: BrowserWindow | null = null
let latestSnapshot: UsageSnapshot | null = null

function getTrayIcon(): Electron.NativeImage {
  const png =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAQAAACXBpU6AAAAIElEQVR42mP8z8BQz0AEYBxVSF+FAP5/AQhAAQ0qV8QAAAAASUVORK5CYII='

  return nativeImage.createFromDataURL(png).resize({ width: 18, height: 18 })
}

function createPanel(): BrowserWindow {
  const window = new BrowserWindow({
    width: PANEL_WIDTH,
    height: PANEL_HEIGHT,
    show: false,
    frame: false,
    resizable: false,
    fullscreenable: false,
    skipTaskbar: true,
    transparent: true,
    vibrancy: 'under-window',
    visualEffectState: 'active',
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  })

  if (process.env.ELECTRON_RENDERER_URL) {
    window.loadURL(`${process.env.ELECTRON_RENDERER_URL}`)
  } else {
    window.loadFile(join(__dirname, '../renderer/index.html'))
  }

  window.on('blur', () => {
    window.hide()
  })

  return window
}

function positionPanel(): void {
  if (!tray || !panel) {
    return
  }

  const trayBounds = tray.getBounds()
  const panelBounds = panel.getBounds()
  const x = Math.round(trayBounds.x + trayBounds.width / 2 - panelBounds.width / 2)
  const y = Math.round(trayBounds.y + trayBounds.height + 4)

  panel.setPosition(x, y, false)
}

async function refreshUsage(): Promise<UsageSnapshot> {
  latestSnapshot = await fetchUsageSnapshot(readCursorCredentials())
  panel?.webContents.send('usage:updated', latestSnapshot)
  return latestSnapshot
}

function togglePanel(): void {
  if (!panel) {
    return
  }

  if (panel.isVisible()) {
    panel.hide()
    return
  }

  positionPanel()
  panel.show()
  panel.focus()
}

app.whenReady().then(async () => {
  app.dock?.hide()

  panel = createPanel()
  tray = new Tray(getTrayIcon())
  tray.setToolTip('Cursor Usage')

  tray.setContextMenu(
    Menu.buildFromTemplate([
      {
        label: 'Refresh',
        click: () => {
          void refreshUsage()
        }
      },
      {
        label: 'Open Cursor Dashboard',
        click: () => {
          void shell.openExternal('https://cursor.com/settings')
        }
      },
      { type: 'separator' },
      {
        label: 'Quit',
        click: () => {
          app.quit()
        }
      }
    ])
  )

  tray.on('click', togglePanel)

  ipcMain.handle('usage:get', () => latestSnapshot ?? fetchUsageSnapshot(readCursorCredentials()))
  ipcMain.handle('usage:refresh', () => refreshUsage())
  ipcMain.handle('usage:open-dashboard', () => shell.openExternal('https://cursor.com/settings'))

  await refreshUsage()
  setInterval(() => {
    void refreshUsage()
  }, REFRESH_INTERVAL_MS)
})

app.on('window-all-closed', (event) => {
  event.preventDefault()
})
