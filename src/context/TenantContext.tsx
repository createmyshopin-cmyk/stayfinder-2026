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
 * 1. Subdomain (e.g., greenleaf.app.com)
 * 2. Custom domain mapping in tenants table
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

  // Try domain match
  const { data } = await supabase
    .from("tenants")
    .select("id, tenant_name")
    .eq("domain", hostname)
    .limit(1)
    .single();

  if (data) {
    return { id: data.id, name: data.tenant_name };
  }

  // Try subdomain match (e.g., greenleaf from greenleaf.app.com)
  const parts = hostname.split(".");
  if (parts.length >= 3) {
    const subdomain = parts[0];
    const { data: subData } = await supabase
      .from("tenants")
      .select("id, tenant_name")
      .ilike("domain", `%${subdomain}%`)
      .limit(1)
      .single();

    if (subData) {
      return { id: subData.id, name: subData.tenant_name };
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
