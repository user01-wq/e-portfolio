-- Banner slideshow transition effect + solo-mode selection
alter table public.profiles
  add column if not exists banner_effect  text    default 'fade',
  add column if not exists solo_banner_id uuid    references public.banners(id) on delete set null;
