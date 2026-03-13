-- Auto-generate invoice on new booking
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS auto_generate_invoice boolean NOT NULL DEFAULT false;
