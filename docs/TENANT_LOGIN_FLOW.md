# Tenant Login Flow

## Overview

Tenant admins sign in at **`/login`** (tenant accounts only). Platform admins use **`/saas-admin/login`**.

## Flow for New Tenants

1. **Create account** → Go to `/create-account` on the main platform (e.g. `stayfinder-2026.vercel.app` or `travelvoo.in`)
2. Fill company name, email, password, WhatsApp
3. After signup → Account is created with:
   - Auth user
   - Tenant + subdomain (e.g. `greenleaf` → `greenleaf.travelvoo.in`)
   - `admin` role in `user_roles`
   - 3-day trial subscription
4. **Sign in** → Use `/login` with the same email/password

## Flow for Returning Tenants

1. Visit **`/login`** on any domain (main site or their subdomain)
2. Enter email + password
3. On success:
   - If on main platform → Redirects to `https://{subdomain}.{base_domain}/admin/dashboard`
   - If already on subdomain → Goes to `/admin/dashboard`

## Fixing "Access Denied"

**Cause:** The user does not have the `admin` role in `user_roles`, or has no tenant linked via `tenants.user_id`.

**Options:**

1. **New user** → Sign up at `/create-account`
2. **Existing tenant, no access** → SaaS admin grants access:
   - SaaS Admin → Tenants → View tenant → **Grant Admin Access**
   - This runs `grant-tenant-admin` Edge Function
3. **Manual DB fix** (Supabase SQL Editor):

```sql
-- Get user id: auth.users where email = 'dude@dude.com'
-- Get tenant id: tenants where email = 'dude@dude.com' or owner matches

-- Add admin role
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' FROM auth.users WHERE email = 'dude@dude.com'
ON CONFLICT (user_id, role) DO NOTHING;

-- Link tenant to user (required for get_my_tenant_id)
UPDATE public.tenants
SET user_id = (SELECT id FROM auth.users WHERE email = 'dude@dude.com' LIMIT 1)
WHERE email = 'dude@dude.com';
```

## URLs Summary

| Who              | Login URL            | After login              |
|------------------|----------------------|--------------------------|
| Tenant admin     | `/login`             | `/admin/dashboard`       |
| Platform admin   | `/saas-admin/login`  | `/saas-admin/dashboard`  |
| Create tenant    | `/create-account`    | Auto sign-in + dashboard |
