-- Run this in Supabase > SQL Editor

create table if not exists team_members (
  email text primary key,
  role text not null default 'editor' check (role in ('admin','editor','viewer'))
);

create table if not exists opportunities (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  funder text,
  type text default 'Grant',
  link text,
  amount text,
  region text default 'Africa',
  themes text[] default '{}',
  eligibility text,
  mhyi_project text,
  opens_on date,
  deadline date,
  rolling boolean default false,
  documents text,
  how_to_apply text,
  contact text,
  status text default 'Spotted',
  owner text,
  notes text,
  source text,
  verified boolean default false,
  created_at timestamptz default now()
);

alter table team_members enable row level security;
alter table opportunities enable row level security;

create or replace function public.team_role() returns text
language sql stable security definer set search_path = public as $$
  select role from team_members where lower(email) = lower(auth.jwt() ->> 'email')
$$;

create policy "team can read" on opportunities for select
  using (team_role() is not null);
create policy "editors can add" on opportunities for insert
  with check (team_role() in ('admin','editor'));
create policy "editors can edit" on opportunities for update
  using (team_role() in ('admin','editor'));
create policy "admins can delete" on opportunities for delete
  using (team_role() = 'admin');
create policy "see own role" on team_members for select
  using (lower(email) = lower(auth.jwt() ->> 'email'));

-- Add yourself as admin (change the email), then create the same user in Authentication > Users
insert into team_members (email, role) values ('awoniyijoy18@gmail.com', 'admin')
on conflict (email) do nothing;
