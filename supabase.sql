-- Pesquisa única: Ensino médio, cursinho e estudantes de Direito · SKEMA Consultoria Jr.
-- Cole este script inteiro em Supabase > SQL Editor > New query > Run.

create extension if not exists pgcrypto;

create table if not exists public.respostas_pesquisa (
  id            uuid primary key default gen_random_uuid(),
  criado_em     timestamptz not null default now(),
  versao        text        not null default '1.0',
  coletor       text,                       -- quem compartilhou o link (?c=nome). Não identifica o respondente.
  publico       text,                       -- ensino_medio | cursinho | outras_faculdades (null se saiu na 1ª pergunta)
  nucleo        boolean,                    -- true = quer cursar Direito (ensino médio/cursinho) ou já cursa (faculdade)
  concluido     boolean     not null default false,
  encerramento  text,                       -- null se concluiu; senão: fora_do_publico | sem_autorizacao | nao_pretende_direito | aluno_skema
  duracao_s     integer,
  respostas     jsonb       not null default '{}'::jsonb,
  constraint respostas_e_objeto check (jsonb_typeof(respostas) = 'object'),
  constraint respostas_tamanho  check (pg_column_size(respostas) < 30000),
  constraint coletor_tamanho    check (coletor is null or char_length(coletor) <= 40),
  constraint publico_valido     check (publico is null or publico in ('ensino_medio','cursinho','outras_faculdades'))
);

create index if not exists respostas_criado_idx  on public.respostas_pesquisa (criado_em desc);
create index if not exists respostas_coletor_idx on public.respostas_pesquisa (coletor);
create index if not exists respostas_publico_idx on public.respostas_pesquisa (publico);

-- Segurança: a chave pública (anon) só pode INSERIR. Ninguém de fora lê as respostas.
alter table public.respostas_pesquisa enable row level security;

revoke all on table public.respostas_pesquisa from anon, authenticated;
grant insert on table public.respostas_pesquisa to anon;

drop policy if exists "anon_pode_inserir" on public.respostas_pesquisa;
create policy "anon_pode_inserir"
  on public.respostas_pesquisa
  for insert
  to anon
  with check (true);

-- Resumo para acompanhar a coleta (só você enxerga, pelo painel do Supabase).
create or replace view public.resumo_coletores
with (security_invoker = true) as
select
  coalesce(coletor, '(sem coletor)')                                   as coletor,
  count(*) filter (where concluido and publico = 'ensino_medio')       as completas_ensino_medio,
  count(*) filter (where concluido and publico = 'cursinho')           as completas_cursinho,
  count(*) filter (where concluido and publico = 'outras_faculdades')  as completas_faculdades,
  count(*) filter (where concluido and nucleo)                         as completas_nucleo,
  count(*) filter (where encerramento is not null)                     as encerradas_na_triagem,
  count(*)                                                             as total_registros
from public.respostas_pesquisa
group by 1
order by total_registros desc;

revoke all on public.resumo_coletores from anon, authenticated;
