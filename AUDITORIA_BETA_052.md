# Auditoria de integridade — Fortaleza Beta 0.5.2 Restaurada

Data da auditoria: 2026-11-03.

## Origem e verificação
O pacote `Fortaleza_Beta_0.5.2_RESTAURADA_Godot.zip` foi inspecionado no ambiente de desenvolvimento, **não neste repositório**.

- Tamanho ZIP: **72.061.694 bytes**
- Entradas ZIP: **412**
- Scripts `.gd`: **55**
- Cenas `.tscn`: **9**
- Texturas `.png`: **99**
- Erros de CRC: **nenhum**
- SHA-256 do ZIP: `5dd8795eb395090a7a59907dc8d1c20d7a4a20859eba222dc77bf40ea6290cff`

## Arquivos de referência confirmados no pacote

| Caminho relativo à raiz do projeto | SHA-256 |
| --- | --- |
| `project.godot` | `e7815db128c1d56cff3be20578d708349286b1affef20ca3ae5910c8f99c5eb4` |
| `scripts/main.gd` | `d5f2ec6c5b9d7045fbc2b891cac1a52cfa98d87704e22ef20974957a2d47c187` |
| `scripts/world_map.gd` | `4adfbe91ca87d1659f451fd2e4e8b04f1280ba6c6913b0e02521f27b39563ad2` |
| `assets/environment/beta3/terrain.png` | `dc48c8d45b83642d8c16f7d6679ae7a9c22627794b944a0f06e937500eec28e5` |
| `assets/environment/beta2/houses.png` | `0e893a026ace96032cf374e223b5bf58aab318b43003ca49cba462f6344306d4` |

## Cenas confirmadas
`scenes/village_iso.tscn`, `scenes/overworld.tscn`, `scenes/world_map.tscn`, `scenes/main.tscn`, `scenes/building_interior.tscn`, `scenes/village_3d.tscn`, `scenes/tactical_battle.tscn`, `scenes/prison_interior.tscn`, `scenes/title.tscn`.

## Situação da distribuição
**O pacote completo ainda não foi publicado no GitHub.** Os arquivos do protótipo atual não correspondem aos hashes acima; não devem ser anunciados como Beta 0.5.2.

Quando a transferência integral ocorrer, o workflow `.github/workflows/entrega.yml` impedirá releases sem as cenas/scripts/texturas essenciais e produzirá ZIP e checksum para cada execução aprovada. Isso reduz o risco de publicar versões incompletas, mas não resolve, por si só, o bloqueio inicial de transferência ChatGPT → GitHub.

## Recuperação no Windows, quando o pacote estiver disponível
Com PowerShell:
```powershell
Get-FileHash .\Fortaleza_Beta_0.5.2_RESTAURADA_Godot.zip -Algorithm SHA256
```
Compare com o SHA-256 registrado acima antes de extrair.
