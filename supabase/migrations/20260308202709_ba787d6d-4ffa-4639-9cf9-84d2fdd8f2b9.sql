
CREATE TABLE public.stay_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL,
  icon text NOT NULL DEFAULT 'Tag',
  sort_order integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.stay_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage stay_categories" ON public.stay_categories FOR ALL TO authenticated USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can read active categories" ON public.stay_categories FOR SELECT TO anon, authenticated USING (active = true);

-- Seed default categories
INSERT INTO public.stay_categories (label, icon, sort_order) VALUES
  ('Couple Friendly', 'Heart', 0),
  ('Family Stay', 'Users', 1),
  ('Luxury Resort', 'Gem', 2),
  ('Budget Rooms', 'Wallet', 3),
  ('Non AC Rooms', 'Fan', 4),
  ('Pool Villas', 'Waves', 5),
  ('Tree Houses', 'TreePine', 6);
