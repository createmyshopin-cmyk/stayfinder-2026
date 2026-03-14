-- Allow users with admin role to SELECT all bookings (fixes "No rows returned" when
-- tenant linkage or policy logic blocks visibility)
DROP POLICY IF EXISTS "Admin role can select all bookings" ON public.bookings;
CREATE POLICY "Admin role can select all bookings"
  ON public.bookings
  FOR SELECT
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));
