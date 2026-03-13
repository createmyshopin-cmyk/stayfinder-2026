import { useParams, useNavigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import { useStays } from "@/hooks/useStays";
import StayCard from "@/components/StayCard";
import StickyHeader from "@/components/StickyHeader";
import StickyBottomNav from "@/components/StickyBottomNav";
import Footer from "@/components/Footer";

const CATEGORY_MAP: Record<string, string> = {
  "couple-friendly": "Couple Friendly",
  "family-stay":     "Family Stay",
  "luxury-resort":   "Luxury Resort",
  "budget-rooms":    "Budget Rooms",
  "non-ac-rooms":    "Non AC Rooms",
  "pool-villas":     "Pool Villas",
  "tree-houses":     "Tree Houses",
};

const SECTION_TITLE: Record<string, string> = {
  "couple-friendly": "Couple Friendly Stays",
  "family-stay":     "Family Stay Picks",
  "luxury-resort":   "Luxury Resorts",
  "budget-rooms":    "Budget Rooms",
  "non-ac-rooms":    "Non AC Rooms",
  "pool-villas":     "Pool Villas",
  "tree-houses":     "Tree Houses",
};

const CategoryPage = () => {
  const { slug = "" } = useParams<{ slug: string }>();
  const navigate = useNavigate();

  const category = CATEGORY_MAP[slug] ?? slug.replace(/-/g, " ").replace(/\b\w/g, c => c.toUpperCase());
  const title    = SECTION_TITLE[slug] ?? category;

  const { stays, loading } = useStays(category);

  return (
    <div className="min-h-screen bg-background">
      <StickyHeader />

      <div className="max-w-lg mx-auto md:max-w-5xl lg:max-w-7xl xl:max-w-[1400px] pb-[80px] md:pb-16 px-4 md:px-6">
        {/* Back + heading */}
        <div className="flex items-center gap-3 pt-4 pb-5">
          <button
            onClick={() => navigate(-1)}
            className="w-9 h-9 rounded-full bg-muted flex items-center justify-center hover:bg-muted/80 transition-colors"
            aria-label="Go back"
          >
            <ArrowLeft className="w-4 h-4 text-foreground" />
          </button>
          <h1 className="text-xl md:text-2xl font-bold text-foreground">{title}</h1>
          {!loading && (
            <span className="text-sm text-muted-foreground ml-1">({stays.length})</span>
          )}
        </div>

        {/* Grid */}
        {loading ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
            {Array.from({ length: 10 }).map((_, i) => (
              <div key={i} className="rounded-2xl bg-muted animate-pulse h-[260px]" />
            ))}
          </div>
        ) : stays.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-24 text-center">
            <p className="text-lg font-semibold text-foreground">No stays found</p>
            <p className="text-sm text-muted-foreground mt-1">Check back soon for new listings in this category.</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 md:gap-4 lg:gap-5">
            {stays.map((stay, i) => (
              <StayCard key={stay.id} stay={stay} index={i} />
            ))}
          </div>
        )}
      </div>

      <Footer />
      <StickyBottomNav />
    </div>
  );
};

export default CategoryPage;
