-- Add sort_order and is_visible to experiences & educations
alter table public.experiences
  add column if not exists sort_order  integer not null default 0,
  add column if not exists is_visible  boolean not null default true;

alter table public.educations
  add column if not exists sort_order  integer not null default 0,
  add column if not exists is_visible  boolean not null default true;

-- Back-fill sort_order from start_date DESC so existing rows have sensible order
update public.experiences e
set sort_order = sub.rn - 1
from (
  select id, row_number() over (partition by profile_id order by start_date desc nulls last) as rn
  from public.experiences
) sub
where e.id = sub.id;

update public.educations e
set sort_order = sub.rn - 1
from (
  select id, row_number() over (partition by profile_id order by year desc nulls last) as rn
  from public.educations
) sub
where e.id = sub.id;

create index if not exists experiences_sort_idx on public.experiences(profile_id, sort_order asc);
create index if not exists educations_sort_idx  on public.educations(profile_id, sort_order asc);
