-- Fix platform DNS configuration to use correct Vercel DNS values

INSERT INTO public.saas_platform_settings (setting_key, setting_value)
VALUES
  ('platform_base_domain',      'travelvoo.in'),
  ('platform_cname_target',     'cname.vercel-dns.com'),
  ('platform_a_record_ip',      '216.198.79.1'),
  ('platform_subdomain_suffix', '.travelvoo.in'),
  ('platform_dns_ttl',          '600')
ON CONFLICT (setting_key) DO UPDATE
  SET setting_value = EXCLUDED.setting_value,
      updated_at    = now();
