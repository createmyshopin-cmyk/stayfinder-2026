-- Add SEO columns to stays for per-stay meta tags and rich snippets
ALTER TABLE public.stays
  ADD COLUMN IF NOT EXISTS seo_title text,
  ADD COLUMN IF NOT EXISTS seo_description text,
  ADD COLUMN IF NOT EXISTS seo_keywords text,
  ADD COLUMN IF NOT EXISTS og_image_url text;
