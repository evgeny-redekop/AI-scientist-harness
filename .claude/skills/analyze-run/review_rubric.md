# Review rubric — the bar an analysis must clear

This file is the **single source of the bar**. It is passed verbatim to the
`analysis-reviewer` agent and is also read by the analyst, so the same standard shapes the work
and judges it. Device-agnostic: every device specific (units, calibrations, channel names,
loaders) arrives via the packet and the device profile, never from here.

The standard is **peer-review ready**. Slow but defensible beats fast and weak. An analysis that
cannot be brought to a defensible form is not presented as a caveated result — it goes to the
pipeline audit (§7).

---

## 1. Duty A — computation audit (every step, never lenient)

**This is the highest-value duty.** The scientist can catch a wrong headline claim; what he
cannot catch is a wrong constant buried in a cell. A defect here is a gap at the step it occurs,
regardless of how preliminary that step is. Read the **code and stdout**, not the figure.

Check, for every computational step:

- **Formulas.** Is the physics formula the right one, in the right form, for what is being
  computed — parallel vs series combination, subtraction of a background or parallel channel,
  reciprocals, geometric factors, per-element vs whole-array quantities? Re-derive it; do not
  accept it because it looks familiar or a comment says it is right.
- **Normalization and units.** Every constant, gain, divider, and conversion: applied once,
  in the right direction, to the right channel. Flag anything applied twice, applied to a
  quantity already in the target unit, or inverted.
- **Axis quantity vs axis label.** Does the label name the quantity the code actually computed?
- **Masking, filtering, and cuts.** Any mask, threshold, drop, or restriction of the data —
  is it justified from a measured noise floor, and is it a fit window rather than a silent
  removal? Masking that quietly drops data is a gap even if the figure looks clean.
- **Offsets and zeros.** Self-measured or inherited? Applied to the channel the fit actually
  consumes? Right parity of method for the observable?
- **Fit mechanics.** Window stated; exclusions stated; parameters carry uncertainties; the
  window covers the physically discriminating region. Quality carries **both** a number and a
  written reading of the drawn fit; a number standing alone is a gap, and so is an unrecorded
  impression. Where the two disagree the figure decides, and a fit whose number looks
  respectable while the curve contradicts the data is a gap however good the χ². A visible
  discrepancy must be **reconciled, not merely disclosed**: the analyst adjusts the window or the
  model until figure and number agree and records that change, or states that the two could not be
  reconciled and withdraws the number as a result. A step that reports the disagreement, keeps the
  window, and still quotes the fitted value as a result is a gap.
- **Interpolation.** Flagged, with bracketing measured points given.
- **Metadata access.** Setpoints read from each dataset's own metadata, indexed so a missing key
  raises rather than silently yielding a default/NaN that propagates.
- **Reduction discipline.** No moment-statistics standing in for physics; no averaging of a
  quantity that is then plotted on an axis.
- **Sanity.** Does any derived number contradict what is plainly visible in the data? If an
  algorithm disagrees with the obvious structure, the algorithm is suspect.

## 2. Duty B — figure/claim review (staged)

Staging governs **presentation completeness only**. It never softens Duty A.

- **INTERMEDIATE** (the analyst does not claim the analysis is finished): judge only whether the
  figure credibly does what *this step* claims — real structure, mechanically sound (axes, units,
  labels, no blank panels, no rendering artifact), not leading with descriptive statistics.
  Criteria belonging to the finished key figure are out of scope. **Default to pass.**
- **KEY** (presented as the analysis result, or any stated conclusion): enforce the **full
  rubric**. This is where strictness belongs.

**Three defects are gaps even at INTERMEDIATE stage**, because the step then does not do what it
claims: (1) a conclusion generalized beyond the single dataset/cut shown; (2) cropped, masked, or
filtered data, or a fit not overlaid on the real unmasked data; (3) a quantity extracted per curve
(fit parameter, peak position, width, edge, threshold crossing) plotted as a trend without a
preceding step that draws the extraction on the raw curves at several values of the control
parameter, or plotted against a derived/theory-side abscissa before its dependence on the directly
swept knob has been shown.

## 3. Always-included criteria (every objective)

1. **Robustness within a dataset** — the claim survives the choices made *inside* each dataset:
   different cuts, fit windows, sub-ranges, branches. "It appears in dataset N" is not
   robustness; showing it does not move when those choices move is.
2. **Consistency across datasets** — checked against every dataset that bears on it, with
   **where it holds and where it breaks** stated explicitly.
3. **Show everything** — nothing cropped, cut, clipped, masked, or noise-floor-filtered unless
   the operator asked; any fit-window mask is marked on the figure and the fit overlaid on
   unmasked data.
   The rule itself is in `lessons.md` under Data integrity; this is the check.
4. **Record what was left out** — which runs, ranges, and regimes were used, which were excluded,
   and why. This is what lets a later audit re-open the choice instead of inheriting it.
5. **Run/dataset ids and clear axis labels** on every figure.
6. **Independence** — corroborating checks must not share a hidden assumption (same calibration,
   same anchor, same noise floor). Two checks sharing one are **one check**.

## 4. Rubric generation (per analysis)

**Only after the data has been loaded and the uncropped overview actually looked at** — a rubric
drafted before seeing the data grades an imagined analysis. Then draft **4–7 concrete, checkable,
physics-first criteria** for what the key figure(s) of *this* objective must show, from: the
objective, the analysis shape (single-extraction vs family-comparison), the run metadata, the
overview figure, and the accumulated lessons files (weight taught lessons highly).

Return a markdown checklist, one `- [ ]` per criterion, no preamble. The always-included criteria
of §3 are appended to every rubric. **The drafted rubric goes to the scientist for approval or
edit before analysis proceeds**, then into both the analysis plan and the reviewer packet.

## 5. Verdict ladder

Every claim carries exactly one rung, plus the observation that would demote it. **"Consistent
with X" is not a verdict.**

| Rung | Requirement |
|---|---|
| **established** | discriminators pass; every live alternative explicitly addressed; robust within and consistent across all datasets in scope |
| **supported** | robust within and consistent across all datasets in scope; ≥1 live alternative remains, and is named |
| **suggestive** | holds in a subset only, or robustness untested; the missing check/data is named |
| **unsupported** | rests on a single comparison, or a live mundane alternative is unaddressed |

Only **established** and **supported** may be presented as results. Anything lower is an open
thread, reported with its blocking gap.

## 6. Coverage table

Mandatory for any claim. One row per dataset in scope:

| dataset | supports | contradicts | n/a | NOT EXAMINED |
|---|---|---|---|---|

Any `NOT EXAMINED` row **caps the verdict at *suggestive***. The point is to make an omission
visible instead of letting it hide in prose.

## 7. Duty C — pipeline audit (when the bar cannot be met)

Triggered when a claim fails the bar and figure-level fixes will not close the gap. **Do not
report "not defensible" yet.** The usual cause is that the analysis is being refined *inside* a
badly-chosen data scope, because the runs, range, and regime were picked first and thereafter
treated as fixed.

**The perturbation numbers arrive with the packet.** Moving the fit window and the seeds is the
analyst's job, done before you are called (`SKILL.md` §5). You judge the reported numbers; you do
not re-run them. If they are absent, that absence is itself a gap.

1. **Reconstruct the chain**, raw data → claim, written out explicitly: datasets used and
   excluded; ranges, regimes, working points; every reduction, mask, and fit window; every
   calibration/zero/gain and whether it was self-measured or inherited; every model or formula
   **and the domain of validity it was borrowed with**; the inference step from number to claim.
2. **Judge the chain, not the figure.** Work through it item by item, asking two questions of
   each: how much does the claim depend on this, and how well is it justified? The item most
   depended on and least justified is the weak point. Start with the data-scope items, chosen
   earliest and questioned least.
3. **Only if the audit comes up empty**: report not-yet-defensible, delivering the pipeline table,
   the identified weak link, and a concrete `journal/data_requests.md` entry for the measurement
   that would close it, folded together with any other open question whose discriminator needs a
   similar sweep. Never a softened claim.

## 8. Output contract

Gaps are **numbered** so a subset can be endorsed or dismissed. Computation gaps (Duty A) are
listed first and marked, because they matter most.

**Order gaps by dependence × justification**: how much the claim depends on what the gap names,
times how poorly that is justified. Report them in that order, computation gaps first within it.
Raise as many as you find; the ordering is what makes a long list usable.

```
VERDICT: pass | fail        STAGE: intermediate | key
COMPUTATION GAPS
  A1. <specific, actionable — what is wrong, where, and why it matters>
FIGURE GAPS
  B1. <specific, actionable>
STRONGEST CASE AGAINST THE CLAIM: <one paragraph>
```

Empty gap lists are the expected outcome of a clean step; say so plainly rather than inventing
something to report.

## 9. Rebuttal rules

- The reviewer scores **blind** first: figure + objective + rubric, never the analyst's narrative
  or preferred reading. Independence comes from that blind pass.
- The analyst answers with **one line per gap, no exceptions**, in this exact format:
  `GAP A1: ACCEPT — <how it will be fixed>` or
  `GAP A2: CONTEST — <line N of file X> <quoted value or formula> <why the reviewer misread it>`.
  **A gap must be CONTESTed if the code already handles it correctly** — conceding a gap raised
  against correct code is an error, not a safe default.
- The reviewer **rejects** a rebuttal that lacks a `GAP X:` line for any gap it raised, and
  re-requests before reconsidering anything.
- On reconsideration the reviewer additionally receives the analyst's reading, the reply, and the
  **code and stdout** as backing. A `CONTEST` holds only if the code/stdout actually shows it.
- **Drop or narrow a gap only for a correct, specific data/physics reason.** Never for a bare
  disagreement, an appeal to authority, or a promise to fix it later. The reviewer keeps the last
  word; it concedes only to a correct reason.
- On reconsideration the reviewer may add **at most one** new gap, and only a concrete
  computational error the image hides — never a style or aesthetic point.
- **A clean pass skips the rebuttal entirely.**
- Reviewer malfunction (unparseable output, tool failure) **fails open** — proceed and say so
  loudly. A substantive failure never fails open.
