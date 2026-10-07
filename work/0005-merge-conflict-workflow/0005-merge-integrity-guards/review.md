---
feature: 0005-merge-conflict-workflow/0005-merge-integrity-guards
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Approved with minors only. The committed suite could not be independently re-executed: this sandbox denies `bash` (see 'Not reviewed'). AC9/AC10 are assessed by static trace of the checks plus the tester's recorded `285 passed, 0 failed`, consistent with prior reviews in this roadmap."
parent: 0005-merge-conflict-workflow
---

# Review — Merge-integrity guard as a portable behavior contract

## Verdict

**approve** — every acceptance criterion is met on the delivered surfaces; the
only findings are non-blocking Minors/Nits, none of which breaks an acceptance
criterion or the `0001`/`0002` contract.

## Base and diff

The work item is uncommitted on `main`. `HEAD` and `origin/main` are both
`ccaff33`, so the review range is the working tree, not a branch range.

Commands run:

- `git merge-base HEAD origin/main` → `ccaff33b426ae324eaacce0a2a40df450d8b7896`
- `git rev-parse HEAD origin/main` → both `ccaff33b426ae324eaacce0a2a40df450d8b7896`
- `git status --porcelain` → 7 modified tracked files + 4 untracked `work/.../0005-merge-integrity-guards/*.md` artifacts
- `git diff` / `git diff --name-status` / `git diff --stat`
- `git diff --name-only -- tests/` → empty

Files changed:

| Path | Change |
| ---- | ------ |
| `docs/workflow.md` | new `### Merge-integrity guard`; `:363`/`:387` re-verification reference generalized |
| `.opencode/skill/merge-conflict/SKILL.md` | contract pointer; 4 re-verification literals generalized; post-merge pass report-only |
| `.opencode/agent/status.md` | guard pointer in `<inputs>`/`<findings>`/`<rules>` |
| `.opencode/command/status.md` | guard pointer on the findings bullet |
| `.opencode/agent/shipper.md` | re-verification literal generalized; report-only guard rule |
| `docs/artifact-conventions.md` | `ship.md` template's illustrative `Re-verification:` command |
| `.opencode/skill/pr-workflow/SKILL.md` | PR description's matching `Re-verification:` line |

`git status --porcelain` shows the only new paths are the item's own `work/`
artifacts; no executable, source, config, or test file is added.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — invariant set enumerated | **met** | `docs/workflow.md:408-416` table carries all seven rows and codes/classes: `DUPLICATE-PREFIX` `(c)`, `DUPLICATE-CHILD` `(c)`, `DANGLING-DEP` `(b)`, `CYCLIC-DEP` `(b)`, `MISSING-CHILD` `(b)`, `UNLISTED-CHILD` `(b)`, `DRIFT-FACT` `(d)`. |
| AC2 — two prompt-only enforcement points, no separate checker | **met** | `docs/workflow.md:397-406` states "prompt behavior only", "no committed checker, script, helper, or executable tool", "no tests/ agreement area", "no separate checker exists", the `/status` offline+read-only point, and the `/ship` post-merge pass "after a merge to the default branch". |
| AC3 — report-only finding contract, no file modified | **met** | `docs/workflow.md:418-425` gives the grammar, code+class+offender, `non-fatal`, `never silently dropped`, `never truncated`, `not auto-repaired`, `modifies no file`; restated on `status.md:137-140,212-214` and `command/status.md:37-39`; the skill's post-merge pass at `SKILL.md:277-280`. |
| AC4 — no checker/script/executable; `tests/` untouched; no maintainer-only tooling in the instruction | **met** | `git diff -- tests/` empty; no new tracked file; the only `bash tests/run.sh` left in an adopter-shared surface is the shipper's permission allowlist (`shipper.md:49`), a grant not an instruction. |
| AC5 — verification names the repository's own configured test command; drift observable offline | **met** | `docs/workflow.md:427-431`, `:363-365`, `:388-389`; `SKILL.md:211-213,254-256,274-275,409-410`; `shipper.md:173-175`; `artifact-conventions.md:419`; `pr-workflow/SKILL.md:54`; no maintainer-only `bash tests/run.sh` instruction remains on any of them; `docs/workflow.md:430-431` states the drift invariant is observable offline through `/status`. |
| AC6 — contract present on adopter-shared surfaces | **met** | Contract in `docs/workflow.md` (`docs/*.md`, copied verbatim); referenced from `.opencode/skill/merge-conflict/SKILL.md:124-127`, `.opencode/agent/status.md:57-60,139-140`, `.opencode/command/status.md:37-39`, `.opencode/agent/shipper.md:234-237`. |
| AC7 — vocabulary agrees with `0002`; no second vocabulary/policy | **met** | Seven codes/classes match `SKILL.md:111-120`; `TEXTUAL-CONFLICT` correctly excluded (pre-flight-only, `SKILL.md:122`); `no second vocabulary`/`no second policy` literals at `docs/workflow.md:420` and `SKILL.md:126`. |
| AC8 — up-to-date/no-collision no-op, no error, no mutation | **met** | `docs/workflow.md:423-425`; the skill's `### Up to date and degraded paths` (`SKILL.md:132-135`) and reconcile no-op (`SKILL.md:393-396`) preserved. |
| AC9 — `bash tests/run.sh` exits 0; no check area added/removed/duplicated | **met (per tester evidence; not independently re-executed)** | `verify.md:17` records `TOTAL: 285 passed, 0 failed, 0 skipped`; `tests/checks/*.sh` is still the 11 listed in `tests/README.md:69-81`; `git diff -- tests/` empty. Sandbox denied re-execution (see "Not reviewed"). |
| AC10 — no new phase/command/agent/skill/artifact/executable; inventories unchanged | **met (static)** | `.opencode/command` = 12, `.opencode/agent` = 14, `.opencode/skill` = 11 (matches `README` Layout and `40-inventory.sh` expected counts); no file added outside `work/`; `docs/workflow.md` phase headings, derived-state table, artifact field set, and every permission frontmatter untouched by the diff. |

Coverage: **10/10 acceptance criteria met.**

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[m1] The always-loaded cost table is now stale** — `docs/customization.md:60,62`
  `docs/customization.md` states "refresh this table whenever a listed file
  changes", and this item changes `docs/workflow.md` (currently 24,843 bytes /
  ≈24.3 KB on disk vs the table's ~21.6 KB; total ≈46.3 KB vs ~42.2 KB). The
  table was already drifted before this item, but this change widens it. The
  design explicitly listed `docs/customization.md` as unchanged, so this is a
  deliberate omission rather than an oversight, and no committed check pins the
  numbers. Recommend refreshing the `docs/workflow.md` row (and the total) in
  this item, or recording in `design.md` why the approximation is left as-is.
  Non-blocking: no acceptance criterion and no `tests/**` check depends on it.

- **[m2] The `Test:` = `none` edge case is not stated by the guard** —
  `docs/workflow.md:427-431`
  The spec's edge cases require that when the Project profile `Test:` value is
  `none`, the verification step "states what that implies rather than assuming a
  command". The delivered text names "the repository's own configured test
  command — the Project profile `Test:` value" but never addresses `none`.
  `verify.md:94,108-115` already records this as a residual risk. The `none`
  convention exists elsewhere (`project-discovery/SKILL.md`,
  `.opencode/agent/bootstrap.md`), so AC5 is still met; recommend a short clause
  ("if the profile's `Test:` value is `none`, there is no command to run") in the
  guard subsection as a follow-up.

- **[m3] The shipper cannot actually run the now-generic command in an adopter repo** —
  `.opencode/agent/shipper.md:49` (with `:173-176`)
  The re-verification instruction now names the repository's configured test
  command, but the shipper's bash allowlist still hardcodes
  `"bash tests/run.sh*": allow` and falls through to `"*": deny`. In an adopted
  repository whose `Test:` value is e.g. `pnpm test`, the shipper agent cannot
  execute the instruction it is told to follow. This is design risk R8
  (`design.md:337-341`, `verify.md:121-125`), deliberately out of scope, and AC5
  requires only the *instruction* to be portable. Recommend a follow-up item to
  generalize the shipper's allowlist (or document the manual fallback) rather
  than widening it here, which would risk `30-permissions.sh`.

### Nits

- **[n1] Subject–verb disagreement** — `docs/workflow.md:424-425`
  "An empty `work/` tree and an already-up-to-date branch ... are no-ops that
  report **no findings** and **does not error**" should read "do not error". The
  design's required literal was `does not error`, so the builder followed the
  design; recommend correcting both.

- **[n2] The restated grammar narrows the skill's grammar** — `docs/workflow.md:419`
  The docs quote the skill's `### Finding grammar` as
  `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`, while the
  canonical form at `SKILL.md:99` is
  `<offender path or canonical reference(s)> — <specific detail>`. This is not a
  second vocabulary (codes/classes agree), but a reader diffing the two surfaces
  sees a mismatch. Recommend copying the skill's exact placeholder text or
  labelling the parenthetical as an abbreviation.

## Not reviewed

- **Independent execution of `bash tests/run.sh`.** The review sandbox denies
  `bash` (allowlist limited to `git diff/log/show/status/merge-base/rev-parse/
  blame`, `ls`, `cat`), so I could not re-run the suite or reproduce the tester's
  `285 passed, 0 failed`. I statically traced the checks that constrain the edited
  surfaces and found no violation:
  - `tests/checks/80-cycle-fixture.sh` pinned literals (`A child in a cycle is
    never \`ready\``, `CYCLIC-DEP`, `informational and never fatal`, `members of a
    cycle are never reported`, `Report them without failing`) are all still
    present (`status.md:121,131,148-149`; `command/status.md:22,28,29`).
  - `tests/checks/10-readiness.sh`'s `Dependencies and readiness` deferral is
    intact in `status.md:86` and `command/status.md:18`; the algorithm marker
    still occurs only in `docs/workflow.md`.
  - `tests/checks/96-signature-sweep.sh` extracts only `### N.` phase headings
    and the `/visual` routing bullet from `docs/workflow.md`; the new
    `### Merge-integrity guard` heading is not a phase heading and is ignored.
  - `tests/checks/20-lifecycle.sh`, `40-inventory.sh`, `50-instructions.sh`,
    `90-packaging.sh`, `95-split-guard.sh` read inventory/copy-set surfaces that
    the diff does not touch (`README.md`, `AGENTS.md`, `template/**`,
    `opencode.json`, `docs/customization.md` are unchanged).
- **Mutation self-check (`tests/mutation.sh`).** Not run (sandbox); the diff adds
  no `tests/checks/` area and does not alter `tests/mutation.sh`.
- **`/visual`.** No UI surface; not applicable.
- **`0001`/`0003`/`0004` policies beyond the changed re-verification literal.**
  Read for consistency only; the diff leaves the taxonomy, lifecycle placement,
  ownership, resolution principles, and renumbering rule untouched, and the
  generalization preserves the requirement and green gate. I concur with the
  design's "additive clarification" classification (R1).
