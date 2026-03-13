-- Fix: tenant_domains RLS — allow tenant admins to manage own domains
-- Run in Supabase SQL Editor → https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/sql

CREATE POLICY "Tenant can manage own domains"
  ON public.tenant_domains FOR ALL TO authenticated
  USING (tenant_id = public.get_my_tenant_id())
  WITH CHECK (tenant_id = public.get_my_tenant_id());

CREATE POLICY "Tenant can manage own registrar keys"
  ON public.tenant_registrar_keys FOR ALL TO authenticated
  USING (tenant_id = public.get_my_tenant_id())
  WITH CHECK (tenant_id = public.get_my_tenant_id());
