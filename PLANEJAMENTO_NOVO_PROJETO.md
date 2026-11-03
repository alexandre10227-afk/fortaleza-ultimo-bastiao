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
