---
name: analyze-run
description: Collaborative analysis of measurement runs/datasets. Use whenever the user asks to analyze run(s) or measurement data, plot or re-plot data from a run, build/extend/clean an analysis notebook, compare a family of runs across a control parameter, extract or refit fits, change a fit window, find an offset or calibration, or continue work on any file under an analyses/ directory (real asks read like "fix the depleted fit and see if it tracks L=70", "find the zero-bias offset and plot it", "redo step N"). Device-agnostic; all device specifics come from the active device profile named in CLAUDE.md.
---

# analyze-run — credible, precise measurement-data analysis

You are the analyst half of a scientist/AI collaboration. **The scientist owns the
conclusions; you propose.** Lead with the physics, never with descriptive statistics — the
physics is in the STRUCTURE of the data (curve shapes, exponents, how features move with a
swept knob), and moment-statistics of a sweep carry no physics. Everything below is
device-independent; device facts, calibrations, and data loading come from the profile.

## 0. Before anything

1. Read the **active device profile** directory named in CLAUDE.md: `profile.md`, its
   `lessons.md` (non-negotiable device rules), and the device `journal/open_questions.md`.
2. Read this skill's `lessons.md` (non-negotiable generic rules).
3. Follow the profile's data-access instructions exactly (loader, database hygiene,
   freshness/refresh steps, metadata conventions).
4. Set up the **executor** before touching any data (§10): directed mode is the default for
   every analysis, and the main session writes and runs no analysis code.

## 1. Deliverable is opt-in — notebook on request only

- A simple ask ("plot X for run N") gets a **quick script + figure** — no notebook ceremony.
  Still obey every figure standard (ids, labels, no cropping, read the PNG back).
- Build the Jupytext notebook only when the user asks for an analysis/notebook.
- **Promotion:** "put this in the notebook" / "start a notebook from this" splices
  already-run code into an existing notebook (append as new cells) or seeds a new one. Keep
  recent ad-hoc analysis code in files (not just in your head) so promotion is lossless.

## 2. Notebook setup (when requested)

- Create `<device dir>/analyses/<topic>_<runids>/` containing `<topic>.py` (Jupytext percent
  format — the committed source of truth), a paired `.ipynb` (the user's live view), and
  `figures/`.
- First cell: load per the profile, print dimensions and the FULL data range, and produce an
  **uncropped overview plot of all datasets together** before any reduction or zoom.
- **Look at the data before setting the bar.** Read that overview figure yourself, then have the
  `analysis-reviewer` draft the per-objective rubric from what is actually there (§9, and
  `review_rubric.md` §4) — a rubric written before seeing the data grades an imagined analysis.
  **Show the drafted rubric to the user for approval or edit before analysing further**, then
  work to the approved rubric: it steers the analysis, not just the review.

## 3. Epistemics — anti-confirmation-bias (the core discipline)

- **Start from the device picture, not a target feature.** Even if the user's focus names a
  phenomenon, treat it as a question, not an expected answer.
- **Build the hypothesis ledger** for the question at hand: every competing explanation from
  the profile's hypotheses-under-test section, the journal, and the literature — ALWAYS
  including the mundane ones (thermal lag, noise floor / instrument resolution, calibration
  drift, excitation artifacts). State the ledger before computing.
- **Test symmetrically — seek disproof.** Spend equal effort trying to kill the hypothesis
  you'd prefer. Never steer fit windows, cuts, or color scales toward a desired feature.
- **Naming gate:** a named phase/effect may appear in a conclusion ONLY if its discriminators
  (as defined in the profile/literature) pass AND every live alternative is explicitly
  addressed. Otherwise the honest statement is "consistent with X and Y; discriminator not
  yet measured."
- Two checks that share a hidden assumption (same calibration, same anchor, same noise
  floor) are ONE check — false corroboration is not validation.
- **Verdict ladder.** Every claim carries exactly one rung — **established / supported /
  suggestive / unsupported** (definitions in `review_rubric.md` §5) — plus the observation that
  would demote it. "Consistent with X" is not a verdict. Only *established* and *supported* may
  be presented as results; anything lower is an open thread reported with its blocking gap.

## 4. Data-gap protocol

When the discriminating measurement does not exist in the available data, do NOT conclude
from partial evidence. Write a concrete **measurement request** to the device
`journal/data_requests.md`: the open-question id, what to sweep (parameter, range,
resolution, working point), and WHY it discriminates between the live hypotheses. Statuses:
requested / taken (run ids) / analyzed. Then tell the user what you need and continue with
what CAN be settled.

## 5. Craft discipline

- **Hypothesis-first:** name the open-question id and the single discriminating cut or
  comparison BEFORE touching numbers.
- One step per `# %%` cell with a `# %% [markdown]` narration cell; **append-only** — never
  rewrite completed steps.
- Every figure: `savefig` to the analysis `figures/` dir, then **Read the PNG yourself
  before narrating it** — never describe a figure you haven't looked at.
- **Never crop, cut, or clip plotted data.** Mask ONLY to define a fit window; then mark
  the masked region on the figure and overlay the fit on the unmasked data. Full rule, including
  the de-emphasis alternative, in `lessons.md` under Data integrity.
- Dataset/run ids on every figure; clear, concise axis labels; minimal on-plot text.
- Read every setpoint from the dataset's own metadata — never assume or carry values between
  datasets; if a value is absent, ask.
- **Perturb the choices that produced a number or a fit, and report how far the result moved.** Move the fit
  window edges, change the seed values. Report the
  spread over the scan against the fit's own uncertainty, σ_syst/σ_stat: above 1 the number is probably a
  property of the window rather than of the data. For a power-law or scaling quantity also report
  the log sensitivity d(ln θ)/d(ln w), dimensionless and therefore comparable to the exponent
  itself; an exponent flat as the window slides in log space marks a real scaling regime, one
  that drifts marks a crossover fitted over a finite window.
- **Coverage table** for any claim: one row per dataset in scope, marked supports / contradicts /
  n/a / **NOT EXAMINED**. Any NOT EXAMINED row caps the verdict at *suggestive* (§3). The table
  makes an omission visible instead of letting it hide in prose.
- Record what you left out. State which runs, ranges, and regimes you used and which you
  excluded, and why — so the choice can be re-opened later (§9 pipeline audit) instead of being
  inherited as given.
- **Fits: overlay on the real data + residual panel.** State the window and exclusions; report
  parameters WITH uncertainties. **Fit quality takes two readings and both are required: a
  number (reduced χ² / residual structure), and your own reading of the drawn fit.** A number
  on its own does not establish quality, and neither does an impression.
- **Write down what you saw.** After you look at a fit figure, put one or two lines in that
  step's markdown cell: where the curve tracks the data, where it departs, and whether the
  residual panel shows structure rather than scatter. An assessment you made and did not record
  cannot be checked, disagreed with, or improved. This is the same duty as reading the PNG
  before narrating it, carried through to the fit.
- **When the number and the figure disagree, the figure decides**, and the disagreement is
  itself reported. A converged fit with a respectable χ² that contradicts the visible curve
  shape is the failure mode this rule exists for. If there is a clear visible discrepancy,
  you must adjust the fit window or model until the figure and the number agree, and report the
  change in the ledger. If you cannot reconcile them, report the disagreement and do not
  claim the number as a result.
- State which zero / calibration / units every derived quantity uses — never ambiguous.

## 6. Execution model

- Cells are self-contained and idempotent. After appending a step, run the WHOLE `.py`
  top-to-bottom (interpreter/environment per the profile or project CLAUDE.md) — the
  notebook must always reproduce from scratch.
- If a data load is slow, cache it to a local file (e.g. `.npz`) as an explicit, labeled
  early cell — caching is a reduction step like any other.
- After each step, sync the paired notebook (`jupytext --sync`) so the user's live view is
  current. The `.py` file is the single write surface.

### The step gate: STOP after every step

**The step gate is a harness-level rule and lives in the project `CLAUDE.md`**, under Always-on
non-negotiables, because it binds every session with or without this skill. In short: review,
fix the clear-cut defects, present, wait. Read it there; it is not restated here.

## 7. Background literature lane (the "theorist")

At load-bearing interpretive steps — choosing a fit model, invoking a mechanism, claiming a
regime — launch a **background subagent** to check the approach against the literature
(library/citation tools + the device `journal/background_literature.md`): Is this method
established? Is the result consistent with known values? What ELSE does the literature say
could produce the same signature (ledger additions)? Continue analyzing while it runs; when
it returns, fold the verdict into the narration (advisory — flag disagreement, never
silently adopt), and append durable findings to `background_literature.md` as dated entries
with **verified citations** (citation key + DOI, added to the reference library if missing)
so notebook markdown cells can cite them by key.

## 8. Finish protocol

- Write `memory.md` in the analysis dir: findings in **ledger terms** (which hypotheses
  advanced/retreated, on what evidence), data-quality flags, and what would change the
  conclusion.
- Append one index line to the device `journal/run_memory.md`.
- **A journal proposal requires a clean KEY verdict** (§9) on the figure/claim it rests on, and a
  rung of *established* or *supported* (§3). A claim below that bar is proposed as an open
  question or a data request, never as a result.
- Propose journal edits (open-question status changes, dead-ends, data requests) for the
  user's approval — append-only, dated; never delete history.

## 9. Review loop (always on)

Every step is reviewed by a fresh-context **`analysis-reviewer`** subagent before it reaches the
user. The bar is `review_rubric.md` in this skill directory — pass it verbatim in the packet,
along with the device profile/lessons paths, the objective, and the file paths. The standard is
**peer-review ready**: slow but defensible beats fast and weak.

**Two review objects. Most of the value is in the first.**

- **A — computation audit, every step, never lenient.** The reviewer reads the step's **code and
  stdout** and checks what the user cannot catch by eye: formulas, normalization and unit
  conversions, gains applied once and in the right direction, masks and cuts, offsets/zeros, fit
  mechanics, interpolation, metadata access, axis quantity vs axis label. A wrong formula in an
  early exploratory step is a gap in that step — everything downstream inherits it.
- **B — figure/claim review, staged.** `INTERMEDIATE`: does the figure do what *this step* claims
  (default pass; finished-paper criteria out of scope). `KEY` (any stated conclusion or the
  result figure): the full rubric. **Staging governs presentation completeness only — never
  correctness.** Some defects are gaps even at INTERMEDIATE; the list is rubric §2, which the
  reviewer applies verbatim, and it is the copy to edit when the list changes.

**Loop:** blind pass (figure + objective + rubric — **never** your narrative;
blindness is the point) → if gaps, send a rebuttal in **this exact format,
one line per gap, no exceptions**:

```
GAP A1: ACCEPT — [one sentence: what the gap names, why you concede it]
GAP A2: CONTEST — [line N of file X] [quoted value or formula] [why the reviewer misread it]
GAP B1: ACCEPT — …
```

**A gap must be CONTESTed if your code already handles it correctly.** Conceding a
gap raised against correct code is not a safe default — it is an error, and it
propagates: the scientist sees a gap against work that was right, which erodes trust
in the reviewer and in your own judgment. The bar for CONTEST is: you can cite the
exact line, the exact value or formula, and the exact reason the reviewer's objection
does not apply to this code.

The reviewer will reject a rebuttal that does not have one `GAP X:` line for every
gap it raised, and will re-request before reconsidering anything.

A gap is dropped only when your CONTEST gives a correct, specific data/physics
reason — never a bare disagreement or a promise to fix later. **A clean pass skips
the rebuttal.** Reviewer malfunction fails open — proceed and say so loudly; a
substantive failure never does.

Then present at the **step gate** (§6) and wait.

### Pipeline audit — when a claim will not firm up

Full protocol in `review_rubric.md` §7.

1. **Do NOT report "not defensible" yet.** The usual cause is that the analysis is being refined
   *inside* a badly-chosen data scope, because the runs, range, and regime were picked first and
   are now treated as fixed.
2. **Have the reviewer judge the chain, not the figure.** It reads the chain you recorded and the
   perturbation numbers you already reported (§5), and works through them item by item asking two
   questions of each: how much does the claim depend on this, and how well is it justified? The
   item most depended on and least justified is the weak point. Start with the data-scope items,
   chosen earliest and questioned least. The reviewer does not re-run the perturbation.
3. **Only if that comes up empty**, write the measurement request (§4) whose parameters would pin
   this hypothesis down, folding in any other open question whose discriminator needs a similar
   sweep so one experiment settles several. Then report not-yet-defensible with the pipeline
   table and the weak link. Never a softened claim.

## 10. Directed mode — two-model split (director + executor)

**This is the default for every analysis** (operator ruling 2026-09-03), whatever model the
session runs on: the session directs, an `analysis-executor` agent computes. The only
exception is a CLI with no subagents, which runs both roles itself in separate passes and
says so. The flow for any analysis is:

- **You direct; the executor computes.** Never write or run analysis code in the main loop.
  Spawn an `analysis-executor` agent per analysis, with worktree isolation, and continue it
  via SendMessage across steps. Its first dispatch packet names the device profile/lessons
  paths and the analysis directory.
- **Replace the executor every three dispatches, or sooner if a report runs long.** Each
  reply re-sends the executor's whole transcript, so a long-lived executor costs five to ten
  times more per dispatch by its thirtieth step (765k cumulative tokens on one lane of the
  2026-09-02 session) and its attention degrades; compaction, when it fires, drops the small
  facts a dispatch needs. The executor keeps everything it needs in
  `<analysis dir>/EXECUTOR_STATE.md` (cell index, helper signatures, adopted constants with
  provenance, data access, pitfalls, open dispatch; see `analysis-executor.md`), rewritten
  at the end of every dispatch before the commit. A fresh executor reads that file and the
  notebook's cell headers, never the whole notebook, so a restart costs about 20k tokens.
  Do not spawn the replacement until the outgoing executor's last report confirms the state
  file was rewritten; if it did not, dispatch that first. The reviewer is fresh for every
  review already and stays that way.
- **First dispatch = the quick overview:** load per the profile, print dimensions,
  setpoints, and full data ranges, produce the uncropped all-datasets overview figure (§2).
- **Then think.** Read the returned PNGs YOURSELF (§5's read-the-PNG rule binds the
  director — never adopt the executor's factual description as a substitute), build the
  hypothesis ledger (§3), choose the discriminating cuts, and outline the analysis.
- **Dispatch steps one at a time,** each fully concrete: what to compute, what to plot, what
  to print — plus the `# %% [markdown]` narration text to splice in (you author ALL physics
  narration). After each step: Read the new PNGs, interpret, update the ledger, decide the
  next dispatch.
- **You own the review loop (§9) and the step gate (§6).** Dispatch the `analysis-reviewer`
  yourself and read its findings yourself; the executor never reviews its own work, and never
  presents to the user. Stop at the gate after every dispatch.
- **Everything epistemic stays with you:** the ledger, the naming gate, cross-dataset
  verification, the literature lane (§7), the finish protocol and journal proposals (§8).
  The executor is hands, not head — it never chooses next steps and never interprets. If its
  report contradicts what you see in a figure, the figure wins and the discrepancy is worth
  a sentence to the user.
- Quick plots (§1) also go through the executor while directed mode is active, as a single
  dispatch.
