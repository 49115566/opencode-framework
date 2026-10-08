---
description: "Implement a work item's tasks. Usage: /build [item-ref or task-id]"
agent: builder
---

Run the **Build** phase for: $ARGUMENTS

Follow your Builder agent instructions exactly. In particular:

- Read `AGENTS.md`, then the work item's `spec.md`, `design.md`, and `tasks.md`.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Resolve the project's test, lint, and typecheck commands via the
  `project-discovery` skill if `AGENTS.md` does not already state them.
- Before selecting a task, run the `/build` plan gate in `docs/workflow.md` →
  "Plan publication": refresh refs best-effort first — `git fetch origin
  <default>`, and, when the remote advertises one, the `plan/<ref>` branch too
  (an offline fetch ignored) — then verify the plan is published on the default
  branch. If the plan is not published there, or a `plan/<ref>` branch (local or
  via `git ls-remote` on origin) carries plan artifacts that differ from the
  default branch (an unmerged publication or a later revision), refuse and report
  the plan pull request that must be merged first. A plan branch the remote
  advertises but that has no resolvable local ref cannot be compared; refuse
  rather than guess. If neither exists, proceed and note that no plan publication
  was found (historical/pre-flow item); an unreachable `origin` never hard-fails.
- Implement the requested task, or the next unblocked unchecked task if none is
  named. State which task you are doing.
- Follow existing conventions; keep the change scoped to the task.
- Run the task's `Verify:` step plus lint and typecheck for the touched scope.
- Tick `[x]` for the finished task in `tasks.md` and refresh `updated`.

If `$ARGUMENTS` is a work-item slug and tasks remain, do the next unblocked task
only. If it is a task ID, do just that task. If empty, ask which work item to
build, or list candidates from `work/`.

Rules: never commit, push, or open a PR; never edit another phase's artifact
except ticking `tasks.md` boxes. Leave a task unchecked if it cannot be verified.
End with the handoff block.
