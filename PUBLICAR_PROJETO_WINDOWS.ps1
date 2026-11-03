# Fortaleza - Publicador de projeto COMPLETO para GitHub
# Requer Git para Windows e autenticacao GitHub (ex.: gh auth login).
# Aceita uma pasta contendo project.godot OU um .zip do projeto.
$ErrorActionPreference = 'Stop'
$Repo = 'https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao.git'
Write-Host '=== Fortaleza: publicacao do projeto COMPLETO ===' -ForegroundColor Cyan
$Origem = Read-Host 'Informe o caminho da PASTA do Godot ou do ZIP completo'
$Origem = $Origem.Trim('"')
if (!(Test-Path -LiteralPath $Origem)) { throw 'Arquivo/pasta nao encontrado.' }
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git nao encontrado. Instale Git para Windows: https://git-scm.com/downloads/win'
}
$Temp = Join-Path $env:TEMP ('fortaleza-publicacao-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Temp | Out-Null
try {
    $Fonte = $Origem
    if ((Get-Item -LiteralPath $Origem).PSIsContainer -eq $false) {
        if (-not $Origem.EndsWith('.zip', [StringComparison]::OrdinalIgnoreCase)) { throw 'Selecione um ZIP ou pasta.' }
        $Extrair = Join-Path $Temp 'extraido'
        Expand-Archive -LiteralPath $Origem -DestinationPath $Extrair -Force
        $Projetos = @(Get-ChildItem -LiteralPath $Extrair -Filter 'project.godot' -Recurse -File)
        if ($Projetos.Count -ne 1) { throw "Esperado 1 project.godot; encontrados $($Projetos.Count)." }
        $Fonte = $Projetos[0].DirectoryName
    }
    if (!(Test-Path -LiteralPath (Join-Path $Fonte 'project.godot'))) { throw 'Nao ha project.godot na raiz selecionada.' }
    $Scripts = @(Get-ChildItem -LiteralPath $Fonte -File -Filter '*.gd' -Recurse)
    $Cenas = @(Get-ChildItem -LiteralPath $Fonte -File -Filter '*.tscn' -Recurse)
    $Imagens = @(Get-ChildItem -LiteralPath $Fonte -File -Filter '*.png' -Recurse)
    Write-Host "Encontrados: $($Scripts.Count) scripts, $($Cenas.Count) cenas, $($Imagens.Count) imagens."
    if ($Scripts.Count -lt 30 -or $Cenas.Count -lt 8 -or $Imagens.Count -lt 50) {
        throw 'Parece ser uma versao incompleta. Nao sera publicada.'
    }
    $Destino = Join-Path $Temp 'repositorio'
    & git clone $Repo $Destino
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao clonar. Confira a conexao e autorizacao do GitHub.' }
    $Exclusoes = @('.git','.godot','__pycache__','.import')
    & robocopy $Fonte $Destino /E /XD $Exclusoes /XF '*.tmp' '*.log' | Out-Null
    if ($LASTEXITCODE -gt 7) { throw "Falha ao copiar (robocopy $LASTEXITCODE)." }
    & git -C $Destino add -A
    & git -C $Destino diff --cached --quiet
    if ($LASTEXITCODE -eq 0) { Write-Host 'Nenhuma alteracao para publicar.'; return }
    & git -C $Destino commit -m 'Atualizar Fortaleza: projeto Godot integral'
    if ($LASTEXITCODE -ne 0) { throw 'Commit falhou. Configure user.name e user.email no Git.' }
    & git -C $Destino push origin main
    if ($LASTEXITCODE -ne 0) { throw 'Push falhou. Entre na sua conta GitHub pelo Git Credential Manager ou gh auth login.' }
    Write-Host 'Projeto enviado. Confira a aba Actions e execute a publicacao de Release.' -ForegroundColor Green
    Start-Process 'https://github.com/alexandre10227-afk/fortaleza-ultimo-bastiao/actions'
}
finally {
    if (Test-Path -LiteralPath $Temp) { Remove-Item -LiteralPath $Temp -Recurse -Force -ErrorAction SilentlyContinue }
}
