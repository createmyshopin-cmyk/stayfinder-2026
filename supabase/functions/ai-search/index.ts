import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  try {
    const { query } = await req.json();
    if (!query || typeof query !== "string" || query.trim().length < 2) {
      return new Response(JSON.stringify({ stays: [], filters: [], summary: "" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) throw new Error("LOVABLE_API_KEY is not configured");

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Fetch AI settings
    const { data: settingsRow } = await supabase
      .from("ai_settings")
      .select("*")
      .limit(1)
      .single();

    const aiEnabled = settingsRow?.search_enabled ?? true;
    const dataSources: string[] = (settingsRow?.data_sources as string[]) ?? ["stays", "room_categories", "amenities", "reviews", "pricing"];
    const customPrompt = settingsRow?.system_prompt ?? "";
    const blacklist: string[] = settingsRow?.blacklisted_words ?? [];
    const aiModel: string = (settingsRow as any)?.ai_model ?? "google/gemini-3-flash-preview";

    // Check blacklisted words
    const queryLower = query.toLowerCase();
    if (blacklist.some((w: string) => queryLower.includes(w))) {
      return new Response(JSON.stringify({ stays: [], filters: [], summary: "Search blocked." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // If AI disabled, do basic text search fallback
    if (!aiEnabled) {
      const { data: fallbackStays } = await supabase
        .from("stays")
        .select("*")
        .eq("status", "active")
        .or(`name.ilike.%${query}%,location.ilike.%${query}%,category.ilike.%${query}%`);

      // Log query
      await supabase.from("ai_search_logs").insert({
        query: query.trim(),
        results_count: fallbackStays?.length || 0,
        filters: [] as any,
      });

      return new Response(JSON.stringify({ stays: fallbackStays || [], filters: [], summary: "" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch synonyms
    const { data: synonyms } = await supabase.from("ai_synonyms").select("*");
    const synonymMap = (synonyms || []).map((s: any) => `"${s.query_term}" → "${s.maps_to}"`).join(", ");

    // Fetch data based on enabled sources
    let stays: any[] = [];
    let rooms: any[] = [];

    if (dataSources.includes("stays")) {
      const { data } = await supabase.from("stays").select("*").eq("status", "active");
      stays = data || [];
    }

    if (dataSources.includes("room_categories")) {
      const { data } = await supabase.from("room_categories").select("*");
      rooms = data || [];
    }

    // Build context for AI
    const staysSummary = stays.map((s: any) => ({
      id: s.id,
      stay_id: s.stay_id,
      name: s.name,
      location: s.location,
      category: s.category,
      price: s.price,
      original_price: s.original_price,
      rating: s.rating,
      reviews_count: s.reviews_count,
      amenities: s.amenities,
      images: s.images,
    }));

    const roomsSummary = rooms.map((r: any) => ({
      stay_id: r.stay_id,
      name: r.name,
      price: r.price,
      max_guests: r.max_guests,
      amenities: r.amenities,
    }));

    const basePrompt = customPrompt || "You are a travel search assistant for StayFinder, a platform for stays in Wayanad, Kerala.";

    const systemPrompt = `${basePrompt}

Given the user's natural language search query and a list of available stays, return a JSON response with:
1. "matched_ids": array of stay "id" values (UUIDs) that best match the query, ordered by relevance (max 10)
2. "filters": array of suggested filter labels (max 5) e.g. ["Couple Friendly", "Pool", "Mountain View"]
3. "summary": a short one-line summary of what was searched for

Match based on:
- Stay name, location, category
- Amenities (e.g. "pool" matches stays with pool amenity)
- Price intent ("budget" = low price, "luxury" = high price)
- Category mapping: "romantic"/"honeymoon"/"couple" → "Couple Friendly", "family" → "Family Stay", "cheap"/"budget" → "Budget Rooms", "luxury"/"premium" → "Luxury Resort", "pool villa" → "Pool Villas", "treehouse" → "Tree Houses"
${synonymMap ? `- Additional synonym mappings: ${synonymMap}` : ""}
- Guest count: match room categories with sufficient max_guests
- If query mentions a specific attraction/place, match stays in nearby locations

Be generous with matching - if unsure, include the stay. Return at least some results if any stays exist.

AVAILABLE STAYS:
${JSON.stringify(staysSummary)}

${roomsSummary.length > 0 ? `ROOM CATEGORIES:\n${JSON.stringify(roomsSummary)}` : ""}

Respond ONLY with valid JSON, no markdown.`;

    const aiResponse = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: aiModel,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: query },
        ],
        temperature: 0.3,
      }),
    });

    if (!aiResponse.ok) {
      if (aiResponse.status === 429) {
        return new Response(JSON.stringify({ error: "Rate limit exceeded. Try again shortly." }), {
          status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      if (aiResponse.status === 402) {
        return new Response(JSON.stringify({ error: "AI credits depleted." }), {
          status: 402, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      const errText = await aiResponse.text();
      console.error("AI gateway error:", aiResponse.status, errText);
      throw new Error("AI gateway error");
    }

    const aiData = await aiResponse.json();
    const content = aiData.choices?.[0]?.message?.content || "{}";

    let parsed: { matched_ids?: string[]; filters?: string[]; summary?: string };
    try {
      const cleaned = content.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
      parsed = JSON.parse(cleaned);
    } catch {
      console.error("Failed to parse AI response:", content);
      parsed = { matched_ids: [], filters: [], summary: "" };
    }

    const matchedIds = parsed.matched_ids || [];
    let matchedStays: any[] = [];

    if (matchedIds.length > 0) {
      const { data: matched } = await supabase
        .from("stays")
        .select("*")
        .in("id", matchedIds)
        .eq("status", "active");

      const stayMap = new Map((matched || []).map((s: any) => [s.id, s]));
      matchedStays = matchedIds.map((id: string) => stayMap.get(id)).filter(Boolean);
    }

    // Log query
    await supabase.from("ai_search_logs").insert({
      query: query.trim(),
      results_count: matchedStays.length,
      filters: (parsed.filters || []) as any,
    });

    return new Response(
      JSON.stringify({
        stays: matchedStays,
        filters: parsed.filters || [],
        summary: parsed.summary || "",
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("ai-search error:", e);
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : "Unknown error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
