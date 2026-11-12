#!/usr/bin/env python3
import hashlib, json, os, pathlib, shutil, subprocess, sys
C = pathlib.Path.home() / ".claude"
DB = C / "skill-guard.json"
try: db = json.loads(DB.read_text())
except Exception: db = {}
def digest(d):
    m = hashlib.sha256()
    for p in sorted(d.rglob("*")):
        if p.is_file() and not p.is_symlink():
            m.update(str(p.relative_to(d)).encode()); m.update(p.read_bytes())
    return m.hexdigest()
def official(d):
    try:
        man = json.loads((d.parent / "manifest.json").read_text())
        src = {s.get("name"): s.get("source") for s in man.get("skills", [])}
        return src.get(d.name) in ("anthropic", "anthropic-example")
    except Exception:
        return False
exe = shutil.which("skillspector") or str(C.parent / ".local/bin" / ("skillspector.exe" if os.name == "nt" else "skillspector"))
alerts = []
for md in sorted((C / "skills").rglob("SKILL.md")):
    d = md.parent
    if ".trash" in md.parts: continue  # deleted skills (moved to trash), not active
    if official(d): continue  # official Anthropic skills synced from claude.ai
    h = digest(d)
    if db.get(d.name) == h: continue
    # Read the report from stdout: on Windows SkillSpector refuses --output ("Safe file output is unsupported")
    try:
        p = subprocess.run([exe, "scan", str(d), "--no-llm", "--format", "json"],
                           capture_output=True, timeout=300, text=True, encoding="utf-8", errors="replace")
        out = p.stdout.strip()
        r = json.loads(out[out.find("{"):]) if "{" in out else None
        if not isinstance(r, dict):
            err = (p.stderr or "sem resultado").strip()[:200]
            if "trampoline" in err and "WindowsApps" in sys.executable:
                err += " - o hook corre com o Python da Microsoft Store, que nao ve %APPDATA%\\uv; volta a correr o install.ps1"
            raise ValueError(err)
    except Exception as e:
        alerts.append(f"- {d.name} ({d}): scan falhou ({e}); rever manualmente"); continue
    ra = r.get("risk_assessment", {})
    hi = [f"{i['id']} {i['location']['file']}:{i['location'].get('start_line')}"
          for i in r.get("issues", []) if i.get("severity") in ("HIGH", "CRITICAL")]
    if hi or ra.get("recommendation") == "DO_NOT_INSTALL":
        alerts.append(f"- {d.name} ({d}): score {ra.get('score')}/100, {ra.get('recommendation')}; HIGH/CRITICAL: {', '.join(hi[:8])}")
    db[d.name] = h
DB.write_text(json.dumps(db, indent=1))
if alerts:
    print("SKILL GUARD: SkillSpector found risky findings in new or changed skills:\n" + "\n".join(alerts) +
          "\nFollow the skill-inspector skill to review the source at those locations, then tell the user the "
          "verdict (APPROVE/CAUTION/REJECT) in their language and ASK whether they want to keep it installed. "
          "If they say no, remove the folder (local skill) or tell them to disable it on claude.ai (synced skill).",
          file=sys.stderr)
    sys.exit(2)
