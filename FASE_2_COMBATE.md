# Fase 2 — núcleo inicial de combate (03/11/2026)

Estado: **primeiro módulo jogável implementado, ainda não representa a conclusão da Fase 2**.

## Sistemas implementados
- Encontros manuais por proximidade nas estradas da Fortaleza e Porto Cinzento. O personagem pode apertar **E** próximo a um inimigo para iniciar a batalha.
- `combat_core.gd`: regras testáveis de combate em turnos, dano versus defesa, quatro habilidades básicas, custo de PM, defesa temporária e resolução de vitória/derrota.
- Classes iniciais do protagonista: **Guerreiro** (Golpe Poderoso), **Cavaleiro** (Postura de Guarda), **Mago** (Centelha Arcana), **Sacerdote** (Prece de Amparo). A identidade própria de classe é preservada.
- Encontros iniciais: Lobo Cinzento e Saqueador; Guardião de Pedra reservado para desafios posteriores. Criaturas reaparecem somente em novo dia, por região; derrotas são registradas.
- `battle_panel.gd`: painel original de combate com PV/PM, ações clicáveis, habilidade específica da classe e histórico da luta. Não permite deslocamento enquanto a batalha está ativa; Esc não cancela um combate em andamento.
- Progressão: experiência dependente da dificuldade (inclusive 3× no Impossível), nível, moedas, melhoria automática de PV e PM ao subir de nível.
- `GameState`: `hero_level`, `hero_xp`, `hero_hp`, `hero_mp`, `active_battle` e `defeated_field_enemies` persistidos no formato de save anterior com valores padrão para campanhas antigas.
- Atributos de classe e equipamentos de cabeça, peito, botas e arma influenciam a fórmula inicial de combate.
- Poções básicas para recuperação de PV em batalha, vendidas no comércio regular, consumidas apenas quando o turno é válido.
- `character_sheet.gd` exibe informações reais de combate, PV/PM, XP e técnica inicial.

## Integração e limites importantes
- Nenhuma morte permanente ou penalidade irreversível introduzida antes da definição do sistema de legado/sucessão; na derrota inicial o personagem retorna ferido e perde algumas moedas.
- Não modificar o destino do Duque nem disponibilizar sua armadura exclusiva.
- Técnicas ensinadas por mestres e livros de chefes ainda são registradas, **mas seus efeitos ativos adicionais precisam ser implementados e balanceados**. Não afirmar que a árvore de habilidades está completa.
- Ainda pendentes: animações de ataque originais, IA de batalha com movimentação, variedade de efeitos, companheiros na luta, equipamentos inimigos, combate dos chefes, arenas próprias, habilidades passivas, ferimentos e morte permanente.
- `tests/test_phase2_combat.gd`: verifica regras, cálculo de recompensas, persistência, revives e interface de batalha.
- Validação técnica GitHub Actions: execução <https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/actions/runs/41746044679> **aprovada**, com importação, suite completa e smoke test no Godot 4.7.2. Tela de atributos atualizada depois dessa execução; deve ser incluída na próxima revisão.
- Desempenho e aparência gráfica no Windows ainda dependem de teste de campo do usuário.

## Próxima fase dentro da Etapa 2
1. Animar ataque, reação, magia e defesa no estilo original pixel art 2,5D.
2. Fazer habilidades aprendidas com NPCs/livros funcionarem nas batalhas, com progressão, custo e requisitos.
3. Introduzir IA tática, estado dos companheiros, alianças e morte/perda conforme a dificuldade.
4. Integrar combate em mundo/arenas, minichefes, missões e recursos, preservando o desempenho.
