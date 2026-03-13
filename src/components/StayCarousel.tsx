import { ChevronRight } from "lucide-react";
import { useStays } from "@/hooks/useStays";
import StayCard from "@/components/StayCard";

interface StayCarouselProps {
  title: string;
  category: string;
}

const StayCarousel = ({ title, category }: StayCarouselProps) => {
  const { stays, loading } = useStays(category);

  if (loading || stays.length === 0) return null;

  return (
    <section id="stays" className="py-4">
      <div className="flex items-center justify-between px-4 md:px-6 mb-3">
        <h3 className="text-base md:text-lg font-bold text-foreground">{title}</h3>
        <button className="flex items-center gap-0.5 text-sm font-semibold text-primary">
          View All <ChevronRight className="w-4 h-4" />
        </button>
      </div>

      {/* Mobile: horizontal scroll. Desktop: responsive grid */}
      <div
        className="
          flex gap-3 px-4 overflow-x-auto scrollbar-hide snap-x snap-mandatory touch-pan-x
          md:grid md:grid-cols-3 md:overflow-x-visible md:px-6 md:snap-none md:gap-4
          lg:grid-cols-4 lg:gap-5 xl:grid-cols-5
        "
        style={{ WebkitOverflowScrolling: "touch" }}
      >
        {stays.map((stay, i) => (
          <StayCard key={stay.id} stay={stay} index={i} />
        ))}
      </div>
    </section>
  );
};

export default StayCarousel;
