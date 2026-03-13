
-- Quotations table
CREATE TABLE public.quotations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_id text NOT NULL UNIQUE,
  guest_name text NOT NULL,
  phone text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  stay_id uuid REFERENCES public.stays(id) ON DELETE SET NULL,
  rooms jsonb NOT NULL DEFAULT '[]'::jsonb,
  addons jsonb NOT NULL DEFAULT '[]'::jsonb,
  checkin date,
  checkout date,
  discount integer NOT NULL DEFAULT 0,
  coupon_code text,
  special_requests text,
  room_total integer NOT NULL DEFAULT 0,
  addons_total integer NOT NULL DEFAULT 0,
  total_price integer NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'draft',
  notes text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.quotations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage quotations" ON public.quotations
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Invoices table
CREATE TABLE public.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id text NOT NULL UNIQUE,
  booking_id uuid REFERENCES public.bookings(id) ON DELETE SET NULL,
  quotation_id uuid REFERENCES public.quotations(id) ON DELETE SET NULL,
  guest_name text NOT NULL,
  phone text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  stay_id uuid REFERENCES public.stays(id) ON DELETE SET NULL,
  rooms jsonb NOT NULL DEFAULT '[]'::jsonb,
  addons jsonb NOT NULL DEFAULT '[]'::jsonb,
  checkin date,
  checkout date,
  room_total integer NOT NULL DEFAULT 0,
  addons_total integer NOT NULL DEFAULT 0,
  discount integer NOT NULL DEFAULT 0,
  coupon_code text,
  total_price integer NOT NULL DEFAULT 0,
  payment_status text NOT NULL DEFAULT 'pending',
  payment_notes text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage invoices" ON public.invoices
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Public read for invoice links
CREATE POLICY "Public can view invoices by id" ON public.invoices
  FOR SELECT TO anon
  USING (true);
