import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { toast } from "@/hooks/use-toast";
import { RefreshCw, Plus, Package, Pencil, Trash2 } from "lucide-react";

interface Plan {
  id: string; plan_name: string; price: number; billing_cycle: string;
  max_stays: number; max_rooms: number; max_bookings_per_month: number;
  max_ai_search: number; feature_flags: Record<string, boolean>; status: string;
}

const limitLabel = (v: number) => v === -1 ? "Unlimited" : v.toString();

const emptyForm = { plan_name: "", price: 0, billing_cycle: "monthly", max_stays: 1, max_rooms: 10, max_bookings_per_month: 50, max_ai_search: 100, status: "active" };

const SaasAdminPlans = () => {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editPlan, setEditPlan] = useState<Plan | null>(null);
  const [form, setForm] = useState(emptyForm);

  useEffect(() => { fetchPlans(); }, []);

  const fetchPlans = async () => {
    setLoading(true);
    const { data } = await supabase.from("plans").select("*").order("price");
    if (data) setPlans(data as Plan[]);
    setLoading(false);
  };

  const openNew = () => { setEditPlan(null); setForm(emptyForm); setShowForm(true); };
  const openEdit = (p: Plan) => {
    setEditPlan(p);
    setForm({ plan_name: p.plan_name, price: p.price, billing_cycle: p.billing_cycle, max_stays: p.max_stays, max_rooms: p.max_rooms, max_bookings_per_month: p.max_bookings_per_month, max_ai_search: p.max_ai_search, status: p.status });
    setShowForm(true);
  };

  const savePlan = async () => {
    if (!form.plan_name) return;
    if (editPlan) {
      const { error } = await supabase.from("plans").update(form).eq("id", editPlan.id);
      if (error) { toast({ title: "Error", description: error.message, variant: "destructive" }); return; }
      toast({ title: "Plan updated" });
    } else {
      const { error } = await supabase.from("plans").insert({ ...form, feature_flags: {} });
      if (error) { toast({ title: "Error", description: error.message, variant: "destructive" }); return; }
      toast({ title: "Plan created" });
    }
    setShowForm(false);
    fetchPlans();
  };

  const deletePlan = async (id: string) => {
    await supabase.from("plans").delete().eq("id", id);
    toast({ title: "Plan deleted" });
    fetchPlans();
  };

  if (loading) return <div className="flex items-center justify-center py-20"><RefreshCw className="w-6 h-6 animate-spin text-muted-foreground" /></div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2"><Package className="w-6 h-6 text-primary" /> Plans & Packages</h1>
          <p className="text-sm text-muted-foreground mt-1">Manage subscription plans</p>
        </div>
        <Button onClick={openNew}><Plus className="w-4 h-4 mr-1" /> New Plan</Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {plans.map(plan => (
          <Card key={plan.id} className="relative">
            <CardContent className="pt-6 space-y-3">
              <div className="flex items-center justify-between">
                <h3 className="font-bold text-lg">{plan.plan_name}</h3>
                <Badge variant={plan.status === "active" ? "default" : "secondary"}>{plan.status}</Badge>
              </div>
              <p className="text-3xl font-bold text-primary">₹{plan.price}<span className="text-sm font-normal text-muted-foreground">/{plan.billing_cycle}</span></p>
              <div className="space-y-1 text-sm text-muted-foreground">
                <p>Stays: {limitLabel(plan.max_stays)}</p>
                <p>Rooms: {limitLabel(plan.max_rooms)}</p>
                <p>Bookings/mo: {limitLabel(plan.max_bookings_per_month)}</p>
                <p>AI Searches: {limitLabel(plan.max_ai_search)}</p>
              </div>
              {Object.keys(plan.feature_flags).length > 0 && (
                <div className="flex flex-wrap gap-1 pt-2">
                  {Object.entries(plan.feature_flags).filter(([, v]) => v).map(([k]) => (
                    <Badge key={k} variant="outline" className="text-[10px]">{k.replace(/_/g, " ")}</Badge>
                  ))}
                </div>
              )}
              <div className="flex gap-2 pt-2">
                <Button size="sm" variant="outline" onClick={() => openEdit(plan)}><Pencil className="w-3 h-3 mr-1" /> Edit</Button>
                <Button size="sm" variant="ghost" className="text-destructive" onClick={() => deletePlan(plan.id)}><Trash2 className="w-3 h-3 mr-1" /> Delete</Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>{editPlan ? "Edit Plan" : "New Plan"}</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div><Label>Plan Name *</Label><Input value={form.plan_name} onChange={e => setForm({ ...form, plan_name: e.target.value })} className="mt-1" /></div>
            <div className="grid grid-cols-2 gap-3">
              <div><Label>Price (₹)</Label><Input type="number" value={form.price} onChange={e => setForm({ ...form, price: +e.target.value })} className="mt-1" /></div>
              <div><Label>Billing Cycle</Label><Input value={form.billing_cycle} onChange={e => setForm({ ...form, billing_cycle: e.target.value })} className="mt-1" /></div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div><Label>Max Stays (-1 = unlimited)</Label><Input type="number" value={form.max_stays} onChange={e => setForm({ ...form, max_stays: +e.target.value })} className="mt-1" /></div>
              <div><Label>Max Rooms</Label><Input type="number" value={form.max_rooms} onChange={e => setForm({ ...form, max_rooms: +e.target.value })} className="mt-1" /></div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div><Label>Max Bookings/mo</Label><Input type="number" value={form.max_bookings_per_month} onChange={e => setForm({ ...form, max_bookings_per_month: +e.target.value })} className="mt-1" /></div>
              <div><Label>Max AI Searches</Label><Input type="number" value={form.max_ai_search} onChange={e => setForm({ ...form, max_ai_search: +e.target.value })} className="mt-1" /></div>
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setShowForm(false)}>Cancel</Button>
              <Button onClick={savePlan}>{editPlan ? "Update" : "Create"}</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default SaasAdminPlans;
