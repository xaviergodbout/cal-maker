-- Run once in the Supabase SQL Editor.
create table public.calendars (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null,
  revision bigint not null default 1,
  updated_at timestamptz not null default now()
);
create table public.calendar_versions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null,
  revision bigint not null,
  created_at timestamptz not null default now()
);
create index on public.calendar_versions(user_id, id desc);
alter table public.calendars enable row level security;
alter table public.calendar_versions enable row level security;
create policy own_calendar on public.calendars for select to authenticated using (user_id = (select auth.uid()));
create policy own_versions on public.calendar_versions for select to authenticated using (user_id = (select auth.uid()));
revoke all on public.calendars, public.calendar_versions from anon, authenticated;
grant select on public.calendars, public.calendar_versions to authenticated;

-- Atomic revision check prevents overwriting changes from another device.
create function public.save_calendar(payload jsonb, expected_revision bigint)
returns bigint language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid(); next_revision bigint;
begin
  if uid is null then raise exception 'AUTH_REQUIRED'; end if;
  if jsonb_typeof(payload) is distinct from 'object' or jsonb_typeof(payload->'entrees') is distinct from 'object'
     or octet_length(payload::text) > 2000000 then raise exception 'INVALID_DATA'; end if;
  if expected_revision = 0 then
    insert into public.calendars(user_id, data) values(uid, payload)
      on conflict do nothing returning revision into next_revision;
  else
    update public.calendars set data = payload, revision = revision + 1, updated_at = now()
      where user_id = uid and revision = expected_revision returning revision into next_revision;
  end if;
  if next_revision is null then raise exception 'CALENDAR_CONFLICT'; end if;
  insert into public.calendar_versions(user_id, data, revision) values(uid, payload, next_revision);
  delete from public.calendar_versions where user_id = uid and id not in
    (select id from public.calendar_versions where user_id = uid order by id desc limit 50);
  return next_revision;
end $$;
revoke all on function public.save_calendar(jsonb, bigint) from public;
grant execute on function public.save_calendar(jsonb, bigint) to authenticated;

-- A public health record contains no calendar or account information.
create table public.calendar_health (id integer primary key check (id = 1));
insert into public.calendar_health values(1);
alter table public.calendar_health enable row level security;
create policy health_read on public.calendar_health for select to anon, authenticated using(true);
revoke all on public.calendar_health from anon, authenticated;
grant select on public.calendar_health to anon, authenticated;
