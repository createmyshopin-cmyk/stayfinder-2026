-- Ensure stays has SEO columns (in case 20260313270000_stays_seo.sql wasn't applied)
ALTER TABLE public.stays ADD COLUMN IF NOT EXISTS seo_title text;
ALTER TABLE public.stays ADD COLUMN IF NOT EXISTS seo_description text;
ALTER TABLE public.stays ADD COLUMN IF NOT EXISTS seo_keywords text;
ALTER TABLE public.stays ADD COLUMN IF NOT EXISTS og_image_url text;
