import { Link } from "react-router";

export function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-orange-50 text-slate-800 p-6 text-center">
      <h1 className="text-6xl font-bold text-orange-300 mb-4">404</h1>
      <p className="text-xl font-bold mb-2">Oops! Page not found.</p>
      <p className="text-slate-500 mb-8">It seems you've wandered off the path.</p>
      <Link to="/" className="bg-orange-500 text-white font-bold py-3 px-6 rounded-xl shadow-lg hover:bg-orange-600 transition-colors">
        Go Home
      </Link>
    </div>
  );
}
