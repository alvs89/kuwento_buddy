import { Link, useSearchParams } from "react-router";
import { stories } from "../data/stories";
import { BookOpen, Search, X } from "lucide-react";

export function Library() {
  const [searchParams, setSearchParams] = useSearchParams();
  const categoryFilter = searchParams.get("category");
  const searchQuery = searchParams.get("q") || "";

  const filteredStories = stories.filter((story) => {
    const matchesCategory = categoryFilter
      ? story.category.toLowerCase().includes(categoryFilter.toLowerCase())
      : true;
    const matchesSearch = story.title.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const categories = Array.from(new Set(stories.map((s) => s.category)));

  return (
    <div className="p-6 pb-32 max-w-md mx-auto space-y-6 text-white">
      <div className="flex justify-between items-center mb-2">
        <h1 className="text-3xl font-bold">Library</h1>
        <div className="bg-[#282828] p-2 rounded-full border border-[#3E3E3E] shadow-sm">
           <BookOpen size={20} className="text-gray-200" />
        </div>
      </div>

      {/* Search & Filter */}
      <div className="space-y-4 sticky top-0 bg-[#121212] z-10 py-2 -mx-2 px-2">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            placeholder="Search titles..."
            className="w-full pl-10 pr-4 py-3 rounded-xl bg-[#181818] border border-[#333] focus:border-green-500 text-white placeholder-gray-500 text-sm focus:outline-none transition-all"
            value={searchQuery}
            onChange={(e) => setSearchParams({ ...Object.fromEntries(searchParams), q: e.target.value })}
          />
        </div>
        
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide -mx-2 px-2">
          <button
            onClick={() => {
              const newParams = new URLSearchParams(searchParams);
              newParams.delete("category");
              setSearchParams(newParams);
            }}
            className={`whitespace-nowrap px-4 py-1.5 rounded-full text-xs font-bold transition-colors border ${
              !categoryFilter
                ? "bg-white text-black border-white"
                : "bg-[#181818] text-gray-300 border-[#333] active:bg-[#282828]"
            }`}
          >
            All
          </button>
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => {
                const newParams = new URLSearchParams(searchParams);
                newParams.set("category", cat);
                setSearchParams(newParams);
              }}
              className={`whitespace-nowrap px-4 py-1.5 rounded-full text-xs font-bold transition-colors border ${
                categoryFilter === cat
                  ? "bg-white text-black border-white"
                  : "bg-[#181818] text-gray-300 border-[#333] active:bg-[#282828]"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-2 gap-4">
        {filteredStories.length > 0 ? (
          filteredStories.map((story) => (
            <Link key={story.id} to={`/story/${story.id}`} className="group block bg-[#181818] rounded-xl overflow-hidden active:bg-[#282828] transition-colors border border-[#333] shadow-sm">
              <div className="aspect-square relative overflow-hidden bg-[#121212]">
                <img
                  src={story.coverImage}
                  alt={story.title}
                  className="w-full h-full object-cover transition-transform duration-500"
                />
                <div className="absolute top-2 right-2 bg-black/60 backdrop-blur-md text-white text-[10px] font-bold px-1.5 py-0.5 rounded-md border border-white/10">
                  {story.level}
                </div>
              </div>
              <div className="p-3">
                <h3 className="font-bold text-sm text-white mb-1 truncate leading-tight">{story.title}</h3>
                <p className="text-[10px] text-gray-400 line-clamp-2 mb-2 leading-relaxed">{story.description}</p>
                <div className="flex items-center gap-1 text-[10px] text-green-400 font-bold uppercase tracking-wider">
                  <span>{story.category}</span>
                </div>
              </div>
            </Link>
          ))
        ) : (
          <div className="col-span-full py-12 text-center text-gray-500 flex flex-col items-center">
            <BookOpen size={48} className="opacity-20 mb-4" />
            <p className="text-sm">No stories found.</p>
            <button 
              onClick={() => setSearchParams({})}
              className="mt-2 text-green-500 text-sm font-bold active:underline"
            >
              Clear filters
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
