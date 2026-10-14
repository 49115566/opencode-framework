---
feature: 0015-recursive-workflow-guards/0002-recursive-readiness-status-guard
phase: review
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Review — Recursive readiness and `/status` guard

## Verdict

**approve** — the diff authors the specified fixture-based guard and fixture tree
with no surviving finding of any severity: every acceptance criterion is met, the
guard's expected blocks re-derive correctly by hand from the authority, the
pinned literals exist in their live surfaces, and no production surface is
touched.

## Base ref and diff

No open challenge exists: `work/.../0002-recursive-readiness-status-guard/challenges.md`
is absent, so there was nothing to adjudicate first.

Commands used to establish the range:

```
git merge-base HEAD origin/main            # -> f65715666331a6377a9c234b45e6f86d30ffc12a
git rev-parse HEAD origin/main             # HEAD == f657156..., origin/main == 9185203...
git diff --stat f657156...HEAD             # (empty)
git status --porcelain                     # 1 modified + 3 untracked
git diff f657156...HEAD -- work/.../tasks.md
git diff / git diff --stat / git diff --numstat
```

The item's work is entirely **uncommitted on top of the plan commit**
`f657156` (which itself is `HEAD` and an ancestor of `origin/main`), so the
reviewed change set is `git diff` plus the untracked files:

- `M work/0015-recursive-workflow-guards/0002-recursive-readiness-status-guard/tasks.md` (8 boxes ticked)
- `?? tests/checks/89-recursive-status-guards.sh` (new, 686 lines)
- `?? tests/fixtures/recursive-status/` (new fixture tree, 6 manifests / 70 files)
- `?? work/0015-recursive-workflow-guards/0002-recursive-readiness-status-guard/verify.md`

No base ambiguity. The diff is additive test/artifact-only; no `.opencode/**`,
`docs/**`, `README.md`, `AGENTS.md`, or other production surface appears in
`git status`.

## Findings

### Blockers

None.

### Major

None.

### Minor

None.

### Nits

None.

### Questions

None blocking. Two non-classified observations are recorded under "Residual
risk" below; neither is a defect of this diff.

## Acceptance criteria walk

All 15 criteria met. Evidence is the guard at `tests/checks/89-recursive-status-guards.sh`
and the fixture under `tests/fixtures/recursive-status/items/`; I re-derived every
expected block by hand from `docs/workflow.md` → "Dependencies and readiness",
"Derived state", and "Status reporting", then compared to the guard's literals.

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 (depth ≥ 3, hybrid, `.gitkeep`-only) | met | `9200-tree/0001-hybrid` is a hybrid (`manifest.md` + `spec.md` + `design.md`); `9200-tree/0001-hybrid/0001-empty-leaf` is a 3-segment `.gitkeep`-only node (`89:131-147`, `89:378-382`) |
| AC2 (per-level readiness incl. depth ≥ 3) | met | `rs_ready_blocked` walks each node's own `Children` (`89:289-316`); `recursive-readiness` pins all 20 rows, `nested-readiness` pins the 4 depth-3 rows (`89:322-375`) |
| AC3 (four satisfaction cases) | met | `0008-dependent` expected `blocked: 0004-rejected, 0005-noreview, 0007-recalled` — shipped and approved satisfied, changes-requested and no-review not (`89:341`, `89:386-402`) |
| AC4 (recalled blocks dependent) | met | `0007-recalled/ship.md` carries `reopened: build`; `rs_satisfied` returns 0 (`89:235-246`); `0007-recalled` named in `0008`'s blocked set |
| AC5 (`ship.md` presence precedence) | met | `0006-precedence` is full + `request-changes` + `ship.md`; it is satisfied and omitted from `0008`'s blocked set (`89:395-402`) |
| AC6 (decomposing target own-signal-only; sibling-only) | met | `0010` ready via `0009`'s own `approve`; `0012` blocked despite `0011`'s shipped descendant; `9201-decoy` same-local-id decoy proves sibling-only (`89:404-419`) |
| AC7 (cycle member never ready) | met | deliberate `0003-cyclic-a ↔ 0004-cyclic-b` cycle; `rs_cycle_members` Kahn reduction (`89:250-283`); both blocked, neither `ready` (`89:421-432`) |
| AC8 (deterministic; no stored readiness) | met | `determinism` runs `rs_snapshot` twice and compares (`89:613-633`); `no-stored-readiness` asserts the canonical six-column header on all 6 manifests (`89:635-659`) |
| AC9 (hybrid own phase before container) | met | `9200-tree/0001-hybrid\|design` (own `spec`+`design`, own artifacts win) and pure containers derive `manifest` (`89:458-463`, `89:536-543`) |
| AC10 (nested decomposing first; `.gitkeep` `not started`) | met | `0009-decomposing-approved\|ship` (own full set), `0011-decomposing-unsat\|manifest`, `.../0001-empty-leaf\|not started` (`89:499-545`) |
| AC11 (stale/reopened/challenged precedence, verbatim labels) | met | `design (backtracked)`, `build (reopened)`, `challenged (blocked)`, and stale-outranks-challenge (`89:434-473`, `89:547-567`) |
| AC12 (`/status` render contract pinned) | met | indentation + `its derived phase and` + `blocked: <local ids>` + `<ready>/<total> ready` + `<phase> <n>, ...` pinned across `docs/workflow.md`, `.opencode/agent/status.md`, `.opencode/command/status.md` (`89:661-686`); each literal independently confirmed present in its surface |
| AC13 (literal expected blocks; flatten/mis-derive fails) | met | four reviewed `cat <<'EOF'` blocks compared exactly; mutation probes in `verify.md:40-54` show flatten/mis-derive producing `FAIL` |
| AC14 (missing fixture fails, not skips; read-only) | met | `fixture-existence` uses `bad` and never `skip` (`89:131-147`); `read-only-contract` rejects live `work/`, nested `work/`, and absolute/`../` paths (`89:149-168`); the fixture contains no `work/` or absolute path (grep-verified) |
| AC15 (references neighbours; no re-assertion; no checker) | met | header names `10-readiness`/`20-lifecycle`/`80-cycle-fixture`/`87-backtrack-guards`; `no-duplication` builds 8 forbidden needles from fragments and asserts their absence (`89:170-226`); no production checker is added |

## Correctness review of the guard

- **Expected blocks re-derive correctly.** I hand-computed the readiness map, the
  24-node derived-label block, and the three summary lines (`13/15`;
  `2/4 · not started 3, ship 1`; `1/1 · build (reopened) 1`) from the authority
  and the fixture contents, and they match the guard's literals exactly. The
  `LC_ALL=C` sort orders of the ready rows, the derived block, and the phase
  tally are all consistent with the expected literals.
- **Precedence order matches the authority.** `rs_derive` (`89:441-473`) applies
  earliest `stale:` → `reopened:` → unshipped open-challenge → manifest-with-no-
  own-artifacts → artifact-presence/verdict rows, which is the order in
  `docs/workflow.md` → "Derived state" (structural rows before the challenged
  overlay, manifest row before `spec.md`). Own artifacts correctly take
  precedence over `manifest` for hybrid nodes.
- **Sibling-only resolution is genuinely exercised.** `rs_ready_blocked` resolves
  a bare local id against the declaring node's own directory (`89:303`), and the
  `9201-decoy` same-local-id recalled row plus the negative assertions at
  `89:413-419` would catch a cross-root resolver.
- **Satisfaction semantics are right.** `rs_satisfied` (`89:235-246`) gives
  non-recalled `ship.md` precedence over a verdict and treats a `reopened:` marker
  as unsatisfied; `0011`'s shipped descendant is never consulted for `0012`.
- **No shell-contract violations.** The guard never calls shell `exit` and never
  emits `skip` (only `ok`/`bad`); it is Bash-3.2-safe (no associative arrays, no
  `mapfile`, no empty-array expansion); it reads only `tests/fixtures/**`, the
  three live surfaces, and its own source; it modifies no file.
- **Fixture integrity.** All fixture `tasks.md` files are fully checked (no
  `- [ ]` present), all `feature:`/`parent:` values are the correct canonical
  references, every fixture manifest keeps the six-column `Children` header, and
  the deliberate cycle is recorded under the hybrid manifest's `## Open issues`
  (detection left to `80-cycle-fixture`, per AC7).
- **No collision with neighbouring areas.** `80-cycle-fixture.sh:66`'s
  "only one `roadmap.md` fixture" invariant is preserved (the new root uses
  `manifest.md` only). `89` is an unused, descriptive check filename and adds no
  `run.sh` edit (adding a file is adding a check).

## Scope and conventions

- The change is additive and test-only, matching the item's non-goals: no
  production surface, no committed executable checker, no second harness/token
  scheme, fixture ids in a non-allocating `92xx` band.
- `tests/README.md` and `tests/mutation.sh` are correctly left untouched;
  registration is owned by `0005-guard-registration-sweep` per the spec.

## Residual risk (not findings)

- **`tests/mutation.sh` staged-copy registration is pending `0005`.** The
  mutation runner stages only `tests/fixtures/{cyclic-roadmap,declared-conflicts,backtracking}`
  (`tests/mutation.sh:119-121`), so the full `bash tests/mutation.sh` pass's
  whole-suite setup runs would source `89` against a copy lacking
  `tests/fixtures/recursive-status/` and report `fixture-existence` missing. This
  is **out of scope here** — the spec's non-goals assign the staged-copy entry and
  mutation jobs to `0005`, and `tests/mutation.sh` is explicitly not run in CI —
  but the human should expect the full mutation pass to be transiently red until
  `0005` lands. `bash tests/run.sh` (the CI command) is unaffected.
- **`stale`-vs-challenge wording is inconsistent across shipped surfaces.** The
  guard follows the normative AC11 and `docs/workflow.md` (earliest `stale:`
  outranks an open challenge), consistent with the shipped
  `87-backtrack-guards` expectation `9115-stale-challenge|design (backtracked)`.
  However, `.opencode/agent/status.md:124-126` states the opposite ("the blocked
  `challenged (blocked)` label wins the Phase column"), and the spec's own
  "Edge cases" bullet mirrors that wording. The design
  (`design.md:163-179`) documents this and, correctly, does not edit the pinned
  production surface. This is a pre-existing upstream inconsistency, not a defect
  of this diff; a follow-up should reconcile the status prompt and the spec's
  Edge-case bullet. No guard assertion catches it because AC12 pins only the
  render shape, not the precedence.

## Not reviewed

- I could **not execute** `bash tests/run.sh` or `bash tests/mutation.sh` in this
  environment: the review sandbox's bash allowlist denies arbitrary program
  execution. `verify.md` reports `569 passed, 0 failed, 0 skipped` for the full
  suite and `66 passed` for the area. I mitigated this by reading every changed
  file, reading the guard's pinned surfaces, and hand-deriving the expected blocks
  independently; the guard's evidence chain is otherwise sound.
- The live-`/status`-render residual (a real `/status` run emitting the computed
  shape) remains a documented manual check, as the spec's non-goal requires.
