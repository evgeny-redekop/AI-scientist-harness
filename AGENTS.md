# AGENTS.md

The rule set for this repository, written to be read by any coding-agent CLI. `CLAUDE.md`
is a thin Claude Code entry point that imports this file; anything binding lives here, so
edit this file rather than that one.

## Read these before anything else

- `.claude/skills/analyze-run/SKILL.md` (the analysis procedure)
- `.claude/skills/analyze-run/lessons.md` (generic operator-taught rules, non-negotiable)
- `.claude/integrations.md` (project tracking, instance-specific)
- the active device's `profile.md` and `lessons.md`, per the Active device section below

**Loading them is not left to the agent's discretion**, because leaving them to be read on
demand meant they often were not. Each CLI is configured to force it:

| CLI | mechanism | file |
|---|---|---|
| Claude Code | `@` imports, expanded before the first prompt | `CLAUDE.md` |
| opencode | `instructions` array, combined with this file | `opencode.json` |
| any other | no config import: open them explicitly, first thing | this list |

⚠️ **Adding a CLI means wiring its own import mechanism**, not adding a sentence here. A prose
instruction is the weakest tier and is the fallback only where the tool offers nothing better.
opencode in particular does not parse file references out of `AGENTS.md`, so the `opencode.json`
entry is what actually loads them. Note also that opencode reads `AGENTS.md` **or** `CLAUDE.md`,
first match wins, so it never sees the pointer and this file has to stand alone.

This repository is a **portable agent harness for measurement-data analysis**: generic
analysis skills plus per-device knowledge directories. It has no dependence on any other
repository — device data loaders are vendored under each device's `lib/`. It is developed
against Claude Code, and the rules below are CLI-agnostic; where a mechanism is specific to
one CLI it is marked as such.

## Active device

<!-- SWAP POINT (public/private fork): the working copy points at a real device
     (devices/<name>/); the public generic skeleton points at devices/TEMPLATE/.
     This pointer is the ONE line that differs between the two. See README →
     "Two copies: generic skeleton vs working copy". The same pointer appears in
     the @ imports of CLAUDE.md and the instructions array of opencode.json once a
     real device is filled in; change all three together. -->

**`devices/TEMPLATE/`** — copy this to `devices/<name>/`, fill in `profile.md`, seed the
`journal/`, and update this pointer to your device directory. Read `profile.md` there before
any data loading, calibration, normalization, or measurement-interpretation work. It is the
single source of device/setup truth. Device-taught rules: its `lessons.md`. Campaign state:
its `journal/` (see `journal/SCHEMA.md`). To work on a different device, add a sibling
directory under `devices/` (start from `devices/TEMPLATE/`) and update this pointer.

## Analysis harness

- **Skills** (`.claude/skills/`): `analyze-run` — credible measurement-data analysis with an
  opt-in Jupytext-notebook deliverable (code + figures + narration together); `three-voices`
  — isolated-context deliberation (Skeptic/Pacifist/Idealist subagents) on a load-bearing
  fork. A CLI without a skill mechanism reads `SKILL.md` directly and follows it.
- **Agents** (`.claude/agents/`): the three deliberation voices; `analysis-reviewer` — the
  independent critic behind the always-on review loop (`analyze-run` §9), which audits the
  computation in a step's code, scores figures against a per-objective rubric, and audits the
  whole pipeline when a claim will not firm up; plus `analysis-executor` — the executor half of
  **directed mode** (`analyze-run` §10). When the session model outranks the executor's pinned
  model, the session directs and the executor computes; it is hands, never head. A CLI without
  subagents runs these roles itself, in a separate pass with the same inputs, and says so.
- **Hooks** (`hooks/`, registered in `.claude/settings.json`, a Claude Code mechanism):
  `notebook_sync.sh` mirrors worktree `.py` edits onto the live `.ipynb`;
  `analyze_run_autoload.sh` marks the `analyze-run` rules active at session start. Under
  another CLI these are run by hand: sync the notebook after every step, and check the rules
  are loaded at session start.
- **Deliverables** live under the device's `analyses/<topic>_<runids>/` (percent `.py`
  committed as source of truth, paired `.ipynb` as live view — `jupytext.toml` at root).
- **Journal protocol:** the journal is the append-only scientific record. Every result ties
  to ≥1 open-question id; the agent proposes journal edits, the user approves before writing.

## Always-on non-negotiables

These apply in every session, with or without a skill:

- **Isolate in a worktree before doing the task.** Before its first file edit, a session moves
  into its own git worktree, and every file-modifying subagent is spawned with worktree
  isolation. Do this at the start of the task, not after an edit is refused. Several sessions
  and subagents may work a repository at once, so an unisolated edit lands on top of changes
  another session is holding uncommitted, and the loser is whichever one writes second. Finish
  by fast-forwarding `main` onto the worktree branch and pushing; if the shared checkout has
  uncommitted work from a live session, stop and reconcile rather than merging over it.
- **Load `analyze-run` before touching measurement data.** Before writing or running any code
  against measurement data (loading a run, plotting, fitting, extending a notebook, or
  continuing work under an `analyses/` directory), the `analyze-run` rules must be active. In
  Claude Code the imports in `CLAUDE.md` expand the whole body into context at startup, and
  they survive resume and compaction; if those rules are somehow absent, an import is
  misconfigured, so load the skill explicitly and say so. Under any other CLI, open the files
  listed at the top of this document before the first analysis action. This rule is what makes
  the rest of this list actually bind.
- **Stop after every analysis step and wait for permission.** Present the figure, what it shows,
  and the reviewer's numbered gaps; then stop. Do not start the next step, or queue work in the
  background, until the user responds. They are authoritative; the reviewer is advisory to them.
- **Nothing reaches the user unreviewed.** Every step is checked by the `analysis-reviewer`
  (`analyze-run` §9) against `review_rubric.md` — the computation audit on the code (formulas,
  normalizations, gains, masks, offsets, units) is never lenient at any stage. Fix what it
  catches before presenting.
- **A claim that will not firm up goes to the pipeline audit, never to a caveated result.**
  Reconstruct the chain, judge the links, test the data-scope choices first (which runs, ranges,
  regimes were picked and what was excluded), change the constraints and re-run. Only if that
  comes up empty is it reported as not-yet-defensible, with a `data_requests.md` entry.
- **Never crop, cut, clip, or mask plotted data** (axes, ranges, or color scales) unless
  explicitly asked; mask only to define a fit window, marked on the figure, fit overlaid on
  unmasked data.
- **Dataset/run ids and clear axis labels on every figure.**
- **Read every saved PNG yourself before describing it** — never narrate an unseen figure.
- **Verify a hypothesis across ALL available datasets before stating a conclusion**; name
  where it holds and where it breaks.
- **No target feature is presupposed**: mundane explanations (thermalization, noise
  floor/resolution, calibration drift) stay on the list of live hypotheses until
  discriminators rule them out; missing discriminating data ⇒ a `journal/data_requests.md`
  entry, not a claim.
- **Follow the device profile's data-access hygiene** (data-source freshness, sanctioned
  loader, normalized units).

## Lessons protocol

A user message starting `!` (or "remember this rule: …") is a durable lesson: generalize it
to one dated bullet, classify it **generic** (→ `.claude/skills/analyze-run/lessons.md`) vs
**device-specific** (→ `devices/<active>/lessons.md`), echo the wording and destination back
for confirmation, then append it above that file's `LESSONS:END` marker and archive the
verbatim original in the device file. `!rule || local` persists only the part before `||`;
the whole message steers the current session. "Re-fold lessons" = regroup bullets topically,
archives untouched.

## Environment

Analysis code expects the scientific Python stack (`numpy`, `scipy`, `matplotlib`,
`xarray`, `qcodes`, `astropy`, `jupytext`). Use whichever conda or virtual environment
provides these on your machine; `conda run -n <env> python ...` or activate before running.
