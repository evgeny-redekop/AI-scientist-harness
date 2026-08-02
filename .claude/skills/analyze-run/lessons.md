# Generic analyst lessons (operator-taught, durable)

Device-independent analysis craft taught at supervised checkpoints. The block between
the LESSONS markers is loaded as **non-negotiable constraints** at the start of every
analysis, on any device. Device-specific rules live with the device
(`harness/devices/<name>/lessons.md`) — only rules that would survive a move to a different
chip belong here.

**`!rule` protocol** (works in any chat; stated in CLAUDE.md): a user message starting `!`
is a durable lesson — generalize it to one dated bullet, classify it generic vs device,
echo the wording AND destination back for confirmation, then append it just above the
LESSONS:END marker of the right file and copy the verbatim original to the device raw
archive. `!rule || local` persists only the part before `||` (the rest steers the current
session only). "Re-fold lessons" = regroup bullets topically; archives untouched.

<!-- LESSONS:START -->
### Reading the data — never assume
- NEVER assume or carry parameters between datasets. Read each setpoint directly from that
  dataset's own metadata/snapshot; if a value is absent, ask the supervisor.
- Metadata lookups must FAIL LOUDLY. Never fetch a setpoint through a chained
  `.get(key, {}).get("value")` or any silent-default accessor: if the key is missing or has
  moved, you get `None`/NaN instead of an error, and it propagates into derived quantities —
  silently disabling the very metadata-verification step meant to catch it. Index required
  keys directly, or raise with the full path. When a verification step reports a setpoint as
  NaN/absent, treat that as a code bug to chase down, never as a property of the run.
  [2026-07-23]
- Verify constant knobs in the narrative TEXT (quote values from metadata), never as a
  dedicated figure — a figure whose only purpose is to confirm a fixed parameter is a wasted
  step.

### Data integrity — show everything, reduce only explicitly
- Open with the raw data, full range: the FIRST figure must let a reader see everything the
  instrument recorded, and on the initial overview plot ALL datasets together — no crop, no
  filter. (Weissgerber 2015; Tufte 2001)
- NEVER crop, cut, clip, or mask plotted data — not the axis range, the signal range, or the
  colormap scale (no percentile vmax/vmin caps) — unless a supervisor explicitly asks. To
  de-emphasize a region, raise its transparency or add a labelled band; never remove it.
- Every reduction is a labeled, motivated step: each crop, mask, smoothing window,
  average/median, or detrend gets its OWN figure and a stated reason — never silently.
  (Sandve 2013; Tukey 1977)
- NEVER average or take medians of the data you put on an x or y axis. Use statistics only
  when truly unavoidable; by default show a few line cuts at different values of the swept
  axis instead of a reduced curve.
- Treat variations at or below the swept-axis grid pitch or the measured noise scale as
  unresolved — never interpret sub-resolution wobble as a real feature or periodicity.
- When the primary boundary metric is nearly flat in the swept parameter, relocate the
  dependence to the quantity that actually carries it (e.g. band intensity or width) rather
  than forcing it onto the flat metric.
- When the operator asks for something SPECIFIC THAT DOES NOT GENERALIZE — a tuned constant,
  a hand-picked threshold, a deliberate departure from the obvious form — write an explicit
  comment at that line saying what the choice is, that the operator asked for it, and why.
  Without it the choice is indistinguishable from an unexplained magic number and a later
  reader correctly flags it as a defect. Real cost: `0.70 * T_ridge` (the fallback lower fit
  edge when no kink is found) was requested by the operator for a better fit, but carried no
  comment — two independent blind referees raised it as an unexplained hardcoded constant
  setting the fit window. Both were right about the code as written and wrong about the
  substance. One line of comment prevents the whole exchange. [2026-07-27]

### Figures and axes
- ALWAYS state the run/dataset id(s) of every dataset used, on every figure.
- ALWAYS label x and y axes clearly and concisely; keep all on-plot text sharp and minimal
  (a figure drowning in text fails even if the analysis is right).
- Honest axes and color: never truncate an axis or use dual axes to exaggerate a feature;
  colorblind-safe, perceptually-ordered colormaps. (Tufte 2001; Wong; Wilke 2019)
- Show line cuts on the 2-D map they came from — mark each cut location with dashed lines on
  the map — then again as their own 1-D panel. (Wong, "Points of View")
- Shared axes across panels in a row (maximum common range) and shared colour scales, so
  panels are directly comparable.
- When plotting a family of curves along a dense swept axis, show enough representative
  curves (well more than ~5) spanning the range so the trend is distinguishable.
- When similar colours distinguish different cuts, the legend must state an explicit
  dash/solid mapping so the curves are tellable apart.
- A panel title or stated conclusion must match the plotted traces and the printed output —
  never assert a global claim that a visible trace or printed min/max contradicts.
- Zoom each symmetry/fold-check panel to the actual data span so the overlap is legible, and
  show a numerical fold-residual readout so consistency is demonstrated, not asserted.

- Deliver VISUALS, not tables of derived numbers. A scientist can check a fit drawn on data by
  eye and cannot check a column of fitted values; put numbers on the figure or in the narrative,
  never as printed output. In notebooks every figure must render in-cell (`plt.show()`, never
  `plt.close()`), and the committed notebook must be executed so the figures are embedded.
  [2026-07-26]

### Fitting and calibration
- A fit is NEVER shown alone — always overlay it on the real data, plus a residual panel.
  (Hughes & Hase 2010; Numerical Recipes Ch. 15)
- Fit windows must be drawn truthfully on the data they were fit to, so the reader can
  verify the fit covers exactly the claimed points.
- State the fit window and what was excluded; report parameters WITH uncertainties, not bare
  best-fit values. (Hughes & Hase 2010; Taylor 1997)
- Justify fit quality with a NUMBER (reduced χ² / residual structure), not by eye.
  (Bevington; Andrae 2010)
- Prefer self-measured calibrations to stored values: measure zeros/offsets from the
  symmetry of the data in hand rather than a nominal axis value; report any drift from the
  stored value, and always state which zero/calibration you used.
- Calibrate the zero/offset of the channel your fit actually consumes. AC and DC zeros need
  not coincide: for AC quantities, find the zero by even-symmetrization of the AC response;
  for DC quantities, by the zero-crossing of the DC signal. When both methods are available,
  cross-check them — a disagreement beyond their spreads is itself a finding: report it as a
  flag on the measurement chain and state whether the conclusion changes with the choice of
  zero. [2026-07-14]
- Match the zero-finding method to the parity of the observable: an odd quantity (voltage,
  current) crosses zero — locate it by antisymmetry or zero-crossing; an even quantity
  (differential resistance vs bias) peaks at zero — locate it by its apex. Applying the
  wrong-parity method gives unstable, meaningless zeros. [2026-07-14]
- Extract a calibration from the best-conditioned dataset in the family: the run whose fine,
  wide sweep IS the axis being calibrated, taken in a well-conditioned regime — never a
  narrow span. Sharpen the feature with a secondary knob (several cuts at different values),
  compute the value per run, then reconcile across runs (average, or take the most precisely
  measured). Do not switch calibration datasets mid-analysis. [2026-07-14]
- Continuously swept data lags the applied setpoint (settling hysteresis) and under-reads
  sharp features. On a steep feature, a settled fixed-setpoint measurement outranks the
  swept trace: treat the swept apex as a lower bound, and prefer step-and-settle
  acquisition when the feature itself is the target. [2026-07-14]
- Judge fit quality by the residuals over the physically discriminating region of the curve
  — the transition, not a flat plateau. A plateau-dominated goodness metric is degenerate
  (anything flat "fits" it) and will steer any window optimizer to the wrong region.
  [2026-07-14]
- When the extracted value could plausibly depend on the fit-window choice, vary the window
  edges and report how much the result moves. Use judgment: a quick sensitivity check where
  it matters, not a ritual for every fit. [2026-07-14]

- Judge a fit by LOOKING at it, not by an aggregate number. Draw the fitted curve on the data
  at several points spanning the control parameter, and resolve every goodness metric against
  that parameter rather than averaging over it. A mean or median rms is meaningful only once
  you have shown the rms is flat across the range; otherwise it hides that the model fits well
  in one part and fails in another, and it will select the wrong model. The same caution applies
  to any per-item median quoted about a range-interpolated result — check it against the points
  that actually produce the answer. [2026-07-26]
- Draw the fit window ON the data and verify it contains the feature the fitted parameter
  describes. A window that excludes the transition will still converge and still return a
  transition temperature — extrapolated outside every fitted point. If the extracted parameter
  falls outside the fitted range, mark it as an extrapolation on the figure. [2026-07-26]
- Before running any bounded fit or bounded search, CHECK EVERY BOUND AND SEED: each initial
  guess must lie strictly inside its own bounds, and each bound must admit the values the data
  plausibly needs. A seed outside its bound makes the optimizer raise, the point is recorded as
  a failure, and the failure then reads as "the model cannot describe the data here" when it is
  really a coding error — the most expensive kind, because it looks like a result. The same
  applies to fit windows and search ranges: an optimizer or peak-finder that can rail against a
  range edge will return the edge, not a measurement, so report how often a bound is active and
  widen it to check. [2026-07-26]

### Mapping a fitted number onto a theory parameter
- Before converting a fitted quantity (an exponent, a slope, a width) into a named theory
  parameter, establish TWO things and state them: (i) which branch/limit of the theory the
  formula belongs to, and whether the data actually sit in that limit — a formula inherited
  from a review, a previous notebook, or a neighbouring regime carries its domain of validity
  with it; (ii) that the experimental proxy being compared against is the quantity the theory
  names, not merely one with the same units. A mapping used outside its domain manufactures
  structure that looks physical (apparent ceilings, divergences, "identity violations") but
  is an artifact of the algebra. [2026-07-23]
- Agreement between model and data AT a critical point is nearly worthless as evidence:
  competing models generically coincide there — wherever the observable becomes independent of
  the control parameter, any exponent extracted there goes to the same limit regardless of which
  model is right. A model earns its keep AWAY from the critical point. Likewise, if two
  "independent" checks both reduce to the same measured quantity restated, they are one check.
  [2026-07-23]
- When a named mechanism is invoked to explain a functional form, ask the literature what
  ELSE produces that form — especially results from the same material/device lineage — and
  put those on the ledger before the named mechanism is allowed into a conclusion. Any smooth
  crossover or saturating function fitted over a finite window will yield *some* power-law
  exponent; a fitted exponent is therefore never on its own evidence for a power-law mechanism.
  [2026-07-23]

### Detection, coverage, and robustness
- Feature/band detectors (saturation, flatness, edges) must use thresholds derived from the
  measured noise floor and RELATIVE to the local signal, applied as one contiguous interval
  from the anchored side. An absolute cutoff is enormous where the signal is small and
  trivial where it is large, and will latch onto the first noise excursion. [2026-07-14]
- Analyze ALL the data: the analysis itself always runs over every datapoint and the full
  available range of every dataset, so the regime a hypothesis predicts is actually
  bracketed. In figures, show at least a representative subset of what was analyzed — and
  at most everything — but never silently restrict the analysis to a subrange. [2026-07-14]
- Reliability masks and noise thresholds are dataset-specific: never port one between runs
  or datasets. If a mask declares an entire run unusable, suspect the mask before the run.
  [2026-07-14]
- A featureless result after a unit conversion is not evidence of a conversion error — a
  correct conversion need not change the on-plot structure. Distinguish a genuine null from
  a bug by bringing in the rest of the family, not by re-deriving the conversion.
  [2026-07-14]
<!-- LESSONS:END -->

## Raw teaching archive

The verbatim originals of these rules were taught on the device they arose on and are
archived in that device's lessons file (`harness/devices/<name>/lessons.md` → "Raw teaching
archive"). New generic teachings get their verbatim originals archived in the active
device's lessons file.
