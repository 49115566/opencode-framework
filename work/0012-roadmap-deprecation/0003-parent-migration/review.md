---
feature: 0012-roadmap-deprecation/0003-parent-migration
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Review — Existing-parent migration: grandfather the seven live decomposing nodes and migrate the test fixtures

## Verdict

**approve** — every acceptance criterion is met, the change set is confined to
the fixtures, the three guards, the mutation tooling, test prose, and this item's
own artifacts, and no defect of any severity survived scrutiny; the suite
result is accepted on the tester's reported evidence (this read-only session
cannot execute `bash`).

## Base ref and diff

- `git merge-base HEAD origin/main` → `1bd367973f8a0e998bca56dbcc6b93d5562e579b`
- `git rev-parse HEAD origin/main main` → all three are `1bd3679…`
- The item's plan was merged at `7f0e34e` / PR #65 (`1bd3679`), and the builder
  does not commit, so the entire change set is uncommitted against `HEAD`.
- Commands: `git diff HEAD --stat`, `git diff HEAD --name-status`,
  `git diff HEAD -- <path>` per file, `git status --porcelain --untracked-files=all`.

Reviewed range: `git diff HEAD` (staged renames + working-tree edits) plus the
untracked `verify.md`. 12 tracked files changed (`+176 / -87`): 5 fixture
renames, `cyclic-roadmap/roadmap.md`, `80`/`85`/`87`, `tests/README.md`,
`tests/mutation.sh`, and this item's `tasks.md`; `verify.md` is new.

## Findings

None. No Blocker, Major, Minor, or Nit survived scrutiny. What I specifically
probed (and why it holds):

- **Resolver correctness.** Each guard's local resolver
  (`cycle_manifest` `80-cycle-fixture.sh:28-34`, `guard_manifest`
  `85-conflict-guards.sh:50-56`, `bt_manifest` `87-backtrack-guards.sh:58-64`)
  returns the modern spelling first, the recognized alias second, and non-zero
  otherwise; every caller handles the non-zero case (`85:291,304`,
  `87:96,215`-area, `87:740`, `80:39`). No call site still uses the retired
  `bt_roadmap_*` helpers, and no file under `tests/` still names a *migrated*
  fixture's old `roadmap.md` path.
- **Alias coverage is genuinely observable (AC4).** `80-cycle-fixture.sh:47-54`
  asserts the cycle fixture resolves to `*/roadmap.md` and carries `phase:
  roadmap` / `# Roadmap —`; `tests/mutation.sh:383-389` (`job_8`) keeps the
  removal of that retained file mutation-sensitive.
- **No accidental content drift.** The five migrated manifests differ only by
  `phase: manifest`, the `# Manifest —` H1, and Initiative nouns; the
  six-column `Children` header, `Canonical reference` cells, directory names,
  `## Sequencing`, and the withdrawal/revision records are byte-preserved
  (`9003-roadmap-old/manifest.md` keeps its five-column header; the `9120`
  `## Open issues` note is untouched).
- **No dangling literal.** `grep` over `tests/` finds `roadmap.md` only in the
  retained `cyclic-roadmap` fixture, `job_8`, and `80`'s retained-alias
  assertions — never a migrated old path. The renamed fault token
  `missing-manifest|` (`87:629`) has no consumer elsewhere, so nothing is left
  half-renamed.
- **Scope and secrets.** `git status --porcelain -uall` lists only in-scope
  paths; no change under the seven grandfathered parents, `docs/`, `.opencode/`,
  `template/`, `README.md`, or `AGENTS.md`; no secrets, credentials, debug
  logging, or network access introduced.

## Acceptance criteria

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 — Grandfather read-only | **met** | `git status --porcelain` shows no path under `0003`–`0007`, `0010`, `0011`; `glob work/*/roadmap.md` confirms all seven (plus the in-flight `0012`) still hold `roadmap.md`. No `manifest.md` was added under a live parent. |
| AC2 — Decision recorded | **met** | `spec.md:7` (frontmatter `notes`), `spec.md:36-41` (Goals), `spec.md:183-188` (resolved Open questions), and `design.md:32-42` §1 record the grandfather + no-forced-migration decision in committed state. |
| AC3 — Fixtures use the modern spelling | **met** | Five `git mv` renames to `manifest.md` with `phase: manifest` and `# Manifest —` (`9001`/`9002`/`9003`/`9120`/`9121`); `glob tests/fixtures/**/{roadmap,manifest}.md` shows the five modern plus only the retained `cyclic-roadmap/roadmap.md`. Negative pinned at `80-cycle-fixture.sh:61-71`; positive `need` pins at `85:400-412` and `87:224-234`. |
| AC4 — Deprecated-alias coverage retained | **met** | `80-cycle-fixture.sh:47-54` asserts the retained alias resolves and declares `phase: roadmap` / `# Roadmap —`; `tests/mutation.sh:383-389` keeps it mutation-covered. |
| AC5 — Guards reconciled to the fixtures | **met** | `85` parent detection/standalone skip use the resolver (`85:291,304`); `87` discovery/skip and path lookups use it (`87:96,215,227,630,740,779,801,852`); `grep -n roadmap.md` in `85`/`87` is empty; expected blocks are unchanged (they key on directory-based entity refs). |
| AC6 — Mutation tooling reconciled | **met** | `job_15`/`job_16` → `9001-roadmap-a/manifest.md` target+restore (`mutation.sh:461,463,472,475`); `job_24` → `9120-revised-roadmap/manifest.md` (`mutation.sh:561,564`); `job_8` retained (`mutation.sh:388-389`). |
| AC7 — Test prose terminology reconciled | **met** | `tests/README.md` has exactly one `roadmap` occurrence, the stable `AC24 roadmap-revision` label (`:189`); the guards' remaining occurrences are the stable label/area name, preserved fixture directory names, and the resolver's `for base in manifest roadmap`. |
| AC8 — Read-only and no live-work dependency | **met** | Fixture references are unchanged and fixture-local; the new whole-tree scan reads only `tests/fixtures` (`80:66`); no nested `work/` dir exists under the fixture tree. |
| AC9 — Suite stays green | **met (on reported evidence)** | `verify.md:40` reports `bash tests/run.sh` → `TOTAL: 502 passed, 0 failed, 0 skipped`, mutation `29 checked passed, 0 failed`, selftest `6 passed`. This read-only session cannot execute `bash` (allowlisted to `git`/`ls`/`cat`), so I did not re-run it; I instead read every changed guard and its consumers and found no literal or path that the rename left inconsistent. |
| AC10 — Scope | **met** | `git diff HEAD --name-status` and `git status -uall` name only the five renamed fixtures, `cyclic-roadmap/roadmap.md`, `80`/`85`/`87`, `tests/README.md`, `tests/mutation.sh`, `tasks.md`, and `verify.md`. The seven parents, `docs/`, `.opencode/`, and the root inventories are untouched; no sequence number is allocated or reused. |
| AC11 — Extend, do not fork | **met** | Diff adds no agreement area, guard, finding code, state model, reference grammar, or conflict class. The new `modern-spelling` assertions are sub-areas inside the existing `85`/`87` areas; the six-column `Children` header and `conflicts-with` grammar are unchanged. |

Edge cases: the absent-column legacy header is preserved and asserted
(`9003-roadmap-old/manifest.md:25-27`, `85:393-396`); fixture-local
`Canonical reference` cells are untouched; `.gitkeep`-only/shipped/recalled
fixture children are unaffected; the empty-fixture failure mode is covered by the
fixture-existence and modern-spelling assertions plus `80:67`.

## Not reviewed

- **Independent suite execution.** `bash tests/run.sh` and
  `bash tests/mutation.sh` could not be run in this session (bash is restricted
  to `git`/`ls`/`cat`); AC9/AC6 rest on the tester's `verify.md` evidence,
  corroborated by static reading of every changed line and its consumers.
- **Out-of-scope surfaces owned by siblings.** The docs contract (`0001`) and the
  `/roadmap` command / `roadmap` agent retirement plus root inventories (`0002`)
  were checked only to confirm they were *not* touched.
