# AI-scientist-harness

A [Claude Code](https://claude.com/claude-code) harness for collaborative analysis of experimental measurement data. It separates analysis craft (generic, in this repository) from knowledge of your specific system (private, written by you).

The central idea is a **system profile**: a structured document you write once about your experiment. The AI reads it at the start of every session to understand what you are measuring, what can go wrong, and what you are trying to learn.

## What you bring

Before any analysis session, you write `profile.md` for your experimental system. This is what lets the AI reason about your measurements rather than treating them as abstract numbers.

A complete profile covers five areas.

**The science.** What phenomenon are you studying? Name the effects you expect to see, the parameter ranges where they should appear, and the competing explanations that would produce similar signals. The AI cannot exclude a mundane explanation (thermalization, noise floor, calibration drift) unless the alternatives are written down and the profile states what evidence would rule them out.

**System vulnerabilities and weak spots.** Every measurement setup has failure modes that can look like signal: drifting offsets, pickup at specific frequencies, an amplifier that clips at high drive, a contact that degrades at low temperature. List yours. Without this list, the AI has no basis for flagging a suspicious feature before you do.

**Hypotheses under test.** For each effect you are looking for, state what discriminating evidence would confirm it, and what would rule it out. This gives analysis a concrete standard for when a conclusion is defensible.

**The measurement setup.** Signal chain, instruments, gains, units, and calibrations. If a conversion factor lives anywhere other than this document, it will drift or get lost.

**Data access.** How to load your data files: format, path conventions, the loader function. The harness vendors your loader under `devices/<name>/lib/` so it stays alongside the profile.

## How the collaboration works

Sessions run as a sequence of analysis steps. At each step, the AI loads your data and produces a figure or fit; a built-in reviewer agent audits the computation before you see it. You see the figure, the reviewer's numbered concerns, and a proposed interpretation. You respond: approve the step, redirect it, or correct a factual error. Corrections become durable rules via the `!rule` protocol, routed to the generic skill or to your device profile depending on scope.

Open questions and data gaps go into a journal (append-only, one file per topic). When discriminating data does not yet exist, the analysis writes a concrete measurement request to `journal/data_requests.md` and stops. Journal conclusions are proposed by the AI and approved by you before they are written.

For large computations, **directed mode** splits the work: the session model (director) owns all reasoning and reads every figure itself; a pinned-model executor runs the code. This lets you use a stronger model for judgment while keeping compute costs predictable.

## What the harness enforces

**Every analysis starts from the full list of competing explanations**, including the mundane ones from your profile. An effect can be named in a conclusion only after its discriminators pass and the alternatives are addressed.

When discriminating data does not exist, the analysis writes a concrete sweep request to `journal/data_requests.md` and stops.

**Figures show everything**: no cropping or masking of plotted data; every fit is overlaid on the full data with residuals, stated windows, and uncertainties; every run id appears on the figure; every saved PNG is read back by the AI before it is described.

Quick plots stay quick. "Put this in the notebook" promotes work into an append-only Jupytext `.py` file that reproduces top-to-bottom. The `.py` is committed as source of truth; the `.ipynb` is a view.

**Literature checking** runs in a background lane: before an interpretive claim is written up, the AI checks it against the literature and records the findings in `journal/background_literature.md` with verified citations.

## Public skeleton and private working copy

This repository is the public skeleton. To use it, clone it privately and add your experiment directory. The two copies differ by exactly two things: the files present (your working copy adds `devices/<name>/`) and one pointer line in `CLAUDE.md` (marked in-file as the SWAP POINT).

| | Public skeleton | Private working copy |
|---|---|---|
| Visibility | public | private |
| Active experiment | `devices/TEMPLATE/` | `devices/<your-experiment>/` |
| Contains real data or results | no | yes |

The craft files (`.claude/skills/`, `.claude/agents/`, `hooks/`, `devices/TEMPLATE/`) carry analysis discipline with no experiment-specific content. Before publishing any changes to the public skeleton, verify this with grep:

```sh
# Run from the repo root. Must print nothing.
grep -RInE '<your-experiment-tokens>' .claude/ devices/TEMPLATE hooks/
```

## Layout

```
CLAUDE.md                      # always-on rules + active experiment pointer (SWAP POINT)
.claude/
  skills/
    analyze-run/               # analysis discipline + notebook workflow
      SKILL.md                 #   includes directed mode (§10)
      lessons.md               # operator-taught rules, grows via !rule
    three-voices/              # deliberation on a contested scientific claim
      SKILL.md
  agents/
    analysis-executor.md       # directed-mode executor (pinned model)
    voice-skeptic.md           # three deliberation voices with distinct priors
    voice-pacifist.md
    voice-idealist.md
hooks/
  analyze_run_autoload.sh      # SessionStart hook: loads analyze-run at every session start
devices/
  <your-experiment>/           # private: profile, journal, lib, analyses
    profile.md                 # single source of system truth
    lessons.md                 # experiment-taught rules
    lib/                       # vendored data loader
    journal/                   # open questions, dead ends, run memory, data requests
    analyses/                  # notebook deliverables
  TEMPLATE/                    # copy this to start a new experiment
    profile.md
    journal/SCHEMA.md
jupytext.toml                  # .py percent files are source of truth; .ipynb is a view
```

## Getting started

1. Clone this repository (or add it as a `git remote` called `upstream` in a private fork and pull from there).
2. Copy `devices/TEMPLATE/` to `devices/<your-experiment>/` and fill in `profile.md`. See **What you bring** above for what goes in it.
3. Update the `CLAUDE.md` "Active device" line to point at your new directory. This is the SWAP POINT.
4. (Recommended) Install the SessionStart hook so analysis rules survive session resume and compaction. Register it in `~/.claude/settings.json` (global) or the project `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "startup|resume|clear|compact",
        "hooks": [ { "type": "command",
                     "command": "/absolute/path/to/hooks/analyze_run_autoload.sh" } ] }
    ]
  }
}
```

The hook walks up from the session directory to find the skill; it hard-codes no path.

5. Open Claude Code in your working directory and describe what you want: "plot signal vs gate voltage for run 12", "fit the 200–250 K temperature sweep", "run three voices on open question 3", "!always subtract the baseline measured in run 3".

## Adding a new experiment

Copy `devices/TEMPLATE/` to `devices/<name>/`, fill in `profile.md`, seed the journal from its `SCHEMA.md`, update the `CLAUDE.md` pointer, and vendor your data loader under `lib/`.
