---
feature: 0002-agentic-roadmaps
phase: spec
status: final
created: 2026-10-04
updated: 2026-10-04
notes: "Scoped through one batched clarifying round. User decisions recorded: plan-only (no orchestration, now or planned); roadmap is a parent work item with nested child work items; dependencies are declared and readiness is surfaced; the roadmap agent authors autonomously but produces no child specs; a new /roadmap command is added while /spec stays single-feature and is taught to address roadmap children."
---

# Agentic multi-feature roadmaps

## Problem

opencode-framework is built around the assumption that a unit of work is a
single feature. A work item is one `work/<NNNN-slug>/` directory, and the
lifecycle produces exactly one spec, one design, one task list, and one
verification for it (`docs/workflow.md:37-46`). The framework also explicitly
treats work items as unrelated: "Items are independent directories and may
proceed in parallel" (`docs/workflow.md:180`). There is no artifact that sits
*above* a spec.

That gap matters to a framework user who wants to add a complex, interdependent
feature set to a project. Today they must either cram several features into one
spec — losing the per-feature discipline the framework exists to enforce — or
plan the decomposition off to the side, holding the feature boundaries, ordering,
and dependencies in their head. When one feature genuinely depends on another,
nothing in the framework records that or warns that a dependent feature is not
ready to start. Finally, the "trickier decision-making" the user wants to hand to
an agent — how to carve a large initiative into features, what depends on what,
and in what order to attack it — has no place to happen and no reviewable output.
The closest prior art is the deferred backlog in
`work/0001-framework-consistency-hardening/spec.md:101-110`, which explicitly put
"full-workflow orchestration" and "parallel-agent development" aside; roadmap
authoring, the planning layer that comes before those, was never specified.

Affected users: framework users planning beyond a single feature, and framework
maintainers who must keep the lifecycle's documented model coherent.

## Goals

- A user can hand a broad, multi-feature initiative to an agent and receive a
  roadmap that decomposes it into individually workable child features with
  explicit interdependencies and a dependency-satisfying order.
- A roadmap is a first-class, reviewable artifact living in the same work tree as
  specs, and the features it defines are real work items that later run the
  existing per-feature lifecycle unchanged.
- For every feature under a roadmap, the framework reports whether it is `ready`
  or `blocked`, and names what blocks it.
- Every existing per-feature phase command works, without semantic change, for a
  feature nested under a roadmap.
- A standalone, non-roadmap feature remains exactly as easy and behaves exactly
  as before.
- The roadmap agent authors roadmaps autonomously and produces no child specs.
- The new capability is documented and counted so the framework's own
  consistency check stays clean.

## Non-goals

- **Executing or orchestrating the lifecycle across items.** The framework will
  not drive build, test, or review for roadmap children automatically. This is
  deliberately out of scope now and is not a planned follow-up (user decision).
- **Parallel-agent execution** of multiple children.
- **The roadmap agent producing child specs** or any phase artifact other than
  the roadmap. Child specs are authored later through the normal spec phase.
- **Cross-roadmap or cross-initiative dependencies.** Dependencies may only
  reference children of the same roadmap.
- **Delivery dates, effort estimates, or scheduling.** A roadmap expresses
  feature boundaries and ordering, not timelines.
- **Automatically revising a roadmap as children complete.** Progress is reported
  through status; changing an existing roadmap is a manual, out-of-scope edit.
- **Changing the per-feature lifecycle.** No phase is added to, removed from, or
  reordered within a single work item's lifecycle.
- **Syncing with external issue trackers or repositories.**
- **New runtime dependencies.** The capability stays within the framework's
  prompt/config-only model, as existing features do.

## Users and stories

- **As a** framework user planning a large initiative, **I want** an agent to
  decompose it into interdependent child features and sequence them, **so that**
  I can delegate the structural planning without giving up reviewability.
- **As a** framework user, **I want** each feature named by a roadmap to be a
  normal work item I can spec, design, build, test, review, and ship on its own,
  **so that** the framework's existing discipline still applies per feature.
- **As a** framework user, **I want** the framework to tell me which features are
  ready to start and which are blocked and by what, **so that** I do not begin
  work whose prerequisites are unfinished.
- **As a** framework maintainer, **I want** the roadmap capability documented and
  counted consistently with the rest of the framework, **so that** its own
  consistency checks keep passing.

## Acceptance criteria

1. **AC1** — Given a broad, multi-feature initiative, when the user invokes the
   roadmap command with that initiative, then a new top-level roadmap work item
   is created under `work/` with the next available sequence number, and a
   roadmap artifact is written for it without requiring a separate approval step.

2. **AC2** — Given a roadmap has been produced, when the user reads it, then it
   identifies the initiative, states the assumptions the agent made, and
   enumerates each proposed child feature with a stable local identifier, a short
   scope description sufficient to author a spec later, and a canonical reference
   by which that child can be addressed.

3. **AC3** — Given a roadmap has been produced, when the work tree is inspected,
   then every enumerated child feature has its own child work item directory
   nested under the roadmap item with a stable local sequence number, and that
   directory contains no phase artifacts (no spec, design, task list,
   verification, or review).

4. **AC4** — Given a roadmap enumerates interdependent features, when
   dependencies are recorded, then each dependency names an existing child of the
   same roadmap, no child depends on itself, and the dependency graph is acyclic;
   if the initiative's dependencies are cyclic, the roadmap reports the cycle as
   an open issue rather than recording an unsatisfiable graph.

5. **AC5** — Given a roadmap with recorded dependencies, when the status command
   is invoked, then it reports every child as `ready` or `blocked`, where a child
   is `ready` if and only if all of its dependencies are satisfied and `blocked`
   otherwise, and for each blocked child it names the specific blocking children.

6. **AC6** — Given a dependency between two children, when readiness is computed,
   then the dependency counts as satisfied only when the depended-on child has a
   review verdict of approve or has been shipped, and a child with no
   dependencies is ready.

7. **AC7** — Given a roadmap containing children at various phases, when the
   status command is invoked, then it reports the roadmap item separately from
   its children and summarizes roadmap progress as the distribution of its
   children across phases, without presenting the roadmap as a single-feature
   item.

8. **AC8** — Given a child work item nested under a roadmap, when any existing
   per-feature phase command is invoked against that child using its canonical
   reference, then the command reads and writes that child's artifacts at its
   nested location, and the per-item phase semantics are identical to those of a
   standalone item.

9. **AC9** — Given a child work item whose dependencies are not yet satisfied,
   when the user moves to start that child (for example, by requesting its spec),
   then the framework refuses to begin and reports the blocking dependencies, and
   beginning anyway requires an explicit user override; refusing never deletes or
   corrupts existing artifacts.

10. **AC10** — Given a roadmap and its children, when status derives each phase
    and each readiness result, then every conclusion is derived from files that
    exist and their contents (there is no separate state file), and the report is
    produced without modifying any file.

11. **AC11** — Given the framework after this change, when a user creates and
    advances a standalone, non-roadmap work item, then its behavior, artifacts,
    and required fields are exactly as before, and no roadmap artifact or
    dependency metadata is required.

12. **AC12** — Given the roadmap command completes, when the resulting changes are
    inspected, then only the roadmap artifact and the child directory structure
    were created; no source files were modified and no child phase work was
    performed.

13. **AC13** — Given the documented inventories of commands, agents, and skills,
    when the roadmap capability is added, then the new command and agent are
    documented wherever comparable items are listed, the stated counts match what
    is on disk, and the framework's existing consistency check reports no new
    drift.

14. **AC14** — Given a roadmap request that is actually a single feature, or that
    is too vague to decompose, when the roadmap command runs, then it either
    recommends the single-feature spec path instead of creating a roadmap, or
    records the assumptions and open questions it used to decompose; it never
    silently invents scope.

15. **AC15** — Given a roadmap references a child that has since been removed or
    renamed, or a dependency names a missing child, when status is invoked, then
    it reports the dangling reference as a finding rather than failing or
    silently ignoring it.

## Edge cases

- **Empty initiative**: the user invokes the roadmap command with no usable
  description. The framework asks for the initiative or declines; it does not
  create an empty roadmap item.
- **Single-feature initiative**: the request decomposes into one feature. The
  framework recommends the normal spec path (AC14) rather than creating a
  one-child roadmap unless the user insists.
- **No decomposable features**: the initiative cannot be broken into independent
  units. The roadmap records this as an open issue rather than fabricating
  features.
- **Self-dependency and cycles**: a child depends on itself, or children form a
  cycle. The roadmap reports the cycle (AC4); status must not report a cycle as
  ready.
- **Dependency on a missing or removed child**: a declared dependency names a
  child that no longer exists. Status reports a dangling reference (AC15).
- **Dependency satisfaction boundaries**: the depended-on child is
  review-request-changes, approved-but-not-shipped, shipped, or has no review yet.
  Only approved or shipped satisfies the dependency (AC6).
- **Blocked start override**: the user overrides a blocked child. Existing
  artifacts are untouched, and status still reports the dependency state so the
  override is visible.
- **Numbering collisions**: a new roadmap's top-level number collides with an
  existing item, or a child's local number collides within its parent. The next
  free number is used in each scope (top-level and per-parent), independent of
  other roadmaps.
- **Empty work tree**: `work/` contains no items. Creating the first roadmap
  succeeds and status handles the new hierarchy.
- **Coexistence with flat items**: a standalone item created before or after this
  change lives alongside roadmap parents and children without interference
  (AC11).
- **Concurrent activity**: status may run while children are being edited; being
  read-only, it must not corrupt or lock anything (AC10).
- **Large roadmap**: an initiative decomposing into many children still produces a
  readable roadmap and a correct readiness report.
- **Duplicate initiative**: a roadmap is requested for an initiative already
  represented by a roadmap or a standalone item. The framework surfaces the
  possible duplicate rather than silently creating a second one.

## Open questions

Decisions already made with the user are recorded here as resolved; the remaining
items are design-level and belong to `/plan`.

- [x] **Capability boundary** — resolved with the user: plan only. The roadmap
  agent produces a roadmap and child directory structure; it does not produce
  child specs and does not orchestrate the lifecycle. Orchestration is not a
  planned follow-up.
- [x] **Work-item hierarchy** — resolved with the user: a roadmap is a parent work
  item at `work/<NNNN-slug>/`, and its children are nested work items at
  `work/<NNNN-slug>/<MMMM-slug>/`.
- [x] **Readiness model** — resolved with the user: dependencies are declared and
  status reports `ready`/`blocked`; a dependency is satisfied when the
  depended-on child is review-approved or shipped (AC6).
- [x] **Autonomy** — resolved with the user: the roadmap agent authors the
  roadmap autonomously (no pre-write approval gate) but writes no child specs;
  the artifact is reviewed after the fact.
- [x] **Invocation** — resolved with the user: a new roadmap command is added; the
  existing single-feature spec command is unchanged in purpose but taught to
  address a child nested under a roadmap (AC8).
- [x] **Scope** — resolved with the user: one work item covering roadmap
  authoring, the dependency model, and readiness surfacing.
- [ ] **Canonical reference syntax** for addressing a child across phase
  commands (parent plus child identifier) — owner: architect, needed by:
  `/plan`. The spec fixes only that a stable canonical reference exists and is
  accepted by the phase commands; the exact spelling is a design decision.
- [ ] **Roadmap artifact frontmatter/phase value** and how nested child frontmatter
  records its parent — owner: architect, needed by: `/plan`. Must remain
  consistent with `docs/artifact-conventions.md`.
- [ ] **Whether a blocked child's start is a hard refusal or a warning requiring
  explicit override** — owner: user, needed by: `/plan`. The spec fixes that an
  explicit user override is required (AC9); the exact interaction is design.

## Dependencies and constraints

- **Prompt/config-only product**: this capability is delivered as framework
  agents, commands, skills, and documentation, with no installed runtime
  dependency, matching the rest of the framework (`README.md:1-9`).
- **Documentation duplication**: inventories and lifecycle facts are restated
  across `README.md`, `AGENTS.md`, `docs/workflow.md`, and
  `docs/artifact-conventions.md`. All copies must stay consistent, and the
  framework's consistency diagnostic must remain clean (AC13).
- **Derived state**: phase is derived from existing artifacts, never a state file
  (`docs/workflow.md:145-163`). Roadmap and readiness derivation must follow the
  same rule (AC10).
- **Permissions and ignores**: nested work paths already fall under the
  artifact-write permission patterns (`work/**` and `**/work/**`) and the
  `work/*` ignore rule (`docs/customization.md:107-125`, `.gitignore:7-8`); no new
  grant is implied by nesting. The design must confirm this and document any
  consequence.
- **Backward compatibility**: existing flat work items and the standalone
  lifecycle keep working unchanged (AC11); no migration is required for existing
  `work/` content.
- **Artifact ownership**: this phase writes only
  `work/0002-agentic-roadmaps/spec.md`; no other phase's artifact may be edited.
- **No commits**: per `AGENTS.md`, no commit, push, or PR occurs during this work
  item.
- **opencode version**: targets opencode 1.18+ as stated in `README.md:29`.

## Assumptions

- The roadmap command creates the child work-item directories at plan time,
  reserving their numbers, and leaves them empty of phase artifacts for the
  normal spec phase to fill later.
- A roadmap parent item holds only the roadmap artifact; it is not itself a
  single-feature item and has no spec, design, tasks, verification, or review of
  its own.
- Child feature numbering is local to its parent roadmap and independent of other
  roadmaps and of the flat top-level sequence.
- Dependencies are meaningful only within a single roadmap.
- The roadmap agent may ask a single batched round of clarifying questions when
  an initiative is too ambiguous to decompose, but is expected to proceed
  autonomously and record assumptions otherwise (AC14).
