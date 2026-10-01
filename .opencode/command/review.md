---
description: "Perform a read-only review of a work item's diff. Usage: /review [slug]"
agent: reviewer
---

Run the **Review** phase for: $ARGUMENTS

Follow your Review agent instructions exactly. In particular:

- Read `work/<slug>/spec.md`, `design.md`, `tasks.md`, and `verify.md`.
- Determine the base ref and produce the full diff. State the exact commands you
  used. If the base is ambiguous, ask rather than reviewing the wrong range.
- Walk every acceptance criterion and mark it met / partial / not met.
- Review for correctness, security, tests, convention fit, scope, and
  performance. Apply the `code-review` skill's severity definitions and finding
  format.
- Write `work/<slug>/review.md` with a verdict of `approve` or
  `request-changes`, then set `status: final`.

If `$ARGUMENTS` is empty, ask which work item to review, or list candidates from
`work/`.

You are read-only: never edit source code, config, or tests — write only
`review.md`. Approve on evidence, not to be agreeable; do not invent blockers.
End with the handoff block.
