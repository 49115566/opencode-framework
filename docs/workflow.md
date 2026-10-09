# Workflow

This document is the authoritative description of the development lifecycle for
projects using this framework. `AGENTS.md` summarizes it; this file is the
source of truth. If the two disagree, this file wins and `AGENTS.md` should be
corrected.

## Mental model

A **work item** is one unit of change — a feature, a behavior change, or a
sizable bug. Each work item gets a directory under `work/` and moves through six
phases. Each phase consumes the previous phase's artifact and produces its own.
Nothing is implicit: the repository's committed `work/` directory plus the code
diff is the complete state of the work, visible to a fresh clone, a teammate,
and CI.

```
/spec ──▶ spec.md ──▶ /plan ──▶ design.md + tasks.md ──▶ /ship plan ──▶ merge ──▶ /build ──▶ code + [x] tasks
                                                                                  │
                              /ship ◀── review.md ◀── /review ◀── verify.md ──────┤ (/test)
                                                                                  └─ visual.md (/visual, optional, UI only)
```

A work item is *done* when its PR is open (or merged) and `review.md` records an
approving verdict. The lifecycle stops at "reviewable PR"; merging and
deployment are human decisions owned by the user and CI.

## The work item directory

```
work/
  0001-add-dark-mode/          # standalone work item
    spec.md       # requirements            (product)
    design.md     # technical design        (architect)
    tasks.md      # ordered, checkable work (architect; builder ticks boxes)
    verify.md     # test evidence + gaps    (tester)
    review.md     # findings + verdict      (reviewer)
  0002-billing/                # roadmap parent work item
    roadmap.md    # initiative + children   (roadmap)
    0001-model/   # nested child work item
      spec.md     # requirements            (product)
      ...
    0002-api/     # nested child work item
      spec.md
      ...
```

- `NNNN` is the next zero-padded sequence number across the whole `work/` tree.
  Allocate it by finding the highest existing directory name and adding one.
- `slug` is a short kebab-case handle derived from the request (e.g.
  `add-dark-mode`). Prefer 2–4 words. It is immutable once created.
- A **canonical reference** is an item's path relative to `work/`: `NNNN-slug`
  for a standalone item, or `NNNN-slug/MMMM-slug` for a nested roadmap child.
  Phase commands accept either form; a one-segment reference behaves exactly as
  before. See "Roadmaps" for the nested layout.
- Workflow artifacts under `work/` are committed working state:
  version-controlled so a fresh clone, a teammate, and CI derive the same
  phase. Only `scratch/` and opencode's generated state are ignored.
- A phase may be skipped only by explicit user request. If skipped, say so in
  the next artifact's frontmatter `notes`.

## Roadmaps

A **roadmap** is a parent work item that plans a broad, multi-feature initiative
before any child is specified. It lives in the same tree as ordinary items: the
parent directory `work/<NNNN-slug>/` holds a single `roadmap.md` and one nested
child work-item directory per feature, `work/<NNNN-slug>/<MMMM-slug>/`. The
parent has no spec, design, tasks, verification, or review of its own; each child
later runs the ordinary per-feature lifecycle unchanged. Artifact shapes and the
reference grammar are defined in `docs/artifact-conventions.md`.

The `/roadmap` command authors the parent artifact and creates each child
directory containing only a `.gitkeep`, then stops. It writes no child specs and
performs no child phase work. Child numbering is local to the parent and
independent of the flat top-level sequence and of other roadmaps.

### Dependencies and readiness

The `Children` table in `roadmap.md` is the single machine-readable source for
the child set and the dependency graph. The `Depends on` cell holds another
child's **local id**, comma-separated when there are two or more, or `—` when the
child has none. A dependency may not name its own row, dependencies are
intra-roadmap only, and the stored graph must be acyclic. If an initiative's
dependencies are cyclic, the roadmap records the cycle under `## Open issues` and
leaves the stored graph acyclic.

Readiness is derived live from files at status time; it is never stored:

```
satisfied(dep_local_id):
  child_dir = work/<parent>/<dep_local_id>/
  if child_dir does not exist        -> dangling; not satisfied
  if child_dir/ship.md exists
       and it carries a `reopened:` marker -> not satisfied  # recalled; shipped signal revoked
  if child_dir/ship.md exists        -> satisfied        # shipped; presence is the sole shipped signal
  if child_dir/review.md exists
       and its verdict == "approve"  -> satisfied        # approved, even if unshipped
  otherwise                          -> not satisfied

ready(child)      = every dependency of child is satisfied AND child is not in a cycle
blocked_by(child) = [dep_local_id for each unsatisfied dependency]
```

A child with no dependencies is `ready`. A dependency is satisfied when its child
directory contains `ship.md` — its presence is the sole shipped signal, keyed on
presence rather than contents — or when its `review.md` verdict is `approve`, which
satisfies the dependency **even if unshipped**. `ship.md` presence takes precedence
over a `request-changes` verdict; a `request-changes` verdict or a missing
`review.md` (with no `ship.md`) is not satisfied.
A non-recalled `ship.md` presence and an `approve` verdict satisfy exactly as
before. A **recalled** item — its `ship.md` carrying a `reopened:` marker — does
not satisfy the dependency, and its dependents are reported `blocked`, naming the
recalled item as the unsatisfied dependency, until it re-ships; the revocation is
defined by `### Shipped items and reopen`.
A child in a cycle is never `ready`.

### Declared conflicts (`conflicts-with`)

A **planning-time conflict** is a *declared, committed claim* by one plan that it
expects to collide with one or more targets. It is plan state recorded before
development, not a detected collision: it is distinct from the merge-time
`## Merge conflicts` contract, which acts on branches after they exist, and
distinct from `Depends on`, which is a readiness edge. A declaration is advisory —
it adds, removes, or reorders no `Depends on` edge and changes no child's
readiness; only `Depends on` gates readiness. A pair is a declared conflict when
at least one side names the other, so a declaration does not require a reciprocal
declaration.

The `Children` table carries the declaration in a `conflicts-with` column. The
same grammar defines the intended conflict set of a child or standalone work item;
that grammar is independent of where such an item's declaration is stored. A
roadmap authored before the column existed has no `conflicts-with` column, and its
absence is treated as no declared conflicts (`—` for every row).

A child or standalone item's own declaration is stored in its `design.md`
frontmatter `conflicts-with` value; the field is optional and holds one
`ConflictTargetList`, the grammar defined below. Absence of the field or a `—`
value means no declared conflicts, and no separate container or artifact is
required. A roadmap child's declared set is the **union** of that `design.md`
value and its parent `Children` row's `conflicts-with` cell; when the two
disagree, the later read-only check reports the disagreement rather than silently
preferring one. A malformed or unresolved item value is likewise reported by the
later check, never dropped or auto-repaired. The declaration is advisory: it adds
no readiness edge, reorders no child, and changes no child's readiness.

A `conflicts-with` cell holds one `ConflictTargetList`:

```
ConflictTargetList ::= "—"                              # no declared conflicts
                    | ConflictTarget ("," ConflictTarget)*

ConflictTarget     ::= SiblingOrItemRef | SurfacePath
SiblingOrItemRef   ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )?
SurfacePath        ::= repository-relative file or directory path
```

- **Three target kinds.** Each target is exactly one of: an **intra-roadmap
  sibling local id** (`MMMM-slug`) naming a different row in the same `Children`
  table; a **canonical work-item reference** — a top-level `NNNN-slug` (including a
  roadmap parent) or a nested `NNNN-slug/MMMM-slug` — resolving to `work/<ref>/`;
  or a **repository-relative surface path**, an exact file or directory path (for
  example `docs/workflow.md`, `tests/checks`). Surface paths are exact: no glob
  metacharacters, no `..`, no absolute paths.
- **Separation and empty value.** Targets are comma-separated and each is trimmed
  of surrounding whitespace. Repository paths and references contain no comma, so
  a comma always separates targets. A cell that is `—` (em dash, the same
  convention as `Depends on`) declares no conflicts; an empty or whitespace-only
  cell is malformed, not equivalent to `—`.
- **Reference-vs-path discriminator.** A target matching
  `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$` is a reference (a sibling local id
  or a canonical work-item reference); any other target is a surface path. For a
  reference with no `/`, resolution precedence is the **sibling row in the same
  table first, then `work/<token>/`**, so a bare `MMMM-slug` is deterministic when
  a sibling row and a top-level item could share the same text.
- **Well-formedness.** A reference may not name the declaring row's own local id
  (no self-reference), and a list may not repeat a target after trimming.
- **Unresolved declarations.** A malformed cell, or a target that resolves to no
  sibling row, no `work/<ref>/` directory, and no existing path, is an
  **unresolved declaration**. It is reported by a later read-only check and never
  silently dropped or auto-repaired.
- **Reporting vocabulary is reused.** A declared conflict, when reported, uses the
  shipped `(a)`–`(d)` class labels and the finding-line grammar defined in
  `## Merge conflicts` and `.opencode/skill/merge-conflict/SKILL.md`. There is no
  new class, finding code, or policy defined for declarations.

### Status reporting

`/status` reports a roadmap parent separately from its children. The roadmap row
shows `<ready>/<total> ready` plus a distribution tally of its children across
phases (`<phase> <n>, ...`), so a roadmap is never presented as a single-feature
item. Each child row shows its own phase and readiness; a blocked child names the
specific children blocking it. Status is read-only and modifies nothing.

Status also reports integrity findings rather than failing:

- `DANGLING-DEP` — a `Depends on` local id with no child directory or no table row.
- `MISSING-CHILD` — a table row whose canonical reference/directory is absent.
- `UNLISTED-CHILD` — a child directory present under the parent but absent from the Children table (possible rename). When the parent's `## Open issues` names that directory as a withdrawn child, it is a **deliberate withdrawal**: reported report-only and never auto-repaired, not treated as an accidental graph fault.
- `CYCLIC-DEP` — a cycle in a manually edited graph; cycle members are never reported ready.

### Starting a blocked child

When `/spec` is invoked for a nested child, the product agent resolves the parent
`roadmap.md` and evaluates readiness first. If the child is blocked, it reports
the specific blocking children and stops before writing `spec.md`. It proceeds
only on an explicit user override, and then records the override and the blocking
dependencies in the new `spec.md` frontmatter `notes`. Refusing touches no
existing file, and status still reports the child's dependency state afterwards.

### Revising a roadmap

The `/roadmap` command has two modes: `/roadmap <initiative>` authors a new
parent (above), and `/roadmap revise <item-ref>` revises an **existing** parent in
place. `<item-ref>` must resolve to `work/<item-ref>/roadmap.md`; a reference that
is not a roadmap parent is refused, because the revise mode revises a parent and
never creates one. The **roadmap agent is the sole writer of the parent
`roadmap.md`**: a child phase that discovers the parent is wrong records a finding
in its own committed `backtracks.md` (below, and `## Phase reversal
(backtracking)`) and recommends the revise route; it never edits the parent. The
revision writes autonomously, with no pre-write approval gate, exactly as the
create mode does; the user reviews the committed revision after the fact. A
revision request that changes nothing is a no-op and modifies no file.

A revision applies four operations to the loaded parent, in one pass, and
validates the result **after all four** (never on an intermediate state):

1. **Re-scope** — replace an existing row's `Title` and/or `Scope` in place. The
   row's `Local id`, child directory, and `Canonical reference` are preserved.
2. **Add** — append a row for a newly enumerated feature. Its `Local id` is the
   next local number: the greatest 4-digit `MMMM` prefix **ever committed** under
   `work/<parent>/` plus one, per `docs/artifact-conventions.md` → "Sequence
   allocation" applied within the parent. A spent number is never reused. Create
   `work/<parent>/<MMMM-slug>/.gitkeep`, and set the row's `Canonical reference`
   to resolve to that directory.
3. **Withdraw** — remove the row from the `Children` table and from
   `## Sequencing`. The child's directory and spent local number are **preserved**
   (the number is never reused). Record the withdrawal and its rationale under the
   parent's `## Open issues`, naming the retained directory; the record shape is in
   `docs/artifact-conventions.md` → the `roadmap.md` template. A withdrawal does
   not mark the child stale — it leaves the active set.
4. **Re-sequence** — edit `Depends on` cells as required and rewrite
   `## Sequencing` as a topological order of the stored graph, so every child
   follows all of its dependencies.

After all four operations, the revision runs one validation predicate over the
final state and **stores no fault**:

- every `Depends on` token names another row's `Local id` in the same `Children`
  table, and no row depends on itself;
- the stored graph is acyclic;
- every row's `Canonical reference` resolves to an existing child directory, and
  every active child directory (all child directories except recorded withdrawals)
  appears as a row;
- `## Sequencing` lists every active child after all of its dependencies;
- the six-column `Children` header is unchanged — `Depends on` stays at pipe-field
  5 and `conflicts-with` at pipe-field 6 — and every `conflicts-with` cell is `—`
  or a well-formed target list.

If the intended dependencies would create a cycle, the revision stores no cyclic
edge, leaves the stored graph acyclic, and records the cycle under
`## Open issues`. If an operation would leave a dependency dangling — for example
withdrawing a child another child depends on — the revision does not silently
choose a resolution: it either applies the re-point or withdrawal that removes the
dangling edge in the same revision, or refuses and reports the ambiguous intent.

An existing unshipped child is **affected** when the revision changes any cell of
its `Children` row (`Title`, `Scope`, `Depends on`, `conflicts-with`) or
explicitly re-sequences it. For each affected existing unshipped child, the
revision marks each present phase artifact (`spec.md`, `design.md`, `tasks.md`,
`verify.md`, `review.md`) `stale: roadmap`, per `## Phase reversal (backtracking)`;
nothing is deleted or silently rewritten, and the pre-revision content stays
recoverable from committed git history. `stale: roadmap` maps to `spec` when the
child's phase is derived, so the child must re-run forward. A child holding only
`.gitkeep` marks nothing and simply derives `not started`; an unaffected child is
untouched.

A **shipped** child — its `ship.md` present — is excluded from a backtrack by the
model above. A revision that would re-scope or re-sequence a shipped child
**refuses and surfaces** the conflict for the user rather than rewriting the
shipped child's artifacts; the post-ship path is `0005-post-ship-pr-denial`.

A revision records its provenance in committed state. The triggering child's
detecting phase appends a finding entry to `work/<child-ref>/backtracks.md` — a
target phase of `roadmap` (the `stale` token), the affected
`work/<parent-ref>/roadmap.md`, observable evidence, and status `open` — and, when
the revision completes, the roadmap agent appends the matching resolution entry
naming what changed. `backtracks.md` is item-level backtrack state, not a phase
artifact, so appending it does not breach the ownership invariant; the roadmap
agent appends only this entry and writes no child phase artifact. The parent
`roadmap.md` changes its frontmatter `updated` date and appends a revision note
under `## Open issues` naming the date, the triggering child, the operations
applied, and the invalidated children. The pre-revision roadmap remains
recoverable from committed git history. The entry shapes are in
`docs/artifact-conventions.md` → "`backtracks.md`" and the `roadmap.md` template.

## Phases

Each phase below lists: **Purpose**, **Entry criteria**, **Process**,
**Exit criteria**, **Artifact**, **Next**.

### 1. Requirements — `/spec <feature or problem description | item-ref>`

- **Purpose**: Convert an informal request into a precise, testable,
  implementation-free specification.
- **Entry**: A request from the user. No `spec.md` required.
- **Process**: Recon the repo for domain context → surface ambiguities → ask the
  user batched clarifying questions → write the spec. Details in the `product`
  agent prompt and the `spec-writing` skill.
- **Exit**: `spec.md` has a problem statement, goals, non-goals, at least one
  user story, and numbered acceptance criteria in Given/When/Then form. Open
  questions are either resolved or explicitly marked as deferred.
- **Artifact**: `work/<item-ref>/spec.md`, frontmatter `phase: spec`.
- **Next**: `/plan <item-ref>`. If `/plan` finds this spec ambiguous or wrong, it
  takes the `/plan`→`/spec` reverse edge (see "Phase reversal (backtracking)");
  the finding's handoff routes the item back here to re-run `/spec <item-ref>`
  and revise `spec.md`.

### 2. Design — `/plan <item-ref>`

- **Purpose**: Decide *how* to satisfy the spec and decompose the work into
  independently verifiable tasks.
- **Entry**: `spec.md` exists and is unambiguous.
- **Process**: Read `spec.md` → recon existing architecture and conventions →
  evaluate at least one alternative → write `design.md` → decompose into
  `tasks.md`. Details in the `architect` agent prompt.
- **Exit**: `design.md` names the approach, the alternatives considered, the
  interfaces/data model affected, and the risks. `tasks.md` is an ordered list
  where every task is small (roughly one focused commit), has its own
  verification, and declares dependencies. Every acceptance criterion in
  `spec.md` maps to at least one task.
- **Artifact**: `design.md` and `tasks.md`, frontmatter `phase: design` and
  `phase: tasks` respectively.
- **Next**: `/ship plan <item-ref>` to publish the plan (see
  "Plan publication"); then `/build` once the plan is merged. A denied or
  changes-requested `plan/<ref>` pull request routes back here to re-run
  `/plan <item-ref>` and republish — never a force-push, and not a backtrack.
  If the spec is ambiguous or wrong, take the `/plan`→`/spec` reverse edge and
  hand off `Next: /spec <item-ref>` (see "Phase reversal (backtracking)").

### 3. Build — `/build [item-ref or task-id]`

- **Purpose**: Implement the tasks.
- **Entry**: `tasks.md` exists with unchecked items, and the plan is published —
  see the `/build` plan gate in "Plan publication". An unmerged `plan/<ref>`
  branch blocks development; an item with no publication recorded (historical or
  pre-flow) proceeds with a note.
- **Process**: Read `spec.md`, `design.md`, `tasks.md` → select the requested
  task or the next unblocked unchecked task → implement following existing
  conventions → run the project's checks → tick the box in `tasks.md`.
- **Exit**: Each completed task's check box is `[x]`, its acceptance is
  demonstrably met, and the project's lint/typecheck/tests pass for the touched
  scope. Do **not** commit.
- **Artifact**: source changes plus `tasks.md` with updated check boxes.
- **Next**: `/build` again for more tasks, then `/test` when all boxes are
  checked. If the design is wrong, take the `/build`→`/plan` reverse edge and
  hand off `Next: /plan <item-ref>` (see "Phase reversal (backtracking)"); the
  task stays unchecked and the design is revised by its owner.

### 4. Test — `/test [item-ref]`

- **Purpose**: Independently verify the implementation against the acceptance
  criteria and close coverage gaps.
- **Entry**: All tasks are checked, or the user asks for verification.
- **Process**: Read `spec.md` and `tasks.md` → map every acceptance criterion to
  a test → run the suite → write missing tests → record results and residual
  risk in `verify.md`.
- **Exit**: Every acceptance criterion is covered by at least one passing test
  or is explicitly flagged as manual/untestable with a reason. Failures are
  reported, not hidden.
- **Artifact**: test files plus `work/<item-ref>/verify.md`, frontmatter
  `phase: test`.
- **Next**: `/review`. If defects were found, classify each one: an implementation
  defect routes to `/build` to fix it first, while a defect that is really a spec
  or design fault is routed upstream through the backtrack model — take the
  `/test`→`/plan` or `/test`→`/spec` reverse edge (recorded `backtracks.md`
  finding, downstream `stale:` markers, `Next: /plan <item-ref>` or
  `Next: /spec <item-ref>`). If the classification is unresolved, escalate rather
  than guess and do not push the item at the wrong phase.
- **Optional visual pass**: if the work item has a user-facing UI, run `/visual`
  (or have the tester delegate to the `visual` subagent). It drives a real
  browser, produces `work/<item-ref>/visual.md` plus screenshots, and feeds its
  findings into review. It is optional so that non-UI projects never need a
  browser; when present, review must consider it.

### 5. Review — `/review [item-ref]`

- **Purpose**: A skeptical, read-only pass over the diff against the spec and
  project standards.
- **Entry**: Tests pass and `verify.md` exists.
- **Process**: Determine the base ref → read the diff → check correctness,
  security, tests, conventions, scope, and performance → write severity-ranked
  findings with `file:line` references and a verdict.
- **Exit**: `review.md` states a verdict of `approve` or `request-changes`, and
  every finding has a severity, a location, and an actionable recommendation.
- **Artifact**: `work/<item-ref>/review.md`, frontmatter `phase: review`.
- **Next**: `/ship` if `approve`; otherwise `/build` to address blockers.

### 6. Ship — `/ship [item-ref]`

- **Purpose**: Turn a reviewed work item into a reviewable pull request.
- **Entry**: `review.md` exists with verdict `approve` (or the user explicitly
  overrides), and the item is not **challenged** — an open challenge in
  `challenges.md` blocks it (see `## Findings challenge and adjudication`).
- **Process**: Reconcile first — if the branch has fallen behind the default
  branch, merge it forward and resolve conflicts per `## Merge conflicts` →
  confirm checks are green and the tree contains no secrets →
  create a branch → stage logical commits with conventional messages →
  (user-approved) push → open a PR with a structured body linking the artifacts →
  write `ship.md` recording the branch, commits, and PR (or "not created"), commit
  it (`docs(work): record ship state for <item-ref>`), and push so the shipped
  signal travels with the branch.
- **Recall mode**: `/ship recall <item-ref> <phase>` handles a post-ship denial by
  revoking the shipped signal and re-entering the named phase; see
  `### Shipped items and reopen`.
- **Exit**: PR URL reported to the user, or — when `gh` is unavailable — the
  local-commit path recorded in `ship.md`; the branch carries a committed
  `ship.md` and the run leaves no uncommitted `ship.md`. Nothing is merged by the
  agent.
- **Artifact**: branch, commits, PR, and `ship.md` recording the shipped signal
  (branch, commits, and PR URL). Presence of `ship.md` is the shipped signal; see
  "Dependencies and readiness".
- **Next**: Human review and merge. `/status` will show the item as shipped.

## Plan publication

A work item's **plan** is its committed requirements and design artifacts —
`work/<item-ref>/spec.md`, `design.md`, and `tasks.md` when present. The plan is
published to the shared default branch before development begins so other
maintainers can cross-reference intended surfaces before any code exists. It is a
process step, not a lifecycle phase: it adds no artifact, no `phase` value, and
no derived-state row.

Publication is a **mode of `/ship`** — `/ship plan <item-ref>` — performed by the
shipper, the only agent that writes git (see `AGENTS.md` → guardrails). Plan mode:

- **Preconditions.** `work/<item-ref>/spec.md` and `design.md` exist (the item has
  completed `/plan`; `tasks.md` is included when present). No `review.md` is
  required — plan mode is a documented exception to the approved-work-item entry
  criterion, like fix mode. The plan diff contains no secrets.
- **Branch.** A dedicated `plan/<ref>` branch, where `<ref>` is the canonical
  reference with `/` replaced by `-` (for example
  `plan/0006-parallel-plan-conflicts-0002-plan-record`). Each item gets its own
  branch, so concurrent publications do not overwrite one another, and the plan
  branch is distinct from the item's final ship branch.
- **Commit and pull request.** The plan artifacts under `work/<item-ref>/` are
  committed as one conventional commit and pushed; a pull request is opened with
  the plan description template. The PR links the plan artifacts by repository
  path and prints the item's declared conflicts, or `—`.
- **Approval and merge.** At least one human approval is required before the plan
  pull request is merged (a process precondition the framework documents but does
  not verify offline). The shipper neither approves nor merges; the merge is a
  human action, and the repository may enforce approval via branch protection.
- **No shipped state.** Plan mode never writes `ship.md`, never runs the ship
  pre-flight or reconcile, and never creates the final ship branch or pull request.
  `ship.md` remains the sole shipped signal.
- **Revision.** When a later `/plan` revision changes the intended surfaces or
  declared targets, it is republished through the same flow: a commit is added to
  the existing `plan/<ref>` branch and its pull request updated (or a new one
  opened if the branch was pruned). A pushed branch is never force-pushed.
- **Denied or changes-requested pull request.** When a `plan/<ref>` pull request
  is denied, closed, or sent back for changes, the documented route is to re-run
  `/plan <item-ref>` to revise the plan and republish with
  `/ship plan <item-ref>`. Publication adds a commit to the existing `plan/<ref>`
  branch and updates its pull request (or opens a new one when the branch was
  pruned) — never a force-push. This round trip is the plan-publication
  **revision** flow, explicitly **not** a backtrack: it writes nothing to
  `backtracks.md` and moves no phase backward.
- **Idempotence.** Re-invoking publication when the plan is already on the default
  branch and unchanged is a no-op: it reports that and creates nothing.

### The `/build` plan gate

Development does not begin while a plan pull request is unmerged. Before
selecting a task, the builder runs an offline-first, git-only gate — it requires
no `gh` and never hard-fails:

```
plan_gate(item_ref):
  ref         = item_ref with "/" -> "-"
  plan_branch = "plan/" + ref
  default_ref = "origin/<default>" if origin exists, else "<default>"
  # 0. Refresh refs best-effort (an offline fetch is ignored). Refresh the
  #    default branch, and the plan branch too when the remote advertises one,
  #    so the comparison below sees a later revision and a retained, already-
  #    merged branch is not mistaken for an unmerged one.
  remote_plan = false
  if origin exists:
      git fetch origin <default>
      remote_plan = git ls-remote --heads origin plan/<ref> returns a ref
      if remote_plan: git fetch origin plan/<ref>
  # Resolve the plan branch (remote first, then local) and flag it unmerged when
  # its plan artifacts differ from the default branch — a first publication or a
  # later revision. Branch existence alone is not enough, because a merged plan
  # branch may be retained. A ref the remote advertises but that does not resolve
  # locally cannot be compared, so it is refused rather than read as matching or
  # differing.
  plan_ref = none
  unmerged_plan = false
  unresolved_plan = false
  if remote_plan and origin/plan/<ref> resolves:
      plan_ref = "origin/plan/<ref>"
  elif a local branch plan/<ref> exists:
      plan_ref = "plan/<ref>"
  elif remote_plan:
      unresolved_plan = true
  if plan_ref is not none:
      unmerged_plan = git diff --quiet <plan_ref> <default_ref> -- work/<item_ref>/ is false
  # 1. Published / merged? (a differing plan branch is not yet published)
  if <default_ref> has work/<item_ref>/design.md
     and not unmerged_plan and not unresolved_plan                  -> PROCEED
  # 2. An unmerged plan branch — or one the remote advertises but that cannot be
  #    resolved and compared — blocks development
  if plan_ref is not none or unresolved_plan                         -> REFUSE
  # 3. No publication recorded (historical / pre-flow item)
  otherwise                                                          -> PROCEED (note it)
```

- Step 0 refreshes refs best-effort before the default-branch check: it fetches
  `origin/<default>`, and the `plan/<ref>` branch too when the remote advertises
  one, so a plan merged since the last fetch is seen even when the local
  `plan/<ref>` branch was retained and a later revision is not hidden by a stale
  remote-tracking ref. The refresh is ignored when `origin` is unreachable.
- An unmerged `plan/<ref>` branch (case 2) refuses development: the builder stops
  before implementing and reports the plan branch or pull request that must be
  merged first.
- Case 2 is content-aware, not mere branch existence: a `plan/<ref>` branch whose
  plan artifacts differ from the default branch — a first publication **or a
  later revision** — refuses development; a retained branch whose plan artifacts
  already match the default branch (a merged publication) does not. An unmerged
  revision therefore blocks development even after the first plan merged.
- An item with no plan pull request — historical, or created before this flow —
  is not blocked and needs no migration; the builder proceeds and notes that no
  plan publication was found (case 3).
- A plan present on the default branch proceeds even if a merged `plan/<ref>`
  branch is retained, because step 0 refreshes the ref and step 1 treats a
  branch whose plan artifacts already match the default branch as merged, not
  unmerged (case 2 is content-aware).
- A `plan/<ref>` branch the remote advertises but that has no resolvable local
  ref — for example when the best-effort fetch of it fails — cannot be compared,
  so the gate refuses rather than read it as matching or differing.
- An unreachable `origin` degrades to the best-effort result and never hard-fails
  the build.

The declaration remains advisory throughout: it adds no readiness edge, reorders
no child, and changes no child's readiness. The declared-conflict grammar and its
resolution rules are the single authority in "Declared conflicts
(`conflicts-with`)"; a plan's declaration home is the `design.md` frontmatter
`conflicts-with` value.

## Declared-conflict check

The `conflicts-with` declarations of the unshipped plans under `work/` are
compared by one read-only check whose algorithm is stated once here. Every other
surface — the `/conflicts` command, the `/status` report, and the `/build` plan
gate — references this section and restates nothing. Like the merge-integrity
guard, the check is **prompt behavior only**: there is **no committed checker,
script, helper, or executable tool** for it and **no committed fixture or
agreement area**; fixture-based guards and mutation coverage are a separate work
item.

### The compared set

The check reads only committed `work/` state and the local repository (for target
resolution). It considers every **unshipped item** under `work/` — a roadmap
child or a standalone item — and derives that item's **declared set**:

- **Roadmap parent** — never an entity itself; it is a container. Its `Children`
  table supplies each row's declaration. A roadmap authored before the
  `conflicts-with` column existed has no column, treated as `—` for every row.
- **Roadmap child** — one entity per `Children` row, even when the child
  directory holds only `.gitkeep` (the parent cell still represents it). A child
  whose `work/<parent>/<local-id>/ship.md` exists is **excluded**; a child with no
  `ship.md` is included.
  - `own` is the child's `design.md` frontmatter `conflicts-with` (absent or `—`
    → empty); `cell` is the row's `conflicts-with` cell (absent column or `—` →
    empty).
  - The child's declared set is `own ∪ cell`.
  - When `own` and `cell` are **both present** (neither `—`) and the two sets are
    **not identical** — a subset relationship still counts — the check reports
    the discrepancy (`DRIFT-FACT`, below) and prefers neither. A one-sided record
    is the union and is not a discrepancy.
- **Standalone item** — one entity per top-level item directory that is not a
  roadmap parent and has a `spec.md`. Its declaration is its `design.md`
  frontmatter `conflicts-with`. A `ship.md` excludes it.

An item with an empty declared set — absent field, absent column, or `—` —
contributes no declared target of its own, so it yields no finding **from its own
declaration** and historical items remain valid with no migration. It is still an
unshipped item: a declared target that names it is a counterpart under the
one-sided naming clause below, even though the named item declares nothing. A
**shipped** item still **resolves** as a target but is not a counterpart: naming
it produces neither a conflict nor an unresolved finding.

Each target token is resolved with the single algorithm in "Declared conflicts
(`conflicts-with`)" above — the reference-vs-path discriminator, the sibling-first
precedence for a bare `MMMM-slug`, exact repository-relative surface paths, and
the prohibition on glob metacharacters, `..`, and absolute paths. A reference
token resolves to a canonical item reference (a sibling row's
`<parent>/<local-id>` or a `work/<NNNN-slug>[/<MMMM-slug>]/` directory); a surface
token resolves to its repository-relative path. A token that is malformed (empty
or whitespace-only, a glob metacharacter, `..`, or absolute) or that resolves to
no sibling row, no `work/<ref>/`, and no existing repository path is an
**unresolved declaration**: it is reported (`DANGLING-DEP`, below) and never
dropped or auto-repaired.

### The pair predicate

`conflict(A, B)` is evaluated between any two **unshipped items** `A` and `B` and
is true exactly when one of:

1. **Shared target** — some target of `A` and some target of `B` are the same
   target. Two targets share identity when their trimmed repository-relative
   paths are equal (surface targets) or when both resolve to the same canonical
   item reference (reference targets). Equal trimmed tokens that resolve to
   *different* items — for example the same `MMMM-slug` in two different roadmaps
   — are **not** the same target.
2. **One side names the other** — a target of `A` resolves to `B`'s canonical
   reference, or a target of `B` resolves to `A`'s. A one-sided declaration
   suffices; no reciprocity is required. The named item need not declare anything
   itself: an unshipped item with an empty declared set is still a counterpart
   under this clause, so a declaration that names it is reported even though that
   item contributes no target of its own.

Each unordered pair is reported **once**: reciprocal naming, or a pair that both
shares a target and names the other, yields exactly one finding. The finding list
is never truncated; repeated runs on unchanged plans yield identical findings;
concurrent runs take no lock and write nothing.

### Findings

Findings use the shipped finding-line grammar
`- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>` and a class
label from the shipped `(a)`–`(d)` set (`## Merge conflicts` and
`.opencode/skill/merge-conflict/SKILL.md` → "Finding grammar"); no new class,
code, or policy is introduced. The check reuses the shipped codes and broadens
their **planning-time meaning**:

| Situation | Code | Class | Offender / detail |
| --------- | ---- | ----- | ----------------- |
| Two unshipped plans share a surface target outside `work/` | `TEXTUAL-CONFLICT` | `(a)` | the two item refs; detail names the shared path |
| Two unshipped plans share a `work/` path or name each other | `TEXTUAL-CONFLICT` | `(b)` | the two item refs; detail names the shared target |
| A declared target is malformed or resolves to nothing | `DANGLING-DEP` | `(b)` | the declaring item ref; detail names the target |
| A child's own declaration and parent cell disagree (both non-`—`, sets unequal) | `DRIFT-FACT` | `(d)` | the child ref; detail shows both sets |

The shipped merge-time meanings of these codes are unchanged. The two notes that
scope `TEXTUAL-CONFLICT` to the dry-run-detected case remain true of that case,
while `/status` and `/conflicts` may additionally report a *declared*
`TEXTUAL-CONFLICT` without performing a dry-run merge.

### Contract and enforcement points

The check is **advisory, offline, local, and read-only**. It performs no fetch,
remote read, merge, or dry-run merge; it takes no lock; and it modifies no file.
It operates on committed plan declarations only and does **not** perform or
reproduce the shipped pre-ship branch/textual detection of `## Merge conflicts`:
that contract acts on branches at merge time, while this check compares
declarations at planning time. It is distinct from `Depends on` as well: a
declared conflict adds no readiness edge, reorders no child, and changes no
child's readiness, so no phase is blocked.

The check runs at three prompt-only enforcement points:

- **`/conflicts [item-ref]`** — the dedicated read-only command. With no argument
  it reports every declared conflict, unresolved declaration, and declaration
  discrepancy across the whole `work/` tree. With an item-ref it reports only the
  findings that involve that item and names each counterpart.
- **`/status`** — its existing integrity window reports the same findings,
  read-only and local-only.
- **The `/build` plan gate** — after a `PROCEED` outcome the builder runs the
  focused check for the item and prints the findings before selecting a task; the
  findings never change the gate outcome and never stop the build. The check
  itself performs no fetch; the gate's own best-effort ref refresh is separate.

An empty compared set — no unshipped plans, no declarations, or all plans already
shipped — reports no findings and does not error.

## Phase reversal (backtracking)

This section is the single authority for reversing the lifecycle. A **backtrack**
is a sanctioned reverse transition on the same **unshipped** work item, triggered
by a detected defect in an earlier phase's artifact or output. It is a step
inside the existing phases, not a new phase, command, or agent: it adds no
`phase` value and no artifact-presence row. It is explicitly not two things: not
normal forward progression, and not the plan-publication **revision** flow
(`## Plan publication`), which re-issues an item's own plan forward and never
moves a phase backward.

### The reverse-edge rule

On an unshipped work item, a later phase may target an earlier phase, or — for a
nested roadmap child — its parent `roadmap.md`. The sanctioned edges and what
each revises:

| Detecting phase | Target              | Revises                        |
| --------------- | ------------------- | ------------------------------ |
| `/build`        | `/plan`             | `design.md`, `tasks.md`        |
| `/plan`         | `/spec`             | `spec.md`                      |
| `/test`         | `/build`            | `tasks.md` + code (rework)     |
| `/test`         | `/plan`             | `design.md`, `tasks.md`        |
| `/test`         | `/spec`             | `spec.md`                      |
| `/review`       | `/build`            | `tasks.md` + code (rework)     |
| any child phase | parent `roadmap.md` | `roadmap.md` (see `### Revising a roadmap`) |

The general later→earlier rule and the table are the model; these exceptions
restrict it:

- **No self-target.** A phase targeting itself is not a reversal and is refused.
- **Shipped items are excluded.** An item whose `ship.md` is present is out of
  scope for a backtrack; its reversal is the post-ship reopen case (below).
- **The target must be strictly earlier** than the detecting phase.
- **`roadmap` is reachable only from a nested child**, and only against that
  child's own parent; the route that revises `roadmap.md` is owned by
  `0004-roadmap-revision`.
- **A recorded finding precedes the edge.** Every backtrack carries a committed
  finding before the reverse edge is taken; there is no unrecorded reversal.
- **The detecting phase never edits the target artifact.** It records the finding
  and hands control to the owner.

### Ownership

Control returns to the target phase, whose **owning agent** revises its own
artifact or output. The detecting phase records its finding but never edits the
target phase's artifact. The invariant "only the owning phase writes its
artifact" is unchanged, and the rule that a phase may not rewrite another
phase's artifact continues to hold in both directions.

### Finding record and non-destructive invalidation

Every backtrack is recorded in the item's committed, append-only
`work/<item-ref>/backtracks.md` record: a finding entry (detecting phase, target
phase, affected artifact or output, observable evidence, status `open`) and, when
the revision completes, a resolution entry. The record is not a phase artifact:
it carries no `phase`, is not an artifact-presence row, and does not by itself
determine the item's derived phase. Its template, and the frontmatter markers
below, are documented in `docs/artifact-conventions.md`.

When the reverse edge is taken, each artifact downstream of the target phase is
marked `stale: <phase>` in its frontmatter; nothing is deleted or silently
rewritten, and the pre-revision content stays recoverable from committed git
history. The item resumes at the target phase and re-runs forward through the
downstream phases. A stale artifact never satisfies a downstream prerequisite and
is never read as the item's current phase artifact.

### Taking an edge

When a detecting phase finds an earlier artifact wrong, it takes the reverse edge
by performing five steps in order and then handing off. This procedure is the
single operational statement of the edge; the agent prompts and commands
reference it rather than restating it.

1. **Confirm the edge is sanctioned.** The target is strictly earlier than the
   detecting phase, the item is unshipped (`ship.md` absent), and the edge is one
   the taking phase supports. A self-target, a parent-`roadmap` edge, and a
   post-ship reopen are not taken here. The three `/test` edges
   (`/test`→`/build`/`/plan`/`/spec`) are supported: an implementation defect is
   the existing `/test`→`/build` rework with no forced finding record or `stale:`
   marker, while a defect that is really a spec or design fault is routed with a
   recorded finding and `stale:` markers.
2. **Record the finding.** Append a `## Finding <n>` entry to
   `work/<item-ref>/backtracks.md`, creating the record with its frontmatter
   (`feature`, `record: backtracks`, `created`, `updated`) when absent. The entry
   names the detecting phase, the target phase, the affected artifact(s), the
   observable evidence, and `status: open`; numbering is sequential and
   append-only.
3. **Apply the `stale:` markers.** Mark every existing artifact strictly
   downstream of the target phase and not owned by the target phase with
   `stale: <target-phase-label>`. Downstream follows the artifact-presence order
   (`spec.md` < `design.md` < `tasks.md` < `verify.md` < `review.md`); the
   target's own artifact is revised by its owner, not marked. This is
   non-destructive metadata, not an authorship edit.
4. **Never edit the target artifact.** The detecting phase does not touch the file
   it is sending back; the target phase's owner revises it on re-entry.
5. **Hand off.** End with the handoff for the target phase:
   `Next: /plan <item-ref>` (from `/build` or `/test`) or
   `Next: /spec <item-ref>` (from `/plan` or `/test`).

The intra-item edges and their marker sets are concrete:

| Edge | Detecting phase | Finding entry (`backtracks.md`) | Existing artifacts marked `stale:` | Handoff |
| ---- | --------------- | ------------------------------- | ---------------------------------- | ------- |
| `/build`→`/plan` | builder | detecting `/build`; target `/plan`; affected `design.md`, `tasks.md` | `verify.md`, `review.md` → `stale: design` | `Next: /plan <item-ref>` |
| `/plan`→`/spec` | architect | detecting `/plan`; target `/spec`; affected `spec.md` | `design.md`, `tasks.md`, `verify.md`, `review.md` → `stale: spec` | `Next: /spec <item-ref>` |
| `/test`→`/plan` | tester | detecting `/test`; target `/plan`; affected `design.md`, `tasks.md` | `verify.md`, `review.md` → `stale: design` | `Next: /plan <item-ref>` |
| `/test`→`/spec` | tester | detecting `/test`; target `/spec`; affected `spec.md` | `design.md`, `tasks.md`, `verify.md`, `review.md` → `stale: spec` | `Next: /spec <item-ref>` |
| `/test`→`/build` | tester | none — the existing implementation-defect rework; no forced finding record | none — no forced `stale:` marker | `/build` to fix (existing route) |

The marker's target-phase label uses the existing vocabulary: target `/plan` →
`stale: design`; target `/spec` → `stale: spec`. The `/test`→`/build` edge is the
pre-existing implementation-defect rework and forces no finding record or `stale:`
marker; the `/test`→`/plan` and `/test`→`/spec` edges are wired by the
reverse-phase routing. A parent-`roadmap` revision and post-ship reopen follow
this same procedure when their items land, and their absence here is not a gap in
the model.

### Re-entry

Every phase that owns a target reads for an open finding targeting its own phase
before doing forward work. A finding is **open** when `backtracks.md` contains an
entry whose target phase is the running phase and that has no matching
`## Resolution` entry.

- **Open finding present.** The owning agent reads the finding, revises the
  affected artifact(s), appends a `## Resolution <n>` entry
  (`resolves: Finding <n>`, `revision: <what changed>`), clears the `stale:`
  marker on any artifact it owns and has just re-run, and resumes the forward
  lifecycle from its phase as if the later phases had not run. The resolver is
  the target phase's owner; the detector never resolves its own finding.
- **No open finding.** The phase behaves as ordinary forward
  progression/revision: it records no finding and touches `backtracks.md` only
  when one already exists for another phase.

Re-entry is invoked by re-running the target phase's existing command
(`/build <item-ref>`, `/plan <item-ref>`, or `/spec <item-ref>`); there is no
separate command.

### Shipped items and reopen

A backtrack applies only to unshipped items. An item whose `ship.md` is present
is excluded: a reversal on it is the **post-ship recall** case, defined here and
owned by `0005-post-ship-pr-denial`. The model changes neither the shipped signal
(`ship.md` presence) nor the `Depends on`/readiness contract except through the
one revocation below. The optional `reopened: <phase>` marker on `ship.md` names
the phase a recalled item re-enters and is documented in
`docs/artifact-conventions.md`.

#### Post-ship states

`/ship` writes `ship.md` when it produces a reviewable PR, whether or not `gh`
was available. After that point an item is in one of:

- **Pre-ship** — no `ship.md`. The item is anywhere from `spec` through `review`;
  a defect is handled by the reverse edges above, never a recall.
- **Shipped** — `ship.md` present with **no** `reopened:` marker. The PR is open
  and awaiting human review or merged, **or was never opened** (for example `gh`
  was unavailable and only local commits exist), **or its branch was abandoned**.
  All four are the same state under the single shipped signal and stay shipped
  until an explicit recall; no automatic detection and no automatic revocation
  occurs.
- **Recalled / reopened** — `ship.md` present **with** a `reopened: <phase>`
  marker. The shipped signal is revoked: the item derives the named phase
  (reopened) and no longer satisfies its dependents (see "Dependencies and
  readiness"). It stays recalled until it re-ships.

A **denied, closed, or changes-requested** PR is **not a state by itself**: it is
the triggering condition a maintainer reports when invoking a recall. The
framework never reads a PR's state and never revokes a signal on its own.

#### Recall (`/ship recall <item-ref> <phase>`)

The recall is a documented **mode of the existing `/ship` command**; it adds no
command, agent, skill, `phase` value, or state file:

```
/ship recall <item-ref> <phase>
  <phase> ∈ { spec | design | build }     # phase labels, strictly earlier than ship
  spec   -> re-enter /spec   (record target phase `/spec`)
  design -> re-enter /plan   (record target phase `/plan`)
  build  -> re-enter /build  (record target phase `/build`)
```

The argument is the **phase label** used by the `reopened:` and `stale:` markers
and by the derived-state table (`spec | design | build`); the recorded target
phase and the handoff use the corresponding command. The mode is refused when
`work/<item-ref>/ship.md` is absent (an unshipped item is an ordinary backtrack,
not a recall) and when `<phase>` is not strictly earlier than ship — `test`,
`review`, and `ship` are refused. It requires the user's explicit invocation,
which is the consent to record and commit the revocation.

The shipper performs the recall:

1. **Record the finding.** Append a `## Finding <n>` entry to
   `work/<item-ref>/backtracks.md`, creating the record with its frontmatter
   (`feature`, `record: backtracks`, `created`, `updated`) when absent. The
   detecting phase is `/ship`; numbering is sequential and append-only:

   ```markdown
   ## Finding <n> — YYYY-MM-DD

   - detecting phase: `/ship`
   - target phase: `/build` | `/plan` | `/spec`
   - affected: `ship.md` (shipped signal revoked), plus the downstream
     artifacts marked `stale: <phase>` in step 3
   - evidence: <triggering condition — PR denied / closed / changes-requested, PR
     never opened, or branch abandoned — and its observable evidence>
   - status: open
   ```

2. **Revoke the shipped signal.** Add the `reopened: <phase>` field to the
   existing `ship.md` frontmatter and refresh `updated`; leave the recorded
   branch, commits, PR URL, and body intact. The marker is distinct from the
   frontmatter `status` and does not overload it.
3. **Mark the downstream artifacts `stale: <phase>`.** Reuse the non-destructive
   mechanical marking above (the detecting phase applies it; the target phase's
   own artifacts are revised, not marked). Whichever artifacts exist are marked;
   absent ones are skipped:

   | Re-entry phase | `ship.md` marker | Artifacts marked `stale:` |
   | -------------- | ---------------- | ------------------------- |
   | `build` (`/build`) | `reopened: build` | `verify.md`, `review.md` → `stale: build` |
   | `design` (`/plan`) | `reopened: design` | `verify.md`, `review.md` → `stale: design` |
   | `spec` (`/spec`) | `reopened: spec` | `design.md`, `tasks.md`, `verify.md`, `review.md` → `stale: spec` |

4. **Commit and report.** Commit the revocation and the record on the item's
   branch (`docs(work): recall <item-ref>`). When no branch or network is
   available the mode makes the local commits and reports the exact commands the
   user runs to push; recording and revoking never require the network.
5. **Hand off** `Next: /build <item-ref>`, `/plan <item-ref>`, or
   `/spec <item-ref>` per the phase.

A second recall (for example after a re-ship and a new denial) appends a new
finding and re-applies or updates the `reopened:` marker; no prior entry is
erased and the marker names the latest re-entry phase.

#### Re-entry and re-ship

After the recall the item is no longer treated as shipped, so re-entry is the
`### Re-entry` procedure above, unchanged: the target phase's owner reads the
open finding targeting its phase, revises its own artifact(s), appends a
`## Resolution <n>` entry, clears the `stale:` markers on the artifacts it owns,
and resumes the forward lifecycle from its phase. The `/plan` and `/spec` targets
behave as `0002` wires them; the `/build` target reads the same open finding. The
target owner clears its own `stale:` markers but **not** the `reopened:` marker:
the item stays recalled, and its dependents stay blocked, until it re-ships.

Re-ship is the ordinary `/ship <item-ref>` work-item path. For a recalled item
(`ship.md` present with `reopened:` and a fresh `review.md` `approve`), the
shipper reuses the branch recorded in `ship.md`, adds commits, pushes without
force, updates the existing PR — or opens a new one when the branch was pruned —
never rebases a pushed branch, never force-pushes, never rewrites pushed history,
and never deletes or closes the denied PR. It then writes a fresh `ship.md`
**without** the `reopened:` marker (the shipper's own artifact), so the item
derives `shipped` and satisfies its dependents again. The recall stays auditable
in `backtracks.md` and in git history.

## Findings challenge and adjudication

This section is the single authority for contesting a finding. A **challenge** is
a committed, append-only record that disputes a finding in `review.md` or a
defect reported in `verify.md` — the finding itself, its severity, or an
acceptance-criterion interpretation — without the challenger editing the artifact
owned by the phase that produced it. It is a step inside the existing phases, not
a new phase, command, or agent: it adds no `phase` value, no artifact-presence
row, and no state file. The existing severity scale
(`Blocker`/`Major`/`Minor`/`Nit`), finding format, and review verdict vocabulary
(`approve`/`request-changes`) are reused unchanged; no second severity scale,
finding grammar, or verdict is introduced.

### What is challengeable

A finding in `review.md` and a defect reported in `verify.md` are both
challengeable, including a claimed defect that is really a spec or design fault.
A challenge to a non-review finding is never silently dropped. An item with no
finding and no reported defect has nothing to challenge: no challenge record is
created and nothing blocks.

### Raising a challenge

The challenger appends a `## Challenge <n>` entry to the item's committed,
append-only `work/<item-ref>/challenges.md` record naming the challenged finding,
the challenge `type` (`finding | severity | acceptance-criterion`), the evidence,
and the rationale. Raising happens on the existing phase surface — a challenge to
a `review.md` finding or a `verify.md` defect is raised from the author's current
phase prompt — so no command is added. The challenger **never edits the artifact
owned by the phase that produced the finding**; it records state only. A challenge
hands control to the producing phase: `Next: /review <item-ref>` for a review
finding, `Next: /test <item-ref>` for a verify defect.

The record is not a phase artifact: it carries no `phase`, and by itself it does
not determine the item's derived **phase** (it determines the blocked
**condition** below). Its entry shapes are documented in
`docs/artifact-conventions.md`.

### The challenged (blocked) condition

While `challenges.md` holds any challenge with no matching `Response` or
`Withdrawal`, the item is **challenged**: it does not advance to its next forward
phase, including `/ship`, and the open challenge escalates to the user. The
condition is the record's open entry plus the derived label `challenged`; it adds
no `phase` value, and its precedence in derived state is stated below. Nothing
resolves on its own: an open challenge that is never adjudicated or withdrawn
keeps the item challenged and keeps the escalation in place.

### Adjudication

The phase that produced the challenged finding re-evaluates it first on
re-entry; if it cannot resolve the challenge, it escalates to the user on the
existing question surface, and the user decides. The challenger is never the
adjudicator of its own challenge, and no adjudication completes without a
`Response` entry recording the decision, its basis, and who made it
(`adjudicator`: the producing phase command, or `user`). A challenge may be
withdrawn by its author; the withdrawal is appended, the item is unblocked, and
the prior entry is preserved. A later decision that supersedes an earlier one is
appended as a `Reversal` entry; it never rewrites the prior entry.

### Outcomes and routing

A **sustained** challenge overturns the challenged finding or adjusts its
severity and, for a review finding, the review verdict is recomputed — `approve`
if and only if no `Blocker` or `Major` remains. The outcome and its evidence are
recorded, and the next command follows the recomputed verdict (`/ship` if
`approve`, `/build` if `request-changes`). If a sustained challenge shows the
acceptance criterion itself is wrong rather than the finding being mistaken, the
correction is routed upstream through `## Phase reversal (backtracking)` —
revising `spec.md` or `design.md` by their owners — rather than written into
`review.md`. A **rejected** challenge leaves the challenged finding and the
verdict unchanged, records the rejection and its rationale, and resumes normal
routing — for a blocking review finding, the existing `review.md` verdict
`request-changes` → `/build` route.

### Ownership

The challenger/detector records state and never edits the artifact owned by the
producing phase; the producing phase's owner revises its own artifact and appends
the outcome. The invariant "only the owning phase writes its artifact" is
unchanged, and the rule that a phase may not rewrite another phase's artifact
continues to hold in both directions.

### The record

`work/<item-ref>/challenges.md` is committed, append-only, and numbered from `1`;
entries are never edited, reordered, or removed. Its entry kinds (`Challenge`,
`Response`, `Withdrawal`, `Reversal`), fields, and the malformed out-of-order
rule are documented in `docs/artifact-conventions.md`. A malformed record — for
example a `Response`/`Withdrawal`/`Reversal` recorded before its `Challenge` — is
reported rather than reordered. An absent `challenges.md` means nothing is
challenged, and historical items need no migration.

## Derived state

There is no state file. `/status` derives each item's phase from artifacts and
content:

| Observed state                                             | Phase        |
| ---------------------------------------------------------- | ------------ |
| earliest `stale:` marker among the item's artifacts names phase `P` | `P` (backtracked) |
| `ship.md` present with a `reopened:` marker naming phase `P` | `P` (reopened) |
| an open challenge in `challenges.md` (no matching `Response`/`Withdrawal`) on an item that has no `ship.md` | challenged (blocked) |
| `roadmap.md` present (check before `spec.md`)              | roadmap      |
| `spec.md` missing                                          | not started  |
| `spec.md` present, `design.md` missing                     | spec         |
| `design.md` present, `tasks.md` missing                    | design       |
| `tasks.md` present, some boxes unchecked                   | build        |
| all boxes checked, `verify.md` missing                     | test         |
| `verify.md` present, `review.md` missing                  | review       |
| `ship.md` present                                          | shipped      |
| `review.md` verdict `request-changes`                      | build (rework)|
| `review.md` verdict `approve`, no `ship.md`                | ship         |
| `visual.md` present (optional; does not change the phase) | review       |

The first two rows are evaluated **before** the artifact-presence rows below
them. An `earliest stale:` marker names the backtrack target phase `P`; the item
derives `P` (backtracked), and the marked artifact is never read as the item's
current phase artifact nor counted as a satisfied downstream prerequisite. The
`stale` token `roadmap` — used only for a phase→parent-`roadmap.md` backtrack —
maps to `spec` when the item's phase is derived. A `reopened:` marker on
`ship.md` derives the named phase `P` (reopened); it is the one condition that
invalidates the `ship.md` presence row, and readiness consumes the same
revocation: a `ship.md` carrying a `reopened:` marker does not satisfy a
dependent until the item re-ships (see `### Shipped items and reopen`). The
`review.md` verdict
`request-changes` → `build (rework)` row below is the pre-existing, already
rendered instance of the general backtrack model
(`## Phase reversal (backtracking)`): it is retained verbatim, defines no second
rework mechanism, and its routing literal and consumers are unchanged.

The **challenged** condition is a blocked overlay that applies to **unshipped
items only**; it is evaluated after the `stale:`/`reopened:` structural
derivations and before the forward-action and `ship.md`/verdict rows, so an
unshipped item with an open challenge is never read as ready to advance or ship
even when its artifact-presence and verdict rows would otherwise derive a forward
phase. While an unshipped item's `challenges.md` holds a `Challenge <n>` with no
matching `Response n`/`Withdrawal n`, the item derives `challenged` (blocked), the
next forward phase — including `/ship` — refuses and reports the open challenge(s),
and the open challenge escalates to the user; the condition reuses the `0001`
marker model (the record's open entry is the marker, plus the derived label) and
introduces no new `phase` value. The unshipped precondition is what keeps the
overlay from masking a completed item: a `ship.md`-present item derives `shipped`
(or `P` (reopened) when it also carries a `reopened:` marker) and its open
challenge is **out-of-scope for a challenge**, because post-ship reversal is
recall's domain (`0005`, `### Shipped items and reopen`); therefore no shipped
item is ever derived `challenged`. Its raising, adjudication, and outcome are
defined once in `## Findings challenge and adjudication`.

`/status` reports the Phase column by mirroring this table's Phase cell — the
base phases plus `P` (backtracked), `P` (reopened), `build (rework)`, and
`challenged (blocked)` — and adds a per-item Notes line for the derived states.
For a backtracked item the Notes name the target phase being revised and the
affected upstream artifact from the open `backtracks.md` finding, and list the
downstream artifacts the backtrack invalidated (the `stale:`-marked ones), or
`none` when no downstream artifact exists; for a reopened item they name the
recall and the re-entered phase; for an unshipped challenged item they name the
open challenge(s); and for a shipped item carrying an open challenge they surface
that challenge as out-of-scope. The report reuses this table and the readiness
authority as its single sources and restates neither.

A directory containing `roadmap.md` is a roadmap parent and is derived as
`roadmap` before the single-feature rows. A roadmap child is derived like any
other item: a child holding only its `.gitkeep` has no phase artifacts and is
`not started`.

## The fix track

`/fix` is the lightweight track for a small defect whose correct behavior is
already clear. It has **no work item**: no `spec.md`, `design.md`, `tasks.md`,
`verify.md`, or `review.md`, and no directory under `work/`. It consumes no
sequence number, so a fix cannot collide with or renumber a work item even when
both are in flight.

- Reproduce the defect with a failing test or an exact repro, find the root
  cause, make the smallest change, and add a regression test that fails without
  the change and passes with it. Fixes never introduce new behavior; a change
  that needs new behavior routes to `/spec`.
- Run test, lint, and typecheck for the touched scope. A failed check, or a
  defect that could not be reproduced, blocks landing — the closing handoff omits
  the landing step and reports the failure as the blocker instead.
- Only the `shipper` performs git writes, and only on the user's explicit
  request. The builder and every other non-shipper agent never commit, push, or
  open a PR.
- A verified fix lands through `/ship fix` (with an optional short description).
  The shipper stages only the fix's files, creates a `fix/<short-description>`
  branch, commits the change and its regression test as conventional commits, and
  opens a PR whose description carries the reproduction, root cause, change, and
  check results.
- A landed fix creates no work item and no shipped-state record. `ship.md`
  remains the sole shipped signal for lifecycle work items, so a fix has no
  `/status` phase and never appears under `work/`.

## Routing heuristics

- **`/fix <bug>`** — for defects where the desired behavior is already clear and
  the change is small. Skips spec/design. Still: reproduce, fix, test, then
  report; a verified fix lands through `/ship fix` on the user's explicit request
  (see "The fix track"). Fixes never introduce new behavior.
- **Full lifecycle** — new features, behavior changes, cross-cutting work,
  anything touching public interfaces, data, or security.
- **`/ship recall <item-ref> <phase>`** — recall a shipped item whose PR was
  denied, closed, or sent back for changes (or whose PR was never opened, or
  whose branch was abandoned): record the finding, revoke the shipped signal
  without deleting the historical `ship.md`, and re-enter `spec`/`design`/`build`.
  Explicit and maintainer-invoked; see `### Shipped items and reopen`.
- **`/roadmap <initiative> | /roadmap revise <item-ref>`** — decompose a broad,
  multi-feature initiative into a parent roadmap item and nested child work items,
  or revise an existing parent in place, sequencing them and recording
  intra-roadmap dependencies. Use before `/spec` when a request spans
  several interdependent features; a single, self-contained feature still goes
  straight to `/spec`.
- **`/status`** — when unsure where things stand.
- **`/conflicts [item-ref]`** — to compare the `conflicts-with` declarations of
  unshipped plans before development and report overlaps in the shipped conflict
  classes. Advisory, offline, and read-only; it blocks no phase and names each
  counterpart for a focused item. See `## Declared-conflict check`.
- **`/doctor`** — a **framework-maintainer only**, read-only consistency check of
  the framework's documented inventories, counts, permission blocks, and ignore
  rules. It reports drift and never edits; safe to run at any time, including
  before release.
- **`/visual [url or item-ref]`** — to inspect a running user-facing frontend in a
  real browser for layout, interaction, responsiveness, and accessibility. Use
  for UI-bearing work; harmless to skip for backend-only work.
- **`/bootstrap`** — once, when adopting the framework into a repository.

When a task's nature is ambiguous, ask the user which track to use.

## Multiple work items

Items are independent directories and may proceed in parallel. Keep them on
separate branches. `tasks.md` check boxes are per-item; never mix items in one
commit unless the user asks.

Artifacts are committed, so they travel with the branch: a work item's
`work/<item-ref>/` directory merges alongside its code, and the artifact paths
linked from its pull request resolve for a reviewer who does not share the
author's working tree.

Because two branches can each allocate the same next number, a merge can leave
two items sharing a canonical reference without a filesystem conflict. After a
merge, scan the top-level `work/` directories — and each roadmap parent's child
directories — for duplicate 4-digit prefixes. On a collision, follow
"Renumbering after a parallel merge" in `docs/artifact-conventions.md`: renumber
the unshipped item to the next number from the allocation contract and update
every reference in the same change before it ships. A number is never reused.
Duplicate sequence numbers are only one class of conflict; for every other class
— shared-surface textual conflicts, `work/` artifact conflicts, and
derived-agreement drift — see `## Merge conflicts`.

## Merge conflicts

This section is the normative merge-conflict contract: it classifies the conflict
classes this workflow can encounter and states the sanctioned handling for each.
The `merge-conflict` skill restates the operational procedure; on any
disagreement, this section is the source of truth.

### Conflict taxonomy

| Class | Conflict | Affected surface(s) |
| ----- | -------- | ------------------- |
| (a) shared-surface textual conflict | Both branches edit the same framework file, so Git emits conflict markers. | `README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**` |
| (b) `work/` artifact conflict | Both branches edit the same committed work artifact. | Roadmap `Children` / `Depends on` tables, artifact frontmatter, nested-child intersections |
| (c) duplicate sequence number | Both branches allocate the same `NNNN`, or the same per-parent `MMMM`. | Top-level `work/<NNNN-slug>`, per-parent `work/<NNNN-slug>/<MMMM-slug>` |
| (d) derived-agreement drift | A duplicated inventory or count fact merges cleanly but the two sides now disagree. | README Layout counts, README Skills table |

### Lifecycle placement

Reconciliation happens at two points in the lifecycle: a **pre-ship reconcile**
before the shipper performs any ship operation, and a **post-merge integrity
pass** after a merge to the default branch. The pre-ship reconcile merges the
default branch forward into the item branch and resolves any conflicts, so a
ship is never built on a stale merge base. The post-merge integrity pass is a
documented, shipper-owned checklist run on the merged tree: re-scan top-level
and per-parent `work/` directories for duplicate 4-digit prefixes, re-check
every roadmap `Depends on` against its `Children` table for dangling, missing,
unlisted, or cyclic references, and re-run the repository's own configured test
command — the Project profile `Test:` value — to surface derived-agreement
drift.

When the branch is already up to date, both steps are no-ops and do not error.

### Ownership

The `shipper` is the single owner of reconciliation. Reconciliation is a step inside `/ship` and adds no new command or agent.

### Resolution principles

- **Merge the default branch forward.** Bring the default branch into the item
  branch with a merge. Never rebase a pushed branch and never force-push; the
  shipper's guardrails forbid both.
- **Preserve both branches' intent.** Keep both sides' records and changes rather
  than dropping one. A conflict whose resolution requires a judgment about
  competing intents is a semantic conflict: never silently accept it, and escalate
  it to the user for explicit approval before proceeding.
- **Auto-resolve the mechanical.** A conflict whose resolution is mechanical or
  structural — one that does not require choosing between competing intents — may
  be resolved automatically, subject to the re-verification below.

### Verification

After any resolution, re-run the repository's own configured test command — the
Project profile `Test:` value — and the affected item's checks.
Both must be green before the resolved merge is recorded or shipped. A clean
merge is not evidence of correctness: even a merge that produced no conflict
markers still runs the suite, because derived-agreement drift is surfaced only
there.

### Merge-integrity guard

The invariants this merge-conflict contract protects are stated once here. The
guard is **prompt behavior only**: there is **no committed checker, script, helper, or executable tool** for it and **no tests/ agreement area**, and no separate checker exists. It runs at two prompt-only enforcement points and adds no separate guard:

- **`/status`** reports the invariants **offline and read-only** on demand, as
  the guard's read-only window.
- The **`/ship` post-merge integrity pass** runs **after a merge to the default
  branch**, as the `shipper`-owned checklist described under "Lifecycle
  placement".

The guard observes the same invariant set at both points, and neither defines a separate guard. The invariant set, with the finding code that names each invariant and the class it belongs to:

| Invariant | Code | Class |
| --------- | ---- | ----- |
| no two top-level `work/` items share a 4-digit `NNNN` prefix | `DUPLICATE-PREFIX` | `(c)` |
| no two children of one roadmap parent share a 4-digit `MMMM` | `DUPLICATE-CHILD` | `(c)` |
| every roadmap `Depends on` resolves to an existing `Children` row and child directory | `DANGLING-DEP` | `(b)` |
| the stored dependency graph is acyclic | `CYCLIC-DEP` | `(b)` |
| no child is missing — a `Children` row whose child directory is absent | `MISSING-CHILD` | `(b)` |
| no child is unlisted — a child directory absent from the `Children` table | `UNLISTED-CHILD` | `(b)` |
| the duplicated inventory/count facts agree with disk | `DRIFT-FACT` | `(d)` |

Findings use the `merge-conflict` skill's `### Finding grammar`
(`- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`); this
subsection defines **no second vocabulary** and **no second policy**. Every
finding names its code, its class, and the offending canonical reference, and is
**non-fatal**: the list is **never silently dropped** and **never truncated**,
findings are **not auto-repaired**, and the guard **modifies no file**. An empty
`work/` tree and an already-up-to-date branch with no collision are no-ops that
report **no findings** and **does not error**.

The guard's verification is portable: it names the repository's own
**configured test command** — the **Project profile** `Test:` value in
`AGENTS.md` — rather than a maintainer-only path, so an adopter runs their own
suite. The duplicated-inventory/count-fact invariant is nevertheless
**observable offline through `/status`**, without that command.

### Relationship to renumbering

Duplicate sequence numbers — class (c) — are handled by "Renumbering after a
parallel merge" in `docs/artifact-conventions.md`. This section defers to and
extends that rule; it never defines a second renumbering rule.

## Resuming and interruption

Because state is file-based, resuming is just re-reading `work/<item-ref>/`. If a
session ends mid-phase, the next session reads the artifacts and continues. If
an artifact is stale relative to the code, reconcile before proceeding and note
what changed.

## Failure and rollback

- A failed `/build` or `/test` leaves artifacts and code in place. Report the
  failure; do not paper over it.
- Never rewrite another phase's artifact to hide a failure. If an upstream
  artifact is wrong, say so and take the sanctioned reverse transition in
  `## Phase reversal (backtracking)`: record the finding and hand control to the
  phase that owns the wrong artifact.
- Destructive git recovery (reset, revert, restore) requires user confirmation.
