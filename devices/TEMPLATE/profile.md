# Device profile — <NAME> (<one-line device description>)

Single source of device/setup truth for the analysis harness. Fill every section; the
generic skills read this file first and follow it exactly. Companions in this directory:
`lessons.md` (device-taught rules), `journal/` (campaign state — seed from
`journal/SCHEMA.md`), `analyses/` (deliverables), `lib/` (vendored data loaders).

## 1. Identity & scientific goal
<What the device is, its geometry/size (including any finite-size lengths that matter),
the measurement environment, and the campaign's scientific goal. State goals as questions,
not expected findings.>

## 2. Data access & loading
<Where the data lives (files/databases), scoping rules for run ids, freshness/refresh
hygiene, the sanctioned loader in `lib/` with a copy-paste snippet, how per-run metadata
(gains, amplitudes, setpoints) is read, and any metadata traps (stale readbacks, values not
captured by the logging system).>

**Protected files.** `hooks/db_guard.py` reads the block below before every shell command and
refuses any that would delete, move, truncate, overwrite or rewrite one of the files named in
it. Reading stays allowed, and so does copying a fresh master over the local working copy. A
name is matched as plain text anywhere in the command, so sidecar files such as SQLite's
`-wal` and `-shm` are covered by the database name itself. List one filename per line, with
no path. An empty block means nothing is protected, and the hook says so on stderr.

<!-- PROTECTED-FILES:BEGIN -->
<one raw-data filename per line, e.g. mydevice_2026.db>
<!-- PROTECTED-FILES:END -->

## 3. Units & normalization
<The reporting units for the primary observable(s) and the exact normalization formula with
constants.>

## 4. Signal chain
<Instrument table: name → logged parameter → role. Which channel is which physical quantity
(and any historical mix-ups to guard against). Excitation source, dividers, amplifier
chains, grounding notes.>

## 5. Knobs & hard limits
<Every control knob: what it does physically, sign conventions, hard safety limits,
settling times, sweep-direction/hysteresis rules, and read-only observables.>

## 6. Calibrations (live numbers — dated; re-verify per campaign)
<Each calibration constant with its value, date, drift history, and the procedure to
re-measure it from data. Prefer self-measured over stored values.>

## 7. Established facts (with provenance)
<Facts the data has settled — each with run ids / analysis paths / dates. Include negative
results explicitly. Do not extend beyond what the evidence covers.>

## 8. Hypotheses under test (ledger seed)
<Candidate effects/phases/mechanisms — each with (a) literature-defined discriminators,
(b) current status: established / supported / open / disfavored / refuted, (c) evidence
pointers. Mundane hypotheses (thermal artifacts, noise floor/resolution, calibration drift,
excitation effects) are permanent members. Cross-reference journal open-question ids.
NEVER write this section as "how to find X" — write it as "what would prove or disprove X".>

## 9. Working state pointer
<One paragraph of historical spine at most; current working points and in-flight questions
belong in `journal/`, not here.>
