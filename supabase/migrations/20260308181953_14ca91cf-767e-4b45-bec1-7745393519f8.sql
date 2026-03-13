
CREATE TABLE public.tenant_domains (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE NOT NULL,
  subdomain text NOT NULL DEFAULT '',
  custom_domain text NOT NULL DEFAULT '',
  ssl_status text NOT NULL DEFAULT 'pending',
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.tenant_domains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage tenant_domains" ON public.tenant_domains FOR ALL USING (has_role(auth.uid(), 'super_admin'));
CREATE POLICY "Public can read verified domains" ON public.tenant_domains FOR SELECT USING (verified = true);

CREATE UNIQUE INDEX idx_tenant_domains_subdomain ON public.tenant_domains(subdomain) WHERE subdomain != '';
CREATE UNIQUE INDEX idx_tenant_domains_custom ON public.tenant_domains(custom_domain) WHERE custom_domain != '';
