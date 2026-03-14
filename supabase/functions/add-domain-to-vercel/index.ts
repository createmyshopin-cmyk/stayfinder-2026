import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
    }

    const supabaseUser = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userErr } = await supabaseUser.auth.getUser();
    if (userErr || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
    }

    const { domain } = await req.json();
    if (!domain) {
      return new Response(JSON.stringify({ error: "domain is required" }), { status: 400, headers: corsHeaders });
    }

    const VERCEL_TOKEN = Deno.env.get("VERCEL_TOKEN");
    const VERCEL_PROJECT_ID = Deno.env.get("VERCEL_PROJECT_ID");

    if (!VERCEL_TOKEN || !VERCEL_PROJECT_ID) {
      // Vercel integration not configured — silently succeed (manual setup)
      return new Response(JSON.stringify({ success: true, vercel_configured: false }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const vercelRes = await fetch(
      `https://api.vercel.com/v10/projects/${VERCEL_PROJECT_ID}/domains`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${VERCEL_TOKEN}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ name: domain }),
      }
    );

    // 409 = domain already exists in the project — treat as success
    const added = vercelRes.ok || vercelRes.status === 409;

    if (!added) {
      const errBody = await vercelRes.text();
      console.error("Vercel add domain failed:", vercelRes.status, errBody);
      return new Response(JSON.stringify({ success: false, error: `Vercel API error (${vercelRes.status})` }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: true, vercel_configured: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
