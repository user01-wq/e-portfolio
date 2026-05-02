-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  full_name text,
  avatar_url text,
  bio text,
  email text
);

-- Create experiences table
create table public.experiences (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  school text not null,
  start_date date,
  end_date date,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create educations table
create table public.educations (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  degree text not null,
  school text not null,
  year text,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create projects table
create table public.projects (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  image_url text,
  link text,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.experiences enable row level security;
alter table public.educations enable row level security;
alter table public.projects enable row level security;

-- Create Policies
-- Profiles: everyone can view, owner can update
create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);
create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);
create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- Experiences: everyone can view, owner can all
create policy "Experiences are viewable by everyone." on experiences
  for select using (true);
create policy "Users can insert own experiences." on experiences
  for insert with check (auth.uid() = profile_id);
create policy "Users can update own experiences." on experiences
  for update using (auth.uid() = profile_id);
create policy "Users can delete own experiences." on experiences
  for delete using (auth.uid() = profile_id);

-- Educations: everyone can view, owner can all
create policy "Educations are viewable by everyone." on educations
  for select using (true);
create policy "Users can insert own educations." on educations
  for insert with check (auth.uid() = profile_id);
create policy "Users can update own educations." on educations
  for update using (auth.uid() = profile_id);
create policy "Users can delete own educations." on educations
  for delete using (auth.uid() = profile_id);

-- Projects: everyone can view, owner can all
create policy "Projects are viewable by everyone." on projects
  for select using (true);
create policy "Users can insert own projects." on projects
  for insert with check (auth.uid() = profile_id);
create policy "Users can update own projects." on projects
  for update using (auth.uid() = profile_id);
create policy "Users can delete own projects." on projects
  for delete using (auth.uid() = profile_id);

-- Setup auth trigger for new users
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, new.raw_user_meta_data->>'full_name', new.email);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
