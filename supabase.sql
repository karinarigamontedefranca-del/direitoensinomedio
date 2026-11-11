-- Pesquisa: Ensino médio e cursinho · SKEMA Consultoria Jr.
-- Cole este script inteiro em Supabase > SQL Editor > New query > Run.

create extension if not exists pgcrypto;

create table if not exists public.respostas_ensino_medio (
  id            uuid primary key default gen_random_uuid(),
  criado_em     timestamptz not null default now(),
  versao        text        not null default '1.0',
  coletor       text,                       -- quem compartilhou o link (?c=nome). Não identifica o respondente.
  nucleo        boolean,                    -- true = quer cursar Direito (1ª ou 2ª opção do filtro)
  concluido     boolean     not null default false,
  encerramento  text,                       -- null se concluiu; senão: fora_do_publico | sem_autorizacao | nao_pretende_direito
  duracao_s     integer,
  respostas     jsonb       not null default '{}'::jsonb,
  constraint respostas_e_objeto check (jsonb_typeof(respostas) = 'object'),
  constraint respostas_tamanho  check (pg_column_size(respostas) < 30000),
  constraint coletor_tamanho    check (coletor is null or char_length(coletor) <= 40)
);

create index if not exists respostas_em_criado_idx on public.respostas_ensino_medio (criado_em desc);
create index if not exists respostas_em_coletor_idx on public.respostas_ensino_medio (coletor);

-- Segurança: a chave pública (anon) só pode INSERIR. Ninguém de fora lê as respostas.
alter table public.respostas_ensino_medio enable row level security;

revoke all on table public.respostas_ensino_medio from anon, authenticated;
grant insert on table public.respostas_ensino_medio to anon;

drop policy if exists "anon_pode_inserir" on public.respostas_ensino_medio;
create policy "anon_pode_inserir"
  on public.respostas_ensino_medio
  for insert
  to anon
  with check (true);

-- Resumo para acompanhar a coleta (só você enxerga, pelo painel do Supabase).
create or replace view public.resumo_coletores
with (security_invoker = true) as
select
  coalesce(coletor, '(sem coletor)')                  as coletor,
  count(*)                                            as total_registros,
  count(*) filter (where concluido)                   as completas,
  count(*) filter (where concluido and nucleo)        as completas_nucleo_direito,
  count(*) filter (where encerramento is not null)    as encerradas_na_triagem
from public.respostas_ensino_medio
group by 1
order by completas desc;

revoke all on public.resumo_coletores from anon, authenticated;
