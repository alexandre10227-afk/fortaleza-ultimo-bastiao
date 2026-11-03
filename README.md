# Fortaleza: Último Bastião

## Teste de entrega via GitHub

Este repositório contém **um projeto Godot leve, executável e independente de recursos externos** para verificar se o download pelo GitHub funciona no Windows.

> **Importante:** esta é uma versão de diagnóstico reduzida, **não é o projeto completo da Beta 0.5.1**. O pacote completo, de aproximadamente 68 MB, permanece na Biblioteca do ChatGPT; não foi possível transferir seus arquivos binários pelo conector GitHub.

### Como testar
1. No GitHub, escolha **Code → Download ZIP**.
2. Extraia o ZIP.
3. Abra **Godot 4.x → Import** e selecione `project.godot`.
4. Pressione **F6** na cena ou **F5** para executar o projeto.

### Controles
- **WASD / setas:** mover o personagem
- **M:** abrir/fechar mapa mundial
- **E:** entrar em um cômodo / sair do cômodo
- **Clique:** selecionar região no mapa
- **R:** recuperar energia (somente teste)

### Mecânicas de diagnóstico
- Mundo desenhado diretamente no Godot (não é uma ilha flutuante)
- Salão principal, quarto e ferraria separados
- Mapa mundial com regiões selecionáveis
- Viagem custa 5 de energia e concede experiência de Agilidade proporcional à distância, limitada a 15
- Obstáculos com colisão simples
- Retorno a interiores pela tecla E

O propósito deste pacote é **desbloquear a distribuição e testar a abertura no Godot**. A migração da Beta 0.5.1 integral, com todos os sprites, mapas, cenas e sistemas, continua pendente.

### Estado do projeto
- **Teste de entrega via GitHub:** disponível
- **Beta 0.5.1 completa no GitHub:** pendente
- **Teste visual no Windows:** pendente
