---
description: "Ship an approved work item as a branch, conventional commits, and a PR. Usage: /ship [item-ref]"
agent: shipper
---

Run the **Ship** phase for: $ARGUMENTS

Follow your Ship agent instructions exactly. The argument grammar is:

```
/ship [item-ref | fix [short description]]
  item-ref  -> work-item mode (unchanged)
  fix       -> fix-landing mode (new); the optional description disambiguates
  (empty)   -> ask which work item to ship (unchanged)
```

**Work-item mode** (`/ship <item-ref>`):

- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Verify the preconditions: `review.md` verdict is `approve` (or the user
  explicitly overrides), the tree contains only work-item changes, no secrets are
  present, and tests/lint/typecheck pass.
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

**Fix-landing mode** (`/ship fix [short description]`):

- The user's explicit `/ship fix` request is the consent to commit, push, and open
  a PR; without it, perform no git write.
- Require an established reproduction, a regression test that fails without the
  fix and passes with it, and green test/lint/typecheck for the touched scope. A
  failed check or an unreproduced defect blocks landing. No independent `review.md`
  is required — a documented exception to the approved-work-item precondition; if
  no regression test exists, landing is blocked unless the user explicitly accepts
  the gap, and the acceptance must be stated in the PR.
- Stage only the fix's files (never `git add -A`; ask when the boundary is
  unclear) and scan them for secrets before committing.
- Create or switch to a `fix/<short-description>` branch (never the default
  branch) and commit the change and its regression test as conventional commits.
- Push (this requires approval), then open a PR using the `pr-workflow` fix
  template, whose description records the reproduction, root cause, change, and
  check results. A fix PR has no artifact links and no `## Artifacts` section.
- Do **not** write `ship.md`: a fix creates no work item and no shipped-state
  record. Report the branch, commits, and PR; when `gh` is unavailable, finish the
  local commits and report the exact commands to push and open the PR.

If `$ARGUMENTS` is empty, ask which work item to ship, or list candidates from
`work/`.

Never merge, approve, force-push, or push to the default branch. If `gh` is
unavailable or unauthenticated, make the local commits and report the exact
commands for the user to run. End with the handoff block.
