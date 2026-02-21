import { useEffect, useState } from "react";
import { Link } from "react-router";
import { stories } from "../data/stories";
import { Buddy } from "../components/Buddy";
import { Trophy, Flame, BookOpen, Star, Loader2 } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { projectId, publicAnonKey } from "../../../utils/supabase/info";

interface StoryProgress {
  segmentIndex: number;
  completed: boolean;
  lastAccessed: string;
}

interface UserProgress {
  [storyId: string]: StoryProgress | string | undefined;
  lastActive?: string;
}

export function Journal() {
  const { user } = useAuth();
  const [progressData, setProgressData] = useState<UserProgress | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const fetchProgress = async () => {
      try {
        const response = await fetch(
          `https://${projectId}.supabase.co/functions/v1/make-server-5b56fc96/progress/${user.id}`,
          { headers: { Authorization: `Bearer ${publicAnonKey}` } }
        );
        if (response.ok) {
          const data = await response.json();
          setProgressData(data);
        }
      } catch (error) {
        console.error("Failed to fetch journal data", error);
      } finally {
        setLoading(false);
      }
    };

    fetchProgress();
  }, [user]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full text-white">
        <Loader2 className="animate-spin text-green-500" size={48} />
      </div>
    );
  }

  // Calculate stats
  const completedCount = progressData
    ? Object.values(progressData).filter((val): val is StoryProgress => 
        typeof val === 'object' && val !== null && 'completed' in val && val.completed === true
      ).length
    : 0;

  // Simple streak calculation (mocked slightly as we only have lastActive)
  const lastActiveDate = progressData?.lastActive ? new Date(progressData.lastActive) : null;
  const isToday = lastActiveDate && new Date().toDateString() === lastActiveDate.toDateString();
  const streak = isToday ? 1 : 0; // In a real app, we'd need a full history of activity dates

  // Get recent stories
  const recentStoryIds = progressData 
    ? Object.keys(progressData).filter(key => key !== 'lastActive')
    : [];
  
  const recentStories = recentStoryIds
    .map(id => {
      const story = stories.find(s => s.id === id);
      const progress = progressData?.[id] as StoryProgress;
      return story && progress ? { ...story, ...progress } : null;
    })
    .filter((s): s is NonNullable<typeof s> => s !== null)
    .sort((a, b) => new Date(b.lastAccessed).getTime() - new Date(a.lastAccessed).getTime())
    .slice(0, 5);

  return (
    <div className="p-6 pb-32 max-w-md mx-auto space-y-8 text-white">
      <header className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold mb-1">My Journal</h1>
          <p className="text-gray-400 text-sm">Keep up the great work!</p>
        </div>
        <div className="bg-[#282828] p-3 rounded-full border border-[#3E3E3E]">
           <Buddy emotion="happy" className="w-12 h-12" />
        </div>
      </header>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-[#181818] p-5 rounded-2xl flex flex-col items-center justify-center text-center shadow-lg border border-[#333]">
          <div className="bg-orange-500/20 p-3 rounded-full mb-3 text-orange-500">
            <BookOpen size={24} />
          </div>
          <span className="text-4xl font-bold text-white mb-1">{completedCount}</span>
          <span className="text-xs font-bold text-gray-400 uppercase tracking-widest">Stories Read</span>
        </div>
        
        <div className="bg-[#181818] p-5 rounded-2xl flex flex-col items-center justify-center text-center shadow-lg border border-[#333]">
          <div className="bg-red-500/20 p-3 rounded-full mb-3 text-red-500">
             <Flame size={24} />
          </div>
          <span className="text-4xl font-bold text-white mb-1">{streak}</span>
          <span className="text-xs font-bold text-gray-400 uppercase tracking-widest">Day Streak</span>
        </div>
      </div>

      {/* Achievements / Badges */}
      <section>
        <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
          <Trophy className="text-yellow-500" size={20} />
          Badges
        </h2>
        <div className="flex gap-4 overflow-x-auto pb-4 scrollbar-hide -mx-6 px-6">
          <div className={`shrink-0 w-28 flex flex-col items-center gap-2 transition-opacity ${completedCount > 0 ? 'opacity-100' : 'opacity-40 grayscale'}`}>
            <div className="w-20 h-20 bg-[#282828] rounded-full flex items-center justify-center border-4 border-yellow-500 shadow-lg">
              <span className="text-3xl">🌟</span>
            </div>
            <span className="text-xs font-bold text-center text-gray-300">First Story</span>
          </div>
          <div className={`shrink-0 w-28 flex flex-col items-center gap-2 transition-opacity ${completedCount >= 5 ? 'opacity-100' : 'opacity-40 grayscale'}`}>
            <div className="w-20 h-20 bg-[#282828] rounded-full flex items-center justify-center border-4 border-blue-500 shadow-lg">
              <span className="text-3xl">🐛</span>
            </div>
            <span className="text-xs font-bold text-center text-gray-300">Bookworm</span>
          </div>
          <div className={`shrink-0 w-28 flex flex-col items-center gap-2 transition-opacity ${streak >= 7 ? 'opacity-100' : 'opacity-40 grayscale'}`}>
            <div className="w-20 h-20 bg-[#282828] rounded-full flex items-center justify-center border-4 border-gray-600 shadow-lg">
              <span className="text-3xl">🔥</span>
            </div>
            <span className="text-xs font-bold text-center text-gray-500">7 Day Streak</span>
          </div>
        </div>
      </section>

      {/* Recent History */}
      <section>
        <h2 className="text-xl font-bold mb-4">Recent Stories</h2>
        <div className="space-y-3">
          {recentStories.length > 0 ? (
            recentStories.map((story) => (
              <Link 
                to={`/story/${story.id}`}
                key={story.id} 
                className="flex items-center gap-4 bg-[#181818] p-3 rounded-xl border border-[#333] shadow-sm hover:bg-[#222] active:scale-[0.98] transition-all cursor-pointer"
              >
                <img src={story.coverImage} alt={story.title} className="w-14 h-14 rounded-lg object-cover" />
                <div className="flex-1 min-w-0">
                  <h3 className="font-bold text-base text-white mb-1 truncate">{story.title}</h3>
                  <div className="flex items-center gap-1 text-yellow-500">
                    {[...Array(story.completed ? 5 : 3)].map((_, i) => (
                       <Star key={i} size={12} fill="currentColor" />
                    ))}
                  </div>
                </div>
                <div className={`px-2 py-1 rounded-full text-xs font-bold border ${story.completed ? 'bg-green-500/20 text-green-400 border-green-500/30' : 'bg-blue-500/20 text-blue-400 border-blue-500/30'}`}>
                  {story.completed ? 'Done' : 'In Progress'}
                </div>
              </Link>
            ))
          ) : (
            <div className="text-center py-8 text-gray-500 text-sm">
              No stories read yet. Start reading!
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
