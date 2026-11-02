# Vichea

Vichea is a classroom understanding and feedback MVP. It uses the existing empty workspace as a static browser app, backed by Supabase Auth, PostgreSQL, Row Level Security, and Realtime. Teacher accounts are email/password accounts. Students join a live session with a nickname and session code.

## Architecture and scope

- `index.html`, `styles.css`, and `app.js`: responsive browser client; no build step.
- `supabase/schema.sql`: relational schema, indexes, RLS, session join and understanding-check RPCs, and Realtime publication setup.
- Supabase is the source of truth. There is no fake/demo response seed. Class counts, check-ins, poll answers, quiz scores, and questions come from database rows.
- Anonymous questions hide the student's nickname from classmates and the teacher UI. The database retains a participant relationship for moderation and abuse handling.

The current MVP includes teacher sign-up/sign-in, classroom creation and teacher-managed rosters, date-based attendance with Present/Late/Absent marks and weighted attendance scores (Present = 1, Late = 0.5, Absent = 0), live session creation and codes, nickname-based student joining, live presence/check-in/question/poll updates, sequential quiz folders with question images, timers and per-student scores, understanding totals, session pause/resume/end, and a saved report summary. This is an early demo foundation, not a production school deployment: student identity and abuse prevention need stronger protections before public use, and the report/export, classroom member join flow, poll result reveal, and complete analytics views remain follow-up work.

## Supabase setup

1. Create a Supabase project and confirm email/password auth is enabled.
2. Open the SQL Editor and run `supabase/schema.sql` once. If the project already has the earlier Vichea schema, run `supabase/fix_join_session.sql` to repair student joins, `supabase/add_classroom_attendance.sql` to add the attendance register and policies, and `supabase/add_live_quizzes.sql` to enable quiz folders, ordered questions, timers, score tracking, and quiz image uploads. Run `supabase/remove_classroom_join_code.sql` to remove the unused classroom join-code column (session join codes remain).
3. In Table Editor / Publications, check that the listed tables are in `supabase_realtime` if your project does not allow the publication statements in the script.
4. Serve this folder from a local HTTP server or static host. Opening `index.html` as a `file://` URL may prevent browser modules/CDN resources from loading.
5. For GitHub Pages, set `supabaseUrl` and `supabaseAnonKey` in `config.js` to the Supabase Project URL and public anon/publishable key, then set the deployed Pages address as the Supabase Auth Site URL and an allowed redirect URL. These values are public in a browser app; never use the service-role key. For local setup, you can instead enter them on the first screen; those values are saved in that browser's local storage.
6. Create a teacher account. If email confirmation is enabled, confirm the email, then log in.
7. Create a classroom, start a session, and share the session code. Students can open the app on another browser/device, choose â€œJoin a session,â€ and enter the code and a nickname.

Realtime updates require the database changes feed and network access. Supabase project URL and public key are loaded from `config.js` first, with browser local storage as a fallback for local development. No secret key is used in the browser.

## Demo flow

Teacher: create a classroom â†’ start a session â†’ share its code â†’ ask for an understanding check â†’ create a poll â†’ answer/pin anonymous questions â†’ end the session and open the saved report.

Student: open `/#join` or use the join button â†’ enter the session code and a nickname â†’ submit an understanding response, question, or poll vote. Open a second browser profile or private window to simulate another student. Each person's response is persisted in Supabase and updates teacher views through Realtime.

## Known MVP limitations

- The project currently has no Node.js/npm runtime available in the workspace; the app is plain HTML/CSS/JS and relies on Supabase and QRCode CDN scripts.
- A teacher account requires email/password auth. Students are intentionally accountless for the demo.
- Classroom join codes are not used or displayed. Students join live sessions with the session code.
- Teacher dashboards for historical question aggregation and cross-session analytics are minimal. Session reports currently preserve counts and response totals as JSON.
- PDF export and school/administrator roles are not included.
- Student nickname and participant IDs are demo-grade identifiers. Add rate limiting, signed participant tokens, moderation controls, and institutional privacy review before production use.

## Stack note

The workspace was empty and has no Node/npm installed. I used a no-build browser client to keep it runnable within the available environment instead of introducing an untestable framework scaffold. Supabase remains the real backend and realtime transport.
