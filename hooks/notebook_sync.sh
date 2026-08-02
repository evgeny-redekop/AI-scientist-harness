#!/usr/bin/env bash
# notebook_sync.sh — two-way sync of a jupytext analysis notebook between a git
# worktree (where Claude edits the .py) and the live project folder (where the
# user edits the .ipynb in Jupyter).
#
#   pull : live  -> worktree   (run as a PreToolUse Read hook, before Claude reads)
#   push : worktree -> live    (run as a PostToolUse Edit hook, after Claude edits)
#
# The .py is the cross-folder transfer unit; jupytext --sync keeps the live .ipynb
# in step with it. Safety: any file about to be overwritten with *different*
# content is first copied to a timestamped backup dir, so nothing is lost.
# Always exits 0 so it can never block a tool call.
#
# Scope: registered per project in .claude/settings.json via $CLAUDE_PROJECT_DIR,
# so it only runs for the checkout that ships it. It therefore does NOT hard-code
# a project path; the worktree layout plus the jupytext pairing check are what
# decide whether a given file is in scope.

mode="$1"
# Set JUPYTEXT_BIN if jupytext is not on PATH, e.g. inside a conda environment.
JT="${JUPYTEXT_BIN:-$(command -v jupytext 2>/dev/null)}"
PY3="$(command -v python3 2>/dev/null || echo /usr/bin/python3)"
LOG="$HOME/.claude/hooks/notebook_sync.log"
log() { echo "$(date '+%F %T') [$mode] $*" >> "$LOG" 2>/dev/null; }

# --- file_path from the hook's stdin JSON ---
fp="$("$PY3" -c 'import sys,json
try: print(json.load(sys.stdin).get("tool_input",{}).get("file_path","") or "")
except Exception: print("")' 2>/dev/null)"
[ -z "$fp" ] && exit 0

# --- only a .py inside a worktree of this project ---
case "$fp" in *"/.claude/worktrees/"*) ;; *) exit 0 ;; esac
case "$fp" in *.py) ;; *) exit 0 ;; esac
root="${fp%%/.claude/worktrees/*}"
rest="${fp#*/.claude/worktrees/}"; rel="${rest#*/}"
live="$root/$rel"
# require a real jupytext-paired notebook
head -n 12 "$fp" 2>/dev/null | grep -q "jupytext" \
  || [ -f "${fp%.py}.ipynb" ] || [ -f "${live%.py}.ipynb" ] || exit 0

backup() { local f="$1"; [ -f "$f" ] || return 0
  local b="$HOME/.claude/hooks/sync_backups/$(date +%Y%m%d-%H%M%S)-$$-$RANDOM"; mkdir -p "$b"
  cp -p "$f" "$b/" 2>/dev/null && log "backup $(basename "$f") -> $b"; }

if [ "$mode" = "pull" ]; then
  livenb="${live%.py}.ipynb"
  if [ -x "$JT" ] && [ -f "$livenb" ]; then
    ( cd "$(dirname "$live")" && "$JT" --sync "$(basename "$livenb")" >/dev/null 2>&1 )
  fi
  [ -f "$live" ] || exit 0
  if ! cmp -s "$live" "$fp"; then backup "$fp"; cp "$live" "$fp"; log "pulled live -> worktree ($fp)"; fi
  exit 0
fi

if [ "$mode" = "push" ]; then
  [ -f "$fp" ] || exit 0
  if [ ! -f "$live" ] || ! cmp -s "$fp" "$live"; then
    backup "$live"; cp "$fp" "$live"; touch "$live"     # .py newest -> sync goes py->ipynb
    [ -x "$JT" ] && ( cd "$(dirname "$live")" && "$JT" --sync "$(basename "$live")" >/dev/null 2>&1 )
    log "pushed worktree -> live + synced .ipynb ($live)"
  fi
  exit 0
fi
exit 0
