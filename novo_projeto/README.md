> **STATUS CONSOLIDADO (03/11/2026):** principais sistemas da fundação foram implementados. **A Etapa 1 não está formalmente concluída** até a aprovação integral dos testes de CI, inspeção gráfica e medição de desempenho no Windows. A auditoria atual é [ETAPA_1_AUDITORIA.md](../ETAPA_1_AUDITORIA.md). O código tem mapa clicável, oito direções de caminhada, interiores separados, configurações, campanha persistente e sistemas sociais básicos. **Não gerar ZIP final antes da validação.**

# Fortaleza: Último Bastião — Novo Projeto / Etapa 1

**Status:** implementação inicial em andamento. **Não representa a Etapa 1 concluída nem uma versão pronta para o teste de aceitação.**

Os arquivos na pasta `novo_projeto/` são a base do recomeço, separada dos arquivos do protótipo legado na raiz do repositório.

## Já codificado
- Projeto Godot 4.x com autoload `GameState`.
- Menu de criação: nome e quatro dificuldades.
- Cena de audiência com rei e escolha Guardião/Exilado.
- Estado persistente em JSON (versão 1), com região, dia, reputação, memória de NPCs e histórico de eventos.
- Penalidades do Exilado modeladas: preços da fortaleza 3x, recrutamento local bloqueado e defensor SS atribuído como evento (a simulação de combate dele ainda não existe).
- Contador de dias com onda registrada a cada cinco dias; liberação do registro da masmorra depois da onda 20 (não existe exploração de masmorra nesta etapa).
- Cena tridimensional experimental com personagem em Sprite3D, câmera ortográfica, formas primitivas e movimento por WASD; falta arte final, colisões e separação verdadeira de cidades.
- HUD e visualização inicial das Crônicas do Mundo.
- Teste automatizado de lógica para dificuldade, juramento, penalidades, ondas, XP de viagem, persistência e memória.

## Ainda pendente na Etapa 1
- Arte original 2D/3D, terreno e interiores completos, colisões e animações fluidas.
- Cidade Fortaleza e Porto Cinzento com geografia, NPCs e entradas independentes.
- Tavernas com visitantes persistentes, horários, raridade e comportamento autônomo.
- Inventário, interação com itens, comércio, coleta, equipamentos e missões de abertura.
- Mapa mundial visual com escolha efetiva de destinos e controle de viagem.
- Interfaces completas, sistema de configurações, escolha de aparência e polimento.
- Testes de regressão de todas essas funcionalidades.
- Base persistente de bestiário, expedições e memorial integrada ao conteúdo.
- Canal externo de download de release **verificado**, depois da conclusão integral da etapa.

## Executar localmente (para desenvolvimento, não aceite final)
Importe `novo_projeto/project.godot` no Godot 4.7.x. F5 inicia a cena do prólogo.

Teste automatizado do estado:
```bash
godot --headless --path novo_projeto --script res://tests/test_state.gd
```

**Regra de entrega:** o ZIP `Fortaleza_Etapa_01_Godot.zip` será gerado somente após todas as funções previstas para a Etapa 1 estarem implementadas e tecnicamente testadas, restando apenas a avaliação do usuário no Windows.

A atualização de planejamento está em [PLANEJAMENTO_NOVO_PROJETO.md](../PLANEJAMENTO_NOVO_PROJETO.md).


## Incremento seguinte da Etapa 1 — taverna, economia e inventário (03/11/2026)

Novos arquivos: `scripts/town_system.gd`, `tests/test_town.gd`. `game_state.gd` e `world.gd` receberam integração.

**Funcionando em nível inicial:** visitantes da taverna com IDs e raridades estáveis, rotação determinística por região e dia, compra de pão com desconto automático de moedas, inventário com quantidade, recrutamento sem duplicação, bloqueio de residentes da fortaleza para Exilado, preço regional triplicado, save/load de inventário, moedas e companheiros.

Controles temporários no mundo: `V` abre visitantes da taverna; teclas `1` a `5` tentam recrutar; `B` compra pão; `I` exibe inventário; `C` abre crônicas; `N` avança um dia. Esses controles são atalhos de debug e serão substituídos por interações físicas com NPCs, balcões e menus definitivos.

**Testes locais Godot 4.7.2:** editor abriu sem erro; `tests/test_state.gd` e `tests/test_town.gd` passaram, além da inicialização headless de `world.tscn`. Testes de aceitação e revisão visual permanecem pendentes.

**Limitações conhecidas:** a rotação de visitantes ainda é uma lista pequena de personagens definidos no código, não um gerador completo de raridades ponderadas; os estabelecimentos ainda não são interiores funcionais; movimentação não usa colisão de física; faltam trabalho/coleta, missões, inventário visual e mapa mundial selecionável. A etapa continua em andamento: **não gerar ZIP final**.


## Incremento de exploração — terreno, entradas e mapa (03/11/2026)

- **Terreno:** superfície ampliada com textura procedural original simples, evitando depender de assets externos neste estágio.
- **Cenário:** NPCs em `Sprite3D` como marcadores visuais iniciais; ainda não possuem inteligência, diálogos ou rotinas visíveis.
- **Colisões preliminares:** movimentação bloqueia volumes retangulares de casas. **Não é colisão física completa**: faltam `CharacterBody3D`, `StaticBody3D`, portas, mobília e navegação.
- **Interiores:** entrar e sair por proximidade e tecla `E`; Taverna, Ferraria, Quarto e Salão têm layout e objetos provisórios distintos. Ainda não são cenas finais independentes.
- **Mapa mundial:** abrir com `M` ou `T` e escolher entre Fortaleza e Porto Cinzento. Viagem desconta 5 de energia, concede XP de Agilidade e muda região no estado persistente. Ainda falta diferenciar visualmente as duas cidades.
- **Interação contextual:** taverna só abre pelo atalho `V` dentro do interior; compras por `B` apenas em taverna/ferraria.
- **Novo teste:** `tests/test_exploration.gd` exercita bloqueio de casas, entrada/saída de interiores, mapa e mudança de região.

**Validação local efetuada:** os testes `test_state.gd`, `test_town.gd` e `test_exploration.gd` passaram no Godot 4.7.2 Linux headless; inicialização headless também não relatou erros. Esses testes **não validam qualidade visual, colisões físicas reais ou experiência Windows**.

**Status:** Etapa 1 em desenvolvimento. Sem ZIP de aceite até implementar mapa e cidades distintos, NPCs com comportamento, coleta, missões, inventário visual, colisões físicas, interiores definitivos, salvamento da posição, interface e revisão geral.


## Incremento de engenharia e desempenho — 03/11/2026

**Exigência fixa do projeto:** antes de qualquer ZIP de aceite, revisar/otimizar código, polir gráficos e medir desempenho. O checklist obrigatório está em `PLANEJAMENTO_NOVO_PROJETO.md`. Uma execução headless sem erros **não equivale** a FPS verificado, ausência de lag ou aprovação visual.

**Código implementado nesta atualização:**
- Personagem principal migrou para `CharacterBody3D` com `CollisionShape3D`.
- Dez edifícios no cenário receberam `StaticBody3D` e `BoxShape3D` para colisões físicas iniciais. Ainda não estão implementados pisos/rampas físicos, colisão de mobília ou animações.
- Sprites provisórios compartilham um único `ImageTexture` gerado em vez de repetir a criação da textura para cada NPC.
- Materiais 3D repetidos são compartilhados por cor (`_shared_materials`), evitando gerar recursos duplicados; seis materiais reutilizados no mapa do teste.
- Dica contextual passou a atualizar a cada 0,18 s, apenas mudando o texto quando necessário, em vez de recalcular em todos os quadros.
- Ao sair de um interior, o personagem retorna à posição anterior; interiores eliminam imediatamente nós anteriores da árvore ao reconstruir.

**Validação técnica local:** Godot 4.7.2 em modo headless: `test_state.gd`, `test_town.gd`, `test_exploration.gd`, `test_optimization.gd` e inicialização do projeto passaram. O teste novo verifica personagem físico, dez edifícios com corpos físicos, compartilhamento dos quatro sprites e limite de materiais de cena. Não foi efetuado teste de desempenho gráfico no Windows; FPS e consumo de VRAM seguem **não medidos**.

**Próximos bloqueios para o ZIP:** cidades realmente diferenciadas, interiores próprios/colisão de móveis, animação 2D direcional, NPCs autônomos, missões/coleta, UI final e medição de desempenho real antes de empacotar.


## Incremento: identidades das duas cidades e moradores interativos (03/11/2026)

- `scripts/region_system.gd`: dados autorais de **Fortaleza** (fronteira militar, muralhas e torres) e **Porto Cinzento** (núcleo portuário, cais e água), paletas ambientais e residentes regionais.
- `scripts/world.gd`: troca visual de cidade ao viajar; detalhes regionais são reconstruídos apenas durante mudança de região, e não por quadro.
- Dois moradores por cidade recebem `Sprite3D` compartilhado, nome/ID, profissão e fala próprios. A tecla `Q` conversa com residente próximo; conversas são eventos registrados na memória persistente de NPCs. Posições seguem uma pequena rotina determinística por dia.
- `tests/test_regions.gd`: cobre apresentação lógica das duas regiões, substituição de moradores, conversa, memória e persistência. `tests/test_optimization.gd` atualizado à nova quantidade de sprites visíveis.
- **Resultados locais Godot 4.7.2 headless:** `test_state`, `test_town`, `test_exploration`, `test_optimization` e `test_regions` passaram na cópia local atualizada. Os testes são de lógica e estrutura; não verificam FPS real em Windows.
- **Limitações:** cenário ainda usa blocos 3D; NPCs mudam de posição no calendário, mas ainda não caminham animados em tempo real; não há biomas finalizados nem cidades com plantas arquitetônicas próprias. Não tratar esta atualização como arte final.

**Em seguida:** organizar mapas e interiores em cenas reutilizáveis, criar animação de movimento e rotina real de NPCs e integrar missões iniciais. Antes do ZIP haverá otimização e polimento artístico obrigatórios.


## Incremento: caixa de diálogo oriental original 9-slice (03/11/2026)

**Implementado:** componente reutilizável `scripts/dialogue_panel.gd`, integrado às cenas `start.gd` (audiência com Rei Aldric) e `world.gd` (conversas com residentes).

- Moldura original com visual **madeira/pergaminho**, criada proceduralmente (não são arquivos extraídos de Hero's Adventure).
- `StyleBoxTexture` com **margens 9-slice de 16 px** para preservar os quatro cantos quando o painel é redimensionado.
- Caixa de nome (`NameBox`), texto progressivo **Typewriter** (0,025 s por caractere), botão para avançar e opção de pular a animação.
- Escolhas clicáveis que disparam sinal; o juramento do rei aplica Guardião ou Exilado, e os NPCs têm primeira pergunta e despedida.
- Durante a conversa, os controles de movimentação e os atalhos da exploração ficam bloqueados; a interface usa apenas um componente e pode ser reaproveitada em missões e romances.
- `tests/test_dialogue.gd`: verifica nome, revelação, pulo da animação, opções, sinal e fechamento.
- **Testado localmente no Godot 4.7.2**: seis testes (`test_state`, `test_town`, `test_exploration`, `test_optimization`, `test_regions`, `test_dialogue`) aprovados em headless. Inicialização da cena principal também não mostrou erro no teste headless.

**Pendente:** arte/texturas definitivas, fonte caligráfica licenciada, retratos individuais, sons de máquina de escrever, transições animadas, navegação por controle e validação visual em resolução diferente. Não confundir com UI final polida nem com etapa concluída.

**Entrega:** sem ZIP; valem as exigências de otimização, revisão de interface e medição de desempenho antes do pacote de aceitação.


## Incremento: missões iniciais e coleta persistente (03/11/2026)

**Implementado e publicado no código:** primeiro ciclo de missão obtida por diálogo com escolha, coleta de recursos próximos e entrega ao NPC.

- Fortaleza: Doran oferece **Ferro para as muralhas**; entregar 3 unidades de minério de ferro rende 35 moedas.
- Porto Cinzento: Elira oferece **Suprimentos do porto**; entregar 3 unidades de ervas rende 35 moedas.
- Falar com o morador próximo usando `Q`; selecionar a opção de ajuda. Visitar pontos de coleta visíveis pelo cenário e usar `G` para coletar.
- Cinco pontos de coleta iniciais por região, com reposição no dia seguinte. Um ponto não pode ser coletado mais de uma vez no mesmo dia, inclusive após salvar/recarregar.
- Missões são iniciadas e concluídas uma única vez; consumo dos itens e pagamento são atômicos na lógica de campanha. Estados e eventos persistem no save JSON atual.
- As missões e coletas entram nas Crônicas do Mundo e a conclusão é lembrada pelo NPC.
- Novo teste automatizado `tests/test_quests.gd`: verifica estado, entrega insuficiente, conclusão sem repetição, reposição diária, salvamento e carregamento.

**Validação executada localmente no Godot 4.7.2 em modo headless:** os seis testes anteriores e o novo `test_quests.gd` passaram (7/7), e o editor importou o projeto sem erros de script. Não são testes de FPS nem de aceitação no Windows.

**Limitações:** recursos ainda usam malhas simples; missões são exemplos iniciais, não os cinco arcos completos. Ainda faltam painéis de missões, animações, navegação, arte e interiores definitivos. A Etapa 1 **não está concluída** e nenhum ZIP de aceite foi gerado.


## Pesquisa e aplicação do visual Wuxia/Dark Fantasy — 03/11/2026

**Fontes pesquisadas:** [Willosuna Fantasy UI Kit](https://willosuna.itch.io/fantasy-ui-kit), [Drakesigil Dark Fantasy RPG UI Essentials](https://drakesigil.itch.io/drakesigil-dark-fantasy-rpg-ui-essentials), [Gilded Fantasy UI Kit Lite](https://gildedforge.itch.io/gilded-fantasy-ui-kit-lite-free-sample), [Abyssal Forge no Unity Asset Store](https://assetstore.unity.com/packages/2d/gui/abyssal-forge-dark-fantasy-rpg-ui-kit-410980). Os kits serviram como **referências de características genéricas**, não foram comprados nem copiados.

**Aplicado de modo original no Godot:**
- `scripts/ui_theme.gd`: paleta própria de pergaminho claro, madeira escura e bronze envelhecido, com `StyleBoxFlat` para painéis, botões nos estados normal/hover/pressionado/desabilitado, campos de texto e cores de raridade (Comum a Mítico).
- Criação de personagem e seletor de dificuldade usam a nova biblioteca de estilos.
- Escolhas e botão de continuar no diálogo 9-slice original usam botões do tema. Continua preservado o efeito Typewriter e a NameBox.
- Mapa mundial recebe moldura e botões correspondentes à mesma identidade.
- Nova bateria `tests/test_ui_theme.gd` verifica estilos, cores de raridade e integração inicial com diálogos.
- **Validação local:** importação sem erros no Godot 4.7.2 Linux headless e oito conjuntos de testes lógicos executados: campanha, comércio, exploração, otimização, regiões, diálogo, missões e tema. O teste isolado de interface passou mas imprimiu avisos de limpeza de objetos ao encerrar abruptamente em modo headless; a limpeza do teste deve ser melhorada.

**Ainda pendente antes de qualquer ZIP:** revisão visual em janela gráfica, responsividade 16:9 e resoluções menores, ícones originais, retratos, fontes, HUD/inventário/taverna/lojas totalmente tematizados, acessibilidade, otimização visual e medição real de FPS.

**Direito de uso:** arquivos pagos de lojas não foram adicionados ao repositório; uso de terceiros somente após obtenção autorizada e conferência da licença de redistribuição dentro de um projeto público.


## Incremento narrativo — revisão temática do manhwa e diálogos profundos (03/11/2026)

- Fonte primária de referência temática: [sinopse oficial do WEBTOON](https://m.webtoons.com/en/fantasy/i-became-the-tyrant-of-a-defense-game/list?title_no=10765); estrutura de arcos consultada como contexto em [Fabledex](https://www.fabledex.com/stories/tyrant-of-the-tower-defense-game). **A campanha de Fortaleza tem diálogos, nomes e enredo originais**. Ver a [bíblia narrativa](../HISTORIA_ORIGINAL.md).
- `scripts/story_content.gd`: conteúdo autoral com o dilema de salvar um ferido versus manter o portão fechado; reações do rei e diálogos regionais que mudam conforme rota, missão e memória.
- `scripts/start.gd`: audiência real dividida em cenas de texto e duas escolhas consecutivas. A primeira registra `first_principle = compassion/duty` e a segunda seleciona Guardião/Exilado, preservando o fluxo já existente.
- `scripts/game_state.gd`: `narrative_flags` no mesmo save versionado; decisões só podem ser registradas uma vez por chave e são relatadas nas Crônicas do Mundo.
- `scripts/world.gd`: Doran e Elira lembram encontros e serviços; Mira e Kael expressam preocupações e respondem ao caminho inicial.
- `tests/test_story.gd`: verifica sequência, decisão irreversível, consequências de Exilado, diferenças de texto e persistência.

**Validação local no Godot 4.7.2:** testes `test_state`, `test_town`, `test_exploration`, `test_optimization`, `test_regions`, `test_dialogue`, `test_quests` e `test_story` passaram; `test_ui_theme` também reportou PASS, porém mantém avisos de recursos ao fechar abruptamente no headless. A abertura da cena principal com `--quit-after 15` terminou sem erros. Não houve revisão gráfica em janela Windows.

**Pendências:** História das cinco rotas e desenvolvimento dos NPCs são conteúdo futuro; as falas condicionais da Etapa 1 não equivalem a IA social completa. A Etapa 1 permanece incompleta e **nenhum ZIP de aceite foi gerado**.


## Incremento: evento opcional do Duque — núcleo inicial (03/11/2026)

- `scripts/duke_event.gd`: seis perguntas originais, no máximo uma por dia, amizade e requisito de 75 pontos, recrutamento antes da onda 10, bifurcação mortal, armadura exclusiva e filha S com evolução SS condicionada à missão e materiais da masmorra.
- `scripts/game_state.gd`: estado persistente `duke_state`; virada da onda 10 escolhe entre **boss extra pendente** e **morte em casa**. Morte, armadura e herdeira não são ativadas pelo simples avanço do calendário no caminho especial: exigem vitória do boss e conclusão da cutscene, a implementar.
- `scripts/world.gd`: a mansão pode ser acessada na Fortaleza (edifício lateral ao fim da fileira). Dentro: `Q` conversa/responde charada via caixa Wuxia, `R` tenta recrutar o Duque ou a filha. Após a onda 30, a filha tem 1% por renovação diária elegível de aparecer na taverna de Porto Cinzento.
- `tests/test_duke_event.gd`: testes de requisitos, prazo, exclusividade da armadura, boss pendente, save/load e evolução condicional **adicionados ao repositório, porém ainda não executados nesta atualização**.
- A integração de combate real do boss, o vídeo/cutscene de morte e os drops completos da masmorra dependem das Etapas 2–4. **Não relatar esses elementos como prontos.**
- **Sem ZIP:** prevalecem otimização, polimento gráfico e verificação técnica real antes de entregar a etapa para aceite.


## Incremento social: cinco niveis de amizade e estadias de quatro dias (03/11/2026)

- `scripts/friendship_system.gd`: Indiferente 0–19, Conhecido 20–39, Amigos 40–59, Confidente 60–79, Leal ate a Morte 80–100; somente ultimo nivel habilita **recrutamento comum**.
- `scripts/town_system.gd`: visitantes chegam em dias programados e ficam **quatro dias consecutivos**. Na manha do quinto dia deixam a taverna; podem fixar residencia na vila ou viajar para outra cidade. Alguns retornam em estadias posteriores.
- `scripts/game_state.gd`: itinerarios `npc_lives` e condicoes de historia `npc_story_flags` persistem no save. Dia a dia gera eventos de chegada e saida no diario. Memoria e amizade nao reiniciam quando o NPC viaja.
- Quando Elira conclui sua missao inicial, o roteiro dela passa a priorizar fixar residencia depois de uma visita. NPC recrutado deixa sua agenda automatica de visitante.
- A herdeira especial do Duque obedece a mesma permanencia de quatro dias quando sua aparicao rara de 1% ocorre.
- `scripts/world.gd`: a taverna mostra o nivel de amizade e os dias restantes. NPCs que ficam na cidade podem participar da lista de moradores visiveis.
- Novos testes em `tests/test_tavern_life.gd`; `test_town.gd` e `test_duke_event.gd` atualizados conforme as regras. **Esses testes ainda necessitam uma rodada completa de execucao na versao publicada**. Nenhum ZIP de aceite gerado.


## Incremento: presentes exclusivos por categoria e economia de itens (03/11/2026)

**Regra fixa:** cada NPC **aceita presentes de uma unica categoria**; qualquer presente de outra categoria e recusado sem consumo nem ganho de amizade. Categorias atribuidas: Doran=Minerios, Elira=Armas, Mira=Comestiveis, Kael=Armas, Selene=Estudos, Duque=Arte, herdeira=Arte. As excecoes de recrutamento e missao do Duque permanecem.

- `scripts/item_catalog.gd`: catalogo autoral das cinco categorias com as raridades Comum, Raro, Epico e Lendario, precos de compra/venda e pontos de amizade por raridade **somente em presentes aceitos**.
- `scripts/unique_weapons.gd`: Espada do Heroi e Armadura do Duque separadas de todos os mercados e presentes comuns.
- `scripts/economy_system.gd`: custos de receitas e niveis de construcoes ate 5; consumo seguro de materiais e dinheiro.
- `scripts/game_state.gd`: metodos `give_gift`, `market_buy`, `market_sell`, `eat_food`, `craft_item` e `upgrade_building`; limites de presentes por dia e persistencia no save. Personagem especial falecido/indisponivel nao recebe presente.
- `scripts/world.gd`: `P` abre a selecao de presentes do inventario para o NPC proximo, personagem na mansao ou visitante selecionado na taverna. Dialogos incluem opcao de oferecer presente. `O` abre mercado na taverna/ferraria ou quando ha caravana; `Z` alterna comprar/vender, `L` passa de pagina, teclas 1–5 negociam. A caravana possui janela inicial de quatro dias e adicional de preco.
- `tests/test_item_economy.gd` criado com checagens de recusas, raridade, mercado, comida, receitas, construcoes e salvamento. **Este novo teste ainda nao foi executado no motor nesta rodada**; nao declarar a atualizacao aprovada por Godot sem os resultados.
- **Pendente:** menus definitivos de forja/obras, alvos de comida para todos os companheiros, variacao de estoque, visuais definitivos, balanceamento e testes reais de FPS antes do ZIP.


### Consolidação do inventário e atalhos de protótipo (03/11/2026)

- IDs de recursos integrados: `ferro` coletado já serve como minério comum para presentear ferreiros, vender e usar em fabricação/obras; `ervas` também consta no catálogo de Comestíveis. Não são criados itens incompatíveis com o inventário antigo.
- Troncos de `madeira` adicionados ao cenário das duas cidades; coleta pela tecla `G`. Madeira é **material de obra**, não categoria de presente.
- `P`: presentear NPC próximo ou, dentro da taverna, o último visitante selecionado com as teclas 1–5. Presentes errados são recusados sem custo, independentemente de raridade.
- `O`: abrir mercado de taverna/ferraria; também abre comércio com a caravana quando estiver disponível no calendário. `Z` alterna compra/venda, `L` pagina o catálogo, `1–5` selecionam os itens apresentados.
- `F`: consumir comida do inventário e aplicar bônus temporários ao protagonista. `H`: abrir receitas iniciais dentro da ferraria. `Y`: aprimorar a ferraria com materiais e moedas.
- Esses são controles provisórios e menus simples, ainda não a interface gráfica final. Outros estabelecimentos e buffs para companheiros aguardam integração nas próximas etapas.
- **Teste novo `test_item_economy.gd` escrito, mas não executado nesta rodada no Godot:** cobre recusa para todas as categorias incompatíveis de todos os NPCs, presentes aceitos por raridade, compra/venda, consumo, receita, aprimoramento e save/load. Não declarar testes ou desempenho aprovados antes da validação de execução.


## Incremento: E contextual, menu clicável de NPC e pedir passagem (03/11/2026)

- Novo `scripts/npc_interaction_menu.gd`: janela de NPC em tema próprio, com nome, profissão, raridade, amizade, categoria favorita e botões clicáveis.
- `E` próximo de NPC: **Conversar**, **Abrir loja** somente quando mercador/vendedor/ferreiro, **Presentear**, **Recrutar** somente com requisitos satisfeitos, **Pedir passagem** sem penalidade e **Fechar**.
- Presentes: clicar **Presentear** abre itens do inventário com raridade, quantidade e indicação de aceitação; categorias incompatíveis são desabilitadas. Selecionar um item aceito tenta entregá-lo uma vez, respeitando limite diário e estado do NPC.
- Taverna: `E` abre lista clicável dos visitantes presentes por quatro dias; selecionar visitante abre perfil. Mansão: `E` abre perfil do Duque ou herdeira, mantendo exigências excepcionais. Botão **Sair do prédio** disponível nos menus de interiores.
- **Pedir passagem:** deslocamento lateral de sprite quando existe posição livre, sem tocar na economia, reputação ou amizade. É um primeiro comportamento visual; ainda não há `NavigationAgent3D` para navegação de NPCs.
- Menu impede mover o personagem enquanto estiver aberto. O mapeamento antigo de teclas segue temporariamente no código para debug; o fluxo de jogador prioriza `E` + clique.
- Criado `tests/test_npc_interaction.gd` para regras de visibilidade de botões, presentes aceitos/recusados e sinais de clique. **Teste ainda precisa ser executado no Godot da revisão publicada**; a inspeção estática confirmou conexões e funções sem duplicidade, mas não prova execução ou desempenho.


## Incremento NPCs — seis topicos e subtopicos de classificacao (03/11/2026)

- `scripts/npc_registry.gd`: cadastro central de **Comerciantes, Soldados, Ferreiros, Cidadaos comuns, Fazendeiros, Nobres**, com dois eixos independentes: **Recrutavel/Nao recrutavel** e **Importante para a historia/Personagem comum**.
- A ficha de NPC em `scripts/npc_interaction_menu.gd` agora exibe ocupacao e situacao no cadastro. Inclui acesso clicavel a um diretorio com filtros por categoria e subtopico.
- `scripts/world.gd`: o diretorio tambem aparece como opcao no mapa de viagem; o botao Loja e definido pela classificacao real de vendedor, sem depender apenas do texto da profissao; Recrutar consulta elegibilidade-base mais restricoes atuais.
- `scripts/game_state.gd`: impede recrutamento de NPCs marcados como nao recrutaveis, mantendo os requisitos especificos do Duque e da filha.
- Entradas de contexto para NPCs novos (comerciante, fazendeiro e cidada comum) ja podem ser consultadas no cadastro, mas **nao significam personagens totalmente implementados no cenario**; vida, dialogos, imagens e atividades aguardam integracao gradual.
- `tests/test_npc_registry.gd` criado para categorias, filtros, restricoes e janela. **Ainda nao rodado com o Godot nesta atualizacao**; nao reivindicar resultado de execucao sem validar a copia sincronizada.
- A etapa permanece incompleta; otimizar e polir a interface, o grafico e o desempenho antes de gerar qualquer ZIP.


## Incremento: habitantes com trabalho e descanso, e correção de duplicações (03/11/2026)

- `scripts/region_system.gd`: três personagens já previstos no cadastro foram **incluídos no mundo**: Íris (feirante) e Bento (agricultor) na Fortaleza; Lia (moradora) em Porto Cinzento. Mantêm seus perfis **não recrutáveis** conforme `npc_registry.gd`.
- `scripts/npc_daily_routines.gd`: postos de trabalho e repouso por personagem. Os moradores alternam posição/atividade de modo determinístico com o calendário, **sem atualizar IA ou instanciar assets a cada frame**. A janela de interação mostra a atividade atual.
- `scripts/world.gd`: pequenas bancas de mercado e canteiros agrícolas ilustram o trabalho dos habitantes; a lista única `_active_city_residents()` impede que um NPC esteja visível simultaneamente na rua, taverna ou como membro recrutado. A cena de NPCs é reconstruída na mudança de dia/região.
- `scripts/item_catalog.gd`: Íris aceita **Arte**, Bento aceita **Comestíveis**, Lia aceita **Estudos**. Mantida a regra de apenas uma categoria de presente por NPC.
- `tests/test_npc_daily_routines.gd`: teste de profissões/locais, rotina/atividade, mapa e preferências. `test_regions.gd` e `test_optimization.gd` ajustados aos novos elementos/estados.
- **Validação disponível nesta sessão:** o módulo `npc_daily_routines.gd` passou no Godot 4.7.2 headless em um teste de fumaça local; nove conjuntos de regressão da cópia local anterior também produziram PASS, mas **essa cópia ainda não corresponde ao HEAD completo publicado no GitHub**. Portanto, os testes da integração nova **não podem ser declarados aprovados até executar a versão sincronizada integral**. O teste antigo de UI também emite avisos de recursos ao sair.
- **Pendente:** patrulha/rotinas animadas com navegação física, horários intradiários, estações de trabalho mais detalhadas e revisão de FPS real. Cenários ainda usam geometria provisória; a Etapa 1 continua incompleta. **Sem ZIP antes de otimização, polimento e validação.**


## Incremento: referencia visual enviada pelo usuario — criacao, ficha, presentes e escolhas (03/11/2026)

Analise das 5 imagens e do video de ~48m54s documentada em [REFERENCIAS_VISUAIS.md](../REFERENCIAS_VISUAIS.md); pagina Nexus Mods analisada corresponde a **Achievement Save Files**, nao a um pacote de UI ou texturas. Nenhuma arte proprietaria do jogo de referencia foi copiada ou incluida.

- `character_profile.gd`: atributos Forca, Constituicao, Destreza, Inteligencia e Sorte; distribuicao de **10 pontos iniciais**, limites e quatro origens com bonus proprios.
- `start.gd`: escolha de nome, origem, aparencia inicial (quatro variantes), pontos +/− e dificuldade, antes da audiencia com Rei Aldric. Dificuldades e rotas existentes preservadas.
- `game_state.gd`: salva/carrega `character_origin`, `character_stats` e `character_appearance`, com valores-padrao para saves anteriores.
- `attribute_radar.gd`: radar vetorial de cinco eixos, gerado em Godot sem textura de terceiros, redesenhado somente quando os atributos mudam. Usado na criacao e na ficha.
- `character_sheet.gd`: abas **Personagem, Inventario, Relacoes, Diario e Habilidades**. Os dados mostrados sao os que a campanha realmente possui; artes marciais e equipamentos completos permanecem na Etapa 2.
- `world.gd`: botao de ficha no HUD e tecla `I` abre Inventario, com movimento bloqueado enquanto o painel estiver aberto. Visual inicial altera a paleta de cores procedural do sprite do heroi, sem deixar de compartilhar as texturas existentes entre NPCs.
- `npc_interaction_menu.gd`: presentes em painel de duas colunas, ficha social e grade de itens por clique; categorias rejeitadas ficam desabilitadas. Retrato temporario por inicial, arte definitiva pendente.
- `dialogue_panel.gd`: painel 9-slice existente preservado, agora com moldura de retrato original para o falante.
- `story_content.gd`, `game_state.gd`, `world.gd`: dilemas iniciais originais de Doran e Elira com escolhas irreversiveis; alteram reputacao regional, amizade e cronicas, sem copiar os textos do jogo de referencia.
- `tests/test_character_profile.gd` novo e `tests/test_story.gd`/`tests/test_npc_interaction.gd` atualizados. **A integracao publicada ainda nao passou por uma bateria completa de testes no Godot/Windows**. Modelos locais separados de atributos e radar foram executados no Godot 4.7.2 headless com PASS; isso nao deve ser apresentado como validacao do projeto completo.

**Pendente:** retratos e animacoes originais definitivos, telas de atributos responsivas, equipamentos/slots, artes marciais completas, ficha de NPC mais ilustrada, controles de interface e otimizacao de desempenho. **Sem ZIP** ate cumprir o criterio de polimento/otimizacao e testes da Etapa 1.


## Incremento: classes e subclasses, com magos por elementos (03/11/2026)

- `scripts/hero_classes.gd`: seis classes (Guerreiro, Arqueiro, Assassino, Defensor, Curandeiro, Mago), com subclasses Raro/Epico e superiores Lendario/Mitico; progressao estrutural e parametros iniciais de potencial.
- Magia: **Terra, Agua, Fogo e Vento** como elementos basicos. Uma afinidade = Raro, duas = Epico, tres = Lendario, quatro = Elementalista Lendario com potencial de ascensao Mitico. **Trovao** e **Mago Verde** (plantas) sao escolas Epicas independentes, mesmo com uma afinidade.
- `scripts/start.gd`: classe inicial selecionavel e campo de afinidade elemental exibido apenas para magos. Subclasses superiores nao sao escolhidas na criacao.
- `scripts/game_state.gd`: save/load de `hero_build` e `npc_hero_builds`, incluindo valores de compatibilidade para saves antigos; ranks A/S/SS permanecem independentes.
- `scripts/character_sheet.gd` e `scripts/npc_interaction_menu.gd`: exibem classe, subclasse e raridade de combate; a ficha do mago inclui afinidades.
- `tests/test_hero_classes.gd` executado localmente no Godot 4.7.2 headless: **PASS** para tabela, elementos exclusivos, progressao e subclasses superiores. Ainda nao e validacao integrada do HEAD remoto.
- Balanceamento, efeitos reais, missões de promoção, materiais e combate completo pertencem a Etapa 2. **Sem ZIP antes de concluir a Etapa 1, polir, otimizar e validar.**


## Correção de balanceamento: protagonista separado das raridades dos NPCs (03/11/2026)

- A tabela `hero_classes.gd` com raridades de subclasses **é exclusiva de NPCs**, inclusive Duque, herdeira e Vaelor; os ranks especiais A/S/SS não se misturam com ela.
- Novo `scripts/protagonist_progression.gd`: **Guerreiro, Cavaleiro, Mago e Sacerdote** são as quatro classes básicas do jogador. Não existe raridade de classe do protagonista.
- `scripts/start.gd` permite selecionar somente essas quatro classes. Especializações superiores, incluindo magias e técnicas, são aprendidas durante a campanha.
- `GameState.protagonist_track` salva classe, especializações, habilidades e fonte de aprendizado. Um mestre presente com amizade **Confidente (60+)** pode ensinar uma especialização compatível; `GameState.learn_from_boss_book` consome um livro de chefe compatível, se houver no inventário.
- No menu contextual `E` de um mestre cadastrado aparece **Treinar com mestre**; a seleção mostra as técnicas e bloqueia requisitos não atendidos. A ficha do protagonista mostra especializações aprendidas, sem raridade de NPC.
- `tests/test_protagonist_progression.gd` acrescentado, mas a versão remota atual ainda requer testes de integração com o Godot. Livros de boss ainda não possuem drops automáticos e habilidades aprendidas ainda não executam golpes reais, que pertencem à etapa de combate.


## Versão para aceite do usuário — polimento e testes (03/11/2026)

**Código-fonte revisado para Windows / Godot 4.7.2. A decisão de liberar a Etapa 2 depende do teste do usuário.**

- Correção da inferência de tipo no cálculo da chance da herdeira do Duque (`game_state.gd`).
- Correção da tipagem de seleção e hover no mapa de viagem.
- Normalização dos campos numéricos de itinerários dos NPCs depois de carregar JSON para evitar inconsistências de save e regressões da taverna.
- Correção do teste de treinamento com Doran: a rota Guardião precisa estar ativa e o mestre na região.
- Novo teste de colisão real com raycast: divisórias da ferraria sólidas no interior, desativadas ao voltar para a rua.
- Retratos pixel-art originais e cacheados (`portrait_factory.gd`), ícones de itens por categoria (`item_icon_factory.gd`), usados nas telas de NPC, presentes e diálogos.
- Casas com telhados inclinados, portas, janelas, faixas de identificação e acabamento cromático mais discreto no solo; sprites mais legíveis.
- **Validação local completa da revisão:** 25/25 testes automatizados aprovados em Godot 4.7.2 headless. Jogo aberto em renderização gráfica Linux/Xvfb OpenGL Compatibility, incluindo capturas reais de menu e mundo.
- Medição gráfica de 120 quadros: cerca de **57,8 FPS sob Mesa llvmpipe** e **42,6 MiB no monitor MEMORY_STATIC**; estes valores não representam FPS nem consumo total do processo no Windows.
- ZIP de código-fonte com `LEIA-ME_TESTE_WINDOWS.md` e `RELATORIO_QA_ETAPA1.md` preparado para avaliação direta do usuário. Este pacote **não inclui executável**, exigindo Godot 4.7.2. Nunca interpretar como aceite automático da Etapa 2.

**Pendente do aceite:** verificação de FPS real no Windows, animações/câmera em diferentes máquinas e opinião visual final do usuário.


## Etapa 2 iniciada com aceite condicional da Etapa 1 (03/11/2026)

O usuário conferiu a Etapa 1 no Windows, relatou jogo fluido sem lag e **autorizou iniciar a Etapa 2**, mantendo pendentes ajustes de arte e usabilidade.

Primeira entrega de implementação:
- Fluxo inicial separado em `Menu principal → escolha de dificuldade → criação do protagonista → audiência de Aldric`.
- `Esc` fecha a janela superior e os diálogos/abas. Entrada de casas por aproximação de porta, sem apertar E, com fade curto e cooldown de saída.
- `equipment_catalog.gd`: 24 peças entre armas/armaduras de quatro classes e categorias Comum/Raro/Épico; slots `weapon/head/chest/feet`. Apenas 16 itens Comuns entram em receitas da ferraria. Itens Raros/Épicos são restritos a comerciantes de arquetipo.
- `forge_panel.gd` e `equipment_market_panel.gd`: menus próprios de fabricação e mercado, com classes, ícones, botões clicáveis, materiais necessários e preços, em vez de lista de texto no diálogo.
- NPCs vendedores adicionados: mercador marcial na Fortaleza; arcanista e devoto em Porto Cinzento; Doran especializa-se em equipamentos de Guerreiro.
- `GameState.equipped`: quatro slots persistidos em save e inventário, checagem de classe, bônus de Ataque/Defesa. Vender a última unidade equipada é proibido. O mercado comum não pode contornar as restrições de equipamento.
- Texturas leves originais geradas e reutilizadas via `world_texture_factory.gd`: pedra, madeira, grama e estrada. Objetos usam cache de materiais e UVs repetidos.
- Itens de enredo Espada do Herói e Armadura do Duque continuam **exclusivos**.
- Testes `test_phase2_equipment.gd` e `test_phase2_ui_flow.gd` cobrem novas regras, telas e entrada automática.
- Validação local Godot 4.7.2: **26 testes anteriores PASS** com teste de moradores atualizado, e **teste adicional de fluxo de UI PASS** (27 suites). Revisão CI GitHub em curso; FPS real da nova versão no Windows não foi medido.
- **Ainda não é combate completo**: técnicas, inimigos, atributos vivos, danos, IA e batalhas serão implementados em continuidade da Etapa 2; a arte definitiva também segue em revisão.


### Fechamento de regressão do primeiro incremento da Etapa 2 (03/11/2026)

- `menu_backdrop.gd`: cenário ilustrado original de castelo/montanhas para menu principal, dificuldade e criação.
- `actor_animation.gd`: silhueta do herói com novos detalhes em tecido, cinto, ombreiras e botas, ainda em pixel art procedural (24 quadros pré-gerados, oito direções).
- `world_texture_factory.gd`: padrões cacheados de pedra, madeira, grama e estradas; aplicar a paredes, telhados e terreno com materiais compartilhados.
- `equipment_market_panel.gd` e `forge_panel.gd`: mercado e forja clicáveis com abas de classe, slots, materiais, moedas e paginação.
- **Validação remota:** workflow <https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/actions/runs/41743624248> concluído com sucesso: importação/compilação, regressões automatizadas e smoke test das cenas no Godot 4.7.2. **27 testes locais** também aprovados, incluindo `test_phase2_ui_flow.gd`.
- Arte final, teste de FPS dessa versão no Windows e combate ativo continuam pendentes. Nenhuma alegação de Fase 2 finalizada; o usuário já autorizou o seu início.
