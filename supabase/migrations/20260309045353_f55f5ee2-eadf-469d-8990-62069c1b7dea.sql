
-- Reels table for stays
CREATE TABLE public.stay_reels (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  stay_id UUID NOT NULL REFERENCES public.stays(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT '',
  thumbnail TEXT NOT NULL DEFAULT '',
  url TEXT NOT NULL DEFAULT '',
  platform TEXT NOT NULL DEFAULT 'youtube',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.stay_reels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage stay_reels" ON public.stay_reels FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view stay_reels" ON public.stay_reels FOR SELECT USING (true);

-- Nearby destinations table for stays
CREATE TABLE public.nearby_destinations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  stay_id UUID NOT NULL REFERENCES public.stays(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  image TEXT NOT NULL DEFAULT '',
  distance TEXT NOT NULL DEFAULT '',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.nearby_destinations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage nearby_destinations" ON public.nearby_destinations FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can view nearby_destinations" ON public.nearby_destinations FOR SELECT USING (true);
