# Fortaleza: Último Bastião — Bíblia narrativa original (versão 0.1)

**Estado:** planejamento narrativo e primeiro prólogo integrado em `novo_projeto/`; a campanha completa ainda não foi escrita nem implementada.

## Referência analisada e limites criativos

Referência temática: *I Became the Tyrant of a Defense Game* (sinopse oficial WEBTOON, https://m.webtoons.com/en/fantasy/i-became-the-tyrant-of-a-defense-game/list?title_no=10765), com apoio de organização de arcos apresentada por Fabledex (https://www.fabledex.com/stories/tyrant-of-the-tower-defense-game). A sinopse oficial fala de um jogador transportado ao corpo de um príncipe e da obrigação de sobreviver a uma defesa inicialmente impossível. O guia secundário organiza arcos de defesa, perdas, exploração e ameaças diferenciadas. **Não foram copiados diálogos, nomes, reinos, cronologia ou personagens da obra.** Nossa Masmorra Antiga do Lago continuará sendo desbloqueada após a onda 20, como definido pelo usuário, ainda que a referência use outra progressão.

## Identidade autoral

**Premissa:** O Vale das Cinzas é a última faixa habitada entre antigas terras férteis e a região em que as criaturas se multiplicam. A fortaleza se tornou símbolo de proteção para uns e de exploração para outros. Uma convocação real traz ao palácio alguém sem título, propriedade ou experiência de comando: o protagonista criado pelo jogador. O rei oferece uma função arriscada, não uma herança.

**Pergunta central:** *Quem decide quais vidas merecem ser protegidas quando os recursos não são suficientes para todos?*

- **Rei Aldric:** acredita que um dever sem sacrifício é uma promessa vazia; temendo a queda das fronteiras, esconde as falhas políticas do reino.
- **General Vaelor (rank SS):** defensor profissional e competente, com convicções próprias; na rota Exilado, permanece responsável pela fortaleza, sem vitória garantida.
- **Doran:** ferreiro da fortaleza, tem uma filha; quer que a muralha signifique segurança para quem trabalha atrás dela.
- **Elira:** mercenária de Porto Cinzento; testemunhou o custo humano de contratos militares. Tem dúvidas sobre lealdade e independência.
- **Mira:** curandeira que trata soldados e civis sem discriminação; confronta decisões desumanas.
- **Kael:** explorador atento a padrões de comportamento dos monstros; insinua que as ondas não são completamente instintivas.

Estes traços são um ponto de partida para histórias pessoais na Etapa 2, e não garantia de que todos os arcos já estejam programados.

## Cinco atos da campanha

### Ato I — A dívida do juramento (Etapa 1 e início da Etapa 2)
- Prólogo com duas escolhas: **princípio moral** (salvar o ferido vs. segurar o portão) e **juramento irreversível** (Guardião vs. Exilado).
- Guardião começa na Fortaleza com autoridade a conquistar; Exilado inicia em Porto Cinzento e um general SS recebe o comando.
- Doran pede ferro para as muralhas; Elira pede ervas para suprimentos. Missões simples introduzem histórias pessoais. Conversas mudam após reencontros e conclusão das missões.
- Dias 1–5: o mundo apresenta o ritmo de ameaças; batalhas completas só serão implementadas na Etapa 3.

### Ato II — Vidas fora dos muros (Etapa 2 e 3)
- O jogador encontra refugiados e deve equilibrar segurança, recursos e direitos civis.
- NPCs tomam decisões por conta própria; lealdade, amizade e relações familiares geram eventos, inclusive mortes e sucessões.
- Espiões ou batedores descobrem que os monstros estão testando rotas e defesas.

### Ato III — O lago lembra (após a onda 20)
- A **Masmorra Antiga do Lago** revela vestígios de uma civilização que tentou controlar uma fonte de energia natural e desencadeou desequilíbrio ecológico.
- Equipamentos únicos, receitas Raras/Épicas/Lendárias e possibilidade de drops Míticos de chefes internos.
- Na rota Exilado, o desbloqueio depende da fortaleza resistir à onda 20 sob a IA de Vaelor.
- O conteúdo explora a questão ética: destruir a fonte e perder recursos, explorar a fonte e ampliar riscos, ou tentar contê-la.

### Ato IV — Dez máscaras da ameaça (Etapas 3 e 4)
- **Dez chefes principais de raças diferentes**, cada um com motivação, comportamento e estratégia própria. Raças e nomes finais ainda requerem desenho e testes; não serão simples trocas de cor.
- Minichefes emergem de eventos, locais e ondas. Inimigos mortais que sobrevivem após derrotar companheiros evoluem e podem influenciar histórias individuais.
- A vitória confirmada sobre os **dez chefes principais** é condição de desbloqueio do chefe final.

### Ato V — O preço da vitória (Etapa 4)
A história chega a um de cinco finais conforme a escolha inicial e consequências registradas:
1. **Protetor do Povo:** defesa com responsabilidade comunitária, dilemas com recursos/refugiados.
2. **Conquistador:** expansão militar e custo da ordem imposta.
3. **Senhor das Guildas:** autonomia econômica e responsabilidade pelo trabalho de outros.
4. **Exilado:** independência e impacto de ter deixado a fortaleza a cargo de Vaelor.
5. **Tirano das Cinzas:** vitória imposta pelo medo, com consequências duradouras.

Os finais **não serão reduzidos a uma barra única**: juramento, marcos irreversíveis, moral, lealdade, perdas, facções e estado do mundo influenciam suas variantes.

## Padrão de escrita dos diálogos

- Toda fala importante expressa **objetivo, memória ou conflito** do NPC; não apenas exposição de informações.
- O protagonista terá opções com princípios incompatíveis. Respostas mudam opiniões e eventos, mas não devem oferecer informação falsa sobre consequências mecânicas.
- Não use frases idênticas ou adaptações próximas de falas da obra de referência.
- NPCs mortos jamais retornam apenas porque o jogador entrou novamente no mapa.
- Rumores só comunicam eventos ocorridos na simulação; mentiras dentro da ficção devem ser identificadas como rumores falíveis, não como fatos do mundo.

## Implementação da primeira sequência

Arquivos:
- `scripts/story_content.gd`: falas originais da audiência, duas escolhas e reações contextuais de NPCs.
- `scripts/start.gd`: fluxo de diálogo com o rei por etapas, usando painel de texto 9-slice e escolhas.
- `scripts/game_state.gd`: `narrative_flags` persistentes e eventos de escolha.
- `scripts/world.gd`: diálogo de Doran, Elira, Mira e Kael sensível à rota, à memória e à conclusão da missão.
- `tests/test_story.gd`: regressão das escolhas, consequências iniciais e save/load.

**Restrições remanescentes:** Os dois atos iniciais são esboços; histórias pessoais completas, sistema de consequências complexo, chefes e cinco finais jogáveis permanecem para etapas posteriores. A interface visual e a narrativa requerem revisão em janela e polimento antes do ZIP.
