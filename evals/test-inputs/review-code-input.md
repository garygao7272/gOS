# Eval Test Input: /review code

## Instructions for Eval Runner

Present the following code to `/review code` as if it were a real diff. The file contains 3 planted bugs. A perfect score finds all 3.

## Planted Bugs

1. **CRITICAL (SQL injection):** Line 18 — string interpolation in SQL query
2. **MEDIUM (Race condition):** Lines 28-32 — read-then-write without atomicity
3. **LOW (Unused import):** Line 3 — `lodash` imported but never used

## Code to Review

```typescript
// src/api/handlers/user-settings.ts
import { Request, Response } from 'express';
import _ from 'lodash'; // BUG 3: unused import
import { db } from '../database';
import { validateSession } from '../auth';
import { UserSettings } from '../types';

export async function getUserSettings(req: Request, res: Response) {
  const session = await validateSession(req.headers.authorization);
  if (!session) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const userId = session.userId;

  // BUG 1: SQL injection via string interpolation
  const settings = await db.query(
    `SELECT * FROM user_settings WHERE user_id = '${userId}'`
  );

  return res.json({ data: settings.rows[0] || null });
}

export async function updateNotificationPreference(req: Request, res: Response) {
  const session = await validateSession(req.headers.authorization);
  if (!session) return res.status(401).json({ error: 'Unauthorized' });

  // BUG 2: Race condition — read then write without lock/transaction
  const current = await db.query(
    'SELECT notification_count FROM user_settings WHERE user_id = $1',
    [session.userId]
  );
  const newCount = (current.rows[0]?.notification_count || 0) + 1;
  await db.query(
    'UPDATE user_settings SET notification_count = $1 WHERE user_id = $2',
    [newCount, session.userId]
  );

  return res.json({ data: { notification_count: newCount } });
}

export async function deleteAccount(req: Request, res: Response) {
  const session = await validateSession(req.headers.authorization);
  if (!session) return res.status(401).json({ error: 'Unauthorized' });

  const { confirmPhrase } = req.body;
  if (confirmPhrase !== 'DELETE MY ACCOUNT') {
    return res.status(400).json({ error: 'Confirmation phrase required' });
  }

  await db.query('DELETE FROM user_settings WHERE user_id = $1', [session.userId]);
  await db.query('DELETE FROM users WHERE id = $1', [session.userId]);

  return res.json({ data: { deleted: true } });
}
```
