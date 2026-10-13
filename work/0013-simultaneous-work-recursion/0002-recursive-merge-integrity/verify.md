---
feature: 0013-simultaneous-work-recursion/0002-recursive-merge-integrity
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
notes: "Documentation/prompt-only change to three surfaces (docs/workflow.md, docs/artifact-conventions.md, .opencode/skill/merge-conflict/SKILL.md). No committed test file was added: the spec's non-goals explicitly defer committed recursive merge-integrity fixtures/agreement areas to Roadmap 5 and AC13 confines the change set to the three named surfaces (spec.md:105-107, 232-239); the authoritative verification level is authority inspection plus the configured suite (spec.md:354-359). No `challenges.md` exists, so there was no open challenge to adjudicate; no prior `verify.md` defect. Ordinary forward work; item unshipped. All 15 ACs and all 11 spec edge cases verified on the current working tree."
---

# Verification — Merge integrity and renumbering for recursive trees

## Summary

This is a docs-and-prompt change that generalizes the merge-integrity contract
from its shipped two-level cap to arbitrary depth across the three surfaces the
spec fixes. Verification is (1) the repository's configured suite, and (2) an
independent, read-only, falsifiable document harness (50 assertions, one or more
per acceptance criterion) run against the live surfaces. **No acceptance-criterion
defect was found; every AC and every spec edge case is covered.** No committed
test was added — by design, per the spec's explicit non-goal and AC13/AC14.

There is no `work/0013-simultaneous-work-recursion/0002-recursive-merge-integrity/challenges.md`,
so there was no open challenge to adjudicate.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | **PASS** | exit 0; `TOTAL: 495 passed, 0 failed, 0 skipped`. The configured suite (AGENTS.md Project profile `Test:`). |
| `FRAMEWORK_TEST_AREAS=40-inventory bash tests/run.sh` | **PASS** | exit 0; `TOTAL: 39 passed, 0 failed, 0 skipped` — documented inventory counts unchanged (AC14). |
| `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` | **PASS** | exit 0; `TOTAL: 49 passed, 0 failed, 0 skipped` — pinned finding grammar, `planning-time`, and forbidden-prefix absence intact (AC11). |
| `FRAMEWORK_TEST_AREAS=96-signature-sweep bash tests/run.sh` | **PASS** | exit 0; `TOTAL: 86 passed, 0 failed, 0 skipped`. |
| inline read-only document harness (`bash -s`, 50 assertions) | **PASS** | `HARNESS TOTAL: 50 passed, 0 failed`; exit 0. Independent, falsifiable greps of the live surfaces (one or more per AC). |
| `git diff --name-only` | **PASS** | `.opencode/skill/merge-conflict/SKILL.md`, `docs/artifact-conventions.md`, `docs/workflow.md`, plus this item's `work/…/tasks.md` (builder box-ticks only) — exactly the three surfaces (AC13). |
| `git diff --name-only \| grep -E 'README\|\.opencode/agent\|\.opencode/command\|^tests/'` | **PASS** | empty — no excluded surface, command/agent, README, or test touched (AC13). |
| `git diff -U0 -- docs/workflow.md \| grep -E '^@@'` | **PASS** | hunks only at the `(c)` taxonomy row, "Lifecycle placement", the guard enforcement bullets/scope sentence, the `DUPLICATE-CHILD` row, and "Relationship to renumbering". |
| `git diff -U0 -- docs/artifact-conventions.md \| grep -E '^@@'` | **PASS** | exactly two hunks: renumber step 1 (`:701`) and step 4 (`:714`); "Sequence allocation" untouched. |
| `git diff \| grep -E '^\+.*phase:'` | **PASS** | empty — no new `phase` value or state model (AC15). |
| `git diff \| grep '^+' \| grep -oE '\(e\)\|DECLARED-[A-Z]+\|PLAN-[A-Z]+\|CONFLICT-[A-Z]+'` | **PASS** | empty — no new finding code/class/prefix (AC11). |
| `git diff \| grep '^+' \| grep -oE '\b[A-Z]{3,}-[A-Z]{2,}\b' \| sort -u` | **PASS** | only `DUPLICATE-CHILD`, `DUPLICATE-PREFIX` — both shipped codes (AC11). |
| `grep -nE 'top-level and per-parent\|per-parent \`MMMM\`\|per-parent roadmap' docs/workflow.md` | **PASS** | no match — old two-level post-merge/taxonomy wording removed (AC2). |

## Acceptance coverage

For a prose deliverable, each criterion's test is a targeted static-content
assertion against the three live surfaces (`file:line` cited), executed by the
inline harness and backed by the full suite. The three initially-failing
assertions were line-wrap artifacts in the assertion string (the content is
present across a wrapped line) and were re-run whitespace-normalized; see
"Gaps and residual risk".

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — class `(c)` surface reaches arbitrary depth | harness `AC1 (c) same parent at any node` + `any decomposing node at any depth`; `docs/workflow.md:1441`; `(a)`/`(b)`/`(d)` rows unchanged (`:1439,1440,1442`) | PASS |
| AC2 — post-merge pass at every node | harness `AC2 every node of recursive tree` + `its own node Children` + old-wording-absent; `docs/workflow.md:1450-1457` | PASS |
| AC3 — guard scope: invariant set at every node | harness `AC3 evaluated at every node` + `no node depends on another`; `docs/workflow.md:1500` | PASS |
| AC4 — duplicate rows explicit + single-sourced | harness `AC4 DUPLICATE-PREFIX row` + `DUPLICATE-CHILD row any depth` + `single-source pointer`; `docs/workflow.md:1506-1507,1500` | PASS |
| AC5 — both enforcement points at every node | harness `AC5 /status at every node` + `/ship post-merge at every node` + `neither defines separate guard`; `docs/workflow.md:1492-1498` | PASS |
| AC6 — renumber detect at any depth | harness `AC6` ×6; `docs/artifact-conventions.md:701-707` | PASS |
| AC7 — whole-subtree rewrite | harness `AC7` ×7; `docs/artifact-conventions.md:714-724` | PASS |
| AC8 — renumber at any depth, one rule | harness `AC8` ×3; `docs/workflow.md:1532-1535` | PASS |
| AC9 — skill guard/enforcement passages generalize | harness `AC9` ×7; `SKILL.md:73-79` (pre-flight), `:80-86` (graph faults), `:91-99` (cross-branch), `:291-297` (post-merge), `:373-413` (reconcile detect/move) | PASS |
| AC10 — single authority, no competing rule | harness pointers: `docs/workflow.md:1500`; `docs/artifact-conventions.md:690-691,704-705`; `SKILL.md:78-79,370`; only the shipped duplicate rule/guard/renumber authority carry the rule | PASS |
| AC11 — shipped vocabulary reused | harness `AC11` ×13; `docs/workflow.md:1506-1513`; suite `85-conflict-guards` PASS (49/0/0); `SKILL.md:106,132` | PASS |
| AC12 — report-only, non-fatal, offline/local, no-op | harness `AC12` ×6; `docs/workflow.md:1515-1522,1459`; `SKILL.md:66-67,98,299-302` | PASS |
| AC13 — scope: three surfaces only | `git diff --name-only` + excluded-surface grep (both empty of excluded paths); `docs/workflow.md`/`docs/artifact-conventions.md`/`SKILL.md` only | PASS |
| AC14 — suite green, inventory unchanged | `bash tests/run.sh` → 495/0/0; `FRAMEWORK_TEST_AREAS=40-inventory` → 39/0/0; `README.md` unmodified; no `work/**` shipped file or `ship.md` touched | PASS |
| AC15 — backward compatibility | `git diff` strict generalization; `git diff -U0` shows "Multiple work items" and "Sequence allocation" untouched; no `phase:` token added; no work-item rename / spent-number / `ship.md` change | PASS |

### Edge cases (spec → "Edge cases")

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Collision at depth three and deeper | AC6 (full canonical ref, depth-≥ 3 shared parent/prefix, `docs/artifact-conventions.md:701-707`); AC7 (whole subtree) | PASS |
| The chosen node itself decomposes | AC7 sweep lists `every descendant`/`intermediate manifest` (`docs/artifact-conventions.md:714-724`; `SKILL.md:399-413`) | PASS |
| Same local id under different parents (not a duplicate) | Unchanged rule `docs/workflow.md:1402-1403` ("identity is the full canonical path, not the trailing segment"); AC6 full canonical reference | PASS |
| Top-level vs same-parent collision (mutually exclusive) | AC4: `DUPLICATE-PREFIX` = top-level, `DUPLICATE-CHILD` = same-parent at any depth (`docs/workflow.md:1506-1507`) | PASS |
| `.gitkeep`-only / pure-container / hybrid nodes | `SKILL.md:73-79` scans each node's immediate children with no container/hybrid distinction; `docs/workflow.md:1402-1403` unchanged per-node rule | PASS |
| Parent with zero or one child | Derived: no same-parent pair exists → no collision, no error; a consequence of the per-node scan (`docs/workflow.md:1500`; `docs/artifact-conventions.md:701-704`) | MANUAL (derived) |
| Cross-branch collision with no counterpart | `SKILL.md:96-98` — "report a collision when a 4-digit prefix is shared by two different canonical references" | PASS |
| Legacy `roadmap.md` alias | `SKILL.md:80-81` accepts "its `manifest.md`, or the legacy `roadmap.md` alias"; `docs/workflow.md:1500` says "each decomposing node at any depth" | PASS |
| Already-shipped offender | Choose step unchanged: not-approved/not-shipped then later-commit-time (`docs/artifact-conventions.md:708-711`; `SKILL.md:385-397`) | PASS |
| Empty `work/` tree / up-to-date branch | `docs/workflow.md:1521-1522` ("no-ops that report **no findings** and **does not error**"); `:1459` | PASS |
| Concurrency | Read-only, no lock: `docs/workflow.md:1490-1492`; `SKILL.md:66-67` | PASS |

## Gaps and residual risk

- **No committed regression test was added — by design, not omission.** The
  spec's non-goals explicitly defer "committed fixtures, agreement areas, or
  mutation coverage pinning the recursive merge-integrity contract" to a
  successor roadmap (Roadmap 5), and AC13 confines the change set to the three
  named surfaces (`spec.md:105-107, 232-239`). The design's own test strategy is
  authority inspection plus the configured suite (`design.md:306-331`). Evidence
  therefore rests on the 50-assertion harness above plus the unchanged green
  suite. Adding a committed check would violate the item's declared scope.
- **Prompt-behavior-only criteria.** AC1–AC12 describe normative prose and
  prompt behavior, not executable code; the guard is explicitly "prompt behavior
  only" with no committed checker (`docs/workflow.md:1489-1490`). The live
  `/status` read-only window and the `/ship` post-merge pass emitting recursive
  findings at depth ≥ 3 remain a **documented manual check**, identical to the
  pre-existing two-level residual; there is no runtime to exercise offline.
- **Residual `per-parent` shorthand in the `merge-conflict` skill.** Three spots
  keep the shipped term as a generic synonym for "same-parent": the pre-flight
  vocabulary table (`SKILL.md:126`), the classify step (`:260-261`), and the
  renumber "Choose" step (`:394`). These are outside the four passages AC9
  enumerates (and the design's item 6 scoped the reconcile edit to Detect and
  Move); the term is depth-generic ("for each parent"), does not cap at two
  levels, and is governed by the immediately preceding generalized Detect step.
  Recorded as an observation, not a defect; a future wording sweep could align
  the term to "same-parent at any depth".
- **Lateral two-level summaries remain, deferred by the spec.** The `status`
  agent, `shipper` agent, and `ship`/`status` command surfaces still carry
  two-level wording (`.opencode/agent/status.md:227`, `.opencode/agent/shipper.md:203`,
  `.opencode/command/ship.md:41`, `.opencode/command/status.md:60`). The spec
  explicitly defers these to Roadmap 4 and excludes them here (non-goals
  `spec.md:99-104`; AC13). They are report-only and not contradictory in effect.
  Recorded, not a defect.
- **Verification is read-only and exercised no runtime.** The deliverable is
  normative prose; a reviewer should confirm the prose is the intended normative
  contract. No production file was modified during testing; the only files this
  phase touched are `verify.md` (this file) and, previously, the builder's
  `tasks.md` box-ticks.

No failing tests, no defects, no open challenges. `tasks.md` T1–T8 are all `[x]`.
