import { Hono } from "npm:hono";
import { cors } from "npm:hono/cors";
import { logger } from "npm:hono/logger";
import { createClient } from "jsr:@supabase/supabase-js@2.49.8";
import * as kv from "./kv_store.tsx";

const app = new Hono();

// Enable logger
app.use('*', logger(console.log));

// Enable CORS for all routes and methods
app.use(
  "/*",
  cors({
    origin: "*",
    allowHeaders: ["Content-Type", "Authorization"],
    allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    exposeHeaders: ["Content-Length"],
    maxAge: 600,
  }),
);

// Health check endpoint
app.get("/make-server-5b56fc96/health", (c) => {
  return c.json({ status: "ok" });
});

// Sign up endpoint
app.post("/make-server-5b56fc96/signup", async (c) => {
  const { email, password, name } = await c.req.json();
  
  if (!email || !password) {
    return c.json({ error: "Email and password are required" }, 400);
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') || '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '',
  );

  const { data, error } = await supabase.auth.admin.createUser({
    email,
    password,
    user_metadata: { name },
    // Automatically confirm the user's email since an email server hasn't been configured.
    email_confirm: true
  });

  if (error) {
    console.error("Signup error:", error);
    return c.json({ error: error.message }, 400);
  }

  return c.json({ user: data.user });
});

// Get user progress
app.get("/make-server-5b56fc96/progress/:userId", async (c) => {
  const userId = c.req.param("userId");
  try {
    const progress = await kv.get(`user:${userId}:progress`);
    return c.json(progress || {});
  } catch (error) {
    console.error("Error fetching progress:", error);
    return c.json({ error: "Failed to fetch progress" }, 500);
  }
});

// Save user progress
app.post("/make-server-5b56fc96/progress", async (c) => {
  try {
    const { userId, storyId, segmentIndex, completed } = await c.req.json();
    
    if (!userId || !storyId) {
      return c.json({ error: "Missing required fields" }, 400);
    }

    // Get existing progress
    const currentProgress = (await kv.get(`user:${userId}:progress`)) || {};
    
    // Update progress
    const updatedProgress = {
      ...currentProgress,
      [storyId]: {
        segmentIndex: Math.max(segmentIndex, currentProgress[storyId]?.segmentIndex || 0),
        completed: completed || currentProgress[storyId]?.completed || false,
        lastAccessed: new Date().toISOString()
      },
      lastActive: new Date().toISOString()
    };

    await kv.set(`user:${userId}:progress`, updatedProgress);
    
    // Update streak (simplified logic: check if lastActive was yesterday)
    // For now, we just track lastActive. Proper streak logic would go here.
    
    return c.json({ success: true, progress: updatedProgress });
  } catch (error) {
    console.error("Error saving progress:", error);
    return c.json({ error: "Failed to save progress" }, 500);
  }
});

Deno.serve(app.fetch);