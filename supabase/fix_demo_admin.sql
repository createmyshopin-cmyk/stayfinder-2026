-- =============================================================================
-- Fix Demo Admin: grant admin role + confirm email + create tenant
-- Run in Supabase SQL Editor
-- =============================================================================

-- 1. Add user_id to tenants if missing (required for get_my_tenant_id)
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_tenants_user_id ON public.tenants(user_id);

-- 2. Ensure get_my_tenant_id() exists
CREATE OR REPLACE FUNCTION public.get_my_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.tenants WHERE user_id = auth.uid() LIMIT 1;
$$;

-- 3. Fix demo admin and create tenant
DO $$
DECLARE
  v_user_id uuid;
  v_tenant_id uuid;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'admin@admin.com' LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'No user found. Run seed_demo_admin.sql first.';
    RETURN;
  END IF;

  -- Confirm email
  UPDATE auth.users SET email_confirmed_at = now() WHERE id = v_user_id;

  -- Grant admin role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (v_user_id, 'admin')
  ON CONFLICT (user_id, role) DO NOTHING;

  -- Find or create tenant for this user
  SELECT id INTO v_tenant_id FROM public.tenants WHERE user_id = v_user_id OR email = 'admin@admin.com' LIMIT 1;

  IF v_tenant_id IS NULL THEN
    INSERT INTO public.tenants (tenant_name, owner_name, email, domain, status, user_id)
    VALUES ('Demo Resort', 'Demo Admin', 'admin@admin.com', 'demo-resort', 'trial', v_user_id)
    RETURNING id INTO v_tenant_id;

    INSERT INTO public.tenant_domains (tenant_id, subdomain) VALUES (v_tenant_id, 'demo-resort');

    INSERT INTO public.tenant_usage (tenant_id) VALUES (v_tenant_id)
    ON CONFLICT (tenant_id) DO NOTHING;
  ELSE
    UPDATE public.tenants SET user_id = v_user_id WHERE id = v_tenant_id;
  END IF;

  RAISE NOTICE 'Demo admin fixed with tenant. Log in with admin@admin.com / admin.com';
END $$;

-- 4. Fix tenant_domains RLS — allow tenant admins to manage own domains
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'tenant_domains' AND policyname = 'Tenant can manage own domains'
  ) THEN
    EXECUTE $p$
      CREATE POLICY "Tenant can manage own domains"
        ON public.tenant_domains FOR ALL TO authenticated
        USING (tenant_id = public.get_my_tenant_id())
        WITH CHECK (tenant_id = public.get_my_tenant_id())
    $p$;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'tenant_registrar_keys' AND policyname = 'Tenant can manage own registrar keys'
  ) THEN
    EXECUTE $p$
      CREATE POLICY "Tenant can manage own registrar keys"
        ON public.tenant_registrar_keys FOR ALL TO authenticated
        USING (tenant_id = public.get_my_tenant_id())
        WITH CHECK (tenant_id = public.get_my_tenant_id())
    $p$;
  END IF;
END $$;

-- 5. Demo upgrade RPC (for testing when Edge Functions are not deployed)
CREATE OR REPLACE FUNCTION public.demo_upgrade_plan(p_tenant_id uuid, p_plan_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_my_tenant uuid;
  v_has_sub boolean;
BEGIN
  v_my_tenant := get_my_tenant_id();
  IF v_my_tenant IS NULL OR v_my_tenant != p_tenant_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authorized for this tenant');
  END IF;

  UPDATE public.tenants SET plan_id = p_plan_id, status = 'active' WHERE id = p_tenant_id;

  UPDATE public.subscriptions SET plan_id = p_plan_id, status = 'active', renewal_date = CURRENT_DATE + 30
  WHERE tenant_id = p_tenant_id;

  IF NOT FOUND THEN
    INSERT INTO public.subscriptions (tenant_id, plan_id, status, billing_cycle, renewal_date)
    VALUES (p_tenant_id, p_plan_id, 'active', 'monthly', CURRENT_DATE + 30);
  END IF;

  RETURN jsonb_build_object('success', true);
END;
$$;
