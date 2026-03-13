// One-time cleanup utility for corrupted calendar_pricing values.
// Secured to admin users.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type JsonResponse = {
  updated_price_rows: number;
  updated_original_price_rows: number;
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
    },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceKey) {
    return json({ error: "missing_env" }, 500);
  }

  const authHeader = req.headers.get("Authorization") ?? "";

  // Client scoped to the caller for auth
  const supabaseUser = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userErr } = await supabaseUser.auth.getUser();
  if (userErr || !userData?.user) return json({ error: "unauthorized" }, 401);

  // Admin client for privileged operations
  const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

  const { data: isAdmin, error: roleErr } = await supabaseAdmin.rpc("has_role", {
    _user_id: userData.user.id,
    _role: "admin",
  });

  if (roleErr) return json({ error: "role_check_failed" }, 500);
  if (!isAdmin) return json({ error: "forbidden" }, 403);

  // Count corrupted rows first (fast, head=true)
  const [{ count: priceCount }, { count: originalCount }] = await Promise.all([
    supabaseAdmin
      .from("calendar_pricing")
      .select("id", { count: "exact", head: true })
      .gt("price", 100000),
    supabaseAdmin
      .from("calendar_pricing")
      .select("id", { count: "exact", head: true })
      .gt("original_price", 100000),
  ]);

  // Normalize by capping at ₹100,000
  await Promise.all([
    supabaseAdmin
      .from("calendar_pricing")
      .update({ price: 100000 })
      .gt("price", 100000),
    supabaseAdmin
      .from("calendar_pricing")
      .update({ original_price: 100000 })
      .gt("original_price", 100000),
  ]);

  const res: JsonResponse = {
    updated_price_rows: priceCount ?? 0,
    updated_original_price_rows: originalCount ?? 0,
  };

  return json(res);
});
