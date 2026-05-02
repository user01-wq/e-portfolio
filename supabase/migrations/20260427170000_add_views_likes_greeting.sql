-- Add greeting to profiles
alter table public.profiles
add column greeting text default 'สวัสดีค่ะ ฉัน';

-- Add views and likes to projects
alter table public.projects
add column views integer default 0 not null,
add column likes integer default 0 not null;

-- Create RPC function to increment views
create or replace function increment_project_views(project_id uuid)
returns void as $$
begin
  update public.projects
  set views = views + 1
  where id = project_id;
end;
$$ language plpgsql security definer;

-- Create RPC function to increment likes
create or replace function increment_project_likes(project_id uuid)
returns void as $$
begin
  update public.projects
  set likes = likes + 1
  where id = project_id;
end;
$$ language plpgsql security definer;
