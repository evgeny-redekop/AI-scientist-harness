#!/usr/bin/env bash
# analyze_run_autoload.sh — Claude Code SessionStart hook (portable).
#
# On every session start (startup / resume / clear / compact), if the session's
# cwd is inside a checkout of this harness, emit a short notice that the
# analyze-run rules are binding for this session.
#
# The rules THEMSELVES arrive via the '@.claude/skills/analyze-run/SKILL.md'
# import in the harness CLAUDE.md, which expands the file inline at startup.
# This hook must stay small: Claude Code caps hook output at 10,000 characters
# and replaces anything longer with a ~2 KB preview plus a file path, so a hook
# can never be the delivery route for the ~17 KB skill body.
#
# Portable by construction: it does NOT hard-code any project path. It walks up
# from cwd to the nearest `.claude/skills/analyze-run/SKILL.md` and loads that
# copy — so a worktree on a branch gets that branch's skill, a plain checkout
# gets its own. Outside any harness checkout it emits nothing and exits 0.
#
# Install: nothing to do. The repo's .claude/settings.json already registers this
# file through "$CLAUDE_PROJECT_DIR/hooks/analyze_run_autoload.sh", so the tracked
# copy is the one that runs, here and in every worktree.
#
# Do not register it from ~/.claude/settings.json pointing at a copy outside the
# repo. That copy drifts, and edits to the tracked file then silently do nothing.
#
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

ctx="The analyze-run skill is ACTIVE for this session because you are inside a
measurement-analysis harness checkout. Its rules are non-negotiable and bind every
measurement-data action this session, whether or not you separately call the Skill tool.

The full skill body is already in your context: the harness CLAUDE.md imports it with
'@.claude/skills/analyze-run/SKILL.md', which expands the file inline at startup. Do not
re-read it to obtain the rules. Its source is:
  $skill

If that text is genuinely absent from your context, the import is misconfigured: read the
file above before touching measurement data, and tell the user the import is broken.

Also read the active device profile named in CLAUDE.md before loading data."
log "emitted activation notice for $skill (cwd $cwd)"

printf '%s' "$ctx" | python3 -c 'import json,sys
ctx=sys.stdin.read()
print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":ctx}}))'
exit 0
