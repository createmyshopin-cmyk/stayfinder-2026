-- Fix plans RLS: update to super_admin (was 'admin' which doesn't match the role used)
DROP POLICY IF EXISTS "Admins can manage plans" ON public.plans;

CREATE POLICY "Super admins can manage plans" ON public.plans
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'super_admin'));
