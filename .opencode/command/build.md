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
- After a **PROCEED** outcome from that gate, run the read-only focused
  declared-conflict check for the item (`docs/workflow.md` →
  `## Declared-conflict check`) and print the findings that involve it before
  selecting a task. The findings are advisory: they never change the gate outcome
  and never stop the build, and the check itself performs no fetch (the gate's own
  best-effort ref refresh is separate).
- Implement the requested task, or the next unblocked unchecked task if none is
  named. State which task you are doing.
- If the design is wrong — the task cannot be implemented as designed — take the
  `/build`→`/plan` reverse edge (see `docs/workflow.md` → "Phase reversal
  (backtracking)") instead of improvising: append a `## Finding <n>` entry to
  `work/<item-ref>/backtracks.md` (detecting `/build`, target `/plan`, affected
  `design.md` and `tasks.md`, `status: open`), mark every existing artifact
  strictly downstream of `/plan` (`verify.md`, `review.md`) `stale: design`, do
  not edit `design.md`, `tasks.md`, or `spec.md`, leave the task unchecked, and
  end the handoff with Next: `/plan <item-ref>`.
- To dispute a `review.md` finding or a `verify.md` defect instead of complying
  with or overriding it, raise a challenge: append a `## Challenge <n>` entry to
  `work/<item-ref>/challenges.md` (`type`, `evidence`, `rationale`), never edit
  the producing phase's artifact, and hand off to the producing phase —
  `Next: /review <item-ref>` for a review finding, `Next: /test <item-ref>` for
  a verify defect (see `docs/workflow.md` → "Findings challenge and
  adjudication").
- Follow existing conventions; keep the change scoped to the task.
- Run the task's `Verify:` step plus lint and typecheck for the touched scope.
- Tick `[x]` for the finished task in `tasks.md` and refresh `updated`.

If `$ARGUMENTS` is a work-item slug and tasks remain, do the next unblocked task
only. If it is a task ID, do just that task. If empty, ask which work item to
build, or list candidates from `work/`.

Rules: never commit, push, or open a PR; never edit another phase's artifact
except ticking `tasks.md` boxes. Leave a task unchecked if it cannot be verified.
End with the handoff block.
