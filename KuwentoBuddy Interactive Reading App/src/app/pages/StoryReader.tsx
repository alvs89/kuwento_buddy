import { useState, useEffect, useRef } from "react";
import { useParams, useNavigate, Link, useLocation } from "react-router";
import { stories } from "../data/stories";
import { Buddy } from "../components/Buddy";
import { ArrowLeft, Play, Pause, SkipForward, CheckCircle2, AlertCircle, Volume2, VolumeX, BookOpen, RotateCcw, BookMarked, Trophy } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import confetti from "canvas-confetti";
import { twMerge } from "tailwind-merge";
import { useAuth } from "../context/AuthContext";
import { projectId, publicAnonKey } from "../../../utils/supabase/info";

export function StoryReader() {
  const { storyId } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();
  const story = stories.find((s) => s.id === storyId);

  const [currentSegmentIndex, setCurrentSegmentIndex] = useState(0);
  const [showQuestion, setShowQuestion] = useState(false);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [feedbackState, setFeedbackState] = useState<"idle" | "correct" | "incorrect">("idle");
  const [buddyEmotion, setBuddyEmotion] = useState<"neutral" | "happy" | "thinking" | "sad" | "reading">("reading");
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [showExitConfirm, setShowExitConfirm] = useState(false);
  
  // New state for Resume/Replay Logic
  const [savedSegmentIndex, setSavedSegmentIndex] = useState<number | null>(null);
  const [showResumeDialog, setShowResumeDialog] = useState(false);
  const [showCompletedDialog, setShowCompletedDialog] = useState(false);
  
  // Ref to keep track of the current utterance
  const utteranceRef = useRef<SpeechSynthesisUtterance | null>(null);

  // Detect if we arrived via "Read Again" from the activity screen — skip all prompts
  const skipDialogs = (location.state as { fromReadAgain?: boolean } | null)?.fromReadAgain === true;

  // Fetch progress on mount
  useEffect(() => {
    // If navigated here via "Read Again", start fresh — no dialogs
    if (skipDialogs) return;

    if (!user || !storyId) return;

    const fetchProgress = async () => {
      try {
        const response = await fetch(
          `https://${projectId}.supabase.co/functions/v1/make-server-5b56fc96/progress/${user.id}`,
          { headers: { Authorization: `Bearer ${publicAnonKey}` } }
        );
        if (response.ok) {
          const data = await response.json();
          const storyProgress = data && data[storyId];
          
          if (storyProgress) {
             if (storyProgress.completed) {
                 setShowCompletedDialog(true);
             } else if (storyProgress.segmentIndex > 0) {
                 setSavedSegmentIndex(storyProgress.segmentIndex);
                 setShowResumeDialog(true);
             }
          }
        }
      } catch (error) {
        console.error("Failed to fetch progress", error);
      }
    };

    fetchProgress();
  }, [user, storyId]);

  // Save progress
  const saveProgress = async (index: number, completed: boolean = false) => {
    if (!user || !storyId) return;
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
            segmentIndex: index,
            completed
          })
        }
      );
    } catch (error) {
      console.error("Failed to save progress", error);
    }
  };

  if (!story) return <div className="p-8 text-center text-white">Story not found</div>;

  const currentSegment = story.segments[currentSegmentIndex];
  const isLastSegment = currentSegmentIndex === story.segments.length - 1;

  // Text-to-Speech Functions
  const stopSpeaking = () => {
    if (window.speechSynthesis) {
      window.speechSynthesis.cancel();
      setIsSpeaking(false);
    }
  };

  const toggleSpeech = () => {
    if (!window.speechSynthesis) return;

    if (isSpeaking) {
      stopSpeaking();
    } else {
      // Stop any existing speech first
      window.speechSynthesis.cancel();
      
      const utterance = new SpeechSynthesisUtterance(currentSegment.text);
      utterance.lang = 'en-US'; // Default to US English, could be configurable
      utterance.rate = 0.9; // Slightly slower for kids
      
      // Try to select a good voice
      const voices = window.speechSynthesis.getVoices();
      const preferredVoice = voices.find(v => v.name.includes('Google US English') || v.name.includes('Samantha'));
      if (preferredVoice) utterance.voice = preferredVoice;

      utterance.onend = () => {
        setIsSpeaking(false);
        setBuddyEmotion("reading");
      };

      utterance.onerror = (e) => {
        console.error("Speech error", e);
        setIsSpeaking(false);
      };
      
      utteranceRef.current = utterance;
      setBuddyEmotion("happy"); // Buddy looks happy/talking when reading
      window.speechSynthesis.speak(utterance);
      setIsSpeaking(true);
    }
  };

  // Cleanup speech on unmount or segment change
  useEffect(() => {
    stopSpeaking();
    
    // Reset state when segment changes
    setShowQuestion(false);
    setSelectedOption(null);
    setFeedbackState("idle");
    setBuddyEmotion("reading");

    return () => {
      stopSpeaking();
    };
  }, [currentSegmentIndex]);

  const handleNextClick = () => {
    stopSpeaking();
    setShowQuestion(true);
    setBuddyEmotion("thinking");
  };

  const handleOptionSelect = (index: number) => {
    if (feedbackState === "correct") return; 
    setSelectedOption(index);
    if (feedbackState === "incorrect") setFeedbackState("idle");
  };

  const checkAnswer = () => {
    if (selectedOption === null) return;

    if (selectedOption === currentSegment.question.correctIndex) {
      setFeedbackState("correct");
      setBuddyEmotion("happy");
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 }
      });
      // Save progress immediately on correct answer
      saveProgress(currentSegmentIndex, isLastSegment);
    } else {
      setFeedbackState("incorrect");
      setBuddyEmotion("sad");
    }
  };

  const handleContinue = () => {
    if (isLastSegment) {
      saveProgress(currentSegmentIndex, true);
      navigate(`/story/${story.id}/activity`);
    } else {
      const nextIndex = currentSegmentIndex + 1;
      setCurrentSegmentIndex(nextIndex);
      saveProgress(nextIndex, false);
    }
  };

  const handleBack = () => {
    stopSpeaking();
    setShowExitConfirm(true);
  };
  
  const handleReturnToStory = () => {
    stopSpeaking();
    setShowQuestion(false);
    setBuddyEmotion("reading");
  };

  const confirmExit = () => {
    stopSpeaking();
    navigate("/library");
  };

  const handleRestartStory = () => {
    setCurrentSegmentIndex(0);
    setSavedSegmentIndex(null);
    setShowResumeDialog(false);
    setShowCompletedDialog(false);
    saveProgress(0, false); // Reset progress in backend
  };

  const handleResumeStory = () => {
    if (savedSegmentIndex !== null) {
      setCurrentSegmentIndex(savedSegmentIndex);
    }
    setShowResumeDialog(false);
  };

  const handleCancelReplay = () => {
    navigate(-1);
  };

  return (
    <div className="flex flex-col h-screen bg-[#0e2a47] text-white font-sans overflow-hidden">
      {/* Header */}
      <div className="h-16 flex items-center justify-between px-4 bg-[#0a1e33] border-b border-white/5 z-20 shrink-0">
        <button 
          onClick={handleBack}
          className="p-2 -ml-2 text-gray-400 hover:text-white transition-colors rounded-full hover:bg-white/5"
        >
          <ArrowLeft size={24} />
        </button>
        
        <div className="flex flex-col items-center">
           <span className="font-bold text-white text-sm tracking-wide truncate max-w-[150px]">
             {story.title}
           </span>
           <span className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">
              Page {currentSegmentIndex + 1} of {story.segments.length}
           </span>
        </div>
        
        <div className="w-10" /> {/* Spacer */}
      </div>

      {/* Progress Bar */}
      <div className="h-1.5 bg-[#05101a] w-full shrink-0">
         <div 
           className="h-full bg-gradient-to-r from-green-600 to-green-400 transition-all duration-500 ease-out rounded-r-full"
           style={{ width: `${((currentSegmentIndex + 1) / story.segments.length) * 100}%` }}
         />
      </div>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col relative overflow-hidden">
        {/* Scrollable Content */}
        <div className="flex-1 overflow-y-auto w-full pb-40"> {/* pb-40 for the bottom controls */}
           
           <AnimatePresence mode="wait">
            {!showQuestion ? (
              <motion.div
                key={`segment-${currentSegmentIndex}`}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.4 }}
                className="flex flex-col items-center"
              >
                {/* Image */}
                <div className="w-full aspect-video bg-black relative shadow-2xl mb-6">
                   <div className="absolute inset-0 bg-gradient-to-t from-[#0e2a47] to-transparent opacity-20 pointer-events-none" />
                   <img 
                     src={currentSegment.image || story.coverImage} 
                     alt="Story scene" 
                     className="w-full h-full object-cover"
                   />
                </div>

                {/* Text */}
                <div className="px-6 max-w-lg w-full">
                  <p className="text-xl md:text-2xl font-medium leading-relaxed text-gray-100 drop-shadow-sm">
                    {currentSegment.text}
                  </p>
                </div>
              </motion.div>
            ) : (
              <motion.div 
                key={`question-${currentSegmentIndex}`}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="flex flex-col items-center px-6 py-6 max-w-lg mx-auto w-full"
              >
                 <div className="w-full bg-[#1e1e1e] p-6 rounded-3xl border border-[#333] shadow-2xl space-y-6">
                   <h3 className="font-bold text-xl text-white leading-snug">{currentSegment.question.text}</h3>
                   
                   <div className="space-y-3">
                     {currentSegment.question.options.map((option, idx) => (
                        <button
                          key={idx}
                          onClick={() => handleOptionSelect(idx)}
                          disabled={feedbackState === "correct"}
                          className={twMerge(
                            "w-full text-left p-4 rounded-xl transition-all flex items-center justify-between text-base font-medium border-2",
                            selectedOption === idx 
                              ? "bg-[#282828] text-green-400 border-green-500 shadow-[0_0_15px_rgba(34,197,94,0.2)]" 
                              : "bg-[#252525] text-gray-300 border-transparent hover:border-[#444] active:scale-[0.98]"
                          )}
                        >
                          <span>{option}</span>
                          {selectedOption === idx && <CheckCircle2 size={20} className="text-green-500" />}
                        </button>
                     ))}
                   </div>
                 </div>

                 <div className="w-full mt-6 space-y-4">
                   {feedbackState === "idle" && (
                     <>
                        <button
                          onClick={handleReturnToStory}
                          className="w-full py-3 text-gray-400 font-bold text-sm flex items-center justify-center gap-2 hover:text-white transition-colors"
                        >
                          <BookOpen size={18} />
                          <span>Review Previous Page</span>
                        </button>
                        
                        <button
                          onClick={checkAnswer}
                          disabled={selectedOption === null}
                          className="w-full bg-white text-black font-extrabold text-lg py-4 rounded-full shadow-lg active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                        >
                          Check Answer
                        </button>
                     </>
                   )}
                   
                   {feedbackState === "correct" && (
                     <button
                       onClick={handleContinue}
                       className="w-full bg-green-500 hover:bg-green-400 text-black font-extrabold text-lg py-4 rounded-full shadow-[0_0_20px_rgba(34,197,94,0.4)] animate-pulse active:scale-95 transition-all flex items-center justify-center gap-2"
                     >
                       <span>{isLastSegment ? "Finish Story" : "Continue"}</span>
                       <ArrowLeft className="rotate-180" size={20} />
                     </button>
                   )}

                   {feedbackState === "incorrect" && (
                      <div className="text-center animate-shake">
                         <div className="space-y-3">
                           <button
                             onClick={() => setFeedbackState("idle")}
                             className="w-full bg-[#282828] text-white font-bold py-3 rounded-full hover:bg-[#333] transition-colors"
                           >
                             Try Again
                           </button>
                           
                           <button
                              onClick={handleReturnToStory}
                              className="w-full py-2 text-gray-400 font-medium text-sm flex items-center justify-center gap-2 hover:text-white transition-colors"
                            >
                              <BookOpen size={16} />
                              <span>Review Previous Page</span>
                            </button>
                         </div>
                      </div>
                   )}
                 </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Floating Controls & Buddy - Fixed at Bottom */}
        <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-[#0e2a47] via-[#0e2a47] to-transparent z-10 pointer-events-none overflow-visible">
          <div className="max-w-lg mx-auto flex items-end justify-between pointer-events-auto pb-4 overflow-visible">
            
            {/* Player Controls */}
            <div className={`transition-opacity duration-300 ${showQuestion ? 'opacity-0 pointer-events-none' : 'opacity-100'}`}>
              <div className="flex items-center gap-4 bg-[#1e1e1e]/90 backdrop-blur-xl p-2 rounded-full border border-white/10 shadow-2xl">
                <button 
                  className="w-10 h-10 flex items-center justify-center text-gray-300 active:text-white hover:bg-white/10 rounded-full transition-colors disabled:opacity-30"
                  onClick={() => currentSegmentIndex > 0 && setCurrentSegmentIndex(c => c - 1)}
                  disabled={currentSegmentIndex === 0}
                >
                   <ArrowLeft size={20} />
                </button>
                
                <button 
                  className={`w-12 h-12 rounded-full flex items-center justify-center shadow-lg active:scale-95 transition-transform ${
                    isSpeaking ? "bg-green-500 text-black" : "bg-white text-black"
                  }`}
                  onClick={toggleSpeech}
                >
                  {isSpeaking ? (
                    <Pause size={20} fill="black" />
                  ) : (
                    <Volume2 size={24} className="ml-0.5" />
                  )}
                </button>

                <button 
                  className="w-10 h-10 flex items-center justify-center text-gray-300 active:text-white hover:bg-white/10 rounded-full transition-colors"
                  onClick={handleNextClick}
                >
                   <SkipForward size={20} />
                </button>
              </div>
            </div>

            {/* Buddy Avatar - Bubble appears above, naturally fits in the layout */}
            <div className={`transition-all duration-500 ease-[cubic-bezier(0.34,1.56,0.64,1)] overflow-visible ${
              showQuestion ? '-translate-y-[20px] scale-110' : 'translate-y-0'
            }`}>
               <div className="relative overflow-visible">
                 <Buddy 
                    emotion={buddyEmotion} 
                    className="w-24 h-24 drop-shadow-2xl filter" 
                    hint={
                      feedbackState === "incorrect" ? currentSegment.question.hint :
                      feedbackState === "correct" ? "Great job!" :
                      undefined
                    }
                    hintType={feedbackState === "correct" ? "feedback" : "hint"}
                 />
               </div>
            </div>

          </div>
        </div>
      </div>

      {/* Exit Confirmation Dialog */}
      <AnimatePresence>
        {showExitConfirm && (
          <div className="fixed inset-0 z-50 flex items-center justify-center px-4">
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/80 backdrop-blur-sm"
              onClick={() => setShowExitConfirm(false)}
            />
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-[#1e1e1e] w-full max-w-sm p-6 rounded-3xl border border-[#333] shadow-2xl relative z-10"
            >
              <h3 className="text-xl font-bold text-white mb-2">Leave Story?</h3>
              <p className="text-gray-400 mb-6">Your progress will be saved so you can continue later.</p>
              
              <div className="flex gap-3">
                <button 
                  onClick={() => setShowExitConfirm(false)}
                  className="flex-1 py-3 px-4 bg-[#282828] text-white font-bold rounded-full hover:bg-[#333] transition-colors"
                >
                  Stay
                </button>
                <button 
                  onClick={confirmExit}
                  className="flex-1 py-3 px-4 bg-red-500 text-black font-bold rounded-full hover:bg-red-400 transition-colors"
                >
                  Exit
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Resume Confirmation Dialog */}
      <AnimatePresence>
        {showResumeDialog && (
          <div className="fixed inset-0 z-50 flex items-center justify-center px-4">
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/90 backdrop-blur-md"
              // Prevent closing by clicking outside to force a choice
            />
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-[#1e1e1e] w-full max-w-sm p-6 rounded-3xl border border-[#333] shadow-2xl relative z-10 text-center"
            >
              <div className="w-16 h-16 bg-[#282828] rounded-full flex items-center justify-center mx-auto mb-4 border border-[#333]">
                <BookMarked size={32} className="text-green-500" />
              </div>
              
              <h3 className="text-xl font-bold text-white mb-2">Resume Reading?</h3>
              <p className="text-gray-400 mb-6">You left off at page {savedSegmentIndex !== null ? savedSegmentIndex + 1 : '?'}. Would you like to continue?</p>
              
              <div className="space-y-3">
                <button 
                  onClick={handleResumeStory}
                  className="w-full py-4 px-4 bg-green-500 text-black font-extrabold text-lg rounded-full hover:bg-green-400 shadow-[0_0_20px_rgba(34,197,94,0.3)] transition-all flex items-center justify-center gap-2"
                >
                  <span>Resume Reading</span>
                  <ArrowLeft className="rotate-180" size={20} />
                </button>
                
                <button 
                  onClick={handleRestartStory}
                  className="w-full py-3 px-4 bg-[#282828] text-white font-bold rounded-full hover:bg-[#333] transition-colors flex items-center justify-center gap-2"
                >
                  <RotateCcw size={18} className="text-gray-400" />
                  <span>Start from Beginning</span>
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Completed Story Dialog */}
      <AnimatePresence>
        {showCompletedDialog && (
          <div className="fixed inset-0 z-50 flex items-center justify-center px-4">
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/90 backdrop-blur-md"
            />
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-[#1e1e1e] w-full max-w-sm p-6 rounded-3xl border border-[#333] shadow-2xl relative z-10 text-center"
            >
              <div className="w-16 h-16 bg-[#282828] rounded-full flex items-center justify-center mx-auto mb-4 border border-[#333]">
                <Trophy size={32} className="text-yellow-500" />
              </div>
              
              <h3 className="text-xl font-bold text-white mb-2">Great Job!</h3>
              <p className="text-gray-400 mb-6">You've already finished this story. Want to read it again?</p>
              
              <div className="space-y-3">
                <button 
                  onClick={handleRestartStory}
                  className="w-full py-4 px-4 bg-green-500 text-black font-extrabold text-lg rounded-full hover:bg-green-400 shadow-[0_0_20px_rgba(34,197,94,0.3)] transition-all flex items-center justify-center gap-2"
                >
                  <RotateCcw size={20} />
                  <span>Read Again</span>
                </button>
                
                <button 
                  onClick={handleCancelReplay}
                  className="w-full py-3 px-4 bg-[#282828] text-white font-bold rounded-full hover:bg-[#333] transition-colors flex items-center justify-center gap-2"
                >
                  <ArrowLeft size={18} className="text-gray-400" />
                  <span>Go Back</span>
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}