---
feature: 0006-parallel-plan-conflicts/0004-conflict-guards
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "Nested child of 0006-parallel-plan-conflicts. Dependencies 0001-conflict-declaration-model and 0003-conflict-check are both satisfied (ship.md present), so this item is ready with no override. User decisions 2026-10-08: (1) guard mechanism is a fixture-driven parser plus content agreement, keeping the shipped no-committed-checker contract, with the live LLM run a documented manual residual; (2) coverage is the full declared-conflict contract — column/positional parsing, cell resolution, pair predicate, ship.md exclusion, own-union-parent-cell drift, and all four reporting situations."
parent: 0006-parallel-plan-conflicts
---

# Committed guards for the declared-conflict model and check

## Problem

The planning-time `conflicts-with` declaration model (`0001`), the item-level
plan record (`0002`), and the read-only declared-conflict check (`0003`) are
shipped, but the **committed** suite does not guard any of them. Each upstream
sibling explicitly deferred its committed fixtures and mutation coverage to this
child. Today the only protection is item-level suites that live under `work/` and
are not wired into CI, so a later edit that drops the `conflicts-with` column from
the roadmap fixture, shifts the positional parse that keeps `Depends on`'s
meaning, removes a grammar/resolution rule, changes a finding code, or deletes the
check from an operative prompt would leave the committed suite green.
Framework maintainers and adopters who run parallel work rely on the committed
suite as the regression gate; without committed guards, the model and check can
silently rot.

## Goals

- Give the committed suite fixture-based coverage of the `conflicts-with`
  declaration model and the declared-conflict check, so a regression in the column
  layout, cell grammar and resolution, pair predicate, or reporting vocabulary is
  caught and named.
- Bring the committed roadmap-cycle fixture and its agreement onto the current
  column layout so `Depends on` retains its meaning and the cycle agreement keeps
  passing.
- Prove the declared-conflict data is genuinely conflict-bearing and that every
  declared target resolves or is `—`, without a live model run.
- Extend the mutation self-check so each new guard is proven caught and named.
- Keep the suite read-only and independent of live `work/**`, and keep the
  shipped prompt-only, no-committed-checker contract intact.
- Keep the existing readiness, cycle, and inventory agreements green without
  duplicating their assertions.

## Non-goals

- Changing the `conflicts-with` grammar, target kinds, resolution precedence,
  finding codes or classes, the pair predicate, or the check algorithm — those are
  fixed by `0001`–`0003`.
- Making the prompt-only check behaviorally executable; adding a committed
  checker, script, helper, or executable tool for it is explicitly out of scope,
  and no rule is defined for a new code or class.
- Re-testing or duplicating the readiness, cycle, or inventory/command-signature
  agreements; the new area composes with them and leaves them intact.
- Reading live `work/**`; the suite must stay runnable on a fresh clone with no
  per-item artifacts.
- Any change to a production surface — docs, prompts, commands, agents, or skills
  are already shipped by `0001`–`0003`; this child changes only committed test
  fixtures, checks, the suite's documentation, and the mutation self-check.
- Adding a command, agent, or skill, or changing any documented inventory count.
- Migrating historical items or back-filling declarations.
- Any runtime dependency, service, network access, or new toolchain.

## Users and stories

- **As a** framework maintainer, **I want** the committed suite to fail and name
  the area when the `conflicts-with` column, its parsing, or its positional
  meaning regresses, **so that** CI protects the declaration model without my
  remembering to re-run item-level suites.
- **As a** maintainer, **I want** committed fixtures that prove every declared
  target resolves (or is `—`) and that a genuine declared conflict is encoded,
  **so that** a broken grammar, resolution rule, or fixture is caught without a
  live model run.
- **As a** maintainer running parallel plans, **I want** the guard to exercise the
  full check contract — shared targets, one-sided naming, shipped-item exclusion,
  and parent/item declaration drift, **so that** the behavior my plans depend on
  is pinned.
- **As a** maintainer, **I want** the mutation self-check to prove each new guard
  is caught and named, **so that** the guards cannot pass vacuously.
- **As an** adopter, **I want** the guards to run offline on a fresh clone and
  leave the existing agreements untouched, **so that** adopting the framework
  needs no per-item setup and no migration.

## Acceptance criteria

1. **AC1** — Given the committed roadmap-cycle fixture, when the committed suite
   runs, then the fixture's `Children` table uses the current column layout that
   includes `conflicts-with`, the cycle agreement still passes, and `Depends on`
   is still parsed at the same field position so the fixture's cycle is still
   proven.
2. **AC2** — Given the committed declaration fixture data, when the suite runs,
   then every `conflicts-with` cell is validated: each cell is either `—` or a
   well-formed list of the three declared target kinds, and the suite fails and
   names the area for a malformed or unresolved target.
3. **AC3** — Given committed fixture data encoding two unshipped plans that share
   a declared target, when the suite runs, then it proves a genuine declared
   conflict exists between them, and it fails if the fixture no longer encodes
   one.
4. **AC4** — Given committed fixture data encoding one plan that names another
   unshipped plan which declares nothing, when the suite runs, then it proves the
   pair is a declared conflict even though the named plan contributes no target of
   its own.
5. **AC5** — Given committed fixture data, when the suite runs, then it exercises
   each resolution outcome: an intra-roadmap sibling local id resolves to a
   sibling row; a canonical item reference resolves to an existing item in the
   fixture's local item tree; a repository-relative surface path resolves to an
   existing file or directory; `—` declares no conflicts; and a malformed,
   self-referential, duplicated, empty, or non-existent target is unresolved.
6. **AC6** — Given committed fixture data for a roadmap child that declares
   targets itself and whose parent row also declares targets, when the suite runs,
   then it proves the child's declared set is the union of the two, and that a
   disagreement between two present, unequal sets is detected and named while a
   one-sided record is not treated as a discrepancy.
7. **AC7** — Given committed fixture data containing an item marked shipped,
   when the suite runs, then it proves the shipped item is excluded as a
   counterpart while still resolving as a declared target.
8. **AC8** — Given the shipped authority and the operative surfaces that run the
   check, when the suite runs, then it asserts, and fails on the loss of, the
   reporting vocabulary: the shipped finding-line grammar and the shipped codes
   and `(a)`–`(d)` classes for the four planning-time situations, with no new
   class, code, or policy introduced.
9. **AC9** — Given the committed suite runs, when the new area executes, then it
   reads only committed suite fixtures and live repository surfaces, never reads
   live `work/**`, and neither invokes nor adds a committed executable checker for
   the prompt-only check.
10. **AC10** — Given the existing readiness, cycle, and inventory agreements,
    when the new area and the fixture update land, then those agreements remain
    green and the new area introduces no duplicate readiness, cycle, or
    inventory-count assertion.
11. **AC11** — Given the mutation self-check runs against the new area, when it
    applies a mutation aimed at each new guard (column layout, positional parse,
    cell resolution, pair predicate, and reporting vocabulary), then each mutation
    is caught and names the new area, and any mutation that escapes fails the
    self-check.
12. **AC12** — Given the suite's own documentation, when the new agreement area
    is added, then the suite documents the new area and its stable token, and the
    existing area list and its tokens stay accurate.
13. **AC13** — Given the committed suite is run on a fresh clone with no `work/`
    present, when the new area executes, then the run exits successfully and every
    new assertion is satisfied from committed fixture and live-surface content.

## Edge cases

- **No declarations** — a fixture whose cells are all `—` is valid and yields no
  declared-conflict finding.
- **Absent column** — fixture data authored before the column existed has no
  `conflicts-with` column; absence is treated as `—` for every row, not as
  malformed.
- **Bare-reference ambiguity** — a `MMMM-slug` that could be a sibling row or a
  top-level item resolves sibling-first; the guard does not reinterpret it.
- **Cross-roadmap same-token** — equal reference tokens that resolve to different
  items are not the same target and do not form a conflict.
- **Directory surface target** — an existing repository-relative directory path
  resolves; a non-existent one is unresolved.
- **Malformed surface target** — a glob metacharacter, `..`, or an absolute path
  is unresolved.
- **Duplicate / empty / self-referential target** — a repeated target, an
  empty or whitespace-only cell, and a row naming its own local id are each
  malformed.
- **Shipped target** — naming a shipped item resolves but produces no conflict
  and no unresolved finding.
- **Unspecced child** — a child directory holding only `.gitkeep` is still
  represented by its parent row's cell and compared.
- **Reciprocal naming** — two plans each naming the other yield exactly one
  finding, not two.
- **Mutation staging** — any new committed fixture directory is staged by the
  mutation self-check's copy, so the mutation cases run against it.
- **Empty compared set** — when no fixture plan declares anything, or all are
  shipped, the guard passes without error.

## Open questions

- [ ] **Assumption — fixture set.** The guard may add one or more committed
  fixtures beyond the existing roadmap-cycle fixture (for example a declaration
  fixture and a fixture-local item tree) rather than overloading the cycle
  fixture; the exact fixture set and the new agreement area's token are left to
  design. — owner: architect, needed by: design.
- [ ] **Assumption — refusal to add a checker.** Per user decision, the guard
  stays fixture-parser-plus-content and does not add a committed executable
  checker for the prompt-only check; the live model run remains a documented
  manual residual. Confirm at design if the residual should be recorded in the
  suite documentation. — owner: architect, needed by: design.

## Dependencies and constraints

- **Consumes `0001-conflict-declaration-model` unchanged.** The `conflicts-with`
  column, the `ConflictTargetList` grammar, the three target kinds, the
  sibling-first resolution precedence, the empty-value convention, and the
  unresolved-declaration rule are the authority in `docs/workflow.md` →
  "Declared conflicts (`conflicts-with`)". This item pins them and forks nothing.
- **Consumes `0002-plan-record` unchanged.** The item-level declaration home, the
  union of an item's own declaration with its parent row's cell, the mismatch
  report, and the shipped-state exclusion are fixed by `0002` and the authority;
  this item guards them but does not redefine them.
- **Consumes `0003-conflict-check` unchanged.** The compared set, the pair
  predicate, the four finding situations, and the shipped codes and classes are
  fixed by `0003`; this item pins them and adds no code or class.
- **Prompt-only check contract.** The check has no committed checker, script,
  helper, or executable tool; therefore the committed guards can pin the
  declaration data and the reporting vocabulary, but a live model run of the check
  is a documented manual residual, exactly as the cycle diagnostic's LLM run is.
- **Read-only, fresh-clone suite.** The committed suite is read-only and never
  reads live `work/**`; every new guard must be fixture-based and live-surface
  based, and any item-reference target in a fixture must resolve within the
  fixture, not against live items.
- **Positional-parser hazard.** The existing cycle agreement asserts an exact
  `Children` header and reads `Depends on` at a fixed field position; the new
  column must be inserted so that position is unchanged, and the fixture and that
  agreement must move together.
- **Mutation staging.** The mutation self-check copies a fixed set of live
  surfaces and fixtures into scratch; any new fixture directory must be added to
  that copy so the new mutation cases run against it.
- **No inventory impact.** This child adds no command, agent, or skill, so the
  documented inventory counts and command-signature agreement are unchanged and
  must stay green.
- **Framework-internal only.** Docs, prompts, fixtures, and tests; no runtime
  dependency, service, network access, or new toolchain.
- **Item context.** Nested child of `0006-parallel-plan-conflicts`
  (`parent: 0006-parallel-plan-conflicts`). Dependencies
  `0001-conflict-declaration-model` and `0003-conflict-check` are both satisfied
  (`ship.md` present), so this item was ready with no override.
