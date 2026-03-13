
-- Reviews table
CREATE TABLE public.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id uuid REFERENCES public.stays(id) ON DELETE CASCADE NOT NULL,
  guest_name text NOT NULL,
  rating integer NOT NULL DEFAULT 5,
  comment text NOT NULL DEFAULT '',
  avatar_url text,
  photos text[] NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage reviews" ON public.reviews FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view approved reviews" ON public.reviews FOR SELECT USING (status = 'approved');
CREATE POLICY "Public can submit reviews" ON public.reviews FOR INSERT WITH CHECK (true);

-- Media gallery table
CREATE TABLE public.media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  url text NOT NULL,
  alt_text text NOT NULL DEFAULT '',
  category text NOT NULL DEFAULT 'general',
  stay_id uuid REFERENCES public.stays(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage media" ON public.media FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view media" ON public.media FOR SELECT USING (true);

-- Site settings table (singleton)
CREATE TABLE public.site_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_name text NOT NULL DEFAULT 'StayFinder',
  contact_email text NOT NULL DEFAULT '',
  contact_phone text NOT NULL DEFAULT '',
  whatsapp_number text NOT NULL DEFAULT '',
  address text NOT NULL DEFAULT '',
  social_instagram text NOT NULL DEFAULT '',
  social_facebook text NOT NULL DEFAULT '',
  social_youtube text NOT NULL DEFAULT '',
  currency text NOT NULL DEFAULT 'INR',
  booking_enabled boolean NOT NULL DEFAULT true,
  maintenance_mode boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage site_settings" ON public.site_settings FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can read site_settings" ON public.site_settings FOR SELECT USING (true);

INSERT INTO public.site_settings (id) VALUES (gen_random_uuid());
