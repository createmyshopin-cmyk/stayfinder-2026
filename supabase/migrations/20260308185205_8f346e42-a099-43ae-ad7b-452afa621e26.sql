
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
