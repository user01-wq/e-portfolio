-- Create storage buckets
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true);
insert into storage.buckets (id, name, public) values ('portfolio_files', 'portfolio_files', true);

-- Avatar policies
create policy "Avatar images are publicly accessible." on storage.objects for select using ( bucket_id = 'avatars' );
create policy "Authenticated users can upload avatars." on storage.objects for insert with check ( bucket_id = 'avatars' and auth.role() = 'authenticated' );
create policy "Authenticated users can update avatars." on storage.objects for update using ( bucket_id = 'avatars' and auth.role() = 'authenticated' );
create policy "Authenticated users can delete avatars." on storage.objects for delete using ( bucket_id = 'avatars' and auth.role() = 'authenticated' );

-- Portfolio files policies
create policy "Portfolio files are publicly accessible." on storage.objects for select using ( bucket_id = 'portfolio_files' );
create policy "Authenticated users can upload portfolio files." on storage.objects for insert with check ( bucket_id = 'portfolio_files' and auth.role() = 'authenticated' );
create policy "Authenticated users can update portfolio files." on storage.objects for update using ( bucket_id = 'portfolio_files' and auth.role() = 'authenticated' );
create policy "Authenticated users can delete portfolio files." on storage.objects for delete using ( bucket_id = 'portfolio_files' and auth.role() = 'authenticated' );

-- Update projects table
alter table public.projects 
add column media_type text default 'link',
add column embed_code text,
add column file_path text;
