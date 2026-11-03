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
