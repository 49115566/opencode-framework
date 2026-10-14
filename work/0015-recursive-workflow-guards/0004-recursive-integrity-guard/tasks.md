---
feature: 0015-recursive-workflow-guards/0004-recursive-integrity-guard
phase: tasks
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Tasks — Committed recursive merge-integrity and renumber guards

Ordered, dependency-aware. One task ≈ one focused commit. The exact check
filename (`tests/checks/91-integrity-guard.sh`), fixture root
(`tests/fixtures/recursive-integrity/`), sub-area names, the old/new renumber
constants, and the `tests/checks/80-cycle-fixture.sh` AC13 relaxation are fixed by
`design.md`; no task below re-decides them. The area is renamed off the collided
`89-` stem to the free `91-` stem (see `design.md` → "Renaming the area off the
collided `89-` stem"); `T4` owns the rename and the full reference sweep, so
`T5`–`T7` and `T9` (whose `Verify:` names the area) are re-opened, while `T1`–`T3`
and `T8` stay checked — their substantive deliverables are unchanged and `T4`
sweeps the incidental area references in `T1`–`T3`'s files.

- [x] **T1** — Narrow `tests/checks/80-cycle-fixture.sh`'s AC13 whole-set
      `roadmap.md` assertion (`80-cycle-fixture.sh:61-71`): compute the stray-alias
      set as `find tests/fixtures -name roadmap.md | grep -vxF
      'tests/fixtures/recursive-integrity/items/9203-spelling-both/roadmap.md'` and
      keep the exact-equality comparison against the retained cyclic alias,
      updating the explanatory comment to name the one documented deliberate
      exception. Change no cycle-diagnostic assertion and no mutation job. [AC11]
      [AC4]
      Verify: `FRAMEWORK_TEST_AREAS=80-cycle-fixture bash tests/run.sh` exits 0; in
      a scratch copy of `tests/` (never the repository) add a third
      `tests/fixtures/scratch-third/roadmap.md` and confirm `80` fails naming
      `unexpected roadmap.md fixture set`.
- [x] **T2** — Author the integrity fixture tree `tests/fixtures/recursive-integrity/items/`: `9201-clean` (clean node + `.gitkeep` leaf), `9202-graph-faults` (row `0002-missing` with no directory, `0003-dangling` with `Depends on 0099-ghost`, directory `0004-withdrawn` recorded as a withdrawal under `## Open issues`, directory `0005-unlisted` with no record), `9203-spelling-both` (`manifest.md` + `roadmap.md`), `9204-phase-mismatch` (`manifest.md` with `phase: roadmap`), the top-level prefix pair `9210-dup-a`/`9210-dup-b`, and the depth-3 collision `9211-deep/0001-mid/{0001-alpha,0001-beta}`. Use the six-column `Children` header and `manifest.md` `phase: manifest` exactly as `docs/artifact-conventions.md` defines. [AC2] [AC3] [AC4] [depends: T1]
      Verify: `bash tests/run.sh` exits 0 (the `80` relaxation keeps the migration
      guard green with the dual-spelling fixture present) and the fixture paths
      exist (`ls tests/fixtures/recursive-integrity/items/9202-graph-faults/` shows
      the four child dirs; `grep -c '^| 0' tests/fixtures/recursive-integrity/items/9202-graph-faults/manifest.md` shows the rows).
- [x] **T3** — Author the renumber fixture `9220-renamed-parent/`: `manifest.md` with a `0002-new` row (Local id + Canonical reference `9220-renamed-parent/0002-new`) and a `0003-follower` row with `Depends on: 0002-new`; the intermediate `0002-new/manifest.md`; a descendant `0001-leaf/spec.md` carrying the new `feature:` and `parent:` values; `0003-follower/design.md` with `conflicts-with: 0002-new`; and `0003-follower/ship.md` recording a handoff path naming the new reference. The old local id `0001-old` and old canonical reference `9220-renamed-parent/0001-old` must appear nowhere in the fixture. [AC7] [depends: T2]
      Verify: `bash tests/run.sh` exits 0 and `grep -rF '0001-old' tests/fixtures/recursive-integrity/` prints nothing (exit 1).
- [ ] **T4** — Rename the area to `tests/checks/91-integrity-guard.sh` (off the collided `89-` stem) and sweep every reference: `mv tests/checks/89-integrity-guard.sh tests/checks/91-integrity-guard.sh`; set `FIG_SELF="$FIG_CHECKS_DIR/91-integrity-guard.sh"`; change the `.opencode/` self-reference scan literal to `91-integrity-guard`; update the header comment; and rewrite the remaining `89-integrity-guard` references — the `tests/checks/80-cycle-fixture.sh` AC13 cross-reference (`80-cycle-fixture.sh:66`) and the six fixture-prose references under `tests/fixtures/recursive-integrity/` — enumerated in `design.md` → "Renaming the area off the collided `89-` stem". Keep the header (naming the areas deferred to), the Bash 3.2-compatible helpers, and the recursive analyzer (`fig_manifest`, `fig_children_rows`, `fig_scan_node`, top-level prefix grouping) that emits normalized `CODE|offender[,offender]` findings into the three category blocks `fixture_duplicates`, `fixture_graph`, and `fixture_drift`; compare each against its reviewed expected block, labelled `AC30 per-node-eval`, `AC30 structural-graph`, and `AC30 spelling-drift`; assert the depth-3 collision is attributed to `9211-deep/0001-mid` and that `9202-graph-faults/0004-withdrawn` yields no `UNLISTED-CHILD` fault. [AC2] [AC3] [AC4] [depends: T2]
      Verify: `FRAMEWORK_TEST_AREAS=91-integrity-guard bash tests/run.sh` exits 0 and prints the three `AC30` labelled blocks with no `FAIL`; `grep -rF '89-integrity-guard' tests/` prints nothing.
- [ ] **T5** — Add the `report-only` sub-area: pin the non-fatal / never-truncated / not-auto-repaired / modifies-no-file contract on `docs/workflow.md` → "Merge-integrity guard" and the operational mirror `.opencode/skill/merge-conflict/SKILL.md`; assert the clean `9201-clean` node yields empty findings and does not error; and pin the recursive authority phrases (the invariant set is evaluated at every node; no node's check depends on another's; every node at every depth). Reference the pinned surfaces by path; restate no sibling literal. [AC5] [AC2] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=91-integrity-guard bash tests/run.sh` exits 0 with the `AC30 report-only` lines present and passing.
- [ ] **T6** — Add the `renumber-sweep` sub-area: assert the fixture's new directory exists and contains the new reference in each enumerated rewrite position (directory, `feature:`, `parent:`, owning manifest `Local id`/`Canonical reference`, intermediate manifest `Canonical reference`, `Depends on`, `conflicts-with`, ship path), and assert by a recursive literal scan that the old local id and old canonical reference appear nowhere under `tests/fixtures/recursive-integrity/`; pin that `docs/artifact-conventions.md` and `.opencode/skill/merge-conflict/SKILL.md` name the intermediate manifest on the changed path, referencing `tests/checks/88-renumber-sweep.sh` by name and restating none of its literals. [AC7] [AC8] [AC9] [depends: T3] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=91-integrity-guard bash tests/run.sh` exits 0 with the `AC30 renumber-sweep` lines passing.
- [ ] **T7** — Add the structural assertions: `fixture-existence` fails (never skips) when a required fixture file is missing; `read-only-contract` asserts the fixture references no live `work/` path and adds no committed executable checker; `mutation-staging` asserts `tests/mutation.sh`'s staged-copy list names `tests/fixtures/recursive-integrity`; `no-duplication` asserts the header references `10-readiness`, `20-lifecycle`, `80-cycle-fixture`, `85-conflict-guards`, `87-backtrack-guards`, `88-renumber-sweep`, `90-packaging`, `96-signature-sweep`, and the structure guard `0001-recursive-structure-guard` by name and re-asserts none of their owned literals. Every assertion carries the `AC30` token. [AC1] [AC6] [AC10] [AC11] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=91-integrity-guard bash tests/run.sh` exits 0 with the `fixture-existence`, `read-only-contract`, `mutation-staging`, and `no-duplication` lines present and passing.
- [x] **T8** — Add the new fixture root to `tests/mutation.sh`'s `stage_copy()` as one additive `cp -R "$REPO_ROOT/tests/fixtures/recursive-integrity" "$copy/tests/fixtures/recursive-integrity"` line beside the existing fixture copies. Do not add mutation jobs or change `JOB_COUNT`; those remain `0005-guard-registration-sweep`'s. [AC10] [depends: T2]
      Verify: `bash tests/mutation.sh` exits 0 (the whole-suite clean copy passes with the fixture staged) and `grep -F 'recursive-integrity' tests/mutation.sh` matches the new line.
- [ ] **T9** — Run the full suite and prove the renumber assertion is sensitive and the scope is clean. [AC8] [AC11] [AC12] [depends: T5] [depends: T6] [depends: T7] [depends: T8]
      Verify: `bash tests/run.sh` exits 0 (all areas green, including `80-cycle-fixture`); in a scratch copy of `tests/` (never the repository) reintroduce `9220-renamed-parent/0001-old` into one fixture file and run `FRAMEWORK_TEST_AREAS=91-integrity-guard bash tests/run.sh <scratch-root>` — it must exit non-zero and print a line containing `AC30 renumber-sweep`; and `git diff --name-only` lists only files under `tests/` plus this work item.
