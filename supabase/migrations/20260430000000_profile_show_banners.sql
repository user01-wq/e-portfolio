alter table public.profiles
add column if not exists show_banners boolean not null default true;
