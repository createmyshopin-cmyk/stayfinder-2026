CREATE OR REPLACE FUNCTION public.resolve_stay_uuid(_stay_id text)
RETURNS uuid
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT id FROM public.stays WHERE stay_id = _stay_id LIMIT 1
$$;