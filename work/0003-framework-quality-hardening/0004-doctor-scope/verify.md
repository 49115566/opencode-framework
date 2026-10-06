---
feature: 0003-framework-quality-hardening/0004-doctor-scope
phase: test
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Re-verification pass after /review request-changes. Item suite 66/0 on the working tree AND on a committed-tree simulation (review M1 durability fixed). Review m1/m2/m3 confirmed fixed. Real /doctor runs reproduced: clean (14/12/10) and README-missing (exactly one SURFACE-MISSING, zero cascade). No production file changed by this pass."
---

# Verification — Doctor audience and diagnostic accuracy

## Summary

All eleven acceptance criteria and all eight spec edge cases are verified against
the current working tree (base `ff5a2fa`). The product is prompt/documentation
text; there is no runtime code, no schema, and no state file. Verification is
static inspection plus **two real `/doctor` agent invocations reproduced this
pass** (`opencode run --agent doctor`), matching the test-strategy table in
`design.md`.

This pass changed **no production file**. It re-ran and audited the item suite
added for this work item and re-derived every acceptance criterion independently
of `verify.md`'s earlier claims. The suite is the committed evidence:

- `work/0003-framework-quality-hardening/0004-doctor-scope/verify-tests.sh` —
  66 read-only shell assertions covering AC1–AC11 and the spec edge cases. Its
  only writes are a throwaway quickstart fixture under `scratch/` (gitignored),
  removed on exit via a trap.

It also **closes the four findings from `review.md`**, all of which were
test-durability or prompt-consistency issues, not acceptance failures:

- **M1** — the AC10 change-set assertion failed on a committed tree. The suite
  now accepts either the uncommitted change set or a clean tree and relies on the
  content-based invariants; verified 66/0 on a committed copy.
- **m1** — the AC1 whole-tree sweep scanned `.opencode/node_modules/**/*.md`.
  The `find` now excludes `*/node_modules/*` (39 files scanned vs 69 before).
- **m2** — the maintainer-only label had been placed inside the README Agents
  row's "Can run bash" cell, which check #6 compares. The README Agents row is
  now untouched (`README.md:189` byte-identical to `HEAD`); the label lives only
  in description/non-compared surfaces.
- **m3** — `.opencode/command/doctor.md` said "Run the nine checks" while
  listing ten bullets. The surface guard is now a separate bullet before the
  numbered list; the list holds exactly nine checks.

### Test command determination

There is no test runner in this repository. `AGENTS.md` → "Project profile" is an
unfilled template; the only `package.json` is `.opencode/package.json`
(`{"dependencies":{"@opencode-ai/plugin":"1.18.34"}}`, no `scripts.test`); there
is no root `package.json`, `pyproject.toml`, `Makefile`, `Cargo.toml`, or
`go.mod`. Confirmed via the `project-discovery` skill. Matching
`work/0001-framework-consistency-hardening`, `work/0002-agentic-roadmaps`, and
`work/0003-.../0001-state-model`, the framework's verification is read-only shell
assertions plus real agent invocation.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0003-framework-quality-hardening/0004-doctor-scope/verify-tests.sh` | PASS | `TOTAL: 66 passed, 0 failed` |
| same suite against a committed-tree copy (`/tmp/opencode/durable-0004`) | PASS | `66 passed, 0 failed` — proves review M1 (durability) is fixed |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | `TOTAL: 179 passed, 0 failed` |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | `TOTAL: 51 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh` | PASS | `TOTAL: 69 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | FAIL (pre-existing + transient) | `98 passed, 5 failed`; 4 pre-existing on `HEAD`, 1 transient change-set guard — see "Gaps" |
| `opencode run --agent doctor "Run the framework consistency diagnostic."` | PASS | `No findings — repository is consistent.`; `Checked counts: agents 14, commands 12, skills 10` |
| same `/doctor` in a git copy with `README.md` deleted | PASS | Exactly 1 `[SURFACE-MISSING] README.md`; 0 `*-UNDOCUMENTED`/`*-PHANTOM` cascade findings |
| `git status --porcelain` before/after the clean `/doctor` run | PASS | identical; the run created/edited nothing |
| quickstart simulation into `scratch/qs-verify` (documented `cp -r` + `rm -f`) | PASS | 13 agents / 11 commands copied; neither `doctor.md` present |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — every documented `/doctor` surface marks it maintainer-only | item `AC1 README carries the marker`, `AC1 AGENTS.md carries the marker`, `AC1 docs/workflow.md carries the marker`, `AC1 doctor agent description …`, `AC1 /doctor command description …`, `AC1 README /doctor Commands row is marked` + `name/agent cells unchanged`, `AC1 AGENTS.md /doctor entry …`, `AC1 AGENTS.md doctor entry …`, `AC1 broad sweep: all 5 live /doctor surfaces carry the marker` | PASS |
| AC2 — fresh adoption installs no doctor agent/command | item `AC2 quickstart contains the doctor removal step`, `AC2 quickstart result has no doctor agent and no /doctor command`, `AC2 sanity: the framework repo itself still has both` | PASS |
| AC3 — docs state maintainer-only, adoption absence, misreport warning | item `AC3 README states maintainer-only`, `AC3 README explains … not copied`, `AC3 README warns … not authoritative`, `AC3 README addresses an existing adoption`, `AC3 README tells existing adopters to remove or ignore`, `AC3 README warns an out-of-band copy misreports`, `AC3 workflow routing bullet marks maintainer-only` | PASS |
| AC4 — examples carry no concrete count and no `file:line` | item `AC4 finding examples contain no integer at all`, `AC4 no file:line citations …`, `AC4 no concrete inventory counts …`, `AC4 COUNT-MISMATCH example is symbolic …`, `AC4 … names the Layout comment`, `AC4 TEMP-PATH example is symbolic …`, `AC4 a SURFACE-MISSING example is present` | PASS |
| AC5 — classification derived from declared state, no inline snapshot | item `AC5 completeness rule has no inline non-lifecycle agent snapshot`, `AC5 classification derives from docs/workflow.md`, `AC5 classification keys on the phase tables`, `AC5 rule states a command-less agent is not a finding`, `AC5 … does not hard-code agent name 'ask'/'scout'/'scribe'/'bootstrap'`, `AC5 command agrees …` | PASS |
| AC6 — one finding for a missing surface, never a per-item cascade | item `AC6 agent/command defines the SURFACE-MISSING code`, `AC6 rule emits exactly one …`, `AC6 rule forbids the per-item cascade`, `AC6 command emits exactly one …`, `AC6 command forbids the per-item cascade`; **real README-missing `/doctor` run (git repo)** → exactly 1 `[SURFACE-MISSING] README.md`, 0 cascade | PASS |
| AC7 — clean framework run with checked counts | item `AC7 README layout comment agrees: 14 role prompts / 12 slash commands / 10 knowledge skills`; **real `/doctor` run** → `No findings`; agents 14, commands 12, skills 10 | PASS |
| AC8 — README stays out of always-loaded instructions; still read on demand | item `AC8 opencode.json instructions do not include README.md`, `AC8 opencode.json is unchanged by this item`, `AC8 the diagnostic still reads README.md on demand`, `AC8 README.md is a declared diagnostic input`; `opencode.json` instructions = `AGENTS.md`, `docs/workflow.md`, `docs/artifact-conventions.md` | PASS |
| AC9 — read-only guarantee unchanged | item `AC9 doctor permission block is byte-identical to HEAD`, `AC9 edit stays denied`, `AC9 bash catch-all stays denied`, `AC9 read-only rule preserved in the agent/command`; `git status` identical before/after the real run | PASS |
| AC10 — no phase/input/output/exit/command-behaviour change | item `AC10 only the five expected files changed`, `AC10 docs/workflow.md Phases..Derived-state section is byte-identical`, `AC10 no other command file changed`, `AC10 artifact conventions unchanged`; `git diff --name-only HEAD` = the five expected files | PASS |
| AC11 — doctor facts (inventories, counts, permission table, ignore rules) still agree | item `AC11 agent retains the full check-code catalogue` (12 codes); **real `/doctor` run** printed `No findings` after all nine checks | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Upgrading an existing adoption (doctor files already present) | item `AC3 README addresses an existing adoption`, `… remove or ignore` | PASS (static) |
| Out-of-band `.opencode/` copy retains the files | item `AC3 README warns an out-of-band copy misreports` | PASS (static) |
| Missing documentation surface → one finding, no cascade | **real README-missing `/doctor` run in a git repo**: exactly 1 `[SURFACE-MISSING]`, 0 inventory findings | PASS (real) |
| Unreadable (permission-denied) surface rather than absent | none — file-permission denial cannot be exercised deterministically without touching the repo; the rule text covers "absent or unreadable" | MANUAL (see Gaps) |
| New inventory item added without docs → no stale exemption | item AC5 (`docs/workflow.md` phase-table derivation; no inline snapshot) | PASS (static) |
| Documented item deleted → phantom still reported | item `EDGE documented item with no file is still reported`, `EDGE command phantom`, `EDGE skill phantom` | PASS (static; existing behaviour) |
| Empty `work/` state → clean, no error | item `EDGE doctor's declared inputs do not read work/`; the real run's nine checks never touch `work/` | PASS (static + reasoned) |
| Wrong working directory → root resolved from repo | item `EDGE wrong working directory resolved from repo root` (`git rev-parse --show-toplevel` in process step 0); the README-missing run resolved the git root correctly | PASS (static + real) |
| Concurrent activity → read-only, no writes | item AC9; `git status` identical across the real run | PASS |

### Coverage notes

- AC1's sweep is a whole-tree invariant: every live `.md` under `.opencode/` and
  `docs/` (excluding `work/` and `node_modules/`) plus `AGENTS.md` and `README.md`
  that mentions `/doctor` must carry the marker. Recon found exactly five such
  files; all five do (`README.md` ×2 occurrences, `AGENTS.md` ×2,
  `docs/workflow.md`, `.opencode/agent/doctor.md`, `.opencode/command/doctor.md`).
- AC2 executes the documented copy sequence rather than grepping the doc, so a
  doc/code divergence in the quickstart fails the suite.
- AC6/AC7/AC11 need the model. Both halves were reproduced for real this pass;
  the static preconditions they depend on (disk counts vs README Layout comments,
  catalogue codes, permission-block equality) are asserted so repository drift is
  caught without a model.

## Review-finding follow-up

| Finding | Fix in the current tree | Independent check |
| ------- | ----------------------- | ----------------- |
| M1 — suite fails once the item is committed | `verify-tests.sh:272-302` gates the change-set assertion on `changed` empty vs expected | committed copy → 66/0 |
| m1 — sweep scans `node_modules` | `verify-tests.sh:97` adds `-not -path '*/node_modules/*'` | `find` returns 39 (was 69) |
| m2 — label inside a compared capability cell | `README.md:189` left untouched; label only in description/list surfaces | `git diff README.md` shows no Agents-row change |
| m3 — "nine checks" vs ten bullets | `.opencode/command/doctor.md:13-18` is a separate guard bullet before the nine-item list | list holds exactly nine `-` items |

## Gaps and residual risk

- **AC1 interpretation — the README Agents row is intentionally unlabeled.**
  The spec enumerates the required surfaces for AC1 as the README **Commands**
  table, the `AGENTS.md` supporting-commands list, and the command/agent
  descriptions — all four carry the marker, plus the `docs/workflow.md` routing
  bullet. The `doctor` row in the README **Agents** table is deliberately left
  byte-identical to `HEAD` because check #6 compares its "Can run bash" cell to
  enforced permissions (review m2). The `doctor` agent is nevertheless labeled
  maintainer-only in `AGENTS.md:54`. If a stricter reading of the goal
  ("everywhere they are documented") is wanted, this is the one surface that does
  not carry the marker; it needs a design decision, not a test change.
- **Model-dependent acceptance.** AC6, AC7, and AC11 are prompt behaviours. Two
  real runs are recorded above; this is stronger than the earlier pass but is
  still observation, not a deterministic harness. A committed prompt test harness
  is `0006-committed-tests-ci`'s scope.
- **Unreadable-surface variant not exercised.** AC6 also covers an unreadable
  (rather than absent) required doc. Producing a permission-denied `README.md`
  without mutating the repository is not deterministic in this environment; the
  rule text and example cover "absent or unreadable". Manual check: `chmod 000
  README.md` in a throwaway copy, run `/doctor`, expect one `[SURFACE-MISSING]`.
- **Completeness-rule semantics are prose.** The lifecycle-classification rule is
  enforced only by static text assertions; no runtime parser exists. This matches
  the spec's "largely static/manual" constraint.
- **Cross-item pre-existing suite (not this item's defect).**
  `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh`
  reports `98/5` on the working tree: four failures are pre-existing on `HEAD`
  (its AC1/AC3 expect 0001's already-committed artifacts to be untracked), and the
  fifth (`AC6 doctor agent/command changed vs HEAD`) is transient — on a
  committed copy the suite is `99/4`, i.e. only the four pre-existing failures.
  This item adds no durable failure there. `0006-committed-tests-ci` should
  repoint that stale guard.
- **`design.md` line citations are stale, not a product defect.** `design.md`
  cites `README.md:159`/`:179`; the rows are now at `:169`/`:189`. The design is a
  planning artifact; AC4 constrains the diagnostic prompt, not the design.
- **Test-fixture location.** The suite creates `scratch/qs-verify` for the AC2
  quickstart simulation and removes it via a trap; `scratch/` is gitignored and
  no tracked file is touched.

## Self-check

- No production file was modified by this pass. `git status --porcelain` still
  lists the same five modified tracked files and the item's `work/` artifacts;
  the only test artifact is `verify-tests.sh`.
- No test was weakened, skipped, or deleted to get a pass. The suite reports
  `66 passed, 0 failed` on both the working tree and a committed copy; the four
  pre-existing `0001-state-model` failures are reported, not hidden.
