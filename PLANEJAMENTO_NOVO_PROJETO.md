# Fortaleza: Último Bastião — Planejamento oficial do novo projeto

**Versão do planejamento:** 1.0 — 03/11/2026  
**Estado:** especificação aprovada; implementação do novo projeto ainda não iniciada.  
**Importante:** os arquivos Godot simplificados existentes na raiz do repositório pertencem a um teste antigo de distribuição e **não representam esta nova versão**. O planejamento não autoriza publicar o protótipo como jogo completo.

## Visão central

RPG autoral de fantasia medieval, inspirado na atmosfera de *I Became the Tyrant of a Defense Game* e na apresentação/mecânicas de *Hero's Adventure: Road to Passion*, mas com enredo, arte, nomes e personagens próprios. Protagonista personalizado, sem título ou propriedade inicial, progride por trabalho, relações, exploração, combate e decisões. Sprites de personagens em 2D animado dentro de cenários isométricos 3D.

### Regras narrativas inegociáveis

- O jogador é convocado por um rei no prólogo e escolhe aceitar ou recusar a missão de proteger a fortaleza.
- Aceitar habilita quatro rotas de final: **Protetor do Povo, Conquistador, Senhor das Guildas, Tirano das Cinzas**.
- Recusar habilita a quinta rota: **Exilado**. Começa em outra cidade; um herói de rank SS assume a fortaleza; o mundo e as invasões continuam sendo simulados.
- Na região da fortaleza, o Exilado perde credibilidade, paga **3 vezes** os preços normais ao comprar e não pode recrutar NPCs residentes dali.
- Uma onda de monstros ataca a fortaleza a cada **cinco dias do calendário do jogo**, com crescimento gradual, influenciado pela dificuldade.
- Após a conclusão da **onda 20**, libera-se a **Masmorra Antiga do Lago**. O mundo registra o evento também na rota Exilado se a defesa da IA resistir.
- Quatro dificuldades: Fácil e Normal com bônus positivos somente; Difícil e Impossível com bônus e penalidades. Impossível: **3x de XP**, maior chance de itens raros, mais monstros, mais dano sofrido e menos recursos.
- Conquista **O Último Sobrevivente**: vitória final no Impossível, protagonista vivo com HP > 0 e <= 10% do HP máximo, demais integrantes do grupo principal permanentemente mortos, sem outros sobreviventes do grupo. Desbloqueia um personagem secreto para futuras campanhas.
- NPCs podem aparecer aleatoriamente nas tavernas com raridades Comum/Incomum/Raro/Épico/Lendário; NPCs relevantes têm identidade persistente, histórias e relacionamentos independentes da presença do jogador.

## Modelo comum de dados e acontecimentos (a fundação das sete mecânicas)

Eventos determinísticos de jogo com ID exclusivo, dia, região, atores, tipo, consequências e flag de persistência. Um único histórico permite compor **Crônicas do Mundo**, **Memória dos NPCs**, **Legado e sucessão**, **Política e moral**, **Inimigos mortais evolutivos**, **Migração regional** e **Inteligência militar** sem sete simulações desconectadas.

Entidades persistentes: `WorldState`, `RegionState`, `NPCState`, `RelationshipEdge`, `MemoryEntry`, `EventRecord`, `FactionState`, `PropertyState`, `FortressState`, `WaveState`, `NemesisState`, `CampaignState`, `GlobalAchievementProfile`. Cada NPC importante possui ID estável, vivo/morto, local atual, rotina, profissão, objetivos, traços de personalidade, relações e memórias. NPCs em regiões distantes são atualizados em passos de simulação de eventos; os próximos usam simulação de cena. Eventos críticos precisam ser idempotentes para não duplicar consequências após carregar saves.

**Segurança de progressão:** salvar versão do esquema, semente aleatória, dia, resultados já processados de ondas, eventos, mortes, condições de conquista e escolhas irreversíveis. Separar perfil global de conquistas do save da campanha. Os sistemas não devem depender de uma cena visual estar aberta para avançar a simulação.

## Etapa 1 — Fundação, prólogo e mundo explorável

### Recursos jogáveis
- Projeto Godot 4.x modular, cenas e scripts organizados, Git versionado.
- Menu principal, configurações, criação de personagem, escolha de dificuldade e save/load real.
- Prólogo no salão do rei, escolha persistente Aceitar/Recusar, início em duas cidades diferentes.
- Cenários isométricos com personagens 2D, terreno 3D contínuo, colisões, oito direções, câmera, interiores independentes.
- Vila, taverna, ferraria, quartos, serviços básicos, mapa mundial e viagem entre regiões com custo de energia.
- HUD, inventário e equipamentos iniciais, coleta e interação, diálogos e primeira missão.
- NPCs com ID estável, rotina básica, profissão, relações iniciais, visitantes de taverna com raridades.
- Fundações dos sete sistemas: evento persistente, diário de notícias, registro de memória, estados sociais, dados de tropas/batedores, migração e sucessão, registro de nêmesis (sem mecânicas profundas ainda).

### Novas mecânicas nesta etapa
1. **Crônicas do Mundo:** diário consultável de acontecimentos reais (primeiros rumores de taverna, mudanças de localização e eventos de missões). Notícias não inventam eventos sem registro.
2. **Memória dos NPCs:** salvar e carregar pelo menos eventos de ajuda, ofensa e recrutamento; reações iniciais em diálogos e reputação.
3. **Inteligência militar — estrutura:** informações de ameaças e exploradores modeladas; tela de resumo do risco da próxima onda poderá exibir dados básicos.
4. **Legado e sucessão — estrutura:** relações mestre/aprendiz, família e titularidade de propriedade modeladas, sem herança automática complexa.
5. **Política e moral — estrutura:** reputação por região e credibilidade; penalidade do Exilado e preços 3x funcionais.
6. **Inimigos mortais — estrutura:** ID e histórico de inimigos especiais preserváveis entre ondas.
7. **Migração regional — estrutura:** populações por região e movimentos rastreáveis como eventos.

### Portão de conclusão
Todos os fluxos principais do prólogo, da exploração, dos interiores, das viagens, da taverna, do inventário e da persistência passam nos testes. Jogador pode recusar o rei e observar penalidades aplicadas, sem travar a campanha. Dados de eventos/memórias sobrevivem a salvar e carregar.

## Etapa 2 — RPG, combate, profissões e sociedade viva

### Recursos jogáveis
- Combate, habilidades, equipamentos, XP, talentos e lealdade.
- Recrutamento com raridade e condições; histórias pessoais de NPCs autorais e procedurais coerentes.
- Profissões (ferreiro, agricultor, minerador, comerciante, curandeiro etc.), trabalho e economia local.
- Relações entre NPCs (amizade, família, rivalidade, romance, lealdade), mesmo quando não estão no grupo.
- Ferimentos, incapacitação e morte permanente; distinção clara para conquistas e eventos.

### Novas mecânicas nesta etapa
1. **Crônicas do Mundo:** notícias geradas por mortes, contratos, partidas, recrutamentos e mudanças de profissão.
2. **Memória dos NPCs:** peso, duração e relevância de memórias; decisões autônomas e consequências em recrutamento, diálogos e abandono.
3. **Legado e sucessão:** morte de mestre/dono com transferência coerente de ofício/propriedade para herdeiros/aprendizes elegíveis; consequências sociais.
4. **Política e moral:** grupos sociais, lealdade, decisões de governo local e reações coerentes de NPCs.
5. **Migração regional:** movimentação de aventureiros, trabalhadores e famílias com motivos, custos e destinos persistentes.
6. **Inteligência militar:** batedores recrutáveis, reconhecimento e informação imperfeita (a informação pode estar incompleta, não gerar visão total).
7. **Inimigos mortais:** registro de mortes/derrotas e encontros para suportar promoção posterior.

### Portão de conclusão
Testes de combate, recrutamento e recusa, morte/sucessão, memórias cruzadas, decisão autônoma de NPCs, migração e saves em diferentes regiões. Nenhuma morte deve ressuscitar via recarga ou reset de cena.

## Etapa 3 — Fortaleza, ondas, ameaças e ecologia regional

### Recursos jogáveis
- Propriedades, construção e organização de cômodos, oficinas, alojamentos, estoques, trabalhadores, impostos.
- Refugiados em ondas, necessidades e integração por profissão, com decisões e consequências.
- Ciclo de **uma onda a cada cinco dias**, preparação, combate, crescimento gradual de inimigos e ondas especiais.
- Caminho Guardião com defesa comandada pelo jogador; caminho Exilado com general SS e resolução autônoma de defesa.
- Após onda 20, **Masmorra Antiga do Lago**, sua entrada, acesso, exploração e progressão.
- Dificuldades influenciando inimigos, recursos, recompensas e XP; Impossível = 3x XP.

### Novas mecânicas nesta etapa
1. **Inteligência militar:** relatórios de reconhecimento sobre tipo, força aproximada e flancos inimigos; armadilhas e planejamento conforme relatório.
2. **Inimigos mortais evolutivos:** se inimigo derrotar permanentemente integrante do grupo principal e sobreviver ao final da onda, sobe patente e força; histórico de rivalidade, adaptação, habilidades e recompensa futura.
3. **Política e moral:** tensão entre camponeses, comerciantes, soldados e refugiados, decisões fiscais e rebeliões.
4. **Migração regional:** invasões provocam êxodo e alteram estoques, preços e segurança; efeitos simulados também fora da região visível.
5. **Legado e sucessão:** sucessores assumem funções militares/propriedades se elegíveis, mantendo continuidade da simulação.
6. **Crônicas do Mundo e Memória dos NPCs:** registrar batalhas, perdas, vitórias, promoções e impactos; personagens respondem à história real.

### Portão de conclusão
Simular e validar pelo menos 20 ondas com save/load, ramo Exilado independente, general SS capaz de falhar, promoção de inimigo nas condições exatas, economia e migração sem duplicação, e desbloqueio correto da masmorra após onda 20.

## Etapa 4 — Cinco finais, conquistas, conteúdo e acabamento

### Recursos jogáveis
- Missões ramificadas pelas cinco rotas e escolhas irreversíveis; narrativa original.
- Histórias pessoais interligadas, relações, heranças, traições e acontecimentos em regiões distantes.
- Conquistas por dificuldade, rotas, profissões, recrutamento, defesa e histórias dos NPCs.
- Desbloqueio de personagem secreto em **O Último Sobrevivente**.
- Interface, arte, efeitos, otimização, balanceamento, acessibilidade básica, saves migráveis e exportação para testes Windows.

### Novas mecânicas nesta etapa
1. **Crônicas do Mundo:** registros e epílogos que refletem o estado real das regiões e o destino dos NPCs.
2. **Memória dos NPCs:** consequências das decisões nos arcos finais e alianças/rompimentos.
3. **Inteligência militar:** desafios tardios com ameaças diversificadas e informações falíveis.
4. **Legado e sucessão:** resultados finais de linhagens, oficinas e comando militar.
5. **Política e moral:** elegibilidade de finais coerente com reputação, governo e marcos narrativos.
6. **Inimigos mortais evolutivos:** nêmesis veteranas com reconhecimento narrativo.
7. **Migração regional:** população, economia e consequências regionais consolidadas nos finais.

### Portão de conclusão
Os cinco finais alcançáveis e mutuamente válidos; conquistas obtidas exclusivamente sob suas condições; personagens secretos persistentes no perfil; testes de regressão, performance e integridade do pacote. Rodadas manuais em Windows permanecem pendentes até o usuário aprovar.

## Regra de entrega e qualidade (vale para TODAS as etapas)

**Somente gerar o arquivo de versão da etapa quando todas as funcionalidades daquela etapa estiverem implementadas, integradas e tecnicamente verificadas, restando apenas o teste de aceitação pelo usuário.**

Checklist obrigatório de entrega:
1. Requisitos rastreáveis (funcionalidade → cena/script/teste).
2. Nenhuma cena ou dependência ausente e nenhuma regressão nas etapas aprovadas.
3. Testes headless do Godot, validação de carregamento, mapa/colisões, saves e mecânicas centrais com resultados documentados.
4. Pacote-fonte Godot integral contendo `project.godot`, scripts, cenas, texturas e demais recursos; checksum SHA-256; manifesto de conteúdo; versão distinta das anteriores.
5. Disponibilização por canal externo **efetivamente verificado** (preferência GitHub Releases). Não representar arquivos de protótipo ou links de download não testados como jogo completo.
6. Entrega da etapa marcada **"Aguardando teste de aceitação no Windows"**, não "aprovada". Só depois do feedback do usuário fica oficialmente encerrada.

Versões planejadas: `Fortaleza_Etapa_01_Godot.zip`, `Fortaleza_Etapa_02_Godot.zip`, `Fortaleza_Etapa_03_Godot.zip` e `Fortaleza_Etapa_04_Godot.zip`. **Esses arquivos ainda não foram gerados.**

## Matriz resumida das sete novas mecânicas

| Mecânica | Etapa 1 | Etapa 2 | Etapa 3 | Etapa 4 |
|---|---|---|---|---|
| Crônicas do Mundo | Eventos e diário básico | Notícias sociais | Notícias de ondas/guerras | Epílogos |
| Memória dos NPCs | Modelo persistente | Reações e decisões sociais | Reações às guerras | Consequências nos finais |
| Inteligência militar | Dados e painel básico | Batedores | Planejamento e contra-ataques | Desafios finais |
| Legado e sucessão | Modelo família/ofício | Transferência de legado | Sucessão militar e gestão | Epílogos |
| Política e moral | Credibilidade e preços | Grupos e lealdade | Impostos e conflitos | Efeitos nos finais |
| Inimigos mortais evolutivos | Histórico persistente | Registro de combates | Promoção e evolução | Nêmesis finais |
| Migração regional | Populações e eventos | Movimentos de NPCs | Refugiados e êxodo | Consequências regionais |

**Este arquivo define o escopo; não certifica implementação.**


## Adendo 1.1 — Chefes, Masmorra Antiga do Lago, equipamentos e construções (03/11/2026)

### Progressão de chefes
- **Dez chefes principais** ligados à campanha, **cada um de uma raça diferente**, com identidade, mecânicas, arena, fraquezas e consequências próprias. Seus IDs e estados de vitória devem ser persistentes.
- **Minichefes** distribuídos por áreas, ondas, eventos e masmorras; derrotas e reaparições obedecem às regras explícitas de cada encontro, sem reiniciar chefes únicos ao carregar o jogo.
- **Chefe final** é desbloqueado apenas depois da derrota confirmada do **décimo chefe principal**; a condição de progresso exigirá registro persistente de vitória nos dez chefes, evitando atalhos por recarga de save. O encontro final estará sujeito à campanha/rota de forma que as cinco ramificações permaneçam concluíveis.
- Raças e identidades dos dez chefes serão desenvolvidas como **conteúdo original**. A especificação não pressupõe nomes ou espécies definidos pelo usuário.

### Masmorra Antiga do Lago e raridades
- Entrada liberada **após concluir a onda 20**, preservando a regra anterior.
- O conjunto de recompensas exclusivas da masmorra contém itens **Raros, Épicos e Lendários**.
- **Chefes derrotados dentro da masmorra** têm **chance de conceder itens Míticos**. Mítico é uma categoria de drop excepcional de chefe de masmorra, não um produto fabricável pela forja comum.
- **Baús** podem conter **receitas de fabricação** nas raridades **Rara, Épica e Lendária**. Ter a receita Lendária não elimina as restrições de capacidade da forja: ela poderá exigir um meio especial de fabricação/desbloqueio em etapa futura, ainda a especificar. Receitas não devem criar automaticamente itens sem custo/material.
- Cada item/receita terá identificador único, raridade, fonte, condições de obtenção, efeitos, atributos, requisitos e flag de unicidade quando aplicável.
- Chance exata de drop, garantias por repetição e distribuição de baús serão definidas durante o balanceamento, não presumidas agora.
- Itens únicos não podem ser duplicados por reabertura de baú, reinício de cena ou carregamento de save.

### Forja e progressão geral de construções
**Todas as construções evolutivas terão nível máximo 5**, com custos, requisitos, melhorias visuais e funções específicas por nível. O nível deve persistir em saves e contribuir para empregos, produção e economia.

| Nível da forja | Qualidade máxima regular fabricável | Comércio e função |
| --- | --- | --- |
| 1 | Comum | Ferreiros iniciantes fabricam itens Comuns |
| 2 | Incomum | Aprimora ferramentas e opções de fabricação |
| 3 | Raro | Produção de itens Raros com receita e materiais |
| 4 | Épico | Produção de Épicos; **chance de aparecerem itens Lendários na loja da forja** |
| 5 | Épico | Capacidade produtiva máxima regular continua Épica; maior eficiência, catálogo e melhoria de chances de oferta Lendária |

**Regra expressa:** upgrade para nível 5 **não libera fabricação regular Lendária ou Mítica**; itens Lendários podem aparecer para compra **desde o nível 4**. Receitas Lendárias obtidas em baús são colecionáveis/úteis para futuros meios especiais de produção, sem contradizer o teto Épico da forja regular. Os preços também respeitam o modificador regional de **3× para o Exilado** quando a loja pertencer à fortaleza.

O nível do prédio não substitui a habilidade do ferreiro: a produção requer simultaneamente prédio compatível, profissional habilitado, materiais, receita quando exigida e recursos/tempo suficientes. Ferreiros iniciantes produzem Comuns independentemente de edifícios avançados até se qualificarem.

### Modelo de dados para estes sistemas
- `BossState`: id, raça, tipo (principal/minichefe/final/masmorra), derrotado, histórico do encontro, progressão de desbloqueios.
- `DungeonState`: entrada liberada, andares, salas, chefes, baús e recompensas já reivindicadas.
- `ItemDefinition`/`ItemInstance`: id, raridade, singularidade, fonte, atributos e propriedades; sem duplicação de itens únicos.
- `RecipeDefinition`/`RecipeUnlock`: raridade e estado persistente de receita descoberta.
- `BuildingState`: tipo, nível de 1 a 5, custo e efeitos de upgrade; `ForgeState`: catálogo, estoque, trabalhador e qualidade máxima regular.
- Tabelas de drops e comércio serão configuráveis/testáveis e usarão aleatoriedade salva de modo verificável.

### Distribuição obrigatória nas etapas
1. **Etapa 1 — Fundação:** estruturas de dados de raridade, itens únicos, receitas, prédios de nível 1–5, chefes e progresso persistente; primeiras construções e interface de progressão como base técnica, sem prometer masmorra completa.
2. **Etapa 2 — RPG/combate/profissões:** itens por raridade, receitas, ferreiro com evolução de habilidade, combate e estruturas reutilizáveis de minichefes; validar teto de qualidade por trabalhador e nível.
3. **Etapa 3 — Fortaleza e masmorra:** construções evolutivas de nível máximo 5, loja da forja com chance de Lendários desde nível 4, onda 20 liberando Masmorra Antiga do Lago, chefes e drops da masmorra, baús com receitas; integrar recursos e economia.
4. **Etapa 4 — Campanha e finais:** completar conteúdo dos **dez chefes principais de raças diferentes**, desbloqueio do chefe final após o décimo, integração aos cinco finais, desafios finais, balanceamento e testes de regressão.

### Critérios de aceitação adicionais
- A conclusão da onda 19 **não** libera a masmorra; a conclusão da onda 20 libera, inclusive na rota Exilado após simulação válida da defesa.
- Derrotar nove chefes principais **não** desbloqueia o chefe final; derrotar todos os dez desbloqueia uma única vez.
- A forja no nível 3 fabrica até Raro, no nível 4 até Épico e já pode vender Lendário, e no nível 5 continua limitada a Épico na fabricação regular.
- O profissional iniciante não produz Épico só porque o edifício tem nível alto.
- Mítico só participa da tabela especial de chefes da masmorra, e não do catálogo regular da forja.
- Receitas e drops únicos persistem sem duplicação após save/load.
- Construções não ultrapassam o nível 5; custos e efeitos são aplicados exatamente uma vez.
- **Regra de entrega permanece:** gerar ZIP da etapa somente após implementação integral, revisão de código e testes técnicos passarem; resta apenas a aceitação do usuário em Windows.



## Adendo 1.2 — Bestiário, expedições e Memorial dos Caídos (03/11/2026)

**Bestiário e enciclopédia:** registro persistente por perfil/campanha de criaturas vistas, chefes, fraquezas efetivamente descobertas, regiões, receitas e NPCs. Entradas ocultas até descoberta; informações não são automaticamente reveladas. Fundação do índice e interface básica na **Etapa 1**; descobertas de combate e profissões na **Etapa 2**; informações da masmorra e invasões na **Etapa 3**; catálogo completo na **Etapa 4**.

**Expedições de companheiros:** na **Etapa 2**, preparar dados de equipe, duração, objetivo, provisões e risco. Na **Etapa 3**, executar expedições autônomas em avanço do calendário para coleta, pesquisa de ruínas ou resgate de refugiados, com eventos narrativos, ferimentos, desaparecimentos e morte permanente quando habilitada. Impedir duplicação de recompensas após carregamento; não permitir enviar NPC morto/ausente.

**Memorial dos Caídos:** salvar fatos de cada morte permanente (ID, nome, profissão, feitos, data, local, circunstância e relação). Construção/visitação com interações e reações dos NPCs na **Etapa 3**, completando epílogos e histórico na **Etapa 4**. Na **Etapa 1**, somente estrutura de registro de mortes (sem marcar a funcionalidade completa como concluída).

### Distribuição e regra de entrega
- **Etapa 1:** índice de Bestiário, dados de expedição e histórico de falecimentos persistentes; protótipos funcionais apenas dos módulos pertencentes ao escopo da etapa.
- **Etapa 2:** integração do Bestiário com combate, receitas e profissões; preparação de expedições.
- **Etapa 3:** expedições completas, memorial como propriedade, mortes e migrações persistentes.
- **Etapa 4:** enciclopédia, histórias cruzadas, conquistas e epílogos integrados.
- **Obrigatório:** gerar ZIP da Etapa 1 somente quando todos os requisitos dessa etapa estiverem implementados e tecnicamente testados; depois disso faltará apenas o teste de aceitação do usuário.

## Registro do início da Etapa 1
O desenvolvimento recomeça em uma **pasta independente `novo_projeto/`**, sem depender do antigo protótipo da raiz. Componentes devem ser adicionados incrementalmente, e a primeira publicação de código não constitui aprovação nem entrega da Etapa 1. Os arquivos novos precisam passar por carregamento e testes Godot antes do ZIP final.


## Regra obrigatória permanente — desempenho e polimento ANTES de qualquer ZIP (03/11/2026)

**Pedido fixado pelo usuário:** nenhuma entrega ZIP de qualquer etapa pode ser gerada antes de **otimizar o código** e **polir o visual** para reduzir travamentos e preservar uma apresentação bonita e fluida. Essa regra se soma aos requisitos de implementação completa, testes técnicos e aceitação posterior em Windows; não pode ser dispensada para protótipos.

Checklist de bloqueio para o ZIP:
1. Revisão de código: remover cálculos repetidos a cada quadro, evitar alocações desnecessárias e duplicação de texturas/materiais; usar cache, eventos, simulação por intervalos e estruturas compartilhadas; limpar nós e sinais; verificar leaks.
2. Revisão de cena: testar movimentos, colisões físicas, câmera, interiores, transições, interface, iluminação, legibilidade, animações e consistência visual entre regiões. Evitar terrenos flutuantes e arte provisória no pacote de aceitação.
3. Testes e medição: registrar FPS e tempos de quadro em Windows e na máquina de desenvolvimento, carregamento de cenas, uso de memória e estabilidade em regiões povoadas e durante simulação de mundo/ondas. Definir orçamentos e limites com base na máquina-alvo e nos testes, sem inventar métricas antes de medir.
4. Ajustes de desempenho: geometria de baixa complexidade, materiais/texturas reutilizados, iluminação adequada ao hardware, culling e simulação de NPCs por proximidade, processamento de eventos só quando necessário; parâmetros gráficos ajustáveis.
5. Verificação de regressão e integridade de saves, além de checklist de recursos, dependências e resultados de testes reproduzíveis.
6. **Somente depois** gerar o ZIP da etapa e entregá-lo como `Aguardando aceitação do usuário no Windows`.

O código e as cenas iniciais do `novo_projeto/` continuam **em desenvolvimento**; resultados headless não provam FPS real ou polimento artístico.


## Adendo 1.3 — Evento do Duque, herdeira e boss extra (03/11/2026)

**Evento original**, incorporado ao jogo sem reproduzir personagens ou falas de obras de terceiros.

### Personagens e pré-requisitos
- **Duque**, NPC único e recrutável de **rank A**, na **Mansão do Duque (Fortaleza)**.
- Visitar a mansão e responder **seis charadas, no máximo uma por dia do jogo**. Perguntas e escolhas narrativas são originais. O sistema marca respostas e dias para impedir múltiplas tentativas por save/load.
- É preciso terminar as seis perguntas e atingir **amizade de pelo menos 75 pontos (Amigo Leal)** para recrutá-lo, **antes do início da onda 10**. Escala inicial: resposta certa +15, errada +5, máximo 100; com seis perguntas são necessários ao menos cinco acertos (+80).
- A regra de Exilado permanece: não pode recrutar moradores da Fortaleza, incluindo o Duque.

### Bifurcação irrevogável na onda 10
- **Com o Duque recrutado antes da onda 10:** surge um **boss extra original**, provisoriamente chamado **Carrasco do Juramento**. Ao derrotá-lo, inicia-se uma **cutscene** da morte do Duque. Ao concluir essa cena, o Duque morre permanentemente; a **Armadura do Duque**, item único, é concedida uma única vez; a **filha do Duque**, heroína de **rank S**, passa a aparecer na mansão, podendo ser recrutada. Boss, batalha e encenação cinematográfica completos serão implementados na Etapa 3/4; a Etapa 1 somente registra e protege esses estados.
- **Sem cumprir os requisitos e recrutar antes da onda 10:** o Duque **morre em casa**, sem boss extra, sem cutscene especial e **sem possibilidade de obter a Armadura do Duque**. Morte e consequências permanecem registradas.
- Após a **onda 30** (ou seja, a partir da onda 31), a filha poderá aparecer na taverna de Porto Cinzento, com **1% de chance por renovação diária elegível**. Uma mesma data não deve gerar novas tentativas ao reabrir a taverna. Ela continua rank S, mas, por não haver Armadura do Duque nessa rota, não completa o ritual de legado necessário para evoluir a SS.

### Evolução da filha S → SS
- Precisa ser recrutada.
- Precisa concluir a missão **O Legado da Armadura**, apresentando a Armadura do Duque (exclusiva do evento completo).
- Precisa de materiais da Masmorra Antiga do Lago: valores iniciais para balanceamento **3 Cristais do Lago e 1 Núcleo Ancestral**, consumidos uma única vez na evolução. A masmorra é liberada depois da onda 20.
- A evolução será implementada no sistema completo de personagens/itens, sem criar meios de obter a armadura no caminho da morte em casa.

### Fases
- **Etapa 1:** dados persistentes, cena inicial de mansão, seis perguntas originais, amizade, recrutamento e estado do evento; registros de crônicas.
- **Etapa 2:** personagem A, filha S e missões de relacionamento/equipamentos devidamente integrados ao combate, inventário e lealdade.
- **Etapa 3:** boss extra na onda 10, batalha verdadeira, animação de morte, armadura única, acesso à filha na mansão e materiais da Masmorra do Lago.
- **Etapa 4:** evolução S→SS, narrativa refinada, retratos, dublagem/sons opcionais e cenas cinematográficas polidas.

### Critérios de validação
- Não permitir mais de uma pergunta por dia nem recrutamento com menos de seis perguntas/75 pontos, ou após iniciar a onda 10.
- A onda 10 deve resolver o destino uma única vez, mesmo com múltiplos saves/loads.
- A morte em casa nunca concede armadura.
- Boss extra não concede automaticamente armadura antes de sua derrota e do fim da cutscene.
- O evento concluído concede uma única Armadura do Duque e desbloqueia a filha na mansão.
- A herdeira rara surge na taverna apenas após a onda 30, chance real de 1% por renovação elegível, não por cada clique.
- A evolução SS requer armadura, missão e materiais, sem gastos duplicados.
- A regra absoluta de otimização, polimento e testes ANTES do ZIP continua em vigor.

**Estado técnico:** regras e alguns caminhos de interface implementados inicialmente em `novo_projeto/scripts/duke_event.gd`, `game_state.gd` e `world.gd`; boss/cutscene não são jogáveis ainda. O teste automatizado de regressão `tests/test_duke_event.gd` foi criado e precisa de execução/validação técnica no motor antes da entrega da etapa.


## Adendo 1.4 — Amizade por niveis e permanencia nas tavernas (03/11/2026)

- Relacionamento geral entre protagonista e NPCs em **cinco niveis**: **Indiferente (0–19)**, **Conhecido (20–39)**, **Amigos (40–59)**, **Confidente (60–79)** e **Leal ate a Morte (80–100)**. Recrutamento comum so no ultimo nivel, respeitando restricoes regionais e o NPC estar presente na taverna. Pontos persistem quando o NPC muda de cidade.
- Personagens excepcionais seguem gatilhos proprios: o **Duque** precisa de seis charadas/75 pontos antes da onda 10; sua **herdeira** usa os desfechos especificos de seu evento.
- Cada visitante fica na taverna por **quatro dias consecutivos de calendario** (chegada no primeiro dia, saida no quinto); a duracao nao reinicia ao abrir/fechar menus nem ao salvar e carregar.
- Ao sair, um NPC pode **permanecer na vila** com rotina propria ou **seguir viagem** e reaparecer em outra cidade depois de um intervalo. O destino e influenciado pela historia individual: a conclusao da missao de Elira, por exemplo, faz com que ela opte por permanecer na comunidade quando deixar sua estadia.
- Os itinerarios sao estados persistentes de mundo, avancados uma vez a cada dia do jogo, inclusive enquanto o protagonista esta em outra regiao. Chegada/saida aparecem nas Cronicas do Mundo.
- Se o jogador recrutar um visitante elegivel durante a estadia, ele deixa o itinerario autonomo de viajante e passa para o estado de integrante do grupo.
- A aparicao especial da herdeira do Duque apos a onda 30 continua com chance de **1% por verificacao diaria elegivel**, mas uma aparicao bem-sucedida a mantem na taverna por **quatro dias**, sem novas rolagens durante essa visita.
- Estruturas iniciais no `novo_projeto/`: `friendship_system.gd`, `town_system.gd`, `game_state.gd`, `duke_event.gd` e `world.gd`. Testes de regressao criados/atualizados, ainda requerendo execucao da versao sincronizada antes de qualquer entrega.

**Importante:** esse sistema de agendas e uma base funcional de dados e regras; movimentacao animada e rotina fisica completa dos NPCs em cena ainda pertencem a iteracoes futuras. Mantem-se a regra de nao gerar ZIP antes da conclusao da etapa, otimizacao, polimento e testes.
