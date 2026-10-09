---
description: "Verify the implementation against the spec and record test evidence. Usage: /test [item-ref]"
agent: tester
---

Run the **Test** phase for: $ARGUMENTS

Follow your Tester agent instructions exactly. In particular:

- Read the work item's `spec.md`, `design.md`, `tasks.md`, and the diff.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Confirm the test command via the `project-discovery` skill if needed.
- Build a coverage matrix mapping every acceptance criterion and edge case to a
  test or to a documented manual/untestable reason.
- Add focused tests for gaps. Do not modify production code; if the fault is in
  the implementation, stop and report it as a defect with a minimal reproduction.
- If `work/<item-ref>/challenges.md` holds an open challenge against a
  `verify.md` defect, adjudicate it first: re-evaluate the defect, append a
  `## Response <n>` recording `adjudicator`, `decision`, `basis`, and `outcome`,
  and revise `verify.md` only when sustained; when unresolved escalate on the
  question surface and record the user's decision. Never adjudicate a challenge
  you raised. See `docs/workflow.md` → "Findings challenge and adjudication".
- Classify each defect before handing it off: an implementation defect routes to
  `/build <item-ref>` to fix first, while a defect that is really a spec or design
  fault is routed upstream — append a `backtracks.md` `Finding <n>` entry, mark the
  downstream artifacts `stale:` per `docs/workflow.md` → "Phase reversal
  (backtracking)", do not edit the upstream artifact, and hand off
  `Next: /plan <item-ref>` or `Next: /spec <item-ref>`. When the classification is
  unresolved, record the question and escalate rather than guess.
- Write `work/<item-ref>/verify.md` using the template in
  `docs/artifact-conventions.md`, then set `status: final` (or `blocked`).

If `$ARGUMENTS` is empty, ask which work item to verify, or list candidates from
`work/`. If the work item has no tests configured at all, report that and ask how
to proceed.

Never weaken, skip, or delete a test to obtain a pass. End with the handoff block.
