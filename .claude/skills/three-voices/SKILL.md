---
name: three-voices
description: Deliberate a physics/interpretation fork with three isolated voices (Skeptic, Pacifist, Idealist). Use when the user asks for "three voices", a "collision", or deliberation on a standing question — or before committing to a load-bearing interpretation. Device-agnostic; device content arrives via the collision packet.
---

# three-voices — isolated-context deliberation

Purpose: genuinely independent perspectives on one fork. You (the main session) cannot
unsee your own working hypothesis; three subagents with separate contexts can. **Collision,
not consensus** — the output is the one decisive experiment, not an agreeable verdict.

## 1. Build ONE collision packet (identical for all voices)

- Path to the active device profile directory (named in CLAUDE.md).
- The open-question entry, quoted in full from the device `journal/open_questions.md`
  (id, hypotheses, discriminator, runs) — or, for a new fork, the same fields drafted fresh.
- Paths to the relevant analysis dirs / figures / notebooks.
- The relevant `dead_ends.md` entries (so no voice re-walks a ruled-out branch).
- Optional but encouraged: literature grounding gathered FIRST (library/citation search),
  quoted with citations from/into `journal/background_literature.md`.

## 2. Launch the three voices in parallel

One Agent call each — subagent types `voice-skeptic`, `voice-pacifist`, `voice-idealist` —
in a single message so they run concurrently, each with the identical packet. **Isolation is
structural**: separate contexts, no voice sees another's reasoning, and you do not include
your own current interpretation in the packet (state the fork neutrally).

## 3. Synthesize in the main session

- Lay out genuine disagreements vs **shared assumptions** (a shared assumption among all
  three is a candidate hidden confound, not evidence).
- **Convergence is suspect.** If all three agree without anyone paying a cost, do NOT stop:
  relaunch once with a perturbation — "assume shared premise X is false", a harder dataset, a
  self-measured calibration instead of a stored one — and force them apart.
- **Collapse criteria** (the deliberation ends only when both hold):
  1. There is **one named decisive experiment** — the single new coupling the banked data
     cannot predict, stated surgically: regime, observable, and what each outcome would mean.
  2. The journal update is drafted: open-question status moves, any new questions, a
     dead-end entry if a branch was ruled out, a `data_requests.md` entry if the decisive
     experiment needs new data.
- Flattery is forbidden; the only textual proof of belief is conceding at a cost or
  disagreeing at a cost. Present the voices' positions faithfully — including the one you
  disagree with.

## 4. Close

Present the synthesis and the drafted journal edits to the user for approval (append-only,
dated), then write them. The user owns the conclusion; the deliberation proposes.
