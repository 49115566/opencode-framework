---
description: "Ship an approved work item as a branch, conventional commits, and a PR. Usage: /ship [item-ref]"
agent: shipper
---

Run the **Ship** phase for: $ARGUMENTS

Follow your Ship agent instructions exactly. In particular:

- Verify the preconditions: `review.md` verdict is `approve` (or the user
  explicitly overrides), the tree contains only work-item changes, no secrets are
  present, and tests/lint/typecheck pass.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Determine the default branch and current branch.
- Create or switch to a branch named per the `conventional-commits` skill
  (`<type>/<ref>`, where `<ref>` is the canonical reference — a roadmap child's
  `NNNN-slug/MMMM-slug` becomes `NNNN-slug-MMMM-slug`).
- Stage and commit in logical units with conventional messages, scanning staged
  content for secrets first.
- Push (this requires approval), then open a PR using the `pr-workflow` template,
  linking the spec, design, verification, and review artifacts.
- Write `work/<item-ref>/ship.md` with the branch, commit subjects, and PR URL (or
  "not created"), then stage and commit it (`docs(work): record ship state for
  <item-ref>`) and push the branch (this requires approval). This is required: its
  presence is the sole shipped signal, so commit it even when `gh` is unavailable
  and only local commits exist. Leave no uncommitted `ship.md` — the signal must
  travel on the branch.

If `$ARGUMENTS` is empty, ask which work item to ship, or list candidates from
`work/`.

Never merge, approve, force-push, or push to the default branch. If `gh` is
unavailable or unauthenticated, make the local commits and report the exact
commands for the user to run. End with the handoff block.
