-- Ensure site_settings has SEO columns (in case 20260313260000_seo_settings.sql wasn't applied)
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS meta_title text NOT NULL DEFAULT '';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS meta_description text NOT NULL DEFAULT '';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS meta_keywords text NOT NULL DEFAULT '';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS og_image_url text;
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS og_title text;
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS og_description text;
