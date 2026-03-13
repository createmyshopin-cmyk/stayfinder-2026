# Supabase MCP Migrations

Use these with **Supabase MCP** (`execute_sql` or `apply_migration`) once authenticated.

## Quick apply via MCP

After authenticating Supabase MCP (Settings → Tools & MCP → supabase STAY):

1. **List tables**: "What tables are in the database?"
2. **Run migration**: "Execute the SQL in mcp/migrations/accounting_book.sql"

Or paste the SQL directly into Supabase SQL Editor:  
https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/editor

## Migrations

| File | Purpose |
|------|---------|
| `migrations/accounting_book.sql` | Accounting Book tables (accounting_transactions, booking_ledger_entries) |

**Prerequisites**: `tenants`, `bookings`, `invoices`, `quotations`, `stays`, and `get_my_tenant_id()` must exist. Run base schema migrations first if needed.
