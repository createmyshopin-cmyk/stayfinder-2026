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
