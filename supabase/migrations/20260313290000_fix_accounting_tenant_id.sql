-- Fix: accounting_transactions may have been created without tenant_id (e.g. partial migration).
-- Add column if missing, then ensure RLS policy exists.
ALTER TABLE public.accounting_transactions
  ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.booking_ledger_entries
  ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

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
