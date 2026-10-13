---
feature: 0010-recursive-plan-cycle
phase: roadmap
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Roadmap — Recursive development cycle and roadmap deprecation

## Initiative

The framework's development cycle is single-level. A work item is one feature with
one `spec.md`/`design.md`/`tasks.md`, and a multi-feature or multi-initiative
request needs a *separate* pre-step: the special **roadmap** facility (`0002-agentic-roadmaps`),
which adds a parent `roadmap.md` plus nested two-level children
(`docs/workflow.md` → "Roadmaps"). That split is the seam this initiative removes.
It makes the **standard cycle recursive**: a plan may contain items of any
granularity — tasks, features, initiatives, larger items, or a **hybrid** of them —
and the workflow recursively breaks a plan down until every leaf is an independently
specifiable, buildable, and reviewable unit. The dedicated roadmap concept is
**deprecated** as a special case and subsumed by this uniform recursion, and the
existing per-feature lifecycle becomes the per-node rule applied at every depth.

It serves **framework maintainers**, who must keep the documented lifecycle, the
agents/commands, and the committed consistency guards coherent after the model
changes; and **adopters**, who inherit whichever model the framework documents and
today must learn a special roadmap concept that will no longer exist. The outcome
is one coherent recursive model — no parallel "roadmap" vocabulary — with every
agent and command updated to it, and with the framework still able to run
simultaneous work: parallel items at any level, per-level sequence allocation,
declared conflicts, and merge integrity.

> **Superseded — 2026-10-12.** This plan was withdrawn in full and re-homed to the
> bootstrapped multi-roadmap plan `work/0011-recursive-bootstrap/roadmap.md`. The
> History below (`Assumptions`, `## Open issues`) is preserved unchanged; see the
> revision note in `## Open issues` for what changed and why.

## Assumptions

- **Framework-internal, prompt/config/doc/test only.** No installed runtime
  dependency, service, network access, or new toolchain is introduced. Surfaces in
  scope: `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`,
  `README.md`, `.opencode/{agent,command,skill}/**`, and `tests/`.
- **Extend, do not fork.** The existing nesting model (parent item + nested child
  dirs), the canonical-reference grammar, per-scope sequence allocation, the
  readiness algorithm, the `Children`/`conflicts-with` table, the declared-conflict
  check, the merge-integrity guard, and the backtracking/re-entry vocabulary
  (shipped by `0002`, `0003`, `0005`, `0006`, `0007`) are the seed this initiative
  generalizes. It defines **no second** state model, finding grammar, conflict
  taxonomy, or reference grammar.
- **The recursion subsumes "roadmap".** The abstract contract that retires the
  special roadmap concept is fixed by child `0001-recursive-model`; the concrete
  command/agent removal and the migration of existing roadmap items are child
  `0004-roadmap-deprecation`.
- **Existing roadmap items are context, not scope to rewrite.** The shipped
  roadmap parents `0003`–`0007` (and this roadmap, `0010`) and their nested children
  are treated as approved/shipped context; deprecation must not silently rewrite
  shipped work or reuse spent numbers. How those items are grandfathered, migrated,
  or left read-only is owned by `0004-roadmap-deprecation`.
- **Backward compatibility.** A one-segment standalone item and its artifacts
  behave exactly as before; existing `work/` content requires no forced migration.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every step.
  The suite is read-only and **never reads live `work/**`** (`tests/README.md`), so
  every new guard must be fixture-based.
- **Shipped work is context.** Items whose `ship.md` is present are out of scope for
  re-scoping or re-sequencing; children must extend their decisions, not re-open
  them.
- **Child numbers are local** to this parent and independent of the top-level
  sequence and of other roadmaps.
- **The user owns the policy forks.** Whether recursion depth is bounded; whether
  `/roadmap` is removed outright or redirected; how a parent's progress derives from
  its children; whether fine-grained tasks become child items or stay `tasks.md`
  entries; and the terminology are user decisions owned by the relevant children.
  The roadmap does not decide them.

## Children

All eight children are withdrawn — see the withdrawal records under `## Open
issues`. The six-column header is retained for the positional contract and the
active set is empty.

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |

## Sequencing

No active children: every child was withdrawn in the 2026-10-12 revision (see
`## Open issues`). The stored `Depends on` graph is empty and therefore acyclic, and
`## Sequencing` is vacuous. The initiative is re-homed to the sequence documented in
`work/0011-recursive-bootstrap/roadmap.md`.

## Open issues

- **Single-feature check.** The initiative is genuinely multi-feature — a recursive
  model, an arbitrary-depth schema/reference grammar, recursive decomposition in
  the plan phase, roadmap deprecation and migration, readiness/derived-state/status
  across levels, simultaneous-work guarantees, an all-agent surface sweep, and
  committed guards — so a roadmap is the right vehicle rather than a standalone
  `/spec`.
- **No duplicate roadmap.** Recon of `work/` found five existing roadmaps
  (`0003-framework-quality-hardening`, `0004-adoption-template-split`,
  `0005-merge-conflict-workflow`, `0006-parallel-plan-conflicts`,
  `0007-phase-backtracking`) and flat items `0001-framework-consistency-hardening`,
  `0002-agentic-roadmaps`, `0008-mutation-test-friction`, `0009-minor-nit-resolution`;
  none covers a recursive lifecycle or roadmap deprecation. No collision was found.
- **This roadmap uses the facility it plans to retire.** `0010-recursive-plan-cycle`
  is itself a roadmap parent; the migration in `0004-roadmap-deprecation` must
  explicitly account for this item and its own children (as well as `0003`–`0007`)
  so the deprecation leaves no orphaned or unlisted child behind.
- **Possible overlap with shipped roadmap/readiness work.** `0005-readiness-and-status`
  and `0006-simultaneous-work` extend the readiness algorithm, derived-state table,
  and roadmap integrity surfaces settled by `0003/0002-readiness-ship-state`,
  `0007/0006-status-and-derived-state`, and `0005`/`0006`. They must extend and
  reference those decisions, not re-open or fork them, and keep
  `tests/checks/10-readiness.sh`, `80-cycle-fixture.sh`, and `85-conflict-guards.sh`
  green.
- **Unresolved user decision — bounded depth.** Whether recursion is unbounded or
  capped at a fixed depth (and what happens at the cap) materially changes the
  schema and the status tree, and is owned by `0001-recursive-model`/`0002-recursive-schema`.
- **Unresolved user decision — roadmap removal surface.** Whether `/roadmap` is
  deleted outright or retained as a thin redirect to the recursive plan path changes
  the command inventory and `README.md`/`tests/checks/40-inventory.sh`; owned by
  `0004-roadmap-deprecation`.
- **Unresolved user decision — existing roadmap migration.** Whether shipped and
  unshipped roadmap parents are grandfathered read-only, migrated to the manifest
  form, or left untouched is owned by `0004-roadmap-deprecation` and must not rewrite
  shipped work or reuse spent numbers.
- **Unresolved user decision — parent/child progress derivation.** How a parent
  node's phase and progress derive from its children (and whether a parent has its
  own leaf lifecycle at all) is owned by `0005-readiness-and-status` and changes the
  derived-state table.
- **Unresolved user decision — task vs. item granularity.** Whether fine-grained
  `tasks.md` entries stay tasks or become child items of the recursive tree is a
  boundary the model child `0001-recursive-model` must fix, since it decides how far
  the recursion descends.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001`→`0002`; `0001`/`0002`→{`0003`,`0004`,`0005`}; `0002`/`0005`→`0006`;
  `0001..0006`→`0007`; `0001..0007`→`0008`); no `CYCLIC-DEP` is expected. Recorded
  because the roadmap agent never stores a cycle.
- **Advisory conflicts are intentional.** Several rows declare `docs/workflow.md`
  (and other shared authority surfaces) in `conflicts-with`. The read-only
  declared-conflict check will therefore report `TEXTUAL-CONFLICT` pairs among this
  roadmap's own children; this is intentional — they are independent siblings that
  all edit the authority docs — and is advisory only, changing no `Depends on` edge
  and no child's readiness.
- **Deliberately out of scope — automatic orchestration.** Automatically driving
  build/test/review across nodes, parallel-agent execution, delivery dates, and
  scheduling remain out of scope, consistent with `0002-agentic-roadmaps`' non-goals;
  this initiative changes the *model and artifacts*, not the execution model.
  Recorded here so the omission is explicit rather than silent.
- **Withdrawn child — `0001-recursive-model`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0001-recursive-model/` and spent local number are
  preserved; the number is never reused. Rationale: superseded by the bootstrapped
  multi-roadmap plan `work/0011-recursive-bootstrap/` — the child was a
  sub-initiative (a model plus a deprecation contract), not a single feature, and
  the current two-level tooling cannot nest it. Former scope: the recursive
  lifecycle model and the retirement contract. Re-homed to
  `0011-recursive-bootstrap/0001-recursive-model`.
- **Withdrawn child — `0002-recursive-schema`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0002-recursive-schema/` and spent local number are
  preserved; the number is never reused. Rationale: superseded by the bootstrapped
  multi-roadmap plan; a reference-grammar and sequence-allocation rewrite spanning
  docs and guards is not a single feature. Former scope: recursive references,
  per-level sequence allocation, frontmatter, and the plan/manifest. Re-homed to
  `0011-recursive-bootstrap/0002-recursive-schema`.
- **Withdrawn child — `0003-plan-decomposition`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0003-plan-decomposition/` and spent local number
  are preserved; the number is never reused. Rationale: superseded by the
  bootstrapped multi-roadmap plan. Former scope: recursive decomposition in the plan
  phase and the `/spec`/`/plan`/`architect`/`product` updates. Re-homed to
  `0011-recursive-bootstrap/0003-recursive-writer`.
- **Withdrawn child — `0004-roadmap-deprecation`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0004-roadmap-deprecation/` and spent local number
  are preserved; the number is never reused. Rationale: superseded by the
  bootstrapped multi-roadmap plan, where deprecation and migration are deferred to a
  successor roadmap. Former scope: retiring `/roadmap` and `roadmap.md` and deciding
  the migration of existing roadmap items.
- **Withdrawn child — `0005-readiness-and-status`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0005-readiness-and-status/` and spent local number
  are preserved; the number is never reused. Rationale: superseded by the
  bootstrapped multi-roadmap plan. Former scope: readiness, derived state, and
  `/status` across recursion. Re-homed to
  `0011-recursive-bootstrap/0004-recursive-readiness`.
- **Withdrawn child — `0006-simultaneous-work`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0006-simultaneous-work/` and spent local number are
  preserved; the number is never reused. Rationale: superseded by the bootstrapped
  multi-roadmap plan, where simultaneous-work guarantees are deferred to a successor
  roadmap. Former scope: per-level allocation/duplicate detection, `conflicts-with`
  at every level, and merge integrity for recursive trees.
- **Withdrawn child — `0007-agent-surface-update`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0007-agent-surface-update/` and spent local number
  are preserved; the number is never reused. Rationale: superseded by the
  bootstrapped multi-roadmap plan — a fourteen-agent sweep is an initiative, not a
  feature, and is deferred to a successor roadmap. Former scope: the agent, command,
  and inventory surface sweep.
- **Withdrawn child — `0008-recursive-guards`.** Withdrawn by user decision on
  2026-10-12 and removed from the Children table and Sequencing above. Its directory
  `work/0010-recursive-plan-cycle/0008-recursive-guards/` and spent local number are
  preserved; the number is never reused. Rationale: superseded by the bootstrapped
  multi-roadmap plan, where committed guards are deferred to a successor roadmap.
  Former scope: fixture-based committed guards pinning the recursive workflow.
- **Revised 2026-10-12.** Triggered by the user's supersession decision, not a child
  finding — no child `backtracks.md` exists (the eight children held only
  `.gitkeep`) — after the bootstrapped multi-roadmap plan
  `work/0011-recursive-bootstrap/roadmap.md` was authored. Operations: **withdraw**
  (all eight children removed from the Children table and `## Sequencing`, their
  directories and spent local numbers preserved) and **re-sequence** (`## Sequencing`
  recomputed to empty, a valid topological order of the now-empty stored graph).
  Invalidated: none — each withdrawn child carried no phase artifacts, and a
  withdrawal does not mark a child stale. The initiative and its unresolved user
  decisions are re-homed to `0011-recursive-bootstrap` and its documented
  successor-roadmap sequence. The pre-revision roadmap remains recoverable from
  committed git history.
