/// <reference types="vite/client" />

import type { UsageWidgetAPI } from '@shared/types'

declare global {
  interface Window {
    usageWidget: UsageWidgetAPI
  }
}

export {}
