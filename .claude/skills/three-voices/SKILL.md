---
name: three-voices
description: Deliberate a physics/interpretation fork with three isolated voices (Skeptic, Pacifist, Idealist). Use when the user asks for "three voices", a "collision", or deliberation on a standing question, or before committing to a load-bearing interpretation. Device-agnostic; device content arrives via the collision packet.
---

# three-voices: isolated-context deliberation

Purpose: independent perspectives on one fork. The main session cannot unsee its own working
hypothesis; three subagents with separate contexts can. The output is the one decisive
experiment, and agreement among the voices is no result in itself.

## 1. Build one collision packet, identical for all voices

- Path to the active device profile directory (named in CLAUDE.md).
- The open-question entry, quoted in full from the device `journal/open_questions.md` (id,
  hypotheses, discriminator, runs), or for a new fork the same fields drafted fresh.
- Paths to the relevant analysis directories, figures and notebooks.
- The relevant `dead_ends.md` entries, so no voice re-walks a ruled-out branch.
- Encouraged: literature grounding gathered first (library and citation search), quoted with
  citations from and into `journal/background_literature.md`.

## 2. Launch the three voices in parallel

One Agent call each, subagent types `voice-skeptic`, `voice-pacifist` and `voice-idealist`, in a
single message so they run concurrently, each with the identical packet. Isolation is
structural: separate contexts, no voice sees another's reasoning, and the packet states the fork
neutrally without your own current interpretation.

## 3. Synthesize in the main session

- Separate the genuine disagreements from the shared assumptions. An assumption all three share
  is a candidate hidden confound rather than evidence.
- Convergence is suspect. If all three agree without anyone paying a cost, relaunch once with a
  perturbation ("assume shared premise X is false", a harder dataset, a self-measured calibration
  in place of a stored one) and force them apart.
- The deliberation ends only when both of these hold:
  1. One named decisive experiment: the single new coupling the banked data cannot predict,
     stated with its regime, its observable, and what each outcome would mean.
  2. The journal update is drafted: open-question status moves, any new questions, a dead-end
     entry if a branch was ruled out, and a `data_requests.md` entry if the experiment needs new
     data.
- Flattery is forbidden; the only textual proof of belief is conceding at a cost or disagreeing
  at a cost. Present the voices' positions faithfully, including the one you disagree with.

## 4. Close

Present the synthesis and the drafted journal edits to the user for approval (append-only,
dated), then write them. The user owns the conclusion; the deliberation proposes.
