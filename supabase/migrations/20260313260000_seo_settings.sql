-- Add SEO fields to site_settings for meta tags and Open Graph
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS meta_title text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS meta_description text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS meta_keywords text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS og_image_url text,
  ADD COLUMN IF NOT EXISTS og_title text,
  ADD COLUMN IF NOT EXISTS og_description text;
