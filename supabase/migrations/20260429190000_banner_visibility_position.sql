alter table public.banners
add column is_visible boolean not null default true,
add column object_position text not null default 'center';
