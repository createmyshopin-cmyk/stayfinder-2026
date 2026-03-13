
-- AI Settings (singleton row for global config)
CREATE TABLE public.ai_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  search_enabled boolean NOT NULL DEFAULT true,
  data_sources jsonb NOT NULL DEFAULT '["stays","room_categories","amenities","reviews","pricing"]'::jsonb,
  attraction_radius integer NOT NULL DEFAULT 10,
  auto_review_summary boolean NOT NULL DEFAULT false,
  recommendation_logic jsonb NOT NULL DEFAULT '["similar_price","similar_amenities","nearby_location","highest_rated"]'::jsonb,
  system_prompt text NOT NULL DEFAULT 'You are a travel assistant helping users find stays based on amenities, location, attractions, and price preferences.',
  blacklisted_words text[] NOT NULL DEFAULT '{}',
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage ai_settings" ON public.ai_settings FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can read ai_settings" ON public.ai_settings FOR SELECT USING (true);

-- Insert default settings row
INSERT INTO public.ai_settings (id) VALUES (gen_random_uuid());

-- AI Synonym Mapping
CREATE TABLE public.ai_synonyms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  query_term text NOT NULL,
  maps_to text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_synonyms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage ai_synonyms" ON public.ai_synonyms FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can read ai_synonyms" ON public.ai_synonyms FOR SELECT USING (true);

-- AI Search Query Logs
CREATE TABLE public.ai_search_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  query text NOT NULL,
  results_count integer NOT NULL DEFAULT 0,
  filters jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_search_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view search logs" ON public.ai_search_logs FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Public can insert search logs" ON public.ai_search_logs FOR INSERT WITH CHECK (true);
