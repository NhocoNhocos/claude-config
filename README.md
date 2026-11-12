# claude-config

A minha configuração do Claude Code para as sessões da nuvem.

| Ficheiro | Para que serve |
|---|---|
| `install.sh` | Instala tudo. O script do ambiente Default só corre isto. |
| `install.ps1` | Igual ao `install.sh`, mas para um PC com Windows. |
| `files/settings.json` | Estilo "Simples PT", skills escondidas e hooks do skill-guard |
| `files/CLAUDE.md` | Regra: analisar skills com o skill-inspector antes de instalar |
| `files/hooks/skill-guard.py` | Analisa automaticamente cada skill nova com o SkillSpector |
| `files/skill-guard.json` | Skills já analisadas (ponto de partida) |
| `files/output-styles/simples-pt.md` | Estilo de resposta em português, curto e simples |
| `files/agents/quick-fixer.md` | Ajudante barato (Haiku) para gralhas e edições pequenas; só se usa quando pedes |

Para mudar algo: edita o ficheiro, faz commit e push. A próxima sessão nova já usa a versão nova.

## Instalar no PC (Windows)

Precisas de Git, Python 3, [uv](https://docs.astral.sh/uv/) e Claude Code. No PowerShell:

```powershell
git clone https://github.com/NhocoNhocos/claude-config.git $env:USERPROFILE\claude-config
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\claude-config\install.ps1
```

Para atualizar: `git -C $env:USERPROFILE\claude-config pull` e corre outra vez o `install.ps1`.

## Atenção: cache da nuvem
A nuvem guarda uma "fotografia" do arranque e só volta a correr o script quando ele muda.
Depois de cada push, sobe o número `# claude-config vN` no script do ambiente Default.
