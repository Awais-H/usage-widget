import type { ReactElement } from 'react'
import type { UsageSnapshot } from '@shared/types'
import { formatPlanLabel, formatUpdatedAt } from '../lib/utils'
import { UsageBar } from './UsageBar'

interface UsagePanelProps {
  snapshot: UsageSnapshot
  loading: boolean
  onRefresh: () => void
  onOpenDashboard: () => void
}

export function UsagePanel({
  snapshot,
  loading,
  onRefresh,
  onOpenDashboard
}: UsagePanelProps): ReactElement {
  return (
    <div className="rounded-2xl border border-border bg-panel/95 p-4 shadow-2xl backdrop-blur-xl">
      <div className="mb-4 flex items-start justify-between gap-3">
        <div>
          <p className="text-xs uppercase tracking-[0.2em] text-muted">Cursor Usage</p>
          <h1 className="mt-1 text-lg font-semibold text-white">{formatPlanLabel(snapshot.plan)}</h1>
          {snapshot.email ? <p className="text-sm text-muted">{snapshot.email}</p> : null}
        </div>
        <span
          className={`rounded-full px-2 py-1 text-[10px] font-medium uppercase tracking-wide ${
            snapshot.source === 'live'
              ? 'bg-emerald-500/15 text-emerald-300'
              : 'bg-amber-500/15 text-amber-300'
          }`}
        >
          {snapshot.source}
        </span>
      </div>

      <div className="space-y-4">
        {snapshot.metrics.map((metric) => (
          <UsageBar
            key={metric.label}
            label={metric.label}
            usedPercent={metric.usedPercent}
            detail={metric.detail}
          />
        ))}
      </div>

      {snapshot.error ? (
        <p className="mt-4 rounded-xl border border-amber-500/20 bg-amber-500/10 px-3 py-2 text-xs text-amber-200">
          {snapshot.error}
        </p>
      ) : null}

      <div className="mt-4 flex items-center justify-between text-xs text-muted">
        <span>Updated {formatUpdatedAt(snapshot.updatedAt)}</span>
        {snapshot.subscriptionStatus ? <span>{snapshot.subscriptionStatus}</span> : null}
      </div>

      <div className="mt-4 grid grid-cols-2 gap-2">
        <button
          type="button"
          onClick={onRefresh}
          disabled={loading}
          className="rounded-xl border border-border bg-white/5 px-3 py-2 text-sm text-white transition hover:bg-white/10 disabled:opacity-50"
        >
          {loading ? 'Refreshing…' : 'Refresh'}
        </button>
        <button
          type="button"
          onClick={onOpenDashboard}
          className="rounded-xl bg-accent px-3 py-2 text-sm font-medium text-white transition hover:bg-indigo-500"
        >
          Dashboard
        </button>
      </div>
    </div>
  )
}
