create table if not exists public.page_content (
    id uuid primary key default gen_random_uuid(),
    section text not null,
    title text not null check (char_length(btrim(title)) between 1 and 120),
    body text not null check (char_length(btrim(body)) between 1 and 1000),
    status text,
    created_at timestamptz not null default now()
);

alter table public.page_content
    add column if not exists status text;

alter table public.page_content
    drop constraint if exists page_content_section_check;
alter table public.page_content
    add constraint page_content_section_check
    check (section in ('leaders', 'approach', 'projects', 'updates'));

alter table public.page_content
    drop constraint if exists page_content_status_check;
alter table public.page_content
    add constraint page_content_status_check
    check (
        (section = 'projects' and status is not null and status in ('planning', 'in-progress', 'completed'))
        or (section <> 'projects' and status is null)
    );

alter table public.page_content enable row level security;

grant select on public.page_content to anon, authenticated;
grant insert, update, delete on public.page_content to authenticated;

drop policy if exists "Public can read page content" on public.page_content;
create policy "Public can read page content"
    on public.page_content
    for select
    to anon, authenticated
    using (true);

drop policy if exists "CBO admin can insert page content" on public.page_content;
create policy "CBO admin can insert page content"
    on public.page_content
    for insert
    to authenticated
    with check (auth.jwt() ->> 'email' = 'collectivebags33@gmail.com');

drop policy if exists "CBO admin can update page content" on public.page_content;
create policy "CBO admin can update page content"
    on public.page_content
    for update
    to authenticated
    using (auth.jwt() ->> 'email' = 'collectivebags33@gmail.com')
    with check (auth.jwt() ->> 'email' = 'collectivebags33@gmail.com');

drop policy if exists "CBO admin can delete page content" on public.page_content;
create policy "CBO admin can delete page content"
    on public.page_content
    for delete
    to authenticated
    using (auth.jwt() ->> 'email' = 'collectivebags33@gmail.com');

insert into public.page_content (id, section, title, body, status)
values
    ('00000000-0000-4000-8000-000000000001', 'leaders', 'Badada Malat', 'Community Leader', null),
    ('00000000-0000-4000-8000-000000000002', 'leaders', 'Soso Dagu', 'Assistant Community Leader', null),
    ('00000000-0000-4000-8000-000000000003', 'leaders', 'Amanuil Boku', 'Community Secretary', null),
    ('00000000-0000-4000-8000-000000000004', 'leaders', 'Galata Hassan', 'Treasurer', null),
    ('00000000-0000-4000-8000-000000000005', 'approach', 'Listen first', 'Understand what matters to neighbours before deciding what action to take.', null),
    ('00000000-0000-4000-8000-000000000006', 'approach', 'Bring people together', 'Make room for different voices, shared ideas and community participation.', null),
    ('00000000-0000-4000-8000-000000000007', 'approach', 'Take practical action', 'Turn local priorities into meaningful steps, shaped and owned by the community.', null),
    ('00000000-0000-4000-8000-000000000008', 'projects', 'Community Car Wash', 'Our first group project is underway. We’ll share progress and updates here as the car wash business develops.', 'in-progress')
on conflict (id) do nothing;
