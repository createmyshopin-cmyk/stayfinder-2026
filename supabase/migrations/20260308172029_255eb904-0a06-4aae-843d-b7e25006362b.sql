
ALTER TABLE public.site_settings
  ADD COLUMN sticky_menu_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN sticky_menu_show_ai boolean NOT NULL DEFAULT true,
  ADD COLUMN sticky_menu_show_wishlist boolean NOT NULL DEFAULT true,
  ADD COLUMN sticky_menu_show_explore boolean NOT NULL DEFAULT true;
