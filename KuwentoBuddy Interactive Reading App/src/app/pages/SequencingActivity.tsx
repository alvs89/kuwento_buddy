import { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router";
import { stories } from "../data/stories";
import { Buddy } from "../components/Buddy";
import { ArrowLeft, Check, RefreshCw, Library as LibraryIcon, RotateCcw, Sparkles, BookOpen } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import confetti from "canvas-confetti";
import { useAuth } from "../context/AuthContext";
import { projectId, publicAnonKey } from "../../../utils/supabase/info";

export function SequencingActivity() {
  const { storyId } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const story = stories.find((s) => s.id === storyId);

  // State
  const [availableItems, setAvailableItems] = useState<{ originalIndex: number, text: string }[]>([]);
  const [solvedItems, setSolvedItems] = useState<{ originalIndex: number, text: string }[]>([]);
  const [errorId, setErrorId] = useState<number | null>(null);
  const [isComplete, setIsComplete] = useState(false);
  const [showCompletionDialog, setShowCompletionDialog] = useState(false);
  const [isResetting, setIsResetting] = useState(false);

  useEffect(() => {
    if (story) {
      const items = story.sequencingEvents.map((text, index) => ({
        originalIndex: index,
        text
      }));
      // Shuffle
      setAvailableItems([...items].sort(() => Math.random() - 0.5));
    }
  }, [story]);

  if (!story) return <div className="text-white text-center p-8">Story not found</div>;

  const handleItemClick = (item: { originalIndex: number, text: string }) => {
    const nextExpectedIndex = solvedItems.length;

    if (item.originalIndex === nextExpectedIndex) {
      // Correct
      setSolvedItems([...solvedItems, item]);
      setAvailableItems(availableItems.filter((i) => i.originalIndex !== item.originalIndex));
      
      if (solvedItems.length + 1 === story.sequencingEvents.length) {
        setIsComplete(true);
        confetti({
          particleCount: 150,
          spread: 100,
          origin: { y: 0.6 }
        });
        // Show the completion dialog after a brief moment to let confetti land
        setTimeout(() => setShowCompletionDialog(true), 600);
      }
    } else {
      // Incorrect
      setErrorId(item.originalIndex);
      setTimeout(() => setErrorId(null), 500);
    }
  };

  const handleReadAgain = async () => {
    if (!user || !storyId) {
      navigate(`/story/${storyId}`, { state: { fromReadAgain: true } });
      return;
    }
    setIsResetting(true);
    try {
      await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-5b56fc96/progress`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${publicAnonKey}`
          },
          body: JSON.stringify({
            userId: user.id,
            storyId,
            segmentIndex: 0,
            completed: false
          })
        }
      );
      navigate(`/story/${storyId}`, { state: { fromReadAgain: true } });
    } catch (error) {
      console.error("Failed to reset story for re-read", error);
      navigate(`/story/${storyId}`, { state: { fromReadAgain: true } });
    }
  };

  return (
    <div className="min-h-screen bg-[#121212] font-sans text-white flex flex-col">
      {/* Header */}
      <div className="p-4 flex items-center bg-[#0a1e33] border-b border-white/5">
         <Link to="/library" className="p-2 -ml-2 text-gray-400 hover:text-white">
            <ArrowLeft size={24} />
         </Link>
         <h1 className="font-bold text-lg ml-2">Activity</h1>
      </div>

      <div className="flex-1 p-6 pb-24 overflow-y-auto flex flex-col items-center">
        
        <div className="text-center mb-6">
          <h2 className="text-2xl font-bold text-white mb-2">What Happened?</h2>
          <p className="text-gray-400 text-sm mb-4">Tap the events in the correct order.</p>
          <div className="relative inline-block overflow-visible mb-4">
            <Buddy 
              emotion={isComplete ? "happy" : "thinking"} 
              className="w-24 h-24 mx-auto drop-shadow-lg" 
              hint={
                errorId !== null ? "Try a different order!" :
                undefined
              }
            />
          </div>
        </div>

        {/* Timeline (Solved) */}
        <div className="w-full max-w-md space-y-3 mb-6 min-h-[50px]">
          <AnimatePresence>
            {solvedItems.map((item, idx) => (
              <motion.div
                key={`solved-${item.originalIndex}`}
                initial={{ opacity: 0, height: 0, y: 10 }}
                animate={{ opacity: 1, height: "auto", y: 0 }}
                className="bg-[#1e1e1e] p-4 rounded-xl border border-green-500/30 flex items-center gap-3 shadow-md"
              >
                <div className="bg-green-500 text-black w-8 h-8 rounded-full flex items-center justify-center font-bold shrink-0 text-sm shadow-sm">
                  {idx + 1}
                </div>
                <span className="font-medium text-sm text-white leading-snug">{item.text}</span>
                <Check className="text-green-500 ml-auto" size={18} />
              </motion.div>
            ))}
          </AnimatePresence>
          
          {solvedItems.length === 0 && (
             <div className="text-center p-4 border-2 border-dashed border-[#333] rounded-xl text-gray-600 text-sm">
               Your correct answers will appear here
             </div>
          )}
        </div>

        {/* Available Options (Scrambled) */}
        <div className="w-full max-w-md grid gap-3">
           <AnimatePresence>
             {!isComplete && availableItems.map((item) => (
               <motion.button
                 key={item.originalIndex}
                 layout
                 onClick={() => handleItemClick(item)}
                 initial={{ opacity: 0, scale: 0.9 }}
                 animate={{ 
                   opacity: 1, 
                   scale: 1,
                   x: errorId === item.originalIndex ? [0, -5, 5, -5, 5, 0] : 0,
                 }}
                 exit={{ opacity: 0, scale: 0.9 }}
                 whileTap={{ scale: 0.98 }}
                 className={`p-4 rounded-xl shadow-md border-b-4 text-left transition-all text-sm font-medium ${
                   errorId === item.originalIndex 
                     ? "bg-red-900/20 border-red-500 text-red-200"
                     : "bg-[#252525] border-[#1a1a1a] active:border-t-4 active:border-b-0 text-gray-200 hover:bg-[#333]"
                 }`}
               >
                 {item.text}
               </motion.button>
             ))}
           </AnimatePresence>
        </div>
      </div>

      {/* Great Job Completion Dialog */}
      <AnimatePresence>
        {showCompletionDialog && (
          <div className="fixed inset-0 z-50 flex items-center justify-center px-5">
            {/* Backdrop */}
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/85 backdrop-blur-md"
            />

            {/* Dialog */}
            <motion.div 
              initial={{ scale: 0.85, opacity: 0, y: 30 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              transition={{ type: "spring", stiffness: 350, damping: 28, mass: 0.9 }}
              className="w-full max-w-sm relative z-10"
            >
              <div className="bg-gradient-to-b from-[#1e1e1e] to-[#181818] rounded-[28px] border border-[#333] shadow-[0_20px_60px_rgba(0,0,0,0.6)] overflow-hidden">
                
                {/* Celebration Banner */}
                <div className="relative bg-gradient-to-br from-pink-500/20 via-pink-600/10 to-transparent pt-8 pb-6 px-6">
                  {/* Decorative sparkles */}
                  <motion.div
                    animate={{ rotate: [0, 15, -15, 0], scale: [1, 1.1, 1] }}
                    transition={{ repeat: Infinity, duration: 3, ease: "easeInOut" }}
                    className="absolute top-4 right-6 text-yellow-400/60"
                  >
                    <Sparkles size={20} />
                  </motion.div>
                  <motion.div
                    animate={{ rotate: [0, -10, 10, 0], scale: [1, 1.15, 1] }}
                    transition={{ repeat: Infinity, duration: 2.5, ease: "easeInOut", delay: 0.5 }}
                    className="absolute top-6 left-8 text-pink-400/50"
                  >
                    <Sparkles size={14} />
                  </motion.div>

                  {/* Star badge */}
                  <motion.div
                    initial={{ scale: 0, rotate: -30 }}
                    animate={{ scale: 1, rotate: 0 }}
                    transition={{ type: "spring", stiffness: 400, damping: 15, delay: 0.15 }}
                    className="w-20 h-20 mx-auto mb-4 relative"
                  >
                    <div className="absolute inset-0 bg-gradient-to-br from-yellow-400 to-amber-500 rounded-full shadow-[0_0_30px_rgba(251,191,36,0.4)] flex items-center justify-center">
                      <svg viewBox="0 0 24 24" fill="white" className="w-10 h-10 drop-shadow-sm">
                        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                      </svg>
                    </div>
                    {/* Glow ring */}
                    <motion.div
                      animate={{ scale: [1, 1.2, 1], opacity: [0.4, 0, 0.4] }}
                      transition={{ repeat: Infinity, duration: 2 }}
                      className="absolute inset-0 rounded-full border-2 border-yellow-400/40"
                    />
                  </motion.div>

                  {/* Heading */}
                  <motion.h2
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    className="text-3xl font-extrabold text-white text-center tracking-tight"
                  >
                    Great Job!
                  </motion.h2>
                  <motion.p
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.3 }}
                    className="text-pink-200/80 text-sm text-center mt-2 font-medium leading-relaxed"
                  >
                    You put all the events in the right order!<br />
                    Your Buddy is so proud of you.
                  </motion.p>
                </div>

                {/* Actions */}
                <div className="px-6 pb-6 pt-4 space-y-3">
                  {/* Read Again - Primary */}
                  <motion.button
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.35 }}
                    onClick={handleReadAgain}
                    disabled={isResetting}
                    className="w-full bg-gradient-to-r from-pink-500 to-pink-600 hover:from-pink-400 hover:to-pink-500 text-white font-extrabold text-base py-4 rounded-2xl shadow-[0_4px_20px_rgba(236,72,153,0.35)] active:scale-[0.97] transition-all flex items-center justify-center gap-2.5 disabled:opacity-60"
                  >
                    {isResetting ? (
                      <RefreshCw size={20} className="animate-spin" />
                    ) : (
                      <>
                        <RotateCcw size={20} />
                        <span>Read Again</span>
                      </>
                    )}
                  </motion.button>

                  {/* Return to Journal */}
                  <motion.div
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.4 }}
                  >
                    <Link
                      to="/journal"
                      className="w-full bg-[#282828] hover:bg-[#333] text-white font-bold text-base py-4 rounded-2xl border border-[#3a3a3a] active:scale-[0.97] transition-all flex items-center justify-center gap-2.5"
                    >
                      <BookOpen size={20} className="text-green-400" />
                      <span>Go to My Journal</span>
                    </Link>
                  </motion.div>

                  {/* Back to Library - Subtle */}
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.5 }}
                  >
                    <Link
                      to="/library"
                      className="w-full py-3 text-gray-500 font-semibold text-sm flex items-center justify-center gap-2 hover:text-gray-300 transition-colors"
                    >
                      <LibraryIcon size={15} />
                      <span>Back to Library</span>
                    </Link>
                  </motion.div>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}