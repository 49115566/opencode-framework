---
description: "Design a solution and break it into tasks from an approved spec. Usage: /plan <item-ref>"
agent: architect
---

Run the **Design** phase for the work item: $ARGUMENTS

Follow your Architect agent instructions exactly. In particular:

- Read the work item's `spec.md` first, plus `AGENTS.md`,
  `docs/workflow.md`, and `docs/artifact-conventions.md`.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Recon the affected code and its conventions. Delegate broad recon to the
  `scout` subagent.
- Evaluate at least one real alternative before choosing an approach.
- Write `work/<item-ref>/design.md` and `work/<item-ref>/tasks.md` using the
  templates in `docs/artifact-conventions.md`.
- Ensure every acceptance criterion maps to at least one task, and every task has
  a `Verify:` step and its dependencies annotated.
- Run the design quality bar and set `status: final`.

If `$ARGUMENTS` is empty, ask which work item to plan, or list candidates by
reading `work/`. If `spec.md` is missing or ambiguous, stop and recommend
`/spec` rather than designing from assumptions.

Do not write any code. End with the handoff block.
