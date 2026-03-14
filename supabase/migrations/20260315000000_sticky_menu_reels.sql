-- Add Reels to Sticky Bottom Menu settings
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS sticky_menu_show_reels boolean NOT NULL DEFAULT true;
