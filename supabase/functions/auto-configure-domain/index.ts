import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
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

    const token = authHeader.replace("Bearer ", "");
    const { data: claimsData, error: claimsErr } = await supabaseUser.auth.getClaims(token);
    if (claimsErr || !claimsData?.claims) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { tenant_id, domain, registrar, api_key, api_secret, domain_id, save_credentials } = await req.json();

    if (!tenant_id || !domain || !registrar) {
      return new Response(JSON.stringify({ error: "tenant_id, domain, and registrar are required" }), {
        status: 400, headers: corsHeaders,
      });
    }

    // Determine credentials: use provided or fetch saved
    let key = api_key;
    let secret = api_secret;

    if (!key) {
      const { data: savedCreds } = await supabaseAdmin
        .from("tenant_registrar_keys")
        .select("api_key, api_secret")
        .eq("tenant_id", tenant_id)
        .eq("registrar", registrar)
        .single();

      if (!savedCreds) {
        return new Response(JSON.stringify({ error: "No saved credentials found. Please provide API credentials." }), {
          status: 400, headers: corsHeaders,
        });
      }
      key = savedCreds.api_key;
      secret = savedCreds.api_secret;
    }

    // Save credentials if requested
    if (save_credentials && api_key) {
      await supabaseAdmin.from("tenant_registrar_keys").upsert({
        tenant_id,
        registrar,
        api_key,
        api_secret: api_secret || "",
        updated_at: new Date().toISOString(),
      }, { onConflict: "tenant_id,registrar" });
    }

    // Parse domain parts
    const parts = domain.split(".");
    let recordName: string;
    let baseDomain: string;

    if (parts.length >= 3) {
      // subdomain.domain.tld → recordName = subdomain, baseDomain = domain.tld
      recordName = parts.slice(0, parts.length - 2).join(".");
      baseDomain = parts.slice(-2).join(".");
    } else {
      // domain.tld → recordName = @, baseDomain = domain.tld
      recordName = "@";
      baseDomain = domain;
    }

    const platformDomain = "cname.vercel-dns.com";
    let success = false;
    let message = "";

    if (registrar === "godaddy") {
      // GoDaddy API: PUT CNAME record
      try {
        const gdUrl = `https://api.godaddy.com/v1/domains/${baseDomain}/records/CNAME/${recordName}`;
        const gdRes = await fetch(gdUrl, {
          method: "PUT",
          headers: {
            "Authorization": `sso-key ${key}:${secret}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify([{
            data: platformDomain,
            ttl: 600,
          }]),
        });

        if (gdRes.ok) {
          success = true;
          message = "CNAME record created via GoDaddy API";
        } else {
          const errBody = await gdRes.text();
          message = `GoDaddy API error (${gdRes.status}): ${errBody}`;
        }
      } catch (err) {
        message = `GoDaddy API call failed: ${err.message}`;
      }
    } else if (registrar === "hostinger") {
      // Hostinger DNS API
      try {
        const hUrl = `https://api.hostinger.com/api/dns/v1/zones/${baseDomain}`;
        const hRes = await fetch(hUrl, {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${key}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            records: [{
              type: "CNAME",
              name: recordName === "@" ? "" : recordName,
              content: platformDomain,
              ttl: 600,
            }],
          }),
        });

        if (hRes.ok || hRes.status === 201) {
          success = true;
          message = "CNAME record created via Hostinger API";
        } else {
          const errBody = await hRes.text();
          message = `Hostinger API error (${hRes.status}): ${errBody}`;
        }
      } catch (err) {
        message = `Hostinger API call failed: ${err.message}`;
      }
    } else {
      return new Response(JSON.stringify({ error: `Unsupported registrar: ${registrar}` }), {
        status: 400, headers: corsHeaders,
      });
    }

    // Update domain record if we have a domain_id
    if (domain_id && success) {
      await supabaseAdmin.from("tenant_domains").update({
        registrar,
        auto_configured: true,
        ssl_status: "verifying",
      }).eq("id", domain_id);
    }

    // Register domain with Vercel project so traffic is routed correctly
    let vercelAdded = false;
    const VERCEL_TOKEN = Deno.env.get("VERCEL_TOKEN");
    const VERCEL_PROJECT_ID = Deno.env.get("VERCEL_PROJECT_ID");
    const VERCEL_TEAM_ID = Deno.env.get("VERCEL_TEAM_ID");

    if (VERCEL_TOKEN && VERCEL_PROJECT_ID && success) {
      try {
        const teamQuery = VERCEL_TEAM_ID ? `?teamId=${VERCEL_TEAM_ID}` : "";
        const vercelRes = await fetch(
          `https://api.vercel.com/v10/projects/${VERCEL_PROJECT_ID}/domains${teamQuery}`,
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${VERCEL_TOKEN}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ name: domain }),
          }
        );
        vercelAdded = vercelRes.ok || vercelRes.status === 409; // 409 = already exists, that's fine
        if (!vercelAdded) {
          const vercelErr = await vercelRes.text();
          console.error("Vercel domain add failed:", vercelErr);
        }
      } catch (err) {
        console.error("Vercel API call failed:", err.message);
      }
    }

    return new Response(JSON.stringify({
      success,
      message,
      auto_configured: success,
      vercel_domain_added: vercelAdded,
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
