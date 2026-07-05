import { contextBridge, ipcRenderer } from 'electron'
import type { UsageSnapshot } from '@shared/types'

contextBridge.exposeInMainWorld('usageWidget', {
  getUsage: (): Promise<UsageSnapshot> => ipcRenderer.invoke('usage:get'),
  refreshUsage: (): Promise<UsageSnapshot> => ipcRenderer.invoke('usage:refresh'),
  openDashboard: (): Promise<void> => ipcRenderer.invoke('usage:open-dashboard'),
  onUsageUpdated: (callback: (snapshot: UsageSnapshot) => void): (() => void) => {
    const listener = (_event: Electron.IpcRendererEvent, snapshot: UsageSnapshot): void => {
      callback(snapshot)
    }

    ipcRenderer.on('usage:updated', listener)
    return () => {
      ipcRenderer.removeListener('usage:updated', listener)
    }
  }
})
