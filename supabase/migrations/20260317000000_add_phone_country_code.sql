-- Add phone_country_code to bookings for correct WhatsApp country-code handling
ALTER TABLE public.bookings
  ADD COLUMN IF NOT EXISTS phone_country_code text DEFAULT '91';

COMMENT ON COLUMN public.bookings.phone_country_code IS 'Dial code (e.g. 91, 971) for WhatsApp links; India=91, UAE=971, etc.';

-- Drop existing function (removes all overloads) before recreating with new signature
DROP FUNCTION IF EXISTS public.create_booking_enquiry CASCADE;

-- Recreate create_booking_enquiry RPC with phone_country_code parameter
CREATE FUNCTION public.create_booking_enquiry(
  p_booking_id text,
  p_guest_name text,
  p_phone text,
  p_email text,
  p_stay_id uuid,
  p_checkin date,
  p_checkout date,
  p_rooms jsonb,
  p_addons jsonb,
  p_total_price integer,
  p_coupon_code text,
  p_special_requests text,
  p_adults integer DEFAULT 1,
  p_children integer DEFAULT 0,
  p_pets integer DEFAULT 0,
  p_solo_traveller boolean DEFAULT false,
  p_group_booking boolean DEFAULT false,
  p_group_name text DEFAULT '',
  p_phone_country_code text DEFAULT '91'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id uuid;
  v_inserted_id uuid;
BEGIN
  SELECT tenant_id INTO v_tenant_id
  FROM public.stays
  WHERE id = p_stay_id
  LIMIT 1;

  INSERT INTO public.bookings (
    booking_id,
    guest_name,
    phone,
    phone_country_code,
    email,
    stay_id,
    tenant_id,
    checkin,
    checkout,
    rooms,
    addons,
    total_price,
    coupon_code,
    special_requests,
    status,
    adults,
    children,
    pets,
    solo_traveller,
    group_booking,
    group_name
  ) VALUES (
    p_booking_id,
    p_guest_name,
    p_phone,
    COALESCE(NULLIF(TRIM(p_phone_country_code), ''), '91'),
    COALESCE(NULLIF(TRIM(p_email), ''), ''),
    p_stay_id,
    v_tenant_id,
    p_checkin,
    p_checkout,
    p_rooms,
    p_addons,
    p_total_price,
    NULLIF(TRIM(p_coupon_code), ''),
    NULLIF(TRIM(p_special_requests), ''),
    'pending',
    COALESCE(p_adults, 1),
    COALESCE(p_children, 0),
    COALESCE(p_pets, 0),
    COALESCE(p_solo_traveller, false),
    COALESCE(p_group_booking, false),
    COALESCE(NULLIF(TRIM(p_group_name), ''), '')
  )
  RETURNING id INTO v_inserted_id;

  RETURN jsonb_build_object('id', v_inserted_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_booking_enquiry TO anon;
GRANT EXECUTE ON FUNCTION public.create_booking_enquiry TO authenticated;
