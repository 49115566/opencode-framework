---
feature: 0007-phase-backtracking/0005-post-ship-pr-denial
phase: test
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Verification — Post-ship PR denial, recall, and reopen

The deliverable is framework documentation and prompts (no runtime code). The
spec's acceptance criteria name the surfaces that must carry the recall route;
the design maps AC1–AC12/AC14 to surface inspection and AC13 to the committed
suite. Committed, fixture-based guards for the recall signal and the readiness
revocation are explicitly assigned to sibling `0007-backtracking-guards` by the
parent roadmap and the item's non-goals, so this pass verifies by inspection plus
the suite and does **not** add a guard that would implement `0007`'s scope
(AC14). No test was weakened, skipped, or deleted.

This verification was re-run against the **current working tree**, which is newer
than the `review.md` snapshot: `docs/artifact-conventions.md` (09:33) and
`.opencode/agent/status.md` (09:34) were edited after `review.md` (09:31). The
review's [M1] (`artifact-conventions.md` "keyed on the file existing, never on
its contents") and [m2] (status "presence alone") are **resolved** in the tree
this pass examined; see "Gaps and residual risk".

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 341 passed, 0 failed, 0 skipped`; exit 0. |
| `bash tests/run.sh` (second run) | PASS | Determinism confirmed: `341 passed, 0 failed, 0 skipped`; exit 0. |
| Isolated-copy baseline (`bash tests/run.sh /tmp/opencode/mut`) | PASS | Throwaway copy of the live tree (no `.git`): `341 passed, 0 failed, 0 skipped`. Proves the suite reads only live surfaces, not `work/**`. |
| Mutation probe: delete ` \| /ship recall <item-ref> <phase>` from `.opencode/command/ship.md` (throwaway copy) | FAIL as designed | `TOTAL: 340 passed, 1 failed, 0 skipped`; the failure is exactly `FAIL AC22 .opencode/command/ship.md usage string does not document '… \| /ship recall <item-ref> <phase>'`. The new assertion is meaningful, not theater. |
| Mutation probe: delete the readiness recalled branch from `docs/workflow.md` (throwaway copy) | **Suite stays green** (`341/0/0`) | Confirms the documented gap: no committed guard pins the recalled readiness branch. Guard ownership is sibling `0007-backtracking-guards` (spec non-goal / AC14), so this is expected, not a defect. |
| `git status --short`, `git diff --name-status HEAD` | PASS | 13 modified + 2 untracked phase artifacts; no new file under `.opencode/{agent,command,skill}`; parent `roadmap.md` untouched. |
| Surface `grep` inspections | PASS | Evidence per criterion below; `grep -rniE 'presence only\|presence alone\|never on its contents\|keyed on the file\|irrevocab'` over all live surfaces returns **no match** (only `node_modules` license text). |

## Acceptance coverage

| Criterion | Test(s) / verification | Result |
| --------- | ---------------------- | ------ |
| AC1 — post-ship states enumerated and distinguished | manual: `docs/workflow.md:808-828` (`#### Post-ship states`) enumerates **Pre-ship**, **Shipped** (open/merged, never opened, branch abandoned), **Recalled/reopened**, and states a denied/closed/changes-requested PR is "not a state by itself". | PASS (manual) |
| AC2 — recall records condition, evidence, re-entry phase; append-only | manual: `docs/workflow.md:851-867`; `.opencode/agent/shipper.md:303-317`; `.opencode/command/ship.md:133-148` — finding entry with `detecting phase: /ship`, `target phase`, `evidence`, `status: open`; "sequential and append-only — never edit, reorder, or remove a prior entry". | PASS (manual) |
| AC3 — historical `ship.md` retained and gains `reopened:`; distinct from `status` | manual: `docs/workflow.md:868-872`; `shipper.md:318-325`; `command/ship.md:149-154`; `docs/artifact-conventions.md:53-65` — "leave the recorded branch, commits, PR URL, and body intact", "without deleting or rewriting", "distinct from the frontmatter `status`". | PASS (manual) |
| AC4 — derives `P` (reopened); marker and `stale:` name the same `P` | manual: derived-state row `docs/workflow.md:925` (`ship.md` with `reopened: P` → `P (reopened)`), rows 1–2 evaluated first (`:938-946`); marker table pairs `reopened: build/design/spec` with `stale: build/design/spec` (`:881-883`). | PASS (manual) |
| AC5 — recalled item does not satisfy dependents; non-recalled unchanged; no second signal | suite + manual: `tests/checks/10-readiness.sh` green (single `satisfied(dep_local_id):` authority, pinned phrases intact); `docs/workflow.md:93-95` recalled branch precedes the plain-presence branch, prose `:110-113`; `.opencode/agent/status.md:128-138` and `.opencode/command/status.md:18-25` carry the deferring clause. | PASS (suite + manual) |
| AC6 — downstream `stale:` per `0002`; re-entry revises/appends/resumes | manual: `docs/workflow.md:873-883` marker table, `:896-905` re-entry; `/build` target-side re-entry in `.opencode/agent/builder.md:43-47,66-72` and `.opencode/command/build.md:16-21`. | PASS (manual) |
| AC7 — earlier phase, recorded/deterministic, refused otherwise | manual: `docs/workflow.md:840-848` (`<phase> ∈ {spec, design, build}`, "strictly earlier than ship — `test`, `review`, and `ship` are refused"; refused when no `ship.md`); `shipper.md:171-177`; `command/ship.md:129-132`. | PASS (manual) |
| AC8 — mode of existing `/ship`; signatures consistent; no new command/agent/skill | suite + manual: `tests/checks/96-signature-sweep.sh` new `/ship recall` assertion is green and mutation-proven; `tests/checks/40-inventory.sh` green; `command/ship.md:2,11,122-180` enumerates the mode; canonical `/ship [item-ref]` registry unchanged; no new file under `.opencode/`. | PASS (suite + manual) |
| AC9 — re-ship reuses branch/PR, never force-push/rebase/rewrite, never closes PR | manual: `docs/workflow.md:906-914`; `shipper.md:239-247,380-389`; `command/ship.md:175-180`. | PASS (manual) |
| AC10 — non-recalled contract unchanged; no second signal/state file | suite + manual: `10-readiness.sh` pinned phrases intact; `phase` value comment unchanged (`docs/artifact-conventions.md:19`); `git diff --name-status` shows no new artifact/state file. | PASS (suite + manual) |
| AC11 — never-opened/abandoned stay shipped until explicit recall; no auto-detection/revocation | manual: `docs/workflow.md:815-819` ("stay shipped until an explicit recall; no automatic detection and no automatic revocation occurs"); denied/closed/changes-requested "not a state by itself" (`:826-828`). | PASS (manual) |
| AC12 — all named surfaces state the route consistently; no irrevocability claim | manual: route present in `docs/workflow.md`, `docs/artifact-conventions.md:53-65,514-518`, `.opencode/agent/shipper.md`, `.opencode/command/ship.md`, `.opencode/skill/workflow-lifecycle/SKILL.md:45,75-80`, root + `template/AGENTS.md:131-141`, `.opencode/agent/status.md`, `.opencode/command/status.md`, `.opencode/agent/builder.md`, `.opencode/command/build.md`. `95-split-guard.sh` confirms root↔template parity. The review's [M1] sentence is now the reconciled form (`artifact-conventions.md:474-477`) and the prohibited phrases are absent from every live surface. | PASS (manual + suite parity) |
| AC13 — configured test command passes; agreements updated with the change | suite: `bash tests/run.sh` → `341 passed, 0 failed, 0 skipped` (exit 0), run twice; the one pre-recall signature agreement (`96-signature-sweep.sh`) was updated together with the `/ship` usage change. | PASS |
| AC14 — scope fence: only states/revocation/re-entry; siblings untouched; no second vocabulary | manual: `git diff --name-status HEAD` lists only the design's named surfaces plus `tasks.md`; no new `.opencode/{agent,command,skill}` file; six `phase` values, command→agent pairings, merge-conflict contract, sibling edges, `/status` vocabulary, and committed guards untouched. `/build` adds only the target-side open-finding check, no `/test`/`/review`→`/build` detecting edge. | PASS (manual) |

### Edge cases

| Edge case | Verification | Result |
| --------- | ------------ | ------ |
| `ship.md` present, PR "not created" | `docs/workflow.md:815-819` (same shipped state); recall is explicit only. | PASS (manual) |
| Second recall after re-ship | `docs/workflow.md:891-893`; `shipper.md:343-345`; `command/ship.md:172-174` — new finding appended, marker updated, no prior entry erased. | PASS (manual) |
| Branch pruned before re-ship | `docs/workflow.md:909`; `shipper.md:241-243` — opens a new PR rather than force-pushing. | PASS (manual) |
| No downstream artifacts to mark | `docs/workflow.md:879`; `shipper.md:326-334` — whichever exist are marked, absent skipped. | PASS (manual) |
| `gh` unavailable | `docs/workflow.md:886-889`; `shipper.md:171-173,367-370` — local commits, exact push commands reported; recording/revoking never requires network. | PASS (manual) |
| Denied PR still open | `docs/workflow.md:910-911`; `shipper.md:244,387-389` — never delete or close the PR. | PASS (manual) |
| Target phase ≥ ship | `docs/workflow.md:847`; `shipper.md:177` — `test`/`review`/`ship` refused. | PASS (manual) |
| Dependent of a recalled item | `docs/workflow.md:110-113`; status surfaces — reported blocked until re-ship; derived live, nothing stored. | PASS (manual) |
| Re-entry with no open finding | `docs/workflow.md` `### Re-entry` "No open finding" clause; `builder.md:66-72`; `command/build.md:16-21` — ordinary forward progression, fabricates nothing. | PASS (manual) |
| Recall on an item that never shipped | `docs/workflow.md:845-846`; `shipper.md:175-176` — refused; an unshipped item is an ordinary backtrack. | PASS (manual) |
| Concurrent recall on two branches | Handled by the shipped merge-conflict class (b) contract; this item writes only its own item's committed state. No new behavior required. | PASS (manual, by contract) |
| Marker vs lifecycle tokens | `docs/workflow.md:872`; `docs/artifact-conventions.md:64` — `reopened`/`stale` distinct from `status`, no new `phase` value. | PASS (manual) |

## Gaps and residual risk

- **No committed fixture guard for the recall signal / readiness revocation —
  mutation-proven.** Deleting the recalled branch from the readiness algorithm in
  a throwaway copy still yields `341 passed, 0 failed`. The parent roadmap assigns
  "the post-ship recall signal and readiness no longer satisfied" to
  `0007-backtracking-guards`, and this item's non-goals/AC14 forbid implementing
  that guard here. Until `0007` lands, the recall contract is carried by prompt/doc
  prose; a future edit could drop the recalled branch without a failing test. This
  is the expected sequencing, not a defect of this item.
- **Wording nuance at `docs/workflow.md:104-109`.** The readiness prose says the
  signal is "keyed on presence rather than contents" before the recalled exception
  is stated at `:110-113`. Read as a paragraph it is consistent (and the pinned
  phrase `presence is the sole shipped signal` is intentionally kept verbatim by
  the design), but the clause alone overstates: the authority now reads the
  `reopened:` marker from the file's contents. This is the same class as the
  review's [m2] (which was fixed in `status.md`); it is a wording residual, not an
  AC12 failure, because the surface as a whole explicitly revokes the signal.
- **Minor wording residuals from the review (non-blocking).** [m3] the recall
  finding template's `affected:` hardcodes `ship.md`/`verify.md`/`review.md` (a
  `spec` recall also stales `design.md`/`tasks.md`; the authoritative marker table
  is correct). [n1] the skill routing line names only "PR
  denied/closed/changes-requested". [n2] the shipper's step 4 branch-creation
  precedes its step-10 re-ship override. None affect an acceptance criterion.
- **Declared-conflict `DRIFT-FACT` by design.** `design.md`'s `conflicts-with`
  list is a superset of the parent `Children` row's cell, so the read-only
  declaration check reports `DRIFT-FACT` for this child (advisory; adds no
  readiness edge). The roadmap owner owns updating the parent cell; not
  test-pinned here.
- **Review snapshot is stale relative to the tree.** `review.md` (09:31) assessed
  the tree before the builder's [M1]/[m2] edits (`artifact-conventions.md` 09:33,
  `status.md` 09:34). Both findings are resolved in the tree verified here; the
  next `/review` should reassess the current tree rather than the recorded
  request-changes snapshot.
- **Mutation coverage.** `tests/mutation.sh` is opt-in maintainer tooling and is
  extended by `0007`; not run here. The one new assertion was independently
  mutation-probed and shown to fail-and-name when the recall form is removed.

## Verdict

All 14 acceptance criteria and all 12 edge cases are satisfied on inspection of
the current live surfaces; the configured suite passes (`341 passed, 0 failed,
0 skipped`, twice, exit 0), the sole test change is meaningful and
mutation-proven, and no production defect blocks verification. The only residual
is the committed guard coverage explicitly deferred to sibling
`0007-backtracking-guards`, plus minor wording residuals that affect no criterion.
