# Pesquisa · Ensino médio e cursinho

Formulário web (HTML puro, sem build) que grava no **Supabase** e publica no **Vercel**. Segue o questionário 3 (M1 a M32) da SKEMA Consultoria Jr.

## O que tem aqui

| Arquivo | Para quê |
|---|---|
| `index.html` | O formulário inteiro (design, lógica de perguntas, envio) |
| `config.js` | **O único arquivo que você edita**: chaves do Supabase, lista de faculdades, texto do cartão da proposta, link do aviso |
| `supabase.sql` | Cria a tabela e as regras de segurança |
| `assets/` | Logo e fotos |
| `vercel.json` | Cabeçalhos de segurança e cache |

## Passo a passo

### 1. Supabase (5 min)
1. Crie um projeto em supabase.com.
2. Vá em **SQL Editor > New query**, cole todo o `supabase.sql` e clique em **Run**.
3. Vá em **Project Settings > API** e copie a **Project URL** e a chave **anon public**.
4. Abra o `config.js` e troque `SUPABASE_URL` e `SUPABASE_ANON_KEY`.

> A chave `anon` é pública por design. Quem protege os dados é a regra RLS do `supabase.sql`: a chave só consegue **inserir**, nunca ler. **Nunca** coloque a chave `service_role` neste projeto.

### 2. Testar antes de publicar
Abra o `index.html` com `?demo=1` (por exemplo, `http://localhost:3000/?demo=1`). No modo teste nada é enviado, e o JSON final aparece no console do navegador. Sem `?demo=1`, o envio vai de verdade para o Supabase.

Para testar localmente: `npx serve .` dentro da pasta.

### 3. Vercel
- Pelo site: vercel.com > **Add New > Project** > arraste esta pasta (ou conecte um repositório do GitHub). Framework: **Other**. Não precisa de build.
- Ou pela linha de comando: `npx vercel --prod` dentro da pasta.

### 4. Links para a equipe
Cada pessoa compartilha o link com o **próprio código**, assim você sabe quantas respostas cada um trouxe:

```
https://SEU-SITE.vercel.app/?c=sophia
https://SEU-SITE.vercel.app/?c=antonio
https://SEU-SITE.vercel.app/?c=luiza
```
O código `c` só aceita letras, números, `-` e `_`. Ele identifica quem **divulgou**, nunca quem respondeu.

### 5. Acompanhar e exportar
- **Table Editor > respostas_ensino_medio**: todas as respostas. Botão **Export** gera CSV.
- **Table Editor > resumo_coletores** (visualização): total de respostas completas por pessoa e quantas são do núcleo (quem quer cursar Direito). A meta é 40 a 60 respostas, com pelo menos 30 no núcleo.

## O que o formulário já faz
- **Triagem**: encerra com agradecimento quem não está no 3º ano ou cursinho (`fora_do_publico`) e quem diz que não pretende cursar Direito, depois de uma pergunta sobre o motivo (`nao_pretende_direito`).
- **Menores de 18 anos**: pede a confirmação de autorização do responsável ou da escola. Sem autorização, encerra sem guardar nada (`sem_autorizacao`).
- **Anonimato**: não pede nem grava nome, e-mail, telefone ou escola. Não grava IP nem user agent.
- **Ordem das opções embaralhada** para cada respondente (menos "Outro" e "Nenhum", que ficam no fim).
- **Marca só depois da lembrança espontânea**: tela de revelação da SKEMA no meio do questionário, como no PDF aprovado.
- **Cartão da proposta** com opção de reler em todas as perguntas seguintes.
- **Sem internet**: guarda a resposta no aparelho e reenvia quando a conexão voltar.
- **Um envio por aparelho** (para teste, use `?force=1`).
- Botão final para o respondente enviar o link a um colega.
- Teclado: letras A, B, C... escolhem opções; números escolhem notas; Enter continua.

## O que ajustar antes de publicar (`config.js`)
1. `FACULDADES`: lista usada na pergunta de lembrança de marca (M17 e sugestões da M18). Já vem com PUC Minas, Dom Helder, Milton Campos, Ibmec, UFMG, Newton Paiva, UniBH, FUMEC e SKEMA. **Valide com a SKEMA.**
2. `CARTAO_TEXTO`: texto da proposta. Hoje usa só os diferenciais descritos no contrato.
3. `AVISO_URL` e `CONTATO`: link do aviso de privacidade completo e e-mail de contato.

## Formato dos dados (`respostas` em JSON)
Cada linha da tabela guarda: `coletor`, `nucleo`, `concluido`, `encerramento`, `duracao_s` e o objeto `respostas`, com uma chave por pergunta. Perguntas com opção "Outro" geram também `<chave>_outro` com o texto escrito.

Grades guardam, para cada frase, uma nota de 1 a 5. Nas frases de concordância, 1 = discordo totalmente e 5 = concordo totalmente. Nos formatos de apoio e de conteúdo, 1 = nenhum interesse e 5 = máximo. Escalas guardam o número escolhido (`catt` de 1 a 5, `chance` de 0 a 10).

Exemplos de consulta no SQL Editor:
```sql
-- Quantas respostas completas do núcleo
select count(*) from respostas_ensino_medio where concluido and nucleo;

-- Origem do interesse por Direito
select respostas->>'origin' as origem, count(*) from respostas_ensino_medio where concluido group by 1 order by 2 desc;

-- Peso da família (M10) entre quem tem familiar no Direito (M11)
select respostas->>'flaw' as familiar_no_direito, respostas->>'fweight' as peso_familia, count(*)
from respostas_ensino_medio where concluido group by 1,2 order by 1,3 desc;
```

## Mapa de perguntas (código do PDF → chave no JSON)
| Código | Chave | Tipo | Pergunta |
|---|---|---|---|
| M1 | `sit` | única | Qual é a sua situação hoje? |
| M2 | `age` | única | Qual é a sua idade? |
| M3 | `int` | única | Você pretende cursar Direito? |
| M4 | `why_no` | texto | O que te levou a não escolher o Direito? E qual curso te atrai mais? |
| M5 | `open` | texto | Quando pensa em escolher uma faculdade de Direito, o que é mais importante para você? |
| M6 | `rank` | ranking (lista ordenada) | Entre os fatores abaixo, quais 3 mais pesam na sua escolha da faculdade? |
| M7 | `origin` | única | De onde veio o seu interesse por Direito? |
| M8 | `fwho` | múltipla | Quem participa da decisão sobre onde estudar? |
| M9 | `fmost` | única | E quem tem a maior influência na decisão? |
| M10 | `fweight` | única | Quanto a opinião da sua família pesa na escolha da faculdade? |
| M11 | `flaw` | única | Existem profissionais do Direito na sua família (advogado, juiz, promotor, delegado, servidor jurídico)? |
| M12 | `flike` | grade (objeto linha → nota 1 a 5) | Quanto você concorda com cada frase? |
| M13 | `fsaid` | texto | O que sua família disse ou perguntou quando você falou das faculdades que estava considerando? |
| M14 | `final` | única | Quem vai tomar a decisão final sobre a faculdade? |
| M15 | `payer` | única | Quem deve pagar a mensalidade? |
| M16 | `top` | texto | Quais faculdades de Direito vêm à sua cabeça? Cite até 3. |
| M17 | `aided` | múltipla | Quais destas faculdades você conhece, pelo menos de nome? |
| M18 | `assoc` | grade (objeto linha → nota 1 a 5) | Que faculdade você associa a cada característica? |
| M19 | `chan` | múltipla | Onde você pesquisa faculdades? |
| M20 | `sk` | única | O que você sabe sobre a SKEMA? |
| M21 | `catt` | número | No geral, quão atraente é essa proposta para você? |
| M22 | `ccrd` | grade (objeto linha → nota 1 a 5) | Quanto você concorda com cada frase sobre essa proposta? |
| M23 | `cplus` | texto | O que mais chamou a sua atenção na proposta? E o que menos? |
| M24 | `m1` | texto | Se você fosse estudar Direito, o que te levaria a estudar na SKEMA? |
| M25 | `chance` | número | Qual a chance de você considerar a SKEMA para estudar Direito? |
| M26 | `fear` | única | Qual é o seu maior receio ao escolher uma faculdade de Direito? |
| M27 | `kfmt` | grade (objeto linha → nota 1 a 5) | Quanto cada formato de conteúdo despertaria o seu interesse em uma faculdade de Direito? |
| M28 | `faixa` | única | Qual faixa de mensalidade a sua família considera possível para uma faculdade de Direito? |
| M29 | `qual` | única | Para você, uma faculdade de mensalidade mais alta é, em geral: |
| M30 | `fmt` | grade (objeto linha → nota 1 a 5) | Quão atraente seria cada formato de apoio financeiro? |
| M31 | `reg` | única | Onde você mora? |
| M32 | `school` | única | Que tipo de escola você cursa ou cursou? |

Chaves extras: `consent` (aceite), `auth` (autorização de menores), `fmost_outro`, `aided_outro` etc. (texto de "Outro").

## Sobre a LGPD
- O aviso de privacidade completo precisa estar publicado no link de `AVISO_URL`, identificando a SKEMA Business School como controladora dos dados. O contrato exige aprovação prévia da SKEMA do questionário, do texto de abertura e do aviso.
- Eliminar os dados ao final do projeto: no Supabase, `truncate table respostas_ensino_medio;` e depois apague o projeto.
