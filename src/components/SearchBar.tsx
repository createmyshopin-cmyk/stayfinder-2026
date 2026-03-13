import { Search, X, Sparkles, Loader2, Mic, MicOff } from "lucide-react";
import { useState, useEffect, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { AnimatePresence, motion } from "framer-motion";
import { supabase } from "@/integrations/supabase/client";
import { Badge } from "@/components/ui/badge";
import { useVoiceSearch } from "@/hooks/useVoiceSearch";

const placeholders = [
  "romantic stay with pool...",
  "budget stay near Kalpetta...",
  "family resort for 5 people...",
  "treehouse in Wayanad...",
  "luxury stay with mountain view...",
];

const popularSearches = [
  "Couple Friendly Stays",
  "Budget Stays",
  "Pool Resorts",
  "Family Friendly",
  "Tree Houses",
  "Luxury Resorts",
];

interface SearchResult {
  id: string;
  stay_id: string;
  name: string;
  location: string;
  price: number;
  original_price: number;
  rating: number;
  category: string;
  images: string[];
  amenities: string[];
}

const SearchBar = () => {
  const [focused, setFocused] = useState(false);
  const [query, setQuery] = useState("");
  const [placeholderIndex, setPlaceholderIndex] = useState(0);
  const [results, setResults] = useState<SearchResult[]>([]);
  const [filters, setFilters] = useState<string[]>([]);
  const [summary, setSummary] = useState("");
  const [loading, setLoading] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();
  const navigate = useNavigate();

  const searchAI = useCallback(async (q: string) => {
    if (q.trim().length < 2) {
      setResults([]);
      setFilters([]);
      setSummary("");
      setHasSearched(false);
      return;
    }

    setLoading(true);
    setHasSearched(true);
    try {
      const { data, error } = await supabase.functions.invoke("ai-search", {
        body: { query: q },
      });
      if (error) throw error;
      setResults(data?.stays || []);
      setFilters(data?.filters || []);
      setSummary(data?.summary || "");
    } catch (err) {
      console.error("AI search error:", err);
      setResults([]);
      setFilters([]);
      setSummary("");
    } finally {
      setLoading(false);
    }
  }, []);

  const triggerSearch = useCallback((value: string) => {
    setQuery(value);
    setFocused(true);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => searchAI(value), 400);
  }, [searchAI]);

  const { isListening, isSupported, toggleListening } = useVoiceSearch({
    onResult: (transcript) => {
      triggerSearch(transcript);
    },
  });

  useEffect(() => {
    const interval = setInterval(() => {
      setPlaceholderIndex((i) => (i + 1) % placeholders.length);
    }, 2500);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setFocused(false);
    };
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  const handleChange = (value: string) => {
    triggerSearch(value);
  };

  const handlePopularClick = (term: string) => {
    setQuery(term);
    searchAI(term);
  };

  const handleResultClick = (stay: SearchResult) => {
    setFocused(false);
    navigate(`/stay/${stay.stay_id}`);
  };

  const clearSearch = () => {
    setQuery("");
    setResults([]);
    setFilters([]);
    setSummary("");
    setHasSearched(false);
  };

  return (
    <div ref={ref} className="relative px-4 py-3">
      {/* Search Input */}
      <div className={`relative flex items-center h-12 rounded-full bg-muted shadow-soft px-4 gap-3 transition-all focus-within:shadow-card border ${isListening ? "border-primary shadow-card" : "border-transparent focus-within:border-primary/30"}`}>
        {loading ? (
          <Loader2 className="w-5 h-5 text-primary shrink-0 animate-spin" />
        ) : (
          <Sparkles className="w-5 h-5 text-primary shrink-0" />
        )}
        <input
          type="text"
          value={query}
          onChange={(e) => handleChange(e.target.value)}
          onFocus={() => setFocused(true)}
          placeholder={isListening ? "Listening..." : placeholders[placeholderIndex]}
          className="flex-1 bg-transparent text-sm font-medium text-foreground placeholder:text-muted-foreground outline-none"
        />
        {query && (
          <button onClick={clearSearch} className="shrink-0">
            <X className="w-4 h-4 text-muted-foreground" />
          </button>
        )}
        {isSupported && (
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={toggleListening}
            className={`shrink-0 w-8 h-8 rounded-full flex items-center justify-center transition-colors ${
              isListening ? "bg-primary text-primary-foreground" : "hover:bg-muted-foreground/10 text-muted-foreground"
            }`}
            aria-label={isListening ? "Stop listening" : "Voice search"}
          >
            {isListening ? (
              <motion.div animate={{ scale: [1, 1.2, 1] }} transition={{ repeat: Infinity, duration: 1 }}>
                <Mic className="w-4 h-4" />
              </motion.div>
            ) : (
              <Mic className="w-4 h-4" />
            )}
          </motion.button>
        )}
      </div>

      {/* Voice Listening Indicator */}
      <AnimatePresence>
        {isListening && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="flex items-center justify-center gap-2 py-2"
          >
            <div className="flex gap-1">
              {[0, 1, 2, 3, 4].map((i) => (
                <motion.div
                  key={i}
                  className="w-1 bg-primary rounded-full"
                  animate={{ height: [8, 20, 8] }}
                  transition={{ repeat: Infinity, duration: 0.6, delay: i * 0.1 }}
                />
              ))}
            </div>
            <span className="text-xs text-primary font-medium">Listening...</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Dropdown */}
      <AnimatePresence>
        {focused && (
          <motion.div
            initial={{ opacity: 0, y: -4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -4 }}
            className="absolute left-4 right-4 top-full mt-1 bg-background rounded-xl shadow-elevated z-30 overflow-hidden border border-border max-h-[70vh] overflow-y-auto"
          >
            {/* AI Summary */}
            {summary && (
              <div className="px-4 py-2.5 bg-primary/5 border-b border-border flex items-start gap-2">
                <Sparkles className="w-4 h-4 text-primary mt-0.5 shrink-0" />
                <p className="text-xs text-foreground/80">{summary}</p>
              </div>
            )}

            {/* Suggested Filters */}
            {filters.length > 0 && (
              <div className="px-4 py-2.5 border-b border-border flex flex-wrap gap-1.5">
                {filters.map((f) => (
                  <Badge
                    key={f}
                    variant="secondary"
                    className="text-[11px] cursor-pointer hover:bg-primary/10 transition-colors"
                    onClick={() => handlePopularClick(f)}
                  >
                    {f}
                  </Badge>
                ))}
              </div>
            )}

            {/* Loading */}
            {loading && (
              <div className="flex items-center justify-center gap-2 py-6">
                <Loader2 className="w-4 h-4 animate-spin text-primary" />
                <p className="text-sm text-muted-foreground">AI is searching...</p>
              </div>
            )}

            {/* Results */}
            {!loading && results.length > 0 && (
              <div>
                {results.map((r) => (
                  <button
                    key={r.id}
                    className="flex items-center gap-3 w-full px-4 py-3 hover:bg-muted transition-colors text-left"
                    onClick={() => handleResultClick(r)}
                  >
                    <img src={r.images?.[0] || "/placeholder.svg"} alt={r.name} className="w-12 h-12 rounded-lg object-cover shrink-0" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-foreground truncate">{r.name}</p>
                      <p className="text-xs text-muted-foreground">{r.location}</p>
                    </div>
                    <div className="text-right shrink-0">
                      <p className="text-sm font-bold text-primary">₹{r.price.toLocaleString()}</p>
                      {r.rating > 0 && <p className="text-[11px] text-muted-foreground">⭐ {r.rating}</p>}
                    </div>
                  </button>
                ))}
              </div>
            )}

            {/* No Results */}
            {!loading && hasSearched && results.length === 0 && (
              <div className="px-4 py-6 text-center">
                <p className="text-sm text-muted-foreground">No stays found for your search</p>
                <p className="text-xs text-muted-foreground mt-1">Try different keywords</p>
              </div>
            )}

            {/* Popular Searches */}
            {!hasSearched && !loading && (
              <div className="px-4 py-3">
                <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Popular searches</p>
                <div className="flex flex-wrap gap-1.5">
                  {popularSearches.map((term) => (
                    <Badge
                      key={term}
                      variant="outline"
                      className="text-xs cursor-pointer hover:bg-primary/10 hover:border-primary/30 transition-colors"
                      onClick={() => handlePopularClick(term)}
                    >
                      {term}
                    </Badge>
                  ))}
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default SearchBar;
