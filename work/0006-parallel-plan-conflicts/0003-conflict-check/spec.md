---
feature: 0006-parallel-plan-conflicts/0003-conflict-check
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "User decisions 2026-10-08: (1) invocation is a new read-only `/conflicts [item-ref]` command, also surfaced in `/status` and at the `/build` pre-development gate; (2) the result is advisory and never blocks a phase; (3) the compared set is the unshipped plans (no `ship.md`) across the whole `work/` tree, globally scanned and target-focused on an item-ref; (4) a declared conflict exists when two declared sets share a target or one side names the other item. Dependencies 0001 and 0002 are both satisfied (`ship.md` present), so no readiness override was needed."
parent: 0006-parallel-plan-conflicts
---

# Pre-development parallel-plan conflict check

## Problem

Framework maintainers running parallel roadmap children or parallel work items —
and adopters who inherit the same setup — can commit plans whose declared conflict
targets overlap, yet nothing compares those declarations before development
begins. `0001-conflict-declaration-model` defined the `conflicts-with` vocabulary
and `0002-plan-record` made an item's declared targets committed, published plan
state, but no read-only capability reads the committed declarations and reports an
overlap. A maintainer therefore learns that two in-flight plans are rivals only
when their branches collide and must be reconciled by hand at merge time
(`docs/workflow.md` → `## Merge conflicts`). The cost is avoidable late rework and
hand reconciliation that a planning-time report could have surfaced earlier.

## Goals

- Provide one read-only invocation that reports declared conflicts among the
  committed plans of unshipped work items, and a target-focused mode for a named
  item.
- Compare across the whole `work/` tree — a plan against every other unshipped
  plan, roadmap children against siblings and cross-roadmap in-flight items —
  using each item's declared target set.
- Reuse the shipped conflict classes and finding grammar unchanged; introduce no
  second taxonomy or vocabulary.
- Surface the same findings in `/status` and at the pre-development gate.
- Remain advisory, offline, local, and read-only: never block a phase, mutate a
  branch or file, or auto-repair a declaration.
- Report unresolved declarations and a parent/item declaration discrepancy rather
  than dropping either or silently preferring one.

## Non-goals

- Reconciling, resolving, or scheduling around a conflict; mutating any branch,
  ref, or file; applying a merge or a dry-run merge.
- Duplicating or replacing the shipped pre-ship branch/textual detection of
  `0005-merge-conflict-workflow`, which operates on branches, not plans.
- Gating `/build`, readiness, or child sequencing from a declaration; the result
  is informational only, and declarations stay readiness-neutral.
- Changing the `0001` declaration grammar, target kinds, or resolution
  precedence, or `0002`'s declaration home, union rule, or plan-publication flow.
- A new conflict class, finding code, taxonomy, or policy; a persisted report
  artifact; or a new artifact `phase` value.
- Glob, prefix, or directory-containment surface matching; only exact declared
  targets conflict.
- Committed fixtures, agreement areas, and mutation coverage — owned by
  `0004-conflict-guards`.
- Structural de-duplication of shared framework surfaces, auto-scheduling, or
  auto-reordering children.
- Any runtime dependency, service, network access, or hosted integration.

## Users and stories

- **As a** maintainer about to start development on a plan, **I want** to see
  whether my declared targets collide with any unshipped plan before I build, **so
  that** I can coordinate while it is still cheap.
- **As a** maintainer running parallel roadmap children, **I want** the check to
  compare each child against its siblings and other in-flight items, **so that** an
  untracked overlap surfaces during planning rather than at merge time.
- **As a** maintainer, **I want** the findings in the class labels and finding
  format my merge-time tooling already uses, **so that** I maintain no second
  vocabulary.
- **As an** adopter, **I want** the check to run offline and read-only on a fresh
  clone, **so that** it needs no network, service, or per-item setup.
- **As a** maintainer, **I want** the findings available from `/status` and when
  `/build` starts, **so that** I do not have to remember a separate step.

## Acceptance criteria

1. **AC1** — Given committed plans under `work/`, when the check is invoked with
   no item argument, then it produces a read-only report of every declared conflict
   among unshipped plans and writes no file.
2. **AC2** — Given a canonical item reference, when the check is invoked with it,
   then the report focuses on the declared conflicts that involve that item and
   names each counterpart.
3. **AC3** — Given an item whose `ship.md` is present, when plans are compared,
   then that plan is excluded from the compared set; given an item with no
   `ship.md`, it is included.
4. **AC4** — Given two unshipped plans, when their declared target sets are
   compared, then the pair is reported as a declared conflict exactly when the sets
   share a target (equal after trimming) or one side names the other item's
   canonical reference; a one-sided declaration suffices and no reciprocal
   declaration is required.
5. **AC5** — Given a roadmap child, when its declared set is computed, then it is
   the union of its own declaration and its parent `Children` row's
   `conflicts-with` cell; given a row whose child has no own declaration, the cell
   alone is used.
6. **AC6** — Given a reported declared conflict, when the finding is rendered,
   then it uses the shipped finding-line grammar and a class label drawn from the
   shipped `(a)`–`(d)` set, and the check defines no new class or policy.
7. **AC7** — Given a malformed cell or a target that resolves to no sibling row,
   no `work/<ref>/` directory, and no existing repository path, when the check
   runs, then it reports the target as an unresolved declaration and neither drops
   nor auto-repairs it.
8. **AC8** — Given a roadmap child whose own declaration and whose parent
   `Children` cell are both present (neither `—`) and whose target sets differ,
   when the check runs, then it reports the discrepancy and does not silently
   prefer either.
9. **AC9** — Given a detected declared conflict, when the check reports it, then
   no phase is blocked: `/build` still proceeds, no readiness edge or child order
   changes, and the result is informational only.
10. **AC10** — Given `/status` runs while unshipped plans declare conflicts, when
    it produces its report, then the same declared-conflict findings appear there
    and no file is modified.
11. **AC11** — Given `/build` starts for an item, when the pre-development plan
    gate runs, then the declared-conflict findings involving that item are surfaced
    before development proceeds and, being advisory, do not stop the build.
12. **AC12** — Given the check runs, when it inspects plans, then it reads only
    committed `work/` state and the local repository (for target resolution),
    performs no fetch, remote read, merge, or dry-run merge, takes no lock, and
    modifies no file.
13. **AC13** — Given the check reports declared conflicts, when the report is
    produced, then it operates on committed plans and does not perform or
    reproduce the shipped pre-ship branch/textual detection.
14. **AC14** — Given an item with no declaration (absent field, absent column, or
    `—`), when the check runs, then it produces no declared-conflict finding for
    that item, and historical items remain valid with no migration.
15. **AC15** — Given the check is a new user-facing command, when the command
    inventory is inspected, then the command and its usage signature appear
    wherever commands are inventoried, and the committed suite's inventory and
    command-signature agreements stay green.
16. **AC16** — Given the shipped authority, the command surface, and the routing
    guidance, when the check is added, then each describes the check's surface, its
    advisory nature, and its reuse of the shipped vocabulary consistently, with one
    authoritative statement referenced elsewhere rather than restated.

## Edge cases

- **No unshipped plans or no declarations** — the report is empty and the check
  does not error.
- **All plans shipped** — the compared set is empty; no findings.
- **Declaration naming a shipped item** — the target resolves, but the shipped
  item is not a counterpart; no conflict and no unresolved finding.
- **Bare reference ambiguity** — a `MMMM-slug` that is both a sibling local id and
  a top-level item is resolved by the shipped sibling-first precedence; the check
  does not reinterpret it.
- **Existing directory target** — a repository-relative directory path that
  exists is a resolved surface target.
- **Malformed surface target** — a glob metacharacter, `..`, or an absolute path
  is malformed and reported as unresolved.
- **Duplicate target** — the same target repeated in one list (after trimming) is
  malformed.
- **Empty/whitespace-only cell** — malformed, not equivalent to `—`.
- **Absent column** — a roadmap authored before the column existed has no
  `conflicts-with` column; absence is treated as `—` for every row, not as
  malformed.
- **Unspecced roadmap child with a parent declaration** — a child holding only
  `.gitkeep` is still represented by its parent `Children` cell and compared.
- **Both sides name each other** — the pair yields exactly one declared conflict,
  not two.
- **Both share a surface and name each other** — one conflict for the pair,
  reported once.
- **Many conflicts for one item** — every conflict is reported; the finding list
  is never truncated.
- **Concurrent invocations** — two checks run without interference; the check
  takes no lock and writes nothing.
- **Repeated runs** — running twice on unchanged plans yields identical findings.
- **Cross-roadmap overlap** — a target naming an item in another roadmap's tree
  is resolved and compared like any other in-flight item.

## Open questions

- [ ] **Finding-code selection for a declared conflict.** The shipped authority
  (`docs/workflow.md` → "Declared conflicts (`conflicts-with`)") forbids a new
  finding code, yet no shipped pre-flight/integrity code names a declared,
  not-yet-real conflict. Defer the exact code choice to `/plan`, constrained to the
  shipped vocabulary; if no shipped code fits, raise it rather than silently
  inventing one. — owner: architect, needed by: design.
- [ ] **Assumption — gate surfacing mechanics.** AC11 assumes the check is
  surfaced at the `/build` pre-development gate documented by `0002-plan-record`.
  If that integration cannot be expressed read-only and advisory, record it and
  keep `/conflicts` and `/status` as the surfaces. — owner: architect, needed by:
  design.
- [ ] **Assumption — discrepancy semantics.** AC8 reads the shipped
  union-plus-mismatch rule's "when the two disagree" as: both the item declaration
  and the parent cell are present and their target sets differ (not merely that
  one is a subset of the other). Confirm at design. — owner: user, needed by:
  design.

## Dependencies and constraints

- **Consumes `0001-conflict-declaration-model` unchanged.** The target kinds
  (intra-roadmap sibling local id, canonical work-item reference, repository-
  relative surface path), the `ConflictTargetList` grammar, the sibling-first
  resolution precedence, the empty-value convention, and the
  unresolved-declaration rule are the single authority in `docs/workflow.md` →
  "Declared conflicts (`conflicts-with`)" (`docs/workflow.md:110-177`). This item
  consumes them and defines no second grammar.
- **Consumes `0002-plan-record` unchanged.** The declaration home (`design.md`
  frontmatter `conflicts-with`), the roadmap `Children` cell, the child-union rule
  with its mismatch report, and the plan-publication `/build` gate are authority in
  `docs/workflow.md` → "Declared conflicts (`conflicts-with`)" and
  `## Plan publication`.
- **Reuses the shipped conflict vocabulary.** The `(a)`–`(d)` class labels and the
  finding-line grammar live in `docs/workflow.md` → `## Merge conflicts` and
  `.opencode/skill/merge-conflict/SKILL.md` → "Finding grammar"; this item reuses
  them and forks nothing.
- **Distinct from `0005`.** The shipped pre-ship detection operates on branches
  and a dry-run merge; this check is planning-time and reads committed plan
  declarations only.
- **Offline and local.** `/status` already establishes the read-only, local-only
  reporting pattern (`docs/workflow.md` → "Merge-integrity guard",
  `.opencode/agent/status.md`); the check follows it and never fetches, reads a
  remote, or runs a dry-run merge.
- **Suite constraint.** The committed suite is read-only and never reads live
  `work/**` (`tests/README.md:29`). Adding a command changes the on-disk command
  set, so the README inventory (`Layout` count and `Commands` table) and the
  command-signature agreement must move in the same change to keep
  `bash tests/run.sh` green. Fixture and mutation coverage for the new check is
  `0004-conflict-guards`.
- **Framework-internal change only.** Docs, prompts, and the command surface; no
  runtime dependency, service, network access, or new toolchain.
- **Advisory and readiness-neutral.** Declarations add no readiness edge and
  reorder no child (`docs/workflow.md` → "Dependencies and readiness"); the check
  reports and never gates.
- **Item context.** Nested child of `0006-parallel-plan-conflicts`
  (`parent: 0006-parallel-plan-conflicts`). Dependencies `0001` and `0002` are
  both satisfied (`ship.md` present), so this item was ready with no override.
