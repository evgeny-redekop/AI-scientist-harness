# Journal — SCHEMA

**The journal is the state.** What persists across sessions is this journal — the campaign's
scientific record, owned by the scientist. The markdown files are canonical and
human-readable; the harness (CLAUDE.md + `.claude/skills/`) reads and proposes updates to
them.

## The sections

| File | Role |
|---|---|
| `hull.md` | **The banked record** — reality's vote, frozen. Pointers to the DBs, the reviews, prior science-memory. |
| `open_questions.md` | **Standing & open physics questions** with ids, status, hypotheses, discriminators, and the runs that bear on them. The shared agenda. |
| `dead_ends.md` | **Ruled-out branches & known traps** — so no analysis re-walks them. |
| `run_memory.md` | **Per-analysis index** — one line per completed analysis, pointing at its `memory.md`. |
| `background_literature.md` | **Everything learned from published manuscripts**, independent of our data — dated entries with Zotero-anchored citations (key + DOI) that analyses cite by key. |
| `data_requests.md` | **Measurement-request queue** — data the analysis needs but the DBs don't contain; each tied to an open-question id. |

(The retired pipeline's cycle log `log.md` was not carried over.)

## Entry formats

### `open_questions.md`
```markdown
### <id> — <one-line question>   [status: open | standing | resolved]
- hypotheses: <competing hypotheses, held in tension>
- bears on: <campaign goal this advances>
- discriminator: <the measurement/analysis that would actually resolve it — the candidate decisive experiment>
- in_hull: <yes = existing data/literature can settle it | no = needs a new coupling>
- runs: <run refs + one line on what each added>
- updated: <YYYY-MM-DD> — <what changed>
```
`status`: **open** (active), **standing** (a permanent diagnostic re-asked of every relevant
run, e.g. `std-am-vs-bkt`), **resolved** (closed; keep for the record).

### `dead_ends.md`
```markdown
### <id> — <what was tried / the trap>
- why dead: <what ruled it out, or why it is a trap>
- evidence: <run refs / analysis>
- do instead: <the correct move>
- dated: <YYYY-MM-DD>
```

### `data_requests.md`
```markdown
### <id> — <one-line request>   [status: requested | taken | analyzed]
- bears on: <open-question id(s)>
- sweep: <parameter, range, resolution, working point, excitation/settling if relevant>
- discriminates: <which live hypotheses this separates, and how each outcome reads>
- runs: <run ids once taken>
- dated: <YYYY-MM-DD>
```

### `background_literature.md`
```markdown
### <topic / question id> [<YYYY-MM-DD>]
- claim/method: <what the literature establishes or how it does the analysis>
- relevance: <which open question / hypothesis this bears on>
- citation: <citekey> — <authors, year, journal> — doi:<DOI> (verified in Zotero)
```

### `hull.md`
Free-form pointers + provenance (see the seeded file).

## Update protocol

The main agent **proposes** journal edits in these formats at the end of an analysis or
deliberation; **the user approves before anything is written.** Edits are append-only within
a cooldown: dated notes, statuses moved, never history deleted or rewritten.

## Invariants

- **Every result connects to ≥1 open question.** An orphan result is a journal gap to fill,
  not a finished analysis.
- **Epistemic status travels** with every claim: measured-and-verified vs conjectured. The
  journal never silently promotes a hypothesis to a premise.
- **Dead ends are append-only** within a cooldown; revisit only with new data (then add a
  dated note, do not delete history).
- **Literature claims carry verified citations** (key + DOI present in the Zotero library) —
  no citation, no entry.
