---
feature: 0003-framework-quality-hardening/0002-readiness-ship-state
phase: test
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Independent re-verification of the reworked working tree (base a900b14, all changes uncommitted). This pass added 7 assertions to the item suite (69/0, up from 62) to close five real gaps (whole-tree exactly-once algorithm sweep, whole-tree contradiction sweep, /status-command gh check, lifecycle-surface ship.md naming, derived-state PR-token check) and re-ran all suites, real /doctor and /status, and 14 mutation runs. No production file changed. review.md still carries a stale request-changes verdict that predates the rework; /review must be re-run."
---

# Verification — Readiness semantics and shipped-state detection

## Summary

All ten acceptance criteria and all eleven spec edge cases are verified against
the current working tree (base `a900b149`, working-tree changes only). The change
is prompt/config/doc text plus one executable shell suite; there is no runtime
code and no state file.

This pass changed **no production file**. It extended the item's own suite
`work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh`
with seven assertions that close gaps the existing suites left open:

1. whole-tree exactly-once algorithm sweep (AC1) — the curated candidate list
   previously could be evaded by restating the algorithm in README/AGENTS/doctor;
2. whole-tree approved-but-unshipped contradiction sweep (AC2);
3. derived-state table carries no PR/branch shipped signal (AC4);
4. `AGENTS.md` Ship row and README lifecycle diagram name `ship.md` (AC5/Goal 4);
5. the `/status` command references no `gh` (AC6) — previously only the status
   agent was checked.

These are strengthenings, not fixes: every one passed on the first correct run,
and each was shown to fail under a deliberate mutation (below).

### Test command determination

There is no test runner in this repository. `AGENTS.md` → "Project profile" is an
unfilled template; the only `package.json` is `.opencode/package.json`
(`{"dependencies":{"@opencode-ai/plugin":"1.18.33"}}`, no `scripts.test`); there
is no `pyproject.toml`, `Makefile`, `Cargo.toml`, or `go.mod`. Confirmed by
inspection against the `project-discovery` skill. Matching
`work/0001-framework-consistency-hardening`, `work/0002-agentic-roadmaps`, and
`work/0003-.../0001-state-model`, the framework's verification is read-only shell
assertions plus real agent invocation. The framework suite is
`bash work/0002-agentic-roadmaps/verify-tests.sh` (which T5 extended); the item
suite is its focused independent complement.

### Independent evidence

- Framework suite `work/0002-agentic-roadmaps/verify-tests.sh` → **179 passed,
  0 failed**.
- Focused item suite `.../0002-readiness-ship-state/verify-tests.sh` →
  **69 passed, 0 failed** (62 before this pass; +7).
- **Mutations prove every new guard bites** (see "Mutation evidence").
- Real read-only `/doctor` → **`No findings — repository is consistent.`**
  (agents 14, commands 12, skills 10; no `PERMISSION-TABLE-MISMATCH`, no
  `PERMISSION-WORK-PATTERN`), including the shipper's widened grant.
- Real read-only `/status 0003-framework-quality-hardening` → `0001-state-model`
  derived **`ship`** (approve, no `ship.md`) and reported **ready via its
  approve verdict while unshipped**, so `0002-readiness-ship-state` is `ready`;
  `0001-framework-consistency-hardening` and `0002-agentic-roadmaps` (both with
  committed `ship.md`) derived **`shipped`**. No `gh`/network command trace.
- `opencode debug agent shipper` resolves `edit` to `*` deny, `work/**` allow,
  `**/work/**` allow — matching the README row.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | `TOTAL: 179 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh` | PASS | `TOTAL: 69 passed, 0 failed` (62 pre-pass; +7 added) |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | `TOTAL: 51 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | FAIL (pre-existing) | `TOTAL: 99 passed, 4 failed`; see residual risk |
| `git clone -q . /tmp/opencode/head-clone && bash /tmp/opencode/head-clone/work/0003-.../0001-state-model/verify-tests.sh /tmp/opencode/head-clone` | FAIL (pre-existing) | `TOTAL: 99 passed, 4 failed` on unmodified `HEAD` `a900b14`; confirms unrelated |
| `opencode run --agent doctor "<read-only diagnostic>"` | PASS | `No findings — repository is consistent.`; counts 14/12/10 |
| `opencode run --agent status "/status 0003-framework-quality-hardening"` | PASS | `0001-state-model` ready via approve-unshipped; shipped items derive `shipped`; no `gh`/network trace |
| `opencode debug agent shipper` | PASS | resolved `edit`: `*` deny, `work/**` allow, `**/work/**` allow |
| `grep -rln 'satisfied(dep_local_id):' --include='*.md' . --exclude-dir=work --exclude-dir=node_modules --exclude-dir=.git` | PASS | exactly one hit: `./docs/workflow.md` |
| `grep -rniE 'PR is detected\|PR detected\|detected PR\|no PR\?' --include='*.md' . --exclude-dir=work --exclude-dir=node_modules --exclude-dir=.git` | PASS | no output |
| `grep -rniE 'approved-but-unshipped.*not satisfied\|not satisfied.*approved-but-unshipped' ...` | PASS | no output |
| `git diff --check` | PASS | clean (no whitespace errors) |
| 14 mutation runs on throwaway `/tmp/opencode` copies | PASS (mutations) | every targeted guard failed as designed; see below |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 exactly one surface states the algorithm; others defer by reference | item `AC1 algorithm stated exactly once, in docs/workflow.md`; item `AC1 <status/command/product> defers to the authority by name`; **item `AC1 broad sweep: algorithm token on exactly one live surface`**; 0002 `== AC9 ==` (i)(ii) | PASS |
| AC2 approve-but-unshipped satisfies; no surface denies it | item `AC2 workflow: approve satisfies even if unshipped`; item `AC2 status agent …`; item `AC2 /status command …`; item `AC2 no candidate surface contradicts approve-unshipped`; **item `AC2 broad sweep`**; 0002 AC9(iii)(v); **real `/status`** (`0001-state-model` ready via approve-unshipped) | PASS |
| AC3 surfaces agree branch-for-branch; workflow grouping corrected | item `AC3 authority …`, `AC3 status agent forbids restating …`, `AC3 /status command forbids …`, `AC3 authority no longer groups …`; 0002 AC9(v)(vi) | PASS |
| AC4 `ship.md` presence sole condition; no PR signal | item `AC4 authority: ship.md presence satisfies`, `AC4 algorithm branch order`, `AC4 derived-state row order`, `AC4 derived-state ship.md present -> shipped`, `AC4 ship.md row precedes visual.md row`, `AC4 no live surface credits a detected PR`, `AC4 broad sweep`; **item `AC4 derived-state table has no PR/branch shipped signal`**; 0002 `== AC5/AC6 ==` | PASS |
| AC5 shipper write grant in documented surfaces | item `AC5 shipper frontmatter grants work/**` + `**/work/**`, `AC5 README shipper row …`, `AC5 shipper agent makes the ship.md write required`, `AC5 /ship command …`, `AC5 conventions …`, **`AC5 AGENTS.md Ship row names ship.md`**, **`AC5 README lifecycle names ship.md`**, **`AC5 README state diagram names ship.md`**; item `== AC4/AC5 ship.md signal is committed on the branch ==`; 0002 `== AC11 ==`; `opencode debug agent shipper` | PASS |
| AC6 status agent executable with its own permissions, no `gh`/network | item `AC6 status defers …`, `AC6 status dropped the old algorithm block`, `AC6 status bash allowlist has no gh`, `AC6 status body invokes no gh command`; **item `AC6 /status command references no gh`**; **real `/status`** run | PASS |
| AC7 documented capability, resolved grant, and drift check agree | item `AC7 shipper frontmatter and README row agree`, `AC7 every work-granting agent grants both path forms`; **real `/doctor`** run | PASS |
| AC8 standalone derivation; no state file | item `AC8 approve + no ship.md -> ship`, `AC8 ship.md present -> shipped`, `AC8 no state file introduced`; 0002 `== AC11 ==`; **real `/status`** (approve-no-ship → `ship`; ship present → `shipped`) | PASS |
| AC9 suite asserts one definition and fails on drift | 0002 `== AC9 ==` (9 assertions); item `AC9 suite carries the agreement block`, `AC9 suite asserts the algorithm token`, `AC9 suite asserts exactly-once`; **14 mutation runs** | PASS |
| AC10 suite passes; obsolete assertions updated | 0002 suite 179/0; item `AC10 suite dropped the detected-PR assertion`, `AC10 suite dropped the blanket permission freeze` | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| approve + no `ship.md` → satisfied | item AC2/AC8; 0002 AC9(iii); real `/status` (`0001-state-model` ready) | PASS |
| `ship.md` + `request-changes` → shipped (precedence) | item `AC4 algorithm branch order`, `AC4 derived-state row order`; 0002 AC9(iv) | PASS |
| merged/shipped but no `ship.md` → not satisfied; no surface claims otherwise | item `AC4 no live surface credits a detected PR` + `AC4 broad sweep`; 0002 AC9(iv) | PASS |
| `ship.md` present, no PR URL → presence suffices | item `AC3 authority keys on presence, not contents`; `AC5 conventions names ship.md presence …`; artifact-conventions `PR: <url or "not created">` | PASS |
| no dependencies → ready | item `EDGE no dependencies -> ready`; real `/status` | PASS |
| cycle → never ready | item `EDGE cycle member never ready`; 0002 AC15 | PASS |
| some of several deps unsatisfied → names exactly those | item `EDGE unsatisfied dependencies named by local id`; 0002 multi-dep delimiter; real `/status` blocked child names both blockers | PASS |
| dangling/empty dependency → integrity finding, not a crash | item `EDGE dangling dependency -> not satisfied`; 0002 AC15; real `/status` findings non-fatal | PASS |
| read-only derivation with no network → succeeds | item AC6; real `/status` (no `gh`/URL trace) | PASS |
| `/status` mid-`/ship`, before `ship.md` → pre-ship phase, not an error | item `AC8 approve + no ship.md -> ship`; real `/status` (`0001-state-model` = `ship`) | PASS |
| standalone item → rules behave as before | item AC8; 0002 AC11 | PASS |

## Mutation evidence

Each run mutated a throwaway copy under `/tmp/opencode/mut` (production tree
untouched) and ran the named suite with the copy as `ROOT`. Baseline on an
untouched copy: 0002 suite `179/0`, item suite `69/0`.

| Mutation | Expected guard | Observed |
| -------- | -------------- | -------- |
| Second `satisfied(dep_local_id):` appended to `README.md` | item AC1 broad sweep | FAIL 1: `algorithm token on 2 live surface(s)` |
| Detected-PR branch re-added to `docs/workflow.md` | item AC4 broad sweep | FAIL 3 |
| `approved-but-unshipped … not satisfied` appended to status agent | item AC2 broad sweep | FAIL 2 |
| Second algorithm token in status agent | 0002 AC9 exactly-once | FAIL 1: `appears in 2 candidate file(s)` |
| Skill reverted to `no PR?` | 0002 AC9 (vi) | FAIL 2 |
| `docs(work): record ship state` removed from shipper agent | item AC5 commit guard | FAIL 1 |
| All `presence is the sole shipped signal` removed from workflow | item AC3 | FAIL 1 |
| Derived-state `ship.md present → shipped` row replaced with a `PR detected` row | item AC4 | FAIL 8 |
| `even if unshipped` removed from workflow | item AC2 | FAIL 1 |
| `ship.md or detected PR` re-added to `/status` command | item AC6/AC4 | FAIL 4 |
| `no uncommitted ship.md` removed from workflow | item AC4 commit guard | FAIL 1 |
| Contradiction phrase appended to status agent | 0002 AC9 (v) | FAIL 1 |
| `a PR is detected` appended to `README.md` | 0002 AC9 (iv) | FAIL 1 |
| README shipper row reverted to `none` | item AC5/AC7 | FAIL 3 |

No mutation produced a false negative, and no mutation was able to pass a suite
while a guard it targets was violated.

## Gaps and residual risk

- **Pre-existing, out of scope:** `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh`
  fails 4 assertions (99/4) because AC1/AC3 expect 0001's artifacts to be
  untracked, but they were committed in `b14c0d3`. **Independently reproduced on a
  clean `HEAD` clone** (`a900b14`) before this item's changes, so it is not
  attributable here. AC10 targets the framework suite T5 extended (the 0002
  suite), which passes. Recommend reconciling that stale suite or letting
  `0006-committed-tests-ci` relocate/repoint it.
- **Stale process artifact (not a test failure):** `review.md` carries a
  `request-changes` verdict (M1: the `ship.md` signal was written after the
  commit/push and never committed). The current tree **does** address M1: the
  shipper process now has step 7 to stage/commit/push `ship.md`
  (`docs(work): record ship state`), the `/ship` command and `docs/workflow.md`
  Ship phase/Exit match, and the item suite asserts it. Because the derived-state
  table reads `review.md → request-changes` as `build (rework)`, `/status`
  currently reports this item as rework. `/review` must be re-run to refresh the
  verdict; this pass did not touch `review.md`.
- **Derived-state row ordering (latent, reviewer n1):** `ship.md present` is
  below `verify.md present, review.md missing`, so a hand-made `ship.md` with no
  `review.md` would derive `review`, not `shipped`. This is unreachable on the
  normal path (the Ship precondition requires an approved `review.md`) and is not
  required by the spec's edge-case list. Not asserted as a failure; recorded as a
  follow-up suggestion: move the `ship.md present` row directly under the
  `roadmap.md` row for a strictly monotone "presence wins" table.
- **Guard scope:** the AC9 candidate list and the AC4 broad sweeps are
  token-based heuristics, not proofs. A paraphrase that avoids the exact tokens
  (for example, a routing rule keyed on a merged branch without the word "PR")
  could still evade both suites. The sweeps now cover every live `.md` under
  `.opencode/`, `docs/`, `AGENTS.md`, and `README.md` (41–71 surfaces per sweep);
  historical `work/**` artifacts are deliberately excluded so history is never
  rewritten or falsely flagged.
- **Deferred/manual:** an actual `/ship` run that writes a fresh `ship.md` and a
  clean-clone read-back was not executed (it would mutate the tree and requires
  user approval). Presence-based derivation is asserted statically, the commit
  requirement is asserted in all three surfaces, and the real `/status` run
  correctly derives `shipped` for the two committed `ship.md` files
  (`0001-framework-consistency-hardening`, `0002-agentic-roadmaps`).
- **Historical artifact note:** `work/0002-agentic-roadmaps/verify-tests.sh` is
  another shipped item's test file; only executable assertions changed (the
  planned deliberate cross-item edit, `design.md:124-127`), and
  `work/0002-agentic-roadmaps/verify.md` remains untouched with its superseded
  169 count and its mention of the removed detected-PR branch.

## Self-check

- No production file was modified: `git status --porcelain` lists the same 10
  tracked modified files as before this pass; the only additions are this pass's
  assertions inside the item's `verify-tests.sh` and this `verify.md`.
- No test was weakened, skipped, or deleted. The item suite grew from 62 to 69
  assertions; all 69 pass.
