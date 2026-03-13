
-- Add tenant_id to stays
ALTER TABLE public.stays ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to room_categories
ALTER TABLE public.room_categories ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to bookings
ALTER TABLE public.bookings ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to reviews
ALTER TABLE public.reviews ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to invoices
ALTER TABLE public.invoices ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to quotations
ALTER TABLE public.quotations ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to media
ALTER TABLE public.media ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to coupons
ALTER TABLE public.coupons ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Add tenant_id to ai_search_logs
ALTER TABLE public.ai_search_logs ADD COLUMN tenant_id uuid REFERENCES public.tenants(id) ON DELETE SET NULL;

-- Create indexes for tenant_id on all tables
CREATE INDEX idx_stays_tenant ON public.stays(tenant_id);
CREATE INDEX idx_room_categories_tenant ON public.room_categories(tenant_id);
CREATE INDEX idx_bookings_tenant ON public.bookings(tenant_id);
CREATE INDEX idx_reviews_tenant ON public.reviews(tenant_id);
CREATE INDEX idx_invoices_tenant ON public.invoices(tenant_id);
CREATE INDEX idx_quotations_tenant ON public.quotations(tenant_id);
CREATE INDEX idx_media_tenant ON public.media(tenant_id);
CREATE INDEX idx_coupons_tenant ON public.coupons(tenant_id);
CREATE INDEX idx_ai_search_logs_tenant ON public.ai_search_logs(tenant_id);
