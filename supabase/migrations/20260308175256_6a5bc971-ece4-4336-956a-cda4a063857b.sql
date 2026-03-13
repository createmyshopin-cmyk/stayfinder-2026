
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
