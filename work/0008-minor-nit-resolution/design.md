---
feature: 0008-minor-nit-resolution
phase: design
status: final
created: 2026-10-09
updated: 2026-10-09
conflicts-with: "tests/checks, tests/README.md, tests/mutation.sh, 0007-phase-backtracking/0007-backtracking-guards"
notes: "Ordinary forward progression: work/0008-minor-nit-resolution/backtracks.md does not exist, so no open /plan finding and no resolution entry. Resolves the spec's one deferred design question (exact surfaces and wording) by naming the six in-scope surfaces and fixing the literal replacement text below. Adopts the spec's two design-blocking assumptions because both are entailed by the spec's own non-goals: (1) a question records genuine uncertainty and never a declined Minor/Nit — pinned explicitly in the reviewer prompt; (2) the challenge/response record is reused unchanged. New committed guard is a live-surface agreement check tests/checks/25-review-severity-bar.sh with suite token AC25, not AC24 — AC24 is already claimed by the unshipped sibling plan 0007-phase-backtracking/0007-backtracking-guards, which is the declared conflict target. The guard never reads live work/**."
---

# Design — Minor and nit resolution routing

## Summary

Replace the Blocker/Major-only review gate with an all-severity bar across the
six surfaces that state it: a surviving finding of **any** severity
(`Blocker`, `Major`, `Minor`, or `Nit`) yields `request-changes`, and `approve`
requires that no finding of any severity survives. The change is a literal text
rewrite of the reviewer agent, the `/review` command, the `code-review` skill,
`docs/workflow.md`, `docs/artifact-conventions.md`, and the
`workflow-lifecycle` skill; nothing else in the lifecycle changes. One new
committed agreement area, `tests/checks/25-review-severity-bar.sh` (suite token
`AC25`), pins the bar on those six committed surfaces so the old language cannot
return, and proves it via `tests/mutation.sh`.

## Approach

### 1. The contract in one sentence

The rule now stated identically on every in-scope surface:

> `request-changes` if any finding of any severity survives scrutiny; `approve`
> if and only if no finding of any severity survives. A finding adjusted to
> `Minor` or `Nit` still blocks; only an overturn removes it.

This reuses the existing four-severity scale, the existing
`approve` / `request-changes` verdict, the existing `request-changes` →
`build (rework)` derived row, and the existing challenge/response loop. It adds
no severity, disposition, marker, record type, command, agent, or skill.

### 2. The six surfaces and their exact new text

Every edit below is a literal replacement; no wording is left to the builder.
`T1`–`T3` in `tasks.md` execute this table.

**S1 — `.opencode/agent/reviewer.md`**

- S1a, process step 1 (the `**Sustained**` bullet): replace ``Recompute the
  verdict: `approve` if and only if no `Blocker` or `Major` remains.`` with

  ``Recompute the verdict: `approve` if and only if no finding of any severity
  (`Blocker`, `Major`, `Minor`, or `Nit`) remains. A finding adjusted to `Minor`
  or `Nit` still blocks; only an overturn removes it.``

- S1b, process step 7: replace ``Set the verdict: `request-changes` if any
  Blocker or Major finding survives scrutiny; otherwise `approve`.`` with

  ``Set the verdict: `request-changes` if any finding of any severity
  (`Blocker`, `Major`, `Minor`, or `Nit`) survives scrutiny; `approve` if and
  only if no finding of any severity survives.``

- S1c, `<rules>` (the "Do not approve to be agreeable" rule): replace ``Do not
  invent blockers to look thorough. When unsure, mark it as a question in the
  findings rather than a defect.`` with

  ``Do not invent findings to look thorough. When unsure, mark it as a question
  in the findings rather than a defect — a question records genuine uncertainty,
  never a classified `Minor` or `Nit` you are declining to raise. A finding you
  can classify as any severity must be recorded as a finding and blocks under
  the verdict rule above.``

- S1d, `<handoff>`: change ``otherwise `/build <item-ref>` to address blockers;``
  to ``otherwise `/build <item-ref>` to address findings;``.

**S2 — `.opencode/command/review.md`** (challenge-adjudication bullet): replace
``recompute the verdict (`approve` if and only if no `Blocker` or `Major`
remains)`` with

``recompute the verdict (`approve` if and only if no finding of any severity
remains)``.

**S3 — `.opencode/skill/code-review/SKILL.md`**

- S3a, `## Severity`: replace

  ```
  - **Minor** — worth fixing; not merge-blocking.
  - **Nit** — style or preference; the author may decline.
  ```

  with

  ```
  - **Minor** — worth fixing; blocks the item. Must be fixed or overturned
    through the challenge loop; the author cannot decline it.
  - **Nit** — style or preference; blocks the item. Must be fixed or overturned
    through the challenge loop; the author cannot decline it.
  ```

- S3b, `## Verdict`: replace ``- `request-changes` if any Blocker or Major
  survives scrutiny.`` / ``- `approve` otherwise.`` / ``- Never invent blockers
  to seem thorough, and never approve to be agreeable.`` with

  ```
  - `request-changes` if any finding of any severity (`Blocker`, `Major`,
    `Minor`, or `Nit`) survives scrutiny.
  - `approve` if and only if no finding of any severity survives. Approving is
    not a rubber stamp; state why it is ready.
  - Never invent findings to seem thorough, and never approve to be agreeable —
    a surviving `Minor` or `Nit` is not a reason to approve.
  ```

- S3c, `## Disputed findings`: replace ``recomputes the verdict: `approve` if
  and only if no Blocker or Major remains.`` with

  ``recomputes the verdict: `approve` if and only if no finding of any severity
  remains. A finding adjusted to `Minor` or `Nit` still blocks; only an overturn
  removes it.``

**S4 — `docs/workflow.md`**

- S4a, phase 5 Review `Exit` bullet: after ``every finding has a severity, a
  location, and an actionable recommendation.`` append

  ``A finding of any severity — `Blocker`, `Major`, `Minor`, or `Nit` — that
  survives scrutiny yields `request-changes`; `approve` requires that no finding
  of any severity survives.``

- S4b, phase 5 Review `Next` bullet: change ``otherwise `/build` to address
  blockers.`` to ``otherwise `/build` to address findings.``

- S4c, `## Findings challenge and adjudication` → `### Outcomes and routing`:
  replace ``the review verdict is recomputed — `approve` if and only if no
  `Blocker` or `Major` remains.`` with

  ``the review verdict is recomputed — `approve` if and only if no finding of
  any severity (`Blocker`, `Major`, `Minor`, or `Nit`) remains. A finding
  adjusted to `Minor` or `Nit` still blocks; only an overturn removes it.``

**S5 — `docs/artifact-conventions.md`** (`### review.md`, `Severity meanings`):
replace

```
- **Minor** — worth fixing; not merge-blocking.
- **Nit** — style or preference; take it or leave it.
```

with

```
- **Minor** — worth fixing; blocks the item. Must be fixed or overturned through
  the challenge loop; the author cannot decline it.
- **Nit** — style or preference; blocks the item. Must be fixed or overturned
  through the challenge loop; the author cannot decline it.
```

**S6 — `.opencode/skill/workflow-lifecycle/SKILL.md`**

- S6a, `## Which command now?`: change
  ``review.md verdict request-changes→ /build [item-ref or task-id]   (rework blockers)``
  to ``...(rework findings)``. The pinned prefix `review.md verdict
  request-changes` is preserved, so `20-lifecycle.sh` stays green.
- S6b, `## Derived states`, the `build (rework)` bullet: replace ``the existing
  `review.md` verdict `request-changes` row. It is distinct from `backtracked`…``
  with ``the existing `review.md` verdict `request-changes` row, produced by a
  surviving finding of any severity (`Blocker`, `Major`, `Minor`, or `Nit`). It
  is distinct from `backtracked`…``.

### 3. The new committed guard

`tests/checks/25-review-severity-bar.sh` is a **live-surface agreement check**
(the same category as `50-instructions.sh` and `96-signature-sweep.sh`): it reads
six committed surfaces with `grep`/`awk`, is sourced by `tests/run.sh`, is Bash
3.2 compatible, never calls `exit`, and never reads live `work/**`. No fixture
tree is needed because the contract is surface content, not per-item state.

It uses `AGENT_DIR`, `CMD_DIR`, `SKILL_DIR`, `WF`, and `CONV` from `tests/lib.sh`
and pins the six surfaces as constants. Two sub-areas, each assertion labelled
`AC25 <sub-area>` so a mutation names the guard it trips:

- **`AC25 all-severity-bar`** — positive: each surface states the bar. Because
  the phrases span wrapped lines, the check flattens a surface
  (`tr '\n' ' ' | tr -s ' '`) before a fixed-string match. Exact flattened
  literals:

  | Surface | Required literal (flattened) |
  | ------- | ---------------------------- |
  | `reviewer.md` | ``Set the verdict: `request-changes` if any finding of any severity`` |
  | `reviewer.md` | ``Recompute the verdict: `approve` if and only if no finding of any severity`` |
  | `reviewer.md` | ``A finding adjusted to `Minor` or `Nit` still blocks; only an overturn removes it.`` |
  | `command/review.md` | ``recompute the verdict (`approve` if and only if no finding of any severity remains)`` |
  | `code-review/SKILL.md` | `` `request-changes` if any finding of any severity`` |
  | `code-review/SKILL.md` | `` `approve` if and only if no finding of any severity survives`` |
  | `code-review/SKILL.md` | ``recomputes the verdict: `approve` if and only if no finding of any severity remains`` |
  | `docs/workflow.md` | ``A finding of any severity — `Blocker`, `Major`, `Minor`, or `Nit` — that survives scrutiny yields `request-changes``` |
  | `docs/workflow.md` | ``if and only if no finding of any severity (`Blocker`, `Major`, `Minor`, or `Nit`) remains`` |
  | `workflow-lifecycle/SKILL.md` | ``produced by a surviving finding of any severity (`Blocker`, `Major`, `Minor`, or `Nit`)`` |
  | `workflow-lifecycle/SKILL.md` | ``(rework findings)`` |

- **`AC25 contract-preserved`** — the negative/unchanged half. Positive: the
  four severity labels and both verdicts still appear on both definition
  surfaces (`code-review/SKILL.md`, `docs/artifact-conventions.md`), and both
  Minor/Nit definition lines carry `blocks the item`. Negative: across all six
  surfaces, none contains `Blocker or Major`, `not merge-blocking`, or
  `the author may decline`, and none contains a new disposition token
  (`waived` / `declined`). This is what keeps AC7 and AC10 honest.

Structural: each of the six surface files must exist, else a labelled `bad`
(never `skip`).

### 4. Mutation self-check

`tests/mutation.sh` already stages `.opencode/{agent,command,skill}` and
`docs/*.md`, so no `stage()` change is needed for these surfaces. Add two blocks
(the check is not optional-tool dependent), using the existing `replace_first`,
each followed by `restore_file` and `assert_clean_absent`:

| # | Mutation (on the copy) | Expected named sub-area |
| - | ---------------------- | ----------------------- |
| 1 | `reviewer.md`: replace `if any finding of any severity` → `if any finding of high severity` | `AC25 all-severity-bar` |
| 2 | `code-review/SKILL.md`: replace the first `blocks the item` → `not merge-blocking` | `AC25 contract-preserved` |

Also extend the `mutation.sh` header comment's covered-area list to include
`AC25`.

### 5. Documentation

`tests/README.md` gains a Checks-table row for `25-review-severity-bar.sh`
(suite token `AC25`), a paragraph mapping `AC25` to this item's acceptance
criteria and declaring the two sub-areas and the never-reads-`work/**` contract,
and a manual-residual sentence: a live re-review or an actual challenge
adjudication is prompt behavior and is not executable in CI (the same residual
class the cycle diagnostic records).

## Alternatives considered

- **Extend `20-lifecycle.sh` in place instead of a new area.** Pros: no new file
  or token. Cons: `20-lifecycle.sh` owns routing/derived-state agreement and is
  referenced by the sibling guard's `no-duplication` assertion; folding the
  review bar into it couples two contracts under one token and one mutation
  namespace, and would make an existing area's failure diagnosis ambiguous.
  **Rejected** for a dedicated `25-review-severity-bar.sh` with token `AC25`.
- **A fixture-based guard over a synthetic `review.md`/`challenges.md` tree.**
  Pros: matches the "fixture-based" instinct and could exercise a computed
  verdict. Cons: the deliverable is the *prompt/doc text*, not per-item state;
  there is no mechanical verdict computation in the suite to exercise, so a
  fixture would only duplicate sentences already present on the live surfaces
  and would not prove the surfaces agree. **Rejected** for a live-surface
  agreement check that reads the six committed surfaces and never `work/**`.
- **Guard by positive pins only (no negative control).** Pros: smaller. Cons: it
  would pass if a surface *added* the old "not merge-blocking" language beside
  the new bar, and would not catch the regression the change exists to prevent.
  **Rejected** — the `contract-preserved` sub-area adds the negative absence
  pins.
- **Take suite token `AC24`.** Pros: next monotonic number. Cons: the unshipped
  sibling plan `0007-phase-backtracking/0007-backtracking-guards` already fixes
  `AC24` and adds a mutation namespace for it; pre-empting it would collide when
  both merge. **Rejected** for `AC25`, and the sibling is named in
  `conflicts-with`.
- **A committed executable production checker for the bar.** Pros: runnable
  outside the suite. Cons: the workflow's guards remain prompt behavior with no
  committed production checker; the suite's checks are test-scoped agreement
  areas. **Rejected** for a `tests/checks` area only.

## Interfaces and data model

**New check file:** `tests/checks/25-review-severity-bar.sh` (filename order
between `20-lifecycle.sh` and `30-permissions.sh`). Stable token `AC25`, pure
bash/awk, no optional tool, sourced by `tests/run.sh` (must not `exit`). Sub-areas
`all-severity-bar` and `contract-preserved`.

**Read surfaces** (all committed, none under `work/`):

```
$AGENT_DIR/reviewer.md
$CMD_DIR/review.md
$SKILL_DIR/code-review/SKILL.md
$WF                        # docs/workflow.md
$CONV                      # docs/artifact-conventions.md
$SKILL_DIR/workflow-lifecycle/SKILL.md
```

**Changed surfaces:** `.opencode/agent/reviewer.md`,
`.opencode/command/review.md`, `.opencode/skill/code-review/SKILL.md`,
`docs/workflow.md`, `docs/artifact-conventions.md`,
`.opencode/skill/workflow-lifecycle/SKILL.md`,
`tests/checks/25-review-severity-bar.sh` (new), `tests/mutation.sh`,
`tests/README.md`.

**Deliberately unchanged:** the finding format and finding ids; the
challenge/response record and its adjudication; the `approve` /
`request-changes` verdict vocabulary; the four severity labels; the derived-state
literal `` `review.md` verdict `request-changes` | build (rework) `` and its
route; the `reviewer` agent's declared permissions; `AGENTS.md`, `README.md`,
`template/**`, `opencode.json`; the `/fix` track; readiness, conflict, roadmap,
and merge-conflict contracts; and every already-approved or already-shipped
`work/` artifact.

**Backward compatibility and migrations:** none required. The change is
forward-only. A `review.md` written before the change keeps its recorded verdict
and phase; nothing re-derives a legacy `approve` as blocked. No frontmatter
field, `phase` value, marker, or state file is added, and the suite stays
read-only and fresh-clone-clean.

## Affected areas

- `.opencode/agent/reviewer.md` — the verdict and sustained-challenge recompute,
  the question-escape clarification, the handoff (S1).
- `.opencode/command/review.md` — the challenge recompute clause (S2).
- `.opencode/skill/code-review/SKILL.md` — severity definitions, verdict,
  disputed-findings recompute (S3).
- `docs/workflow.md` — Review phase and challenge outcomes/routing (S4).
- `docs/artifact-conventions.md` — `review.md` severity meanings (S5).
- `.opencode/skill/workflow-lifecycle/SKILL.md` — routing label and derived-state
  bullet (S6).
- `tests/checks/25-review-severity-bar.sh` — new agreement area (`AC25`).
- `tests/mutation.sh` — two mutations and the header comment list.
- `tests/README.md` — Checks-table row, `AC25` mapping paragraph, manual
  residual.

## Risks and mitigations

- **A duplicated surface is missed and keeps the old rule** — likelihood medium /
  impact high. Mitigation: the six in-scope surfaces are enumerated from the
  spec's AC8 and confirmed by a repository-wide grep for the old literals; the
  `contract-preserved` sub-area negates `Blocker or Major`,
  `not merge-blocking`, and `the author may decline` on all six.
- **The new guard is mistaken for a production checker** — likelihood medium /
  impact low. Mitigation: name it an agreement area; the file header and
  `tests/README.md` state it is test-scoped, live-surface test code like
  `50-instructions.sh`/`96-signature-sweep.sh`, reads no live `work/**`, and is
  invoked by no command.
- **Suite-token collision with the sibling `0007` guard** — likelihood medium /
  impact medium. Mitigation: this item takes `AC25` (AC24 is claimed); the
  sibling is named in `conflicts-with`; a merge that collides is resolved by the
  existing renumber/merge contract, and the two guards pin disjoint surfaces.
- **Literal drift between the design's replacement text and the guard** —
  likelihood medium / impact high. Mitigation: the guard's pins are the exact
  flattened phrasings from §2; T4's `Verify:` runs the guard against the surfaces
  edited in T1–T3, so a mismatch fails immediately.
- **A mutation trips more than one sub-area** — likelihood medium / impact low.
  Mitigation: `run.sh` runs every check and checks never `exit`, so all failures
  are logged; `check_mutation` asserts the expected sub-area substring is
  present, and both labels are independently reachable.
- **`tests/README.md` edits break an existing agreement check** — likelihood low
  / impact medium. Mitigation: the Checks-table row names only the new file; the
  `95-split-guard` copy-set scan needs the three `template/` sources, which the
  intro already carries and the new row does not disturb; T6 runs the suite.
- **Bash 4 syntax breaks 3.2 compatibility** — likelihood low / impact high.
  Mitigation: no associative arrays/mapfile; follow `lib.sh`/`50`/`96` patterns;
  `bash tests/run.sh` is the gate.
- **The bar is read as banning genuine questions** — likelihood low / impact
  medium. Mitigation: S1c explicitly scopes a question to genuine uncertainty and
  forbids using it to avoid classifying a `Minor`/`Nit`.

## Test strategy

| Criterion | Verification |
| --------- | ------------ |
| AC1 | `AC25 all-severity-bar` pins the reviewer verdict line: any severity survives → `request-changes`. |
| AC2 | `AC25 all-severity-bar` pins the reviewer, command, code-review, and workflow bar phrases: any surviving severity → `request-changes`; `approve` iff none. |
| AC3 | `AC25 all-severity-bar` proves the bar; `20-lifecycle.sh` (unchanged) proves the severity-agnostic `` `review.md` verdict `request-changes` `` → `build (rework)` route and `/build`. |
| AC4 | The reviewer recompute (`AC25 all-severity-bar`, S1a) recomputes under AC2 after re-review; the fixed finding is gone, so `approve` follows. Prompt behavior; residual recorded in `tests/README.md`. |
| AC5 | `AC25 all-severity-bar` pins the sustained-challenge recompute (S1a, S2, S3c, S4c); `AC25 contract-preserved` pins that a Minor/Nit still blocks and is not declinable. A rejected challenge leaves `request-changes` → `/build` per the unchanged route. |
| AC6 | Same recompute pins as AC5, all all-severity; the prior Blocker/Major-only phrasing is negated by `AC25 contract-preserved` (`Blocker or Major` absent). |
| AC7 | `AC25 contract-preserved` pins the Minor/Nit `blocks the item` definitions and negates `not merge-blocking` / `the author may decline`; S1c closes the question loophole. |
| AC8 | `AC25 all-severity-bar` asserts the bar on all six surfaces; `AC25 contract-preserved` asserts none carries the old language. |
| AC9 | `20-lifecycle.sh` pins the unchanged `` `review.md` verdict `request-changes` `` literal and route; T7 confirms no derived-state row changed. |
| AC10 | `AC25 contract-preserved` pins the four labels and two verdicts and negates new disposition tokens; `40-inventory.sh` and `96-signature-sweep.sh` stay green (no command/agent/skill/inventory change). |
| AC11 | T7: `git status --porcelain -- work/` shows only `work/0008-minor-nit-resolution/`; no already-approved/shipped `work/` artifact is edited or re-derived. Forward-only, no migration. |
| AC12 | `bash tests/run.sh` exit 0 in every task; `bash tests/mutation.sh` exit 0 (two new `AC25` mutations caught and named); the six core commands, their command→agent pairs, and the README inventory counts are untouched. |
