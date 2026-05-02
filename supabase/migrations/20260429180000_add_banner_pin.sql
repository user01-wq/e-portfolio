alter table public.banners
add column is_pinned boolean not null default false;

create index banners_pinned_idx on public.banners(profile_id, is_pinned desc, sort_order asc, created_at desc);
