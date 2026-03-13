
-- Add columns to tenant_domains
ALTER TABLE public.tenant_domains ADD COLUMN IF NOT EXISTS registrar text NOT NULL DEFAULT '';
ALTER TABLE public.tenant_domains ADD COLUMN IF NOT EXISTS auto_configured boolean NOT NULL DEFAULT false;

-- Create tenant_registrar_keys table
CREATE TABLE public.tenant_registrar_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  registrar text NOT NULL DEFAULT '',
  api_key text NOT NULL DEFAULT '',
  api_secret text NOT NULL DEFAULT '',
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, registrar)
);

ALTER TABLE public.tenant_registrar_keys ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage registrar keys"
ON public.tenant_registrar_keys
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));
