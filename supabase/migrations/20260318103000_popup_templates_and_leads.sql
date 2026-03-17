-- Add template support to popup settings
ALTER TABLE public.popup_settings
  ADD COLUMN IF NOT EXISTS template_type text NOT NULL DEFAULT 'lead',
  ADD COLUMN IF NOT EXISTS primary_color text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS background_color text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS subtitle text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stats_text text NOT NULL DEFAULT '';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'popup_settings_template_type_check'
  ) THEN
    ALTER TABLE public.popup_settings
      ADD CONSTRAINT popup_settings_template_type_check
      CHECK (template_type IN ('lead', 'coupon', 'offer', 'stats', 'announcement'));
  END IF;
END $$;

-- Leads captured from popup templates
CREATE TABLE IF NOT EXISTS public.leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  source text NOT NULL DEFAULT 'popup',
  full_name text NOT NULL,
  phone text NOT NULL,
  email text NOT NULL DEFAULT '',
  message text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'new',
  meta jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'leads_status_check'
  ) THEN
    ALTER TABLE public.leads
      ADD CONSTRAINT leads_status_check
      CHECK (status IN ('new', 'contacted', 'converted', 'lost'));
  END IF;
END $$;

ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage leads" ON public.leads;
CREATE POLICY "Admins can manage leads"
  ON public.leads
  FOR ALL
  USING (public.is_tenant_admin(COALESCE(tenant_id, public.get_my_tenant_id())))
  WITH CHECK (public.is_tenant_admin(COALESCE(tenant_id, public.get_my_tenant_id())));

