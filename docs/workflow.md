# Workflow

This document is the authoritative description of the development lifecycle for
projects using this framework. `AGENTS.md` summarizes it; this file is the
source of truth. If the two disagree, this file wins and `AGENTS.md` should be
corrected.

## Mental model

A **work item** is one unit of change — a feature, a behavior change, or a
sizable bug. Each work item gets a directory under `work/` and moves through six
phases. Each phase consumes the previous phase's artifact and produces its own.
Nothing is implicit: the repository's `work/` directory plus the code diff is
the complete state of the work.

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
  0001-add-dark-mode/
    spec.md       # requirements            (product)
    design.md     # technical design        (architect)
    tasks.md      # ordered, checkable work (architect; builder ticks boxes)
    verify.md     # test evidence + gaps    (tester)
    review.md     # findings + verdict      (reviewer)
```

- `NNNN` is the next zero-padded sequence number across the whole `work/` tree.
  Allocate it by finding the highest existing directory name and adding one.
- `slug` is a short kebab-case handle derived from the request (e.g.
  `add-dark-mode`). Prefer 2–4 words. It is immutable once created.
- Artifacts are git-ignored. They are working state, not deliverables.
- A phase may be skipped only by explicit user request. If skipped, say so in
  the next artifact's frontmatter `notes`.

## Phases

Each phase below lists: **Purpose**, **Entry criteria**, **Process**,
**Exit criteria**, **Artifact**, **Next**.

### 1. Requirements — `/spec <feature>`

- **Purpose**: Convert an informal request into a precise, testable,
  implementation-free specification.
- **Entry**: A request from the user. No `spec.md` required.
- **Process**: Recon the repo for domain context → surface ambiguities → ask the
  user batched clarifying questions → write the spec. Details in the `product`
  agent prompt and the `spec-writing` skill.
- **Exit**: `spec.md` has a problem statement, goals, non-goals, at least one
  user story, and numbered acceptance criteria in Given/When/Then form. Open
  questions are either resolved or explicitly marked as deferred.
- **Artifact**: `work/<NNNN-slug>/spec.md`, frontmatter `phase: spec`.
- **Next**: `/plan <slug>`.

### 2. Design — `/plan <feature>`

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

### 3. Build — `/build [task-id]`

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

### 4. Test — `/test`

- **Purpose**: Independently verify the implementation against the acceptance
  criteria and close coverage gaps.
- **Entry**: All tasks are checked, or the user asks for verification.
- **Process**: Read `spec.md` and `tasks.md` → map every acceptance criterion to
  a test → run the suite → write missing tests → record results and residual
  risk in `verify.md`.
- **Exit**: Every acceptance criterion is covered by at least one passing test
  or is explicitly flagged as manual/untestable with a reason. Failures are
  reported, not hidden.
- **Artifact**: test files plus `work/<slug>/verify.md`, frontmatter
  `phase: test`.
- **Next**: `/review`. If defects were found, `/build` to fix them first.
- **Optional visual pass**: if the work item has a user-facing UI, run `/visual`
  (or have the tester delegate to the `visual` subagent). It drives a real
  browser, produces `work/<slug>/visual.md` plus screenshots, and feeds its
  findings into review. It is optional so that non-UI projects never need a
  browser; when present, review must consider it.

### 5. Review — `/review`

- **Purpose**: A skeptical, read-only pass over the diff against the spec and
  project standards.
- **Entry**: Tests pass and `verify.md` exists.
- **Process**: Determine the base ref → read the diff → check correctness,
  security, tests, conventions, scope, and performance → write severity-ranked
  findings with `file:line` references and a verdict.
- **Exit**: `review.md` states a verdict of `approve` or `request-changes`, and
  every finding has a severity, a location, and an actionable recommendation.
- **Artifact**: `work/<slug>/review.md`, frontmatter `phase: review`.
- **Next**: `/ship` if `approve`; otherwise `/build` to address blockers.

### 6. Ship — `/ship`

- **Purpose**: Turn a reviewed work item into a reviewable pull request.
- **Entry**: `review.md` exists with verdict `approve` (or the user explicitly
  overrides).
- **Process**: Confirm checks are green and the tree contains no secrets →
  create a branch → stage logical commits with conventional messages →
  (user-approved) push → open a PR with a structured body linking the artifacts.
- **Exit**: PR URL reported to the user. Nothing is merged by the agent.
- **Artifact**: branch, commits, PR. Optionally `ship.md` recording the PR URL.
- **Next**: Human review and merge. `/status` will show the item as shipped.

## Derived state

There is no state file. `/status` derives each item's phase from artifacts and
content:

| Observed state                                             | Phase        |
| ---------------------------------------------------------- | ------------ |
| `spec.md` missing                                          | not started  |
| `spec.md` present, `design.md` missing                     | spec         |
| `design.md` present, `tasks.md` missing                    | design       |
| `tasks.md` present, some boxes unchecked                   | build        |
| all boxes checked, `verify.md` missing                     | test         |
| `verify.md` present, `review.md` missing                  | review       |
| `visual.md` present (optional; does not change the phase) | review       |
| `review.md` verdict `request-changes`                      | build (rework)|
| `review.md` verdict `approve`, no branch/PR recorded       | ship         |
| `ship.md` present with PR URL, or PR detected              | shipped      |

## Routing heuristics

- **`/fix <bug>`** — for defects where the desired behavior is already clear and
  the change is small. Skips spec/design. Still: reproduce, fix, test, then
  report. Fixes never introduce new behavior.
- **Full lifecycle** — new features, behavior changes, cross-cutting work,
  anything touching public interfaces, data, or security.
- **`/status`** — when unsure where things stand.
- **`/doctor`** — a read-only consistency check of the framework's documented
  inventories, counts, permission blocks, and ignore rules. It reports drift and
  never edits; safe to run at any time, including before release.
- **`/visual [url or slug]`** — to inspect a running user-facing frontend in a
  real browser for layout, interaction, responsiveness, and accessibility. Use
  for UI-bearing work; harmless to skip for backend-only work.
- **`/bootstrap`** — once, when adopting the framework into a repository.

When a task's nature is ambiguous, ask the user which track to use.

## Multiple work items

Items are independent directories and may proceed in parallel. Keep them on
separate branches. `tasks.md` check boxes are per-item; never mix items in one
commit unless the user asks.

## Resuming and interruption

Because state is file-based, resuming is just re-reading `work/<slug>/`. If a
session ends mid-phase, the next session reads the artifacts and continues. If
an artifact is stale relative to the code, reconcile before proceeding and note
what changed.

## Failure and rollback

- A failed `/build` or `/test` leaves artifacts and code in place. Report the
  failure; do not paper over it.
- Never rewrite another phase's artifact to hide a failure. If the spec is
  wrong, say so and route back to `/spec`.
- Destructive git recovery (reset, revert, restore) requires user confirmation.
