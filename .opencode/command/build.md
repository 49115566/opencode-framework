---
description: "Implement a work item's tasks. Usage: /build [slug or task-id]"
agent: builder
---

Run the **Build** phase for: $ARGUMENTS

Follow your Builder agent instructions exactly. In particular:

- Read `AGENTS.md`, then the work item's `spec.md`, `design.md`, and `tasks.md`.
- Resolve the project's test, lint, and typecheck commands via the
  `project-discovery` skill if `AGENTS.md` does not already state them.
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
