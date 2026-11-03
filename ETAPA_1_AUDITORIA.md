# Auditoria da Etapa 1 — Fortaleza: Último Bastião

**Data:** 03/11/2026  
**Referência:** PLANEJAMENTO_NOVO_PROJETO.md  
**Estado:** grande parte da fundação implementada no repositório; **não declarar Etapa 1 concluída sem regressão integrada e inspeção gráfica no Windows**.

## Entregas já codificadas

| Requisito | Estado verificado no código | Observação |
|---|---|---|
| Novo projeto Godot, menu inicial, quatro dificuldades, opções de áudio/tela | Implementado | Configurações salvas separadamente |
| Criação: nome, quatro classes do protagonista, origem, visual, atributos | Implementado | Subclasses raras são exclusivas dos NPCs |
| Prólogo do rei, Guardião/Exilado, escolhas irreversíveis | Implementado | Reputação -100 e preços 3x para Exilado |
| Mundo 2,5D com duas cidades e terreno contínuo | Protótipo funcional | Geometria autoral simples, arte final pendente |
| Movimento e animação em oito direções | Implementado como base | Quadros originais pré-gerados, sem animação de ataque |
| Casas e interiores com cômodos separados, ferraria/salão/quarto/mansão | Implementado como base | Paredes com colisão; arquitetura provisória |
| Colisão de casas e NPCs, pedido de passagem sem punição | Implementado como base | Ainda requer teste gráfico/físico em jogo |
| Mapa mundial clicável e saída de região; custo 5 energia e XP de Agilidade | Implementado | Apenas Fortaleza e Porto Cinzento nesta etapa |
| HUD, diálogo 9-slice, ficha, inventário, relações, habilidades e diário | Implementado como base | Falta polimento de ícones, retratos e layouts |
| Interação contextual E e ações clicáveis de NPC | Implementado | Conversa, loja, presente, mestre, recrutamento, passagem |
| Taverna: quatro dias, itinerários e persistência | Implementado como regras | Deslocamento diário interpolado em cena |
| Amizade e presentes por categoria exclusiva | Implementado | Cinco níveis, 80+ para recrutamento comum |
| Compra/venda, coleta, comida, receitas, moedas e melhoria da ferraria | Implementado como base | Estoques, mercado completo e obras visuais pendentes |
| Duas missões iniciais e dilemas com consequências | Implementado | História aprofundada nas etapas seguintes |
| Evento especial do Duque | Regras/estados implementados | Boss e cutscene reais dependem do combate (Etapas 3–4) |
| Save/load de personagem, posição, NPCs, recursos, evento e mundo | Implementado | Requer testes de cenários completos e versões antigas |
| Crônicas, memória, política/moral e migração | Estruturas e regras iniciais | Simulação social completa pertence à Etapa 2 |
| Inteligência militar, legado, nêmesis, sucessão | Estruturas persistentes iniciais | Sem IA de batalha, sucessão ou tropas reais ainda |
| Bestiário, expedições de reconhecimento e memorial | Estruturas persistentes iniciais | Sem combate/drops gerados artificialmente |

## Melhorias específicas desta revisão

- Correção da referência persistente `settlement`, que era sombreada por uma variável local.
- Movimento reposicionado para `_physics_process` e velocidade zerada quando o controle está bloqueado.
- Posição de exploração preservada por região entre saves e viagens.
- Colisões de paredes internas desabilitadas fora dos interiores, evitando paredes invisíveis na cidade.
- Mapa desenhado com terreno continental e localidades clicáveis, ativado também ao ultrapassar a borda.
- Quartos e áreas principais fisicamente separados, inclusive no espaço de forja e na mansão.
- Quadros de animação originais e reutilizados para oito direções, com 24 texturas pré-geradas por aparência.
- NPCs visíveis com colisão própria, transição suave de rotina e deslocamento lateral ao pedir passagem.
- HUD, notícias e tavernas unificados com o tema escuro de madeira e bronze.
- Menu principal com configurações de janela e áudio, além de continuar e iniciar campanha.
- Bases de inteligência, legado, migração, nêmesis, expedições, memorial e bestiário persistidas.

## Porta de qualidade antes do ZIP

Aprovação exige:
1. Importar o projeto e validar scripts e cenas no Godot da versão-alvo.
2. **Todos** os testes em `novo_projeto/tests/test_*.gd` aprovados na revisão integral do repositório, sem timeouts ou falhas.
3. Testes manuais de criação → prólogo → exploração → diálogo → loja → presente → taverna → interiores → viagem → save/load.
4. Testar no Windows (resoluções diferentes, fullscreen, input teclado/mouse, colisões e animação).
5. Medir FPS, travamentos e memória nas cidades e interiores; corrigir gargalos e regressões.
6. Polimento visual final com retratos e ícones autorais, layouts responsivos e revisão de legibilidade.
7. Gerar apenas então um ZIP final da Etapa 1 e aguardar o aceite do usuário para avançar.

**Validações já observadas:** testes locais anteriores no Godot 4.7.2 passaram para a base antiga; execução do Godot em CI importou o projeto e validou scripts/cenas numa revisão intermediária. A bateria completa da revisão atual ainda está em andamento; esses resultados parciais **não autorizam** declarar a etapa ou o ZIP final como concluídos.

Os sistemas reais de combate, ondas com batalha, boss do Duque, técnicas ativas, cinco finais e rank S→SS continuam intencionalmente nas Etapas 2–4, conforme o escopo aprovado.
