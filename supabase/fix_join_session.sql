-- Fixes PL/pgSQL ambiguity between the join_session output field
-- `session_id` and the session_participants.session_id column.
create or replace function public.join_session(p_code text, p_nickname text)
returns table(id uuid, session_id uuid, nickname text)
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
declare
  s public.sessions;
  p public.session_participants;
begin
  if length(trim(p_nickname)) not between 1 and 40 then
    raise exception 'Nickname must be 1-40 characters';
  end if;

  select *
    into s
    from public.sessions
   where join_code = upper(trim(p_code))
     and status in ('live', 'paused');

  if s.id is null then
    raise exception 'No live session has that code';
  end if;

  insert into public.session_participants(session_id, nickname)
  values (s.id, trim(p_nickname))
  on conflict (session_id, nickname)
  do update set last_seen_at = now()
  returning * into p;

  insert into public.classroom_members(classroom_id, nickname)
  values (s.classroom_id, trim(p_nickname))
  on conflict (classroom_id, nickname) do nothing;

  return query select p.id, p.session_id, p.nickname;
end;
$$;

revoke all on function public.join_session(text, text) from public;
grant execute on function public.join_session(text, text) to anon, authenticated;
