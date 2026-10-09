---
description: "Perform a read-only review of a work item's diff. Usage: /review [item-ref]"
agent: reviewer
---

Run the **Review** phase for: $ARGUMENTS

Follow your Review agent instructions exactly. In particular:

- Read `work/<item-ref>/spec.md`, `design.md`, `tasks.md`, and `verify.md`.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- If `work/<item-ref>/challenges.md` holds an open challenge against a
  `review.md` finding, adjudicate it first: re-evaluate the finding against the
  spec and diff, append a `## Response <n>` recording `adjudicator`, `decision`,
  `basis`, and `outcome`, and — when sustained — revise `review.md` and recompute
  the verdict (`approve` if and only if no `Blocker` or `Major` remains); when
  rejected leave the finding and verdict unchanged; when unresolved escalate on
  the question surface and record the user's decision. Never adjudicate a
  challenge you raised. See `docs/workflow.md` → "Findings challenge and
  adjudication".
- Determine the base ref and produce the full diff. State the exact commands you
  used. If the base is ambiguous, ask rather than reviewing the wrong range.
- Walk every acceptance criterion and mark it met / partial / not met.
- Review for correctness, security, tests, convention fit, scope, and
  performance. Apply the `code-review` skill's severity definitions and finding
  format.
- Write `work/<item-ref>/review.md` with a verdict of `approve` or
  `request-changes`, then set `status: final`.

If `$ARGUMENTS` is empty, ask which work item to review, or list candidates from
`work/`.

You are read-only: never edit source code, config, or tests — write only
`review.md`. Approve on evidence, not to be agreeable; do not invent blockers.
End with the handoff block.
