-- Add Reels / Story display settings to the site_settings singleton
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS stories_enabled       boolean  DEFAULT true,
  ADD COLUMN IF NOT EXISTS stories_section_title text     DEFAULT 'Resort Stories',
  ADD COLUMN IF NOT EXISTS stories_duration      integer  DEFAULT 4,
  ADD COLUMN IF NOT EXISTS reels_enabled         boolean  DEFAULT true,
  ADD COLUMN IF NOT EXISTS reels_section_title   text     DEFAULT 'Resort Reels';

-- Add sort_order to stay_reels if not already present (it is, but guard anyway)
ALTER TABLE public.stay_reels
  ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0;
