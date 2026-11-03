# Referencias de interface — Fortaleza: Ultimo Bastiao

Data de analise: 03/11/2026. Estas sao **referencias de composicao, organizacao e experiencia**, nao autorizacao para copiar ou distribuir imagens do jogo de origem.

## Materiais fornecidos

1. **Ficha com radar e atributos (imagem 1):** painel escuro com bordas metalicas, retrato/sprite grande a esquerda, slots de equipamentos, radar pentagonal de atributos, valores de combate e icones de habilidades. Adaptacao autoral: radar Godot e abas de Personagem/Inventario/Relacoes/Diario/Habilidades.
2. **Janela de presente e afinidade (imagem 2):** retrato e identidade do NPC a esquerda, estado de amizade, habilidades sociais/ajudas e inventario selecionavel em grade a direita. Adaptacao autoral: janela de presente em duas colunas, avatar por inicial temporario, itens clicaveis com raridade, quantidade, aceita/recusada e categoria favorita exclusiva.
3. **Interacao em leque (imagem 3):** pequeno menu contextual ao redor do NPC com informacoes, conversa, presente e comercio. Adaptacao autoral: interacao pelo E e acoes clicaveis; dispersao em leque real e sua posicao na tela ainda aguardam refinamento.
4. **Ficha completa com abas (imagem 4):** personagem, itens, artes marciais, passivas, habilidades, relacoes e diario. Adaptacao autoral: cinco abas que ja apresentam dados reais disponiveis de personagem, inventario, relacoes, eventos e habilidades provisórias. Sistemas de combate/tecnicas/equipamentos completos pertencem a Etapa 2.
5. **Escolhas de dialogo e retratos (imagem 5):** retrato narrativo, texto de fala em faixa inferior e opcoes centralizadas e destacadas. Adaptacao autoral: painel 9-slice madeira/pergaminho, name box, efeito typewriter, moldura de retrato por inicial temporario e escolhas com efeitos persistentes no enredo.

## Video enviado (videoplayback (1).mp4; ~48m54s, 640x360)

Capturas examinadas em marcos de 0:15, 1:00, 2:00, 4:00, 7:00, 12:00, 20:00, 30:00, 40:00 e 47:30:
- Abertura de jogo com arte de fundo, selecao de campanha e continuidade.
- Aproximadamente 2:00: selecao de modos/caminhos da nova campanha.
- Aproximadamente 4:00 a 12:00: tela de criacao com arte de protagonista, escolhas de caracteristicas, atributos distribuidos com + e -, itens iniciais e confirmacao.
- Aproximadamente 20:00: conversa narrativa com retrato lateral e painel inferior.
- Aproximadamente 30:00: ficha com abas e atributos/relacoes.
- Aproximadamente 40:00: tela de artes marciais/arvore de passivas.
- Aproximadamente 47:30: exploracao isometrica de interior, com interface compacta.

Esses sao **marcos visuais amostrados**, nao transcricao nem revisao quadro a quadro do video inteiro.

## Fonte externa Nexus Mods

Pagina fornecida: https://www.nexusmods.com/herosadventure/mods/3?tab=posts
O recurso se chama **Achievement Save Files**, um mod de arquivos de save/presets; **nao** e um pacote de interface, sprites ou texturas autorizado para importacao. Nenhum arquivo desse mod foi usado como arte.

## Implementacao dessa revisao

- `scripts/character_profile.gd`: 5 atributos, dez pontos para distribuir, quatro origens, validacao e bonus originais.
- `scripts/start.gd`: criacao com nome, origem, aparencia inicial, atributos com +/- e dificuldade. Prologo de Aldric foi preservado.
- `scripts/game_state.gd`: persistencia da origem, visual e atributos em saves antigos/novos.
- `scripts/attribute_radar.gd`: grafico radar de cinco eixos desenhado pelo Godot sem texturas importadas; atualiza somente quando necessario.
- `scripts/character_sheet.gd`: abas Personagem/Inventario/Relacoes/Diario/Habilidades, com os dados realmente disponiveis. Equipamentos e artes marciais completos nao estao implementados.
- `scripts/world.gd`: acesso a ficha pelo HUD e `I`; visual inicial do protagonista afeta a paleta procedural do sprite; preserva cache de sprite compartilhado dos NPCs.
- `scripts/npc_interaction_menu.gd`: presentes exibidos em duas colunas com retrato-temporario, ficha do NPC e grade de itens clicaveis. Itens de categorias incorretas ficam desabilitados.
- `scripts/dialogue_panel.gd`: moldura de retrato original com inicial do personagem, sem copiar retratos alheios.
- `scripts/story_content.gd`, `scripts/game_state.gd`, `scripts/world.gd`: dois dilemas originais (forja e refugiados) que alteram reputacao, amizade, memoria e cronicas. Uma mesma escolha nao pode ser repetida.
- `tests/test_character_profile.gd`, `tests/test_story.gd`, `tests/test_npc_interaction.gd` atualizados.

## Limites e proximos testes

**Nao afirmar equivalencia grafica com a fonte:** retratos originais definitivos, inventario equipado, icons de itens, animations, organograma de habilidades, dialogos complexos, interacao radial e responsividade ainda precisam de trabalho. Os scripts novos possuem testes escritos; **nao houve execucao integrada da copia atual do GitHub no Windows**. Os modelos de atributo e radar foram exercitados em copia local com Godot 4.7.2 headless, mas a validacao integrada ainda permanece pendente.

Permanece vigente o bloqueio do ZIP ate conclusao da Etapa 1, otimizacao, polimento e testes.
