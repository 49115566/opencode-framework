---
feature: 0012-roadmap-deprecation/0003-parent-migration
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Verification — Existing-parent migration: grandfather the seven live decomposing nodes and migrate the test fixtures

## Summary

All 11 acceptance criteria and the spec edge cases are verified. The suite is
green (`502 passed, 0 failed, 0 skipped`), the opt-in mutation pass is green
(`29 checked passed, 0 failed`, every mutated surface restored), and the seven
grandfathered parents are byte-for-byte untouched. No production code was
changed; the only changes are test-side.

Two focused assertions were added to close AC3 coverage gaps (both use migrated
`manifest.md` paths, so AC5's "no guard references a migrated fixture's old
`roadmap.md` path" still holds):

- `tests/checks/85-conflict-guards.sh` — the migrated `9002-roadmap-b/manifest.md`
  was not pinned for `phase: manifest` or the `# Manifest —` heading; it is now
  in the `modern-spelling` loop alongside `9001` and `9003`.
- `tests/checks/80-cycle-fixture.sh` — AC3's negative ("no migrated fixture
  remains named `roadmap.md`") had no committed guard. A check now pins the
  retained cyclic alias as the only `roadmap.md` under `tests/fixtures/` (it
  names no migrated old path, only the retained legacy alias, so it stays within
  AC5).

No `challenges.md` exists for this item (nothing to adjudicate) and no defects
were found, so no `backtracks.md` finding was recorded.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 502 passed, 0 failed, 0 skipped` |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 29 checked passed, 0 failed`; `whole-suite runs: 2`; clean copy (no `work/`) passes |
| `bash tests/mutation.sh --selftest` | PASS | `SELFTEST: 6 passed, 0 failed` |
| `FRAMEWORK_TEST_AREAS=80-cycle-fixture,85-conflict-guards,87-backtrack-guards bash tests/run.sh` | PASS | `TOTAL: 174 passed, 0 failed, 0 skipped` |
| `grep -rl 'phase: roadmap' tests/fixtures` | PASS (expected) | lists only `tests/fixtures/cyclic-roadmap/roadmap.md` (retained alias) |
| `grep -rl 'phase: manifest' tests/fixtures` | PASS (expected) | lists the five migrated manifests (9001, 9002, 9003, 9120, 9121) |
| `find tests/fixtures -name roadmap.md` | PASS (expected) | `tests/fixtures/cyclic-roadmap/roadmap.md` only |
| `git status --short work/0003-… work/0004-… work/0005-… work/0006-… work/0007-… work/0010-… work/0011-…` | PASS | empty — no grandfathered parent touched |
| `git diff --name-only HEAD` | PASS (expected) | only fixtures, the three guards, `tests/README.md`, `tests/mutation.sh`, and this item's `tasks.md` |
| `git diff --name-only HEAD -- docs/ .opencode/ template/ README.md AGENTS.md` | PASS | empty — no out-of-scope surface touched |
| `grep -n 'roadmap.md' tests/checks/85-conflict-guards.sh tests/checks/87-backtrack-guards.sh` | PASS | empty (T2/T3 verify step; no migrated old path referenced) |
| `grep -n 'roadmap cycle rule' tests/checks/80-cycle-fixture.sh` | PASS | empty (T4 verify step) |
| `grep -n 'AC13 committed cycle fixture missing' tests/checks/80-cycle-fixture.sh` | PASS | present (T4 verify step) |
| `grep -rn 'roadmap' tests/README.md tests/checks/80-cycle-fixture.sh tests/checks/85-conflict-guards.sh tests/checks/87-backtrack-guards.sh` | PASS | only retained-alias/legacy-fixture prose, the stable `AC24 roadmap-revision` label, preserved fixture directory names, and the manifest-then-alias resolver loop |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — Grandfather read-only | manual: `git status --short` over the seven parents is empty; each still has `roadmap.md` with `phase: roadmap` and no `manifest.md`; `0010` retains its eight `Withdrawn child` records and each parent a `## Children` table. No committed test: the suite must not read live `work/**` (AC8). | MANUAL (PASS) |
| AC2 — Decision recorded | manual: read `spec.md` (frontmatter `notes`, Goals, resolved Open questions) and `design.md` §1 ("Grandfather the seven live parents (no edits)"). | MANUAL (PASS) |
| AC3 — Fixtures use the modern spelling | `85-conflict-guards.sh` `modern-spelling` assertions for `9001`/`9002`/`9003`; `87-backtrack-guards.sh` `modern-spelling` assertions for `9120`/`9121`; `80-cycle-fixture.sh` "only `roadmap.md` fixture" assertion (added); `find`/`grep -rl` commands | PASS |
| AC4 — Deprecated-alias coverage retained | `80-cycle-fixture.sh` "cycle fixture resolves to the retained legacy `roadmap.md` alias", `phase: roadmap`, `# Roadmap —`, Children header, cycle parse; `tests/mutation.sh` `job_8` ("removed the committed cycle fixture") | PASS |
| AC5 — Guards reconciled to the fixtures | `FRAMEWORK_TEST_AREAS=80,85,87` → `174 passed, 0 failed`; `grep -n 'roadmap.md'` in `85`/`87` empty; no guard references a migrated fixture's old path | PASS |
| AC6 — Mutation tooling reconciled | `bash tests/mutation.sh` → `29 checked passed, 0 failed`; `job_8`→`cyclic-roadmap/roadmap.md`, `job_15`/`job_16`→`9001-roadmap-a/manifest.md`, `job_24`→`9120-revised-roadmap/manifest.md`; every restore byte-for-byte | PASS |
| AC7 — Test prose terminology reconciled | `grep -rn 'roadmap'` over `tests/README.md` and the three guards: only the retained-alias/legacy fixture prose, the stable `AC24 roadmap-revision` label, preserved fixture directory names (`9001-roadmap-a`, …), and the resolver loop `for base in manifest roadmap` | PASS |
| AC8 — Read-only and no live-work dependency | `85`/`87` `read-only-contract` assertions (no live `work/` path, no nested `work/` dir, no absolute/escaping path); mutation's "clean copy (no `work/`) passes"; `find tests/fixtures -type d -name work` empty; fixture-local `Canonical reference` cells unchanged | PASS |
| AC9 — Suite stays green | `bash tests/run.sh` → `502 passed, 0 failed, 0 skipped` | PASS |
| AC10 — Scope | `git diff --name-only HEAD` lists only the five migrated manifests, `cyclic-roadmap/roadmap.md`, the three guard scripts, `tests/README.md`, `tests/mutation.sh`, and this item's `tasks.md`; the seven parents are untouched; no new `work/` sequence number is allocated | PASS |
| AC11 — Extend, do not fork | diff inspection: no new agreement area, guard, finding code, state model, reference grammar, or conflict class; six-column `Children` header preserved in `9001`/`9002`/`9120`/`9121`, the legacy five-column header preserved in `9003`; `conflicts-with` grammar untouched | PASS |

### Edge cases (spec)

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Legacy-alias fixture keeps a distinct spelling | `80-cycle-fixture.sh` resolves the fixture to `*/roadmap.md` and asserts `phase: roadmap` / `# Roadmap —` | PASS |
| Absent-column legacy | `85-conflict-guards.sh` `column-layout` asserts the five-column header on `9003-roadmap-old/manifest.md` | PASS |
| Fixture-local references | `85`/`87` `read-only-contract`; `feature: fixture-cyclic-roadmap` and `fixture-cyclic-roadmap/…` `Canonical reference` cells unchanged | PASS |
| Heading spelling | `modern-spelling` `# Manifest —` assertions on all five migrated manifests | PASS |
| Mutation restore | `tests/mutation.sh` restore is byte-for-byte (`cmp -s`), `0 failed` | PASS |
| Unaffected child state | existing `85`/`87` assertions over `.gitkeep`-only, shipped, and recalled fixture children pass unchanged | PASS |
| No-op fixture | `9003-roadmap-old` (minimal, five-column) migrates; covered indirectly by existence/`column-layout`; no dedicated "no-content" fixture exists | PASS (partial — no dedicated fixture) |
| Empty / absent | fixture-existence and `modern-spelling` assertions fail on a missing manifest; `80` also pins the exactly-one legacy fixture | PASS |
| Concurrency | N/A — committed fixtures and prose only; no runtime state or shared resource | N/A |

## Gaps and residual risk

- **AC1, AC2, AC10 are inspection criteria, not committed tests.** The suite is
  contractually read-only over live `work/**` (AC8), so the grandfather decision
  and the scope boundary are verified by `git status`/`git diff` and by reading
  the item's artifacts, and recorded here rather than encoded as suite
  assertions. This is intentional and matches the design's test strategy.
- **Manifest-first resolver masks a dual-spelling directory.** If a fixture
  directory held both `manifest.md` and `roadmap.md`, the resolver would prefer
  `manifest.md` and the duplicate would be invisible. The added `80` assertion
  pins the committed fixture set to exactly the retained cyclic alias, closing
  this for the suite fixture tree; live `work/` drift (`DRIFT-FACT`) remains the
  documented contract owned elsewhere and is out of this item's scope.
- **The `AC3` negative is now committed-tested**, but by a whole-tree `find` in
  `80-cycle-fixture.sh` rather than per-directory checks (per-directory checks
  would have named migrated fixtures' old paths, conflicting with AC5/T2/T3).
  `find` is POSIX and platform-independent; the guard otherwise uses `ls`/globs.
- **AC7 cannot distinguish preserved directory names from the retired concept
  term from a bare grep.** `9001-roadmap-a`, `9120-revised-roadmap`, and the like
  carry the substring `roadmap` as immutable directory/`feature` names that the
  design explicitly preserves; the check treats these as out of scope for the
  terminology sweep.
- **No dedicated "no-op fixture".** The spec's "a fixture with no content beyond
  its `Children` table still migrates" case has no isolated fixture; it is
  covered indirectly by the minimal `9003-roadmap-old` fixture. Low risk.
