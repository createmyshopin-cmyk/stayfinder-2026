-- Add SEO columns to tenants for per-tenant (white-label) SEO defaults
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS seo_title text,
  ADD COLUMN IF NOT EXISTS seo_description text,
  ADD COLUMN IF NOT EXISTS seo_keywords text,
  ADD COLUMN IF NOT EXISTS og_image_url text;
