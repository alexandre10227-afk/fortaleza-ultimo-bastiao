# Classes, subclasses e afinidades — Fortaleza: Último Bastião

**Escopo:** regras de progressão e catálogo para combate (Etapa 2). Estrutura inicial já cadastrada na Etapa 1, incluindo criação de personagem e salvamento. Habilidades, dano real, equipamentos e materiais definitivos de evolução ainda não estão completos.

## Três sistemas distintos

1. **Classe/subclasse e sua raridade:** Raro, Épico, Lendário, Mítico. Determina o potencial de combate e as técnicas que serão desbloqueadas.
2. **Rank narrativo de um herói/NPC:** A, S ou SS (ex.: Duque A; filha S com possibilidade de SS). Nunca é sobrescrito pela raridade da subclasse.
3. **Raridade dos itens:** Comum, Raro, Épico, Lendário e itens especiais exclusivos em catálogo próprio. Não altera automaticamente a subclasse.

## Classes físicas

| Classe principal | Subclasses (Raro → Épico) | Subclasse superior (Lendário → Mítico) | Função |
|---|---|---|---|
| Guerreiro | Espada e Escudo; Samurai | Mestre Espadachim | Dano físico, postura, contra-ataque |
| Arqueiro | Atirador; Caçador | Arqueiro Celestial | Dano à distância, armadilhas e precisão |
| Assassino | Batedor; Lâmina Sombria | Mestre das Sombras | Agilidade, furtividade e críticos |
| Defensor | Escudeiro; Guardião | Bastião Vivo | Resistência, controle e proteção coletiva |
| Curandeiro | Herbalista; Sacerdote | Sábio da Vida | Cura, antídotos e suporte |

Os especialistas começam em Raro e podem chegar a Épico. A promoção para a subclasse superior exige uma futura missão/prova da classe; o protótipo já possui validação das transições, mas ainda não consome materiais nem aplica técnicas de combate.

## Magos — sistema próprio por afinidades

Os quatro **elementos básicos** são **Terra, Água, Fogo e Vento**.

| Forma | Afinidades dominadas | Raridade |
|---|---|---|
| Mago Elemental | 1 elemento básico | Raro |
| Mago Elemental | 2 elementos básicos diferentes | Épico |
| Mago Elemental | 3 elementos básicos diferentes | Lendário |
| Elementalista | Terra + Água + Fogo + Vento | Lendário |
| Elementalista evoluído | Os 4 básicos + prova de ascensão | Mítico |
| Mago do Trovão | Trovão como escola exclusiva | **Sempre Épico** |
| Mago Verde | Plantas, raízes e cipós, escola exclusiva | **Sempre Épico** |

**Importante:** Trovão e Verde NÃO contam como um dos quatro básicos, não dão acesso automático ao Elementalista e não passam de Épico nessa especialização. A exclusividade é parte da identidade dessas subclasses, não um impedimento de continuar ganhando nível/atributos por experiência.

**Evolução do mago:** escolher um elemento básico ao criar personagem; adquirir um segundo eleva a subclasse de Raro a Épico; um terceiro eleva de Épico a Lendário. Uma prova de domínio do quarto elemento desbloqueia a subclasse Elementalista (Lendário), que poderá evoluir para Mítico mediante missão, materiais e treinamento da Etapa 2. Nenhuma afinidade pode ser duplicada.

**Força relativa provisória:** multiplicadores de referência Raro 1,0×; Épico 1,25×; Lendário 1,6×; Mítico 2,0×. Esses números são hipóteses para balanceamento; ainda **não** representam dano ou bônus reais do combate. Um mago com mais elementos terá acesso a estratégias e técnicas adicionais, não apenas dano bruto.

## Integração atual

- `novo_projeto/scripts/hero_classes.gd`: tabela de classes, variações, validação e regras de progressão.
- `novo_projeto/scripts/start.gd`: escolha da classe inicial e, para magos, afinidade básica.
- `novo_projeto/scripts/game_state.gd`: campo `hero_build` e perfis `npc_hero_builds`, persistidos no save; registro de transições e classes separadas dos ranks.
- `novo_projeto/scripts/character_sheet.gd`: classe/subclasse/raridade/elementos aparecem na ficha.
- `novo_projeto/scripts/npc_interaction_menu.gd`: ficha de NPC mostra classe de combate quando conhecida.
- Perfis iniciais propostos: Doran Guerreiro Espada e Escudo Raro; Elira Samurai Raro; Kael Caçador Raro; Mira Herbalista Raro; Duque Espada e Escudo Épico; Herdeira Mestre Espadachim Lendário; Vaelor Bastião Vivo Lendário. Esses valores não mudam os ranks narrativos já definidos.

## Testes e restrições

O novo `tests/test_hero_classes.gd` foi executado localmente no Godot 4.7.2 headless e passou, incluindo testes de escola exclusiva, afinidades únicas, quatro elementos, evolução e subclasse superior. A execução verificou o módulo e regras puras; **não equivale a validar o projeto inteiro publicado**.

Próximos passos: requisitos de XP/material, árvore de habilidades, efeitos elementais no combate, resistências, interface de evolução e integração às profissões de NPC. Antes do ZIP: todos os testes do projeto, desempenho, otimização e polimento gráfico.


## Correção de escopo aprovada — protagonista versus NPCs (03/11/2026)

**Esta seção SUBSTITUI qualquer indicação anterior de que o protagonista use raridade de subclasse.**
As seis classes e tabelas de Raro, Épico, Lendário e Mítico **aplicam-se apenas aos NPCs e heróis recrutáveis**. A força dos NPCs é condicionada à raridade da subclasse; seus ranks A, S e SS continuam distintos. Os magos NPCs continuam separados por Terra, Água, Fogo, Vento, Trovão e Verde, com a progressão já definida.

O **protagonista escolhe somente uma das quatro classes básicas** — Guerreiro, Cavaleiro, Mago ou Sacerdote — inspiradas nas profissões iniciais mencionadas na obra de referência, porém com regras originais. Seu progresso é determinado por **especializações e habilidades aprendidas durante a campanha**, não por raridade.

- **Mestre NPC:** interação contextual `E → Treinar com mestre`, mínimo de **60 pontos de amizade (Confidente)**, mestre presente e compatibilidade com classe; ensinamento é permanente.
- **Livro de chefe:** obtido como recompensa de chefe (integração de drops na Etapa 2/3); consumido ao aprender uma habilidade/especialização compatível. O mesmo livro não pode conceder a mesma especialização duas vezes.
- **Magia do protagonista:** escolas/elementos disponíveis por especialização, mas NÃO aplicam a fórmula automática de raridade de mago NPC.
- **Criador:** apenas quatro opções iniciais, sem seleção direta de subclasse lendária nem afinidade extra por raridade.
- **Separação de dados:** `scripts/protagonist_progression.gd` e `GameState.protagonist_track` para o jogador; `hero_classes.gd` e `npc_hero_builds` para NPCs. Campo `hero_build` permanece temporariamente no save como legado para compatibilidade, sem determinar a progressão do protagonista.

Limites atuais: o consumo e desbloqueio lógico de livros já existem, mas as tabelas reais de drop, animações de treinamento, condições completas de missões e efeitos ativos das técnicas ainda dependem do sistema de combate. Teste `test_protagonist_progression.gd` criado; falta rodar o teste de integração com o código remoto sincronizado.
