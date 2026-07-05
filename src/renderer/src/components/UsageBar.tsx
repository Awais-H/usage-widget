import type { ReactElement } from 'react'
import { cn } from '../lib/utils'

interface UsageBarProps {
  label: string
  usedPercent: number
  detail?: string
}

export function UsageBar({ label, usedPercent, detail }: UsageBarProps): ReactElement {
  const tone =
    usedPercent >= 90 ? 'bg-red-500' : usedPercent >= 70 ? 'bg-amber-400' : 'bg-accent'

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between text-sm">
        <span className="font-medium text-white">{label}</span>
        <span className="text-muted">{Math.round(usedPercent)}%</span>
      </div>
      <div className="h-2 overflow-hidden rounded-full bg-white/10">
        <div
          className={cn('h-full rounded-full transition-all duration-300', tone)}
          style={{ width: `${Math.min(100, usedPercent)}%` }}
        />
      </div>
      {detail ? <p className="text-xs text-muted">{detail}</p> : null}
    </div>
  )
}
