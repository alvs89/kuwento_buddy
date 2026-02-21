import { Link } from "react-router";
import { stories } from "../data/stories";
import { Buddy } from "../components/Buddy";
import { ArrowRight, BookOpen, Star } from "lucide-react";
import { useAuth } from "../context/AuthContext";

export function Home() {
  const { user } = useAuth();
  const featuredStory = stories[0]; 
  const recentStories = stories.slice(1, 4);

  const firstName = user?.user_metadata?.name?.split(" ")[0] || "Friend";

  return (
    <div className="p-6 pb-32 max-w-md mx-auto space-y-8 text-white">
      {/* Header */}
      <header className="flex justify-between items-end pt-4">
        <div>
          <p className="text-gray-400 text-xs font-bold uppercase tracking-wider mb-1">Good Afternoon</p>
          <h1 className="text-3xl font-bold">Hi, {firstName}</h1>
        </div>
        <div className="bg-[#282828] p-2 rounded-full border border-[#3E3E3E] shadow-sm">
           <Buddy emotion="happy" className="w-10 h-10" />
        </div>
      </header>

      {/* Buddy's Tip - Compact Card */}
      <section className="bg-gradient-to-br from-[#1e3a8a] to-[#0f172a] p-5 rounded-2xl border border-blue-900/50 relative overflow-hidden shadow-lg">
        <div className="relative z-10 flex gap-4 items-center">
          <div className="shrink-0 bg-blue-900/50 p-3 rounded-full">
             <Buddy emotion="thinking" className="w-10 h-10" />
          </div>
          <div>
            <h3 className="font-bold text-blue-200 mb-1 text-xs uppercase tracking-wider">Daily Tip</h3>
            <p className="text-sm text-white font-medium leading-relaxed">
              Asking <span className="text-blue-300 italic">"Why?"</span> helps you understand better!
            </p>
          </div>
        </div>
      </section>

      {/* Featured Story - Large Card */}
      <section>
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">Featured</h2>
        </div>
        
        <Link to={`/story/${featuredStory.id}`} className="block group relative rounded-2xl overflow-hidden shadow-2xl transition-transform active:scale-[0.98] border border-[#333]">
           <div className="aspect-[4/3] relative">
             <div className="absolute inset-0 bg-gradient-to-t from-black via-black/20 to-transparent z-10" />
             <img 
                src={featuredStory.coverImage} 
                alt={featuredStory.title}
                className="w-full h-full object-cover"
              />
              <div className="absolute bottom-0 left-0 p-5 z-20 w-full">
                <span className="inline-block px-2 py-0.5 bg-green-500 text-black text-[10px] font-bold uppercase tracking-widest rounded-sm mb-2">
                  {featuredStory.category}
                </span>
                <h3 className="text-2xl font-bold text-white mb-1 leading-tight">{featuredStory.title}</h3>
                <p className="text-gray-300 text-xs mb-3 line-clamp-2">{featuredStory.description}</p>
                
                <div className="flex items-center gap-2 text-xs font-bold bg-white/10 backdrop-blur-md px-3 py-2 rounded-full w-fit">
                   <BookOpen size={14} />
                   <span>Read Now</span>
                </div>
              </div>
           </div>
        </Link>
      </section>
      
      {/* Recent / Recommended List */}
      <section>
        <h2 className="text-xl font-bold mb-4">Recommended for You</h2>
        <div className="space-y-4">
          {recentStories.map((story) => (
            <Link key={story.id} to={`/story/${story.id}`} className="flex gap-4 bg-[#181818] p-3 rounded-xl border border-[#333] shadow-sm active:bg-[#282828] transition-colors">
              <img src={story.coverImage} alt={story.title} className="w-20 h-20 rounded-lg object-cover shrink-0" />
              <div className="flex flex-col justify-center min-w-0">
                <h3 className="font-bold text-base text-white mb-1 truncate">{story.title}</h3>
                <p className="text-xs text-gray-400 line-clamp-2 mb-2">{story.description}</p>
                <div className="flex items-center gap-2 text-[10px] text-gray-500 uppercase font-bold tracking-wider">
                  <span className="bg-[#282828] px-1.5 py-0.5 rounded border border-[#333]">{story.level}</span>
                  <span>•</span>
                  <span>{story.category}</span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* Categories - Grid */}
      <section>
        <h2 className="text-xl font-bold mb-4">Browse Categories</h2>
        <div className="grid grid-cols-2 gap-3">
          <Link to="/library?category=folktales" className="bg-[#181818] p-4 rounded-xl active:bg-[#282828] transition-colors border border-[#333] flex flex-col items-center text-center gap-2">
            <span className="text-3xl">🌿</span>
            <span className="font-bold text-sm text-gray-200">Folktales</span>
          </Link>
          <Link to="/library?category=adventure" className="bg-[#181818] p-4 rounded-xl active:bg-[#282828] transition-colors border border-[#333] flex flex-col items-center text-center gap-2">
            <span className="text-3xl">🗺️</span>
            <span className="font-bold text-sm text-gray-200">Adventure</span>
          </Link>
           <Link to="/library?category=legends" className="bg-[#181818] p-4 rounded-xl active:bg-[#282828] transition-colors border border-[#333] flex flex-col items-center text-center gap-2">
            <span className="text-3xl">🏰</span>
            <span className="font-bold text-sm text-gray-200">Legends</span>
          </Link>
           <Link to="/library" className="bg-[#181818] p-4 rounded-xl active:bg-[#282828] transition-colors border border-[#333] flex flex-col items-center text-center gap-2">
            <span className="text-3xl">📚</span>
            <span className="font-bold text-sm text-gray-200">All</span>
          </Link>
        </div>
      </section>
    </div>
  );
}
