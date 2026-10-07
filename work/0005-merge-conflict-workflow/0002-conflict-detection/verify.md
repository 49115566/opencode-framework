---
feature: 0005-merge-conflict-workflow/0002-conflict-detection
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
notes: "Prompt/config/doc only; no runtime code and no new committed check (committed merge-integrity guards are deferred to sibling 0005-merge-integrity-guards, per spec/design). AC1-AC14 and every spec edge case are encoded as content assertions plus one live behavioral probe in work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh; AC13/AC14 are integration-verified by the canonical bash tests/run.sh plus inventory/unchanged-lifecycle invariants. This re-run adds 4 tests (pre-flight ordering, and a live git merge-tree behavioral probe) for 161 total. No defects found in this child. Sibling 0001-conflict-model's historical item suite still fails 2 assertions as expected drift from this child's design-mandated edits; the canonical committed suite stays green."
---

# Verification — Pre-flight conflict detection and classification

## Summary

All fourteen acceptance criteria of
`work/0005-merge-conflict-workflow/0002-conflict-detection` are satisfied against
the current working tree. The deliverable is prompt/config/document content only
(no executable detector), so the automatable evidence is the read-only item suite
`work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh`,
which encodes AC1–AC12 and every spec edge case as content assertions, plus one
live behavioral probe of the documented `git merge-tree` dry-run, plus the
canonical committed suite for AC13/AC14.

- The item suite passes **161/161** (was 157 before this pass; this run added a
  pre-flight-ordering assertion and a 3-assertion live probe).
- The canonical suite `bash tests/run.sh` passes **285 passed, 0 failed, 0
  skipped**, including `tests/checks/30-permissions.sh` (the shipper stays
  `git-gh`, the status agent stays `read-only`) and `tests/checks/40-inventory.sh`
  (12 commands / 14 agents / 11 skills).
- The `.opencode` diff is confined to the six design-named surfaces; no command,
  agent, or skill file was added; `docs/workflow.md`,
  `docs/artifact-conventions.md`, `AGENTS.md`, `README.md`, `opencode.json`,
  `template/`, and `tests/` are unchanged.
- No production file was modified by this verification pass. The only test file
  edited is `verify-tests.sh`.

**Cross-phase note:** `review.md` records `request-changes` with findings M1–M4.
All four are addressed in the current tree (verified below in "Review findings
re-checked"); `review.md` predates those fixes and is now stale. That artifact is
owned by the review phase and was not edited here. The only unresolved review
finding is M5 (sibling `0001`'s historical snapshot), which is expected drift,
recorded under residual risk.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`; exit 0 |
| `bash work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh` | PASS | `TOTAL: 161 passed, 0 failed`; exit 0 |
| `bash -n work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh` | PASS | syntax OK |
| `bash work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh` | FAIL (expected drift) | `TOTAL: 135 passed, 2 failed`; sibling snapshot, see residual risk |
| `git diff --quiet -- docs/workflow.md docs/artifact-conventions.md AGENTS.md README.md opencode.json template tests` | PASS | unchanged (AC14) |
| `ls .opencode/command/*.md \| wc -l` / agent / skill | PASS | 12 / 14 / 11 — no new command, agent, or skill (AC14) |
| `git status --porcelain -- .opencode` | PASS | exactly the six design-named surfaces |
| live `git merge-tree --write-tree --name-only` probe in a scratch repo | PASS | exit 1 on conflict, tree OID first line, working tree unchanged (AC2) |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — read-only pre-flight determines merge base, reports changed paths, mutates neither branch nor working tree | `verify-tests.sh` AC1: `## Pre-flight (read-only detection)`; `**read-only pre-flight**`; `before any ship operation`; `merge base` + `git merge-base HEAD origin/<default>`; `git fetch <remote> <default-branch>`; `Report the paths each branch changed`; both `git diff --name-only` forms; `mutates neither the branch nor the working tree`; `no merge applied`; `no rebase`; `no force-push`; `no commit`; `no branch change`; **new** pre-flight section precedes the resolve procedure (line 22 < 143) | PASS |
| AC2 — textual-conflict dry-run over changed paths, non-applying, each path classified (a)/(b) | `verify-tests.sh` AC2: `Dry-run textual probe`; `git merge-tree --write-tree --name-only HEAD origin/<default>`; reports conflicting paths; `exit status \`1\` means conflicts were found`; `skip that OID line`; `does not apply to the working tree`; three-arg fallback; `Classify each conflicting path as class`; class `(a)` surface list and class `(b)` = `work/` path; cites the `0001` taxonomy. **New behavioral:** live scratch-repo probe returns non-zero exit with the conflicted path in stdout, tree-OID first line, working tree unchanged | PASS |
| AC3 — framework-integrity checks (duplicates, graph faults, drift) | `verify-tests.sh` AC3: `Duplicate top-level sequence prefixes` (`NNNN`); `Duplicate per-parent roadmap child numbers` (`MMMM`); `Roadmap graph faults` for `dangling`/`missing`/`unlisted`/`cyclic`; `Duplicated inventory/count facts` comparing README Layout counts + Skills table; cross-branch `git ls-tree --name-only origin/<default>:work` | PASS |
| AC4 — every finding carries class label + offender + detail; none silently dropped | `verify-tests.sh` AC4: canonical grammar `- [<CODE>] (<class>) <offender …> — <detail>`; `No finding is silently dropped`; `every conflicting path is reported`; `never truncated`; all eight codes present; all four class labels | PASS |
| AC5 — shipper + `/ship` run the pre-flight before any ship operation; conflict handed to `0001` reconcile | `verify-tests.sh` AC5: shipper precondition and process step 1 wire the pre-flight `before any ship operation` and `its result is recorded`; `a semantic finding is handed to the \`0001\` reconcile step for escalation`; `/ship` bullet does the same and records the result | PASS |
| AC6 — intent-judgment conflict stops and escalates; detection never resolves | `verify-tests.sh` AC6: skill `never resolves a semantic conflict`, `judgment about intent`, `Stop and escalate`; shipper and `/ship` escalate at the `0001` reconcile step `rather than resolving it` | PASS |
| AC7 — minimal read-only git permissions granted; rebase/force-push still forbidden | `verify-tests.sh` AC7: `"git fetch*": allow`, `"git merge-tree*": allow`, `"git ls-tree*": allow`, `"git symbolic-ref*": allow`; `"git push*": ask` retained; no `git rebase` pattern | PASS |
| AC8 — `/status` reports duplicate-sequence + drift findings alongside the existing four, non-fatal, no file change | `verify-tests.sh` AC8: `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DRIFT-FACT` plus `DANGLING-DEP`/`MISSING-CHILD`/`UNLISTED-CHILD`/`CYCLIC-DEP`; `Findings are informational and never fatal`; every finding carries a class; `No file was modified`; command bullet mirrors it with `without failing` / `modifies no file` | PASS |
| AC9 — `/status` detection is local-only (no fetch, no remote, no dry-run merge) | `verify-tests.sh` AC9: `Local-only detection`; `fetches nothing`; `hits no remote`; `runs no dry-run merge`; `takes no lock`; `writes nothing`; command bullet restates it; negative controls assert no `git fetch`/`git merge-tree` anywhere in either status surface (frontmatter included) | PASS |
| AC10 — finding names the specific offender reference and its class | `verify-tests.sh` AC10: grammar requires the exact path/canonical reference; status `names the offending canonical reference`; output examples name `0004-billing, 0004-billing-v2` `(c)`, roadmap child refs `(c)`, and `README.md` `(d)` | PASS |
| AC11 — already-up-to-date branch reports no conflicts, no-op, no error | `verify-tests.sh` AC11: skill "already up to date … reports `no conflicts`"; `the pre-flight is a no-op and does not error`; shipper "up-to-date branch reports `no conflicts` without error" | PASS |
| AC12 — detection result recorded in ship handoff and PR description | `verify-tests.sh` AC12: shipper handoff `Detected: <conflict classes and paths found, or "no conflicts detected">`; line scoped to work-item mode; `pr-workflow` gains `## Conflict detection` with `No conflicts detected`; `/ship` records it `in \`ship.md\` and the PR description` | PASS |
| AC13 — `bash tests/run.sh` passes, including permission agreement | `verify-tests.sh` AC13 runs the canonical suite (exit 0, no `FAIL`, `TOTAL: 285 passed`); extracts `AC8 shipper: … bash=git-gh` and `AC8 status: … bash=read-only`; confirms the inventory check ran. Independently re-run here: `tests/checks/30-permissions.sh` and `40-inventory.sh` pass | PASS |
| AC14 — no lifecycle/artifact-format/readiness/state/command/agent change; no new command or agent | `verify-tests.sh` AC14: counts 12 commands / 14 agents / 11 skills; no new (untracked) command/agent/skill file; no executable detection script outside `work/`; `git diff --quiet` on the lifecycle/artifact/inventory/suite surfaces; `.opencode` change set equals the six design-named surfaces | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| No remote / no default-branch reference | `verify-tests.sh` EDGE: `report that the default branch cannot be determined`, `instead of guessing one`, `that alone does not fail the ship` | PASS |
| `git fetch` unavailable or denied | `verify-tests.sh` EDGE: `If \`git fetch\` is unavailable or denied` → `report the comparison as \`skipped\`` with the reason; `never run it on a stale base` | PASS |
| Empty state (no `work/` items, or a roadmap parent with no children) | `verify-tests.sh` EDGE: status agent `If it is empty` → `report that no items exist`; `/status` `If \`work/\` is empty`. A roadmap parent with zero children yields no duplicates and no graph findings by construction ("check every parent the same way" over an empty set produces no findings and no error). See residual risk. | PASS |
| Duplicate sequence number, one shipped and one not | `verify-tests.sh` EDGE: "Any two top-level `work/`" are reported regardless of state and classified as a top-level class `(c)` collision; class `(c)` `never defines a second rule` (defers to sibling `0004`) | PASS |
| Overlapping classes | `verify-tests.sh` EDGE: reported under `each applicable class` rather than collapsed | PASS |
| Both sides changed the same duplicated fact to the same value | `verify-tests.sh` EDGE: `Both sides changing the same duplicated fact to the same value is not drift`; `report no class \`(d)\` finding` | PASS |
| Clean dry-run merge is not proof of correctness | `verify-tests.sh` EDGE: `A clean dry-run merge (no conflict markers) is not proof of correctness`; re-verification still required | PASS |
| Detection runs concurrently | `verify-tests.sh` EDGE: `take no lock and write nothing` | PASS |
| Large changed set | `verify-tests.sh` EDGE/AC4: every conflicting path reported, `never truncated` | PASS |

## Review findings re-checked

The review phase's Major (M1) and Minor (M2–M4) findings are addressed in the
current tree; M5 is accepted drift.

| Finding | Status in current tree | Evidence |
| ------- | ---------------------- | -------- |
| M1 — `git symbolic-ref` denied | Fixed | `shipper.md:20` adds `"git symbolic-ref*": allow`, so the skill's primary default-branch read is permitted. `tests/checks/30-permissions.sh` still classifies the shipper `git-gh` (the pattern is not in its git-write regex). |
| M2 — `merge-tree` exit status/output shape undocumented | Fixed | `SKILL.md:50-52` states exit `1` means conflicts, not failure, and to skip the leading tree-OID line. Independently confirmed by the live probe (exit 1, OID first, path second). |
| M3 — `/status` `DRIFT-FACT` claimed a cross-branch read | Fixed | `status.md:147` now reads "disagrees with disk"; `grep -c 'or the other branch' status.md` = 0. The skill keeps the clause, correctly, for the cross-branch pre-flight. |
| M4 — shared `<handoff>` gained a work-item-only `Detected:` line | Fixed | `shipper.md:190-191` scopes the line: "The `Detected:` line is work-item mode only; fix-landing mode omits it". |
| M5 — sibling `0001` item suite stale | Accepted drift | Still `135 passed, 2 failed`; not a committed-suite failure. See residual risk. |

## Gaps and residual risk

- **Content criteria are literal-presence checks, not semantic proofs.** The
  deliverable is prose plus prompt configuration; there is no runtime harness for
  document content. AC1–AC12 and the edge cases are verified by asserting the
  required literals from the finished surfaces (the design's stated test
  strategy) plus one live probe of the documented `git merge-tree` behavior, with
  negative controls (no `git fetch`/`git merge-tree` in `/status`; no `git rebase`
  in the shipper; no untracked command/agent/script). A literal assertion proves
  the mandated content is present; a reviewer still reads the surfaces for
  coherence. Inherent to the no-executable-detector delivery fork.
- **Sibling `0001-conflict-model`'s historical item suite fails 2 assertions
  (expected drift, not a `0002` defect).** `bash
  work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh` reports
  `135 passed, 2 failed`: (i) `AC9 step detect present` — this child's design
  explicitly splits the fused `**Detect.** … Merge` step into a read-only
  pre-flight plus a `**Reconcile.**` step; (ii) `AC12 command/agent surface
  changed` — this child intentionally edits `.opencode/agent/{shipper,status}.md`,
  which `0001`'s snapshot negative-control forbids. The `0001` suite is committed
  historical evidence under `work/` (not read by `tests/run.sh`, not referenced by
  CI), and its AC12 check is unsatisfiable after any later legitimate agent edit.
  The canonical gate `bash tests/run.sh` is green. I did not weaken, skip, or
  delete those assertions; `0001`'s artifact is another item's evidence and this
  pass leaves it untouched. Refreshing it is a follow-up for that item's owner
  (or a parent-roadmap record of the accepted drift).
- **AC5's "mechanical conflicts auto-resolved" half is satisfied by reference.**
  The shipper states the semantic half explicitly and hands *every* finding to the
  `0001` reconcile step; the mechanical-auto-resolve policy lives unchanged in
  `merge-conflict` skill step 3 and `docs/workflow.md`. The design's AC5 test
  strategy requires only the pre-flight-before-ship, hand-off, and record
  literals, so this satisfies AC5.
- **`git symbolic-ref*`: allow is broader than one mode.** The shipper's bash
  allowlist matches by command prefix, so it cannot distinguish the read form
  `git symbolic-ref refs/remotes/origin/HEAD` from the two-argument reference
  (setting) form. The skill only uses the read form, and the reviewer recommended
  the pattern; low impact, recorded for completeness.
- **`git merge-tree --write-tree` may leave an unreachable object.** The skill says
  "writes no ref and no working-tree file", which is accurate and satisfies the
  spec's read-only definition (no commit, no branch change, no working-tree
  change). The object-DB side effect is noted in the design; not a defect.
- **The empty "roadmap parent with no children" branch is not literalized.**
  `/status` handles an empty `work/` explicitly; an empty Children table yields no
  duplicates and no graph faults by construction. No acceptance criterion is bound
  to a specific phrase; documentation-completeness note only.
- **Live agent behavior is not executed.** Real `/ship` pre-flight and `/status`
  runs need an agent runtime and live branch state; the delivered contract is the
  prompt content asserted here, plus the verified `git merge-tree` primitive.
  End-to-end fixture/mutation coverage is explicitly deferred to sibling
  `0005-merge-integrity-guards`.
- **`verify-tests.sh` AC14 is a working-tree snapshot.** Its `git status`
  change-set assertion will need refresh once siblings `0003`/`0004` touch the same
  `.opencode` surfaces — by design those run after this child. Mirrors the `0001`
  precedent; not a defect.
- **No UI surface.** The work item is prompt/config only; no `/visual` pass is
  applicable.

## Test edits made this pass

Added to `verify-tests.sh` (test-only; no production change):

- **AC1 ordering** — asserts the `## Pre-flight (read-only detection)` section
  precedes `## Procedure` (a distinct, auditable step ahead of resolve).
- **AC2 live behavioral probe** (3 assertions) — creates a scratch git repo,
  produces a real content conflict, runs the documented
  `git merge-tree --write-tree --name-only HEAD <other>` form, and asserts it
  exits non-zero, emits the conflicted path, starts output with the tree OID, and
  leaves the working tree unchanged. This closes the gap where AC2 was covered
  only by literal presence.
