# Review rubric: the bar an analysis must clear

This file is the single source of the bar. It is passed verbatim to the `analysis-reviewer`
agent and read by the analyst, so one standard shapes the work and judges it. It is
device-agnostic: units, calibrations, channel names and loaders arrive through the packet and
the device profile.

The standard is peer-review ready. An analysis that cannot be brought to a defensible form is
never presented as a caveated result; it goes to the pipeline audit (§7).

---

## 1. Duty A: computation audit (every step, full strictness)

This is the highest-value duty. The scientist can catch a wrong headline claim; a wrong constant
buried in a cell escapes him. A defect here is a gap at the step it occurs, however preliminary
the step. Read the code and stdout rather than the figure.

Check, for every computational step:

- **Formulas.** The right physics formula in the right form for what is computed: parallel
  against series combination, subtraction of a background or parallel channel, reciprocals,
  geometric factors, per-element against whole-array quantities. Re-derive it rather than
  accepting a familiar shape or a comment.
- **Normalisation and units.** Every constant, gain, divider and conversion applied once, in the
  right direction, to the right channel. Flag anything applied twice, applied to a quantity
  already in the target unit, or inverted.
- **Axis quantity against axis label.** The label names the quantity the code computed.
- **Masking, filtering and cuts.** Every mask, threshold, drop or restriction is justified from a
  measured noise floor and is a fit window rather than a silent removal. Masking that quietly
  drops data is a gap even when the figure looks clean.
- **Offsets and zeros.** Self-measured or inherited; applied to the channel the fit consumes; the
  method's parity matches the observable.
- **Fit mechanics.** Window and exclusions stated; parameters carry uncertainties; the window
  covers the discriminating region. Quality carries both a number and a written reading of the
  drawn fit; either standing alone is a gap. Where the two disagree the figure decides, and a fit
  with a respectable χ² whose curve contradicts the data is a gap. A visible discrepancy must be
  reconciled: the analyst adjusts the window or the model until figure and number agree and
  records the change, or states that they could not be reconciled and withdraws the number. A
  step that discloses the disagreement, keeps the window and still quotes the value is a gap.
- **Interpolation.** Flagged, with the bracketing measured points given.
- **Metadata access.** Setpoints read from each dataset's own metadata, indexed so a missing key
  raises rather than yielding a default or NaN that propagates.
- **Reduction discipline.** No moment statistics standing in for physics; no averaging of a
  quantity that is then plotted on an axis.
- **Sanity.** No derived number contradicts what is plainly visible in the data. When an
  algorithm disagrees with the obvious structure, the algorithm is suspect.

## 2. Duty B: figure and claim review (staged)

Staging governs presentation completeness only and never softens Duty A.

- **INTERMEDIATE** (the analyst does not claim the analysis is finished): judge only whether the
  figure credibly does what this step claims: real structure, mechanically sound (axes, units,
  labels, no blank panels, no rendering artefact), and no lead with descriptive statistics.
  Criteria belonging to the finished key figure are out of scope. Default to pass.
- **KEY** (presented as the analysis result, or any stated conclusion): enforce the full rubric.

Four defects are gaps even at INTERMEDIATE stage, because the step then does not do what it
claims: (1) a conclusion generalised beyond the single dataset or cut shown; (2) cropped, masked
or filtered data, or a fit not overlaid on the real unmasked data; (3) a quantity extracted per
curve (fit parameter, peak position, width, edge, threshold crossing) plotted as a trend without
a preceding step that draws the extraction on the raw curves at several values of the control
parameter, or plotted against a derived or theory-side abscissa before its dependence on the
directly swept knob has been shown; (4) a figure-integrity fault from the list below, because
each draws something the data do not contain or makes one quantity read as another.

Figure-integrity checks (defect 4), applied to the figure and the code that drew it:

- **No phantom chord.** A curve drawn over part of an axis is NaN-masked rather than
  boolean-indexed down to the drawn part; two disjoint stretches in one plot call are joined by a
  straight line that reads as data. Look for a near-straight segment bridging a region the points
  avoid, and for `y[mask]` passed to `plot`.
- **One quantity, one scale.** Every panel showing the same quantity uses the same vertical and
  colour scale; a linear panel beside a symlog or log one makes one monotone curve look like two
  dependences.
- **Ordering on a shared abscissa.** If the figure invites reading which of two series is larger,
  they share an x axis; each plotted against its own fitted zero can reverse the apparent order,
  and the ordering must also hold on the raw common x values.
- **Annotations match the curves.** Marked gates, zeros and vertical lines correspond to the
  curves drawn, and to no superseded fit.
- **No wall of text on the figure.** Outside axis labels, panel titles and the suptitle, every
  on-plot string is a label of at most about 46 characters and two lines. A paragraph explaining a
  panel belongs in the caption. This is a gap at every stage because it is what the operator
  reads first.
- **Titles match this run's output.** Numbers in titles and captions come from the current
  stdout.

## 3. Always-included criteria (every objective)

1. **Robustness within a dataset.** The claim survives the choices made inside each dataset:
   cuts, fit windows, sub-ranges, branches. "It appears in dataset N" is no robustness; showing it
   does not move when those choices move is.
2. **Consistency across datasets.** Checked against every dataset that bears on it, with where it
   holds and where it breaks stated.
3. **Show everything.** Nothing cropped, cut, clipped, masked or noise-floor-filtered unless the
   operator asked; any fit-window mask is marked on the figure and the fit overlaid on unmasked
   data. The rule is in `lessons.md` under Data integrity; this is the check.
4. **Record what was left out.** Which runs, ranges and regimes were used, which were excluded,
   and why, so a later audit can reopen the choice.
5. **Run or dataset ids and clear axis labels** on every figure.
6. **Independence.** Corroborating checks share no hidden assumption (the same calibration,
   anchor or noise floor); two checks sharing one are one check.
7. **Applicability contour.** Every stated instrument limit (excitation ceiling, noise floor,
   range) is drawn on the figure the claim is read from, with the fraction of points outside it
   printed; a claim read beyond the limit is capped at suggestive.

## 4. Rubric generation (per analysis)

Only after the data have been loaded and the uncropped overview looked at; a rubric drafted before
seeing the data grades an imagined analysis. Draft four to seven concrete, checkable,
physics-first criteria for what the key figures of this objective must show, from the objective,
the analysis shape (single extraction or family comparison), the run metadata, the overview
figure and the lessons files (weight taught lessons highly).

Return a markdown checklist, one `- [ ]` per criterion, no preamble. The criteria of §3 are
appended to every rubric. The draft goes to the scientist for approval or edit before analysis
proceeds, then into both the analysis plan and the reviewer packet.

## 5. Verdict ladder

Every claim carries exactly one rung, plus the observation that would demote it. "Consistent with
X" is no verdict.

| Rung | Requirement |
|---|---|
| **established** | discriminators pass; every live alternative explicitly addressed; robust within and consistent across all datasets in scope |
| **supported** | robust within and consistent across all datasets in scope; at least one live alternative remains, and is named |
| **suggestive** | holds in a subset only, or robustness untested; the missing check or data is named |
| **unsupported** | rests on a single comparison, or a live mundane alternative is unaddressed |

Only established and supported are presented as results. Anything lower is an open thread,
reported with its blocking gap.

## 6. Coverage table

Mandatory for any claim. One row per dataset in scope:

| dataset | supports | contradicts | n/a | NOT EXAMINED |
|---|---|---|---|---|

Any NOT EXAMINED row caps the verdict at suggestive. The table makes an omission visible.

## 7. Duty C: pipeline audit (when the bar cannot be met)

Triggered when a claim fails the bar and figure-level fixes will not close the gap. Do not
report "not defensible" yet. The usual cause is an analysis refined inside a badly chosen data
scope, because the runs, range and regime were picked first and thereafter treated as fixed.

The perturbation numbers arrive with the packet. Moving the fit window and the seeds is the
analyst's job, done before you are called (`SKILL.md` §5); you judge the reported numbers and do
not re-run them. Their absence is itself a gap.

1. **Reconstruct the chain** from raw data to claim, written out: datasets used and excluded;
   ranges, regimes and working points; every reduction, mask and fit window; every calibration,
   zero and gain and whether it was self-measured or inherited; every model or formula and the
   domain of validity it was borrowed with; the inference step from number to claim.
2. **Judge the chain rather than the figure.** Ask two questions of each item: how much does the
   claim depend on it, and how well is it justified? The item most depended on and least
   justified is the weak point. Start with the data-scope items, chosen earliest and questioned
   least.
3. **Only if the audit comes up empty**, report not-yet-defensible with the pipeline table, the
   weak link, and a concrete `journal/data_requests.md` entry for the measurement that would
   close it, folded together with any other open question whose discriminator needs a similar
   sweep. Never a softened claim.

## 8. Output contract

Gaps are numbered so a subset can be endorsed or dismissed. Computation gaps (Duty A) come first.

Order gaps by dependence × justification: how much the claim depends on what the gap names,
times how poorly that is justified. Raise as many as you find; the ordering makes a long list
usable.

```
VERDICT: pass | fail        STAGE: intermediate | key
COMPUTATION GAPS
  A1. <specific, actionable — what is wrong, where, and why it matters>
FIGURE GAPS
  B1. <specific, actionable>
STRONGEST CASE AGAINST THE CLAIM: <one paragraph>
```

An empty gap list is the expected outcome of a clean step; say so plainly rather than inventing
something to report.

## 9. Rebuttal rules

- The reviewer scores blind first, from the figure, the objective and the rubric, with the
  analyst's narrative and preferred reading withheld. Independence comes from that blind pass.
- The analyst answers with one line per gap, in this exact format:
  `GAP A1: ACCEPT — <how it will be fixed>` or
  `GAP A2: CONTEST — <line N of file X> <quoted value or formula> <why the reviewer misread it>`.
  A gap raised against code that already handles it correctly must be contested; conceding it is
  an error.
- The reviewer rejects a rebuttal that lacks a `GAP X:` line for any gap it raised, and
  re-requests before reconsidering anything.
- On reconsideration the reviewer also receives the analyst's reading, the reply, and the code
  and stdout as backing. A CONTEST holds only if the code or stdout shows it.
- A gap is dropped or narrowed only for a correct, specific data or physics reason. A bare
  disagreement, an appeal to authority or a promise to fix it later does not qualify. The
  reviewer keeps the last word and concedes only to a correct reason.
- On reconsideration the reviewer may add at most one new gap, and only for a concrete
  computational error the image hides; a style point does not qualify.
- A clean pass skips the rebuttal.
- Reviewer malfunction (unparseable output, tool failure) fails open: proceed and say so loudly.
  A substantive failure never fails open.
