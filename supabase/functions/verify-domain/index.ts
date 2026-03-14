import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
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

    const { domain_id, domain } = await req.json();

    if (!domain_id && !domain) {
      return new Response(JSON.stringify({ error: "domain_id or domain required" }), { status: 400, headers: corsHeaders });
    }

    // If verifying a specific domain record
    let targetDomain = domain;
    if (domain_id) {
      const { data: domainRecord } = await supabaseAdmin
        .from("tenant_domains")
        .select("*")
        .eq("id", domain_id)
        .single();

      if (!domainRecord) {
        return new Response(JSON.stringify({ error: "Domain not found" }), { status: 404, headers: corsHeaders });
      }
      targetDomain = domainRecord.custom_domain;

      if (!targetDomain) {
        // Subdomain-only record, auto-verify
        await supabaseAdmin.from("tenant_domains").update({
          verified: true,
          ssl_status: "active",
        }).eq("id", domain_id);

        return new Response(JSON.stringify({
          success: true,
          verified: true,
          message: "Subdomain auto-verified",
        }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    if (!targetDomain) {
      return new Response(JSON.stringify({ error: "No domain to verify" }), { status: 400, headers: corsHeaders });
    }

    // Update status to verifying
    if (domain_id) {
      await supabaseAdmin.from("tenant_domains").update({
        ssl_status: "verifying",
      }).eq("id", domain_id);
    }

    // DNS verification: Check CNAME or A record
    const platformDomain = "cname.vercel-dns.com";
    let verified = false;
    let dnsRecords: string[] = [];

    try {
      // Use DNS over HTTPS (Cloudflare) to check CNAME
      const cnameRes = await fetch(
        `https://cloudflare-dns.com/dns-query?name=${encodeURIComponent(targetDomain)}&type=CNAME`,
        { headers: { "Accept": "application/dns-json" } }
      );
      const cnameData = await cnameRes.json();

      if (cnameData.Answer) {
        for (const record of cnameData.Answer) {
          const value = (record.data || "").replace(/\.$/, "").toLowerCase();
          dnsRecords.push(`CNAME: ${value}`);
          if (value === platformDomain || value.endsWith(`.${platformDomain}`)) {
            verified = true;
          }
        }
      }

      // Also check A records as fallback
      if (!verified) {
        const aRes = await fetch(
          `https://cloudflare-dns.com/dns-query?name=${encodeURIComponent(targetDomain)}&type=A`,
          { headers: { "Accept": "application/dns-json" } }
        );
        const aData = await aRes.json();

        if (aData.Answer) {
          for (const record of aData.Answer) {
            dnsRecords.push(`A: ${record.data}`);
            // Check if pointing to Vercel's IP
            if (record.data === "216.198.79.1") {
              verified = true;
            }
          }
        }
      }
    } catch (dnsErr) {
      console.error("DNS lookup failed:", dnsErr);
    }

    // Update domain record
    if (domain_id) {
      await supabaseAdmin.from("tenant_domains").update({
        verified,
        ssl_status: verified ? "active" : "failed",
      }).eq("id", domain_id);
    }

    return new Response(JSON.stringify({
      success: true,
      verified,
      dns_records: dnsRecords,
      message: verified
        ? "Domain verified! DNS is correctly configured."
        : `Domain not verified. Please add a CNAME record pointing to ${platformDomain}`,
      target: platformDomain,
    }), {
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
