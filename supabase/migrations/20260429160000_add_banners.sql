-- Banners table for homepage slideshow
create table public.banners (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  media_type text not null default 'image', -- 'image' | 'video'
  media_url text not null,
  title text,
  caption text,
  link_url text,
  sort_order int not null default 0,
  created_at timestamp with time zone not null default timezone('utc'::text, now())
);

alter table public.banners enable row level security;

create policy "Banners are viewable by everyone." on banners
  for select using (true);
create policy "Users can insert own banners." on banners
  for insert with check (auth.uid() = profile_id);
create policy "Users can update own banners." on banners
  for update using (auth.uid() = profile_id);
create policy "Users can delete own banners." on banners
  for delete using (auth.uid() = profile_id);

create index banners_profile_sort_idx on public.banners(profile_id, sort_order asc, created_at desc);
