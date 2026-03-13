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
    const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID");
    const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET");
    if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
      throw new Error("Razorpay credentials not configured");
    }

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

    const { tenant_id, plan_id, action } = await req.json();

    if (!tenant_id || !plan_id) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), { status: 400, headers: corsHeaders });
    }

    // Get plan details
    const { data: plan, error: planErr } = await supabaseAdmin
      .from("plans")
      .select("*")
      .eq("id", plan_id)
      .single();

    if (planErr || !plan) {
      return new Response(JSON.stringify({ error: "Plan not found" }), { status: 404, headers: corsHeaders });
    }

    // Get tenant + current subscription
    const { data: tenant } = await supabaseAdmin
      .from("tenants")
      .select("id, plan_id, status")
      .eq("id", tenant_id)
      .single();

    const { data: currentSub } = await supabaseAdmin
      .from("subscriptions")
      .select("*, plans:plan_id(*)")
      .eq("tenant_id", tenant_id)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    // Handle downgrade: schedule for next billing cycle
    if (action === "downgrade") {
      // If there is no subscription row yet, create a baseline row first,
      // then schedule the downgrade on that row.
      let targetSub = currentSub;

      if (!targetSub) {
        if (!tenant?.plan_id) {
          return new Response(JSON.stringify({ error: "No current plan found for tenant" }), { status: 400, headers: corsHeaders });
        }

        const baselineRenewal = new Date();
        baselineRenewal.setMonth(baselineRenewal.getMonth() + 1);

        const { data: insertedSub, error: insertErr } = await supabaseAdmin
          .from("subscriptions")
          .insert({
            tenant_id,
            plan_id: tenant.plan_id,
            status: tenant.status === "trial" ? "trial" : "active",
            billing_cycle: "monthly",
            start_date: new Date().toISOString().split("T")[0],
            renewal_date: baselineRenewal.toISOString().split("T")[0],
          })
          .select("*")
          .single();

        if (insertErr || !insertedSub) {
          return new Response(JSON.stringify({ error: "Failed to initialize subscription" }), { status: 500, headers: corsHeaders });
        }

        targetSub = insertedSub;
      }

      const effectiveDate = targetSub.renewal_date || new Date().toISOString().split("T")[0];

      await supabaseAdmin.from("subscriptions").update({
        scheduled_plan_id: plan_id,
        scheduled_at: new Date().toISOString(),
      }).eq("id", targetSub.id);

      return new Response(JSON.stringify({
        success: true,
        type: "downgrade_scheduled",
        message: `Downgrade to ${plan.plan_name} scheduled for ${effectiveDate}`,
        effective_date: effectiveDate,
      }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Calculate proration for upgrades
    let finalAmount = plan.price;
    let prorationCredit = 0;

    if (currentSub && currentSub.status === "active" && currentSub.renewal_date) {
      const currentPlan = currentSub.plans as any;
      if (currentPlan && currentPlan.price > 0) {
        const renewalDate = new Date(currentSub.renewal_date);
        const startDate = new Date(currentSub.start_date);
        const totalDays = Math.max(1, Math.ceil((renewalDate.getTime() - startDate.getTime()) / 86400000));
        const remainingDays = Math.max(0, Math.ceil((renewalDate.getTime() - Date.now()) / 86400000));
        const dailyRate = currentPlan.price / totalDays;
        prorationCredit = Math.round(dailyRate * remainingDays);
        finalAmount = Math.max(0, plan.price - prorationCredit);
      }
    }

    // If amount is 0 (e.g. free plan or full credit), activate directly
    if (finalAmount <= 0) {
      await activateSubscription(supabaseAdmin, tenant_id, plan_id, plan);
      return new Response(JSON.stringify({
        success: true,
        type: "activated",
        message: "Plan activated (covered by proration credit)",
      }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Create Razorpay order with prorated amount
    const credentials = btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);
    const orderRes = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        "Authorization": `Basic ${credentials}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: finalAmount * 100,
        currency: "INR",
        receipt: `upgrade_${tenant_id.substring(0, 8)}_${Date.now()}`,
        notes: { tenant_id, plan_id, proration_credit: prorationCredit },
      }),
    });

    if (!orderRes.ok) {
      const errBody = await orderRes.text();
      throw new Error(`Razorpay order creation failed: ${errBody}`);
    }

    const order = await orderRes.json();

    return new Response(JSON.stringify({
      type: "payment_required",
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      key_id: RAZORPAY_KEY_ID,
      original_price: plan.price,
      proration_credit: prorationCredit,
      final_amount: finalAmount,
      plan_name: plan.plan_name,
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

async function activateSubscription(supabaseAdmin: any, tenantId: string, planId: string, plan: any) {
  const renewalDate = new Date();
  if (plan.billing_cycle === "yearly") {
    renewalDate.setFullYear(renewalDate.getFullYear() + 1);
  } else {
    renewalDate.setMonth(renewalDate.getMonth() + 1);
  }

  const { data: existingSub } = await supabaseAdmin
    .from("subscriptions")
    .select("id")
    .eq("tenant_id", tenantId)
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (existingSub) {
    await supabaseAdmin.from("subscriptions").update({
      plan_id: planId,
      status: "active",
      start_date: new Date().toISOString().split("T")[0],
      renewal_date: renewalDate.toISOString().split("T")[0],
      scheduled_plan_id: null,
      scheduled_at: null,
    }).eq("id", existingSub.id);
  } else {
    await supabaseAdmin.from("subscriptions").insert({
      tenant_id: tenantId,
      plan_id: planId,
      status: "active",
      billing_cycle: plan.billing_cycle || "monthly",
      start_date: new Date().toISOString().split("T")[0],
      renewal_date: renewalDate.toISOString().split("T")[0],
    });
  }

  await supabaseAdmin.from("tenants").update({
    status: "active",
    plan_id: planId,
  }).eq("id", tenantId);

  // Ensure usage record exists
  const { data: usage } = await supabaseAdmin
    .from("tenant_usage")
    .select("id")
    .eq("tenant_id", tenantId)
    .limit(1)
    .single();

  if (!usage) {
    await supabaseAdmin.from("tenant_usage").insert({ tenant_id: tenantId });
  }
}
