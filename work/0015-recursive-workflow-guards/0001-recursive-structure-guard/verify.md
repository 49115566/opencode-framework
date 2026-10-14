---
feature: 0015-recursive-workflow-guards/0001-recursive-structure-guard
phase: test
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Verification — Recursive model, reference, and allocation guard

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 540 passed, 0 failed, 0 skipped` — full committed suite green with the new area present |
| `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard bash tests/run.sh` | PASS | `TOTAL: 37 passed, 0 failed, 0 skipped`; 37 assertions all labelled `AC27` |
| `bash tests/mutation.sh` | PASS | clean whole-suite runs `540/0/0` and `538/0/2 skipped`; `MUTATION TOTAL: 30 checked passed, 0 failed`; `whole-suite runs: 2` |
| `bash tests/mutation.sh --selftest` | PASS | `SELFTEST: 6 passed, 0 failed` |
| `bash tests/run.sh` twice, `diff` of `AC27` output | PASS | identical (idempotent); two concurrent area runs produced identical findings |
| full `stage_copy` surfaces with **no `work/`**, `bash tests/run.sh <copy>` | PASS | `TOTAL: 540 passed, 0 failed, 0 skipped` — fresh-clone-without-`work/**` proxy |
| `bash tests/run.sh <copy>` with `FRAMEWORK_TEST_NO_PY/_OPENCODE/_NPM=1` | PASS | area `37/0/0` — guard needs only bash/git and never skips |
| `git diff --name-only -- ':!work/'` + `git status --untracked-files=all` | PASS | only `tests/mutation.sh` (modified) and `tests/checks/81-*`/`tests/fixtures/recursive-structure/**` (new) |
| scratch mutation harness (ephemeral, 28 targeted mutations) | PASS | every targeted regression was caught and named; see below |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 fixture depth | `tests/checks/81-recursive-structure-guard.sh` → `AC27 fixture-depth` (root present, `rs_max_depth ≥ 4`); independent mutation: remove root → `FAIL ... fixture root missing`; reduce to 3 levels → `FAIL ... deepest branch is 3 item levels` | PASS |
| AC2 hybrid node | `AC27 hybrid-node` (finds `9001-tree`, a manifest plus own `spec.md`); mutation: strip `9001-tree/spec.md`+`tasks.md` → `FAIL ... no node both decomposes` | PASS |
| AC3 per-level reservation marker | `AC27 reservation-marker` (every child of every manifest node carries `.gitkeep`; a marker-only leaf exists); mutations: remove one `.gitkeep` → FAIL; give every marker-only leaf an artifact → `FAIL ... no marker-only leaf` | PASS |
| AC4 allocation scoping | `AC27 allocation-scoping` (`5 distinct parents each begin ... at 0001`; grandchild under its immediate parent; `parent: 9001-tree/0001-branch` frontmatter); mutations: wrong grandchild `parent:` → FAIL; rename every child so no parent starts `0001` → `FAIL ... fewer than two parents begin` | PASS |
| AC5 reference nests to depth | `AC27 reference-depth` (depth-four reference resolves; `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$` pinned in `docs/artifact-conventions.md`); mutations: remove `0001-deep` → FAIL; tamper the pinned regex → FAIL | PASS |
| AC6 top-level duplicate derived | `AC27 duplicate-derivation` (expected-block equality; exactly one `DUPLICATE-PREFIX|9010-dup-a|9010-dup-b`); mutations: add a third `9010-*` top-level item → block mismatch FAIL; add a real sibling `0001-zzz` under `9001-tree` → block mismatch FAIL | PASS |
| AC7 same-parent depth ≥ 3 duplicate derived | `AC27 duplicate-derivation` (exactly one `DUPLICATE-CHILD|…/0009-dup-x|…/0009-dup-y|…/0001-leaf|0009`); mutation: break the depth-4 pair → block mismatch FAIL | PASS |
| AC8 never mislabeled | `AC27 duplicate-position` — six negative assertions: `9010-dup` absent from the `DUPLICATE-CHILD` set, `0009-dup` absent from the `DUPLICATE-PREFIX` set, and the four equal-text/different-parent pairs absent from `DUPLICATE-CHILD`; the two finding kinds are emitted by separate loops | PASS |
| AC9 model uniform at every node | `AC27 contract-pins` — `need` on `docs/workflow.md` for `applies uniformly at every node`, `no maximum recursion depth`, `nesting continues to arbitrary depth`; mutation drops each phrase → named FAIL | PASS |
| AC10 task entries are not nodes | `AC27 contract-pins` — `need` `are **not** nodes` + fixture scan (no `T*` directory, no listed task names a directory); mutation: create `items/T1/` → FAIL | PASS |
| AC11 reservation/allocation prose pinned | `AC27 contract-pins` — `flat`-matched `each child directory is reserved with a \`.gitkeep\` at that level` and `scoped to its **immediate** parent`; `need` `greatest 4-digit prefix ever committed under that parent and add one`, `never reused within that parent`; mutation drops each (incl. the wrapped first two) → named FAIL | PASS |
| AC12 no committed executable checker | `AC27 contract-pins` — `prompt behavior only` + `no committed checker, script, helper, or executable tool` in both the `### Merge-integrity guard` and `## Declared-conflict check` sections (`flat`-matched); `AC27 read-only-contract` — the guard lives under `tests/checks/` and no production surface names it; mutations drop each phrase, and a doc reference to the guard stem → named FAIL | PASS |
| AC13 read-only and self-contained | `AC27 read-only-contract` — fixture references no live `work/` path and no `..`/absolute token; mutations injecting `work/foo` and `../bar` → FAIL; idempotence: two runs and two concurrent runs produced identical `AC27` output and modified no file | PASS |
| AC14 suite stays green | `bash tests/run.sh` → `540/0/0`; staged copy with no `work/**` → `540/0/0`; area → `37/0/0`, every assertion labelled `AC27` | PASS |
| AC15 mutation clean runs stay green | `bash tests/mutation.sh`: `clean copy (no work/)` and `clean copy with optional tools absent` both passed with the new fixture root staged by T6's `stage_copy()` line; 30/30 mutations caught | PASS |
| AC16 no production surface touched | `git status`/`git diff --name-only -- ':!work/'` name only `tests/mutation.sh`; untracked files are only under `tests/checks/` and `tests/fixtures/recursive-structure/`; no `docs/**`, `.opencode/**`, `README.md`, `AGENTS.md`, or `template/**` is modified | PASS |

## Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Missing fixture | Mutation removes the fixture root → hard `FAIL` naming the root (never a skip) | PASS |
| Shallow fixture | Mutation reduces the tree to 3 levels → `FAIL ... deepest branch is 3 item levels` | PASS |
| Equal text, different parents | Fixture contains `0001-branch`/`0001-leaf` text under both `9001-tree` and `9002-tree`; `duplicate-position` asserts neither is a same-parent collision; identity is the full canonical path | PASS |
| Shared prefix at depth ≥ 3 | `DUPLICATE-CHILD` line carries the shared parent (`…/0001-leaf`) and shared local prefix (`0009`) | PASS |
| Marker-only node | `9001-tree/0002-leaf` etc. are marker-only and produce no false duplicate | PASS |
| Empty or whitespace-only token | **Not exercised by this guard.** This area parses no conflict/token grammar (it derives structure from directory names); token well-formedness is owned by `0003-recursive-conflicts-guard`. The pinned anchored reference regex does reject empty segments, but the guard adds no negative assertion for it. | N/A (out of area) |
| Staged-copy execution | `tests/mutation.sh` stages only the fixture surfaces (no `work/`) and the guard resolves sibling files relative to its own location; clean runs pass | PASS |
| Idempotence and concurrency | Two serial runs and two concurrent runs yield identical findings; runs modify no file (git status unchanged) | PASS |
| Optional-tool absence | Area run with `FRAMEWORK_TEST_NO_PY/_OPENCODE/_NPM=1` → `37/0/0` | PASS |

## Independent mutation evidence

The guard's sensitivity was independently re-checked (not by the builder's own
assertions) with an ephemeral scratch harness that stages the project surfaces
into `scratch/` and mutates only the staged copy — the same mechanism
`tests/mutation.sh` uses — then runs `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard`.
Twenty-eight correctly-targeted mutations, each with the exact `AC27` label it
must trip, were all caught and named:

- fixture-depth: missing root; shallow-to-3
- hybrid-node: strip the hybrid node's own artifacts
- reservation-marker: drop a `.gitkeep`; make every marker-only leaf carry an artifact
- allocation-scoping: corrupt the grandchild `parent:`; remove every `0001-` child start
- reference-depth: delete the depth-4 directory; tamper the pinned grammar literal
- duplicate-derivation: add a third top-level `9010-*`; rename a depth-4 dup; add a real sibling dup
- contract-pins: drop each of `applies uniformly at every node`, `no maximum recursion depth`,
  `nesting continues to arbitrary depth`, `are **not** nodes`, the wrapped reservation phrase,
  `scoped to its **immediate** parent`, `greatest 4-digit prefix ever committed under that parent
  and add one`, `never reused within that parent`, and `prompt behavior only` /
  `no committed checker, script, helper, or executable tool` in each of the merge-integrity and
  declared-conflict sections; create a task-like `T1/` directory
- read-only-contract: inject a `work/` token; inject a `../` token; name the guard from a production doc

Three initially mis-targeted probes (a single-line `sed` that missed the
wrapped prose, a removal that left depth 4 via the `0009` pair, and a
top-level-phrase edit that missed the child-level pinned sentence) were
corrected; none indicated a guard gap. No mutation escaped.

## Gaps and residual risk

- **Suite token `AC27` is provisional.** The design records it for `0005-guard-registration-sweep`
  to reconcile against siblings `0002`–`0004` and register in `tests/README.md`. The guard's
  labels are internally consistent (`AC27` on all 37 assertions).
- **Committed mutation jobs for this guard do not exist yet** (owned by `0005`). AC15's
  requirement is only that the *clean* whole-suite runs stay green, which they do; sensitivity was
  established here by the independent scratch harness rather than committed mutation jobs.
- **The guard derives structure from directory names and `parent:` frontmatter**, not from the
  fixture manifests' `Children` tables. Malformed table content in the fixture (e.g. swapped
  header columns) is not caught by *this* guard; the recursive integrity/table checks are owned by
  `0004-recursive-integrity-guard`/`0005`. No acceptance criterion here requires table parsing.
- **`AC8` "never mislabeled" is primarily structural** (two independent emission paths); the
  expected-block equality is the load-bearing assertion, with the six negative members as clamps.
- **The read-only-contract scan covers the fixture text**, not the guard script itself. The script
  contains no absolute/escaping path in practice (verified by inspection); this is a documentation
  nuance, not an unmet criterion.

No implementation, spec, or design defect was found; no `backtracks.md` finding is recorded.

## Verdict

Every acceptance criterion and applicable edge case is covered by a passing,
mutation-sensitive assertion. The committed suite and the mutation self-check's
clean runs are green. No test was weakened, skipped, or deleted.
