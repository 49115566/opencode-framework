---
feature: 0009-minor-nit-resolution
phase: test
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Verification — Minor and nit resolution routing

## Summary

The change replaces the Blocker/Major-only review gate with an all-severity bar
on six committed surfaces and adds the `AC25` agreement area
(`tests/checks/25-review-severity-bar.sh`) plus two `tests/mutation.sh`
mutations. This pass re-verifies the tree **after** the review's `[N1]` (the
`/review` command's stale `do not invent blockers` wording) was fixed by the
builder: `.opencode/command/review.md:36` now reads `do not invent findings`, and
a matching `AC25 all-severity-bar` assertion pins it so the two prompts cannot
drift apart again. The suite is green (`489 passed, 0 failed, 0 skipped`; up one
assertion from the prior pass) and the mutation self-check is green (`61 checked
passed, 0 failed`).

No open `challenges.md` and no `backtracks.md` record exists for this item, so no
challenge adjudication preceded this pass. No implementation defect was found.
Behavioral outcomes (the actual verdict choice in a live review, a re-review
after a fix, and a challenge adjudication) are prompt-executed and not executable
in CI; they are recorded as a manual residual here and in `tests/README.md`.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 489 passed, 0 failed, 0 skipped`; exit 0 |
| `bash tests/run.sh` (second run) | PASS | Byte-identical output to the first run (`diff -q` clean) — deterministic |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 61 checked passed, 0 failed`; exit 0; both `AC25` mutations caught and named |
| Independent `AC25` sensitivity probe (scratch, not committed) | PASS | Baseline copy `pass=41 fail=0`; three mutations each produced the expected `FAIL AC25 …` line (see below) |
| `git diff HEAD --stat` | PASS (scope) | Only the 9 intended framework files plus `work/0009-minor-nit-resolution/tasks.md` |
| `git status --porcelain -- work/` | PASS (forward-only) | Only `MM work/0009-minor-nit-resolution/tasks.md`; no other `work/` artifact edited or re-derived |

Independent sensitivity probe detail: a scratch copy of the six surfaces was
driven through `tests/lib.sh` + `tests/checks/25-review-severity-bar.sh` in
isolation (baseline `pass=41 fail=0`). Reverting the command's `do not invent
findings` to `do not invent blockers` produced
`FAIL AC25 all-severity-bar review.md command gate: do not invent findings`;
weakening the reviewer verdict to `if any finding of high severity` produced
`FAIL AC25 all-severity-bar reviewer.md verdict`; appending `not merge-blocking`
to the `workflow-lifecycle` skill produced
`FAIL AC25 contract-preserved old/new text 'not merge-blocking' present in: …`.
The probe tree was scratch-only and was removed.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — a surviving Minor/Nit (no Blocker/Major) yields `request-changes` | `tests/checks/25-review-severity-bar.sh` → `AC25 all-severity-bar` reviewer verdict pin (`Set the verdict: \`request-changes\` if any finding of any severity`) | PASS |
| AC2 — `approve` iff no finding of any severity survives; any single severity yields `request-changes` | `AC25 all-severity-bar` bar pins on `reviewer.md` (verdict + recompute), `command/review.md`, `code-review` skill (verdict + disputed-findings), `docs/workflow.md` (Review Exit + challenge recompute) | PASS |
| AC3 — a Minor/Nit-only `request-changes` derives `build (rework)` and routes to `/build` | `AC25 all-severity-bar` bar pins + `tests/checks/20-lifecycle.sh` `review request-changes → /build` route (keyed on the verdict, severity-agnostic) | PASS |
| AC4 — a fixed finding no longer counts and the verdict recomputes under AC2 | `AC25 all-severity-bar` reviewer recompute pin; the live fix→re-review→recompute outcome is prompt-executed | MANUAL (residual recorded in `tests/README.md`) |
| AC5 — a sustained challenge overturns a Minor/Nit and recomputes; a rejected challenge leaves `request-changes` → `/build` | `AC25 all-severity-bar` recompute pins (reviewer, command, code-review, workflow) + reviewer `Rejected` bullet (unchanged) + `20-lifecycle.sh` route; the live adjudication is prompt-executed | PASS (pins) / MANUAL (live adjudication) |
| AC6 — sustained-challenge recompute uses the all-severity bar | `AC25 all-severity-bar` recompute pins + `AC25 contract-preserved` negative control asserts `Blocker or Major` absent on all six surfaces | PASS |
| AC7 — no `approve` path leaves a Minor/Nit unresolved; not author-declinable, not reviewer-approvable | `AC25 contract-preserved` Minor/Nit `blocks the item … cannot decline it` pins + negative control (`not merge-blocking`, `the author may decline`, `waived`, `declined` absent) + `AC25 all-severity-bar` question-escape pins | PASS |
| AC8 — every review-gate surface states the same bar and none calls a Minor/Nit non-blocking/declinable | `AC25 all-severity-bar` pins the bar on all six surfaces; `AC25 contract-preserved` asserts none carries the old language | PASS |
| AC9 — a surviving Minor/Nit item derives `build (rework)`, never `/ship`; the literal and route are unchanged | `tests/checks/20-lifecycle.sh` pins `` `review.md` verdict `request-changes` `` and the `/build` route; the derived-state row (`docs/workflow.md:1051`) is not in the diff | PASS |
| AC10 — four severity labels and both verdicts unchanged; no new severity/disposition/marker/record/command/agent/skill | `AC25 contract-preserved` pins all six labels/verdicts on both definition surfaces and negates `waived`/`declined`; `tests/checks/30-permissions.sh` (14 agents), `40-inventory.sh` (counts), `96-signature-sweep.sh` (13 commands) stay green | PASS |
| AC11 — already-approved/shipped items are not rewritten or re-derived as blocked (forward-only) | Structural/manual: `git status --porcelain -- work/` shows only `work/0009-minor-nit-resolution/tasks.md`; no legacy `review.md` or `ship.md` touched; the change alters no derivation logic | PASS (manual/structural) |
| AC12 — `bash tests/run.sh` passes; six core commands, command→agent pairs, and inventory counts unchanged | `bash tests/run.sh` → 489/0/0; `bash tests/mutation.sh` → 61/0/0; `20-lifecycle.sh` command→agent agreement, `40-inventory.sh` counts, `96-signature-sweep.sh` signatures all green | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Review whose only findings are Nits → `request-changes`, routes to `/build` | `AC25 all-severity-bar` reviewer verdict pin (any severity) + `20-lifecycle.sh` route | PASS |
| Review with no findings → `approve` | `AC25 all-severity-bar` reviewer/code-review `approve` iff no finding of any severity | PASS |
| Only a Nit survives after rework → still does not approve | `AC25 all-severity-bar` bar pins | PASS (pins) / MANUAL (live re-review) |
| Sustained challenge overturns the last finding → `approve` | `AC25 all-severity-bar` recompute pins | PASS (pins) / MANUAL (live adjudication) |
| Sustained challenge adjusts severity but does not overturn → still blocks | `AC25 all-severity-bar` recompute pins include `A finding adjusted to \`Minor\` or \`Nit\` still blocks; only an overturn removes it.` (reviewer, code-review, workflow) | PASS |
| Rejected challenge to a Minor/Nit → verdict stands, routes to `/build` | Reviewer `Rejected` bullet (unchanged) + `20-lifecycle.sh` `request-changes` → `/build` | PASS |
| Both a fixed Minor and an unresolved Nit → `request-changes` | `AC25 all-severity-bar` bar pins | PASS |
| Question rather than a finding → does not block, must not be a decline path | `AC25 all-severity-bar` question-escape pins: `never a classified \`Minor\` or \`Nit\` you are declining to raise` and `A finding you can classify as any severity must be recorded as a finding` | PASS |
| Legacy `review.md` `approve` with Minor/Nit is not re-blocked | Structural/forward-only (AC11); no migration and no rewrite | PASS (manual/structural) |
| `visual.md` Minor/Nit findings gated under the same bar once classified in review | `AC25 all-severity-bar` general bar; `docs/artifact-conventions.md` `visual.md` severity scale intentionally unchanged (spec non-goal) | PASS |
| Open challenge on a Minor/Nit keeps the item blocked until adjudicated | `tests/checks/87-backtrack-guards.sh` `AC24 challenge-loop` + `AC24 derived-state`; live adjudication prompt-executed | PASS (pins) / MANUAL |
| Parallel items: no other readiness changed, no cross-item state | Scope check: no readiness/conflict/roadmap surface in the diff; no new state file or marker | PASS |

## Review finding N1 (re-verification)

The prior `/review` returned `request-changes` on `[N1]`: `.opencode/command/review.md`
still said `do not invent blockers` while the agent said `findings`. The builder
fix is present and verified in this pass:

- `.opencode/command/review.md:36` — `… do not invent findings.`
- `tests/checks/25-review-severity-bar.sh:84-90` — a new `AC25 all-severity-bar`
  assertion pins `do not invent findings` on the command surface.
- The independent probe above confirms the pin is live (reverting the wording
  fails `AC25 all-severity-bar`).

`[N1]` is therefore resolved in the current tree. (This is not a `challenges.md`
adjudication: no challenge was raised, so no `Response` entry is created.)

## Observations examined and accepted (not defects)

These were inspected during this pass and deliberately **not** raised as defects,
because the spec does not require the change and none states a Minor/Nit is
non-blocking or declinable:

- `.opencode/agent/reviewer.md:143` — the handoff summary template
  `Checks: ACs met x/y; blockers n; majors n; minors n; …` omits a `nits n`
  count. It is a summary-count line, not a statement of the review gate, and
  predates the change. Follow-up suggestion only: consider `nits n` for
  completeness.
- `.opencode/agent/reviewer.md:44` — `Style opinions are nits; correctness and
  security are blockers.` This assigns severity (style→Nit, correctness/security→Blocker);
  it does not assert that a Nit is non-blocking. The binding bar is stated at
  `:97-100` and the severity meanings carry `blocks the item`.
- `.opencode/agent/visual.md:126,138` — visual's own handoff routes "visual
  blockers" to `/build`. The spec explicitly keeps `visual.md`'s own severity
  findings out of scope (`spec.md:75-76`); a visual finding is gated under the
  all-severity bar once it is classified in `review.md`.

## Gaps and residual risk

- **Prompt-only behavior.** The deliverable is the framework's own prompts and
  documents; the criteria that describe live review behavior — the actual verdict
  choice (AC1/AC2), the re-review after a fix (AC4), and a challenge adjudication
  (AC5) — are prompt-executed and cannot be exercised in CI. They are verified by
  pinning the committed contract text (`AC25`) and recorded as a documented manual
  residual in `tests/README.md`. This is the largest residual and is inherent to
  the item's medium, not a test gap.
- **Content pins are not semantic.** `AC25` is a live-surface agreement check: it
  catches the old `Blocker or Major` / `not merge-blocking` / declinable wording
  and any weakening of a pinned phrase, but it cannot catch a novel contradictory
  sentence that avoids every negated token. The mutation self-check and the
  independent sensitivity probe bound this risk; the residual is accepted.
- **Untouched contracts rely on existing areas.** AC9/AC11/AC12 rest on
  `20-lifecycle.sh`, `40-inventory.sh`, `96-signature-sweep.sh`, and a structural
  scope check rather than new executables, because the change edits none of the
  derived-state, readiness, inventory, or signature contracts.

## Tests added or changed by this pass

- None. The only coverage gap found on the prior pass (the question-escape clause)
  and the `[N1]` command-wording gap (flagged by review, fixed by the builder) are
  both already pinned in `tests/checks/25-review-severity-bar.sh` in the current
  tree. The new `do not invent findings` assertion was independently proved live
  by the scratch probe. No production behavior, config, or upstream artifact was
  modified. The suite is deterministic (two consecutive runs are byte-identical).
