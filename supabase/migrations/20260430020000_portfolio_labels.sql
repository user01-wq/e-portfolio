alter table public.profiles
  add column if not exists portfolio_title    text,
  add column if not exists portfolio_subtitle text;
