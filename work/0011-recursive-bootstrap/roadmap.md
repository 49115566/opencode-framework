---
feature: 0011-recursive-bootstrap
phase: roadmap
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Roadmap — Bootstrapped multi-roadmap plan for the recursive development cycle

## Initiative

This roadmap replaces the single monolithic plan `work/0010-recursive-plan-cycle/`
with a **bootstrapped, staged multi-roadmap approach** to the same initiative: a
recursive development cycle in which a plan may contain tasks, features,
initiatives, larger items, or a hybrid, and the workflow recursively breaks a plan
down until every leaf is independently workable; the separate "roadmap" concept is
deprecated and subsumed; and the framework remains able to run simultaneous work.

The superseded plan failed the roadmap contract's own bar. Its eight children are
realistically **sub-initiatives, not single features** — one redefines the
lifecycle and retires a concept, one rewrites the reference grammar and sequence
allocation, one sweeps fourteen agent prompts, and so on. The reason is structural,
not an oversight: the framework caps nesting at two levels (the canonical-reference
grammar allows at most `NNNN-slug/MMMM-slug`) and a node is either a roadmap parent
(no lifecycle of its own) or a feature leaf (no children), so "a child that is
itself an initiative" has no representation. The very facility the initiative
creates is the facility needed to plan it — a chicken-and-egg problem. A single
`/roadmap <initiative>` create-mode call also produces **exactly one** parent
roadmap and cannot retire another parent, so a multi-roadmap plan and the
retirement of `0010` cannot both be one call's output.

The response is to **bootstrap**. This roadmap is **Roadmap 1 of the sequence**: it
delivers only the minimum slice that makes the lifecycle recursive, built with
today's non-recursive tooling, with every child a genuine single feature. Once it
ships, the remaining themes are re-planned **recursively** as successor roadmaps —
the recursive model this roadmap defines applied to the rest of the work. This
roadmap therefore deliberately does not try to represent the whole initiative at
once; it establishes the foundation the recursive re-plan of the remainder stands
on.

It serves **framework maintainers**, who need the lifecycle model, agents, and
committed guards to stay coherent while the model changes in stages; and
**adopters**, who inherit whichever model the framework documents and today must
learn a special roadmap concept that will be retired.

## Assumptions

- **Framework-internal, prompt/config/doc/test only.** No installed runtime
  dependency, service, network access, or new toolchain is introduced. Surfaces in
  scope: `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`,
  `README.md`, `.opencode/{agent,command,skill}/**`, and `tests/`.
- **This replaces `0010-recursive-plan-cycle`.** The prior plan is superseded; its
  children are not carried over as-is. Create mode cannot retire another parent, so
  the sanctioned route to withdraw `0010`'s over-scoped children —
  `/roadmap revise 0010-recursive-plan-cycle` — is recorded under `## Open issues`
  and surfaced in the handoff. Until it is run, two plans coexist and the duplicate
  is reported rather than hidden.
- **Bootstrap scope.** The bootstrap is the minimum set that makes the cycle
  recursive and re-plannable: the recursive **model** (what a recursive node is),
  the **schema** (how nesting is represented), a recursive **writer** (a node at any
  depth can enumerate children), and recursive **readiness/status** (derive and
  report the tree). Everything else — deprecation and migration, simultaneous-work
  guarantees, the agent/command surface sweep, and the committed guards — is
  deferred to successor roadmaps authored after this ships.
- **Each child is genuinely one feature.** Every child must be specifiable,
  buildable, and reviewable on its own; nothing here is a sub-initiative. If a child
  still proves too large at `/spec`, the sanctioned remedy is
  `/roadmap revise 0011-recursive-bootstrap` to re-slice at the **same** level (more
  siblings), never to nest — the current tooling cannot nest, which is the whole
  point.
- **One create-mode call yields one parent roadmap.** A "multi-roadmap plan" is
  therefore materialized as this bootstrap roadmap plus later `/roadmap`
  invocations, not as several parents in one call. Cross-roadmap ordering cannot be
  encoded (dependencies are intra-roadmap only) and is documented as prose in
  `## Sequencing`.
- **Extend, do not fork.** The existing nesting model, canonical-reference grammar,
  per-scope sequence allocation, the readiness algorithm, the `Children`/
  `conflicts-with` table, the merge-integrity guard, and the backtracking/re-entry
  vocabulary (shipped by `0002`, `0003`, `0005`, `0006`, `0007`) are the seed this
  initiative generalizes. No second state model, reference grammar, or conflict
  taxonomy is defined.
- **Backward compatibility.** A one-segment standalone item and its artifacts
  behave exactly as before; no existing `work/` content requires a forced migration
  in this bootstrap.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every step.
  The suite is read-only and **never reads live `work/**`** (`tests/README.md`), so
  any new guard is fixture-based and the guards themselves are deferred to a
  successor roadmap.
- **Shipped work is context.** Items whose `ship.md` is present are out of scope for
  re-scoping or re-sequencing; children extend their decisions, do not re-open them.
- **Child numbers are local** to this parent and independent of the top-level
  sequence, of `0010`'s children, and of other roadmaps.
- **The user owns the policy forks.** Whether recursion depth is bounded; which
  command/agent becomes the recursive writer; how a parent node's progress derives
  from its children; and whether fine-grained tasks become nodes or stay
  `tasks.md` entries are user decisions owned by the relevant children.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-recursive-model | Recursive lifecycle model | Define the recursive model: the standard cycle applies uniformly at every node; a plan may decompose into a **hybrid** of tasks, features, initiatives, and larger items; where decomposition is authored and recorded; how a node at any depth relates its own phase artifacts to its children; whether depth is bounded; the vocabulary ("plan", "node", "leaf", "decomposition"); and how the model composes with the shipped backtracking/re-entry rules (`0007`). Author the contract in `docs/workflow.md` and cross-reference it from `AGENTS.md`. Keystone — every other child consumes it. Excludes the concrete writer (`0003`), readiness/status (`0004`), and roadmap deprecation (a successor roadmap). Evidence: `docs/workflow.md` "The lifecycle", "Roadmaps", "Derived state"; `AGENTS.md`; `work/0010-recursive-plan-cycle/roadmap.md`. | — | docs/workflow.md, AGENTS.md | 0011-recursive-bootstrap/0001-recursive-model |
| 0002-recursive-schema | Recursive work-item schema, references, and sequence allocation | Generalize the artifact conventions and reference grammar from the two-level maximum to arbitrary nesting: the canonical reference as a recursive path, with the one-segment form kept backward compatible; per-level sequence allocation (top-level and per-parent) applied at **every** depth; the frontmatter `parent` chain; the plan/children **manifest** that replaces `roadmap.md` as the enumeration source; `.gitkeep` reservation at each level; and preservation of the positional `Children` table and the `conflicts-with` grammar. Update `docs/artifact-conventions.md`. Evidence: `docs/artifact-conventions.md` "Work item references", "Sequence allocation", "Templates"; `tests/checks/80-cycle-fixture.sh`. | 0001-recursive-model | docs/artifact-conventions.md, docs/workflow.md, tests/checks/80-cycle-fixture.sh | 0011-recursive-bootstrap/0002-recursive-schema |
| 0003-recursive-writer | Recursive decomposition writer | Give the planning step a recursive writer: generalize the command/agent that enumerates a node's child items so it can author the manifest (`0002`) for a node at any depth, autonomously and without writing child phase artifacts — the writer the superseded plan's one-level `/roadmap` approximated. Whether this becomes `/plan`, `/roadmap`, or a successor command is a design decision owned by `0001`; the scope is the writer and its handoff. Excludes readiness/status (`0004`) and any retirement or migration (a successor roadmap). Evidence: `.opencode/agent/roadmap.md`, `.opencode/command/roadmap.md`, `docs/workflow.md` "Plan publication". | 0001-recursive-model, 0002-recursive-schema | docs/workflow.md, .opencode/agent/roadmap.md, .opencode/command/roadmap.md | 0011-recursive-bootstrap/0003-recursive-writer |
| 0004-recursive-readiness | Readiness, derived state, and status across recursion | Generalize readiness and derived state to recursive trees: how `Depends on` satisfaction works across levels and whether cross-level dependencies are permitted; how a parent node's phase/progress derives from its children (and the reverse); the derived-state table for a recursive node; and `/status`/the `status` agent reporting a tree of arbitrary depth with `ready`/`blocked` at every level. Reuse the shipped readiness algorithm and derived-state vocabulary; define no second state model. Evidence: `docs/workflow.md` "Roadmaps"→"Dependencies and readiness", "Derived state"; `.opencode/agent/status.md`. | 0001-recursive-model, 0002-recursive-schema | docs/workflow.md, .opencode/agent/status.md | 0011-recursive-bootstrap/0004-recursive-readiness |

## Sequencing

1. 0001-recursive-model
2. 0002-recursive-schema
3. 0003-recursive-writer
4. 0004-recursive-readiness

`0001-recursive-model` is the keystone: the recursive vocabulary, the uniform
per-node rule, the mixed-granularity/hybrid decomposition, and the treatment of
depth must be fixed before any schema, writer, or report can be specified.
`0002-recursive-schema` turns the model into references, frontmatter, the
manifest, and per-level allocation. Once `0002` lands, `0003-recursive-writer` (the
recursive writer) and `0004-recursive-readiness` (readiness, derived state,
`/status`) have no unmet prerequisites and may proceed in parallel; they are
ordered `0003`, `0004` here only to keep a stable reading order, since both edit
`docs/workflow.md`.

### Multi-roadmap sequence

This is **Roadmap 1 (bootstrap)**. The successor roadmaps are authored by separate
`/roadmap` invocations after the preceding stage ships, and — once this roadmap's
model is in place — the remainder is re-planned **recursively**:

1. **Roadmap 1 — `0011-recursive-bootstrap` (this).** Deliver the minimal recursive
   facility: model, schema, writer, readiness/status.
2. **Roadmap 2 — Roadmap deprecation and migration.** Retire `/roadmap` and
   `roadmap.md`, replace them with the recursive manifest, and decide the treatment
   of existing roadmap parents (including `0010` and `0011` themselves), preserving
   shipped work and spent numbers.
3. **Roadmap 3 — Simultaneous work under recursion.** Per-level sequence allocation
   and duplicate detection, `conflicts-with` at every level, merge-integrity and
   renumbering for recursive trees, and parallel plan publication.
4. **Roadmap 4 — Agent, command, and inventory surface sweep.** Update every agent,
   command, and the `workflow-lifecycle` skill to the recursive model, and reconcile
   the documented inventories and counts.
5. **Roadmap 5 — Committed recursive-workflow guards.** Fixture-based guards pinning
   the recursive model, references, allocation, readiness, status, and conflicts.

Cross-roadmap ordering is **not** encoded as a dependency (dependencies are
intra-roadmap only); it is recorded here as prose and re-derived when each successor
is authored. Because the model is recursive after Roadmap 1, the successor sequence
is itself expected to be re-planned through recursive decomposition.

## Open issues

- **Superseded plan — `0010-recursive-plan-cycle`.** Its eight children are
  sub-initiatives, not single features, and are withdrawn in favor of this bootstrap
  plan. This create-mode call cannot retire another parent; the sanctioned route is
  `/roadmap revise 0010-recursive-plan-cycle`, which withdraws `0010`'s children from
  its `Children` table and `## Sequencing` (preserving its directory and spent
  numbers) and records the withdrawal under `0010`'s `## Open issues`. Until that
  runs, two plans cover the same initiative; `0010` remains active and the
  duplicate is reported here rather than hidden.
- **`0010`'s child directories are preserved, not deleted.** `0010`'s children
  `0001`–`0008` keep their directories and spent local numbers; the numbers are never
  reused, and this roadmap's own local ids are scoped to `0011`, so there is no
  collision.
- **One artifact per create call.** `/roadmap <initiative>` produces exactly one
  parent roadmap. The multi-roadmap sequence above is realized by later `/roadmap`
  invocations, not by this call — recorded so the staging is explicit rather than
  silently absent.
- **Over-scoping guard.** If a bootstrap child still proves too large when `/spec`
  runs, the product agent's "large enough to be several features" rule applies; the
  sanctioned remedy is `/roadmap revise 0011-recursive-bootstrap` to add siblings at
  the **same** level. Nesting is unavailable today by design, which is the gap this
  initiative closes.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001`→`0002`→{`0003`,`0004`}); no `CYCLIC-DEP` is expected. Recorded because the
  roadmap agent never stores a cycle.
- **Advisory conflicts are intentional.** Several rows declare `docs/workflow.md`
  (and other shared authority surfaces) in `conflicts-with`. The read-only
  declared-conflict check will therefore report `TEXTUAL-CONFLICT` pairs among this
  roadmap's own children; this is intentional — independent siblings that all edit
  the authority doc — and is advisory only, changing no `Depends on` edge and no
  child's readiness.
- **Unresolved user decision — bounded depth.** Whether recursion is unbounded or
  capped, and what happens at the cap, materially changes the model and the schema;
  owned by `0001-recursive-model`/`0002-recursive-schema`.
- **Unresolved user decision — writer surface.** Whether the recursive writer is
  `/plan`, `/roadmap`, or a successor command changes the command inventory and
  `README.md`/`tests/checks/40-inventory.sh`; owned by `0001-recursive-model` and
  implemented by `0003-recursive-writer`.
- **Unresolved user decision — parent/child progress derivation.** How a parent
  node's phase and progress derive from its children (and whether a parent has its
  own lifecycle at all) is owned by `0004-recursive-readiness`.
- **Unresolved user decision — task vs. item granularity.** Whether fine-grained
  `tasks.md` entries stay tasks or become nodes is fixed by `0001-recursive-model`,
  since it decides how far the recursion descends.
- **Possible overlap with shipped work.** `0002`, `0004`, and `0003` extend the
  roadmap schema, readiness, and plan-publication surfaces settled by
  `0002-agentic-roadmaps`, `0003/0002-readiness-ship-state`, `0006`, and `0007`;
  they must extend and reference those decisions, not fork them, keeping
  `tests/checks/10-readiness.sh`, `80-cycle-fixture.sh`, and `85-conflict-guards.sh`
  green.
- **Deliberately out of scope — automatic orchestration.** Driving build/test/review
  across nodes, parallel-agent execution, delivery dates, and scheduling remain out
  of scope, consistent with `0002-agentic-roadmaps`' non-goals; this initiative
  changes the model and artifacts, not the execution model. Recorded here so the
  omission is explicit.
