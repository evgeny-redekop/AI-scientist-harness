# measurement-harness

A portable [Claude Code](https://claude.com/claude-code) harness for credible, precise
analysis of experimental measurement data. You chat; the harness supplies the discipline.

Born from a condensed-matter transport experiment (a gated Josephson-junction array in a
dilution refrigerator), but built around a strict split:

- **Generic layer** — analysis craft that holds for any measurement campaign. Contains no
  device names, no instrument names, no target phenomena (enforced by grep — see below).
- **Device layer** — everything specific to one chip/setup/campaign, in one swappable
  directory under `devices/`.

Moving to a new device or experiment = writing one new directory under `devices/`. The
harness itself never changes.

## Two copies: generic skeleton vs working copy

This repository is designed to exist as **two copies cut from the same tree**:

| | **Generic skeleton** | **Working copy** |
|---|---|---|
| Visibility | **public** | **private** |
| Active device | `devices/TEMPLATE/` | a real device, e.g. `devices/M55D8/` |
| Contains real data / results? | **no** | yes |
| Purpose | a publishable, reusable framework | day-to-day analysis of one device |

They differ by exactly two things: **which files are present** (the working copy adds a real
`devices/<name>/`) and **one pointer line** (`CLAUDE.md` → "Active device", marked in-file as
the SWAP POINT). Everything else is byte-identical and shared.

**The boundary — what belongs to which layer:**

- **Generic (safe to publish):**
  `.claude/skills/`, `.claude/agents/`, `CLAUDE.md` (pointer at `TEMPLATE`), `devices/TEMPLATE/`,
  `hooks/`, `jupytext.toml`, `README.md`. These carry analysis discipline only — no device
  name, instrument name, run id, gate/knob name, calibration number, or target phenomenon.
- **Device-specific (private — never publish):**
  the entire real `devices/<name>/` directory:
  - `profile.md` — wiring, gains, calibrations, hard limits, established facts;
  - `journal/` — the campaign's scientific record, including unpublished results and
    literature notes;
  - `analyses/` — notebooks and figures built on real data;
  - `lib/` — vendored data loaders, which can encode lab/setup specifics.

**The enforceable gate.** The *craft* files must stay device-token-free — the skills, agents,
TEMPLATE, and hooks carry analysis discipline only. This is checked by grep, so it is
mechanical, not a matter of trust:

```sh
# Run from the repo root. Must print nothing.
grep -RInE 'M55D8|InAs|Josephson|\bVf\b|\bVt\b|R_Q|<other device tokens>' \
  .claude/ devices/TEMPLATE hooks/
```

Two files are deliberately outside this scan and may name the working device:
`CLAUDE.md`, whose "Active device" pointer *is* the swap point (it names the real device in
the working copy, `TEMPLATE` in the public skeleton), and `README.md`, which uses the device
as a documentation example. Neither carries device *content* — only the device *name*, which
is not sensitive; the private material is the profile, journal, analyses, and loaders under
`devices/<name>/`, which are never published.

If a device token appears in a *craft* file, that content is in the wrong layer: move it into
the device `profile.md`/`journal/`. The `!rule` protocol already routes new lessons
generic-vs-device for exactly this reason.

## Layout

```
CLAUDE.md                     # always-on rules + "active device" pointer (the SWAP POINT)
.claude/
  skills/
    analyze-run/              # the workhorse: analysis discipline + notebook workflow
      SKILL.md                #   incl. §10 directed mode (director/executor split)
      lessons.md              # generic operator-taught rules (grows via !rule)
    three-voices/             # isolated-context deliberation on a physics fork
      SKILL.md
  agents/
    analysis-executor.md      # directed-mode executor — hands, not head (pinned model)
    voice-skeptic.md          # three deliberation voices with distinct motives
    voice-pacifist.md
    voice-idealist.md
hooks/
  analyze_run_autoload.sh     # SessionStart hook: auto-loads analyze-run in a checkout
devices/
  M55D8/                      # working device (PRIVATE): Al/InAs Josephson junction array
    profile.md                # single source of device truth
    lessons.md                # device-taught rules + raw teaching archive
    lib/                      # vendored data loaders (qc_io.py, plotting.py) — standalone
    journal/                  # campaign state: open questions, dead ends, run memory,
                              #   background literature (Zotero-cited), data requests, SCHEMA
    analyses/                 # notebook deliverables (<topic>_<runids>/)
  TEMPLATE/                   # GENERIC skeleton for the next device (self-contained)
    profile.md
    journal/SCHEMA.md
jupytext.toml                 # .py percent files are source of truth; .ipynb is a view
```

## What the harness enforces

- **No presupposed findings.** Analyses start from the device picture and a list of ALL
  competing explanations — always including the mundane ones (thermalization, noise floor,
  calibration drift). A phase/effect may be named in a conclusion only when its
  discriminators pass and the alternatives are addressed. Target phenomena are defined only
  in the device profile, as hypotheses with proof requirements.
- **Data gaps become measurement requests**, not conclusions: if the discriminating data
  doesn't exist, the analysis writes a concrete sweep request to `journal/data_requests.md`
  and asks the scientist.
- **Show everything**: no cropping/masking of plotted data; every figure carries run ids;
  every fit is overlaid on the real data with residuals, stated windows, and uncertainties;
  every saved figure is visually read back before it is described.
- **Notebooks on request**: quick plots stay quick; "put this in the notebook" promotes work
  into an append-only Jupytext notebook that reproduces top-to-bottom.
- **Literature with receipts**: a background lane checks interpretive moves against the
  literature and records findings in `journal/background_literature.md` with verified
  citations (Zotero key + DOI).
- **Directed mode** (`analyze-run` §10): when the session runs a stronger model than the
  `analysis-executor` agent's pinned model, the session *directs* (owns all reasoning, reads
  every figure itself, holds the hypothesis list) and dispatches the executor to *compute*.
  The executor never chooses next steps or interprets; if its report contradicts a figure,
  the figure wins.
- **The scientist owns the conclusions.** Journal edits are proposed, then approved. The
  `!rule` protocol turns corrections into durable lessons, routed generic-vs-device.

## Using it

1. Clone (or copy `.claude/` + `CLAUDE.md` + `hooks/` + your device dir into a working folder
   that can see your data).
2. Point `CLAUDE.md` → "Active device" (the SWAP POINT) at your device directory.
3. (Recommended) Install the SessionStart hook so the discipline survives resume/compaction —
   see below.
4. Open Claude Code in that folder and talk: "plot R vs gate for run 530", "analyze the
   580–582 temperature family", "run three voices on <question id>", "!never do X".

### Installing the SessionStart hook

The hook injects the `analyze-run` skill body at every session start inside a harness
checkout, so a resumed or compacted session still has the rules. It hard-codes no path — it
walks up from the session cwd to the nearest `.claude/skills/analyze-run/SKILL.md`.

Register it in `~/.claude/settings.json` (global) or the project `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "startup|resume|clear|compact",
        "hooks": [ { "type": "command",
                     "command": "/ABSOLUTE/PATH/TO/measurement-harness/hooks/analyze_run_autoload.sh" } ] }
    ]
  }
}
```

## Adding a device

Copy `devices/TEMPLATE/` to `devices/<name>/`, fill in `profile.md` (data access & loader,
signal chain, knobs & hard limits, calibrations, established facts with provenance,
hypotheses under test with discriminators), seed the `journal/` from its `SCHEMA.md`, and
update the `CLAUDE.md` pointer. Vendor the device's data loader under `lib/`.

## Publishing the generic skeleton

To cut the public skeleton from this (private) working copy without leaking anything:

1. Work on a branch or a fresh clone — never publish the working copy directly.
2. Remove every real device: `git rm -r devices/<name>` for each real device (keep
   `devices/TEMPLATE/`).
3. Point `CLAUDE.md` → "Active device" at `devices/TEMPLATE/` (the SWAP POINT).
4. Run the grep gate above; it must print nothing. Fix any hit by moving that content into a
   device dir (which you are not publishing).
5. Push to the public repository.

Because the two copies share history, framework improvements flow between them with ordinary
git; only the device directories and the pointer line ever differ.
