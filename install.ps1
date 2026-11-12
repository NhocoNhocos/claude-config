# Instala a configuração do Claude Code num PC com Windows.
# Precisa de: Git, Python 3, uv e Claude Code. Corre no PowerShell (ver README).
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$C = Join-Path $env:USERPROFILE ".claude"
foreach ($d in "skills", "hooks", "output-styles", "agents") { New-Item -ItemType Directory -Force (Join-Path $C $d) | Out-Null }

# 1. SkillSpector + skill skill-inspector
$S = Join-Path $env:TEMP "SkillSpector"
if (Test-Path $S) { Remove-Item -Recurse -Force $S }
git clone -q --depth 1 https://github.com/NVIDIA/SkillSpector.git $S
if ($LASTEXITCODE -eq 0) {
  # --python 3.12: o yara-python (dependência) ainda não tem versão pronta para Python 3.14
  uv tool install --force --python 3.12 $S
  if ($LASTEXITCODE -ne 0) { Write-Warning "skillspector install failed" }
  $SI = Join-Path $C "skills\skill-inspector"
  if (Test-Path $SI) { Remove-Item -Recurse -Force $SI }
  Copy-Item -Recurse (Join-Path $S "skills\skill-inspector") (Join-Path $C "skills")
} else { Write-Warning "SkillSpector clone failed" }

# 2. Ficheiros de configuração
Copy-Item files\hooks\skill-guard.py (Join-Path $C "hooks") -Force
Copy-Item files\CLAUDE.md (Join-Path $C "CLAUDE.md") -Force
Copy-Item files\output-styles\*.md (Join-Path $C "output-styles") -Force
Copy-Item files\agents\*.md (Join-Path $C "agents") -Force
if (-not (Test-Path (Join-Path $C "skill-guard.json"))) { Copy-Item files\skill-guard.json $C }
# settings.json: no Windows o Python costuma chamar-se "python" e não "python3"
# Evita o atalho da Microsoft Store (WindowsApps\python.exe): corre como app empacotada e não vê
# %APPDATA%\uv, por isso o skillspector falha com "uv trampoline failed to canonicalize script path".
$py = (Get-Command python3, python -All -ErrorAction SilentlyContinue |
       Where-Object { $_.Source -notmatch '\\WindowsApps\\' } | Select-Object -First 1).Source
if (-not $py) { $py = "python" }
$pyCmd = '\"' + ($py -replace '\\', '/') + '\"'  # caminho entre aspas (escapadas para JSON), com / para o Git Bash
$Set = Join-Path $C "settings.json"
if (Test-Path $Set) { Copy-Item $Set "$Set.bak" -Force; Write-Host "settings.json antigo guardado em settings.json.bak" }
$json = (Get-Content files\settings.json -Raw -Encoding UTF8) -replace "python3 ", "$pyCmd "
# Junta ao settings.json existente (mantém enabledPlugins, marketplaces, etc.) em vez de o substituir
$tmp = Join-Path $env:TEMP "claude-settings-new.json"
[IO.File]::WriteAllText($tmp, $json, (New-Object Text.UTF8Encoding $false))
& $py -I -c "import json,os,sys; s,n=sys.argv[1],sys.argv[2]; c=json.load(open(s,encoding='utf-8')) if os.path.exists(s) else {}; c.update(json.load(open(n,encoding='utf-8'))); open(s,'w',encoding='utf-8').write(json.dumps(c,indent=2,ensure_ascii=False)+'\n')" $Set $tmp
Remove-Item $tmp

# 3. Mods (plugins)
if (Get-Command claude -ErrorAction SilentlyContinue) {
  claude plugin marketplace add robonuggets/ribbon;      claude plugin install ribbon@robonuggets --scope user
  claude plugin marketplace add johnnyvizz/claude-kit;   claude plugin install savvy-progress@claude-kit --scope user
  claude plugin install savvy-flow@claude-kit --scope user
  claude plugin marketplace add DietrichGebert/ponytail; claude plugin install ponytail@ponytail --scope user
  claude plugin marketplace add lemomo-ai/lemo-opuscar;  claude plugin install lemo-opuscar@lemolab --scope user
  claude plugin disable ponytail@ponytail --scope user
  claude plugin disable lemo-opuscar@lemolab --scope user
} else { Write-Warning "Comando claude nao encontrado: os mods (plugins) nao foram instalados" }
Write-Host "Feito. Fecha e volta a abrir o Claude Code."
