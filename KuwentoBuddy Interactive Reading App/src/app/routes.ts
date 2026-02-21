import { createBrowserRouter } from "react-router";
import { Home } from "./pages/Home";
import { Library } from "./pages/Library";
import { StoryReader } from "./pages/StoryReader";
import { Journal } from "./pages/Journal";
import { SequencingActivity } from "./pages/SequencingActivity";
import { AuthPage } from "./pages/Auth";
import { NotFound } from "./pages/NotFound";
import { Layout } from "./components/Layout";
import { ProtectedRoute } from "./components/ProtectedRoute";

export const router = createBrowserRouter([
  {
    path: "/auth",
    Component: AuthPage,
  },
  {
    path: "/",
    Component: ProtectedRoute, // Wrap Layout with ProtectedRoute
    children: [
      {
        Component: Layout,
        children: [
          { index: true, Component: Home },
          { path: "library", Component: Library },
          { path: "story/:storyId", Component: StoryReader },
          { path: "story/:storyId/activity", Component: SequencingActivity },
          { path: "journal", Component: Journal },
          { path: "*", Component: NotFound },
        ],
      },
    ],
  },
]);
