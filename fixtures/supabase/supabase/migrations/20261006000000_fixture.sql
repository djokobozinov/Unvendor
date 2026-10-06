-- Test fixture: tables, RLS using auth.*, storage buckets + policies.

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  created_at timestamptz not null default now()
);

create table public.notes (
  id bigint generated always as identity primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  body text not null,
  is_public boolean not null default false
);

create table public.orgs (
  id uuid primary key default gen_random_uuid(),
  name text not null
);

create table public.org_members (
  org_id uuid references public.orgs(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null default 'member',
  primary key (org_id, user_id)
);

alter table public.profiles    enable row level security;
alter table public.notes       enable row level security;
alter table public.orgs        enable row level security;
alter table public.org_members enable row level security;

-- auth.uid()
create policy "profiles: read all"   on public.profiles for select using (true);
create policy "profiles: update own" on public.profiles for update using (auth.uid() = id);

create policy "notes: own"    on public.notes for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "notes: public" on public.notes for select using (is_public);

-- auth.jwt()
create policy "notes: admin read" on public.notes for select
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
create policy "notes: admin delete" on public.notes for delete
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- auth.role()
create policy "orgs: create if logged in" on public.orgs for insert
  with check (auth.role() = 'authenticated');

-- auth.uid() inside a subquery
create policy "orgs: members read" on public.orgs for select
  using (exists (select 1 from public.org_members m
                 where m.org_id = orgs.id and m.user_id = auth.uid()));
create policy "org_members: own rows" on public.org_members for select
  using (user_id = auth.uid());

-- Storage
insert into storage.buckets (id, name, public) values
  ('avatars', 'avatars', true),
  ('documents', 'documents', false);

create policy "avatars: upload to own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "documents: read own folder" on storage.objects for select to authenticated
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "documents: upload own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);
