import type { CursorCredentials, UsageMetric, UsageSnapshot } from '@shared/types'

const USAGE_ENDPOINTS = [
  'https://www.cursor.com/api/usage',
  'https://api2.cursor.sh/aiserver.v1.DashboardService/GetUsageSummary'
]

interface RawUsageResponse {
  autoPercentUsed?: number
  apiPercentUsed?: number
  totalPercentUsed?: number
  premiumRequestsUsed?: number
  premiumRequestsLimit?: number
  fastRequestsUsed?: number
  fastRequestsLimit?: number
  slowRequestsUsed?: number
  slowRequestsLimit?: number
  billingCycleEnd?: string
  billingCycleEndsAt?: string
  plan?: string
}

function clampPercent(value: number): number {
  return Math.max(0, Math.min(100, value))
}

function buildMetrics(data: RawUsageResponse): UsageMetric[] {
  const metrics: UsageMetric[] = []

  if (typeof data.autoPercentUsed === 'number') {
    metrics.push({
      label: 'Auto',
      usedPercent: clampPercent(data.autoPercentUsed),
      detail: 'Included agent usage'
    })
  }

  if (typeof data.apiPercentUsed === 'number') {
    metrics.push({
      label: 'API',
      usedPercent: clampPercent(data.apiPercentUsed),
      detail: 'Included API usage'
    })
  }

  if (typeof data.totalPercentUsed === 'number') {
    metrics.push({
      label: 'Total',
      usedPercent: clampPercent(data.totalPercentUsed),
      detail: 'Combined plan usage'
    })
  }

  if (
    typeof data.premiumRequestsUsed === 'number' &&
    typeof data.premiumRequestsLimit === 'number'
  ) {
    const usedPercent =
      data.premiumRequestsLimit === 0
        ? 0
        : (data.premiumRequestsUsed / data.premiumRequestsLimit) * 100

    metrics.push({
      label: 'Premium requests',
      usedPercent: clampPercent(usedPercent),
      detail: `${data.premiumRequestsUsed} / ${data.premiumRequestsLimit}`
    })
  }

  if (typeof data.fastRequestsUsed === 'number' && typeof data.fastRequestsLimit === 'number') {
    const usedPercent =
      data.fastRequestsLimit === 0 ? 0 : (data.fastRequestsUsed / data.fastRequestsLimit) * 100

    metrics.push({
      label: 'Fast requests',
      usedPercent: clampPercent(usedPercent),
      detail: `${data.fastRequestsUsed} / ${data.fastRequestsLimit}`
    })
  }

  return metrics
}

function demoSnapshot(credentials: CursorCredentials): UsageSnapshot {
  const plan = credentials.membershipType ?? 'Pro'

  return {
    source: 'demo',
    plan,
    email: credentials.email,
    subscriptionStatus: credentials.subscriptionStatus,
    billingCycleEndsAt: null,
    updatedAt: new Date().toISOString(),
    metrics: [
      { label: 'Auto', usedPercent: 42, detail: 'Demo data' },
      { label: 'API', usedPercent: 18, detail: 'Demo data' },
      { label: 'Total', usedPercent: 35, detail: 'Demo data' }
    ],
    error: credentials.accessToken
      ? 'Could not reach Cursor usage API. Showing demo data.'
      : 'Sign in to Cursor to load live usage.'
  }
}

async function fetchFromEndpoint(
  endpoint: string,
  accessToken: string
): Promise<RawUsageResponse | null> {
  const response = await fetch(endpoint, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    }
  })

  if (!response.ok) {
    return null
  }

  return (await response.json()) as RawUsageResponse
}

export async function fetchUsageSnapshot(
  credentials: CursorCredentials
): Promise<UsageSnapshot> {
  if (!credentials.accessToken) {
    return demoSnapshot(credentials)
  }

  for (const endpoint of USAGE_ENDPOINTS) {
    try {
      const data = await fetchFromEndpoint(endpoint, credentials.accessToken)
      if (!data) {
        continue
      }

      const metrics = buildMetrics(data)
      if (metrics.length === 0) {
        continue
      }

      return {
        source: 'live',
        plan: data.plan ?? credentials.membershipType ?? 'Unknown',
        email: credentials.email,
        subscriptionStatus: credentials.subscriptionStatus,
        billingCycleEndsAt: data.billingCycleEndsAt ?? data.billingCycleEnd ?? null,
        metrics,
        updatedAt: new Date().toISOString()
      }
    } catch {
      continue
    }
  }

  return demoSnapshot(credentials)
}
