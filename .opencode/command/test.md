---
description: "Verify the implementation against the spec and record test evidence. Usage: /test [slug]"
agent: tester
---

Run the **Test** phase for: $ARGUMENTS

Follow your Tester agent instructions exactly. In particular:

- Read the work item's `spec.md`, `design.md`, `tasks.md`, and the diff.
- Confirm the test command via the `project-discovery` skill if needed.
- Build a coverage matrix mapping every acceptance criterion and edge case to a
  test or to a documented manual/untestable reason.
- Add focused tests for gaps. Do not modify production code; if the fault is in
  the implementation, stop and report it as a defect with a minimal reproduction.
- Write `work/<slug>/verify.md` using the template in
  `docs/artifact-conventions.md`, then set `status: final` (or `blocked`).

If `$ARGUMENTS` is empty, ask which work item to verify, or list candidates from
`work/`. If the work item has no tests configured at all, report that and ask how
to proceed.

Never weaken, skip, or delete a test to obtain a pass. End with the handoff block.
