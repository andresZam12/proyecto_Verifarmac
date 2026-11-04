-- Esquema de la tabla scan_history, usada por HistoryRemoteDataSource
-- (lib/features/history/data/datasources/history_remote_datasource.dart)
-- para sincronizar el historial local con Supabase.
--
-- Ejecutar en: Supabase Dashboard > SQL Editor > New query.
-- Se guarda aquí porque el esquema original nunca quedó versionado en el
-- repo y se perdió cuando el proyecto free de Supabase quedó inactivo.

create table if not exists public.scan_history (
  id                 text primary key,
  user_id            uuid not null references auth.users(id) on delete cascade,
  nombre_medicamento text not null,
  registro_sanitario text not null,
  estado             text not null,
  metodo             text not null,
  creado_en          timestamptz not null,
  laboratorio        text,
  confianza          double precision,
  sincronizado       boolean not null default true
);

create index if not exists idx_scan_history_user_id   on public.scan_history (user_id);
create index if not exists idx_scan_history_creado_en on public.scan_history (creado_en desc);

alter table public.scan_history enable row level security;

drop policy if exists "select own history" on public.scan_history;
create policy "select own history" on public.scan_history
  for select using (auth.uid() = user_id);

drop policy if exists "insert own history" on public.scan_history;
create policy "insert own history" on public.scan_history
  for insert with check (auth.uid() = user_id);

drop policy if exists "update own history" on public.scan_history;
create policy "update own history" on public.scan_history
  for update using (auth.uid() = user_id);

drop policy if exists "delete own history" on public.scan_history;
create policy "delete own history" on public.scan_history
  for delete using (auth.uid() = user_id);
