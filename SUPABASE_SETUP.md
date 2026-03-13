# Supabase Database Setup (STAY UI)

Project: **rqnxtcigfauzzjaqxzut**  
Dashboard: https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut

---

## Prerequisites

1. **Supabase CLI** installed:
   ```bash
   npm install -g supabase
   ```
   Or: https://supabase.com/docs/guides/cli

2. **Logged in** to Supabase CLI:
   ```bash
   supabase login
   ```

---

## Migrate All Database Tables

### Option A: Supabase CLI (recommended)

From the project root:

```bash
# 1. Link to your remote project (one-time)
npm run db:link
# Enter your database password when prompted (Project Settings → Database → Connection string)

# 2. Push all 34 migrations
npm run db:push
```

Or directly:
```bash
supabase link --project-ref rqnxtcigfauzzjaqxzut
supabase db push
```

### Option B: Single SQL file (manual)

1. Run `npm run db:consolidate` to generate `supabase/FULL_MIGRATION.sql`
2. Go to [Supabase SQL Editor](https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/sql/new)
3. Open `supabase/FULL_MIGRATION.sql`, copy all content, paste into the editor, and **Run**

### Option C: Run migrations one by one (if single file fails)

1. Go to [Supabase SQL Editor](https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/sql/new)
2. Run each migration file **in order** (oldest first). Migration order:

   | Order | File |
   |-------|------|
   | 1 | 20260308164058 |
   | 2 | 20260308164820 |
   | 3 | 20260308171055 |
   | 4 | 20260308171747 |
   | 5 | 20260308172029 |
   | 6 | 20260308172942 |
   | 7 | 20260308173348 |
   | 8 | 20260308175256 |
   | 9 | 20260308180015 |
   | 10 | 20260308181418 |
   | 11 | 20260308181953 |
   | 12 | 20260308182921 |
   | 13 | 20260308185205 |
   | 14 | 20260308185958 |
   | 15 | 20260308190220 |
   | 16 | 20260308192629 |
   | 17 | 20260308193608 |
   | 18 | 20260308194724 |
   | 19 | 20260308202709 |
   | 20 | 20260308204011 |
   | 21 | 20260309032316 |
   | 22 | 20260309033027 |
   | 23 | 20260309033356 |
   | 24 | 20260309043101 |
   | 25 | 20260309043550 |
   | 26 | 20260309043916 |
   | 27 | 20260309044810 |
   | 28 | 20260309045353 |
   | 29 | 20260309050158 |
   | 30 | 20260313001000 (schema_extension_rls_audit) |
   | 31 | 20260313100000 (story_reel_settings) |
   | 32 | 20260313200000 (coupon_enhancements) |
   | 33 | 20260313210000 (stays_cooldown_hours) |
   | 34 | 20260313220000 (accounting_book) |

---

## After Migration

- **Auth**: Configure Auth providers in Dashboard → Authentication → Providers
- **Storage**: Buckets `stay-images`, `branding` are created by migrations
- **RLS**: All tables have Row Level Security policies

---

## Useful Commands

| Command | Purpose |
|---------|---------|
| `npm run db:link` | Link to remote Supabase project |
| `npm run db:push` | Apply all migrations |
| `npm run db:reset` | Reset local DB (local dev only) |
| `supabase gen types typescript` | Regenerate TypeScript types |
