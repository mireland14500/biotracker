// Supabase connection for the shared (coach + clients) version.
// Find these in Supabase → Project Settings → API (or "Connect").
// The anon/publishable key is designed to be public: access is enforced by
// the row level security rules in supabase/setup.sql.
// Leave the placeholders as they are to run in "this device only" mode.
window.BIOTRACKER_SUPABASE = {
  url: "YOUR_SUPABASE_URL",        // e.g. https://abcdefghijklmnop.supabase.co
  anonKey: "YOUR_SUPABASE_ANON_KEY",
};
