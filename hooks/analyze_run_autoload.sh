#!/usr/bin/env bash
# analyze_run_autoload.sh — Claude Code SessionStart hook (portable).
#
# On every session start (startup / resume / clear / compact), if the session's
# cwd is inside a checkout of this harness, inject the analyze-run SKILL.md body
# straight into context so its rules are present regardless of whether the model
# ever calls the Skill tool. This is what makes the analysis discipline survive
# a resumed or compacted session, where a one-time skill load would be lost.
#
# Portable by construction: it does NOT hard-code any project path. It walks up
# from cwd to the nearest `.claude/skills/analyze-run/SKILL.md` and loads that
# copy — so a worktree on a branch gets that branch's skill, a plain checkout
# gets its own. Outside any harness checkout it emits nothing and exits 0.
#
# Install (per machine, once):
#   1. Copy this file somewhere stable, e.g. ~/.claude/hooks/analyze_run_autoload.sh
#      (or run it straight from the repo), and `chmod +x` it.
#   2. Register it in ~/.claude/settings.json (or the project .claude/settings.json):
#        "hooks": {
#          "SessionStart": [
#            { "matcher": "startup|resume|clear|compact",
#              "hooks": [ { "type": "command",
#                           "command": "/ABSOLUTE/PATH/TO/analyze_run_autoload.sh" } ] }
#          ]
#        }
# Always exits 0 so it can never block a session from starting.

LOG="${ANALYZE_RUN_AUTOLOAD_LOG:-$HOME/.claude/hooks/analyze_run_autoload.log}"
log() { echo "$(date '+%F %T') $*" >> "$LOG" 2>/dev/null; }

# --- cwd from the hook's stdin JSON ---
payload="$(cat)"
cwd="$(printf '%s' "$payload" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("cwd",""))
except Exception: print("")' 2>/dev/null)"
[ -z "$cwd" ] && cwd="$PWD"

# --- find the nearest analyze-run SKILL.md walking up from cwd ---
skill=""
d="$cwd"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  cand="$d/.claude/skills/analyze-run/SKILL.md"
  if [ -f "$cand" ]; then skill="$cand"; break; fi
  d="$(dirname "$d")"
done

# Not inside a harness checkout -> do nothing.
[ -z "$skill" ] && { log "skip (no harness skill above): $cwd"; exit 0; }

body="$(cat "$skill")"
ctx="The analyze-run skill is ACTIVE for this session because you are inside a measurement-analysis harness checkout. Its rules below are non-negotiable and bind every measurement-data action this session, whether or not you separately call the Skill tool. Also read the active device profile named in CLAUDE.md before loading data.

--- BEGIN analyze-run SKILL.md ($skill) ---
$body
--- END analyze-run SKILL.md ---"
log "injected skill body from $skill (cwd $cwd)"

printf '%s' "$ctx" | python3 -c 'import json,sys
ctx=sys.stdin.read()
print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":ctx}}))'
exit 0
