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
/spec ──▶ spec.md ──▶ /plan ──▶ design.md + tasks.md ──▶ /build ──▶ code + [x] tasks
                                                                          │
                      /ship ◀── review.md ◀── /review ◀── verify.md ─────┤ (/test)
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

The `Children` table carries a `Conflicts with` column alongside `Depends on`.
Like `Depends on`, it names other rows in the same table only, comma-separated
when there are two or more or `—` when there are none; unlike `Depends on`, it is
a coordination relation that never affects readiness or the dependency graph. It
records sibling children that touch overlapping surfaces and therefore must not
be developed concurrently, and is read by the pre-development check in
`## Parallel-development plan conflicts`.

### Dependencies and readiness

The `Children` table in `roadmap.md` is the single machine-readable source for
the child set and the dependency graph. The `Depends on` cell holds another
child's **local id**, comma-separated when there are two or more, or `—` when the
child has none. A dependency may not name its own row, dependencies are
intra-roadmap only, and the stored graph must be acyclic. If an initiative's
dependencies are cyclic, the roadmap records the cycle under `## Open issues` and
leaves the stored graph acyclic. A `Conflicts with` entry never changes a child's
readiness or its place in the dependency graph; readiness is derived from
`Depends on` alone.

Readiness is derived live from files at status time; it is never stored:

```
satisfied(dep_local_id):
  child_dir = work/<parent>/<dep_local_id>/
  if child_dir does not exist        -> dangling; not satisfied
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
A child in a cycle is never `ready`.

### Status reporting

`/status` reports a roadmap parent separately from its children. The roadmap row
shows `<ready>/<total> ready` plus a distribution tally of its children across
phases (`<phase> <n>, ...`), so a roadmap is never presented as a single-feature
item. Each child row shows its own phase and readiness; a blocked child names the
specific children blocking it. Status is read-only and modifies nothing.

Status also reports integrity findings rather than failing:

- `DANGLING-DEP` — a `Depends on` local id with no child directory or no table row.
- `MISSING-CHILD` — a table row whose canonical reference/directory is absent.
- `UNLISTED-CHILD` — a child directory present under the parent but absent from the Children table (possible rename).
- `CYCLIC-DEP` — a cycle in a manually edited graph; cycle members are never reported ready.

### Starting a blocked child

When `/spec` is invoked for a nested child, the product agent resolves the parent
`roadmap.md` and evaluates readiness first. If the child is blocked, it reports
the specific blocking children and stops before writing `spec.md`. It proceeds
only on an explicit user override, and then records the override and the blocking
dependencies in the new `spec.md` frontmatter `notes`. Refusing touches no
existing file, and status still reports the child's dependency state afterwards.

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
- **Next**: `/plan <item-ref>`.

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
- **Next**: `/build` (or `/build <task-id>` for a specific task).

### 3. Build — `/build [item-ref or task-id]`

- **Purpose**: Implement the tasks.
- **Entry**: `tasks.md` exists with unchecked items.
- **Process**: Read `spec.md`, `design.md`, `tasks.md` → select the requested
  task or the next unblocked unchecked task → implement following existing
  conventions → run the project's checks → tick the box in `tasks.md`.
- **Exit**: Each completed task's check box is `[x]`, its acceptance is
  demonstrably met, and the project's lint/typecheck/tests pass for the touched
  scope. Do **not** commit.
- **Artifact**: source changes plus `tasks.md` with updated check boxes.
- **Next**: `/build` again for more tasks, then `/test` when all boxes are
  checked.

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
- **Next**: `/review`. If defects were found, `/build` to fix them first.
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
  overrides).
- **Process**: Reconcile first — if the branch has fallen behind the default
  branch, merge it forward and resolve conflicts per `## Merge conflicts` →
  confirm checks are green and the tree contains no secrets →
  create a branch → stage logical commits with conventional messages →
  (user-approved) push → open a PR with a structured body linking the artifacts →
  write `ship.md` recording the branch, commits, and PR (or "not created"), commit
  it (`docs(work): record ship state for <item-ref>`), and push so the shipped
  signal travels with the branch.
- **Exit**: PR URL reported to the user, or — when `gh` is unavailable — the
  local-commit path recorded in `ship.md`; the branch carries a committed
  `ship.md` and the run leaves no uncommitted `ship.md`. Nothing is merged by the
  agent.
- **Artifact**: branch, commits, PR, and `ship.md` recording the shipped signal
  (branch, commits, and PR URL). Presence of `ship.md` is the shipped signal; see
  "Dependencies and readiness".
- **Next**: Human review and merge. `/status` will show the item as shipped.

## Derived state

There is no state file. `/status` derives each item's phase from artifacts and
content:

| Observed state                                             | Phase        |
| ---------------------------------------------------------- | ------------ |
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
- **`/roadmap <initiative>`** — decompose a broad, multi-feature initiative into
  a parent roadmap item and nested child work items, sequencing them and
  recording intra-roadmap dependencies. Use before `/spec` when a request spans
  several interdependent features; a single, self-contained feature still goes
  straight to `/spec`.
- **`/status`** — when unsure where things stand.
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

## Parallel-development plan conflicts

This section is the normative pre-development conflict contract: it defines a
read-only check `/build` runs before it implements a task, so a builder learns
before writing code that another ready in-flight item will touch the same
surfaces. It complements `## Merge conflicts`, which handles collisions at merge
and ship time, and changes none of that policy. The `merge-conflict` skill
carries the canonical finding vocabulary; this section defines no second one.

The check is **report-only**: it is non-fatal, read-only, takes no lock, modifies
no file, auto-repairs nothing, and never blocks the build. Findings are reported,
never dropped or truncated, and the result is recorded in the build handoff.

### Surface declaration

Each ready in-flight work item may commit a **surface declaration** — the
repository-relative paths or directories it will create or modify — in the
optional `## Surface declaration` section of its `design.md`, so the declaration
is committed before development begins and is discoverable by the item's
canonical reference (`work/<item-ref>/design.md`) without reading implementation
code. The section's exact grammar lives in `docs/artifact-conventions.md` →
`### design.md`: one path per bullet, no leading `/` and no `..`, an optional
trailing `/` marking a directory entry that covers every path beneath it. An
absent or empty section means the item declares no surfaces; the check reports
that it could not compare that item and does not error.

### Comparison universe

The comparison universe is the set of **ready in-flight items** in this
repository's committed `work/` tree:

- it is not a roadmap parent (a directory holding `roadmap.md`),
- it has a committed `design.md` (a plan exists),
- it has no `ship.md` (it is not shipped), and
- it is **ready**: a standalone item, or a nested roadmap child whose `Depends
  on` entries are all satisfied and which is not in a cycle.

Items that are shipped (a `ship.md` is present) or blocked or cyclic are outside
the universe: they are neither reporters nor reported conflicting items. The
comparison is local to the committed tree only; no branch-diff, remote, or
cross-repository comparison is performed. The current item is excluded from its
own peer set. When there is no other ready in-flight item, or no other item
carries a declaration, or the current item declares no surfaces, the check
reports `no conflicts` and does not error.

### Detection

`/build` runs the check once, as a step after it selects the task and before it
implements anything. It reads the current item's `## Surface declaration` (empty
if absent), enumerates the universe above, reads each peer's declaration, and
reports a conflict when any of the following holds:

- **Declared edge.** The current item is a nested roadmap child and its
  `Conflicts with` entry names a ready in-flight sibling, or a ready in-flight
  sibling's `Conflicts with` entry names the current item. The relation is
  symmetric for detection: one direction suffices, and declaring both directions
  is not an error. An unresolvable `Conflicts with` reference is
  `DANGLING-CONFLICT`, owned by `/status`, not this check.
- **Surface overlap by path.** Two declared surfaces name the same concrete path,
  or one is a directory entry that is an ancestor of (or equal to) the other —
  for example a declared `docs/` overlaps a declared `docs/workflow.md`. This
  reports `SURFACE-OVERLAP` naming both items and the overlapping surface(s).
- **Shared framework surface.** Both items declare paths under the same shared
  framework surface class — `README.md`, `AGENTS.md`, `docs/*.md`,
  `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`. This
  reports `SURFACE-OVERLAP` naming both items and the shared surface.

An in-flight peer whose `design.md` lacks a surface declaration is reported as
"could not compare", never treated as declaring no surfaces.

### Finding vocabulary

Every finding uses the `merge-conflict` skill's grammar,
`- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`, and its
canonical vocabulary table, extended for pre-development with:

| Code | Class | Finding |
| ---- | ----- | ------- |
| `DANGLING-CONFLICT` | `(b)` | a roadmap `Conflicts with` names a local id that resolves to no other row in the same `Children` table, or names its own row |
| `DECLARED-CONFLICT` | `(b)` | two ready in-flight items where one plan declares a `Conflicts with` edge naming the other |
| `SURFACE-OVERLAP` | `(a)` or `(b)` | two ready in-flight items declare the same concrete path, an ancestor/descendant directory overlap, or the same shared framework surface; class `(b)` when both entries are under `work/`, otherwise class `(a)` |

This section defines no second vocabulary. `DANGLING-CONFLICT` is reported by
`/status` alongside the merge-integrity findings; `DECLARED-CONFLICT` and
`SURFACE-OVERLAP` are reported only by the pre-development check. Every finding
carries its code, its class, the offending canonical reference(s), and the
specific overlap or declared-edge detail; no detected conflict is silently
dropped, and the list is never truncated, even for a large overlap set.

### Report-only contract

The check is advisory. It never resolves or serializes parallel work, never
assigns an order, moves a branch, merges, or blocks a build; it modifies no file
and auto-repairs nothing. Two concurrent check runs take no lock, write nothing,
and do not interfere. `/build` always continues, whether or not conflicts are
reported, and records the result in its handoff: the declarations assessed and
either the conflicts found or an explicit `no conflicts`, so a reviewer can see
what was checked before development began.

## Resuming and interruption

Because state is file-based, resuming is just re-reading `work/<item-ref>/`. If a
session ends mid-phase, the next session reads the artifacts and continues. If
an artifact is stale relative to the code, reconcile before proceeding and note
what changed.

## Failure and rollback

- A failed `/build` or `/test` leaves artifacts and code in place. Report the
  failure; do not paper over it.
- Never rewrite another phase's artifact to hide a failure. If the spec is
  wrong, say so and route back to `/spec`.
- Destructive git recovery (reset, revert, restore) requires user confirmation.
