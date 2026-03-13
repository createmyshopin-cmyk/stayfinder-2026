import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useLocation } from "react-router-dom";

interface SubscriptionStatus {
  loading: boolean;
  status: string;
  isExpired: boolean;
  isTrial: boolean;
  isActive: boolean;
  isSuspended: boolean;
  daysRemaining: number | null;
  plan: any;
  usage: any;
  canAccessFeatures: boolean;
}

export function useSubscriptionGuard(): SubscriptionStatus {
  const [state, setState] = useState<SubscriptionStatus>({
    loading: true,
    status: "trial",
    isExpired: false,
    isTrial: true,
    isActive: false,
    isSuspended: false,
    daysRemaining: null,
    plan: null,
    usage: null,
    canAccessFeatures: true,
  });

  const location = useLocation();

  useEffect(() => {
    const check = async () => {
      const { data: tenant } = await supabase.from("tenants").select("*").limit(1).single();
      if (!tenant) { setState((s) => ({ ...s, loading: false })); return; }

      const { data: sub } = await supabase
        .from("subscriptions")
        .select("*")
        .eq("tenant_id", tenant.id)
        .order("created_at", { ascending: false })
        .limit(1)
        .single();

      const { data: plan } = tenant.plan_id
        ? await supabase.from("plans").select("*").eq("id", tenant.plan_id).single()
        : { data: null };

      const { data: usage } = await supabase
        .from("tenant_usage")
        .select("*")
        .eq("tenant_id", tenant.id)
        .single();

      let daysRemaining: number | null = null;
      if (sub?.renewal_date) {
        daysRemaining = Math.ceil((new Date(sub.renewal_date).getTime() - Date.now()) / 86400000);
      }

      // Auto-expire trial if days remaining <= 0
      const status = sub?.status || tenant.status || "trial";
      const isTrialExpired = status === "trial" && daysRemaining !== null && daysRemaining <= 0;
      const effectiveStatus = isTrialExpired ? "expired" : status;

      const isExpired = effectiveStatus === "expired" || effectiveStatus === "cancelled";
      const isSuspended = effectiveStatus === "suspended";

      // When expired/suspended, only allow billing page access
      const billingPaths = ["/admin/account/billing"];
      const canAccessFeatures = !isExpired && !isSuspended || billingPaths.some((p) => location.pathname.startsWith(p));

      setState({
        loading: false,
        status: effectiveStatus,
        isExpired,
        isTrial: effectiveStatus === "trial",
        isActive: effectiveStatus === "active",
        isSuspended,
        daysRemaining,
        plan,
        usage,
        canAccessFeatures,
      });
    };
    check();
  }, [location.pathname]);

  return state;
}
