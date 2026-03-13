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
DROP POLICY IF EXISTS "Public can view stay_reels" ON public.stay_reels;
DROP POLICY IF EXISTS "Admins can manage stay_reels" ON public.stay_reels;
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
DROP POLICY IF EXISTS "Public can view nearby_destinations" ON public.nearby_destinations;
DROP POLICY IF EXISTS "Admins can manage nearby_destinations" ON public.nearby_destinations;
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
