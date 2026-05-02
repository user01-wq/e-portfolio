-- Contact / feedback messages from public visitors
create table if not exists public.contact_messages (
  id         uuid                     primary key default gen_random_uuid(),
  name       text                     not null,
  email      text,
  message    text                     not null,
  is_read    boolean                  not null default false,
  created_at timestamp with time zone not null default timezone('utc', now())
);

alter table public.contact_messages enable row level security;

-- Public visitors can INSERT (send messages), but NEVER read them
create policy "Anyone can send a contact message." on public.contact_messages
  for insert with check (true);

-- Only authenticated admin can read / update / delete
create policy "Authenticated users can read messages." on public.contact_messages
  for select using (auth.role() = 'authenticated');

create policy "Authenticated users can update messages." on public.contact_messages
  for update using (auth.role() = 'authenticated');

create policy "Authenticated users can delete messages." on public.contact_messages
  for delete using (auth.role() = 'authenticated');

create index if not exists contact_messages_read_idx on public.contact_messages(is_read, created_at desc);
