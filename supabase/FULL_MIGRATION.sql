-- STAY UI: Consolidated migration (34 files)
-- Run this in Supabase SQL Editor if CLI is not an option
-- Project: rqnxtcigfauzzjaqxzut
-- Generated: 2026-03-13T05:45:53.862Z


-- ========== 20260308164058_8dabfb93-4d47-4aed-9956-3d16f498da8e.sql ==========

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


-- ========== 20260308164820_027b2853-7703-4a93-9de6-9d929c1232aa.sql ==========

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


-- ========== 20260308171055_8527f3af-abed-407c-b11e-f85bf13b4fcb.sql ==========

-- AI Settings (singleton row for global config)
CREATE TABLE public.ai_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  search_enabled boolean NOT NULL DEFAULT true,
  data_sources jsonb NOT NULL DEFAULT '["stays","room_categories","amenities","reviews","pricing"]'::jsonb,
  attraction_radius integer NOT NULL DEFAULT 10,
  auto_review_summary boolean NOT NULL DEFAULT false,
  recommendation_logic jsonb NOT NULL DEFAULT '["similar_price","similar_amenities","nearby_location","highest_rated"]'::jsonb,
  system_prompt text NOT NULL DEFAULT 'You are a travel assistant helping users find stays based on amenities, location, attractions, and price preferences.',
  blacklisted_words text[] NOT NULL DEFAULT '{}',
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage ai_settings" ON public.ai_settings FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can read ai_settings" ON public.ai_settings FOR SELECT USING (true);

-- Insert default settings row
INSERT INTO public.ai_settings (id) VALUES (gen_random_uuid());

-- AI Synonym Mapping
CREATE TABLE public.ai_synonyms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  query_term text NOT NULL,
  maps_to text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_synonyms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage ai_synonyms" ON public.ai_synonyms FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can read ai_synonyms" ON public.ai_synonyms FOR SELECT USING (true);

-- AI Search Query Logs
CREATE TABLE public.ai_search_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  query text NOT NULL,
  results_count integer NOT NULL DEFAULT 0,
  filters jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_search_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view search logs" ON public.ai_search_logs FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can insert search logs" ON public.ai_search_logs FOR INSERT WITH CHECK (true);


-- ========== 20260308171747_9fd145ae-5a1e-499b-8e0f-a3d3033af039.sql ==========

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


-- ========== 20260308172029_255eb904-0a06-4aae-843d-b7e25006362b.sql ==========

ALTER TABLE public.site_settings
  ADD COLUMN sticky_menu_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN sticky_menu_show_ai boolean NOT NULL DEFAULT true,
  ADD COLUMN sticky_menu_show_wishlist boolean NOT NULL DEFAULT true,
  ADD COLUMN sticky_menu_show_explore boolean NOT NULL DEFAULT true;


-- ========== 20260308172942_ac2b88ba-30c1-4063-bb3c-10d1074531e8.sql ==========

ALTER TABLE public.ai_settings 
  ADD COLUMN IF NOT EXISTS ai_model text NOT NULL DEFAULT 'google/gemini-3-flash-preview',
  ADD COLUMN IF NOT EXISTS ai_personality text NOT NULL DEFAULT 'travel_assistant',
  ADD COLUMN IF NOT EXISTS response_length text NOT NULL DEFAULT 'medium',
  ADD COLUMN IF NOT EXISTS cache_enabled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cache_duration integer NOT NULL DEFAULT 12,
  ADD COLUMN IF NOT EXISTS feature_recommendations boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS feature_review_summaries boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS feature_stay_highlights boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS feature_query_suggestions boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS feature_chat_assistant boolean NOT NULL DEFAULT false;


-- ========== 20260308173348_b13290a2-d8f4-4340-8a74-cc5bb6af54dd.sql ==========

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


-- ========== 20260308175256_6a5bc971-ece4-4336-956a-cda4a063857b.sql ==========

-- Plans table (SaaS packages)
CREATE TABLE public.plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_name text NOT NULL,
  price integer NOT NULL DEFAULT 0,
  billing_cycle text NOT NULL DEFAULT 'monthly',
  max_stays integer NOT NULL DEFAULT 1,
  max_rooms integer NOT NULL DEFAULT 10,
  max_bookings_per_month integer NOT NULL DEFAULT 50,
  max_ai_search integer NOT NULL DEFAULT 100,
  feature_flags jsonb NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage plans" ON public.plans FOR ALL USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Public can read active plans" ON public.plans FOR SELECT USING (status = 'active');

-- Features registry
CREATE TABLE public.features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  feature_name text NOT NULL,
  feature_key text UNIQUE NOT NULL,
  description text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'active'
);

ALTER TABLE public.features ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage features" ON public.features FOR ALL USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Public can read features" ON public.features FOR SELECT USING (true);

-- Plan features mapping
CREATE TABLE public.plan_features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid REFERENCES public.plans(id) ON DELETE CASCADE NOT NULL,
  feature_key text NOT NULL,
  enabled boolean NOT NULL DEFAULT false
);

ALTER TABLE public.plan_features ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage plan_features" ON public.plan_features FOR ALL USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Public can read plan_features" ON public.plan_features FOR SELECT USING (true);

-- Tenants table
CREATE TABLE public.tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_name text NOT NULL,
  owner_name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  phone text NOT NULL DEFAULT '',
  domain text NOT NULL DEFAULT '',
  plan_id uuid REFERENCES public.plans(id),
  status text NOT NULL DEFAULT 'trial',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage tenants" ON public.tenants FOR ALL USING (has_role(auth.uid(), 'admin'));

-- Subscriptions table
CREATE TABLE public.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE NOT NULL,
  plan_id uuid REFERENCES public.plans(id) NOT NULL,
  start_date date NOT NULL DEFAULT CURRENT_DATE,
  renewal_date date,
  billing_cycle text NOT NULL DEFAULT 'monthly',
  status text NOT NULL DEFAULT 'trial',
  payment_gateway text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage subscriptions" ON public.subscriptions FOR ALL USING (has_role(auth.uid(), 'admin'));

-- Transactions table
CREATE TABLE public.transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id text NOT NULL,
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE NOT NULL,
  subscription_id uuid REFERENCES public.subscriptions(id),
  amount integer NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'INR',
  payment_method text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'pending',
  payment_gateway text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage transactions" ON public.transactions FOR ALL USING (has_role(auth.uid(), 'admin'));

-- Tenant usage tracking
CREATE TABLE public.tenant_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE NOT NULL UNIQUE,
  stays_created integer NOT NULL DEFAULT 0,
  rooms_created integer NOT NULL DEFAULT 0,
  bookings_this_month integer NOT NULL DEFAULT 0,
  ai_search_count integer NOT NULL DEFAULT 0,
  storage_used bigint NOT NULL DEFAULT 0,
  last_reset timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.tenant_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage tenant_usage" ON public.tenant_usage FOR ALL USING (has_role(auth.uid(), 'admin'));

-- Seed default plans
INSERT INTO public.plans (plan_name, price, billing_cycle, max_stays, max_rooms, max_bookings_per_month, max_ai_search, feature_flags, status) VALUES
('Starter', 999, 'monthly', 1, 10, 50, 100, '{"ai_search": false, "coupons": false, "invoice_generator": true, "quotation_generator": true}', 'active'),
('Pro', 2999, 'monthly', 5, 50, 500, 1000, '{"ai_search": true, "coupons": true, "invoice_generator": true, "quotation_generator": true, "reels": true, "dynamic_pricing": true}', 'active'),
('Enterprise', 6999, 'monthly', -1, -1, -1, -1, '{"ai_search": true, "coupons": true, "invoice_generator": true, "quotation_generator": true, "reels": true, "dynamic_pricing": true, "custom_domain": true, "analytics": true}', 'active');

-- Seed default features
INSERT INTO public.features (feature_name, feature_key, description) VALUES
('AI Search', 'ai_search', 'AI-powered natural language search'),
('Dynamic Pricing', 'dynamic_pricing', 'Calendar-based dynamic pricing'),
('Coupons', 'coupons', 'Coupon and discount management'),
('Reels / Videos', 'reels', 'Video reels and stories'),
('Invoice Generator', 'invoice_generator', 'Generate and send invoices'),
('Quotation Generator', 'quotation_generator', 'Generate and send quotations'),
('Custom Domain', 'custom_domain', 'White-label custom domain support'),
('Analytics', 'analytics', 'Advanced analytics dashboard');


-- ========== 20260308180015_a464561a-5874-42aa-96a8-bf7d129f47e6.sql ==========

-- Add super_admin to app_role enum
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'super_admin';


-- ========== 20260308181418_403e9595-8101-4610-8f7c-9fae22fc92e2.sql ==========

-- Add tenant_id to stays
ALTER TABLE public.stays ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to room_categories
ALTER TABLE public.room_categories ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to bookings
ALTER TABLE public.bookings ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to reviews
ALTER TABLE public.reviews ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to invoices
ALTER TABLE public.invoices ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to quotations
ALTER TABLE public.quotations ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to media
ALTER TABLE public.media ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to coupons
ALTER TABLE public.coupons ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to ai_search_logs
ALTER TABLE public.ai_search_logs ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Create indexes for tenant_id on all tables
CREATE INDEX idx_stays_tenant ON public.stays(tenant_id);
CREATE INDEX idx_room_categories_tenant ON public.room_categories(tenant_id);
CREATE INDEX idx_bookings_tenant ON public.bookings(tenant_id);
CREATE INDEX idx_reviews_tenant ON public.reviews(tenant_id);
CREATE INDEX idx_invoices_tenant ON public.invoices(tenant_id);
CREATE INDEX idx_quotations_tenant ON public.quotations(tenant_id);
CREATE INDEX idx_media_tenant ON public.media(tenant_id);
CREATE INDEX idx_coupons_tenant ON public.coupons(tenant_id);
CREATE INDEX idx_ai_search_logs_tenant ON public.ai_search_logs(tenant_id);


-- ========== 20260308181953_14ca91cf-767e-4b45-bec1-7745393519f8.sql ==========

CREATE TABLE public.tenant_domains (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE NOT NULL,
  subdomain text NOT NULL DEFAULT '',
  custom_domain text NOT NULL DEFAULT '',
  ssl_status text NOT NULL DEFAULT 'pending',
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.tenant_domains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage tenant_domains" ON public.tenant_domains FOR ALL USING (has_role(auth.uid(), 'super_admin'));
CREATE POLICY "Public can read verified domains" ON public.tenant_domains FOR SELECT USING (verified = true);

CREATE UNIQUE INDEX idx_tenant_domains_subdomain ON public.tenant_domains(subdomain) WHERE subdomain != '';
CREATE UNIQUE INDEX idx_tenant_domains_custom ON public.tenant_domains(custom_domain) WHERE custom_domain != '';


-- ========== 20260308182921_09ebce72-3f9d-40ab-8a77-fede2b557177.sql ==========

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


-- ========== 20260308185205_8f346e42-a099-43ae-ad7b-452afa621e26.sql ==========

-- Add scheduled downgrade and proration fields to subscriptions
ALTER TABLE public.subscriptions 
  ADD COLUMN IF NOT EXISTS scheduled_plan_id uuid REFERENCES public.plans(id),
  ADD COLUMN IF NOT EXISTS scheduled_at timestamp with time zone,
  ADD COLUMN IF NOT EXISTS razorpay_subscription_id text DEFAULT '',
  ADD COLUMN IF NOT EXISTS last_payment_id text DEFAULT '';

-- Add branding fields to tenants for future white-label support
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS logo_url text DEFAULT '',
  ADD COLUMN IF NOT EXISTS favicon_url text DEFAULT '',
  ADD COLUMN IF NOT EXISTS primary_color text DEFAULT '#6366f1',
  ADD COLUMN IF NOT EXISTS secondary_color text DEFAULT '#8b5cf6',
  ADD COLUMN IF NOT EXISTS footer_text text DEFAULT '';


-- ========== 20260308185958_d7af8126-3f24-48a6-93fa-cf6e65ed3382.sql ==========

-- Allow authenticated users to upload to branding bucket
CREATE POLICY "Authenticated users can upload branding assets"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'branding');

-- Allow public read access to branding assets
CREATE POLICY "Public can view branding assets"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'branding');

-- Allow authenticated users to update their branding assets
CREATE POLICY "Authenticated users can update branding assets"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'branding');

-- Allow authenticated users to delete their branding assets
CREATE POLICY "Authenticated users can delete branding assets"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'branding');


-- ========== 20260308190220_7a2ff9c1-61f3-4caa-8c5a-f7734b685fd4.sql ==========

-- Enable pg_cron and pg_net extensions for scheduled functions
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


-- ========== 20260308192629_5ca7c695-ae7a-4b4d-892f-b4fd48ba91fb.sql ==========
ALTER TABLE public.calendar_pricing ADD COLUMN IF NOT EXISTS is_blocked boolean NOT NULL DEFAULT false;

-- ========== 20260308193608_d78267ea-939f-4fd7-a282-7660c7172e6e.sql ==========

-- Add columns to tenant_domains
ALTER TABLE public.tenant_domains ADD COLUMN IF NOT EXISTS registrar text NOT NULL DEFAULT '';
ALTER TABLE public.tenant_domains ADD COLUMN IF NOT EXISTS auto_configured boolean NOT NULL DEFAULT false;

-- Create tenant_registrar_keys table
CREATE TABLE public.tenant_registrar_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  registrar text NOT NULL DEFAULT '',
  api_key text NOT NULL DEFAULT '',
  api_secret text NOT NULL DEFAULT '',
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, registrar)
);

ALTER TABLE public.tenant_registrar_keys ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage registrar keys"
ON public.tenant_registrar_keys
FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));


-- ========== 20260308194724_3e18c041-73a3-425f-9fd0-f1992c31121d.sql ==========
CREATE TABLE public.saas_platform_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key text NOT NULL UNIQUE,
  setting_value text NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.saas_platform_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Super admins can manage platform settings"
  ON public.saas_platform_settings
  FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'super_admin'::app_role));

INSERT INTO public.saas_platform_settings (setting_key, setting_value) VALUES
  ('entri_application_id', ''),
  ('entri_secret', '');


-- ========== 20260308202709_ba787d6d-4ffa-4639-9cf9-84d2fdd8f2b9.sql ==========

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


-- ========== 20260308204011_32773b14-7236-4e67-93e0-c875f4e820ca.sql ==========
ALTER PUBLICATION supabase_realtime ADD TABLE public.stay_categories;

-- ========== 20260309032316_3fa4c89b-48b9-4cf3-801a-9381f5ae610d.sql ==========
ALTER PUBLICATION supabase_realtime ADD TABLE public.calendar_pricing;

-- ========== 20260309033027_2497c823-5893-422e-9be4-88958e7925c1.sql ==========
CREATE OR REPLACE FUNCTION public.resolve_stay_uuid(_stay_id text)
RETURNS uuid
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT id FROM public.stays WHERE stay_id = _stay_id LIMIT 1
$$;

-- ========== 20260309033356_8ffdc5a7-2918-4d9a-b383-49f419d1c285.sql ==========
CREATE OR REPLACE FUNCTION public.resolve_stay_uuid_flexible(_stay_id text, _stay_name text)
RETURNS uuid
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT id
  FROM public.stays
  WHERE stay_id = _stay_id OR name = _stay_name
  ORDER BY CASE WHEN stay_id = _stay_id THEN 0 ELSE 1 END
  LIMIT 1
$$;

-- ========== 20260309043101_8d7e6eb5-a6d4-4fbf-a47f-db9ab8dec146.sql ==========
CREATE UNIQUE INDEX IF NOT EXISTS calendar_pricing_unique_date_stay_room 
ON calendar_pricing (date, stay_id, COALESCE(room_category_id, '00000000-0000-0000-0000-000000000000'::uuid));

-- ========== 20260309043550_ac1e3411-1794-4b9a-8e1b-830bd9267131.sql ==========
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;

-- ========== 20260309043916_b80335a3-1341-46ba-8e49-ae5c4b63fb1b.sql ==========

-- Drop the existing restrictive insert policy
DROP POLICY IF EXISTS "Public can create bookings" ON public.bookings;

-- Create a permissive insert policy for anonymous users
CREATE POLICY "Anyone can create bookings"
ON public.bookings
FOR INSERT
TO anon, authenticated
WITH CHECK (true);


-- ========== 20260309044810_ae93856a-68b2-413a-b82a-0af73fea42c9.sql ==========

ALTER TABLE public.bookings
  ADD COLUMN IF NOT EXISTS adults integer NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS children integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pets integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS solo_traveller boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS group_booking boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS group_name text DEFAULT '';


-- ========== 20260309045353_f55f5ee2-eadf-469d-8990-62069c1b7dea.sql ==========

-- Reels table for stays
CREATE TABLE public.stay_reels (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  stay_id UUID NOT NULL REFERENCES public.stays(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT '',
  thumbnail TEXT NOT NULL DEFAULT '',
  url TEXT NOT NULL DEFAULT '',
  platform TEXT NOT NULL DEFAULT 'youtube',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.stay_reels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage stay_reels" ON public.stay_reels FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view stay_reels" ON public.stay_reels FOR SELECT USING (true);

-- Nearby destinations table for stays
CREATE TABLE public.nearby_destinations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  stay_id UUID NOT NULL REFERENCES public.stays(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  image TEXT NOT NULL DEFAULT '',
  distance TEXT NOT NULL DEFAULT '',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.nearby_destinations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage nearby_destinations" ON public.nearby_destinations FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view nearby_destinations" ON public.nearby_destinations FOR SELECT USING (true);


-- ========== 20260309050158_f9306c93-207f-4801-8465-10e9a5ee97d2.sql ==========

INSERT INTO storage.buckets (id, name, public)
VALUES ('stay-images', 'stay-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can view stay images"
ON storage.objects FOR SELECT
USING (bucket_id = 'stay-images');

CREATE POLICY "Admins can upload stay images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'stay-images');

CREATE POLICY "Admins can delete stay images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'stay-images');


-- ========== 20260313001000_schema_extension_rls_audit.sql ==========
-- =============================================================================
-- Migration: Schema Extension & RLS Audit
-- Date: 2026-03-13
-- Covers:
--   1. RLS Fixes  — add super_admin to enum, tenant isolation, fix public invoices
--   2. Schema     — missing columns on bookings, calendar_pricing, subscriptions,
--                   tenants (branding), site_settings (sticky nav)
--   3. New tables — guest_wishlist, booking_timeline
--   4. Helper fn  — get_my_tenant_id(), is_tenant_admin()
--   5. Indexes    — performance improvements
-- =============================================================================


-- ===========================================================================
-- PART 1: RLS FIXES
-- ===========================================================================

-- 1a. Add super_admin to the app_role enum (fixes announcements policy cast error)
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'super_admin';


-- 1b. Add user_id to tenants (links a tenant to an auth user — required for RLS)
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_tenants_user_id ON public.tenants(user_id);


-- 1c. Helper: get the tenant_id of the currently logged-in admin
CREATE OR REPLACE FUNCTION public.get_my_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.tenants WHERE user_id = auth.uid() LIMIT 1;
$$;


-- 1d. Helper: check if the calling user is the admin of a specific tenant
CREATE OR REPLACE FUNCTION public.is_tenant_admin(_tenant_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.tenants
    WHERE id = _tenant_id
      AND user_id = auth.uid()
  );
$$;


-- ===========================================================================
-- 1e. RE-SCOPE RLS on stays (replace blanket admin with tenant-scoped)
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage stays" ON public.stays;

CREATE POLICY "Tenant admin can manage own stays" ON public.stays
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

-- Super admins can see / manage all stays
CREATE POLICY "Super admins can manage all stays" ON public.stays
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1f. room_categories
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage room categories" ON public.room_categories;

CREATE POLICY "Tenant admin can manage own room categories" ON public.room_categories
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all room categories" ON public.room_categories
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1g. bookings
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage bookings" ON public.bookings;

CREATE POLICY "Tenant admin can manage own bookings" ON public.bookings
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all bookings" ON public.bookings
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1h. reviews
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage reviews" ON public.reviews;

CREATE POLICY "Tenant admin can manage own reviews" ON public.reviews
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all reviews" ON public.reviews
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1i. invoices — fix the dangerous public SELECT blanket policy
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage invoices" ON public.invoices;
DROP POLICY IF EXISTS "Public can view invoices by id" ON public.invoices;

CREATE POLICY "Tenant admin can manage own invoices" ON public.invoices
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

-- Token-based public access (guest viewing their own invoice via share link)
-- Uses a scoped check: only if the invoice belongs to the calling tenant
-- Guests without auth get nothing — you must implement token-based edge function access
CREATE POLICY "Super admins can manage all invoices" ON public.invoices
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1j. quotations
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage quotations" ON public.quotations;

CREATE POLICY "Tenant admin can manage own quotations" ON public.quotations
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all quotations" ON public.quotations
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1k. calendar_pricing
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage calendar_pricing" ON public.calendar_pricing;

CREATE POLICY "Tenant admin can manage own calendar_pricing" ON public.calendar_pricing
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all calendar_pricing" ON public.calendar_pricing
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1l. add_ons
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage add_ons" ON public.add_ons;

CREATE POLICY "Tenant admin can manage own add_ons" ON public.add_ons
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all add_ons" ON public.add_ons
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1m. coupons
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage coupons" ON public.coupons;

CREATE POLICY "Tenant admin can manage own coupons" ON public.coupons
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all coupons" ON public.coupons
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1n. media
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage media" ON public.media;

CREATE POLICY "Tenant admin can manage own media" ON public.media
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all media" ON public.media
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1o. ai_search_logs
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can view search logs" ON public.ai_search_logs;

CREATE POLICY "Tenant admin can view own search logs" ON public.ai_search_logs
  FOR SELECT TO authenticated
  USING (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all search logs" ON public.ai_search_logs
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1p. stay_reels & nearby_destinations — add tenant_id + RLS
-- ===========================================================================
ALTER TABLE public.stay_reels
  ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_stay_reels_tenant ON public.stay_reels(tenant_id);

ALTER TABLE public.nearby_destinations
  ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_nearby_destinations_tenant ON public.nearby_destinations(tenant_id);

-- RLS for stay_reels
ALTER TABLE public.stay_reels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view stay_reels" ON public.stay_reels FOR SELECT USING (true);
CREATE POLICY "Tenant admin can manage own stay_reels" ON public.stay_reels
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));
CREATE POLICY "Super admins can manage all stay_reels" ON public.stay_reels
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));

-- RLS for nearby_destinations
ALTER TABLE public.nearby_destinations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view nearby_destinations" ON public.nearby_destinations FOR SELECT USING (true);
CREATE POLICY "Tenant admin can manage own nearby_destinations" ON public.nearby_destinations
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));
CREATE POLICY "Super admins can manage all nearby_destinations" ON public.nearby_destinations
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));


-- ===========================================================================
-- 1q. tenants — tenant can view their own record
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage tenants" ON public.tenants;

CREATE POLICY "Super admins can manage all tenants" ON public.tenants
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Tenant can view and update own record" ON public.tenants
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());


-- ===========================================================================
-- 1r. subscriptions — tenant can read own subscription
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage subscriptions" ON public.subscriptions;

CREATE POLICY "Super admins can manage all subscriptions" ON public.subscriptions
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Tenant can view own subscription" ON public.subscriptions
  FOR SELECT TO authenticated
  USING (tenant_id = public.get_my_tenant_id());


-- ===========================================================================
-- 1s. transactions — tenant can read own transactions
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage transactions" ON public.transactions;

CREATE POLICY "Super admins can manage all transactions" ON public.transactions
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Tenant can view own transactions" ON public.transactions
  FOR SELECT TO authenticated
  USING (tenant_id = public.get_my_tenant_id());


-- ===========================================================================
-- 1t. tenant_usage — tenant can read own usage
-- ===========================================================================
DROP POLICY IF EXISTS "Admins can manage tenant_usage" ON public.tenant_usage;

CREATE POLICY "Super admins can manage all tenant_usage" ON public.tenant_usage
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Tenant can view own usage" ON public.tenant_usage
  FOR SELECT TO authenticated
  USING (tenant_id = public.get_my_tenant_id());


-- ===========================================================================
-- 1u. Fix announcements: super_admin is now valid in the enum
-- ===========================================================================
-- (policy already references 'super_admin'::app_role — enum fix in 1a unblocks it)
-- No policy change needed for announcements.


-- ===========================================================================
-- PART 2: SCHEMA EXTENSIONS
-- ===========================================================================

-- 2a. tenants — add branding columns (idempotent)
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS logo_url       text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS favicon_url    text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS primary_color  text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS secondary_color text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS footer_text    text NOT NULL DEFAULT '';


-- 2b. bookings — add guest detail columns
ALTER TABLE public.bookings
  ADD COLUMN IF NOT EXISTS adults          integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS children        integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pets            integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS solo_traveller  boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS group_booking   boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS group_name      text    NOT NULL DEFAULT '';


-- 2c. calendar_pricing — add is_blocked flag
ALTER TABLE public.calendar_pricing
  ADD COLUMN IF NOT EXISTS is_blocked boolean NOT NULL DEFAULT false;


-- 2d. subscriptions — add Razorpay + plan scheduling columns
ALTER TABLE public.subscriptions
  ADD COLUMN IF NOT EXISTS razorpay_subscription_id text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS scheduled_plan_id uuid REFERENCES public.plans(id) ON DELETE SET NULL;


-- 2e. site_settings — add sticky nav toggles
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS sticky_header_enabled     boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS sticky_bottom_nav_enabled boolean NOT NULL DEFAULT true;


-- ===========================================================================
-- PART 3: NEW TABLES
-- ===========================================================================

-- 3a. guest_wishlist — server-side wishlist persistence
CREATE TABLE IF NOT EXISTS public.guest_wishlist (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id  text NOT NULL,                                           -- anonymous session token
  user_id     uuid REFERENCES auth.users(id) ON DELETE CASCADE,        -- nullable: only set when logged in
  stay_id     uuid REFERENCES public.stays(id) ON DELETE CASCADE NOT NULL,
  tenant_id   uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (session_id, stay_id)
);

ALTER TABLE public.guest_wishlist ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_guest_wishlist_session ON public.guest_wishlist(session_id);
CREATE INDEX IF NOT EXISTS idx_guest_wishlist_user    ON public.guest_wishlist(user_id);

-- Anyone can insert/read/delete by session
CREATE POLICY "Session can manage own wishlist" ON public.guest_wishlist
  FOR ALL
  USING (
    session_id IS NOT NULL
    AND (user_id IS NULL OR user_id = auth.uid())
  )
  WITH CHECK (
    session_id IS NOT NULL
    AND (user_id IS NULL OR user_id = auth.uid())
  );

-- Tenant admin can view wishlist items for their stays
CREATE POLICY "Tenant admin can view wishlist for own stays" ON public.guest_wishlist
  FOR SELECT TO authenticated
  USING (public.is_tenant_admin(tenant_id));


-- 3b. booking_timeline — audit log for booking status changes
CREATE TABLE IF NOT EXISTS public.booking_timeline (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id  uuid REFERENCES public.bookings(id) ON DELETE CASCADE NOT NULL,
  tenant_id   uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  status      text NOT NULL,
  note        text NOT NULL DEFAULT '',
  changed_by  uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.booking_timeline ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_booking_timeline_booking ON public.booking_timeline(booking_id);
CREATE INDEX IF NOT EXISTS idx_booking_timeline_tenant  ON public.booking_timeline(tenant_id);

-- Tenant admin can manage timeline for their bookings
CREATE POLICY "Tenant admin can manage own booking_timeline" ON public.booking_timeline
  FOR ALL TO authenticated
  USING (public.is_tenant_admin(tenant_id))
  WITH CHECK (public.is_tenant_admin(tenant_id));

CREATE POLICY "Super admins can manage all booking_timeline" ON public.booking_timeline
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));

-- System/edge functions can insert timeline entries (anon with check)
CREATE POLICY "System can insert timeline entries" ON public.booking_timeline
  FOR INSERT WITH CHECK (true);


-- ===========================================================================
-- PART 4: PERFORMANCE INDEXES
-- ===========================================================================

CREATE INDEX IF NOT EXISTS idx_stays_status          ON public.stays(status);
CREATE INDEX IF NOT EXISTS idx_stays_category        ON public.stays(category);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin      ON public.bookings(checkin);
CREATE INDEX IF NOT EXISTS idx_bookings_checkout     ON public.bookings(checkout);
CREATE INDEX IF NOT EXISTS idx_bookings_status       ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_calendar_date         ON public.calendar_pricing(date);
CREATE INDEX IF NOT EXISTS idx_calendar_blocked      ON public.calendar_pricing(is_blocked) WHERE is_blocked = true;
CREATE INDEX IF NOT EXISTS idx_reviews_status        ON public.reviews(status);
CREATE INDEX IF NOT EXISTS idx_add_ons_active        ON public.add_ons(active) WHERE active = true;
CREATE INDEX IF NOT EXISTS idx_subscriptions_tenant  ON public.subscriptions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_transactions_tenant   ON public.transactions(tenant_id);


-- ========== 20260313100000_story_reel_settings.sql ==========
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


-- ========== 20260313200000_coupon_enhancements.sql ==========
-- Coupon enhancements: expiry dates, usage limits, description, applicable stays
ALTER TABLE public.coupons
  ADD COLUMN IF NOT EXISTS description text DEFAULT '',
  ADD COLUMN IF NOT EXISTS starts_at timestamptz,
  ADD COLUMN IF NOT EXISTS expires_at timestamptz,
  ADD COLUMN IF NOT EXISTS usage_limit integer,
  ADD COLUMN IF NOT EXISTS applicable_stay_ids jsonb DEFAULT '[]';

COMMENT ON COLUMN public.coupons.starts_at IS 'Coupon becomes valid from this timestamp. NULL = immediately valid.';
COMMENT ON COLUMN public.coupons.expires_at IS 'Coupon expires after this timestamp. NULL = never expires.';
COMMENT ON COLUMN public.coupons.usage_limit IS 'Max number of times this coupon can be used. NULL = unlimited.';
COMMENT ON COLUMN public.coupons.applicable_stay_ids IS 'JSON array of stay UUIDs this coupon applies to. Empty array = all stays.';

-- Function to increment coupon usage atomically
CREATE OR REPLACE FUNCTION public.increment_coupon_usage(coupon_code_input text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.coupons
  SET usage_count = usage_count + 1
  WHERE code = coupon_code_input;
END;
$$;


-- ========== 20260313210000_stays_cooldown_hours.sql ==========
-- Cool time: buffer minutes between bookings (per-stay global + per-date override)

-- Global cooldown on stays (in minutes, default 1440 = 24 hours)
ALTER TABLE public.stays
  ADD COLUMN IF NOT EXISTS cooldown_minutes integer DEFAULT 1440;

COMMENT ON COLUMN public.stays.cooldown_minutes IS 'Buffer minutes after checkout before next check-in. Default 1440 (24h). 0 = no buffer.';

-- Per-date cooldown override on calendar_pricing (nullable = use stay default)
ALTER TABLE public.calendar_pricing
  ADD COLUMN IF NOT EXISTS cooldown_minutes integer;

COMMENT ON COLUMN public.calendar_pricing.cooldown_minutes IS 'Per-date cooldown override in minutes. NULL = use stay-level default.';

-- Function to check booking availability with cooldown support
CREATE OR REPLACE FUNCTION public.check_booking_availability(
  p_stay_id uuid,
  p_checkin date,
  p_checkout date,
  p_exclude_booking_id uuid DEFAULT NULL
)
RETURNS TABLE(available boolean, conflict_reason text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_cooldown_min integer;
  v_cooldown interval;
  v_conflict record;
BEGIN
  SELECT COALESCE(s.cooldown_minutes, 1440)
  INTO v_cooldown_min
  FROM public.stays s WHERE s.id = p_stay_id;

  v_cooldown := make_interval(mins => v_cooldown_min);

  SELECT b.booking_id, b.checkin, b.checkout, b.guest_name
  INTO v_conflict
  FROM public.bookings b
  WHERE b.stay_id = p_stay_id
    AND b.status IN ('pending', 'confirmed')
    AND (p_exclude_booking_id IS NULL OR b.id != p_exclude_booking_id)
    AND (
      (b.checkin::date < p_checkout AND b.checkout::date > p_checkin)
      OR
      (p_checkin < (b.checkout::date + v_cooldown) AND p_checkin >= b.checkout::date)
      OR
      (b.checkin::date < (p_checkout + v_cooldown) AND b.checkin::date >= p_checkout)
    )
  LIMIT 1;

  IF v_conflict IS NOT NULL THEN
    RETURN QUERY SELECT false, format(
      'Conflicts with booking %s (%s to %s) including %s min cooldown',
      v_conflict.booking_id, v_conflict.checkin, v_conflict.checkout, v_cooldown_min
    );
  ELSE
    RETURN QUERY SELECT true, NULL::text;
  END IF;
END;
$$;


-- ========== 20260313220000_accounting_book.sql ==========
-- Accounting Book: transactions table for income, expense, commission tracking
CREATE TABLE IF NOT EXISTS public.accounting_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('income', 'expense', 'commission')),
  category text NOT NULL DEFAULT 'general',
  description text NOT NULL DEFAULT '',
  amount integer NOT NULL DEFAULT 0,
  date date NOT NULL DEFAULT CURRENT_DATE,
  booking_id uuid REFERENCES public.bookings(id) ON DELETE SET NULL,
  invoice_id uuid REFERENCES public.invoices(id) ON DELETE SET NULL,
  quotation_id uuid REFERENCES public.quotations(id) ON DELETE SET NULL,
  stay_id uuid REFERENCES public.stays(id) ON DELETE SET NULL,
  payment_method text DEFAULT 'cash',
  reference_number text DEFAULT '',
  notes text DEFAULT '',
  tags text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Custom bookkeeping fields per booking
CREATE TABLE IF NOT EXISTS public.booking_ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
  booking_id uuid NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  label text NOT NULL DEFAULT '',
  amount integer NOT NULL DEFAULT 0,
  type text NOT NULL CHECK (type IN ('income', 'expense', 'commission')) DEFAULT 'income',
  notes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- RLS policies
ALTER TABLE public.accounting_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_ledger_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant can manage own accounting_transactions"
  ON public.accounting_transactions FOR ALL
  USING (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id())
  WITH CHECK (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id());

CREATE POLICY "Tenant can manage own booking_ledger_entries"
  ON public.booking_ledger_entries FOR ALL
  USING (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id())
  WITH CHECK (tenant_id IS NULL OR tenant_id = public.get_my_tenant_id());

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_tenant ON public.accounting_transactions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_date ON public.accounting_transactions(date);
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_type ON public.accounting_transactions(type);
CREATE INDEX IF NOT EXISTS idx_accounting_transactions_booking ON public.accounting_transactions(booking_id);
CREATE INDEX IF NOT EXISTS idx_booking_ledger_entries_booking ON public.booking_ledger_entries(booking_id);

COMMENT ON TABLE public.accounting_transactions IS 'Central ledger for all income, expenses, and commission entries';
COMMENT ON TABLE public.booking_ledger_entries IS 'Custom per-booking bookkeeping entries (additional charges, commissions, etc.)';

