
CREATE TABLE public.coupons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  type text NOT NULL DEFAULT 'flat' CHECK (type IN ('flat', 'percentage')),
  value integer NOT NULL DEFAULT 0,
  min_purchase integer NOT NULL DEFAULT 0,
  max_discount integer,
  active boolean NOT NULL DEFAULT true,
  usage_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active coupons" ON public.coupons
  FOR SELECT USING (active = true);

CREATE POLICY "Admins can manage coupons" ON public.coupons
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));
