export interface CursorCredentials {
  accessToken: string | null
  email: string | null
  membershipType: string | null
  subscriptionStatus: string | null
}

export interface UsageMetric {
  label: string
  usedPercent: number
  detail?: string
}

export interface UsageSnapshot {
  source: 'live' | 'demo'
  plan: string
  email: string | null
  subscriptionStatus: string | null
  billingCycleEndsAt: string | null
  metrics: UsageMetric[]
  updatedAt: string
  error?: string
}

export interface UsageWidgetAPI {
  getUsage: () => Promise<UsageSnapshot>
  refreshUsage: () => Promise<UsageSnapshot>
  openDashboard: () => Promise<void>
  onUsageUpdated: (callback: (snapshot: UsageSnapshot) => void) => () => void
}

declare global {
  interface Window {
    usageWidget: UsageWidgetAPI
  }
}
