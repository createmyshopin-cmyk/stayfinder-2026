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