# CLAUDE.md

**The rules live in `AGENTS.md`.** This file is only the Claude Code entry point, so that any
other CLI can pick up the same rule set from a filename it recognises. Edit `AGENTS.md`, not
this file. The single exception is the import block below, which is Claude Code machinery.

<!-- Expands the rule set, the analyze-run skill body and instance-specific integrations
     into context before the first prompt. AGENTS.md lists these same paths in prose, for
     CLIs that do not expand '@' imports; opencode.json repeats them for opencode. -->
@AGENTS.md
@.claude/skills/analyze-run/SKILL.md
@.claude/integrations.md
