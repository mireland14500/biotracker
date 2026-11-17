-- Biotracker: Supabase setup (one coach, many clients)
-- Paste this whole file into Supabase → SQL Editor → New query, put the
-- coach's email in step 5, then click "Run". Safe to run more than once.
--
-- Who can do what:
--   client → reads and edits only their own entries
--   coach  → reads every client's entries (read-only) and adds/removes clients
--   anyone else who signs up → sees nothing

-- 1. Tables ------------------------------------------------------------------
create table if not exists public.tracker_members (
  email      text primary key check (email = lower(email)),
  role       text not null check (role in ('coach', 'client')),
  name       text,
  created_at timestamptz not null default now()
);

create table if not exists public.docs (
  owner      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  coll       text not null check (coll in ('entries', 'weeks')),
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (owner, coll, id)
);

-- 2. Helper functions ----------------------------------------------------------
create or replace function public.tracker_role()
returns text language sql stable security definer set search_path = public as $$
  select role from public.tracker_members where email = lower(auth.jwt() ->> 'email')
$$;

-- The coach's client list, with each client's account id once they have signed up.
create or replace function public.coach_clients()
returns table (email text, name text, user_id uuid)
language sql stable security definer set search_path = public, auth as $$
  select m.email, m.name, u.id
  from public.tracker_members m
  left join auth.users u on lower(u.email) = m.email
  where m.role = 'client' and public.tracker_role() = 'coach'
  order by coalesce(m.name, m.email)
$$;

revoke all on function public.tracker_role()  from public, anon;
revoke all on function public.coach_clients() from public, anon;
grant execute on function public.tracker_role()  to authenticated;
grant execute on function public.coach_clients() to authenticated;

-- 3. Row level security ---------------------------------------------------------
alter table public.tracker_members enable row level security;
alter table public.docs            enable row level security;

drop policy if exists "members: read self or coach" on public.tracker_members;
drop policy if exists "members: coach adds clients" on public.tracker_members;
drop policy if exists "members: coach edits clients" on public.tracker_members;
drop policy if exists "members: coach removes clients" on public.tracker_members;
create policy "members: read self or coach" on public.tracker_members for select to authenticated
  using (email = lower(auth.jwt() ->> 'email') or public.tracker_role() = 'coach');
create policy "members: coach adds clients" on public.tracker_members for insert to authenticated
  with check (public.tracker_role() = 'coach' and role = 'client');
create policy "members: coach edits clients" on public.tracker_members for update to authenticated
  using (public.tracker_role() = 'coach' and role = 'client')
  with check (public.tracker_role() = 'coach' and role = 'client');
create policy "members: coach removes clients" on public.tracker_members for delete to authenticated
  using (public.tracker_role() = 'coach' and role = 'client');

drop policy if exists "docs: read" on public.docs;
drop policy if exists "docs: client insert" on public.docs;
drop policy if exists "docs: client update" on public.docs;
drop policy if exists "docs: client delete" on public.docs;
create policy "docs: read" on public.docs for select to authenticated
  using ((owner = auth.uid() and public.tracker_role() = 'client') or public.tracker_role() = 'coach');
create policy "docs: client insert" on public.docs for insert to authenticated
  with check (owner = auth.uid() and public.tracker_role() = 'client');
create policy "docs: client update" on public.docs for update to authenticated
  using (owner = auth.uid() and public.tracker_role() = 'client')
  with check (owner = auth.uid() and public.tracker_role() = 'client');
create policy "docs: client delete" on public.docs for delete to authenticated
  using (owner = auth.uid() and public.tracker_role() = 'client');

-- 4. Live updates (the coach sees new entries without refreshing) ---------------
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'docs') then
    alter publication supabase_realtime add table public.docs;
  end if;
end $$;

-- 5. The coach  ✏️  EDIT THIS EMAIL ----------------------------------------------
-- Clients are added later from inside the app (Clients → Add client),
-- or here with more rows like: (lower('client@example.com'), 'client', 'Client Name')
insert into public.tracker_members (email, role, name) values
  (lower('COACH_EMAIL@example.com'), 'coach', 'Coach')
on conflict (email) do update set role = excluded.role;
