---
name: make-figure
description: Compose and audit a multi-panel analysis figure so it reads as one argument. Use when building or reworking a figure that carries a step's or a paper's claim, when panels are being added or dropped, or when a figure "looks wrong" and the fault may be in the drawing rather than the data. Complements analyze-run (craft) and analysis-reviewer (audit); device-agnostic.
---

# make-figure: a figure is a chapter

A multi-panel figure is one argument told in order. A reader should be able to walk the panels
like paragraphs and reach the takeaway without the surrounding text. This skill has two halves:
compose (build the figure as a chapter) and audit (the integrity checks that keep it from
drawing what the data do not contain). The correctness of the computation belongs to
`analyze-run` and `analysis-reviewer`; here the question is whether the figure faithfully shows
what was computed.

## 1. Compose

- State the takeaway first, in one sentence. If you cannot, the figure has no argument yet and
  more panels will not supply one. Write it down; it becomes the caption's last line.
- Order the panels as an argument. The order that recurs in this harness: raw data first (what
  the instrument recorded), then the feature against the knob that drives it, then a side panel
  for anomalies or controls, then the extracted result with its claim stated on the figure. Row
  order carries meaning.
- Every panel earns its place with a one-sentence takeaway. If you cannot say what a panel adds
  that its neighbours do not, cut it. A figure that dropped from twelve panels to five on this
  test lost only noise.
- Each panel hands off to the next. A cut shown on a map is drawn again as a 1-D panel; a boundary
  found in one panel is carried onto the next on the same axis.
- The caption describes each panel for a reader who has not read up to it, says why the figure
  was made, and ends with the takeaway (the `analyze-run` caption rule). Figure and caption are
  written together.

## 2. Audit (before presenting, on the PNG and on the code that drew it)

These faults draw something the data do not contain, or make one quantity read as another. Each
cost real debugging time in this harness, and each is a reviewer gap (`review_rubric.md` §2,
defect 4). Read the saved PNG yourself first, then the drawing code.

1. **No phantom chord.** A curve drawn over part of an axis is NaN-masked
   (`np.where(in_range, y, np.nan)`) rather than boolean-indexed down to the drawn part. Two
   disjoint stretches in one `plot` call are joined by a straight line that reads as data. Tell: a
   near-straight segment bridging a region the points avoid; in code, `y[mask]` passed to `plot`.
2. **One quantity, one scale.** Every panel showing the same quantity shares the vertical and
   colour scale. A linear panel beside a symlog or log one makes one monotone curve look like two
   dependences; if one panel needs symlog for range, all do.
3. **Ordering on a shared abscissa.** If the figure invites reading which of two series is
   larger, they share an x axis. Each plotted against its own fitted zero can reverse the apparent
   order. Confirm the ordering on the raw common x values, with a guard in code when the claim
   rests on it.
4. **Annotations match the curves.** Marked gates, zeros, vertical lines and shaded bands
   correspond to the curves drawn. A common tell after a refit: the lines moved and the curves did
   not.
5. **No wall of text on the figure.** Outside axis labels, panel titles and the suptitle, every
   on-plot string is a label of at most about 46 characters and two lines. A sentence explaining a
   panel goes in the caption. Enforce it in the drawing code immediately before `savefig`:

   ```python
   _exempt = {t for ax in axes for t in (ax.title, ax.xaxis.label, ax.yaxis.label)}
   _exempt.add(fig._suptitle)
   _long = [t.get_text() for t in fig.findobj(matplotlib.text.Text)
            if t not in _exempt and t.get_text().strip()
            and (t.get_text().count("\n") > 1 or len(t.get_text()) > 46)]
   assert not _long, f"on-plot text too long, move it to the caption: {_long}"
   ```

6. **Titles and captions match this run's output.** Numbers in titles come from the current
   stdout. Re-read them after any recompute.
7. **The standing figure rules still bind** (from the `analyze-run` lessons): run or dataset ids
   on every figure; clear axis labels; nothing cropped, clipped, masked or percentile-capped
   unless the operator asked; a fit-window mask marked on the figure with the fit overlaid on
   unmasked data; an explicit dash and solid legend when similar colours separate cuts; shared
   axes across a row at the largest common range.

## 3. Output

Present at the step gate as usual: the figure, the one-sentence takeaway, and any integrity fault
found and fixed, named (which panel, what it drew, the fix). A fault found here is the same kind
of finding the reviewer reports; a figure with a known integrity fault is never handed to the
operator.
