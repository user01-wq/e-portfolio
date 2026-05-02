alter table public.profiles
  add column if not exists show_profile  boolean not null default true,
  add column if not exists logo_url      text,
  add column if not exists footer_text   text,
  add column if not exists mourning_mode boolean not null default false,
  add column if not exists mourning_end_date date;
