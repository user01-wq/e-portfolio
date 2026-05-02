-- ============================================================
--  E-Portfolio  ·  One-shot setup SQL
--  วางทั้งหมดนี้ใน Supabase SQL Editor แล้วกด Run
--  ใช้สำหรับโปรเจกต์ใหม่เท่านั้น (ยังไม่เคย run มาก่อน)
-- ============================================================

-- ── 1. PROFILES ─────────────────────────────────────────────
create table if not exists public.profiles (
  id                uuid        references auth.users on delete cascade not null primary key,
  updated_at        timestamptz,
  full_name         text,
  avatar_url        text,
  bio               text,
  email             text,
  greeting          text        default 'สวัสดีค่ะ ฉัน',
  theme             text        default 'ocean',
  site_name         text        default 'KruPortfolio',
  portfolio_btn_text text       default 'คลังสื่อการสอน',
  portfolio_title   text,
  portfolio_subtitle text,
  show_banners      boolean     not null default true,
  show_profile      boolean     not null default true,
  logo_url          text,
  footer_text       text,
  mourning_mode     boolean     not null default false,
  mourning_end_date date,
  social_links      jsonb       default '{}'::jsonb,
  nav_visibility    jsonb       default '{"resume":true,"projects":true,"contact":true}'::jsonb,
  banner_effect     text        default 'fade',
  solo_banner_id    uuid        -- FK added later after banners table exists
);

alter table public.profiles enable row level security;

create policy if not exists "Profiles are viewable by everyone."
  on public.profiles for select using (true);
create policy if not exists "Users can insert their own profile."
  on public.profiles for insert with check (auth.uid() = id);
create policy if not exists "Users can update own profile."
  on public.profiles for update using (auth.uid() = id);

-- ── 2. EXPERIENCES ──────────────────────────────────────────
create table if not exists public.experiences (
  id          uuid        primary key default gen_random_uuid(),
  profile_id  uuid        references public.profiles(id) on delete cascade not null,
  title       text        not null,
  school      text        not null,
  start_date  date,
  end_date    date,
  description text,
  sort_order  integer     not null default 0,
  is_visible  boolean     not null default true,
  created_at  timestamptz not null default timezone('utc', now())
);

alter table public.experiences enable row level security;

create policy if not exists "Experiences are viewable by everyone."
  on public.experiences for select using (true);
create policy if not exists "Users can insert own experiences."
  on public.experiences for insert with check (auth.uid() = profile_id);
create policy if not exists "Users can update own experiences."
  on public.experiences for update using (auth.uid() = profile_id);
create policy if not exists "Users can delete own experiences."
  on public.experiences for delete using (auth.uid() = profile_id);

create index if not exists experiences_sort_idx on public.experiences(profile_id, sort_order asc);

-- ── 3. EDUCATIONS ───────────────────────────────────────────
create table if not exists public.educations (
  id          uuid        primary key default gen_random_uuid(),
  profile_id  uuid        references public.profiles(id) on delete cascade not null,
  degree      text        not null,
  school      text        not null,
  year        text,
  description text,
  sort_order  integer     not null default 0,
  is_visible  boolean     not null default true,
  created_at  timestamptz not null default timezone('utc', now())
);

alter table public.educations enable row level security;

create policy if not exists "Educations are viewable by everyone."
  on public.educations for select using (true);
create policy if not exists "Users can insert own educations."
  on public.educations for insert with check (auth.uid() = profile_id);
create policy if not exists "Users can update own educations."
  on public.educations for update using (auth.uid() = profile_id);
create policy if not exists "Users can delete own educations."
  on public.educations for delete using (auth.uid() = profile_id);

create index if not exists educations_sort_idx on public.educations(profile_id, sort_order asc);

-- ── 4. PROJECTS ─────────────────────────────────────────────
create table if not exists public.projects (
  id          uuid        primary key default gen_random_uuid(),
  profile_id  uuid        references public.profiles(id) on delete cascade not null,
  title       text        not null,
  description text,
  image_url   text,
  link        text,
  media_type  text        default 'link',
  embed_code  text,
  file_path   text,
  views       integer     not null default 0,
  likes       integer     not null default 0,
  created_at  timestamptz not null default timezone('utc', now())
);

alter table public.projects enable row level security;

create policy if not exists "Projects are viewable by everyone."
  on public.projects for select using (true);
create policy if not exists "Users can insert own projects."
  on public.projects for insert with check (auth.uid() = profile_id);
create policy if not exists "Users can update own projects."
  on public.projects for update using (auth.uid() = profile_id);
create policy if not exists "Users can delete own projects."
  on public.projects for delete using (auth.uid() = profile_id);

-- RPC: increment views / likes (callable by anon)
create or replace function increment_project_views(project_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.projects set views = views + 1 where id = project_id;
end;
$$;

create or replace function increment_project_likes(project_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.projects set likes = likes + 1 where id = project_id;
end;
$$;

-- ── 5. BANNERS ──────────────────────────────────────────────
create table if not exists public.banners (
  id              uuid        primary key default gen_random_uuid(),
  profile_id      uuid        references public.profiles(id) on delete cascade not null,
  media_type      text        not null default 'image',
  media_url       text        not null,
  title           text,
  caption         text,
  link_url        text,
  sort_order      integer     not null default 0,
  is_pinned       boolean     not null default false,
  is_visible      boolean     not null default true,
  object_position text        not null default 'center',
  created_at      timestamptz not null default timezone('utc', now())
);

alter table public.banners enable row level security;

create policy if not exists "Banners are viewable by everyone."
  on public.banners for select using (true);
create policy if not exists "Users can insert own banners."
  on public.banners for insert with check (auth.uid() = profile_id);
create policy if not exists "Users can update own banners."
  on public.banners for update using (auth.uid() = profile_id);
create policy if not exists "Users can delete own banners."
  on public.banners for delete using (auth.uid() = profile_id);

create index if not exists banners_sort_idx on public.banners(profile_id, is_pinned desc, sort_order asc, created_at desc);

-- Now add the FK from profiles → banners (safe because banners table now exists)
alter table public.profiles
  add constraint if not exists profiles_solo_banner_id_fkey
  foreign key (solo_banner_id) references public.banners(id) on delete set null;

-- ── 6. CONTACT MESSAGES ─────────────────────────────────────
create table if not exists public.contact_messages (
  id         uuid        primary key default gen_random_uuid(),
  name       text        not null,
  email      text,
  message    text        not null,
  is_read    boolean     not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

alter table public.contact_messages enable row level security;

create policy if not exists "Anyone can send a contact message."
  on public.contact_messages for insert with check (true);
create policy if not exists "Authenticated users can read messages."
  on public.contact_messages for select using (auth.role() = 'authenticated');
create policy if not exists "Authenticated users can update messages."
  on public.contact_messages for update using (auth.role() = 'authenticated');
create policy if not exists "Authenticated users can delete messages."
  on public.contact_messages for delete using (auth.role() = 'authenticated');

create index if not exists contact_messages_read_idx
  on public.contact_messages(is_read, created_at desc);

-- ── 7. STORAGE BUCKETS ──────────────────────────────────────
insert into storage.buckets (id, name, public)
  values ('avatars', 'avatars', true)
  on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
  values ('portfolio_files', 'portfolio_files', true)
  on conflict (id) do nothing;

-- avatars bucket policies
create policy if not exists "Avatars are publicly accessible."
  on storage.objects for select using (bucket_id = 'avatars');
create policy if not exists "Auth users can upload avatars."
  on storage.objects for insert with check (bucket_id = 'avatars' and auth.role() = 'authenticated');
create policy if not exists "Auth users can update avatars."
  on storage.objects for update using (bucket_id = 'avatars' and auth.role() = 'authenticated');
create policy if not exists "Auth users can delete avatars."
  on storage.objects for delete using (bucket_id = 'avatars' and auth.role() = 'authenticated');

-- portfolio_files bucket policies
create policy if not exists "Portfolio files are publicly accessible."
  on storage.objects for select using (bucket_id = 'portfolio_files');
create policy if not exists "Auth users can upload portfolio files."
  on storage.objects for insert with check (bucket_id = 'portfolio_files' and auth.role() = 'authenticated');
create policy if not exists "Auth users can update portfolio files."
  on storage.objects for update using (bucket_id = 'portfolio_files' and auth.role() = 'authenticated');
create policy if not exists "Auth users can delete portfolio files."
  on storage.objects for delete using (bucket_id = 'portfolio_files' and auth.role() = 'authenticated');

-- ── 8. AUTH TRIGGER — auto-create profile on sign-up ────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── DONE ─────────────────────────────────────────────────────
-- ตาราง, RLS, Storage, Trigger พร้อมทั้งหมด
-- ขั้นต่อไป: สร้าง admin user ด้วย  node create-admin.mjs
