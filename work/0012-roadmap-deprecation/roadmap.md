---
feature: 0012-roadmap-deprecation
phase: roadmap
status: final
created: 2026-10-13
updated: 2026-10-13
---

# Roadmap — Roadmap deprecation and migration

## Initiative

This is **Roadmap 2** of the bootstrapped multi-roadmap plan that
`work/0011-recursive-bootstrap/roadmap.md` launched (its "Multi-roadmap sequence",
`work/0011-recursive-bootstrap/roadmap.md:125-149`). Roadmap 1 (the bootstrap)
shipped the minimum slice that made the lifecycle recursive — model, schema,
writer, and readiness/derived state — while deliberately leaving the special
**roadmap** concept in place: `/roadmap` is still a shipped command, its `roadmap`
agent still ships, and `roadmap.md` remains the recognized concrete spelling of
the manifest (`docs/artifact-conventions.md:124-137`, `docs/workflow.md:174-192`).

This roadmap retires that special case and replaces it with the generic concept
the bootstrap established: the **manifest** as the sole child-enumeration artifact,
authored by the planning step (`/plan`, `architect`) at any depth. It withdraws
`/roadmap` and its agent, decides the concrete spelling and `phase` treatment of
the manifest, reconciles every documented inventory and signature surface that
names them, and decides the treatment of the seven existing decomposing nodes
without rewriting shipped work or reusing a spent number.

It serves **framework maintainers**, who must keep the lifecycle, agents,
commands, inventories, and committed guards coherent after the concept is retired,
and **adopters**, who today must learn a dedicated "roadmap" facility that the
recursive model has subsumed.

## Assumptions

- **Framework-internal, prompt/config/doc/test only.** No installed runtime
  dependency, service, network access, or new toolchain is introduced. Surfaces in
  scope: `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`,
  `template/AGENTS.md`, `README.md`, `.opencode/{agent,command,skill}/**`,
  `tests/`, and the existing `work/*/roadmap.md` artifacts.
- **Roadmap 2 of the sequence.** Roadmap 1 (`0011-recursive-bootstrap`) has shipped
  all four of its children; this roadmap is the immediate follow-up specified at
  `work/0011-recursive-bootstrap/roadmap.md:133-136`. Roadmaps 3–5 (simultaneous
  work, surface sweep, committed guards) remain separate, later invocations.
- **Extend, do not fork.** The recursive model, the recursive reference grammar and
  per-level allocation, the generic manifest, readiness, and derived state shipped
  by `0011` are the seed this roadmap builds on. It retires a name and a command;
  it defines no second state model, reference grammar, or conflict taxonomy.
- **The manifest is already generic.** `docs/artifact-conventions.md:126-136`
  defines the manifest generically and keeps `roadmap.md` as its shipped concrete
  spelling; the rename/retirement was explicitly deferred here
  (`work/0011-recursive-bootstrap/0002-recursive-schema/spec.md:7`).
- **Shipped work is context.** Items whose `ship.md` is present are out of scope for
  rewriting; this roadmap preserves shipped artifacts, `ship.md` signals, and every
  recorded withdrawal.
- **Spent numbers are never reused.** `0010-recursive-plan-cycle`'s eight withdrawn
  children keep their directories and local numbers
  (`work/0010-recursive-plan-cycle/roadmap.md:152-221`).
- **The committed suite stays green.** `bash tests/run.sh` must pass at every step.
  The suite is read-only and never reads live `work/**` (`tests/README.md:30-31`),
  so any new pin is fixture-based.
- **The user owns the policy forks.** Whether `/roadmap` is deleted or redirected;
  whether `roadmap.md` is renamed or its spelling retained and whether the `phase`
  value changes; and how existing parents are grandfathered or migrated are user
  decisions owned by the relevant children below, not decided here.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-deprecation-contract | Deprecation contract | Define the retirement of the special `roadmap` concept in favor of the generic manifest: state that the manifest is the sole child-enumeration artifact at every depth, decide `roadmap.md`'s concrete spelling (rename to a generic name, or retain it explicitly) and the `phase` value treatment (retain `phase: roadmap` or introduce a successor), and fix the derived-state/artifact-presence and vocabulary consequences. Author `docs/workflow.md` ("The recursive lifecycle model", "Roadmaps", "Where decomposition is authored and recorded", "Derived state") and `docs/artifact-conventions.md` (the manifest template and "Work item references"). Keystone — `0002` and `0003` consume it. Excludes the command/agent retirement (`0002`) and the migration of existing parents (`0003`). Evidence: `docs/artifact-conventions.md:124-217`; `docs/workflow.md:66-98,174-192,1211-1295`; `work/0010-recursive-plan-cycle/roadmap.md:176-182`; `work/0011-recursive-bootstrap/roadmap.md:133-136`. | — | docs/workflow.md, docs/artifact-conventions.md | 0012-roadmap-deprecation/0001-deprecation-contract |
| 0002-command-retirement | Retire the `/roadmap` command and `roadmap` agent | Remove `.opencode/command/roadmap.md` and `.opencode/agent/roadmap.md`, and make the planning step (`/plan`, `architect`) the sole recursive writer, including the create mode the alias owned. Reconcile every documented inventory and signature surface that names them: the `README.md` Layout counts and Commands/Agents tables, `AGENTS.md` and its byte-parity twin `template/AGENTS.md`, `tests/checks/40-inventory.sh`, `tests/checks/96-signature-sweep.sh`, the `workflow-lifecycle` skill, and `docs/workflow.md`'s alias prose. Excludes the docs contract (`0001`) and parent migration (`0003`). Evidence: `README.md:183-215,269-275`; `AGENTS.md:44-51,67-78`; `template/AGENTS.md:49-80`; `tests/checks/40-inventory.sh:40-42`; `tests/checks/96-signature-sweep.sh:47,270`; `.opencode/skill/workflow-lifecycle/SKILL.md:22-88`. | 0001-deprecation-contract | docs/workflow.md, README.md, AGENTS.md, template/AGENTS.md | 0012-roadmap-deprecation/0002-command-retirement |
| 0003-parent-migration | Existing-parent migration | Decide and apply the treatment of the seven existing decomposing nodes (`0003`–`0007`, `0010`, `0011`) under the retired concept: grandfather read-only, migrate to the decided manifest spelling, or leave untouched — preserving shipped artifacts, `ship.md` signals, spent numbers, and `0010`'s recorded withdrawals. Reconcile the fixtures and guards that name `roadmap.md` (`80-cycle-fixture`, `85-conflict-guards`, `87-backtrack-guards`) and any prose in `tests/README.md`. Excludes the docs contract (`0001`) and the command retirement (`0002`). Evidence: `work/*/roadmap.md`; `tests/checks/80-cycle-fixture.sh:21-130`; `tests/checks/85-conflict-guards.sh:31-72`; `tests/checks/87-backtrack-guards.sh:545-736`; `tests/README.md:114`. | 0001-deprecation-contract | work, tests/checks/80-cycle-fixture.sh, tests/checks/85-conflict-guards.sh, tests/checks/87-backtrack-guards.sh | 0012-roadmap-deprecation/0003-parent-migration |

## Sequencing

1. 0001-deprecation-contract
2. 0002-command-retirement
3. 0003-parent-migration

`0001-deprecation-contract` is the keystone: the retired terminology, the concrete
manifest spelling, and the `phase`/derived-state treatment must be fixed before the
command surface (`0002`) or the existing-parent migration (`0003`) can be
specified; both consume it. Once `0001` lands, `0002` and `0003` have no unmet
prerequisite and may proceed in parallel; they are ordered `0002`, `0003` here only
to keep a stable reading order.

## Open issues

- **Single-feature check.** The initiative is genuinely multi-feature — a
  deprecation contract, a command/agent retirement with inventory reconciliation,
  and a migration of seven existing parents — so a roadmap is the right vehicle
  rather than a standalone `/spec`.
- **Re-homes a withdrawn child; no number reuse.** This is exactly the scope of
  `0010-recursive-plan-cycle/0004-roadmap-deprecation`, withdrawn on 2026-10-12 and
  preserved as a `.gitkeep`-only directory
  (`work/0010-recursive-plan-cycle/roadmap.md:176-182`). Its directory and spent
  local number `0004` are **not** reused, and `0010` remains a superseded container;
  this roadmap is a fresh top-level node.
- **No duplicate roadmap.** Recon of `work/` found seven decomposing nodes
  (`0003`–`0007`, `0010`, `0011`); none other covers retiring `/roadmap`/`roadmap.md`
  or migrating parents. Recorded so the choice of a new top-level node rather than a
  nested child is explicit.
- **Unresolved user decision — command removal surface.** Whether `/roadmap` (and
  its `roadmap` agent) is deleted outright or retained as a thin redirect to
  `/plan` changes the command/agent inventory and `tests/checks/40-inventory.sh`;
  owned by `0002-command-retirement`.
- **Unresolved user decision — manifest spelling and `phase`.** Whether `roadmap.md`
  is renamed to a generic file name, and whether `phase: roadmap` is retained or
  replaced by a successor value, changes the derived-state/artifact-presence rows
  and the guards; owned by `0001-deprecation-contract`. Retaining the spelling is a
  valid outcome, in which case this roadmap retires only the term and the command.
- **Unresolved user decision — existing-parent migration.** Whether `0003`–`0007`,
  `0010`, and `0011` are grandfathered read-only, migrated to the decided spelling,
  or left untouched is owned by `0003-parent-migration` and must not rewrite shipped
  work or reuse spent numbers.
- **Overlap with later successor roadmaps.** The broad **agent/command/inventory
  surface sweep** is Roadmap 4 and the **committed recursive-workflow guards** are
  Roadmap 5 (`work/0011-recursive-bootstrap/roadmap.md:140-145`). This roadmap
  touches only the surfaces it retires and adds no recursive-workflow fixture area
  of its own; the boundary is recorded so scope is not silently widened.
- **Possible overlap with shipped work.** `0002`'s inventory edits extend surfaces
  settled by `0004/0005-surface-consistency-sweep` and
  `0003/0008-adoption-packaging`; they must keep `tests/checks/40-inventory.sh`,
  `96-signature-sweep.sh`, and `95-split-guard.sh` (the
  `AGENTS.md`/`template/AGENTS.md` byte-parity guard) green.
- **Advisory conflicts are intentional.** Rows declare shared authority surfaces
  (`docs/workflow.md`, `README.md`, `AGENTS.md`, `template/AGENTS.md`) in
  `conflicts-with`. The read-only declared-conflict check will report
  `TEXTUAL-CONFLICT` pairs among this roadmap's own children; this is intentional —
  independent siblings that edit the same authority docs — and is advisory only,
  changing no `Depends on` edge and no child's readiness.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001`→{`0002`,`0003`}); no `CYCLIC-DEP` is expected. Recorded because the
  planning step never stores a cycle.
- **One create call, one parent.** This node was authored as a single top-level
  decomposing node (the next top-level `0012`); Roadmaps 3–5 remain separate later
  invocations. Recorded so the staging is explicit rather than silently absent.
