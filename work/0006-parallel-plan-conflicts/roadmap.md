---
feature: 0006-parallel-plan-conflicts
phase: roadmap
status: final
created: 2026-10-07
updated: 2026-10-07
---

# Roadmap — Roadmap conflicts-with column and pre-development parallel-development consistency checks

## Initiative

The framework's roadmap feature lets a parent enumerate child work items and their
`Depends on` edges, and the shipped `0005-merge-conflict-workflow` defines how to
reconcile two branches *after* they collide. Neither answers the earlier question:
two planned items that are independent by dependency graph can still be
*untracked rivals* for the same surfaces, and today nothing records which surfaces
a plan expects to touch or warns that two in-flight plans overlap until they
collide at merge time. This initiative adds a **`conflicts-with` declaration** to
the roadmap `Children` table (and a way for a work item to declare the surfaces it
expects to collide on) and a **pre-development consistency check** that compares
committed plans before any build starts — "commit plans before development and
compare with existing plans for conflict."

It serves **framework maintainers** running parallel roadmap children or parallel
work items, who need to see an overlap during planning and decide there rather
than resolving it by hand at merge time, and **adopters**, who inherit the same
blind spot when they run parallel work. The outcome is a planning layer that
records intended conflict surfaces as committed, reviewable state and surfaces
overlaps at the pre-development gate, complementing — never replacing — the
merge-time reconcile contract of `0005-merge-conflict-workflow`.

## Assumptions

- **Planning-time, not merge-time.** "Commit plans before development and compare
  with existing plans for conflict" means a work item's declared conflict surfaces
  are persisted as committed artifact state under `work/` and compared *before*
  `/build` begins. It is distinct from the shipped merge/reconcile contract of
  `0005-merge-conflict-workflow` (`docs/workflow.md:337-435`), which runs at ship
  time on branches. The two are complementary; this roadmap does not re-open or
  fork the merge-conflict contract.
- **`conflicts-with` is a declared claim, not a dependency.** It records surfaces
  or items a plan expects to collide with; it is advisory planning metadata and
  does not create a readiness edge, reorder children, or gate `/build` by itself.
  Readiness remains purely `Depends on`-based (`docs/workflow.md:77-135`).
- **Reuse the shipped conflict vocabulary.** The shipped `0005` model and
  `merge-conflict` skill fixed conflict classes and a finding grammar
  (`docs/workflow.md:337-435`, `.opencode/skill/merge-conflict/SKILL.md`); this
  initiative reuses them and defines no second taxonomy.
- **Framework-internal, prompt/config/doc/test only.** No installed runtime
  dependency, service, network access, or new toolchain is introduced. Surfaces in
  scope: `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`,
  `README.md`, `.opencode/{agent,command,skill}/**`, and `tests/`.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every step.
  The suite is read-only and **never reads `work/**`** (`tests/README.md:29`), so
  any guard must be fixture-based and must not read live `work/` content.
- **Adding a Children column is a breaking change to positional parsers.**
  `tests/checks/80-cycle-fixture.sh:31-64` asserts the exact five-column header and
  parses `Depends on` at table position 5; `docs/artifact-conventions.md:110` fixes
  the same template. The new column must be rolled out with those surfaces in the
  same change.
- **Shipped work is context, not scope.** `0001`–`0005` and all their children are
  treated as approved/shipped. In particular the roadmap model
  (`0002-agentic-roadmaps`), the conflict model, detection, reconcile, and guards
  (`0005-merge-conflict-workflow`, all five children shipped) are consumed, not
  redone.
- **The user owns the policy forks.** The invocation surface (a new command versus
  a step in an existing one), advisory versus blocking behavior, whether
  `conflicts-with` may name other top-level items or only intra-roadmap rows, and
  where the committed plan record lives are user decisions owned by the relevant
  children. The roadmap does not decide them.
- Child numbers are local to this parent and independent of the top-level sequence
  and of other roadmaps.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-conflict-declaration-model | Declared conflict model and `conflicts-with` column | Fix what a *planning-time* conflict is and the vocabulary for declaring it. Add a `conflicts-with` column to the roadmap `Children` table so a row can name the other rows/items/surfaces it expects to collide with, and define how a child or standalone work item declares its own intended conflict set before development. Decide the cell grammar (comma-separated local ids and/or surface paths; `—` when none) and whether it is intra-roadmap-only or may name other top-level items. Update the authority `docs/workflow.md` → "Roadmaps" and "Dependencies and readiness" (`:62-135`), the `roadmap.md` template and its column notes in `docs/artifact-conventions.md` (`:80-136`), the roadmap agent prompt (`.opencode/agent/roadmap.md:73-101`) and `.opencode/command/roadmap.md`, and every surface that names the Children columns (`AGENTS.md`, `README.md`, `workflow-lifecycle` skill). Reuse the shipped `0005` conflict classes and finding grammar (`docs/workflow.md:337-435`, `.opencode/skill/merge-conflict/SKILL.md`) rather than forking them. Keystone — the other children consume the declaration model. Evidence: `docs/artifact-conventions.md:80-136`, `docs/workflow.md:62-135,337-435`, `.opencode/agent/roadmap.md:73-101`, `tests/checks/80-cycle-fixture.sh:27-98`. | — | 0006-parallel-plan-conflicts/0001-conflict-declaration-model |
| 0002-plan-record | Committed pre-development plan record | Define and implement how a work item's declared plan — its intended surfaces and declared conflicts — is persisted as committed state under `work/` *before* development, so it can be compared against other plans. Decide the record's home (a new artifact with its own `phase` value, or a section/frontmatter field on an existing artifact), when it is produced (roadmap authoring and/or `/spec`/`/plan` entry), and how it stays current as the plan evolves. Wire it into the owning lifecycle prompts (`.opencode/agent/product.md`, `.opencode/agent/architect.md`, roadmap agent) and reconcile it with the frontmatter/derived-state contract (`docs/artifact-conventions.md` frontmatter, `docs/workflow.md` derived state). This is the "commit plans before development" half; it must be committed artifact state, never a second registry file. Evidence: `docs/workflow.md:16-55,62-135`, `docs/artifact-conventions.md:20-79`, `.opencode/agent/product.md`, `.opencode/agent/architect.md`. | 0001-conflict-declaration-model | 0006-parallel-plan-conflicts/0002-plan-record |
| 0003-conflict-check | Pre-development parallel-plan conflict check | Deliver a read-only comparison that, before development starts, detects declared conflicts among committed plans — a new plan against existing plans, and roadmap children against siblings and other in-flight items — and reports them using the shipped `0005` conflict classes and finding grammar (`docs/workflow.md:337-435`, `merge-conflict` skill). Surface results at the pre-development gate and in `/status`, remaining offline and read-only; decide with the user whether it is a new command (e.g. `/conflicts`) or a step inside an existing command, and whether the result is advisory or blocking. It detects and reports only: no reconcile, no branch mutation, and no duplication of the shipped pre-ship branch detection (`work/0005-merge-conflict-workflow/0002-conflict-detection`), which operates on branches rather than plans. If a command is added, update the README inventory surface and `tests/checks/40-inventory.sh`. Evidence: `docs/workflow.md:77-135,337-435`, `.opencode/skill/merge-conflict/SKILL.md`, `.opencode/agent/status.md`, `tests/checks/40-inventory.sh`. | 0001-conflict-declaration-model, 0002-plan-record | 0006-parallel-plan-conflicts/0003-conflict-check |
| 0004-conflict-guards | Committed plan-conflict guards | Extend the committed suite (`tests/`) to pin the new declaration and check: the `Children` table header and positional parsing account for the new `conflicts-with` column, every `conflicts-with` cell resolves to an existing row/item or surface (or is `—`), and declared conflicts are reported by the check. Update the committed fixture `tests/fixtures/cyclic-roadmap/roadmap.md` and `tests/checks/80-cycle-fixture.sh:27-98` to the new column layout, refresh `tests/README.md` for the new agreement area, and extend `tests/mutation.sh` so each guard is proven caught and named. Must keep the existing readiness/cycle/inventory areas (`tests/checks/40-inventory.sh`, `tests/checks/80-cycle-fixture.sh`) green rather than duplicating their agreements, and must be fixture-based because the suite never reads live `work/**` (`tests/README.md:29`). Evidence: `tests/checks/80-cycle-fixture.sh:27-98`, `tests/checks/40-inventory.sh`, `tests/fixtures/cyclic-roadmap/roadmap.md`, `tests/README.md:29,64-116`, `tests/mutation.sh`. | 0001-conflict-declaration-model, 0003-conflict-check | 0006-parallel-plan-conflicts/0004-conflict-guards |

## Sequencing

1. 0001-conflict-declaration-model
2. 0002-plan-record
3. 0003-conflict-check
4. 0004-conflict-guards

`0001-conflict-declaration-model` is the keystone: the column grammar, the
child/item declaration contract, and the reused `0005` taxonomy must be fixed
before anything can be persisted or compared. `0002-plan-record` then makes a
plan's declared surfaces committed state. `0003-conflict-check` consumes both and
adds the pre-development comparison and its reporting surface. `0004-conflict-guards`
is last so it can pin the settled column layout and the check's reporting with
committed, fixture-based regression coverage. `0002` and `0003` are strictly
ordered because the check has nothing to compare until plans are recorded; `0004`
may start as soon as `0003` reports, but is placed last so the column layout it
freezes is final.

## Open issues

- **Possible overlap with the shipped `0005-merge-conflict-workflow`.** `0005`
  fixed the conflict taxonomy and finding grammar (`0001-conflict-model`) and a
  pre-ship branch-vs-default detection (`0002-conflict-detection`); this initiative
  is planning-time and operates on plans, not branches. The children must consume
  and reference that vocabulary, not fork a second definition
  (`docs/workflow.md:337-435`). An intra-roadmap dependency on `0005` is impossible
  (dependencies are intra-roadmap only), so the relationship is recorded here and
  must be honored by `0001` and `0003`.
- **Extension of the shipped roadmap model.** `0002-agentic-roadmaps` owns the
  `Children` table and readiness algorithm. Child `0001-conflict-declaration-model`
  extends that artifact and must keep readiness purely `Depends on`-based and keep
  `tests/checks/80-cycle-fixture.sh` / `40-inventory.sh` green rather than
  replacing their agreements.
- **Positional-parser breakage is a hard constraint.** `tests/fixtures/cyclic-roadmap/roadmap.md`,
  `tests/checks/80-cycle-fixture.sh:31-64`, and the template at
  `docs/artifact-conventions.md:110` all assume a fixed five-column table. The new
  column shifts `Depends on`'s position; child `0004-conflict-guards` must update
  these in the same change as `0001`'s template edit. Shipped historical
  `verify-tests.sh` under `work/` are read-only history and are not rewritten.
- **Unresolved user decision — invocation surface and blocking behavior.** Whether
  the pre-development check is a new command (e.g. `/conflicts`), a step inside
  `/spec`/`/plan`/`/status`, and whether it is advisory or blocking is a design
  fork owned by child `0003-conflict-check`; it changes the command/inventory
  surface and therefore `tests/checks/40-inventory.sh`.
- **Unresolved user decision — `conflicts-with` scope.** Whether a cell may name
  only intra-roadmap local ids or also other top-level work items and bare surface
  paths is owned by child `0001-conflict-declaration-model`; it determines the cell
  grammar and the reference-resolution rules `0004` guards.
- **Unresolved user decision — committed-plan record shape.** Whether the plan
  record is a new artifact with its own `phase` value or a section/frontmatter
  field on an existing artifact is owned by child `0002-plan-record`; it affects
  the frontmatter contract and the derived-state table in `docs/workflow.md`.
- **Deliberately out of scope — structural conflict reduction.** De-duplicating the
  shared framework surfaces so parallel work items stop colliding (the same
  omission recorded by `0005`) and any automatic scheduling/reordering of children
  from declared conflicts are not part of this initiative. Recorded so the omission
  is explicit.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001` → `0002` → `0003` → `0004`); no `CYCLIC-DEP` is expected. Recorded
  because the roadmap agent never stores a cycle.
- **Single-feature check.** The initiative is genuinely multi-feature — a roadmap
  artifact schema change, a persisted plan record, a detection/reporting
  capability, and committed guards — so a roadmap is the right vehicle rather than
  a standalone `/spec`.
- **No duplicate roadmap.** Recon of `work/` found three existing roadmaps
  (`0003-framework-quality-hardening`, `0004-adoption-template-split`,
  `0005-merge-conflict-workflow`) and two flat items (`0001`, `0002`); none adds a
  `conflicts-with` column or a pre-development plan check. `0005` is the closest
  neighbor but is merge-time; no collision was found.
