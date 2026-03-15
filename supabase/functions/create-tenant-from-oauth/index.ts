import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const slugify = (s: string) =>
  s.toLowerCase().replace(/[^a-z0-9-]/g, "").replace(/^-+|-+$/g, "");

/** Create tenant for a user who signed up via Google OAuth. User already exists in auth. */
serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceRoleKey);

    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Authorization required" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userErr } = await admin.auth.getUser(token);
    if (userErr || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body = await req.json();
    const { companyName, subdomain, whatsappNumber } = body as {
      companyName: string;
      subdomain: string;
      whatsappNumber?: string;
    };

    const company = (companyName || "").trim();
    const emailTrim = (user.email || "").trim().toLowerCase();
    const userId = user.id;

    if (!company || !emailTrim) {
      return new Response(
        JSON.stringify({ error: "Company name and email are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let slug = slugify(subdomain || "");
    if (!slug || slug.length < 2) {
      slug = slugify(emailTrim.split("@")[0] || "");
    }
    if (!slug || slug.length < 2) {
      return new Response(
        JSON.stringify({ error: "Subdomain must be at least 2 characters (letters, numbers, hyphens)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: existing } = await admin
      .from("tenant_domains")
      .select("id")
      .eq("subdomain", slug)
      .maybeSingle();
    if (existing) {
      return new Response(
        JSON.stringify({ error: `Subdomain "${slug}" is already taken` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Never merge: user already has a tenant → redirect to sign in, do NOT create
    const { data: existingTenant } = await admin
      .from("tenants")
      .select("id")
      .eq("user_id", userId)
      .maybeSingle();
    if (existingTenant) {
      return new Response(
        JSON.stringify({ already_has_account: true, message: "You already have an account. Please sign in." }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: starterPlan } = await admin
      .from("plans")
      .select("id")
      .eq("status", "active")
      .order("price", { ascending: true })
      .limit(1)
      .maybeSingle();

    if (!starterPlan?.id) {
      return new Response(
        JSON.stringify({ error: "No active plan found. Contact support." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const phone = (whatsappNumber || "").trim().replace(/\D/g, "") || "";

    const { data: tenant, error: tenantErr } = await admin
      .from("tenants")
      .insert({
        tenant_name: company,
        owner_name: company,
        email: emailTrim,
        phone: phone || emailTrim,
        domain: slug,
        status: "trial",
        plan_id: starterPlan.id,
        user_id: userId,
      })
      .select()
      .single();

    if (tenantErr) {
      return new Response(
        JSON.stringify({ error: tenantErr.message }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: autoVerifySetting } = await admin
      .from("saas_platform_settings")
      .select("setting_value")
      .eq("setting_key", "signup_auto_verify")
      .maybeSingle();
    const autoVerify = autoVerifySetting?.setting_value === "true";

    const domainPayload: { tenant_id: string; subdomain: string; verified?: boolean; ssl_status?: string } = {
      tenant_id: tenant.id,
      subdomain: slug,
    };
    if (autoVerify) {
      domainPayload.verified = true;
      domainPayload.ssl_status = "active";
    }
    await admin.from("tenant_domains").insert(domainPayload);

    const renewal = new Date();
    renewal.setDate(renewal.getDate() + 3);
    await admin.from("subscriptions").insert({
      tenant_id: tenant.id,
      plan_id: starterPlan.id,
      status: "trial",
      billing_cycle: "monthly",
      renewal_date: renewal.toISOString().split("T")[0],
    });

    await admin.from("tenant_usage").insert({ tenant_id: tenant.id });

    await admin.from("user_roles").upsert(
      { user_id: userId, role: "admin" },
      { onConflict: "user_id,role" }
    );

    return new Response(
      JSON.stringify({
        success: true,
        tenant_id: tenant.id,
        user_id: userId,
        message: "Account created. You can sign in now.",
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
