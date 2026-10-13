---
feature: 0011-recursive-bootstrap/0004-recursive-readiness
phase: test
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Verification — Readiness, derived state, and status across recursion

## Summary

The deliverable is framework documentation and prompts (no runtime code). The
implementation changes exactly four surfaces outside `work/` —
`docs/workflow.md`, `.opencode/agent/status.md`, `.opencode/command/status.md`,
and `.opencode/skill/workflow-lifecycle/SKILL.md` — and touches no test file.
Verification is therefore the committed suite (which stays green and pins every
single-source literal) plus reproducible content probes over the authored text.
No implementation, spec, or design defect was found; the item is `final`.

No `challenges.md` exists for this item, so there was no open challenge to
adjudicate.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 489 passed, 0 failed, 0 skipped`, exit 0 (baseline and final) |
| `FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh` | PASS | 8 passed, 0 failed — readiness single-source guard |
| `FRAMEWORK_TEST_AREAS=10-readiness,80-cycle-fixture,87-backtrack-guards bash tests/run.sh` | PASS | 126 passed, 0 failed (T1 scope) |
| `FRAMEWORK_TEST_AREAS=20-lifecycle,80-cycle-fixture bash tests/run.sh` | PASS | 79 passed, 0 failed (T2 scope) |
| `FRAMEWORK_TEST_AREAS=20-lifecycle,87-backtrack-guards bash tests/run.sh` | PASS | 167 passed, 0 failed (T3 scope) |
| `FRAMEWORK_TEST_AREAS=10-readiness,20-lifecycle,80-cycle-fixture,85-conflict-guards bash tests/run.sh` | PASS | 130 passed, 0 failed (T4 scope) |
| `FRAMEWORK_TEST_AREAS=80-cycle-fixture,96-signature-sweep bash tests/run.sh` | PASS | 105 passed, 0 failed (T5 scope) |
| `FRAMEWORK_TEST_AREAS=20-lifecycle,96-signature-sweep bash tests/run.sh` | PASS | 154 passed, 0 failed (T6 scope) |
| `FRAMEWORK_TEST_AREAS=40-inventory,96-signature-sweep bash tests/run.sh` | PASS | 131 passed, 0 failed — no inventory/signature change (AC11) |
| `grep -c 'satisfied(dep_local_id):' docs/workflow.md` | `1` | Algorithm marker single-sourced in the authority |
| `grep -rl 'satisfied(dep_local_id):' .opencode/` | (empty) | No deferring surface restates the branch sequence |
| `git status --porcelain -- . ':!work'` | 4 modified files | Exactly the four authorized surfaces; no additions |
| `git status --porcelain -- tests/` | (empty) | No test file added, weakened, skipped, or deleted |
| Content probes (`/tmp/opencode/verify-0004.sh`) | PASS | 39 passed, 0 failed — one grep assertion per criterion clause |

## Acceptance coverage

The deliverable is a document contract; per the spec's test strategy and non-goal
(committed recursive-readiness guards are deferred to a successor roadmap), each
criterion is verified by the committed suite where a pinned literal exists, and
by a reproducible content probe otherwise. "Probe" identifiers below are the
`chk` labels in `/tmp/opencode/verify-0004.sh`; the underlying commands are plain
`grep`s against the named file.

| Criterion | Test(s) / probe | Result |
| --------- | --------------- | ------ |
| AC1 | probe `AC1 workflow states sibling-only`; `AC1 ancestor/descendant/cousin/cross-tree named`; `AC1 non-sibling -> DANGLING-DEP`; `AC1 no new dependency edge kind` (`docs/workflow.md:176-181`) | PASS |
| AC2 | probe `AC2 same rule independently at every level`; `AC2 child_dir rooted at node-ref` (`docs/workflow.md:184-192`); `AC2 marker exactly once`; `AC2 marker absent from .opencode`; `AC2 status agent/command defers`; `10-readiness.sh` (marker exactly once) | PASS |
| AC3 | probe `AC3 decomposing target own-signal only`; `AC3 descendants not consulted` (`docs/workflow.md:211-213`) | PASS |
| AC4 | probe `AC4 own phase artifacts first`, `AC4 qualified roadmap row` (`docs/workflow.md:1149-1163`), plus the same statement in `status.md`, `command/status.md`, `SKILL.md`; `20-lifecycle.sh`/`87-backtrack-guards.sh` green | PASS |
| AC5 | probe `AC5 structural stale/reopened first`; `AC5 no new phase value`; `AC5 no second state model` (`docs/workflow.md:1153-1156`); `87-backtrack-guards.sh` labels green | PASS |
| AC6 | probe `AC6 indented to arbitrary depth`, `AC6 blocked: <local ids>` (`docs/workflow.md:292-297`), status agent and command indentation clauses; `80-cycle-fixture.sh` green | PASS |
| AC7 | probe `AC7 <ready>/<total> ready`, `AC7 phase distribution tally`, `AC7 readiness never stored`, `AC7 blocked child names siblings` (`docs/workflow.md:299-303`) | PASS |
| AC8 | probe `AC8 recall revocation`, `AC8 cycle rule`, `AC8 even-if-unshipped`, `AC8 presence is the sole shipped signal`; `10-readiness.sh` and `85-conflict-guards.sh` green (single-source preserved) | PASS |
| AC9 | probe `AC9 .gitkeep-only child not started`, `AC9 pure container still roadmap` (`docs/workflow.md:1221-1227`); full suite green (`20-lifecycle`, `80-cycle-fixture`) | PASS |
| AC10 | `git diff --name-only -- . ':(exclude)work/'` lists exactly the four surfaces; probe `AC10 status command Usage string retained`; no new command/agent/skill; `git status` shows no added `.opencode/` file | PASS |
| AC11 | `bash tests/run.sh` → `TOTAL: 489 passed, 0 failed, 0 skipped`, exit 0; `40-inventory.sh` + `96-signature-sweep.sh` green; marker count 1; routing literals pinned by `20-lifecycle.sh`/`87-backtrack-guards.sh` | PASS |

## Edge cases

| Edge case | How verified | Result |
| --------- | ------------ | ------ |
| Pure container | `docs/workflow.md:1221-1223` (manifest + no own artifacts → `roadmap`); AC9 probe | PASS |
| Hybrid node | `docs/workflow.md:1149-1152, 1224-1225` (own artifacts first); status agent/command/skill restate | PASS |
| Deep chain | `docs/workflow.md:184-186` "independently at every level"; status agent "arbitrary depth"; status agent output-format example shows 3 levels | PASS |
| `.gitkeep`-only child | `docs/workflow.md:1225-1227` ("`not started`"); committed `87-backtrack-guards.sh` fixture `9116-empty` derives `not started` | PASS |
| No dependencies | shipped algorithm unchanged (`A child with no dependencies is ready`) | PASS |
| Cycle within a manifest | `80-cycle-fixture.sh` green; `A child in a cycle is never '`ready`'` retained | PASS |
| Recalled dependency | `docs/workflow.md:214-218` revocation sentence retained; `10-readiness.sh` and `87-backtrack-guards.sh` readiness-revocation green | PASS |
| Decomposing dependency, unshipped/unapproved | `docs/workflow.md:211-213` own-signal-only; no recursive propagation | PASS |
| Decomposing dependency approved mid-children | same clause — own `approve` verdict satisfies regardless of children | PASS |
| Cross-level target attempted | `docs/workflow.md:176-181` non-sibling → `DANGLING-DEP` | PASS |
| Empty `work/` tree | status agent `<process>` step 1 unchanged ("no items exist … recommend `/spec`") | PASS (unchanged path) |
| Standalone leaf | derived-state rows below the `roadmap` row unchanged; status agent keeps `checked/total tasks` | PASS |
| Concurrent/parallel nodes | readiness derived live, never stored (`docs/workflow.md:188-203`); `/status` read-only/local-only retained | PASS |

## Gaps and residual risk

- **No committed behavioral guard for the new recursive clauses.** The spec
  explicitly defers committed recursive-readiness fixtures/agreement areas and
  mutation coverage to a successor roadmap (Roadmap 5); the design's test
  strategy confirms "no new test file is added," and AC10/AC11 constrain the
  change set to four surfaces. Per the tester rule "do not add tests for behavior
  the spec does not require [as a deliverable]", no committed test was added.
  The recursive rules (hybrid-node derivation, depth-3 status rendering,
  decomposing-target-own-signal-only) are verified by review + grep probes only.
  This is the spec's accepted residual, not a hidden gap.
- **Legacy vocabulary remains in out-of-scope surfaces.** The `roadmap` agent
  (`.opencode/agent/roadmap.md:96`) still says "dependencies are intra-roadmap
  only", and `docs/workflow.md` routing heuristics (`:1272`) say "intra-roadmap
  dependencies". Both are consistent with, and strictly weaker than, the
  authority's sibling-only rule, so neither is a competing rule; the roadmap
  agent/command and README are the broad surface sweep deferred to Roadmap 4
  (spec non-goal). Low risk: the authority is explicit and single-sourced.
- **Parent manifest is currently untracked.** `work/0011-recursive-bootstrap/roadmap.md`
  is untracked on `main` (`git status --porcelain` shows `??`). This is the
  parent item's planning state, outside this child's deliverable; it does not
  affect the committed suite (which never reads `work/**`) or this child's
  artifacts (`spec.md`/`design.md`/`tasks.md` are tracked). Flagged for the
  parent item's owner, not routed as a defect here.
- **`/status` rendering is prompt behavior, not executable.** `AC6`/`AC7` name
  the rendered report shape; the committed suite pins the contract text
  (`Status reporting`, `status.md`, `command/status.md`) but cannot execute an
  LLM's rendered output. Same class of residual already documented for the
  prompt-only `CYCLIC-DEP` rule (`tests/README.md`).

## Verdict

All eleven acceptance criteria and all documented edge cases are covered by the
green committed suite and/or reproducible content probes. No defect found; no
test was weakened, skipped, or deleted. Status: `final`.
