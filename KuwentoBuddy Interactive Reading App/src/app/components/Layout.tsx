import { useState } from "react";
import { Outlet, NavLink, useNavigate } from "react-router";
import { BookOpen, Home, Trophy, LogOut, AlertTriangle } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { AnimatePresence, motion } from "motion/react";

export function Layout() {
  const { signOut } = useAuth();
  const navigate = useNavigate();
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  const handleSignOut = async () => {
    await signOut();
    navigate("/auth");
  };

  return (
    <div className="flex flex-col h-screen bg-black text-white font-sans overflow-hidden">
      {/* Main Content Area */}
      <main className="flex-1 overflow-y-auto pb-24 bg-[#121212] relative">
         <Outlet />
      </main>

      {/* Bottom Navigation Bar (Mobile First) */}
      <nav className="fixed bottom-0 left-0 right-0 bg-[#000000] border-t border-[#333] h-20 px-6 flex items-center justify-around z-50 pb-2">
        <NavLink
          to="/"
          className={({ isActive }) =>
            `flex flex-col items-center gap-1 transition-colors ${
              isActive ? "text-white" : "text-gray-500 hover:text-gray-300"
            }`
          }
        >
          <Home size={24} strokeWidth={2.5} />
          <span className="text-[10px] font-bold tracking-wide">Home</span>
        </NavLink>
        
        <NavLink
          to="/library"
          className={({ isActive }) =>
            `flex flex-col items-center gap-1 transition-colors ${
              isActive ? "text-white" : "text-gray-500 hover:text-gray-300"
            }`
          }
        >
          <BookOpen size={24} strokeWidth={2.5} />
          <span className="text-[10px] font-bold tracking-wide">Library</span>
        </NavLink>

        <NavLink
          to="/journal"
          className={({ isActive }) =>
            `flex flex-col items-center gap-1 transition-colors ${
              isActive ? "text-white" : "text-gray-500 hover:text-gray-300"
            }`
          }
        >
          <Trophy size={24} strokeWidth={2.5} />
          <span className="text-[10px] font-bold tracking-wide">Journal</span>
        </NavLink>

        <button
          onClick={() => setShowLogoutConfirm(true)}
          className="flex flex-col items-center gap-1 text-gray-500 hover:text-red-400 transition-colors"
        >
          <LogOut size={24} strokeWidth={2.5} />
          <span className="text-[10px] font-bold tracking-wide">Exit</span>
        </button>
      </nav>

      {/* Logout Confirmation Dialog */}
      <AnimatePresence>
        {showLogoutConfirm && (
          <div className="fixed inset-0 z-[60] flex items-center justify-center px-4">
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/80 backdrop-blur-sm"
              onClick={() => setShowLogoutConfirm(false)}
            />
            <motion.div 
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              className="bg-[#1e1e1e] w-full max-w-sm p-6 rounded-3xl border border-[#333] shadow-2xl relative z-10 text-center"
            >
              <div className="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mx-auto mb-4 text-red-500">
                <AlertTriangle size={32} strokeWidth={2} />
              </div>
              
              <h3 className="text-xl font-bold text-white mb-2">Log Out?</h3>
              <p className="text-gray-400 mb-6 text-sm leading-relaxed">
                Are you sure you want to exit? You'll need to sign in again to continue reading.
              </p>
              
              <div className="flex gap-3">
                <button 
                  onClick={() => setShowLogoutConfirm(false)}
                  className="flex-1 py-3 px-4 bg-[#282828] text-white font-bold rounded-full hover:bg-[#333] transition-colors border border-[#333]"
                >
                  Cancel
                </button>
                <button 
                  onClick={handleSignOut}
                  className="flex-1 py-3 px-4 bg-red-500 text-white font-bold rounded-full hover:bg-red-600 transition-colors shadow-lg shadow-red-500/20"
                >
                  Yes, Exit
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
