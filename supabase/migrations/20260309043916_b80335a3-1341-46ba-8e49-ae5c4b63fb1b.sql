
-- Drop the existing restrictive insert policy
DROP POLICY IF EXISTS "Public can create bookings" ON public.bookings;

-- Create a permissive insert policy for anonymous users
CREATE POLICY "Anyone can create bookings"
ON public.bookings
FOR INSERT
TO anon, authenticated
WITH CHECK (true);
