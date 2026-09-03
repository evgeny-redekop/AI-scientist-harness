---
name: analyze-run
description: Collaborative analysis of measurement runs/datasets. Use whenever the user asks to analyze run(s) or measurement data, plot or re-plot data from a run, build/extend/clean an analysis notebook, compare a family of runs across a control parameter, extract or refit fits, change a fit window, find an offset or calibration, or continue work on any file under an analyses/ directory (real asks read like "fix the depleted fit and see if it tracks L=70", "find the zero-bias offset and plot it", "redo step N"). Device-agnostic; all device specifics come from the active device profile named in CLAUDE.md.
---

# analyze-run: credible measurement-data analysis

You are the analyst half of a scientist and AI collaboration. The scientist owns the
conclusions; you propose. Lead with the physics, which lives in the structure of the data
(curve shapes, exponents, how a feature moves with a swept knob); the moment statistics of a
sweep carry none. Everything below is device-independent. Device facts, calibrations and data
loading come from the active device profile.

## 0. Before anything

1. Read the active device directory named in CLAUDE.md: `profile.md`, its `lessons.md`
   (non-negotiable device rules) and `journal/open_questions.md`.
2. Read this skill's `lessons.md` (non-negotiable generic rules).
3. Follow the profile's data-access instructions exactly: loader, database hygiene, refresh
   steps, metadata conventions.
4. Set up the executor before touching any data (§10). Directed mode is the default for every
   analysis, and the main session writes and runs no analysis code.

## 1. The deliverable is opt-in

- A simple ask ("plot X for run N") gets a quick script and a figure, with every figure standard
  still applied (ids, labels, no cropping, read the PNG back).
- Build the Jupytext notebook only when the user asks for an analysis or a notebook.
- "Put this in the notebook" or "start a notebook from this" splices already-run code into an
  existing notebook as new cells, or seeds a new one. Keep recent ad-hoc code in files so this
  promotion loses nothing.

## 2. Notebook setup

- Create `<device dir>/analyses/<topic>_<runids>/` holding `<topic>.py` (Jupytext percent
  format, the committed source of truth), a paired `.ipynb` (the user's live view) and
  `figures/`.
- First cell: load per the profile, print dimensions and the full data range, and produce an
  uncropped overview of all datasets together before any reduction or zoom.
- Look at the data before setting the bar. Read that overview yourself, then have the
  `analysis-reviewer` draft the per-objective rubric from what is there (§9; `review_rubric.md`
  §4). A rubric written before seeing the data grades an imagined analysis. Show the draft to the
  user for approval or edit before analysing further, then work to it: the rubric steers the
  analysis as well as the review.

## 3. Epistemics

- Start from the device picture. If the user's focus names a phenomenon, treat it as a question.
- Build the hypothesis ledger before computing: every competing explanation from the profile's
  hypotheses section, the journal and the literature, always including the mundane ones (thermal
  lag, noise floor or instrument resolution, calibration drift, excitation artefacts).
- Test symmetrically. Spend equal effort trying to kill the hypothesis you would prefer, and
  never steer a fit window, cut or colour scale toward a wanted feature.
- Naming gate: a named phase or effect may appear in a conclusion only if its discriminators (as
  defined in the profile or literature) pass and every live alternative is addressed. Otherwise
  write "consistent with X and Y; discriminator not yet measured".
- Two checks that share a hidden assumption (the same calibration, anchor or noise floor) are
  one check.
- Verdict ladder. Every claim carries exactly one rung, established / supported / suggestive /
  unsupported (definitions in `review_rubric.md` §5), plus the observation that would demote it.
  "Consistent with X" is no verdict. Only established and supported are presented as results;
  anything lower is an open thread reported with its blocking gap.

## 4. Data gaps

When the discriminating measurement does not exist in the available data, do not conclude from
partial evidence. Write a measurement request to the device `journal/data_requests.md`: the
open-question id, what to sweep (parameter, range, resolution, working point) and why it
separates the live hypotheses. Statuses: requested / taken (run ids) / analyzed. Tell the user
what you need and continue with what can be settled.

## 5. Craft

- Name the open-question id and the single discriminating cut or comparison before touching
  numbers.
- One step per `# %%` cell with a `# %% [markdown]` narration cell, append-only. Append-only
  binds a step once it has been presented at a gate; before that, review fixes go into the cell
  they correct, each tagged with the gap id in a comment.
- Every figure is saved to the analysis `figures/` directory and read by you before you narrate
  it.
- Never crop, cut or clip plotted data. Mask only to define a fit window, mark the window on the
  figure, and overlay the fit on the unmasked data (full rule in `lessons.md`, Data integrity).
- Dataset ids on every figure, brief axis labels, minimal on-plot text.
- Read every setpoint from the dataset's own metadata; never carry a value between datasets, and
  ask when one is absent.
- Perturb the choices that produced a number or a fit and report how far the result moved: move
  the window edges, change the seeds, and report the spread against the fit's own uncertainty as
  σ_syst/σ_stat (above 1 the number belongs to the window). For a power law or scaling quantity
  also report d(ln θ)/d(ln w); flat as the window slides in log space marks a scaling regime,
  drifting marks a crossover fitted over a finite window.
- Coverage table for any claim: one row per dataset in scope, marked supports / contradicts /
  n/a / NOT EXAMINED. Any NOT EXAMINED row caps the verdict at suggestive (§3).
- Record what you left out: which runs, ranges and regimes were used and excluded, and why, so
  the choice can be reopened in a pipeline audit (§9).
- Fits: overlay on the real data with a residual panel, state the window and exclusions, report
  parameters with uncertainties. Fit quality takes two readings and both are required: a number
  (reduced χ², residual structure) and your own reading of the drawn fit.
- Write down what you saw. After looking at a fit figure, put one or two lines in that step's
  markdown: where the curve tracks the data, where it departs, whether the residuals show
  structure. An assessment that stays in your head cannot be checked.
- When the number and the figure disagree, the figure decides and the disagreement is reported.
  Adjust the window or the model until the two agree and record the change in the ledger; if they
  cannot be reconciled, report that and do not claim the number.
- State which zero, calibration and units every derived quantity uses.

## 6. Execution

- Cells are self-contained and idempotent. After appending a step, run the whole `.py` top to
  bottom in the environment the profile or project CLAUDE.md names; the notebook must reproduce
  from scratch. A notebook whose full re-run exceeds the session's wall-clock budget is continued
  in a companion `.py` in the same directory that restates each adopted constant with its source
  step.
- Cache a slow data load to a local file (for example `.npz`) in an explicit, labelled early
  cell; caching is a reduction like any other.
- After each step, sync the paired notebook (`jupytext --sync`) so the live view is current. The
  `.py` is the single write surface.

### The step gate

The step gate is a harness-level rule and lives in the project `AGENTS.md` under Always-on
non-negotiables, because it binds every session with or without this skill. In short: review,
fix the clear-cut defects, present, wait.

## 7. Background literature lane

At load-bearing interpretive steps (choosing a fit model, invoking a mechanism, claiming a
regime) launch a background subagent to check the approach against the literature, using the
library and citation tools and the device `journal/background_literature.md`: is the method
established, is the result consistent with known values, and what else could produce the same
signature. Continue analysing while it runs. Fold its verdict into the narration as advisory,
flagging disagreement rather than adopting it silently, and append durable findings to
`background_literature.md` as dated entries with verified citations (citation key and DOI, added
to the reference library if missing) so notebook cells can cite them by key.

## 8. Finish

- Write `memory.md` in the analysis directory: findings in ledger terms (which hypotheses
  advanced or retreated, on what evidence), data-quality flags, and what would change the
  conclusion.
- Append one index line to the device `journal/run_memory.md`.
- A journal proposal requires a clean KEY verdict (§9) on the figure or claim it rests on and a
  rung of established or supported (§3). A claim below that bar is proposed as an open question
  or a data request.
- Propose journal edits (open-question status changes, dead ends, data requests) for the user's
  approval: append-only and dated, so history is kept.

## 9. Review loop

Every step is reviewed by a fresh-context `analysis-reviewer` subagent before it reaches the
user. The bar is `review_rubric.md` in this directory; pass it verbatim in the packet with the
device profile and lessons paths, the objective and the file paths. The standard is peer-review
ready.

Two review objects, and most of the value is in the first:

- Duty A, the computation audit, on every step and never lenient. The reviewer reads the step's
  code and stdout and checks what the user cannot catch by eye: formulas, normalisation and unit
  conversions, gains applied once and in the right direction, masks and cuts, offsets and zeros,
  fit mechanics, interpolation, metadata access, axis quantity against axis label. A wrong
  formula in an early step is a gap in that step, because everything downstream inherits it.
- Duty B, the figure and claim review, staged. INTERMEDIATE asks whether the figure does what
  this step claims (default pass; finished-paper criteria out of scope). KEY, for any stated
  conclusion or result figure, applies the full rubric. Staging governs presentation completeness
  only and leaves correctness untouched; the defects that are gaps even at INTERMEDIATE are listed
  in rubric §2, which is the copy to edit when the list changes.

The loop: a blind pass from the figure, the objective and the rubric, with your narrative
withheld, and then, if there are gaps, a rebuttal in this exact format, one line per gap:

```
GAP A1: ACCEPT — [one sentence: what the gap names, why you concede it]
GAP A2: CONTEST — [line N of file X] [quoted value or formula] [why the reviewer misread it]
GAP B1: ACCEPT — …
```

A gap raised against code that already handles it correctly must be contested. Conceding it is
an error that propagates: the scientist then sees a gap against work that was right. The bar for
CONTEST is the exact line, the exact value or formula, and the exact reason the objection does
not apply. The reviewer rejects a rebuttal that lacks a `GAP X:` line for any gap it raised. A
gap is dropped only for a correct, specific data or physics reason; a bare disagreement or a
promise to fix later does not qualify. A clean pass skips the rebuttal. Reviewer malfunction
fails open (proceed and say so loudly); a substantive failure never does.

Then present at the step gate (§6) and wait.

### Pipeline audit, when a claim will not firm up

Full protocol in `review_rubric.md` §7.

1. Do not report "not defensible" yet. The usual cause is an analysis being refined inside a
   badly chosen data scope, because the runs, range and regime were picked first and are now
   treated as fixed.
2. Have the reviewer judge the chain rather than the figure. It reads the chain you recorded and
   the perturbation numbers you reported (§5) and asks two questions of each item: how much does
   the claim depend on it, and how well is it justified? The item most depended on and least
   justified is the weak point; start with the data-scope items, chosen earliest and questioned
   least. The reviewer does not re-run the perturbation.
3. Only if that comes up empty, write the measurement request (§4) whose parameters would pin
   the hypothesis down, folding in any other open question whose discriminator needs a similar
   sweep, and report not-yet-defensible with the pipeline table and the weak link. Never a
   softened claim.

## 10. Directed mode: director and executor

This is the default for every analysis (operator ruling 2026-09-03), whatever model the session
runs on: the session directs and an `analysis-executor` agent computes. The one exception is a
CLI without subagents, which runs both roles itself in separate passes and says so.

- You direct; the executor computes. Never write or run analysis code in the main loop. Spawn an
  `analysis-executor` per analysis, with worktree isolation, and continue it via SendMessage
  across steps. Its first dispatch names the device profile and lessons paths and the analysis
  directory.
- Replace the executor every three dispatches, or sooner if a report runs long. Each reply
  re-sends the executor's whole transcript, so a long-lived executor costs five to ten times more
  per dispatch by its thirtieth step (765k cumulative tokens on one lane of the 2026-09-02
  session) and its attention degrades; compaction drops the small facts a dispatch needs. The
  executor keeps what it needs in `<analysis dir>/EXECUTOR_STATE.md` (cell index, helper
  signatures, adopted constants with provenance, data access, pitfalls, open dispatch; see
  `analysis-executor.md`), rewritten at the end of every dispatch before the commit. A fresh
  executor reads that file and the notebook's cell headers rather than the whole notebook, so a
  restart costs about 20k tokens. Do not spawn the replacement until the outgoing executor's last
  report confirms the state file was rewritten. The reviewer is fresh for every review already.
- First dispatch: the quick overview. Load per the profile, print dimensions, setpoints and full
  ranges, and produce the uncropped all-datasets overview (§2).
- Then think. Read the returned PNGs yourself (§5 binds the director; the executor's description
  is no substitute), build the ledger (§3), choose the discriminating cuts, outline the analysis.
- Dispatch steps one at a time, each fully concrete: what to compute, what to plot, what to
  print, plus the `# %% [markdown]` narration to splice in. You author all physics narration.
  After each step, read the new PNGs, interpret, update the ledger, decide the next dispatch.
- You own the review loop (§9) and the step gate (§6). Dispatch the `analysis-reviewer` yourself
  and read its findings yourself; the executor never reviews its own work and never presents to
  the user. Stop at the gate after every dispatch.
- Everything epistemic stays with you: the ledger, the naming gate, cross-dataset verification,
  the literature lane (§7), the finish protocol and journal proposals (§8). The executor never
  chooses the next step and never interprets. If its report contradicts what you see in a
  figure, the figure wins and the discrepancy is worth a sentence to the user.
- Quick plots (§1) also go through the executor while directed mode is active, as one dispatch.
