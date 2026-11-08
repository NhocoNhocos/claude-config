#!/usr/bin/env bash
# Verifica se os ficheiros estão válidos antes de fazer push.
set -e; cd "$(dirname "$0")"
jq empty files/settings.json files/skill-guard.json
python3 -m py_compile files/hooks/skill-guard.py
bash -n install.sh
head -1 files/agents/*.md | grep -q -- "---"
echo "tudo ok"
