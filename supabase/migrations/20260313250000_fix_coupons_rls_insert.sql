-- =============================================================================
-- Migration: Fix coupons RLS for INSERT with null tenant_id
-- Date: 2026-03-13
-- Issue: When tenant_id is NULL (e.g. localhost or Guest Contacts "Give Discount"),
--        is_tenant_admin(NULL) returns false and blocks the insert.
-- Fix: Use COALESCE(tenant_id, get_my_tenant_id()) so that when tenant_id is null,
--      we check if the user is admin of their own tenant (from user_id link).
-- =============================================================================

DROP POLICY IF EXISTS "Tenant admin can manage own coupons" ON public.coupons;

CREATE POLICY "Tenant admin can manage own coupons" ON public.coupons
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(COALESCE(tenant_id, public.get_my_tenant_id())))
  WITH CHECK (public.is_tenant_admin(COALESCE(tenant_id, public.get_my_tenant_id())));
