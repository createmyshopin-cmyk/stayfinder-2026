-- Add Google Calendar integration fields to site_settings
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS gcal_webhook_url text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS gcal_calendar_id text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS gcal_enabled boolean NOT NULL DEFAULT false;
