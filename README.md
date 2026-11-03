# Fortaleza: Último Bastião

## Situação atual — a Beta integral ainda NÃO foi enviada
O repositório foi usado primeiro para um **protótipo de diagnóstico reduzido**. Os arquivos `main.gd`, `main.tscn` e `project.godot` atualmente na raiz **não representam o jogo completo**. Não utilize esse protótipo como base para continuar o desenvolvimento.

A **Beta 0.5.2 Restaurada** existe como pacote ZIP (~69 MB) na Biblioteca do ChatGPT, com 412 arquivos. O conector GitHub deste chat não permite transferir diretamente os binários do pacote, então o upload inicial do projeto completo **ainda está pendente**.

## Como será feita a entrega definitiva

Foi adicionada uma rotina de validação e empacotamento no **GitHub Actions**: [Ver pipeline](https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/actions/workflows/entrega.yml).

- Quando o projeto real for enviado, cada atualização de `main` será conferida (scripts, cenas, texturas) e gerará um ZIP com estrutura válida e SHA-256.
- O ZIP estará disponível como artefato na aba **Actions**, com retenção de 30 dias.
- Para manter uma versão sem prazo de expiração, abra **Actions → Validar e empacotar o jogo completo → Run workflow**, marque `publicar_release` e defina `versao`. Se a validação passar, a versão sairá em [Releases](https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/releases).
- **Enquanto os arquivos completos não estiverem no repositório, o workflow falhará intencionalmente**, impedindo publicar um protótipo como versão final.

## Como fazer a primeira sincronização (Windows)

**Somente se você já possui em seu computador o projeto Godot completo ou o ZIP completo:**

1. Instale [Git para Windows](https://git-scm.com/downloads/win) e autentique no GitHub (Git Credential Manager ou GitHub CLI).
2. Baixe o arquivo [PUBLICAR_PROJETO_WINDOWS.ps1](./PUBLICAR_PROJETO_WINDOWS.ps1) deste repositório.
3. Abra o PowerShell no diretório do script e execute:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\PUBLICAR_PROJETO_WINDOWS.ps1
   ```
4. Informe o caminho da **pasta Godot com `project.godot`** ou do **ZIP completo**.
5. O script confere a quantidade de cenas, scripts e imagens antes de enviar. Se houver menos de 30 scripts, 8 cenas ou 50 texturas, bloqueia a publicação.
6. Após o push, confira a aba **Actions**. A partir daí, releases futuras poderão ser baixadas do próprio GitHub.

Se você não tem o ZIP completo nem a pasta original no computador, **esse procedimento não resolve a transferência inicial**; será necessário outro canal para colocar os 69 MB de arquivos binários no repositório. O script não baixa o ZIP da Biblioteca por conta própria.

## Estado técnico
- Beta 0.5.2 completa no ambiente de desenvolvimento: **gerada**
- Testes headless em nove cenas do Godot 4.7.2: **passaram**
- Revisão visual e testes Windows: **pendentes**
- Upload integral ao GitHub: **pendente**
- Pipeline de validação, ZIP automático e releases: **configurado**

**Observação:** a campanha principal é isométrica 2D; a vila 3D continua experimental. Não foi realizada conversão integral para 3D.


## Novo recomeço — Etapa 1

O desenvolvimento da nova versão foi iniciado em **[novo_projeto/](./novo_projeto/)**, separado do protótipo de diagnóstico na raiz. A implementação inicial inclui criação de personagem, audiência do rei, escolha Guardião/Exilado, dados persistentes, cenário 3D experimental e teste de lógica. **Ainda não há versão final da Etapa 1.** Consulte [estado detalhado](./novo_projeto/README.md) e [planejamento atualizado](./PLANEJAMENTO_NOVO_PROJETO.md).
