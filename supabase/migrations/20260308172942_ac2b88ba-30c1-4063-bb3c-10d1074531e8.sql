
ALTER TABLE public.ai_settings 
  ADD COLUMN IF NOT EXISTS ai_model text NOT NULL DEFAULT 'google/gemini-3-flash-preview',
  ADD COLUMN IF NOT EXISTS ai_personality text NOT NULL DEFAULT 'travel_assistant',
  ADD COLUMN IF NOT EXISTS response_length text NOT NULL DEFAULT 'medium',
  ADD COLUMN IF NOT EXISTS cache_enabled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cache_duration integer NOT NULL DEFAULT 12,
  ADD COLUMN IF NOT EXISTS feature_recommendations boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS feature_review_summaries boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS feature_stay_highlights boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS feature_query_suggestions boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS feature_chat_assistant boolean NOT NULL DEFAULT false;
