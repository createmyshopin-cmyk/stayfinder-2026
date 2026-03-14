import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { Lock } from "lucide-react";

/**
 * Tenant accounts login only.
 * Super admins are redirected to /saas-admin/login.
 */
export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { toast } = useToast();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const { data, error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      toast({ title: "Login failed", description: error.message, variant: "destructive" });
      setLoading(false);
      return;
    }

    const userId = data.user.id;

    // Super admins must use platform login
    const { data: isSuperAdmin } = await supabase.rpc("has_role", {
      _user_id: userId,
      _role: "super_admin",
    });
    if (isSuperAdmin) {
      await supabase.auth.signOut();
      toast({
        title: "Use platform admin login",
        description: "Platform admins sign in at /saas-admin/login",
        variant: "destructive",
      });
      navigate("/saas-admin/login", { replace: true });
      setLoading(false);
      return;
    }

    // Tenant accounts only — must have admin role
    const { data: hasAdminRole, error: roleError } = await supabase.rpc("has_role", {
      _user_id: userId,
      _role: "admin",
    });

    if (roleError || !hasAdminRole) {
      await supabase.auth.signOut();
      toast({
        title: "Access denied",
        description: "Create an account first below, or ask your platform admin to grant you access.",
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    toast({ title: "Welcome back!", description: "Redirecting to dashboard..." });

    // If on platform domain (not tenant subdomain), redirect to tenant's subdomain for better UX
    const hostname = window.location.hostname;
    const isPlatformDomain =
      hostname === "localhost" ||
      hostname.includes("vercel.app") ||
      hostname.includes("lovable.app") ||
      hostname.split(".").length < 3;

    if (isPlatformDomain) {
      const { data: tenant } = await supabase
        .from("tenants")
        .select("id")
        .eq("user_id", userId)
        .maybeSingle();
      if (tenant) {
        const { data: domain } = await supabase
          .from("tenant_domains")
          .select("subdomain")
          .eq("tenant_id", tenant.id)
          .not("subdomain", "is", null)
          .limit(1)
          .maybeSingle();
        const { data: suffixRow } = await supabase
          .from("saas_platform_settings")
          .select("setting_value")
          .eq("setting_key", "platform_subdomain_suffix")
          .maybeSingle();
        const suffix = suffixRow?.setting_value || ".travelvoo.in";
        const baseDomain = suffix.replace(/^\./, ""); // .travelvoo.in -> travelvoo.in
        if (domain?.subdomain && baseDomain) {
          const tenantUrl = `https://${domain.subdomain}.${baseDomain}/admin/dashboard`;
          window.location.href = tenantUrl;
          setLoading(false);
          return;
        }
      }
    }

    navigate("/admin/dashboard", { replace: true });
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-muted/30 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <Lock className="h-6 w-6 text-primary" />
          </div>
          <CardTitle className="text-2xl">Sign In</CardTitle>
          <CardDescription>Sign in to manage your stays and bookings</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleLogin} className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-foreground">Email</label>
              <Input
                type="email"
                placeholder="you@yourbusiness.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-foreground">Password</label>
              <Input
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Signing in…" : "Sign In"}
            </Button>
          </form>
          <p className="text-center text-sm text-muted-foreground mt-4">
            Don't have an account?{" "}
            <Link to="/create-account" className="text-primary hover:underline font-medium">
              Create one
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
