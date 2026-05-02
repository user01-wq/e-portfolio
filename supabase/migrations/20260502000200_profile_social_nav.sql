-- Social links (JSONB) and navbar visibility toggles
alter table public.profiles
  add column if not exists social_links   jsonb default '{}'::jsonb,
  add column if not exists nav_visibility jsonb default '{"resume":true,"projects":true,"contact":true}'::jsonb;
