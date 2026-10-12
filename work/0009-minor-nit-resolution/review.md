---
feature: 0009-minor-nit-resolution
phase: review
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Review — Minor and nit resolution routing

## Verdict

**approve** — the all-severity bar is propagated consistently across all six
authority surfaces and pinned by a new live-surface agreement area; the prior
review's `[N1]` (the `/review` command's stale "do not invent blockers" wording)
is fixed and pinned, and no finding of any severity survives this pass.

## Base and range

- `git status`
- `git log --oneline -15`
- `git merge-base HEAD origin/main` → `5b07658a304e8ca0f95ab20d4403d2bffa925a7b`
- `git rev-parse HEAD origin/main` → both `5b07658a304e8ca0f95ab20d4403d2bffa925a7b` (HEAD == base == `origin/main`)
- `git diff HEAD --stat`
- `git diff HEAD -- .opencode docs tests/mutation.sh tests/README.md`

The item is not on its own branch: the change is staged and unstaged on `main`
against `HEAD`, so the range is `HEAD` → working tree, which is unambiguous. The
new file `tests/checks/25-review-severity-bar.sh` is staged and additionally has
unstaged edits; `git diff HEAD` shows the full working-tree content, which is what
was reviewed. `work/0009-minor-nit-resolution/review.md` and `verify.md` are
untracked (not part of the code diff).

`work/0009-minor-nit-resolution/challenges.md` does not exist, so there is no open
challenge to adjudicate before forward work; likewise no `backtracks.md` and no
`visual.md`.

Execution note: the review's Bash allowlist is read-only (`git`/`ls`/`cat`
prefixes only), so `bash tests/run.sh` and `bash tests/mutation.sh` could not be
re-run here. The AC12 result rests on `verify.md` (`489 passed, 0 failed, 0
skipped`; mutation `61 checked passed, 0 failed`) and on a static read of the new
guard against the six surfaces it pins; that static read found every pin matched
and no self-failing negative-control token (see "Static verification of the new
guard").

## Prior finding resolution (N1)

The previous `review.md` returned `request-changes` on a single Nit `[N1]`: the
`/review` command still said "do not invent blockers" while the reviewer agent had
moved to "findings". That is now resolved in this tree without contradiction:

- `.opencode/command/review.md:36` reads `… do not invent findings.` — the noun on
  the command surface now matches the agent's rule (`.opencode/agent/reviewer.md:124-128`)
  and the two other "blockers" → "findings" corrections (`.opencode/agent/reviewer.md:144`,
  `docs/workflow.md:399`).
- `tests/checks/25-review-severity-bar.sh:88-90` pins `do not invent findings` on
  the command surface, so the two prompts cannot drift apart again.

No new finding replaces it.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — a surviving Minor/Nit (no Blocker/Major) yields `request-changes` | met | `.opencode/agent/reviewer.md:97-100` (any severity → `request-changes`), pinned `tests/checks/25-review-severity-bar.sh:63-65`. |
| AC2 — `approve` iff no finding of any severity survives | met | "`approve` if and only if no finding of any severity survives" on `reviewer.md:97-100`, `.opencode/skill/code-review/SKILL.md:58-61`, `docs/workflow.md:393-397`; pinned `25-review-severity-bar.sh:63-111`. |
| AC3 — a Minor/Nit-only `request-changes` derives `build (rework)` and routes to `/build` | met | The verdict→row mapping is severity-agnostic and untouched (`docs/workflow.md:1051`, `.opencode/skill/workflow-lifecycle/SKILL.md:38-39`); `tests/checks/20-lifecycle.sh:75-78` pins both. |
| AC4 — a fixed finding no longer counts and the verdict recomputes under AC2 | met (prompt-executed) | `reviewer.md:74-77` recomputes under AC2; the live fix→re-review outcome is a documented manual residual (`verify.md:59,123-129`). |
| AC5 — a sustained challenge overturns/recomputes; a rejected challenge leaves `request-changes` → `/build` | met (pins) / manual | Recompute on all four surfaces (`reviewer.md:74-77`, `.opencode/command/review.md:18`, `code-review/SKILL.md:75-78`, `docs/workflow.md:1000-1005`); the `Rejected` bullet is unchanged; live adjudication is prompt behavior. |
| AC6 — sustained-challenge recompute uses the all-severity bar | met | Every `Blocker or Major`-only recompute phrase is replaced; `25-review-severity-bar.sh:136-148` negates `Blocker or Major` on all six surfaces. |
| AC7 — no `approve` path leaves a Minor/Nit unresolved; not declinable, not reviewer-approvable | met | `code-review/SKILL.md:27-30` and `docs/artifact-conventions.md:446-449` define Minor/Nit as blocking/non-declinable; `reviewer.md:124-128` closes the question escape; `25-review-severity-bar.sh:125-131` pins the definitions and `:136-148` negates `not merge-blocking` / `the author may decline` / `waived` / `declined`. |
| AC8 — all six surfaces state the same bar; none calls a Minor/Nit non-blocking/declinable | met | `25-review-severity-bar.sh:63-111` pins the bar on all six; `:117-148` pins the preserved vocabulary and negates the old language. See "Questions" for the one non-gate summary line. |
| AC9 — a surviving Minor/Nit derives `build (rework)`, never `/ship`; the literal and route are unchanged | met | `tests/checks/20-lifecycle.sh:75-78` pins the unchanged `` `review.md` verdict `request-changes` `` literal; the derived-state row (`docs/workflow.md:1051`) is not in the diff. |
| AC10 — four severity labels and both verdicts unchanged; no new severity/disposition/marker/record/command/agent/skill | met | `25-review-severity-bar.sh:117-124` pins the six tokens on both definition surfaces and `:136-148` negates `waived`/`declined`; `tests/checks/30-permissions.sh`, `40-inventory.sh`, `96-signature-sweep.sh` are untouched by the diff (no agent/command/skill added). |
| AC11 — already-approved/shipped items are not rewritten or re-derived (forward-only) | met | `git status --porcelain -- work/` lists only this item's directory; no legacy `review.md`/`ship.md` is edited, and no derivation logic changed. |
| AC12 — `bash tests/run.sh` passes; six core commands, command→agent pairs, inventory counts unchanged | met (recorded) | `verify.md:34-36` records `489/0/0` and mutation `61/0/0`; the diff adds no command/agent/skill and touches no inventory table. Not re-executed here (read-only allowlist); the static check of the new guard below found no failing pin. |

## Findings

### Blockers

None.

### Major

None.

### Minor

None.

### Nits

None.

### Questions (not findings; do not block)

- **Reviewer handoff summary omits a `nits n` count** — `.opencode/agent/reviewer.md:143`.
  The closing block reads `Checks: ACs met x/y; blockers n; majors n; minors n;
  challenges adjudicated n.` With the new bar, a review whose only surviving
  findings are Nits still yields `request-changes`, yet the handoff would report
  `minors 0` and no Nit tally. This is a summary-count line, not a statement of the
  review gate: it does not assert that a Nit is non-blocking or declinable, the
  findings body still lists every Nit, and the line predates this change (it
  enumerated three of four severities before, too). I could not show it is a defect
  rather than a cosmetic gap, so it is recorded as a question rather than a
  classified finding. Follow-up option only: consider adding `nits n` for
  completeness; not required by any AC and not a blocker for this item.

## Static verification of the new guard

Read line-by-line against the six surfaces it pins (the suite could not be
executed here):

- `25-review-severity-bar.sh:38-45` — the file-existence loop `bad`s (never
  `skip`s) on a missing surface, as `design.md` §3 requires.
- `:63-111` — every `AC25 all-severity-bar` literal is present and flatten-safe
  (`flat "$f" | grep -qF`) on the current tree, including the two added
  question-escape pins (`:75-80`), which match `reviewer.md:124-128` after
  whitespace squeezing, and the new `do not invent findings` command pin
  (`:88-90`).
- `:117-131` — `AC25 contract-preserved` pins the four labels and two verdicts on
  both definition surfaces and pins the Minor/Nit `blocks the item` definitions.
- `:136-148` — the negative control over `Blocker or Major`, `not merge-blocking`,
  `the author may decline`, `waived`, and `declined` does not self-fail: none of
  the six surfaces contains any token (the new "declining to raise" / "cannot
  decline it" wording does not contain `declined`).
- The check uses only `lib.sh` constants (`AGENT_DIR`, `CMD_DIR`, `SKILL_DIR`,
  `WF`, `CONV`), is Bash 3.2-safe (no associative arrays/mapfile), never calls
  `exit`, and reads no live `work/**`.
- `tests/mutation.sh:412-425` — the two new mutations target the intended pins:
  `if any finding of any severity` first occurs at `reviewer.md:97` (the recompute
  line is `if and only if no finding of any severity`, so it is not hit), and the
  first `blocks the item` in `code-review/SKILL.md` is the Minor definition; each
  yields the expected `AC25 all-severity-bar` / `AC25 contract-preserved` line.

## Scope

The diff is exactly the nine files the design enumerates (six authority surfaces,
the new `tests/checks/25-review-severity-bar.sh`, `tests/mutation.sh`,
`tests/README.md`) plus this item's `tasks.md` check-box updates. No unrelated
files, no reformatting, no dependency additions, no secrets. `docs/artifact-conventions.md`
and `docs/workflow.md` changes are confined to the severity meanings and the
Review/challenge-adjudication gate text.

## Not reviewed / accepted

- **The spec's "fixture-based" guard expectation vs. the live-surface guard.**
  `spec.md:245-253` describes "any new guard" as fixture-based, while
  `design.md:243-249` rejects a fixture for this item (the deliverable is surface
  content, not per-item state) and builds a live-surface agreement check patterned
  on `50-instructions.sh` / `96-signature-sweep.sh`. The design's reasoning is
  sound and the guard satisfies the binding constraint (it never reads live
  `work/**`); the spec itself defers "exact surfaces and wording" to design
  (`spec.md:210-214`). Accepted, not a finding.
- **`visual.md` and the `visual`/`browser-verification` surfaces** keep their own
  severity language; the spec explicitly scopes `visual.md`'s own findings out
  (`spec.md:75-76`), and a visual finding is gated once classified in `review.md`.
- **Live behavioral criteria** (AC1/AC2 verdict choice, AC4 re-review, AC5
  adjudication) are prompt-executed and not CI-executable; `verify.md:121-138` and
  `tests/README.md:203-206` record the residual.
