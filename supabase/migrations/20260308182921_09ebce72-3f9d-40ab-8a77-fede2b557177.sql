
-- calendar_pricing table
CREATE TABLE public.calendar_pricing (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  stay_id uuid REFERENCES public.stays(id) ON DELETE CASCADE NOT NULL,
  room_category_id uuid REFERENCES public.room_categories(id) ON DELETE CASCADE,
  date date NOT NULL,
  price integer NOT NULL DEFAULT 0,
  original_price integer NOT NULL DEFAULT 0,
  available integer NOT NULL DEFAULT 1,
  min_nights integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_calendar_pricing_tenant ON public.calendar_pricing(tenant_id);
CREATE INDEX idx_calendar_pricing_stay_date ON public.calendar_pricing(stay_id, date);

-- add_ons table
CREATE TABLE public.add_ons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  stay_id uuid REFERENCES public.stays(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  price integer NOT NULL DEFAULT 0,
  category text NOT NULL DEFAULT 'activity',
  image_url text NOT NULL DEFAULT '',
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_add_ons_tenant ON public.add_ons(tenant_id);

-- announcements table
CREATE TABLE public.announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL DEFAULT '',
  type text NOT NULL DEFAULT 'info',
  target text NOT NULL DEFAULT 'all',
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz
);

-- RLS for calendar_pricing
ALTER TABLE public.calendar_pricing ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can manage calendar_pricing" ON public.calendar_pricing FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view calendar_pricing" ON public.calendar_pricing FOR SELECT USING (true);

-- RLS for add_ons
ALTER TABLE public.add_ons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can manage add_ons" ON public.add_ons FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view active add_ons" ON public.add_ons FOR SELECT USING (active = true);

-- RLS for announcements
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins can manage announcements" ON public.announcements FOR ALL USING (has_role(auth.uid(), 'super_admin'::app_role));
CREATE POLICY "Public can read published announcements" ON public.announcements FOR SELECT USING (published = true);
