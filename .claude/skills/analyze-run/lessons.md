# Generic analyst lessons (operator-taught, durable)

Device-independent analysis craft taught by the operator at supervised checkpoints. The block
between the LESSONS markers is loaded as non-negotiable constraints at the start of every
analysis, on any device. Device-specific rules live with the device
(`devices/<name>/lessons.md`); only rules that would survive a move to a different chip belong
here. Rewritten 2026-09-03 for concision, without changing any rule's substance; the campaign
anecdotes that motivated each rule are in the device files' raw teaching archives.

**`!rule` protocol** (works in any chat; stated in CLAUDE.md): a user message starting `!` is
a durable lesson. Generalize it to one dated bullet, classify it generic or device, echo the
wording and destination back for confirmation, append it just above the LESSONS:END marker of
the right file, and copy the verbatim original to the device raw archive. `!rule || local`
persists only the part before `||`; the rest steers the current session only. "Re-fold
lessons" means regroup bullets topically; archives stay untouched.

<!-- LESSONS:START -->
### Reading the data
- Read every setpoint from the dataset's own metadata. Never carry a value from one dataset
  to another; if a value is absent, ask.
- Metadata lookups fail loudly. Index required keys directly or raise with the full path. A
  chained `.get(key, {}).get("value")` returns None or NaN for a missing or moved key, the NaN
  propagates into every derived quantity, and the verification step meant to catch it reports
  nothing. A setpoint that reads as NaN is a code bug rather than a property of the run.
  [2026-07-23]
- The snapshot records what was commanded before the run; the circuit records what the run
  used. Before quoting a number from a run, measure what the circuit fixes and print each beside
  its recorded value: which channel carries the current (the span of each channel across a sweep
  from insulating to conducting, a ratio that needs no gain), each amplifier gain (the slope of
  the raw voltage channel against applied bias where the device takes the whole bias),
  excitation and series resistance (the current plateau where the device is a short), and the
  delivered-to-commanded ratio of every knob behind a divider or series element. A disagreement
  becomes a row in the device's correction table. Cost: gains recorded a decade off, a bias path
  delivering 1/282 where 1/100 was documented, and two meters reading each other's signals for
  31 runs, each found after a number built on the record had been presented. [2026-09-03]
- Confirm a constant knob in the narration by quoting its value from the metadata. A figure whose
  only purpose is to confirm a fixed parameter is a wasted step.

### Data integrity
- The first figure shows everything the instrument recorded, all datasets together, full range,
  with no crop and no filter. (Weissgerber 2015; Tufte 2001)
- Never crop, cut, clip or mask plotted data, whether the axis range, the signal range or the
  colour scale (no percentile caps), unless the operator asks. To de-emphasise a region, raise
  its transparency or add a labelled band.
- Every reduction gets its own figure and a stated reason: crops, masks, smoothing windows,
  averages, detrends and per-curve extractions. A reduction done inside the cell that plots its
  result cannot be audited. (Sandve 2013; Tukey 1977)
- Do not average or take medians of data that go on an axis. Show a few line cuts at different
  values of the swept axis instead of a reduced curve; use statistics only when nothing else
  works.
- Variation at or below the grid pitch of the swept axis, or below the measured noise, is
  unresolved. Do not read it as a feature or a period.
- When the primary metric is nearly flat in the swept parameter, look for the dependence in the
  quantity that carries it (an intensity, a width) rather than forcing it onto the flat metric.
- When the operator asks for a specific choice that does not generalise (a tuned constant, a
  hand-picked threshold, a deliberate departure from the obvious form), write a comment at that
  line saying what the choice is, that the operator asked for it, and why. Without the comment it
  reads as an unexplained magic number, and a later reader correctly flags it. [2026-07-27]

### Figures and axes
- State the run or dataset ids of every dataset used, on every figure.
- Label both axes clearly and briefly.
- On-plot strings are labels. Outside axis labels, panel titles and the suptitle, no annotation
  runs past about 46 characters or two lines; reasoning and caveats go in the caption. Enforce it in code: before `savefig`, walk `fig.findobj(matplotlib.text.Text)`,
  skip the exempt items, and assert the rest are short. [2026-08-27]
- Honest axes and colour: no truncated or dual axes to exaggerate a feature; colourblind-safe,
  perceptually ordered colormaps. (Tufte 2001; Wong; Wilke 2019)
- Show line cuts on the 2-D map they came from, each cut position marked with a dashed line,
  then as their own 1-D panel. (Wong, "Points of View")
- Panels in a row share axes (the largest common range) and colour scales, so they compare
  directly.
- A family of curves along a dense swept axis shows enough curves, well more than five, spanning
  the range, so the trend is visible.
- When similar colours distinguish cuts, the legend states the dash and solid mapping.
- A title or stated conclusion matches the plotted traces and the printed output. A visible trace
  or a printed extremum that contradicts it is a defect.
- Zoom a symmetry or fold-check panel to the data span so the overlap is legible, and print the
  fold residual so the consistency is shown rather than asserted.
- Put every derived number where it can be checked against the data that produced it: on the
  figure, or in the narration beside it. A printed column of fitted values gives the reader
  nothing to judge; the fitted curve drawn on the data does. [2026-07-26]
- In notebooks every figure renders in its cell (`plt.show()`, never `plt.close()`), and the
  committed notebook is executed so the figures are embedded. [2026-07-26]
- A curve drawn over part of an axis is NaN-masked (`np.where(in_range, y, np.nan)`) and plotted
  whole rather than boolean-indexed down to the drawn part. Two disjoint stretches passed to one
  plot call are joined by a straight line across the gap, and that phantom chord reads as data.
  [2026-08-27]
- One quantity gets one vertical scale within a figure. A linear panel beside symlog or log
  panels of the same quantity makes one monotone curve look like two different dependences; if
  one panel needs symlog for range, every panel of that quantity uses it. [2026-08-27]
- Before comparing two series for their order, put them on a shared abscissa. Each plotted
  against its own fitted zero can reverse the apparent order; check the ordering on the raw
  common x values. [2026-08-27]

### Fitting and calibration
- Fit the quantity the claim is about. A fit made in one variable and converted afterwards is a
  fit of the first: its exponent, its window sensitivity and its extrapolated zero belong to that
  variable. When the physics names a quantity (a critical current, an energy, a length), fit it
  directly through each dataset's own conversion, and report a proxy fit only as a cross-check.
  [2026-08-27]
- When a scan over a parameter grid also rejects outliers, freeze the outlier set during the
  scan: decide it once, hold it fixed, re-derive it at the winner, and repeat until it stops
  changing. Otherwise a candidate wins by declaring more points bad, and the scan drifts to the
  edge of its range. The same holds for a scan that changes which items qualify: freeze the
  population, report the scan per item where the count is small, and quote a limit at the weakest
  member of the set. [2026-08-27, 2026-09-03]
- Show every fit as a curve on the unreduced data, with a residual panel and the fit window drawn
  on the same axes. The drawn window is exactly the set of points the fit consumed. (Hughes &
  Hase 2010; Numerical Recipes Ch. 15)
- Check that the window contains the feature the fitted parameter describes. A window that
  excludes the transition still converges and still returns a transition temperature,
  extrapolated beyond every fitted point; mark such a parameter as an extrapolation on the
  figure. [2026-07-26]
- State the window and the exclusions, and report every parameter with its uncertainty. (Hughes
  & Hase 2010; Taylor 1997)
- Quantify fit quality with a number (reduced χ², residual structure) computed over the region
  that discriminates between models, meaning the transition itself, and report it per curve, with
  the fit drawn at several settings across the range. A metric dominated by a flat plateau is
  degenerate and steers a window optimiser to the wrong region. An aggregate rms is admissible
  only once shown flat across the range, and the same holds for a median over an interpolated
  result. (Bevington; Andrae 2010) [2026-07-14, 2026-07-26]
- A fit is judged twice, by its number and by its drawn shape, and the reading of the shape is
  written into the step's markdown: where the curve tracks the data, where it departs, and
  whether the residuals show structure. Where the number and the figure disagree, the figure
  decides and the disagreement is reported. An assessment left in your head cannot be checked.
  [2026-08-08]
- Prefer self-measured calibrations to stored values: take zeros and offsets from the symmetry of
  the data in hand, report any drift from the stored value, and state which zero and calibration
  were used.
- Calibrate the zero of the channel the fit consumes. AC and DC zeros need not coincide: an AC
  zero comes from the even symmetry of the AC response, a DC zero from the zero crossing of the
  DC signal. When both exist, cross-check them; a disagreement beyond their spreads is a finding
  about the measurement chain, and the narration states whether the conclusion changes with the
  choice. [2026-07-14]
- Match the zero-finding method to the parity of the observable. An odd quantity (voltage,
  current) crosses zero and is located by antisymmetry; an even quantity (differential
  resistance against bias) peaks at zero and is located by its apex. [2026-07-14]
- Extract a calibration from the best-conditioned dataset in the family: the run whose fine,
  wide sweep is the axis being calibrated, taken in a well-conditioned regime. Sharpen the
  feature with a secondary knob, compute the value per run, reconcile across runs (average, or
  the most precise), and do not switch calibration datasets mid-analysis. [2026-07-14]
- Continuously swept data lag the setpoint and under-read sharp features. On a steep feature a
  settled fixed-setpoint measurement outranks a swept trace, and a swept apex is a lower bound.
  The lag scales with sweep rate: before calling a run-to-run spread jitter, plot the extracted
  position against every rate the runs differ in. Recover the acquisition order of every line,
  and exclude the points after a large step in any knob from every calibration, with the count
  set by the fitted decay. [2026-07-14, 2026-09-03]
- A fitted number must survive the choices that produced it. Before any bounded fit or search,
  check every bound and seed: each seed strictly inside its bounds, each bound wide enough for
  the values the data may need. A seed outside its bound makes the optimiser raise, the point is
  recorded as a failure, and the failure reads as "the model cannot describe the data here". A
  fit or peak-finder that can rail against a bound returns the bound, so report how often a bound
  is active and widen it to check. Then move the window edges and the sub-range and report the
  shift as σ_syst/σ_stat against the fit's own uncertainty; above 1 the number is a property of
  the window. For a power law or scaling quantity also report d(ln θ)/d(ln w): flat across a
  sliding log window marks a real scaling regime, drifting marks a crossover fitted over a finite
  range. [2026-07-14, 2026-07-26, 2026-08-03]
- A model of a sweep-direction artefact must vanish at zero sweep rate, and this is checked
  before any fit quality is compared. Evaluate every candidate at zero rate and report the gap
  it leaves between the two directions: a settling lag closes it; a fixed direction offset holds
  it open and thereby claims the swept axis is bistable, which needs its own evidence. Exclude an
  inadmissible model however well it fits. The measurement that would overturn the limit is a
  rate ladder taken in both directions. [2026-08-22]

### Extracting a quantity and plotting its dependence
- Any quantity extracted per curve (a fit parameter, a peak position, a width, an edge, a
  threshold crossing) gets its own extraction step, presented and approved, before it appears
  as a trend. That step draws the extraction on the raw curves at several values of the control
  parameter, including both extremes and any marginal curve, with the window or search region
  marked. A trend plot without it is a gap. [2026-08-02]
- Plot an extracted quantity first against the directly swept knob, one trace per other swept
  knob, and present that figure before any version with a derived or theory-side abscissa. The
  replot states the transformation and keeps the direct version beside it. [2026-08-02]

### Mapping a fitted number onto a theory parameter
- Before converting a fitted quantity into a named theory parameter, state two things: which
  branch or limit of the theory the formula belongs to, with evidence from the run that the data
  sit in that limit; and that the experimental proxy is the quantity the theory names, since
  sharing its units is not enough. A formula inherited from a review, an earlier notebook or a
  neighbouring regime carries its domain of validity with it, and outside that domain it
  manufactures structure that looks physical. [2026-07-23]
- Agreement between model and data at a critical point is weak evidence: competing models
  coincide wherever the observable stops depending on the control parameter. A model earns its
  keep away from the critical point. Two checks that reduce to the same measured quantity are one
  check. [2026-07-23]
- When a named mechanism is invoked to explain a functional form, ask the literature what else
  produces that form, especially in the same material or device lineage, and put those on the
  ledger before the mechanism enters a conclusion. Any smooth crossover fitted over a finite
  window yields some power-law exponent, so a fitted exponent alone is never evidence for a
  power-law mechanism. [2026-07-23]

### Detection, coverage, and robustness
- Detectors of a feature or band (saturation, flatness, an edge) use thresholds derived from the
  measured noise floor and relative to the local signal, applied as one contiguous interval from
  the anchored side. An absolute cutoff is enormous where the signal is small and trivial where
  it is large, and latches onto the first noise excursion. Three controls bind every edge or
  threshold read from a noisy quantity. Run the identical estimator on a synthetic constant with
  the run's own noise; if it reproduces the measured statistic, the edge is the instrument's
  sensitivity contour. Test the start column and the search bounds by the same criterion as every
  other column, starting from the measured zero; a search that opens a fixed number of columns
  from zero returns that offset whenever the feature is narrower than the grid. Draw a flagged
  bound at the bound (scan end, grid step) with a symbol for its direction, and derive nothing
  else from that row. [2026-07-14, 2026-09-03]
- Analyse all the data: every point and the full range of every dataset, so the regime a
  hypothesis predicts is bracketed. Figures show at least a representative subset and at most
  everything; the analysis never silently restricts itself to a sub-range. [2026-07-14]
- Reliability masks and noise thresholds are dataset-specific; never port one between runs. If a
  mask declares a whole run unusable, suspect the mask before the run. [2026-07-14]
- A featureless result after a unit conversion is no evidence of a conversion error, since a
  correct conversion need not change the structure. Separate a genuine null from a bug by
  bringing in the rest of the family. [2026-07-14]

### Narration and figure captions
- Narration is written as in a scientific publication: clear, brief declarative sentences, every
  word carrying meaning, and no specialist term without a plain-words gloss at first use. Cut any
  sentence whose removal leaves the meaning intact. Avoid the machine-writing tells: a bolded
  aphorism closing a section, a negation as a heading, a three-item rhetorical chain, a stem
  repeated across parallel items, em dashes, and the "X, not Y" antithesis. [2026-08-22]
- Every figure has a clear, brief title and a caption in the markdown beside it. The caption
  describes each panel for a reader who has not read the notebook so far, says why the figure was
  made, and says what to take from it. [2026-08-22]
<!-- LESSONS:END -->

## Raw teaching archive

The verbatim originals of these rules are archived in the lessons file of the device they arose
on (`devices/<name>/lessons.md`, "Raw teaching archive"). New generic teachings get their
verbatim originals archived in the active device's lessons file.
