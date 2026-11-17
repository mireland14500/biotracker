# Biotracker

A mobile-friendly daily habit / biofeedback tracker for sharing with a coach. It tracks the same metrics as the coach's Google Sheets Biotracker:

- **Bio feedback:** energy, mood, stress, signs of illness, DOMS, resting heart rate
- **Sleep:** hours, self-rated and device-rated quality
- **Nutrition & digestion:** calories, protein, food quality, water, alcohol, hunger, stool movements, digestive stress, supplements
- **Training:** session, strength/performance, steps, cardio
- **Physical:** bodyweight, plus weekly circumference measurements and the log book check-in

Views: **Daily log** (tap-to-score entry), **Week view** (spreadsheet-style table with averages, plus a copyable summary for the coach), and **Trends** (charts with a 7-day average).

It's a single static file (`index.html`), with no build step.

## Coach + clients (Supabase)

With Supabase connected, one coach can run it for any number of clients:

- **Clients** sign in and log their own days. They can only see and edit their own data.
- **The coach** signs in, picks a client from a dropdown and sees that client's daily log, week table and trends (read-only). The coach adds and removes clients by email in **Clients**.
- Anyone else who signs up sees nothing. Access is enforced by row level security in the database, not by the page.

### Setup (about 10 minutes)

1. Create a free project at [supabase.com](https://supabase.com).
2. **SQL Editor → New query:** paste [`supabase/setup.sql`](supabase/setup.sql), change `COACH_EMAIL@example.com` to the coach's email, then click **Run**.
3. **Authentication → URL Configuration:** set **Site URL** to the deployed page (for example `https://<user>.github.io/biotracker/`) and add the same URL under **Redirect URLs**. This makes the confirmation and password-reset emails link back to the app.
4. **Project Settings → API:** copy the **Project URL** and the **anon / publishable** key into [`config.js`](config.js). The anon key is meant to be public; the database rules protect the data.
5. The coach opens the app, taps **Create account** with their email, and confirms it from their inbox. Then they add clients under **Clients**, and each client creates an account with the email the coach entered.

## Storage modes
The page picks one automatically:

| Where it runs | Where data is saved |
| --- | --- |
| `config.js` filled in | Supabase (shared between the coach and clients, with sign-in) |
| claude.ai artifact | That artifact's cloud database |
| Anywhere else | This browser only (localStorage) |
