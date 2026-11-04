# Tesouro Nacional, producao e comercio — Fase 2

**Atualizacao:** 03/11/2026  
**Validacao:** Godot 4.7.2, 31 suites aprovadas no [GitHub Actions](https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/actions/runs/41752854984).

## Contabilidade e fontes de recursos

Os territorios **Fortaleza** e **Porto Cinzento** possuem tesouros publicos, liquidez de mercado, estoque publico, carteiras de trabalhadores e livros de transacoes separados. Nao confundir:
- **Ouro do jogador:** inventario e compras pessoais.
- **Tesouro Nacional:** tributos, despesas de construcao e negociacoes entre territorios.
- **Tesouro municipal da guarnicao:** equipamentos e reparos de soldados (sistema `city_armory_economy.gd` preservado).
- **Liquidez de compradores:** verba gasta nas vendas consignadas do jogador.

A cada dia os perfis economicos simulados de lenhador, mineiro, agricultor e mercador produzem rendimentos; parte vira tributo, e cada territorio compra madeira, pedra, ferro ou alimentos quando possui recursos. **Estes perfis sao a primeira simulacao economica, ainda nao uma carreira individual para todos os NPCs nomeados.** Trabalhadores tem carteiras e registro de impostos, evitando cobrar a mesma data duas vezes.

## Mercado de consignacao

O jogador abre **Ficha → Mundo**, ou usa **K**, para anunciar uma unidade de um item comercial do inventario. O anuncio remove o item do inventario, permitindo retirada enquanto nao vendido.

A partir do dia seguinte, o mercado pode comprar **uma unidade por anuncio/dia**, condicionado a liquidez disponivel. Da receita bruta, **88% vai para o jogador** e **12% para o tesouro** (valor inteiro com minimo de uma moeda em taxa). Itens exclusivos de boss/missao, ou a ultima unidade equipada, nao podem ser anunciados.

Venda comum direta de itens no mercado continua como sistema legado separado; o imposto aqui se aplica ao novo **servico de consignacao**.

## Obras publicas

Via Ficha → Mundo, na rota Guardiao da Fortaleza, o jogador autoriza melhorias das construcoes publicas. Cada obra usa:
- Ouro do Tesouro Nacional (progressao quadratica por nivel).
- Madeira, pedra e ferro (multiplicados pelo nivel corrente).
- Pedra incomum a partir de melhorias avancadas; cristal azul para ferraria/muralha superiores.
- Limite de cinco niveis por construcao; nunca ultrapassa recursos ou dinheiro disponiveis.

O novo estoque nao substitui os materiais pessoais do jogador: o projeto ja possuia melhorias pessoais, que continuam acessiveis pela jogabilidade legada. O uso do Tesouro Nacional e um segundo canal de financiamento.

## Diplomacia territorial

O Guardiao pode negociar lotes de tres unidades de madeira, pedra, ferro ou pedra incomum da Fortaleza com Porto Cinzento. Cada negociacao real:
- Remove estoque do territorio vendedor e adiciona ao territorio comprador.
- Transfere ouro **entre tesouros**, sem emitir receita gratuita.
- Aumenta confianca em cinco pontos por unidade comercializada.
- Quando a confianca atinge **60/100**, registra alianca bilateral entre as duas cidades.

**Limite atual:** tratados so representam a primeira rota comercial Fortaleza → Porto Cinzento na campanha Guardiao. A politica mais elaborada, rotas do Exilado e acordos entre mais cidades serao implementados nas proximas fases.

## Recursos no mapa

Pedra de pedreira agora pode ser encontrada/coletada pelo protagonista no mapa com a interacao de recursos; madeira e ferro ja possuíam coleta. Cada no coletavel repoe na virada do dia, de acordo com a regra de coleta existente.

## Companheiros e equipamentos — mesma atualizacao

A batalha de estrada agora recebe ate dois companheiros **previamente recrutados**, com funcoes distintas:
- Atacante: Elira e Kael.
- Guardiao: Doran.
- Curandeira: Mira.
- Suporte: Selene.

Eles atuam no turno e podem sofrer dano. Cair no combate **nao causa morte permanente nesta primeira integracao**. Seus dados de batalha entram no save. Equipamentos do protagonista fornecem PV, PM, cura, defesa e dano/critico conforme propriedades cadastradas.

## Verificacao

- `tests/test_national_treasury.gd`: tributos, remuneracao, estoque, custo crescente, consignacao, taxa, retirada de anuncio, diplomacia, alianca, save/load e cobrancas unicas.
- `tests/test_party_combat.gd`: companheiros, ataque, cura, dano, equipamentos e save/load.
- CI [41752854984](https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/actions/runs/41752854984): importacao, **31 suites de regressao** e smoke test da cena principal concluidos com sucesso.

**Nao e o fim da Fase 2.** Ainda faltam combates de grupo graficamente animados, profissões individuais, precificacao dinamica, caravanas visiveis e politica territorial mais aprofundada. Nenhum ZIP final foi gerado antes do polimento e do aceite da fase.
