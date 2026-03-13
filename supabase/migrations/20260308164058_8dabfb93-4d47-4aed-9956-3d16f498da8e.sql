
-- Create app_role enum
CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user');

-- Create user_roles table
CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  UNIQUE (user_id, role)
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Security definer function for role checks
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- RLS for user_roles
CREATE POLICY "Users can view own roles" ON public.user_roles
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage roles" ON public.user_roles
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Stays table
CREATE TABLE public.stays (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id text UNIQUE NOT NULL,
  name text NOT NULL,
  location text NOT NULL DEFAULT '',
  description text NOT NULL DEFAULT '',
  category text NOT NULL DEFAULT '',
  rating numeric NOT NULL DEFAULT 0,
  reviews_count integer NOT NULL DEFAULT 0,
  price integer NOT NULL DEFAULT 0,
  original_price integer NOT NULL DEFAULT 0,
  amenities text[] NOT NULL DEFAULT '{}',
  images text[] NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.stays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active stays" ON public.stays
  FOR SELECT USING (status = 'active');

CREATE POLICY "Admins can manage stays" ON public.stays
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Room categories table
CREATE TABLE public.room_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id uuid REFERENCES public.stays(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  max_guests integer NOT NULL DEFAULT 2,
  available integer NOT NULL DEFAULT 1,
  amenities text[] NOT NULL DEFAULT '{}',
  price integer NOT NULL DEFAULT 0,
  original_price integer NOT NULL DEFAULT 0,
  images text[] NOT NULL DEFAULT '{}'
);
ALTER TABLE public.room_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view room categories" ON public.room_categories
  FOR SELECT USING (true);

CREATE POLICY "Admins can manage room categories" ON public.room_categories
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Bookings table
CREATE TABLE public.bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id text UNIQUE NOT NULL,
  stay_id uuid REFERENCES public.stays(id) ON DELETE SET NULL,
  guest_name text NOT NULL,
  phone text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  checkin date,
  checkout date,
  rooms jsonb NOT NULL DEFAULT '[]',
  addons jsonb NOT NULL DEFAULT '[]',
  coupon_code text,
  total_price integer NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  special_requests text,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can create bookings" ON public.bookings
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can manage bookings" ON public.bookings
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));
