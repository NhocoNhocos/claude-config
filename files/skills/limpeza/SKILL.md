---
name: limpeza
description: Faz um inventário e uma limpeza das skills, plugins e agentes do Claude Code. Lista tudo, explica cada um numa linha, aponta duplicados, sugere em que sessões/projetos devem ficar e só altera alguma coisa depois de autorização, com cópia de segurança. Usar quando o utilizador escrever /limpeza ou pedir para arrumar skills, plugins ou agentes.
disable-model-invocation: true
---

# Limpeza de skills, plugins e agentes

Responde em português de Portugal, trata o utilizador por "tu", frases curtas.

**Regra principal:** nas fases 1 a 5 não apagues, não movas e não desligues nada. Só lês.

## Fase 1 — Inventário (só leitura)

Procura em todos estes sítios. No Windows, `~` é `%USERPROFILE%`.

1. **Skills gerais:** `~/.claude/skills/*/SKILL.md`
2. **Skills deste projeto:** `<pasta atual>/.claude/skills/*/SKILL.md`
3. **Skills de outros projetos:** lê `~/.claude.json` (chave `projects`) para saber as pastas dos projetos. Em cada uma, procura `.claude/skills/*/SKILL.md`.
4. **Plugins e as skills deles:**
   - `~/.claude/plugins/installed_plugins.json` e `~/.claude/settings.json` (chave `enabledPlugins`) para saber quais estão ligados ou desligados.
   - Skills dentro dos plugins: `~/.claude/plugins/**/skills/*/SKILL.md` e comandos em `~/.claude/plugins/**/commands/*.md`.
5. **Agentes:** `~/.claude/agents/*.md`, `<projeto>/.claude/agents/*.md` e `~/.claude/plugins/**/agents/*.md`.
6. **Comandos antigos:** `~/.claude/commands/*.md` e `<projeto>/.claude/commands/*.md`.

**Proteção de dados privados:**
- Em `~/.claude.json` lê só a lista de pastas da chave `projects`. Em `~/.claude/settings.json` lê só a chave `enabledPlugins`. Ignora todo o resto.
- Usa um comando que extraia só essas chaves (por exemplo `python -c` com `json`). Não abras o ficheiro inteiro com Read.
- Nunca mostres, copies nem guardes outros valores desses ficheiros: e-mail, conta, tokens, chaves de API, variáveis `env`.

Para cada item, lê o `name` e a `description` do cabeçalho (frontmatter). Não leias o ficheiro todo se não for preciso.

## Fase 2 — Uma linha por item

Escreve o que cada item faz numa frase curta e simples.

## Fase 3 — Duplicados

Agrupa os que fazem coisas parecidas. Para cada grupo diz qual manter e porquê (mais completo, mais usado, oficial, menos tokens).

## Fase 4 — Onde deve ficar

As sessões do utilizador estão organizadas por categoria:
📱 Redes sociais · 🎮 Jogos · 🧱 Roblox · 📈 Trading · ✈️ AFA · 🤖 Automação · 🛒 Vendas online · 🌐 Sites · ⚙️ Configuração.

Para cada item sugere:
- **Geral** — útil em quase todas as sessões.
- **Só numa categoria** — diz qual e a pasta do projeto onde deve ficar.
- **Remover do geral / desligar** — não faz falta.

Sugere também skills novas que faltem em alguma categoria (só sugerir, não instalar).

Nota para explicar ao utilizador: uma skill não fica presa a uma sessão, fica presa a uma **pasta de projeto**. Para uma skill aparecer só nas sessões de uma categoria, vai para `<pasta do projeto>/.claude/skills/`. Skills de plugins não se movem: só se liga ou desliga o plugin.

## Fase 5 — Tabela e pedido de autorização

Mostra tudo numa tabela:

| Nome | Tipo (skill/plugin/agente/comando) | Onde está agora | O que faz | Duplicado de | Sugestão | Onde deve ficar |
|---|---|---|---|---|---|---|

Depois mostra a lista numerada das alterações que propões (mover, tirar do geral, desligar plugin).

Pergunta com `AskUserQuestion` (multiSelect) quais aprova. **Para aqui e espera.** Sem resposta clara, não mexes em nada.

## Fase 6 — Só depois da autorização

1. **Cópia de segurança primeiro.** Copia `~/.claude/skills` (e `~/.claude/agents` se fores mexer em agentes) para `~/.claude/backups/skills-AAAA-MM-DD-HHMM/`. Confirma que a cópia tem o mesmo número de ficheiros que a original. Se falhar, para.
2. **Move** para `<pasta do projeto>/.claude/skills/` as skills aprovadas. Cria a pasta se não existir.
3. **Tira do geral** as aprovadas, movendo-as para a cópia de segurança (nunca apagar de vez).
4. **Plugins:** só desliga os aprovados, com `claude plugin disable <plugin>`. Não desinstales.
5. Não toques nos plugins `ponytail` e `lemo-opuscar` (já estão desligados de propósito) nem na skill `skill-inspector` sem pedido explícito.
6. Se a configuração estiver no repositório `claude-config`, pergunta se queres atualizar lá também. Nunca ponhas o e-mail pessoal no repositório.

## Fim — Como ficou

Mostra uma tabela "Antes → Depois" e diz:
- onde está a cópia de segurança;
- como desfazer (copiar a pasta da cópia de volta para `~/.claude/skills`);
- que é preciso correr `/reload-plugins` ou abrir uma sessão nova para ver as mudanças.
