# Admin Login Setup

There are **no default credentials**. You must create your first admin account.

---

## Demo Admin (quickest)

**Credentials:** `admin@admin.com` / `admin.com`

1. Open [Supabase SQL Editor](https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/sql/new)
2. Paste and run the contents of **`supabase/seed_demo_admin.sql`**
3. Log in at **`/admin/login`** with the demo credentials

**If you get "Email not confirmed":** Run **`supabase/confirm_demo_email.sql`** in the SQL Editor. Or turn off email confirmation: [Supabase Dashboard → Authentication → Providers → Email](https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/auth/providers) → uncheck **"Confirm email"**.

---

## Option 1: Create admin via app

1. Go to **`/admin/create`** in your app
2. Fill in email, password (min 6 chars), resort name, owner name
3. Submit — creates tenant + admin account
4. Log in at **`/admin/login`**

---

## Option 2: Manual setup via Supabase Dashboard

Use this if `/signup` fails (e.g. empty plans table) or you want a quick test admin.

### Step 1: Create auth user

1. Open [Supabase Dashboard → Authentication → Users](https://supabase.com/dashboard/project/rqnxtcigfauzzjaqxzut/auth/users)
2. Click **Add user** → **Create new user**
3. Enter email and password (min 6 chars)
4. Click **Create user**
5. Copy the **User UID** (you’ll need it)

### Step 2: Create tenant (if needed)

Run in **SQL Editor**:

```sql
-- Create a tenant (replace values as needed)
INSERT INTO public.tenants (tenant_name, owner_name, email, phone, domain, status, user_id)
VALUES (
  'My Resort',
  'Admin User',
  'admin@example.com',  -- must match auth user email
  '+919876543210',
  'my-resort',
  'trial',
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'  -- paste the User UID from Step 1
)
RETURNING id;
```

Copy the returned `id` for the next step.

### Step 3: Link stays/bookings to tenant (optional)

If you already have stays/data, update `tenant_id`:

```sql
UPDATE public.stays SET tenant_id = '<tenant-id-from-step-2>' WHERE tenant_id IS NULL;
UPDATE public.bookings SET tenant_id = '<tenant-id-from-step-2>' WHERE tenant_id IS NULL;
-- repeat for other tenant-scoped tables as needed
```

### Step 4: Assign admin role

```sql
-- Replace with your User UID from Step 1
INSERT INTO public.user_roles (user_id, role)
VALUES ('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', 'admin');
```

### Step 5: Log in

- Go to **`/admin/login`**
- Use the email and password from Step 1

---

## Quick test admin (minimal)

If you only need to test login and the admin panel:

1. Create user in Authentication (email: `admin@test.com`, password: `admin123`)
2. Run in SQL Editor:

```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'::app_role FROM auth.users WHERE email = 'admin@test.com' LIMIT 1;
```

3. Log in at `/admin/login` with `admin@test.com` / `admin123`

**Note:** Without a tenant linked via `tenants.user_id`, you can log in but tenant-scoped data (stays, bookings, etc.) may be empty. For full access, use Option 2 with a tenant.

---

## Admin URLs

| Page | URL |
|------|-----|
| Login | `/admin/login` |
| Dashboard | `/admin/dashboard` |
| Create admin | `/admin/create` |
