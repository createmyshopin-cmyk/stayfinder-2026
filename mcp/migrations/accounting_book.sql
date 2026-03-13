-- MCP Migration: Accounting Book (main tables)
-- Use with Supabase MCP apply_migration or paste in SQL Editor
-- Project: rqnxtcigfauzzjaqxzut

-- accounting_transactions: central ledger
CREATE TABLE IF NOT EXISTS public.accounting_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('income', 'expense', 'commission')),
  category text NOT NULL DEFAULT 'general',
  description text NOT NULL DEFAULT '',
  amount integer NOT NULL DEFAULT 0,
  date date NOT NULL DEFAULT CURRENT_DATE,
  booking_id uuid REFERENCES public.bookings(id) ON DELETE SET NULL,
  invoice_id uuid REFERENCES public.invoices(id) ON DELETE SET NULL,
  quotation_id uuid REFERENCES public.quotations(id) ON DELETE SET NULL,
  stay_id uuid REFERENCES public.stays(id) ON DELETE SET NULL,
  payment_method text DEFAULT 'cash',
  reference_number text DEFAULT '',
  notes text DEFAULT '',
  tags text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- booking_ledger_entries: per-booking custom bookkeeping
CREATE TABLE IF NOT EXISTS public.booking_ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  booking_id uuid NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  label text NOT NULL DEFAULT '',
  amount integer NOT NULL DEFAULT 0,
  type text NOT NULL CHECK (type IN ('income', 'expense', 'commission')) DEFAULT 'income',
  notes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.accounting_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_ledger_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tenant can manage own accounting_transactions" ON public.accounting_transactions;
CREATE POLICY "Tenant can manage own accounting_transactions"
  ON public.accounting_transactions FOR ALL
  USING (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id())
  WITH CHECK (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id());

DROP POLICY IF EXISTS "Tenant can manage own booking_ledger_entries" ON public.booking_ledger_entries;
CREATE POLICY "Tenant can manage own booking_ledger_entries"
  ON public.booking_ledger_entries FOR ALL
  USING (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id())
  WITH CHECK (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id());

CREATE INDEX IF NOT EXISTS idx_accounting_transactions_tenant ON public.accounting_transactions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_date ON public.accounting_transactions(date);
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_type ON public.accounting_transactions(type);
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_booking ON public.accounting_transactions(booking_id);
CREATE INDEX IF NOT EXISTS idx_booking_ledger_entries_booking ON public.booking_ledger_entries(booking_id);

COMMENT ON TABLE public.accounting_transactions IS 'Accounting Book: income, expense, commission ledger';
COMMENT ON TABLE public.booking_ledger_entries IS 'Per-booking custom bookkeeping entries';
