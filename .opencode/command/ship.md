---
description: "Ship an approved work item as a branch, conventional commits, and a PR. Usage: /ship [slug]"
agent: shipper
---

Run the **Ship** phase for: $ARGUMENTS

Follow your Ship agent instructions exactly. In particular:

- Verify the preconditions: `review.md` verdict is `approve` (or the user
  explicitly overrides), the tree contains only work-item changes, no secrets are
  present, and tests/lint/typecheck pass.
- Determine the default branch and current branch.
- Create or switch to a branch named per the `conventional-commits` skill
  (`<type>/<NNNN-slug>`).
- Stage and commit in logical units with conventional messages, scanning staged
  content for secrets first.
- Push (this requires approval), then open a PR using the `pr-workflow` template,
  linking the spec, design, verification, and review artifacts.
- Optionally write `work/<slug>/ship.md` with the branch, commit hashes, and PR
  URL.

If `$ARGUMENTS` is empty, ask which work item to ship, or list candidates from
`work/`.

Never merge, approve, force-push, or push to the default branch. If `gh` is
unavailable or unauthenticated, make the local commits and report the exact
commands for the user to run. End with the handoff block.
