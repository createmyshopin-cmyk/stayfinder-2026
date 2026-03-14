-- Auto-verify new signup: when enabled, new tenant signups get verified subdomain instantly
INSERT INTO public.saas_platform_settings (setting_key, setting_value)
VALUES ('signup_auto_verify', 'false')
ON CONFLICT (setting_key) DO NOTHING;
