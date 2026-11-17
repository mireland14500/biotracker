# Biotracker

A mobile-friendly daily habit / biofeedback tracker for sharing with a coach. It tracks the same metrics as the coach's Google Sheets Biotracker:

- **Bio feedback:** energy, mood, stress, signs of illness, DOMS, resting heart rate
- **Sleep:** hours, self-rated and device-rated quality
- **Nutrition & digestion:** calories, protein, food quality, water, alcohol, hunger, stool movements, digestive stress, supplements
- **Training:** session, strength/performance, steps, cardio
- **Physical:** bodyweight, plus weekly circumference measurements and the log book check-in

Views: **Daily log** (tap-to-score entry), **Week view** (spreadsheet-style table with averages, plus a copyable summary for the coach), and **Trends** (charts with a 7-day average).

It's a single static file (`index.html`), with no build step.

## Storage
- Hosted as a claude.ai artifact, entries sync to that artifact's cloud database, so the coach sees them live.
- Hosted anywhere else (for example GitHub Pages), entries are saved in the browser's localStorage on that device only.
