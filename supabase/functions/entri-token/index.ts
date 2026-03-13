import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) throw new Error("Missing authorization");

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Verify user
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: authErr } = await userClient.auth.getUser();
    if (authErr || !user) throw new Error("Unauthorized");

    // Check admin role
    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: isAdmin } = await adminClient.rpc("has_role", {
      _user_id: user.id,
      _role: "admin",
    });
    if (!isAdmin) throw new Error("Not authorized");

    // Get Entri credentials from saas_platform_settings
    const { data: appIdRow } = await adminClient
      .from("saas_platform_settings")
      .select("setting_value")
      .eq("setting_key", "entri_application_id")
      .single();

    const { data: secretRow } = await adminClient
      .from("saas_platform_settings")
      .select("setting_value")
      .eq("setting_key", "entri_secret")
      .single();

    const applicationId = appIdRow?.setting_value;
    const secret = secretRow?.setting_value;

    if (!applicationId || !secret) {
      return new Response(
        JSON.stringify({ success: false, message: "Entri credentials not configured. Ask your platform admin to set them up in SaaS Admin → Settings." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parse request body for DNS config
    const body = await req.json();
    const { domain } = body;

    if (!domain) throw new Error("Domain is required");

    // Generate Entri JWT token via Entri API
    const entriResponse = await fetch("https://api.goentri.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        applicationId,
        secret,
      }),
    });

    if (!entriResponse.ok) {
      const errText = await entriResponse.text();
      throw new Error(`Entri token generation failed: ${errText}`);
    }

    const entriData = await entriResponse.json();

    return new Response(
      JSON.stringify({
        success: true,
        token: entriData.token,
        applicationId,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ success: false, message: err.message }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
