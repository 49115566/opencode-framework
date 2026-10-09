---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
notes: "Documentation/prompt-only deliverable. Per spec.md non-goals ('committed fixtures, agreement areas, and mutation coverage for the revision — owned by 0007-backtracking-guards') and design.md Test strategy, no new committed check area was added; committed guard coverage is 0007's scope. Verification is the existing suite plus recorded inspection of the named surfaces. No UI surface, so no /visual pass."
---

# Verification — Parent-roadmap revision from child phases

## Scope and approach

This item's deliverable is documentation, prompts, one command, and one test
literal (`docs/workflow.md`, `docs/artifact-conventions.md`, the four
`.opencode` agent/command files, the `workflow-lifecycle` skill,
`AGENTS.md`/`template/AGENTS.md`/`README.md`, and the `/roadmap` registry literal
in `tests/checks/96-signature-sweep.sh`). Its own `spec.md` non-goals and
`design.md` Test strategy explicitly assign **committed fixtures, agreement
areas, and mutation coverage for the revision** to the sibling
`0007-backtracking-guards`; the design's stated verification is "the existing
suite plus observable inspection of the named surfaces". Adding a new
`tests/checks/*` agreement area here would violate that non-goal and overlap
`0007`. No automated test was therefore added, weakened, skipped, or deleted. The
only test change is the required `/roadmap` canonical-signature literal (T7),
which is a contract update, not a weakening. Each acceptance criterion is
verified below either by the existing suite or by a recorded inspection command
with its observed result.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 335 passed, 0 failed, 0 skipped`; exit 0 (log: `scratch/verify-suite.log`) |
| `bash tests/run.sh` (baseline, pre-verification) | PASS | `TOTAL: 335 passed, 0 failed, 0 skipped`; exit 0 — baseline equals post-change result |
| `grep -cE '^(ok|FAIL)' scratch/verify-suite.log` | PASS | `335` assertion lines; no `FAIL`/`skip` lines |
| `git diff --stat` | PASS | only the planned surfaces changed; `tests/` limited to `96-signature-sweep.sh` (+1/−1) |
| `git diff -- tests/` | PASS | one line: the `/roadmap` canonical registry literal; no assertion removed or relaxed |
| `ls .opencode/command/*.md \| wc -l` | PASS | `13` — no new command added |
| `git diff HEAD -- README.md \| grep -E '^[-+].*# [0-9]+ (role prompts\|slash commands\|knowledge skills)'` | PASS | no output — no documented inventory count changed |
| `diff <(git show HEAD:docs/artifact-conventions.md \| grep 'phase: spec  ') <(grep 'phase: spec  ' docs/artifact-conventions.md)` | PASS | `IDENTICAL` — phase enumeration unchanged |
| `diff <(git show HEAD:docs/workflow.md \| sed -n '/^## Derived state/,/^## The fix track/p') <(sed -n '/^## Derived state/,/^## The fix track/p' docs/workflow.md)` | PASS | `IDENTICAL` — derived-state contract unchanged |
| `diff <(git show HEAD:docs/workflow.md \| sed -n '/^### Dependencies and readiness/,/^### Declared conflicts/p') <(sed -n '/^### Dependencies and readiness/,/^### Declared conflicts/p' docs/workflow.md)` | PASS | `IDENTICAL` — readiness algorithm unchanged |
| `git diff \| grep -E '^\+' \| grep -oE '\b[A-Z]{2,}-[A-Z]{2,}\b' \| sort \| uniq -c` | PASS | only `UNLISTED-CHILD` (existing code) ×4; no new finding code |
| content assertions over the named surfaces (inline, read-only) | PASS | 64/64 literals present; the 2 initial misses were line-wrapped grep literals (`docs/artifact-conventions` `phase`, agent quality bar), confirmed present at `.opencode/agent/roadmap.md:199-200` and `docs/workflow.md:207-208` |

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 | `docs/workflow.md:205-215` (revise **existing** parent in place; sole writer; non-parent refused); `.opencode/agent/roadmap.md:30-40,196-201` (quality bar: canonical ref/`feature`/child numbering unchanged; no new top-level item); `.opencode/command/roadmap.md:38-46` (non-parent refused). All literals present (the two line-wrapped ones at `roadmap.md:199-200`, `workflow.md:207-208`). | PASS |
| AC2 | `docs/workflow.md:220-221` ("replace an existing row's `Title` and/or `Scope` in place"; `Local id`/directory/`Canonical reference` preserved); invalidation defined at `:259-268`; `.opencode/agent/roadmap.md:133-134`. | PASS |
| AC3 | `docs/workflow.md:222-227` (greatest ever-committed `MMMM` + 1, never reused; create `work/<parent>/<MMMM-slug>/.gitkeep`; reference resolves to that directory); `.opencode/agent/roadmap.md:135-139`; `.opencode/command/roadmap.md:42-43`; allocation contract `docs/artifact-conventions.md` → "Sequence allocation". | PASS |
| AC4 | `docs/workflow.md:228-233` (row removed from `Children` and `## Sequencing`; directory and spent number preserved; recorded under `## Open issues`); template shape `docs/artifact-conventions.md:143-172`; matches the shipped precedent `work/0003-framework-quality-hardening/roadmap.md:87-95` (verified side by side). | PASS |
| AC5 | `docs/workflow.md:259-273` (affected = row cell changed or explicitly re-sequenced; five present phase artifacts get `stale: roadmap`; nothing deleted/silently rewritten; pre-revision content recoverable; `.gitkeep`-only marks nothing; unaffected untouched; shipped child excluded); `.opencode/agent/roadmap.md:157-164,217-221`. `stale: roadmap`→`spec` mapping is the pre-existing `docs/workflow.md:744` (unchanged). | PASS |
| AC6 | `docs/workflow.md:234-236,247` (rewrite `## Sequencing` as a topological order; every active child after all dependencies); `.opencode/agent/roadmap.md:144-151`. | PASS |
| AC7 | `docs/workflow.md:238-257` (one validation predicate over the final state: deps name another row, no self-dependency, acyclic, every reference resolves, every active child is a row, sequencing after deps, six-column layout; cycle fallback stores no cyclic edge and records under `## Open issues`; dangling dependency re-pointed/withdrawn or refused). `.opencode/agent/roadmap.md:147-156`. | PASS |
| AC8 | `docs/workflow.md:191` (deliberate withdrawal, report-only, never auto-repaired); `docs/artifact-conventions.md:166-172` (named directory is the recognition signal); `.opencode/agent/status.md:161-163`; `.opencode/command/status.md:32-34`. | PASS |
| AC9 | `docs/workflow.md:248-250` (six-column header unchanged; `Depends on` pipe-field 5; `conflicts-with` pipe-field 6; well-formed cells). Suite: `tests/checks/80-cycle-fixture.sh` and `tests/checks/85-conflict-guards.sh` green in `bash tests/run.sh` (335/0/0). Header/fixtures untouched (`git diff --stat`). | PASS |
| AC10 | `docs/workflow.md:275-287` (finding entry in `work/<child-ref>/backtracks.md` with target phase `roadmap`; matching resolution entry; parent `updated` and revision note); template record shapes `docs/artifact-conventions.md:143-176` and `:466-510` (`backtracks.md`, unchanged from `0001`); `.opencode/agent/roadmap.md:165-170`. | PASS |
| AC11 | `.opencode/agent/product.md:109-115` and `.opencode/agent/architect.md:110-116`: each names `/roadmap revise <parent-ref>`, records the finding in `backtracks.md` (target `roadmap`), and states "Never edit the parent `roadmap.md`". | PASS |
| AC12 | `docs/workflow.md:213-214` ("writes autonomously, with no pre-write approval gate"); `.opencode/command/roadmap.md:46` ("without a pre-write approval gate"); agent revise mode contains no approval step. | PASS |
| AC13 | Canonical literal `/roadmap <initiative> \| /roadmap revise <item-ref>` in `tests/checks/96-signature-sweep.sh:47`; every swept surface states it (`AGENTS.md:47`, `template/AGENTS.md:49`, `README.md:203` escaped `\|` and prose `:184`, `.opencode/skill/workflow-lifecycle/SKILL.md:31`, `.opencode/command/roadmap.md:2`, `docs/workflow.md:794`). `bash tests/run.sh` → `96-signature-sweep.sh` and `40-inventory.sh` green; `ls .opencode/command/*.md` = 13 (no new command). | PASS |
| AC14 | `bash tests/run.sh` → exit 0, `TOTAL: 335 passed, 0 failed, 0 skipped`; phase enumeration, derived-state block, and readiness section `IDENTICAL` to `HEAD` (diffs above); README Layout counts unchanged (diff above + `40-inventory.sh` green); no new finding code (grep above). | PASS |
| AC15 | `docs/workflow.md:209-212` and `:275-287` reference `## Phase reversal (backtracking)` and `docs/artifact-conventions.md` → "`backtracks.md`" and the `roadmap.md` template rather than defining a second model; only the pre-existing `UNLISTED-CHILD` code appears in added lines. | PASS |

## Edge-case coverage

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Revision before any child has artifacts | `docs/workflow.md:266-267` — a `.gitkeep`-only child "marks nothing and simply derives `not started`"; derived-state row `docs/workflow.md:754-757` unchanged. | PASS |
| Withdrawing a child another child depends on | `docs/workflow.md:254-257` — either apply the re-point/withdrawal in the same revision, or refuse and report the ambiguous intent; never silently choose. | PASS |
| Adding a child whose dependencies would create a cycle | `docs/workflow.md:252-254` — stores no cyclic edge, leaves the graph acyclic, records under `## Open issues`. | PASS |
| Re-sequencing an already acyclic graph | `docs/workflow.md:234-236` — rewrite as a topological order; validation `:243` keeps it acyclic and no number changes. | PASS |
| Re-scoping a shipped child | `docs/workflow.md:270-273` — shipped child excluded; revision refuses and surfaces; post-ship path `0005-post-ship-pr-denial`. | PASS |
| Duplicate local number attempted | `docs/workflow.md:225-226` — "A spent number is never reused"; allocation by greatest ever-committed + 1. | PASS |
| Empty revision | `docs/workflow.md:214-215` — "A revision request that changes nothing is a no-op and modifies no file"; `.opencode/agent/roadmap.md:171`. | PASS |
| Withdrawn directory surfaces as unlisted | `docs/workflow.md:191` + `docs/artifact-conventions.md:166-172` — report-only deliberate withdrawal, never auto-repaired (AC8). | PASS |
| Revision invoked on a non-parent reference | `docs/workflow.md:207-208`, `.opencode/agent/roadmap.md:126-128`, `.opencode/command/roadmap.md:40-41` — refused. | PASS |
| Concurrent revisions on two branches | No lock is specified (no lock text exists to contradict); the resulting `work/` collision is the shipped class (b) merge-conflict contract (`docs/workflow.md` → "Merge conflicts"), referenced not restated. Behavior inherited; no new text required. | PASS (implied) |
| Dependency target withdrawn in the same revision | `docs/workflow.md:217-218` — "validates the result **after all four** (never on an intermediate state)". | PASS |

## Gaps and residual risk

- **No committed automated guard for the revision route (deliberate).** The new
  text can drift between this item and `0007-backtracking-guards`, which owns the
  fixture-based agreement areas and mutation coverage. This is the scope boundary
  fixed by `spec.md` non-goals and `design.md` Test strategy, not an oversight;
  `0007` should pin the section literals (the four operations, the validation
  predicate, `stale: roadmap` marking, the withdrawal/revision-note shapes, and
  the deliberate-withdrawal recognition).
- **Prompt behavior is not executable in CI.** Whether a live `/roadmap revise`
  run actually applies the operations, marks stale, and appends the entries is
  LLM/prompt behavior; like the cycle and declared-conflict diagnostics, it is a
  documented manual residual. The committed suite pins the surrounding contracts
  (signature, inventory, cycle, conflict, readiness, lifecycle) but cannot run the
  revision itself.
- **Declaration drift is present by construction (advisory).** `design.md`
  frontmatter `conflicts-with` names a superset of the parent `Children` row's
  cell for `0004-roadmap-revision` (`work/0007-phase-backtracking/roadmap.md:86`,
  three surfaces). The read-only declared-conflict check reports a `DRIFT-FACT`
  for this child; the design records it as intentional, it is advisory, prompt-only,
  and blocks no phase. Rewriting the parent cell is the roadmap owner's write and
  out of this phase's scope.
- **Cross-item write surface.** The roadmap agent appends the triggering child's
  `backtracks.md` resolution entry; the text states this is item-level backtrack
  state, not a phase artifact, so it does not breach "only the owning phase writes
  its artifact". No committed test can enforce the distinction; `0007` should.
- **No UI surface.** Documentation/prompt-only item, so no `/visual` pass was run;
  `visual.md` is intentionally absent.
