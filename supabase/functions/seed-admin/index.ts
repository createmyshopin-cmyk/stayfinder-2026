import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Create admin user
  const { data: authData, error: authError } = await supabase.auth.admin.createUser({
    email: "admin@admin.com",
    password: "admin.com",
    email_confirm: true,
  });

  if (authError && !authError.message.includes("already been registered")) {
    return new Response(JSON.stringify({ error: authError.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // Get user id
  let userId = authData?.user?.id;
  if (!userId) {
    const { data: users } = await supabase.auth.admin.listUsers();
    const adminUser = users?.users?.find((u: any) => u.email === "admin@admin.com");
    userId = adminUser?.id;
  }

  if (!userId) {
    return new Response(JSON.stringify({ error: "Could not find admin user" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // Assign admin role
  const { error: roleError } = await supabase
    .from("user_roles")
    .upsert({ user_id: userId, role: "admin" }, { onConflict: "user_id,role" });

  if (roleError) {
    return new Response(JSON.stringify({ error: roleError.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ success: true, userId }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
