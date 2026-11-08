# claude-config

A minha configuração do Claude Code para as sessões da nuvem.

| Ficheiro | Para que serve |
|---|---|
| `install.sh` | Instala tudo. O script do ambiente Default só corre isto. |
| `files/settings.json` | Estilo "Simples PT", skills escondidas e hooks do skill-guard |
| `files/CLAUDE.md` | Regra: analisar skills com o skill-inspector antes de instalar |
| `files/hooks/skill-guard.py` | Analisa automaticamente cada skill nova com o SkillSpector |
| `files/skill-guard.json` | Skills já analisadas (ponto de partida) |
| `files/output-styles/simples-pt.md` | Estilo de resposta em português, curto e simples |

Para mudar algo: edita o ficheiro, faz commit e push. A próxima sessão nova já usa a versão nova.

## Atenção: cache da nuvem
A nuvem guarda uma "fotografia" do arranque e só volta a correr o script quando ele muda.
Depois de cada push, sobe o número `# claude-config vN` no script do ambiente Default.
