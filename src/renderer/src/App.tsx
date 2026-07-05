import { useCallback, useEffect, useState, type ReactElement } from 'react'
import type { UsageSnapshot } from '@shared/types'
import { UsagePanel } from './components/UsagePanel'

const emptySnapshot: UsageSnapshot = {
  source: 'demo',
  plan: 'Loading',
  email: null,
  subscriptionStatus: null,
  billingCycleEndsAt: null,
  metrics: [],
  updatedAt: new Date().toISOString()
}

export default function App(): ReactElement {
  const [snapshot, setSnapshot] = useState<UsageSnapshot>(emptySnapshot)
  const [loading, setLoading] = useState(true)

  const loadUsage = useCallback(async () => {
    setLoading(true)

    try {
      const next = await window.usageWidget.getUsage()
      setSnapshot(next)
    } finally {
      setLoading(false)
    }
  }, [])

  const refreshUsage = useCallback(async () => {
    setLoading(true)

    try {
      const next = await window.usageWidget.refreshUsage()
      setSnapshot(next)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void loadUsage()

    const unsubscribe = window.usageWidget.onUsageUpdated((next) => {
      setSnapshot(next)
      setLoading(false)
    })

    return unsubscribe
  }, [loadUsage])

  return (
    <main className="min-h-screen bg-transparent p-3">
      <UsagePanel
        snapshot={snapshot}
        loading={loading}
        onRefresh={() => {
          void refreshUsage()
        }}
        onOpenDashboard={() => {
          void window.usageWidget.openDashboard()
        }}
      />
    </main>
  )
}
