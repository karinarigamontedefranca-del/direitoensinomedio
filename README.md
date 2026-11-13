# Pesquisa única · Ensino médio, cursinho e outras faculdades de Direito

Formulário web (HTML puro, sem build) que grava no **Supabase** e publica no **Vercel**. **Um único link** atende dois públicos. A primeira pergunta ("Qual é a sua situação hoje?") direciona o respondente: quem está no 3º ano ou no cursinho responde o questionário 3 (M); quem estuda Direito em outra faculdade responde o questionário 4 (F).

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

Os links são os mesmos para os dois públicos; o formulário separa as trilhas sozinho.

### 5. Acompanhar e exportar
- **Table Editor > respostas_pesquisa**: todas as respostas. Botão **Export** gera CSV.
- **Table Editor > resumo_coletores** (visualização): respostas completas por pessoa, separadas por público. O núcleo, no ensino médio/cursinho, é quem quer cursar Direito; na faculdade, todos os que concluem. A meta é 40 a 60 respostas, com pelo menos 30 no núcleo.

## O que o formulário já faz
- **Triagem em ramificação**: a 1ª pergunta escolhe a trilha. "Outra situação" encerra com agradecimento (`fora_do_publico`). Trilha ensino médio/cursinho: quem não pretende cursar Direito encerra depois de dizer o motivo (`nao_pretende_direito`). Trilha faculdade: quem estuda na SKEMA encerra (`aluno_skema`), pois recebe outra pesquisa.
- **Troca de trilha**: se a pessoa voltar à 1ª pergunta e mudar a resposta, as respostas da trilha anterior são descartadas.
- **Menores de 18 anos** (nas duas trilhas; na faculdade a faixa etária começa em "17 anos ou menos"): pede a confirmação de autorização do responsável ou da escola. Sem autorização, encerra sem guardar nada (`sem_autorizacao`).
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
Cada linha da tabela guarda: `coletor`, `publico` (`ensino_medio`, `cursinho` ou `outras_faculdades`), `nucleo`, `concluido`, `encerramento`, `duracao_s` e o objeto `respostas`, com uma chave por pergunta. Perguntas com opção "Outro" geram também `<chave>_outro` com o texto escrito.

Grades guardam, para cada frase, uma nota de 1 a 5. Nas frases de concordância, 1 = discordo totalmente e 5 = concordo totalmente. Nos formatos de apoio e de conteúdo, 1 = nenhum interesse e 5 = máximo. Escalas guardam o número escolhido (`catt` de 1 a 5, `chance` de 0 a 10).

Exemplos de consulta no SQL Editor:
```sql
-- Quantas respostas completas do núcleo
select count(*) from respostas_pesquisa where concluido and nucleo;

-- Origem do interesse por Direito
select respostas->>'origin' as origem, count(*) from respostas_pesquisa where concluido group by 1 order by 2 desc;

-- Peso da família (M10) entre quem tem familiar no Direito (M11)
select respostas->>'flaw' as familiar_no_direito, respostas->>'fweight' as peso_familia, count(*)
from respostas_pesquisa where concluido group by 1,2 order by 1,3 desc;
```

## Mapa de perguntas

Chave `pub` = primeira pergunta (situação). As chaves começam com `e_` (ensino médio e cursinho) ou `f_` (faculdade de Direito).

### Trilha ensino médio e cursinho (questionário 3)
| Código | Chave | Tipo | Pergunta |
|---|---|---|---|
| M1 | `pub` | única | Qual é a sua situação hoje? |
| M2 | `e_age` | única | Qual é a sua idade? |
| M3 | `e_int` | única | Você pretende cursar Direito? |
| M4 | `e_why_no` | texto | O que te levou a não escolher o Direito? E qual curso te atrai mais? |
| M5 | `e_open` | texto | Quando pensa em escolher uma faculdade de Direito, o que é mais importante para você? |
| M6 | `e_rank` | ranking (lista ordenada) | Entre os fatores abaixo, quais 3 mais pesam na sua escolha da faculdade? |
| M7 | `e_origin` | única | De onde veio o seu interesse por Direito? |
| M8 | `e_fwho` | múltipla | Quem participa da decisão sobre onde estudar? |
| M9 | `e_fmost` | única | E quem tem a maior influência na decisão? |
| M10 | `e_fweight` | única | Quanto a opinião da sua família pesa na escolha da faculdade? |
| M11 | `e_flaw` | única | Existem profissionais do Direito na sua família (advogado, juiz, promotor, delegado, servidor jurídico)? |
| M12 | `e_flike` | grade (objeto linha → nota 1 a 5) | Quanto você concorda com cada frase? |
| M13 | `e_fsaid` | texto | O que sua família disse ou perguntou quando você falou das faculdades que estava considerando? |
| M14 | `e_final` | única | Quem vai tomar a decisão final sobre a faculdade? |
| M15 | `e_payer` | única | Quem deve pagar a mensalidade? |
| M16 | `e_top` | texto | Quais faculdades de Direito vêm à sua cabeça? Cite até 3. |
| M17 | `e_aided` | múltipla | Quais destas faculdades você conhece, pelo menos de nome? |
| M18 | `e_assoc` | grade (objeto linha → nota 1 a 5) | Que faculdade você associa a cada característica? |
| M19 | `e_chan` | múltipla | Onde você pesquisa faculdades? |
| M20 | `e_sk` | única | O que você sabe sobre a SKEMA? |
| M21 | `e_catt` | número | No geral, quão atraente é essa proposta para você? |
| M22 | `e_ccrd` | grade (objeto linha → nota 1 a 5) | Quanto você concorda com cada frase sobre essa proposta? |
| M23 | `e_cplus` | texto | O que mais chamou a sua atenção na proposta? E o que menos? |
| M24 | `e_m1` | texto | Se você fosse estudar Direito, o que te levaria a estudar na SKEMA? |
| M25 | `e_chance` | número | Qual a chance de você considerar a SKEMA para estudar Direito? |
| M26 | `e_fear` | única | Qual é o seu maior receio ao escolher uma faculdade de Direito? |
| M27 | `e_kfmt` | grade (objeto linha → nota 1 a 5) | Quanto cada formato de conteúdo despertaria o seu interesse em uma faculdade de Direito? |
| M28 | `e_faixa` | única | Qual faixa de mensalidade a sua família considera possível para uma faculdade de Direito? |
| M29 | `e_qual` | única | Para você, uma faculdade de mensalidade mais alta é, em geral: |
| M30 | `e_fmt` | grade (objeto linha → nota 1 a 5) | Quão atraente seria cada formato de apoio financeiro? |
| M31 | `e_reg` | única | Onde você mora? |
| M32 | `e_school` | única | Que tipo de escola você cursa ou cursou? |

(M1 `sit` é a pergunta `pub` comum às duas trilhas, com mais uma opção: "Estudo Direito em uma faculdade".)

### Trilha faculdade de Direito (questionário 4)
| Código | Chave | Tipo | Pergunta |
|---|---|---|---|
| F2 | `f_ies` | multi | Em qual faculdade você estuda? |
| F3 | `f_sem` | single | Em qual semestre você está? |
| F4 | `f_age` | single | Qual é a sua faixa etária? |
| F5 | `f_open` | open | Com as suas palavras: o que te levou a escolher a faculdade onde você estuda? |
| F6 | `f_first` | single | A sua faculdade atual foi a primeira opção? |
| F7 | `f_cons` | multi | Que outras faculdades você considerou antes de decidir? |
| F8 | `f_rank` | rank | Quais foram os 3 fatores que mais pesaram na sua escolha? |
| F9 | `f_perf` | grid | Hoje, como você avalia a sua faculdade em cada um destes fatores? |
| F10 | `f_tradfam` | single | Alguém da sua família estudou na mesma faculdade? |
| F11 | `f_fwho` | multi | Quem participou da decisão sobre onde estudar? |
| F12 | `f_fmost` | single | E quem teve a maior influência na decisão? |
| F13 | `f_fweight` | single | Quanto a opinião da sua família pesou na escolha da faculdade? |
| F14 | `f_flaw` | single | Existem profissionais do Direito na sua família (advogado, juiz, promotor, delegado, servidor jurídico)? |
| F15 | `f_flike` | grid | Quanto você concorda com cada frase? |
| F16 | `f_fsaid` | open | O que sua família disse ou perguntou quando você falou das faculdades que estava considerando? |
| F17 | `f_top` | open | Quais faculdades de Direito vêm à sua cabeça? Cite até 3. |
| F18 | `f_aided` | multi | Quais destas faculdades você conhece, pelo menos de nome? |
| F19 | `f_assoc` | grid | Que faculdade você associa a cada característica? |
| F20 | `f_price` | money | Quanto você paga de mensalidade, aproximadamente? |
| F21 | `f_disc` | single | Você tem bolsa ou desconto? |
| F22 | `f_nodisc` | single | Se pagasse a mensalidade cheia, teria escolhido a mesma faculdade? |
| F23 | `f_val` | single | Considerando o que a sua faculdade entrega, a mensalidade cheia é: |
| F24 | `f_fmt` | grid | Quão atraente seria cada formato de apoio financeiro? |
| F25 | `f_nps` | scale | De 0 a 10, o quanto você recomendaria a sua faculdade a um amigo? |
| F26 | `f_why` | open | Qual é o principal motivo da sua nota? |
| F27 | `f_swap` | single | Você já pensou em mudar de faculdade? |
| F28 | `f_swapwhy` | open | O que faria uma pessoa na sua situação mudar de faculdade? |
| F29 | `f_know` | single | Na época em que você escolheu a faculdade, o que você sabia sobre o Direito da SKEMA? |
| F30 | `f_knowwhy` | open | O que pesou para a SKEMA não ser a sua escolha? |
| F31 | `f_skprice` | money | Quanto você imagina que seja a mensalidade do Direito da SKEMA? |
| F32 | `f_catt` | scale | No geral, quão atraente é essa proposta para você? |
| F33 | `f_ccrd` | grid | Quanto você concorda com cada frase sobre essa proposta? |
| F34 | `f_cplus` | open | O que mais chamou a sua atenção na proposta? E o que menos? |
| F35 | `f_m1` | open | Se você fosse escolher hoje uma faculdade de Direito, o que te levaria a estudar na SKEMA? |
| F36 | `f_chance` | scale | Qual a chance de você considerar a SKEMA, se estivesse decidindo hoje? |
| F37 | `f_kchan` | multi | Que tipos de conteúdo de faculdades você costuma acompanhar quando pesquisa onde estudar? |
| F38 | `f_kfmt` | grid | Quanto cada formato de conteúdo despertaria o seu interesse em uma faculdade de Direito? |

Notas da trilha faculdade: `f_ies` agora é de escolha única (a faculdade onde estuda; "SKEMA" encerra). `f_age` tem a faixa "17 anos ou menos" para identificar menores. Os campos de dinheiro (`f_price`, `f_skprice`) guardam um objeto linha → número em R$, ou `"nao_informa"`. Na grade `f_perf`, `"nao_sei"` indica "Não sei".

Chaves extras: `consent`, `auth`, `<chave>_outro` (texto de "Outro").

## Consultas úteis
```sql
select publico, count(*) filter (where concluido) as completas from respostas_pesquisa group by 1;

-- Mensalidade paga x tem bolsa (faculdades)
select respostas->>'f_disc' as bolsa, avg((respostas->'f_price'->>'Mensalidade que você de fato paga (R$ por mês)')::numeric)
from respostas_pesquisa where publico='outras_faculdades' and concluido group by 1;
```

## Sobre a LGPD
- O aviso de privacidade completo precisa estar publicado em `AVISO_URL`, identificando a SKEMA Business School como controladora. O contrato exige aprovação prévia da SKEMA do questionário, da abertura e do aviso.
- Eliminar os dados ao final do projeto: `truncate table respostas_pesquisa;` e depois apague o projeto no Supabase.
