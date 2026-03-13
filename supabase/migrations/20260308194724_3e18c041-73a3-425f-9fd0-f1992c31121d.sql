CREATE TABLE public.saas_platform_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key text NOT NULL UNIQUE,
  setting_value text NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.saas_platform_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Super admins can manage platform settings"
  ON public.saas_platform_settings
  FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'super_admin'::app_role));

INSERT INTO public.saas_platform_settings (setting_key, setting_value) VALUES
  ('entri_application_id', ''),
  ('entri_secret', '');
