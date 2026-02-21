import { motion, AnimatePresence } from "motion/react";
import { useEffect, useLayoutEffect, useState, useId, useRef, useCallback } from "react";
import { twMerge } from "tailwind-merge";

export type BuddyEmotion = "neutral" | "happy" | "thinking" | "sad" | "reading" | "pondering";

interface BuddyProps {
  emotion?: BuddyEmotion;
  className?: string;
  speaking?: boolean;
  hint?: string | null;
  hintType?: "hint" | "feedback";
}

export function Buddy({ emotion = "neutral", className = "", speaking = false, hint, hintType = "hint" }: BuddyProps) {
  const [blink, setBlink] = useState(false);
  const uniqueId = useId();
  const glowId = `glow-${uniqueId}`;
  const gradientId = `pinkGradient-${uniqueId}`;

  // Ref for measuring the bubble and clamping it to viewport
  const bubbleRef = useRef<HTMLDivElement>(null);
  const [bubbleShift, setBubbleShift] = useState(0);

  // Auto-blink logic
  useEffect(() => {
    const blinkInterval = setInterval(() => {
      setBlink(true);
      setTimeout(() => setBlink(false), 150);
    }, 4000);
    return () => clearInterval(blinkInterval);
  }, []);

  // Measure the bubble and compute a horizontal shift to keep it within the viewport
  const recalcBubbleShift = useCallback(() => {
    if (!bubbleRef.current) { setBubbleShift(0); return; }

    const rect = bubbleRef.current.getBoundingClientRect();
    const safeMargin = 12; // px from each edge
    const vw = window.innerWidth;
    let shift = 0;

    if (rect.right > vw - safeMargin) {
      // Overflowing right edge → shift left
      shift = -(rect.right - vw + safeMargin);
    } else if (rect.left < safeMargin) {
      // Overflowing left edge → shift right
      shift = safeMargin - rect.left;
    }

    setBubbleShift(shift);
  }, []);

  // Recalculate whenever the hint changes (useLayoutEffect avoids visual flash)
  useLayoutEffect(() => {
    if (!hint) { setBubbleShift(0); return; }
    // Allow one frame for the bubble to render at natural size before measuring
    const raf = requestAnimationFrame(() => recalcBubbleShift());
    return () => cancelAnimationFrame(raf);
  }, [hint, recalcBubbleShift]);

  // Also recalculate on window resize
  useEffect(() => {
    if (!hint) return;
    const handleResize = () => recalcBubbleShift();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, [hint, recalcBubbleShift]);

  const visualEmotion = emotion === "sad" ? "pondering" : emotion;

  // Colors
  const colors = {
    pinkLight: "#FF80BF",
    pinkDark: "#E04F95",
    yellow: "#FDE047",
    black: "#1F2937",
    blueGlow: "#38BDF8",
    darkJoint: "#374151"
  };

  return (
    <div className={twMerge("relative w-48 h-64 overflow-visible", className)}>
      {/* --- SVG Character --- */}
      <div className="w-full h-full">
        <svg viewBox="0 0 200 300" className="w-full h-full drop-shadow-2xl overflow-visible">
          <defs>
             <filter id={glowId} x="-20%" y="-20%" width="140%" height="140%">
              <feGaussianBlur stdDeviation="2" result="blur" />
              <feComposite in="SourceGraphic" in2="blur" operator="over" />
            </filter>
            <linearGradient id={gradientId} x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor="#FF99CC" />
              <stop offset="100%" stopColor="#FF66B2" />
            </linearGradient>
          </defs>

          {/* --- LEGS --- */}
          <g transform="translate(0, 0)"> 
            {/* Left Leg */}
            <path d="M75 180 L70 240" stroke={colors.pinkDark} strokeWidth="18" strokeLinecap="round" />
            <circle cx="75" cy="210" r="10" fill={colors.pinkDark} stroke="#993366" strokeWidth="1"/> 
            <path d="M60 240 Q70 255 90 240" fill={colors.yellow} stroke="#B45309" strokeWidth="2" />
            <ellipse cx="75" cy="245" rx="20" ry="12" fill={colors.yellow} stroke="#B45309" strokeWidth="2" />
            
            {/* Right Leg */}
            <path d="M125 180 L130 240" stroke={colors.pinkDark} strokeWidth="18" strokeLinecap="round" />
            <circle cx="125" cy="210" r="10" fill={colors.pinkDark} stroke="#993366" strokeWidth="1"/> 
            <ellipse cx="125" cy="245" rx="20" ry="12" fill={colors.yellow} stroke="#B45309" strokeWidth="2" />
          </g>

          {/* --- STATIC ARMS (Firmly Attached) --- */}
          {/* Left Arm - Hanging naturally by side */}
          <g>
             <line x1="55" y1="125" x2="45" y2="160" stroke={colors.pinkLight} strokeWidth="14" strokeLinecap="round" />
             <circle cx="45" cy="160" r="8" fill={colors.darkJoint} /> 
             <line x1="45" y1="160" x2="40" y2="190" stroke={colors.pinkLight} strokeWidth="12" strokeLinecap="round" />
             <circle cx="40" cy="195" r="10" fill={colors.black} /> 
          </g>

          {/* Right Arm - Hanging naturally by side */}
          <g>
             <line x1="145" y1="125" x2="155" y2="160" stroke={colors.pinkLight} strokeWidth="14" strokeLinecap="round" />
             <circle cx="155" cy="160" r="8" fill={colors.darkJoint} /> 
             <line x1="155" y1="160" x2="160" y2="190" stroke={colors.pinkLight} strokeWidth="12" strokeLinecap="round" />
             <circle cx="160" cy="195" r="10" fill={colors.black} /> 
          </g>

          {/* --- BODY --- */}
          <path d="M70 170 Q100 200 130 170 L130 160 Q100 170 70 160 Z" fill={colors.black} />
          <path d="M60 110 Q100 100 140 110 L135 160 Q100 175 65 160 Z" fill={`url(#${gradientId})`} stroke="#993366" strokeWidth="2" />
          
          {/* Shoulder Caps */}
          <circle cx="55" cy="125" r="14" fill={colors.pinkDark} stroke="#993366" strokeWidth="1" />
          <circle cx="145" cy="125" r="14" fill={colors.pinkDark} stroke="#993366" strokeWidth="1" />

          {/* Chest Detail */}
          <rect x="85" y="125" width="30" height="20" rx="4" fill="rgba(255,255,255,0.2)" />
          <circle cx="100" cy="135" r="5" fill={colors.yellow} />

          {/* --- HEAD (Static Position) --- */}
          <g transform="translate(0, 0)">
             <rect x="90" y="90" width="20" height="25" fill="#333" />
             <rect x="35" y="55" width="15" height="40" rx="5" fill={colors.yellow} stroke="#B45309" strokeWidth="2" />
             <rect x="150" y="55" width="15" height="40" rx="5" fill={colors.yellow} stroke="#B45309" strokeWidth="2" />
             <circle cx="35" cy="75" r="6" fill={colors.blueGlow} opacity="0.9" />
             <circle cx="165" cy="75" r="6" fill={colors.blueGlow} opacity="0.9" />
             <rect x="50" y="30" width="100" height="85" rx="25" fill={`url(#${gradientId})`} stroke="#993366" strokeWidth="2" />
             <path d="M65 40 Q80 35 95 40" stroke="white" strokeWidth="3" opacity="0.4" strokeLinecap="round" fill="none" />
             <rect x="60" y="45" width="80" height="60" rx="15" fill="#111" stroke="#333" strokeWidth="1" />

             {/* --- FACE EXPRESSIONS (Only Animated Part) --- */}
             <g transform="translate(100, 75)">
                {visualEmotion === "happy" ? (
                  <>
                    <path d="M-20 -5 Q-15 -15 -10 -5" stroke={colors.blueGlow} strokeWidth="4" fill="none" strokeLinecap="round" filter={`url(#${glowId})`} />
                    <path d="M10 -5 Q15 -15 20 -5" stroke={colors.blueGlow} strokeWidth="4" fill="none" strokeLinecap="round" filter={`url(#${glowId})`} />
                    <path d="M-15 10 Q0 25 15 10" stroke={colors.blueGlow} strokeWidth="3" fill="none" strokeLinecap="round" filter={`url(#${glowId})`} />
                  </>
                ) : visualEmotion === "thinking" ? (
                  <>
                     <ellipse cx="-15" cy="-8" rx="6" ry="8" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                     <ellipse cx="15" cy="-8" rx="6" ry="8" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                     <line x1="-5" y1="15" x2="5" y2="15" stroke={colors.blueGlow} strokeWidth="3" strokeLinecap="round" />
                  </>
                ) : visualEmotion === "pondering" ? (
                  <>
                     <circle cx="-15" cy="0" r="8" stroke={colors.blueGlow} strokeWidth="2" fill="none" filter={`url(#${glowId})`} />
                     <circle cx="15" cy="0" r="3" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                     <circle cx="0" cy="15" r="4" stroke={colors.blueGlow} strokeWidth="2" fill="none" />
                  </>
                ) : visualEmotion === "reading" ? (
                   <>
                     <motion.g
                       animate={{ x: [-8, 8, -8] }}
                       transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                     >
                        <ellipse cx="-15" cy="5" rx="6" ry="4" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                        <ellipse cx="15" cy="5" rx="6" ry="4" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                     </motion.g>
                     <path d="M-5 18 Q0 20 5 18" stroke={colors.blueGlow} strokeWidth="2" fill="none" />
                   </>
                ) : (
                  // Neutral
                  <>
                    <motion.g animate={{ scaleY: blink ? 0.1 : 1 }}>
                      <ellipse cx="-18" cy="-5" rx="8" ry="12" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                      <ellipse cx="18" cy="-5" rx="8" ry="12" fill={colors.blueGlow} filter={`url(#${glowId})`} />
                    </motion.g>
                    {speaking ? (
                       <motion.ellipse cx="0" cy="15" rx="5" ry="3"
                          animate={{ ry: [2, 6, 2], rx: [4, 6, 4] }} 
                          transition={{ repeat: Infinity, duration: 0.2 }} 
                          fill="none" stroke={colors.blueGlow} strokeWidth="2"
                       />
                    ) : (
                       <path d="M-10 15 Q0 22 10 15" stroke={colors.blueGlow} strokeWidth="3" fill="none" strokeLinecap="round" filter={`url(#${glowId})`} />
                    )}
                  </>
                )}
             </g>
          </g>
        </svg>
      </div>

      {/* --- Thought Bubble (Above Character) --- */}
      {/* 
        Strategy: The outer wrapper is centered on the Buddy via left-1/2 -translate-x-1/2.
        The tail dots stay perfectly centered. The bubble body gets a dynamic `bubbleShift`
        (measured via ref) that nudges it left or right to stay within the viewport.
        We use Motion's `animate` prop for both scale AND x so they don't conflict.
      */}
      <AnimatePresence>
        {hint && (
          <motion.div
            initial={{ opacity: 0, scale: 0.5, y: 8 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.5, y: 8 }}
            transition={{ type: "spring", stiffness: 350, damping: 22, mass: 0.8 }}
            className="absolute bottom-full left-1/2 -translate-x-1/2 z-50 flex flex-col items-center pb-0.5"
          >
            {/* Main Bubble — ref for measuring, Motion handles scale + x shift together */}
            <motion.div
              ref={bubbleRef}
              initial={{ scale: 0.8, x: 0 }}
              animate={{ scale: 1, x: bubbleShift }}
              transition={{ delay: 0.05, type: "spring", stiffness: 400, damping: 18 }}
              className="bg-white rounded-2xl shadow-[0_4px_16px_rgba(224,79,149,0.2),0_2px_8px_rgba(0,0,0,0.1)] border-2 border-pink-200 relative"
              style={{
                width: "150px",
                maxWidth: "calc(100vw - 48px)",
              }}
            >
              {/* Downward triangle pointer — uses calculated `left` to stay over Buddy center */}
              <div
                className="absolute -bottom-[7px] w-0 h-0"
                style={{
                  left: `calc(50% - ${bubbleShift}px)`,
                  transform: "translateX(-50%)",
                  borderLeft: "7px solid transparent",
                  borderRight: "7px solid transparent",
                  borderTop: "7px solid #fbcfe8",
                }}
              />
              <div
                className="absolute -bottom-[5px] w-0 h-0"
                style={{
                  left: `calc(50% - ${bubbleShift}px)`,
                  transform: "translateX(-50%)",
                  borderLeft: "6px solid transparent",
                  borderRight: "6px solid transparent",
                  borderTop: "6px solid white",
                }}
              />

              {/* Text content with generous padding */}
              <div className="px-4 py-2.5">
                {hintType === "hint" && (
                  <p className="text-pink-500 text-[10px] font-extrabold uppercase tracking-widest text-center mb-1">
                    💡 Hint
                  </p>
                )}
                <p
                  className="text-gray-800 text-[13px] leading-relaxed font-semibold text-center"
                  style={{ wordBreak: "break-word", overflowWrap: "break-word" }}
                >
                  {hint}
                </p>
              </div>
            </motion.div>

            {/* Tail dots pointing DOWN toward the character (bigger → smaller) */}
            <motion.div
              initial={{ scale: 0, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.1, type: "spring", stiffness: 500, damping: 20 }}
              className="w-[10px] h-[10px] rounded-full bg-white shadow-[0_1px_4px_rgba(0,0,0,0.15)] border border-pink-200 mt-[3px] shrink-0"
            />
            <motion.div
              initial={{ scale: 0, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.15, type: "spring", stiffness: 500, damping: 20 }}
              className="w-[7px] h-[7px] rounded-full bg-white shadow-[0_1px_4px_rgba(0,0,0,0.15)] border border-pink-200 mt-[2px] shrink-0"
            />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}