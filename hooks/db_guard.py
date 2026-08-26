#!/usr/bin/env python3
"""Refuse any shell command that would modify a protected raw-data file.

Raw measurement files are the scientific record. Reading one is allowed, and so is
copying a fresh master over the local working copy; everything that would delete,
move, truncate, overwrite or rewrite one is refused before it runs.

Which files are protected is not written here. Each device profile declares its own
between the PROTECTED-FILES markers, so protecting a newly created database is a
one-line edit to `devices/<name>/profile.md` and needs no change to this script or to
the hook registration:

    <!-- PROTECTED-FILES:BEGIN -->
    M55D8_5112026.db
    <!-- PROTECTED-FILES:END -->

A name is matched anywhere in the command as plain text, so the SQLite sidecar files
(`-wal`, `-shm`) are covered by the database name itself.

Wired as a PreToolUse hook on Bash in `.claude/settings.json`. The hook fails open:
a payload it cannot parse, a missing profile, or an empty list lets the command
through, so a fault here never stops ordinary work. It exits 0 in every case and
refuses by returning a deny decision.
"""

import json
import os
import re
import shlex
import sys
from pathlib import Path

BEGIN = "PROTECTED-FILES:BEGIN"
END = "PROTECTED-FILES:END"

# Each entry is (pattern, what the command would do). Matched against the whole
# command, which by this point is known to name a protected file.
WRITE_PATTERNS = [
    (r"\brm\b", "deletes files"),
    (r"\bmv\b", "moves or renames files"),
    (r"\b(shred|truncate|dd)\b", "overwrites a file in place"),
    (r"\b(chmod|chown)\b", "changes file ownership or permissions"),
    (r"\bsed\b[^|;&]*\s-i", "edits a file in place"),
    (r"(?i)\b(insert|update|delete|drop\s+table|alter\s+table|vacuum|reindex)\b",
     "runs write SQL against a database"),
    (r"\bos\.(remove|unlink|rename|replace|truncate)\s*\(", "removes or renames via os"),
    (r"\bshutil\.(move|rmtree)\s*\(", "moves or removes via shutil"),
    (r"""\bopen\s*\([^)]*['"][wax]""", "opens a file for writing"),
    (r"\.(write_bytes|write_text|unlink|rename)\s*\(", "writes or removes via pathlib"),
]

COPY_VERB = r"\b(cp|rsync|scp|copy2|copyfile|copy)\b"
# The refresh copies master to working copy. Run the other way it destroys the master,
# so a copy call that names the working copy before the master is refused. The literal
# path form is caught by the destination test in copies_out; these two cover the
# variable form the profiles use in their copy-paste refresh snippet.
LOCAL_REF = r"\bHARNESS\b|\bLOCAL\b|\bWORKING\b"
MASTER_REF = r"\bMASTER\b|\bLIVE\b|\bSOURCE_ROOT\b"


def repo_root():
    """The harness checkout this hook belongs to."""
    env = os.environ.get("CLAUDE_PROJECT_DIR")
    if env:
        return Path(env)
    return Path(__file__).resolve().parents[1]


def protected_names(root):
    """Every filename declared between the markers in any device profile."""
    names = []
    for profile in sorted(root.glob("devices/*/profile.md")):
        try:
            text = profile.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for block in re.findall(rf"{BEGIN}(.*?){END}", text, re.DOTALL):
            for line in block.splitlines():
                # The capture starts inside the opening comment and ends inside the
                # closing one, so strip both fragments before reading the line.
                line = line.replace("<!--", "").replace("-->", "")
                line = line.strip().lstrip("-*").strip().strip("`")
                # Skip blanks, comment lines, and the TEMPLATE's <placeholder>.
                if not line or line.startswith(("#", "<")):
                    continue
                # A filename has at least one letter or digit. This rejects the stray
                # punctuation a marker leaves behind, which would otherwise be treated
                # as a protected name and match almost every command.
                if not re.search(r"[A-Za-z0-9]", line):
                    continue
                names.append(line)
    return names


def copies_out(command, root):
    """True if a copy call would write a protected file outside the checkout."""
    for verb in re.finditer(COPY_VERB, command):
        tail = command[verb.end():verb.end() + 400]
        local = re.search(LOCAL_REF, tail)
        master = re.search(MASTER_REF, tail)
        if local and master and local.start() < master.start():
            return True
    if not re.search(COPY_VERB, command):
        return False
    try:
        tokens = shlex.split(command)
    except ValueError:
        return False
    destination = tokens[-1] if tokens else ""
    if "/" not in destination:
        return False
    try:
        resolved = Path(destination).expanduser().resolve()
        resolved.relative_to(root.resolve())
    except ValueError:
        return True
    except OSError:
        return False
    return False


def deny(reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


def main():
    try:
        command = json.load(sys.stdin)["tool_input"]["command"]
    except Exception:
        sys.exit(0)

    root = repo_root()
    names = protected_names(root)
    if not names:
        print("db_guard.py: no PROTECTED-FILES block found in any device profile; "
              "raw data files are unguarded.", file=sys.stderr)
        sys.exit(0)

    named = [n for n in names if n in command]
    if not named:
        sys.exit(0)

    # Redirection and tee are only a write when the protected file is the target, so
    # these two are built from the name. A command that loads a database and sends its
    # printed output to a log file is left alone.
    targeted = [
        (rf">>?\s*[^|;&]*{re.escape(n)}", "redirects output into a protected file")
        for n in named
    ] + [
        (rf"\btee\b[^|;&]*{re.escape(n)}", "writes into a protected file through tee")
        for n in named
    ]

    for pattern, effect in targeted + WRITE_PATTERNS:
        if re.search(pattern, command):
            deny(
                f"Blocked by hooks/db_guard.py: this command {effect}, and it names "
                f"{named[0]}, a protected raw-data file. Protected files are the "
                "scientific record and are never modified. Reading one is fine, and so "
                "is copying the live master over the local working copy. The list is "
                "declared between the PROTECTED-FILES markers in the device profile. "
                "If the write is genuinely intended, ask the operator to run it."
            )

    if copies_out(command, root):
        deny(
            f"Blocked by hooks/db_guard.py: this copies {named[0]} out of the working "
            "copy to a destination outside it, which is the refresh run backwards and "
            "would overwrite the live record. The sanctioned direction is master to "
            "working copy."
        )

    sys.exit(0)


if __name__ == "__main__":
    main()
