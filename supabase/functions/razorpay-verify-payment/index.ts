import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

async function verifySignature(orderId: string, paymentId: string, signature: string, secret: string): Promise<boolean> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw", encoder.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const data = encoder.encode(`${orderId}|${paymentId}`);
  const signatureBytes = await crypto.subtle.sign("HMAC", key, data);
  const expectedSignature = Array.from(new Uint8Array(signatureBytes))
    .map(b => b.toString(16).padStart(2, "0")).join("");
  return expectedSignature === signature;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET");
    if (!RAZORPAY_KEY_SECRET) {
      throw new Error("Razorpay secret not configured");
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

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

    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, tenant_id, plan_id, amount, currency = "INR" } = await req.json();

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return new Response(JSON.stringify({ error: "Missing payment details" }), { status: 400, headers: corsHeaders });
    }

    // Verify signature
    const isValid = await verifySignature(razorpay_order_id, razorpay_payment_id, razorpay_signature, RAZORPAY_KEY_SECRET);
    if (!isValid) {
      return new Response(JSON.stringify({ error: "Invalid payment signature" }), { status: 400, headers: corsHeaders });
    }

    // Record transaction
    const txId = `TX-${Date.now().toString(36).toUpperCase()}`;
    await supabaseAdmin.from("transactions").insert({
      transaction_id: txId,
      tenant_id,
      amount,
      currency,
      payment_method: "razorpay",
      status: "success",
      payment_gateway: "razorpay",
    });

    // Create or update subscription
    const renewalDate = new Date();
    renewalDate.setMonth(renewalDate.getMonth() + 1);

    const { data: existingSub } = await supabaseAdmin
      .from("subscriptions")
      .select("id")
      .eq("tenant_id", tenant_id)
      .limit(1)
      .single();

    if (existingSub) {
      await supabaseAdmin.from("subscriptions").update({
        plan_id,
        status: "active",
        renewal_date: renewalDate.toISOString().split("T")[0],
        payment_gateway: "razorpay",
      }).eq("id", existingSub.id);
    } else {
      await supabaseAdmin.from("subscriptions").insert({
        tenant_id,
        plan_id,
        start_date: new Date().toISOString().split("T")[0],
        renewal_date: renewalDate.toISOString().split("T")[0],
        billing_cycle: "monthly",
        status: "active",
        payment_gateway: "razorpay",
      });
    }

    // Update tenant status and plan
    await supabaseAdmin.from("tenants").update({
      status: "active",
      plan_id,
    }).eq("id", tenant_id);

    // Initialize usage tracking if not exists
    const { data: existingUsage } = await supabaseAdmin
      .from("tenant_usage")
      .select("id")
      .eq("tenant_id", tenant_id)
      .limit(1)
      .single();

    if (!existingUsage) {
      await supabaseAdmin.from("tenant_usage").insert({ tenant_id });
    }

    return new Response(JSON.stringify({
      success: true,
      transaction_id: txId,
      message: "Payment verified and subscription activated",
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Error verifying payment:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
