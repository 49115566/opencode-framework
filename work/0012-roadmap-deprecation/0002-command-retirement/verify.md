---
feature: 0012-roadmap-deprecation/0002-command-retirement
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Verification — Retire the `/roadmap` command and agent; `/plan` becomes the sole recursive writer

## Summary

All fourteen acceptance criteria and every spec edge case are verified against the
**current working tree** by a committed-suite run plus an independent, read-only,
falsifiable harness (`scratch/verify-0012-0002.sh`, 76 assertions, `0 failed`).
**No acceptance-criterion defect was found.** The implementation diff matches the
AC14 scope fence exactly; the committed suite is green (482 passed, 0 failed).

There is no `work/0012-roadmap-deprecation/0002-command-retirement/challenges.md`,
so there was no open challenge to adjudicate. There is no `backtracks.md` for this
item, so no open finding targeted its phases.

Verification is against the working tree: the change is uncommitted (`/build` does
not commit), and `scratch/` is the gitignored temp space AGENTS.md sanctions for
temporary/verification files. No production file was modified by this phase.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | **PASS** | `TOTAL: 482 passed, 0 failed, 0 skipped`; exit 0. Full suite against the working tree. |
| `bash scratch/verify-0012-0002.sh` | **PASS** | `HARNESS TOTAL: 76 passed, 0 failed`; exit 0. AC1–AC14 and edge-case assertions (AC1/AC5/AC6/AC7/AC8/AC10/AC11/AC13/AC14 directly; the rest cross-checked). |
| `FRAMEWORK_TEST_AREAS=96-signature-sweep bash tests/run.sh` | **PASS** | `TOTAL: 86 passed, 0 failed, 0 skipped` — AC4 signature agreement. |
| `FRAMEWORK_TEST_AREAS=40-inventory bash tests/run.sh` | **PASS** | `TOTAL: 39 passed, 0 failed, 0 skipped` — AC8 counts/tables vs disk. |
| `FRAMEWORK_TEST_AREAS=30-permissions bash tests/run.sh` | **PASS** | `TOTAL: 14 passed, 0 failed, 0 skipped` — AC2/AC8 Agents table vs permissions. |
| `FRAMEWORK_TEST_AREAS=95-split-guard bash tests/run.sh` | **PASS** | `TOTAL: 28 passed, 0 failed, 0 skipped` — AC9 byte-parity twin outside `## Project profile`. |
| `FRAMEWORK_TEST_AREAS=20-lifecycle bash tests/run.sh` | **PASS** | `TOTAL: 64 passed, 0 failed, 0 skipped` — AC10 routing/derived-state agreement. |
| `FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh` | **PASS** | `TOTAL: 8 passed, 0 failed, 0 skipped` — readiness unchanged. |
| `git diff HEAD --name-status` | 10 changed impl paths + this item's `tasks.md` | AC13/AC14: exactly the allowed surface set; nothing else touched. |
| `git status --short -- work/` | only this item's `tasks.md` | AC13: no other `work/` artifact, no `ship.md`, changed. |
| `ls .opencode/agent .opencode/command .opencode/skill` | `13 / 12 / 11` | AC1/AC2/AC12: no `roadmap` entry, no new command/agent/skill. |
| `grep -rnF '/roadmap' <8 in-scope surfaces>` | none | AC5/AC7: no scoped surface presents `/roadmap`. |
| `grep -rn 'agent: roadmap' .opencode/command/` | none | AC1. |

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 command removed | Harness `AC1` (3): no `.opencode/command/roadmap.md`; no command declares `agent: roadmap`; command listing has no `roadmap`. Suite: `40-inventory` (commands table vs disk), `96` `ALL_COMMANDS` no longer names `/roadmap`. | PASS |
| AC2 agent removed | Harness `AC2` (3): no `.opencode/agent/roadmap.md`; agent listing has no `roadmap`; README Agents table has no `roadmap` row. Suite: `40-inventory` 39/0, `30-permissions` 14/0. | PASS |
| AC3 create mode moved to `/plan` | Harness `AC3` (13) + `AC3-edge` (6): both writer surfaces state the create path — reconnoitre `work/`, allocate next top-level `NNNN`, kebab slug, author `manifest.md` `phase: manifest`, reserve child `.gitkeep`, write no child phase artifact, recommend `/spec` for a single feature; empty argument asks and creates nothing; legacy `roadmap.md` selects revise; pure container/author; hybrid; shipped child refused. | PASS (prompt-text) |
| AC4 canonical `/plan` signature | Harness `AC4` (16) over all eight named positions (AGENTS Design row, template Design row, workflow Design heading, README Commands row, README mermaid label, skill routing block, `plan.md` usage string, `96` registry): all canonical, none single-form. Suite: `96-signature-sweep` 86/0. | PASS |
| AC5 sole recursive writer | Harness `AC5` (2): no in-scope surface names `/roadmap`; none names the `roadmap` agent. Corroborated by `96` and `20-lifecycle`. | PASS (in-scope) |
| AC6 writer emits modern spelling | Harness `AC6` (11): `plan.md`/`architect.md` use `manifest.md` and `phase: manifest`; `architect.md` marks `stale: manifest`; both name `Revising a decomposition`; neither retains `stale: roadmap` or `Revising a roadmap`. Suite `96` passes with the retired spelling removed. | PASS |
| AC7 command-alias prose retired, artifact alias retained | Harness `AC7` (3): no `/roadmap` in `docs/workflow.md` or the skill; workflow still documents `roadmap.md` carrying `phase: roadmap` as a **recognized deprecated alias**. Contract pins of `87`/`95` still green in the full suite. | PASS |
| AC8 README inventory reconciled | Harness `AC8` (5): Layout `13` agents / `12` commands / `11` skills; no `/roadmap` row; Agents table has no `roadmap` row; Commands `/plan` row is the dual form. Suite: `40-inventory` 39/0, `30-permissions` 14/0, `96` README positions. | PASS |
| AC9 contracts reconciled, byte-parity held | Harness `AC9` (4): no `/roadmap` in `AGENTS.md`/`template/AGENTS.md`; both Design rows dual-form. Suite: `95-split-guard` 28/0 verifies byte-identity outside `## Project profile`. | PASS |
| AC10 skill surfaces reconciled | Harness `AC10` (3): routing offers `/plan <item-ref or initiative>`; skill uses `manifest.md`; container phase is `manifest`. Suite: `20-lifecycle` 64/0, `96` skill routing. | PASS |
| AC11 signature guard reconciled | Harness `AC11` (2): `96` contains no `roadmap` literal; its `/plan` registry entry is the dual form. Suite: `96-signature-sweep` 86/0 (cannot pass with a stale registry). | PASS |
| AC12 suite stays green | `bash tests/run.sh` → `482 passed, 0 failed, 0 skipped`; `ls` shows `13 / 12 / 11` with no new entry. | PASS |
| AC13 no behavior or contract fork | Harness `AC13` (4): `docs/artifact-conventions.md` unchanged (six-column `Children` header and `conflicts-with` grammar untouched); no `ship.md` changed; no other `work/` artifact changed. `git diff -U0 docs/workflow.md` touches no `Children`/`conflicts-with`/`Depends on` line. No new command/agent/skill. | PASS |
| AC14 scope fence | Harness `AC14` (2 groups): implementation diff equals exactly the ten allowed paths; `docs/artifact-conventions.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `tests/README.md`, and the read-side prompts (`product`, `status`, `builder`, `tester`, `reviewer`, `visual`, `shipper`, `scribe`) are untouched. | PASS |

### Edge cases

| Edge case (spec) | How verified | Result |
| ---------------- | ------------ | ------ |
| Empty argument | Harness `AC3-edge`: `plan.md` "If `$ARGUMENTS` is empty, ask …"; creates nothing. | PASS |
| Item-ref-shaped, non-resolving argument | Harness `AC3`: both writer surfaces state a `NNNN-slug`-shaped token taking the create path, with reconnoitre to prevent a duplicate. | PASS |
| Single-feature initiative | Harness `AC3`: "recommend `/spec <feature>` and create nothing". | PASS |
| Existing modern manifest | Harness `AC3-edge`: `manifest.md` selects the revise path (four operations unchanged, consumed from `0001`). | PASS |
| Existing legacy manifest | Harness `AC3-edge`: legacy `roadmap.md` artifact alias selects revise; not rewritten. | PASS |
| `.gitkeep`-only child / pure container | Harness `AC3-edge`: pure container selects the author path; child reserved with `.gitkeep`, no child phase artifact. | PASS |
| Hybrid node | Harness `AC3-edge`: hybrid gets its own `design.md`/`tasks.md`; pure container gets neither. | PASS |
| Shipped node | Harness `AC3-edge`: revise refuses and surfaces a shipped child. No `ship.md` signal changed (AC13). | PASS |
| Both spellings present | `docs/workflow.md:340` DRIFT-FACT rule: `manifest.md` authoritative, reported never auto-repaired (consumed from `0001`; unchanged). | PASS |
| Deep nesting | Writer prose states create/author/revise and `stale: manifest` "at any depth" (`architect.md:127-129`); no depth-specific fork. | PASS |
| Muscle-memory `/roadmap` | AC1: no `roadmap` command ships, no redirect retained (unknown command). | PASS |
| Contract parity drift | `95-split-guard` 28/0: identical edit applied to both `AGENTS.md` copies. | PASS |
| Concurrency | N/A by design: no new mechanism; the existing renumber-after-parallel-merge rule is unchanged (spec edge case states this). | N/A |

## Gaps and residual risk

1. **No committed retirement guard added — by design.** `design.md` → "Test
   strategy" states *"No new test area is added"*; AC14 fences the change set to the
   ten named files, and `tests/README.md` (which documents each area) is itself
   fenced. The focused assertions therefore live in the gitignored, uncommitted
   `scratch/verify-0012-0002.sh`; the structural parts (`/roadmap` gone from the
   registry and inventories, signature agreement) remain guarded by the committed
   `96` and `40`. A later regression that re-introduced `/roadmap` prose or the
   single-form signature in a *non-scanned* position would not be caught by the
   committed suite. Follow-up candidate: a committed retirement guard (Roadmap 4/5).
2. **AC5 read literally vs. the spec's own scope fence.** `AC5` says "no documented
   surface" names `/roadmap`, but the spec's Non-goals and `AC14` deliberately defer
   the read-side agent/command prose to Roadmap 4. Residue confirmed (all
   out-of-scope, **not** implementation defects): `product.md:118` names
   `/roadmap revise`; `product.md:78,121` and `status.md:54,265,327` still use
   `roadmap.md` / container phase `roadmap`. The writer surfaces were brought to
   scope; the design's AC5 test strategy explicitly scopes the grep to the in-scope
   surfaces. Recorded for the reviewer; no routing taken because the spec resolves
   the tension internally.
3. **Generic "roadmap child" phrasing remains in two in-scope writer surfaces**
   (`plan.md:27`, `architect.md:87`). The spec's Non-goals treat the generic phrasing
   as the broad Roadmap 4 sweep; no AC requires it changed, and AC6 governs the
   writer's *output* spelling, not this noun. Minor vocabulary residue, not a defect.
4. **Intentional `/plan <item-ref>` prose.** `docs/workflow.md` route descriptions
   and `Next: /plan <item-ref>` handoffs (e.g. `AGENTS.md:108`) keep the single-form
   token to name the *revise route / an existing-item handoff*. AC4 governs only the
   eight named signature positions, all of which are canonical (verified). Not a
   divergence.
5. **Stale out-of-scope comment.** `tests/checks/87-backtrack-guards.sh:597`'s comment
   still says "Revising a roadmap", but it instantiates the heading on a fixture copy
   of `roadmap.md` (owned by `0003-parent-migration`); the guard passes. Out of scope.
6. **Uncommitted working tree.** Verification reads the working tree; the change is
   not committed by `/build`. If a later edit changes the tree before `/review`, this
   record must be re-confirmed.

## Not verified / out of scope

- The seven existing decomposing parents, the `roadmap.md`-loading fixtures and
  `80`/`85`/`87` guards, and `tests/README.md` — explicitly `0003-parent-migration`
  scope (AC14). Verified only that they were left untouched.
- The read-side agent/command prose sweep (`status`, `product`, `reviewer`,
  `visual`, `builder`, `tester`, `shipper`, `scribe`) — Roadmap 4 scope (AC14).
- The `0001` deprecation contract (modern spelling, legacy artifact alias, container
  phase, `stale: manifest` token) — consumed as fixed, only cross-checked.
- No UI surface: `/visual` is not applicable.
