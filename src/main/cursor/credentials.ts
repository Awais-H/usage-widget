import { homedir } from 'node:os'
import { join } from 'node:path'
import Database from 'better-sqlite3'
import type { CursorCredentials } from '@shared/types'

const CURSOR_STATE_DB = join(
  homedir(),
  'Library/Application Support/Cursor/User/globalStorage/state.vscdb'
)

const AUTH_KEYS = {
  accessToken: 'cursorAuth/accessToken',
  email: 'cursorAuth/cachedEmail',
  membershipType: 'cursorAuth/stripeMembershipType',
  subscriptionStatus: 'cursorAuth/stripeSubscriptionStatus'
} as const

function readStateValue(db: Database.Database, key: string): string | null {
  const row = db
    .prepare('SELECT value FROM ItemTable WHERE key = ?')
    .get(key) as { value: string } | undefined

  if (!row?.value) {
    return null
  }

  try {
    return JSON.parse(row.value) as string
  } catch {
    return row.value
  }
}

export function readCursorCredentials(): CursorCredentials {
  try {
    const db = new Database(CURSOR_STATE_DB, { readonly: true, fileMustExist: true })

    try {
      return {
        accessToken: readStateValue(db, AUTH_KEYS.accessToken),
        email: readStateValue(db, AUTH_KEYS.email),
        membershipType: readStateValue(db, AUTH_KEYS.membershipType),
        subscriptionStatus: readStateValue(db, AUTH_KEYS.subscriptionStatus)
      }
    } finally {
      db.close()
    }
  } catch {
    return {
      accessToken: null,
      email: null,
      membershipType: null,
      subscriptionStatus: null
    }
  }
}
