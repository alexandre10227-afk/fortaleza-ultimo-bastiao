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
