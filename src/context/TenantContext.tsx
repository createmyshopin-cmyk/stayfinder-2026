import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { supabase } from "@/integrations/supabase/client";

interface TenantContextType {
  tenantId: string | null;
  tenantName: string | null;
  loading: boolean;
  setTenantId: (id: string | null) => void;
}

const TenantContext = createContext<TenantContextType>({
  tenantId: null,
  tenantName: null,
  loading: true,
  setTenantId: () => {},
});

export const useTenant = () => useContext(TenantContext);

/**
 * Resolves tenant from:
 * 1. Custom domain match in tenant_domains table (e.g., tajresort.com)
 * 2. Subdomain match in tenant_domains table (e.g., taj from taj.easystay.com)
 * 3. Falls back to null (platform-wide / no tenant)
 */
async function resolveTenant(): Promise<{ id: string; name: string } | null> {
  const hostname = window.location.hostname;

  // Skip for localhost / preview domains
  if (
    hostname === "localhost" ||
    hostname.includes("lovable.app") ||
    hostname.includes("lovableproject.com") ||
    hostname.includes("vercel.app")
  ) {
    return null;
  }

  // Step 1: Try exact custom domain match in tenant_domains
  const { data: domainMatch } = await supabase
    .from("tenant_domains")
    .select("tenant_id, tenants(id, tenant_name)")
    .eq("custom_domain", hostname)
    .eq("verified", true)
    .limit(1)
    .single();

  if (domainMatch?.tenant_id) {
    const tenant = domainMatch.tenants as { id: string; tenant_name: string } | null;
    return { id: domainMatch.tenant_id, name: tenant?.tenant_name ?? "" };
  }

  // Step 2: Try subdomain match (e.g., "taj" from "taj.easystay.com")
  const parts = hostname.split(".");
  if (parts.length >= 3) {
    const subdomain = parts[0];
    const { data: subMatch } = await supabase
      .from("tenant_domains")
      .select("tenant_id, tenants(id, tenant_name)")
      .eq("subdomain", subdomain)
      .limit(1)
      .single();

    if (subMatch?.tenant_id) {
      const tenant = subMatch.tenants as { id: string; tenant_name: string } | null;
      return { id: subMatch.tenant_id, name: tenant?.tenant_name ?? "" };
    }
  }

  return null;
}

export function TenantProvider({ children }: { children: ReactNode }) {
  const [tenantId, setTenantId] = useState<string | null>(null);
  const [tenantName, setTenantName] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    resolveTenant().then((tenant) => {
      if (tenant) {
        setTenantId(tenant.id);
        setTenantName(tenant.name);
      }
      setLoading(false);
    });
  }, []);

  return (
    <TenantContext.Provider value={{ tenantId, tenantName, loading, setTenantId }}>
      {children}
    </TenantContext.Provider>
  );
}
