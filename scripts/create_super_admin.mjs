const SUPABASE_URL = "https://rqnxtcigfauzzjaqxzut.supabase.co";
const SERVICE_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxbnh0Y2lnZmF1enpqYXF4enV0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MzM3ODQzNywiZXhwIjoyMDg4OTU0NDM3fQ.bDhDWYV0inYhgsaakK5K4UqKFGc2hJP73U_3SWuTlSg";

const headers = {
  "Content-Type": "application/json",
  Authorization: "Bearer " + SERVICE_KEY,
  apikey: SERVICE_KEY,
};

async function main() {
  console.log("Creating super admin user...");

  // Step 1: Create/get user via Admin API
  const res = await fetch(SUPABASE_URL + "/auth/v1/admin/users", {
    method: "POST",
    headers,
    body: JSON.stringify({
      email: "superadmin@stay.com",
      password: "superadmin123",
      email_confirm: true,
      user_metadata: { name: "Super Admin" },
    }),
  });

  const data = await res.json();

  if (data.code === "email_exists" || (data.msg && data.msg.includes("already"))) {
    console.log("User already exists, fetching ID...");
    // List users to find existing one
    const listRes = await fetch(SUPABASE_URL + "/auth/v1/admin/users?page=1&per_page=100", { headers });
    const listData = await listRes.json();
    const existing = (listData.users || []).find((u) => u.email === "superadmin@stay.com");
    if (existing) {
      await grantRole(existing.id);
    } else {
      console.error("Could not find existing user.");
    }
    return;
  }

  if (!data.id) {
    console.error("Failed to create user:", JSON.stringify(data, null, 2));
    return;
  }

  console.log("User created! ID:", data.id);
  await grantRole(data.id);
}

async function grantRole(userId) {
  console.log("Granting super_admin role to:", userId);

  const roleRes = await fetch(SUPABASE_URL + "/rest/v1/user_roles", {
    method: "POST",
    headers: {
      ...headers,
      Prefer: "resolution=ignore-duplicates",
    },
    body: JSON.stringify({ user_id: userId, role: "super_admin" }),
  });

  if (roleRes.status === 200 || roleRes.status === 201 || roleRes.status === 204) {
    console.log("✅ Done! Super admin ready.");
    console.log("   Email:    superadmin@stay.com");
    console.log("   Password: superadmin123");
    console.log("   URL:      /saas-admin/login");
  } else {
    const body = await roleRes.text();
    console.error("Role insert failed:", roleRes.status, body);
  }
}

main().catch(console.error);
