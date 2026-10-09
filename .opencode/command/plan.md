---
description: "Design a solution and break it into tasks from an approved spec. Usage: /plan <item-ref>"
agent: architect
---

Run the **Design** phase for the work item: $ARGUMENTS

Follow your Architect agent instructions exactly. In particular:

- Re-entry: read `work/<item-ref>/backtracks.md` for an entry whose target phase
  is `/plan` with no matching `## Resolution` (see `docs/workflow.md` → "Phase
  reversal (backtracking)" → "Re-entry"). If one is open, revise
  `design.md`/`tasks.md` for it, append a `## Resolution <n>` entry, clear the
  `stale:` marker on any artifact you own that you re-ran, and resume forward;
  with no open finding, plan as ordinary progression.
- Read the work item's `spec.md` first, plus `AGENTS.md`,
  `docs/workflow.md`, and `docs/artifact-conventions.md`.
- If `spec.md` is ambiguous or wrong, take the `/plan`→`/spec` reverse edge:
  append a `## Finding <n>` entry to `work/<item-ref>/backtracks.md` (detecting
  `/plan`, target `/spec`, affected `spec.md`, `status: open`), mark the existing
  downstream artifacts (`design.md`, `tasks.md`, `verify.md`, `review.md`)
  `stale: spec`, do not edit `spec.md`, and end with `Next: /spec <item-ref>`.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Recon the affected code and its conventions. Delegate broad recon to the
  `scout` subagent.
- Evaluate at least one real alternative before choosing an approach.
- Write `work/<item-ref>/design.md` and `work/<item-ref>/tasks.md` using the
  templates in `docs/artifact-conventions.md`.
- Author the plan's declared conflict targets as the `conflicts-with` value in
  `design.md` frontmatter, using the grammar in `docs/workflow.md` → "Declared
  conflicts (`conflicts-with`)" (`—` when the plan declares none); do not restate
  that grammar.
- Ensure every acceptance criterion maps to at least one task, and every task has
  a `Verify:` step and its dependencies annotated.
- Run the design quality bar and set `status: final`.
- If a `plan/<ref>` pull request is denied, closed, or sent back for changes,
  re-run `/plan <item-ref>` to revise the plan and republish with
  `/ship plan <item-ref>` on the same branch (a new PR if the branch was pruned);
  never force-push. This plan-publication revision flow is not a backtrack.

If `$ARGUMENTS` is empty, ask which work item to plan, or list candidates by
reading `work/`. If `spec.md` is missing or ambiguous, take the `/plan`→`/spec`
reverse edge above rather than designing from assumptions.

Do not write any code. End with the handoff block whose `Next:` is
`/spec <item-ref>` if you took the `/plan`→`/spec` reverse edge, otherwise
`/ship plan <item-ref>` — the plan is published and merged before development
begins.
