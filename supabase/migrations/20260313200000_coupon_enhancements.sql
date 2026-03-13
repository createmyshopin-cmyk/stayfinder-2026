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
