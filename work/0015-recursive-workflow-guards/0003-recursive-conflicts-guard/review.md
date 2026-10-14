---
feature: 0015-recursive-workflow-guards/0003-recursive-conflicts-guard
phase: review
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Review — Recursive declared-conflicts guard

## Verdict

**approve** — every acceptance criterion is met by a committed, mutation-sensitive
assertion; the diff widens the shipped resolver and event builder exactly as the
design specifies, adds only the additive fixture root, and leaves the depth-2
control untouched. No finding of any severity survives.

## Diff reviewed

The item's plan (`spec.md`, `design.md`, `tasks.md`) is already committed on
origin/main at the plan commit, so the build diff is the uncommitted working tree
on top of `HEAD`:

- `git merge-base HEAD origin/main` → `8d1a35ebd57b968df6f66c8a5219f1bcc53ff053`
- `git rev-parse HEAD origin/main` → `8d1a35e` (branch tip) / `5bf6dfe` (main)
- `git diff HEAD --stat` → `tests/checks/85-conflict-guards.sh` (+368/-20),
  `work/…0003…/tasks.md` (9 boxes ticked)
- `git status --short -- tests/ work/` → untracked `tests/fixtures/recursive-conflicts/`
  and `work/…0003…/verify.md`

`HEAD` (`8d1a35e`) is the item's own plan commit and an ancestor of origin/main;
reviewing against origin/main directly would show spurious deletions of the
sibling `0001` artifacts that main carries and this branch does not, so the
correct base is `HEAD`. The new fixture root is untracked and must be `git add`ed
by `/ship`.

## Acceptance criteria

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 recursive reference grammar + ref-vs-path | **met** | `guard_resolve` regex widened to `(/…)*` at `tests/checks/85-conflict-guards.sh:182`; `AC23 recursive-reference` asserts the 3-segment `9201-root-a/0001-nested/0001-leaf` resolves as `item` and `tests/fixtures` as `surface` (`:745-769`). |
| AC2 sibling-first below root, then root fallback | **met** | `AC23 recursive-sibling-precedence` asserts `0002-grand` → the sibling `9201-root-a/0001-nested/0002-grand` (not the top-level decoy) and `0009-solo`/`9203-shared` → root fallback (`:771-796`). |
| AC3 recursion into a decomposing child | **met** | `guard_walk_node` recurses when a child dir holds a manifest (`:298-311`); `AC23 recursive-traversal` pins the full entity set including `9201-root-a/0001-nested` and its own depth-3 rows (`:709-743`). |
| AC4 own ∪ parent-cell union | **met** | `AC23 recursive-union` pins both `docs/workflow.md` (own) and `docs/customization.md` (cell) for `0002-grand`, plus the one-sided `0003-shipped` cell (`:798-823`). |
| AC5 drift discrepancy; one-sided and equal not drift | **met** | `AC23 recursive-drift` pins the drift set and adds the both-present-equal synthetic no-drift case (`:825-866`). |
| AC6 pair predicate across levels | **met** | `AC23 recursive-pair` pins the six-pair block, the `(a)` cross-level surface pair, the `(b)` cross-level item pair, one-sided naming, and the equal-text/different-target absence (`:868-898`). |
| AC7 shipped resolves but is excluded | **met** | `AC23 recursive-shipped` asserts the `…/0003-shipped` target still resolves, is absent from the conflict block, and carries the shipped flag (`:900-908`). |
| AC8 malformed/unresolved reporting | **met** | `AC23 recursive-unresolved` pins the seven-token block and asserts each token is reported, none dropped (`:910-934`). |
| AC9 legacy 5-column header at depth | **met** | `AC23 recursive-column-layout` pins the 5-column header on `9201-root-a/0003-legacy`, the depth-2 positional parse, and `0001-old` declaring nothing while remaining an entity (`:677-707`). |
| AC10 depth-2 control unchanged | **met** | The only removed lines are the header comment, the `?`-capped regex, and the replaced non-recursive loop (`git diff HEAD`); every `EXP_*` block and `AC23` assertion is byte-identical, and `declared-conflicts` has no nested manifest to change the stream. |
| AC11 fresh clone, read-only, no live `work/` | **met** | `$RC_ROOT` grep is clean (I confirmed no `work/` literal under `tests/fixtures/recursive-conflicts/`), the guard is fixture-scoped, and `verify.md` records a no-`work/**` suite pass. |
| AC12 one targeted change trips the matching label | **met** | Every rule has a distinct `AC23 recursive-*` label; each block is a full-equality or contains/absent assertion tied to one rule; the tester's scratch mutation table shows each label independently trippable. Permanent jobs are `0005`'s deliverable, as the spec mandates. |

## Findings

### Blockers

None.

### Major

None.

### Minor

None.

### Nits

None.

## Adversarial checks performed

- **Resolver widening is behavior-preserving at depth ≤2.** No `conflicts-with`
  value in `tests/fixtures/declared-conflicts/` contains a 3-segment reference
  (all are 1- or 2-segment), so the `?`→`*` change cannot reclassify any existing
  token; the depth-2 `ACT_*` blocks are unchanged.
- **Every expected block is self-consistent with the implementation.** I traced
  the walk/resolve/union/drift/pair pipeline over the whole fixture by hand:
  the 16-entity set, the three resolution sub-blocks, the single drift line, the
  seven unresolved lines, and the six conflict pairs all match the committed
  constants, including LC_ALL=C sort order.
- **The recursion is genuinely pinned, not vacuously.** Removing the recursion
  loses all depth-3 entities → `recursive-traversal` full-block equality fails;
  reverting the regex sends the 3-segment target to the surface check (path
  absent) → `recursive-reference` fails.
- **Shipped exclusion is meaningful.** `0003-shipped` declares `docs/workflow.md`,
  which `0002-grand` and `9210-surface-shared` also declare, so including it as a
  counterpart would add two `(a)` pairs — the assertion would catch that.
- **Fixtures are pure data.** No symlinks, no CRLF, no `roadmap.md` that would
  trip `80-cycle-fixture.sh:66` (`find tests/fixtures -name roadmap.md`), and the
  entity ids allocate no real `work/` number.
- **Scope.** Only `tests/checks/85-conflict-guards.sh`, the new fixture root, and
  the item's own `tasks.md` changed; no production/authority surface
  (`docs/**`, `.opencode/**`, `README.md`, `AGENTS.md`, `tests/README.md`,
  `tests/mutation.sh`) was touched, matching the spec's non-goals.
- **Bash 3.2 / portability.** New code uses only `local`, here-strings already
  present in the file, `awk`/`grep`/`sort` — no new runtime dependency.

## Not reviewed

- **The suite was not executed in this environment.** My bash allowlist denies
  arbitrary program execution (`bash tests/run.sh` is blocked here), so I could
  not independently reproduce `verify.md`'s `551 passed` / `97 passed` figures. I
  validated the guard statically against the fixture and could not find a
  divergence; if the reviewer-of-record can run `bash tests/run.sh`, that is the
  one remaining independent check.
- **`bash tests/mutation.sh` is expected to fail until `0005` lands.** The
  mutation harness stages only the three pre-existing fixture roots
  (`tests/mutation.sh:119-121`), so its whole-suite step does not see
  `tests/fixtures/recursive-conflicts/` and the new `recursive-fixture-existence`
  assertions `bad` on the copy. This is not a defect of this item: the spec's
  non-goals explicitly assign the `tests/mutation.sh` staged-copy entry and
  mutation jobs to `0005-guard-registration-sweep`, the parent manifest does the
  same (`manifest.md:99-102,127`), and `design.md` records the transient window.
  `bash tests/run.sh` — the canonical, CI-run command — is unaffected. Flagged so
  the human confirms `0005` is merged in the same roadmap; it is not a finding
  against this diff.
- The live `/conflicts`, `/status`, and `/build`-gate model runs remain a
  documented manual residual, unchanged from the shipped depth-2 area.
