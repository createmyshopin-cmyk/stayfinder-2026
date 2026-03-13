-- Confirm email for admin@admin.com (fix "Email not confirmed" error)
-- Run in Supabase SQL Editor

UPDATE auth.users
SET email_confirmed_at = now()
WHERE email = 'admin@admin.com' AND email_confirmed_at IS NULL;
