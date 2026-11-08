#!/usr/bin/env bash
# Instala a configuração do Claude Code numa sessão da nuvem.
cd "$(dirname "$0")"
C=/root/.claude
mkdir -p $C/skills $C/hooks $C/output-styles

# 1. SkillSpector + skill skill-inspector
rm -rf /opt/SkillSpector
if git clone -q --depth 1 https://github.com/NVIDIA/SkillSpector.git /opt/SkillSpector; then
  /root/.local/bin/uv tool install --force /opt/SkillSpector || echo "skillspector install failed"
  rm -rf $C/skills/skill-inspector
  cp -r /opt/SkillSpector/skills/skill-inspector $C/skills/ || true
fi

# 2. Ficheiros de configuração
cp files/hooks/skill-guard.py $C/hooks/
cp files/CLAUDE.md $C/CLAUDE.md
cp files/settings.json $C/settings.json
cp files/output-styles/*.md $C/output-styles/
[ -f $C/skill-guard.json ] || cp files/skill-guard.json $C/skill-guard.json

# 3. Mods (plugins)
CL=/opt/node22/bin/claude
if [ -x $CL ]; then (cd /root
  $CL plugin marketplace add robonuggets/ribbon && $CL plugin install ribbon@robonuggets --scope user
  $CL plugin marketplace add johnnyvizz/claude-kit && $CL plugin install savvy-progress@claude-kit --scope user && $CL plugin install savvy-flow@claude-kit --scope user
  $CL plugin marketplace add DietrichGebert/ponytail && $CL plugin install ponytail@ponytail --scope user
  $CL plugin marketplace add lemomo-ai/lemo-opuscar && $CL plugin install lemo-opuscar@lemolab --scope user
) || echo "mods install failed"; fi
exit 0
