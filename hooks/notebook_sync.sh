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
# a project path; the jupytext pairing check is what decides whether a given file
# is in scope.
#
# Two layouts, both handled. In a worktree the .py being edited and the live .py
# are different files, so the copy is the point. In the main checkout they are the
# same file and there is nothing to copy, but the paired .ipynb still has to be
# synced or the user's live view silently goes stale.
#
# Ownership (added 2026-09-03). Several worktrees can hold the same notebook, and
# the live copy is one file. A push from one worktree used to overwrite whatever
# another worktree had pushed, and a pull then carried that foreign content back
# into a third worktree: on 2026-09-03 one arm of a two-arm comparison overwrote
# the shared checkout's notebook and the other arm's copy. The rule now: the live
# file is "owned" by the worktree that last pushed it, recorded in a state file
# keyed by the live path. A push is refused while the live file differs from the
# main checkout's HEAD and is not the pusher's own last push; a pull never
# overwrites a worktree's uncommitted edits with content that is not that
# worktree's own push. Every refusal is logged. An edit made in Jupyter or in the
# main checkout counts as another writer, which is the safe reading.

mode="$1"
JT="${JUPYTEXT_BIN:-$HOME/miniconda3/envs/qcodes_env/bin/jupytext}"
[ -x "$JT" ] || JT="$(command -v jupytext 2>/dev/null)"
PY3="/usr/bin/python3"
LOG="$HOME/.claude/hooks/notebook_sync.log"
STATE_DIR="$HOME/.claude/hooks/sync_state"
log() { echo "$(date '+%F %T') [$mode] $*" >> "$LOG" 2>/dev/null; }

# --- file_path from the hook's stdin JSON ---
fp="$("$PY3" -c 'import sys,json
try: print(json.load(sys.stdin).get("tool_input",{}).get("file_path","") or "")
except Exception: print("")' 2>/dev/null)"
[ -z "$fp" ] && exit 0

# --- any .py of this project, in a worktree or in the main checkout ---
case "$fp" in *.py) ;; *) exit 0 ;; esac
case "$fp" in
  *"/.claude/worktrees/"*)
      # worktree: the live copy is the same relative path under the main checkout
      root="${fp%%/.claude/worktrees/*}"
      rest="${fp#*/.claude/worktrees/}"; rel="${rest#*/}"
      wt="$root/.claude/worktrees/${rest%%/*}"
      live="$root/$rel" ;;
  *)  # main checkout: the file being edited IS the live file; only the .ipynb needs syncing
      live="$fp"; root=""; rel=""; wt="" ;;
esac
# require a real jupytext-paired notebook
head -n 12 "$fp" 2>/dev/null | grep -q "jupytext" \
  || [ -f "${fp%.py}.ipynb" ] || [ -f "${live%.py}.ipynb" ] || exit 0

backup() { local f="$1"; [ -f "$f" ] || return 0
  local b="$HOME/.claude/hooks/sync_backups/$(date +%Y%m%d-%H%M%S)-$$-$RANDOM"; mkdir -p "$b"
  cp -p "$f" "$b/" 2>/dev/null && log "backup $(basename "$f") -> $b"; }

md5of() { [ -f "$1" ] && md5 -q "$1" 2>/dev/null || echo "absent"; }
# md5 of a file's committed (HEAD) version in a given checkout; "unknown" if git cannot say
head_md5() { local dir="$1" r="$2"
  git -C "$dir" show "HEAD:$r" 2>/dev/null | md5 -q 2>/dev/null || echo "unknown"; }
state_file() { mkdir -p "$STATE_DIR"; echo "$STATE_DIR/$(printf '%s' "$live" | md5 -q)"; }
# state: line 1 = owning worktree path, line 2 = md5 of the content it last pushed
state_owner() { sed -n 1p "$(state_file)" 2>/dev/null; }
state_md5()   { sed -n 2p "$(state_file)" 2>/dev/null; }
record_state() { printf '%s\n%s\n' "$wt" "$(md5of "$live")" > "$(state_file)"; }

# guarded_sync <file to pass to jupytext --sync> <the .py of the pair>
# jupytext --sync writes in the direction of the newer file. A gitignored .ipynb left
# stale by a merge or checkout is older in content but can be newer in mtime, and the
# sync then writes that stale notebook over the .py: three committed-cell losses on
# 2026-09-02. The guard refuses any sync that shortens the .py, restores it, and marks
# it newest so the next sync runs .py -> .ipynb.
guarded_sync() { local target="$1" py="$2"
  [ -x "$JT" ] || return 0
  local n0=0 tmp; [ -f "$py" ] && n0=$(wc -l < "$py" | tr -d ' ')
  tmp="$(mktemp)"; [ -f "$py" ] && cp -p "$py" "$tmp"
  ( cd "$(dirname "$target")" && "$JT" --sync "$(basename "$target")" >/dev/null 2>&1 )
  local n1=0; [ -f "$py" ] && n1=$(wc -l < "$py" | tr -d ' ')
  if [ "$n1" -lt "$n0" ]; then
    cp -p "$tmp" "$py"; touch "$py"
    log "REFUSED: sync shortened $(basename "$py") from $n0 to $n1 lines; restored and marked newest"
    ( cd "$(dirname "$py")" && "$JT" --sync "$(basename "$py")" >/dev/null 2>&1 )
  fi
  rm -f "$tmp"; }

if [ "$mode" = "pull" ]; then
  livenb="${live%.py}.ipynb"
  if [ -f "$livenb" ]; then
    guarded_sync "$livenb" "$live"
  fi
  [ -f "$live" ] || exit 0
  [ -z "$wt" ] && exit 0                          # main checkout: nothing to copy
  if ! cmp -s "$live" "$fp"; then
    live_md5="$(md5of "$live")"
    # (1) the live content is another worktree's push: never carry it across
    if [ "$(state_owner)" != "$wt" ] && [ "$(state_md5)" = "$live_md5" ] && [ -n "$(state_owner)" ]; then
      log "REFUSED pull into $wt: live $(basename "$live") is owned by $(state_owner)"
      exit 0
    fi
    # (2) this worktree holds its own uncommitted edits and the live file is not its
    #     own push: both sides changed, so neither may overwrite the other
    if [ "$(md5of "$fp")" != "$(head_md5 "$wt" "$rel")" ] && [ "$(state_md5)" != "$live_md5" ]; then
      log "REFUSED pull into $wt: $(basename "$fp") has uncommitted edits and live differs from HEAD by another writer"
      exit 0
    fi
    backup "$fp"; cp "$live" "$fp"; log "pulled live -> worktree ($fp)"
  fi
  exit 0
fi

if [ "$mode" = "push" ]; then
  [ -f "$fp" ] || exit 0
  if [ -n "$wt" ] && { [ ! -f "$live" ] || ! cmp -s "$fp" "$live"; }; then
    if [ -f "$live" ]; then
      live_md5="$(md5of "$live")"
      if [ "$live_md5" != "$(head_md5 "$root" "$rel")" ] \
         && ! { [ "$(state_owner)" = "$wt" ] && [ "$(state_md5)" = "$live_md5" ]; }; then
        log "REFUSED push from $wt: live $(basename "$live") differs from HEAD and is not this worktree's last push (owner: $(state_owner))"
        exit 0
      fi
    fi
    backup "$live"; cp "$fp" "$live"; record_state; log "pushed worktree -> live ($live)"
  fi
  # Always sync the pair: in the main checkout this is the only thing there is to do.
  touch "$live"                                          # .py newest -> sync goes py->ipynb
  guarded_sync "$live" "$live"
  log "synced .ipynb ($live)"
  exit 0
fi
exit 0
