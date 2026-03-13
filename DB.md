# STAY UI — Database Structure

> Supabase · PostgreSQL · 24 Tables · 5 Functions · 1 Enum · 2 Storage Buckets · 10 Edge Functions

---

## Enum

```sql
CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user', 'super_admin');
```

---

## Tables

### 1. `user_roles`
RBAC — links auth users to roles.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | gen_random_uuid() |
| user_id | uuid | → auth.users ON DELETE CASCADE |
| role | app_role | admin / moderator / user / super_admin |

**RLS:** Users view own roles; super_admin manages all.

---

### 2. `tenants`
Tenant (property owner) accounts.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| user_id | uuid | → auth.users (for RLS) |
| tenant_name | text | |
| owner_name | text | '' |
| email | text | '' |
| phone | text | '' |
| domain | text | '' |
| plan_id | uuid | → plans |
| status | text | 'trial' |
| logo_url | text | '' |
| favicon_url | text | '' |
| primary_color | text | '' |
| secondary_color | text | '' |
| footer_text | text | '' |
| created_at | timestamptz | now() |

**RLS:** Super admin manages all; tenant reads/updates own row via `user_id = auth.uid()`.

---

### 3. `stays`
Property listings with booking cooldown support.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | text UNIQUE | display ID |
| tenant_id | uuid | → tenants |
| name | text | |
| location | text | '' |
| description | text | '' |
| category | text | '' |
| rating | numeric | 0 |
| reviews_count | integer | 0 |
| price | integer | 0 |
| original_price | integer | 0 |
| amenities | text[] | {} |
| images | text[] | {} |
| status | text | 'active' |
| cooldown_minutes | integer | 1440 |
| created_at | timestamptz | now() |

- `cooldown_minutes`: Buffer minutes after checkout before next check-in. 0 = no buffer. 1440 = 24h (default). Supports fine-grained values like 5, 15, 30 min. Admin-adjustable per stay + per-date override in calendar_pricing.

**Indexes:** `tenant_id`, `status`, `category`  
**RLS:** Public SELECT where `status='active'`; tenant admin manages own stays; super admin manages all.

---

### 4. `room_categories`
Room types belonging to a stay.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays ON DELETE CASCADE |
| tenant_id | uuid | → tenants |
| name | text | |
| max_guests | integer | 2 |
| available | integer | 1 |
| amenities | text[] | {} |
| price | integer | 0 |
| original_price | integer | 0 |
| images | text[] | {} |

**RLS:** Public SELECT; tenant admin manages own; super admin manages all.

---

### 5. `bookings`
Guest reservations.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| booking_id | text UNIQUE | |
| stay_id | uuid | → stays ON DELETE SET NULL |
| tenant_id | uuid | → tenants |
| guest_name | text | |
| phone | text | '' |
| email | text | '' |
| checkin | date | |
| checkout | date | |
| adults | integer | 1 |
| children | integer | 0 |
| pets | integer | 0 |
| solo_traveller | boolean | false |
| group_booking | boolean | false |
| group_name | text | '' |
| rooms | jsonb | [] |
| addons | jsonb | [] |
| coupon_code | text | |
| total_price | integer | 0 |
| status | text | 'pending' |
| special_requests | text | |
| created_at | timestamptz | now() |

**Indexes:** `tenant_id`, `checkin`, `checkout`, `status`  
**RLS:** Public INSERT; tenant admin manages own; super admin manages all.

---

### 6. `add_ons`
Extra services available per stay.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays ON DELETE CASCADE |
| tenant_id | uuid | → tenants |
| name | text | |
| description | text | '' |
| price | integer | 0 |
| category | text | 'activity' |
| image_url | text | '' |
| active | boolean | true |
| created_at | timestamptz | now() |

**Indexes:** `tenant_id`, `active` (partial)  
**RLS:** Public SELECT where `active=true`; tenant admin manages own.

---

### 7. `calendar_pricing`
Dynamic pricing per date per room.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays ON DELETE CASCADE |
| room_category_id | uuid | → room_categories ON DELETE CASCADE |
| tenant_id | uuid | → tenants |
| date | date | |
| price | integer | 0 |
| original_price | integer | 0 |
| available | integer | 1 |
| is_blocked | boolean | false |
| min_nights | integer | 1 |
| created_at | timestamptz | now() |

**Indexes:** `tenant_id`, `(stay_id, date)`, `date`, `is_blocked` (partial)  
**RLS:** Public SELECT; tenant admin manages own.

---

### 8. `reviews`
Guest reviews for stays.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays ON DELETE CASCADE |
| tenant_id | uuid | → tenants |
| guest_name | text | |
| rating | integer | 5 |
| comment | text | '' |
| avatar_url | text | |
| photos | text[] | {} |
| status | text | 'pending' |
| created_at | timestamptz | now() |

**Indexes:** `tenant_id`, `status`  
**RLS:** Public SELECT where `status='approved'`; public INSERT; tenant admin manages own.

---

### 9. `stay_reels`
Video content per stay.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays |
| tenant_id | uuid | → tenants |
| url | text | |
| platform | text | instagram/youtube/facebook/tiktok |
| title | text | |
| thumbnail | text | |
| sort_order | integer | 0 |

**RLS:** Public SELECT; tenant admin manages own.

---

### 10. `nearby_destinations`
Points of interest near a stay.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays |
| tenant_id | uuid | → tenants |
| name | text | |
| image | text | |
| distance | text | |
| sort_order | integer | 0 |

**RLS:** Public SELECT; tenant admin manages own.

---

### 11. `coupons`
Discount codes with scheduling, usage limits, and stay targeting.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid | → tenants |
| code | text UNIQUE | |
| description | text | '' |
| type | text | percent/fixed |
| value | integer | 0 |
| min_purchase | integer | 0 |
| max_discount | integer | 0 |
| usage_count | integer | 0 |
| usage_limit | integer | NULL (unlimited) |
| active | boolean | true |
| starts_at | timestamptz | NULL (immediate) |
| expires_at | timestamptz | NULL (never) |
| applicable_stay_ids | jsonb | [] |

**RLS:** Tenant admin manages own; super admin manages all.

---

### 12. `quotations`
Price quotes generated for guests.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| quote_id | text UNIQUE | |
| tenant_id | uuid | → tenants |
| stay_id | uuid | → stays |
| guest_name | text | |
| phone | text | '' |
| email | text | '' |
| checkin | date | |
| checkout | date | |
| rooms | jsonb | [] |
| addons | jsonb | [] |
| discount | integer | 0 |
| coupon_code | text | |
| room_total | integer | 0 |
| addons_total | integer | 0 |
| total_price | integer | 0 |
| status | text | 'draft' |
| notes | text | '' |
| special_requests | text | |
| created_at | timestamptz | now() |
| updated_at | timestamptz | now() |

**RLS:** Tenant admin manages own; super admin manages all.

---

### 13. `invoices`
Payment invoices.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| invoice_id | text UNIQUE | |
| tenant_id | uuid | → tenants |
| booking_id | uuid | → bookings |
| quotation_id | uuid | → quotations |
| stay_id | uuid | → stays |
| guest_name | text | |
| phone | text | '' |
| email | text | '' |
| checkin | date | |
| checkout | date | |
| rooms | jsonb | [] |
| addons | jsonb | [] |
| room_total | integer | 0 |
| addons_total | integer | 0 |
| discount | integer | 0 |
| coupon_code | text | |
| total_price | integer | 0 |
| payment_status | text | 'pending' |
| payment_notes | text | '' |
| created_at | timestamptz | now() |
| updated_at | timestamptz | now() |

**RLS:** Tenant admin manages own; super admin manages all. *(No longer public — was a security hole)*

---

### 14. `plans`
SaaS subscription plans.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| plan_name | text | |
| price | integer | 0 |
| billing_cycle | text | 'monthly' |
| max_stays | integer | 1 |
| max_rooms | integer | 10 |
| max_bookings_per_month | integer | 50 |
| max_ai_search | integer | 100 |
| feature_flags | jsonb | {} |
| status | text | 'active' |
| created_at | timestamptz | now() |

**Seeded:** Starter (₹999), Pro (₹2999), Enterprise (₹6999)  
**RLS:** Public SELECT where `status='active'`; super admin manages all.

---

### 15. `features`
Feature registry.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| feature_name | text | |
| feature_key | text UNIQUE | |
| description | text | '' |
| status | text | 'active' |

**Seeded:** `ai_search`, `dynamic_pricing`, `coupons`, `reels`, `invoice_generator`, `quotation_generator`, `custom_domain`, `analytics`

---

### 16. `plan_features`
Feature toggles per plan.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| plan_id | uuid | → plans ON DELETE CASCADE |
| feature_key | text | |
| enabled | boolean | false |

---

### 17. `subscriptions`
Active tenant subscriptions.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid | → tenants ON DELETE CASCADE |
| plan_id | uuid | → plans |
| scheduled_plan_id | uuid | → plans (upgrade queue) |
| status | text | 'trial' |
| start_date | date | CURRENT_DATE |
| renewal_date | date | |
| billing_cycle | text | 'monthly' |
| payment_gateway | text | '' |
| razorpay_subscription_id | text | '' |
| created_at | timestamptz | now() |

**Indexes:** `tenant_id`  
**RLS:** Super admin manages all; tenant reads own.

---

### 18. `transactions`
Payment transaction records.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| transaction_id | text | |
| tenant_id | uuid | → tenants ON DELETE CASCADE |
| subscription_id | uuid | → subscriptions |
| amount | integer | 0 |
| currency | text | 'INR' |
| payment_method | text | '' |
| payment_gateway | text | '' |
| status | text | 'pending' |
| created_at | timestamptz | now() |

**Indexes:** `tenant_id`  
**RLS:** Super admin manages all; tenant reads own.

---

### 19. `tenant_usage`
Resource usage counters per tenant.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid UNIQUE | → tenants ON DELETE CASCADE |
| stays_created | integer | 0 |
| rooms_created | integer | 0 |
| bookings_this_month | integer | 0 |
| ai_search_count | integer | 0 |
| storage_used | bigint | 0 |
| last_reset | timestamptz | now() |

**RLS:** Super admin manages all; tenant reads own.

---

### 20. `tenant_domains`
Custom domain records.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| tenant_id | uuid | → tenants |
| subdomain | text | |
| custom_domain | text | |
| verified | boolean | false |
| ssl_status | text | |
| registrar | text | |
| auto_configured | boolean | false |

---

### 21. `tenant_registrar_keys`
API keys for domain registrars.

| Column | Type |
|--------|------|
| id | uuid PK |
| tenant_id | uuid |
| registrar | text |
| api_key | text |
| api_secret | text |

---

### 22. `site_settings` *(singleton)*
Per-tenant frontend configuration.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| site_name | text | 'StayFinder' |
| contact_email | text | '' |
| contact_phone | text | '' |
| whatsapp_number | text | '' |
| address | text | '' |
| social_instagram | text | '' |
| social_facebook | text | '' |
| social_youtube | text | '' |
| currency | text | 'INR' |
| booking_enabled | boolean | true |
| maintenance_mode | boolean | false |
| sticky_header_enabled | boolean | true |
| sticky_bottom_nav_enabled | boolean | true |
| updated_at | timestamptz | now() |

**RLS:** Public SELECT; tenant admin manages own.

---

### 23. `ai_settings` *(singleton)*
AI feature configuration.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| ai_model | text | 'google/gemini-3-flash-preview' |
| ai_personality | text | 'travel_assistant' |
| system_prompt | text | (default prompt) |
| search_enabled | boolean | true |
| response_length | text | 'medium' |
| cache_enabled | boolean | false |
| cache_duration | integer | 12 |
| attraction_radius | integer | 10 |
| auto_review_summary | boolean | false |
| blacklisted_words | text[] | {} |
| data_sources | jsonb | [...] |
| recommendation_logic | jsonb | [...] |
| feature_recommendations | boolean | true |
| feature_review_summaries | boolean | false |
| feature_stay_highlights | boolean | true |
| feature_query_suggestions | boolean | true |
| feature_chat_assistant | boolean | false |
| updated_at | timestamptz | now() |

**RLS:** Public SELECT; admin manages.

---

### 24. `ai_synonyms`
Search term synonym mapping.

| Column | Type |
|--------|------|
| id | uuid PK |
| query_term | text |
| maps_to | text |
| created_at | timestamptz |

---

### 25. `ai_search_logs`
Query analytics.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid | → tenants |
| query | text | |
| results_count | integer | 0 |
| filters | jsonb | [] |
| created_at | timestamptz | now() |

**RLS:** Public INSERT; tenant admin views own logs.

---

### 26. `stay_categories`
Category taxonomy for the filter UI.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid | → tenants |
| label | text | |
| icon | text | 'Tag' (Lucide icon name) |
| sort_order | integer | 0 |
| active | boolean | true |
| created_at | timestamptz | now() |

**Seeded:** Couple Friendly, Family Stay, Luxury Resort, Budget Rooms, Non AC Rooms, Pool Villas, Tree Houses  
**RLS:** Public SELECT where `active=true`; admin manages.

---

### 27. `announcements`
Platform-wide announcements from SaaS admin.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| title | text | |
| message | text | '' |
| type | text | 'info' |
| target | text | 'all' |
| published | boolean | false |
| created_at | timestamptz | now() |
| expires_at | timestamptz | |

**RLS:** Public SELECT where `published=true`; super_admin manages.

---

### 28. `media`
Media gallery.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| stay_id | uuid | → stays ON DELETE SET NULL |
| tenant_id | uuid | → tenants |
| url | text | |
| alt_text | text | '' |
| category | text | 'general' |
| created_at | timestamptz | now() |

**RLS:** Public SELECT; tenant admin manages own.

---

### 29. `saas_platform_settings`
Key/value store for platform-level config.

| Column | Type |
|--------|------|
| id | uuid PK |
| setting_key | text UNIQUE |
| setting_value | text |
| updated_at | timestamptz |

---

### 30. `guest_wishlist` *(New)*
Server-side wishlist persistence.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| session_id | text | Anonymous session token |
| user_id | uuid | → auth.users (nullable) |
| stay_id | uuid | → stays ON DELETE CASCADE |
| tenant_id | uuid | → tenants |
| created_at | timestamptz | now() |

**Unique:** `(session_id, stay_id)`  
**RLS:** Session can manage own wishlist; tenant admin can view for analytics.

---

### 31. `booking_timeline` *(New)*
Audit log for booking status changes.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| booking_id | uuid | → bookings ON DELETE CASCADE |
| tenant_id | uuid | → tenants |
| status | text | New status value |
| note | text | '' |
| changed_by | uuid | → auth.users (nullable) |
| created_at | timestamptz | now() |

**RLS:** Tenant admin manages own; super admin manages all; system can INSERT.

---

### 32. `accounting_transactions`
Central ledger for all income, expenses, and commission entries.

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid | → tenants |
| type | text | 'income'/'expense'/'commission' |
| category | text | 'general' |
| description | text | '' |
| amount | integer | 0 |
| date | date | CURRENT_DATE |
| booking_id | uuid | → bookings (nullable) |
| invoice_id | uuid | → invoices (nullable) |
| quotation_id | uuid | → quotations (nullable) |
| stay_id | uuid | → stays (nullable) |
| payment_method | text | 'cash' |
| reference_number | text | '' |
| notes | text | '' |
| tags | text[] | '{}' |
| created_at | timestamptz | now() |
| updated_at | timestamptz | now() |

**RLS:** Tenant admin manages own transactions.

---

### 33. `booking_ledger_entries`
Custom per-booking bookkeeping entries (additional charges, commissions, etc.)

| Column | Type | Default |
|--------|------|---------|
| id | uuid PK | |
| tenant_id | uuid | → tenants |
| booking_id | uuid | → bookings ON DELETE CASCADE |
| label | text | '' |
| amount | integer | 0 |
| type | text | 'income'/'expense'/'commission' |
| notes | text | '' |
| created_at | timestamptz | now() |

**RLS:** Tenant admin manages own entries.

---

## Functions

| Function | Returns | Purpose |
|----------|---------|---------|
| `has_role(user_id, app_role)` | boolean | RBAC check (SECURITY DEFINER) |
| `get_my_tenant_id()` | uuid | Returns tenant_id of calling auth user |
| `is_tenant_admin(tenant_id)` | boolean | RLS ownership check |
| `resolve_stay_uuid(stay_id)` | uuid | Text stay_id → UUID |
| `resolve_stay_uuid_flexible(id, name)` | uuid | Lookup by ID or name |

---

## Storage Buckets

| Bucket | Public | Purpose |
|--------|--------|---------|
| `branding` | ✅ | Tenant logos, favicons |
| `stay-images` | ✅ | Stay property photos |

---

## Edge Functions

| Function | Purpose |
|----------|---------|
| `ai-search` | AI-powered stay search (Gemini) |
| `razorpay-create-order` | Create Razorpay payment order |
| `razorpay-verify-payment` | Verify Razorpay webhook |
| `razorpay-create-subscription` | Create recurring subscription |
| `verify-domain` | Verify custom domain DNS |
| `subscription-renewal-cron` | Scheduled renewal processing |
| `auto-configure-domain` | Auto-configure DNS via registrar API |
| `entri-token` | Entri domain service token |
| `seed-admin` | Seed initial admin user |
| `normalize-calendar-pricing` | Normalize pricing data |

---

## Entity Relationships

```
tenants ──┬── stays ──┬── room_categories
          │           ├── bookings ──── booking_timeline
          │           ├── add_ons
          │           ├── calendar_pricing
          │           ├── reviews
          │           ├── stay_reels
          │           ├── nearby_destinations
          │           ├── media
          │           └── guest_wishlist
          ├── plans ──┬── plan_features
          │           └── subscriptions ── transactions
          ├── tenant_usage
          ├── tenant_domains
          ├── site_settings
          ├── ai_settings
          ├── ai_search_logs
          ├── stay_categories
          ├── coupons
          ├── quotations
          └── invoices

user_roles → auth.users
announcements (platform-wide, no tenant FK)
saas_platform_settings (platform-wide, no tenant FK)
```

---

## Migration Files

| File | Description |
|------|-------------|
| `20260308164058_…sql` | Core tables: user_roles, stays, room_categories, bookings |
| `20260308164820_…sql` | Additional columns |
| `20260308171055_…sql` | AI settings, ai_synonyms, ai_search_logs |
| `20260308171747_…sql` | Reviews, media, site_settings |
| `20260308172029_…sql` | Patches |
| `20260308172942_…sql` | AI settings extended columns |
| `20260308173348_…sql` | Quotations, invoices |
| `20260308175256_…sql` | Plans, features, plan_features, tenants, subscriptions, transactions, tenant_usage |
| `20260308180015_…sql` | Patches |
| `20260308181418_…sql` | Add tenant_id to all tables + indexes |
| `20260308181953_…sql` | Additional columns |
| `20260308182921_…sql` | calendar_pricing, add_ons, announcements |
| `20260308185205_…sql` | Patches |
| `20260308185958_…sql` | Patches |
| `20260308190220_…sql` | Patches |
| `20260308192629_…sql` | Patches |
| `20260308193608_…sql` | Patches |
| `20260308194724_…sql` | Patches |
| `20260308202709_…sql` | stay_categories + seed |
| `20260308204011_…sql` | Patches |
| `20260309032316_…sql` | Patches |
| `20260309033027_…sql` | Patches |
| `20260309033356_…sql` | Patches |
| `20260309043101_…sql` | Patches |
| `20260309043550_…sql` | Patches |
| `20260309043916_…sql` | Patches |
| `20260309044810_…sql` | Patches |
| `20260309045353_…sql` | Patches |
| `20260309050158_…sql` | Storage buckets (stay-images, branding) |
| **`20260313001000_schema_extension_rls_audit.sql`** | **RLS audit fixes + schema extensions + new tables** |
| `20260313100000_story_reel_settings.sql` | Story/reel settings |
| `20260313200000_coupon_enhancements.sql` | Coupon scheduling, usage limits, applicable stays |
| `20260313210000_stays_cooldown_hours.sql` | Cooldown minutes for stays + calendar_pricing |
| **`20260313220000_accounting_book.sql`** | **accounting_transactions, booking_ledger_entries + RLS** |
