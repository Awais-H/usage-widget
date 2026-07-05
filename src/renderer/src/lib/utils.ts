export function cn(...classes: Array<string | false | null | undefined>): string {
  return classes.filter(Boolean).join(' ')
}

export function formatPlanLabel(plan: string): string {
  if (!plan) {
    return 'Unknown'
  }

  return plan.charAt(0).toUpperCase() + plan.slice(1)
}

export function formatUpdatedAt(isoDate: string): string {
  return new Intl.DateTimeFormat(undefined, {
    hour: 'numeric',
    minute: '2-digit'
  }).format(new Date(isoDate))
}
