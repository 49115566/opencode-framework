---
description: "Ship an approved work item as a branch, conventional commits, and a PR. Usage: /ship [item-ref] | /ship fix [short description] | /ship plan <item-ref> | /ship recall <item-ref> <phase>"
agent: shipper
---

Run the **Ship** phase for: $ARGUMENTS

Follow your Ship agent instructions exactly. The argument grammar is:

```
/ship [item-ref | plan <item-ref> | fix [short description] | recall <item-ref> <phase>]
  item-ref  -> work-item mode (unchanged)
  plan      -> plan-publication mode (new); publishes the plan before development
  fix       -> fix-landing mode (new); the optional description disambiguates
  recall    -> recall/reopen mode (new); post-ship denial; <phase> ∈ {spec, design, build}
  (empty)   -> ask which work item to ship (unchanged)
```

**Work-item mode** (`/ship <item-ref>`):

- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Verify the preconditions: `review.md` verdict is `approve` (or the user
  explicitly overrides), the tree contains only work-item changes, no secrets are
  present, and tests/lint/typecheck pass.
- Run the read-only pre-flight per the `merge-conflict` skill before any ship
  operation — default branch, `git fetch`, merge base, changed paths, the
  `git merge-tree` dry-run, classification, and the framework-integrity checks.
  Report every finding with its class and offender, escalate a semantic conflict
  at the `0001` reconcile step rather than resolving it, and record the result
  (classes/paths found, or "no conflicts detected") in `ship.md` and the PR
  description. Detection never merges, rebases, or force-pushes.
- Reconcile first, after the read-only pre-flight and before the other ship
  operations, per the `merge-conflict` skill: merge the default branch forward
  with `git merge --no-edit origin/<default>`, resolve class (a) shared-surface
  conflicts preserving both sides, and, for class (b) `work/` conflicts and a
  class (c) duplicate sequence number, run the skill's `work/` artifact reconcile:
  merge `work/` artifact content preserving both sides, re-check the roadmap
  dependency graph, apply "Renumbering after a parallel merge" to a
  top-level/per-parent `NNNN`/`MMMM` collision — `git mv` the chosen item.
  Update every reference in one change so no reference to the old canonical
  reference remains, and never reuse a spent number. A clean merge that touched
  any `work/` path, or that carries a pre-flight class (b) or class (c) finding,
  is not finished: run the reconcile on the already-merged tree before
  re-verifying. Escalate an undecidable renumber
  or an intent fault rather than guessing: on a conflicted merge `git merge
  --abort`; on the clean-merge path the auto-created merge commit is not rewritten
  without user confirmation — report the blocked reference(s) and the decision the
  user must make. Record the `## Reconcile` section — resolved `work/` paths, any
  renumber as `<old> → <new>`, and re-verification evidence — in `ship.md` and the
  PR description, and never rebase or force-push.
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

**Plan-publication mode** (`/ship plan <item-ref>`):

- Publish the item's plan — `work/<item-ref>/spec.md`, `design.md`, and `tasks.md`
  when present — before development begins. This is a documented exception to the
  approved-work-item precondition, like fix mode: no `review.md` is required. The
  plan diff must contain no secrets.
- Create or switch to a dedicated `plan/<ref>` branch, where `<ref>` is the
  canonical reference with `/` replaced by `-` (a nested child's
  `NNNN-slug/MMMM-slug` becomes `NNNN-slug-MMMM-slug`); e.g.
  `plan/0006-parallel-plan-conflicts-0002-plan-record`. The plan branch is distinct
  from the item's final ship branch, and each item gets its own branch so
  concurrent publications are independent.
- Stage the plan artifacts under `work/<item-ref>/` (never `git add -A`), scan
  them for secrets, and commit them as one conventional commit
  (`docs(plan): record plan for <item-ref>`). Push (this requires approval), then
  open a PR using the `pr-workflow` plan template, which links the plan artifacts
  by repository path and prints the item's declared conflicts — its `design.md`
  frontmatter `conflicts-with` value per `docs/workflow.md` → "Declared conflicts
  (`conflicts-with`)" — or `—`.
- At least one human approval is required before the plan PR is merged. The
  shipper neither approves nor merges; the merge is a human action, and the
  repository may enforce approval via branch protection.
- Never write `ship.md`, never run the ship pre-flight or reconcile, and never
  create the final ship branch or PR. `ship.md` remains the sole shipped signal.
- A later `/plan` revision that changes the intended surfaces or declared targets
  is republished through the same flow: add a commit to the existing `plan/<ref>`
  branch and update its PR (or open a new one if the branch was pruned). Never
  force-push a pushed branch.
- Re-invoking publication when the plan is already on the default branch and
  unchanged is a no-op: report that and create nothing.
- When `gh` is unavailable, make the local commits on `plan/<ref>` and report the
  exact commands to push and open the PR.

**Recall/reopen mode** (`/ship recall <item-ref> <phase>`):

- Handle a PR that was denied, closed, or sent back for changes **after**
  `ship.md` was written. This is a documented mode of the work-item command; no
  new command, agent, or skill is added. The user's explicit invocation is the
  consent to record the revocation, and recording/revoking never requires the
  network.
- Verify the preconditions: `work/<item-ref>/ship.md` exists (an item with no
  `ship.md` is an ordinary backtrack, not a recall — refuse), and `<phase>` is one
  of the phase labels `spec | design | build`, i.e. strictly earlier than ship
  (`test`, `review`, and `ship` are refused).
- **Record the finding.** Append a `## Finding <n>` entry to
  `work/<item-ref>/backtracks.md`, creating the record with its frontmatter
  (`feature`, `record: backtracks`, `created`, `updated`) when absent. The
  detecting phase is `/ship`; numbering is sequential and append-only — never
  edit, reorder, or remove a prior entry:

  ```markdown
  ## Finding <n> — YYYY-MM-DD

  - detecting phase: `/ship`
  - target phase: `/build` | `/plan` | `/spec`
  - affected: `ship.md` (shipped signal revoked), plus the downstream
    artifacts marked `stale: <phase>`
  - evidence: <triggering condition — PR denied / closed / changes-requested, PR
    never opened, or branch abandoned — and its observable evidence>
  - status: open
  ```

- **Revoke the shipped signal.** Add the `reopened: <phase>` field to the
  existing `work/<item-ref>/ship.md` frontmatter and refresh `updated`; leave the
  recorded branch, commits, PR URL, and body intact. The marker is distinct from
  the frontmatter `status` and does not overload it.
- **Mark the downstream artifacts `stale: <phase>`**, reusing the
  non-destructive mechanical marking of the reverse edges. Whichever artifacts
  strictly downstream of the re-entry phase exist are marked; absent ones are
  skipped:

  | Re-entry phase | `ship.md` marker | Artifacts marked `stale:` |
  | -------------- | ---------------- | ------------------------- |
  | `build` (`/build`) | `reopened: build` | `verify.md`, `review.md` → `stale: build` |
  | `design` (`/plan`) | `reopened: design` | `verify.md`, `review.md` → `stale: design` |
  | `spec` (`/spec`) | `reopened: spec` | `design.md`, `tasks.md`, `verify.md`, `review.md` → `stale: spec` |

- **Commit and report.** Commit the revocation and the record on the item's
  branch (`docs(work): recall <item-ref>`). When no branch or network is
  available the mode makes the local commits and reports the exact commands the
  user runs to push. It runs no pre-flight and no reconcile, and never deletes,
  truncates, or rewrites the historical `ship.md` or any `backtracks.md` entry.
- **Hand off** `Next: /build <item-ref>`, `/plan <item-ref>`, or
  `/spec <item-ref>` per the phase. A second recall (after a re-ship and a new
  denial) appends a new finding and re-applies or updates the `reopened:` marker;
  no prior entry is erased and the marker names the latest re-entry phase.
- **Re-ship.** When `work/<item-ref>/ship.md` is present with a `reopened:` marker
  and a fresh `review.md` `approve`, the ordinary work-item path re-runs: reuse
  the branch recorded in `ship.md`, add commits, push without force, and update
  the existing PR — or open a new one when the branch was pruned. Never rebase a
  pushed branch, never force-push, never rewrite pushed history, and never delete
  or close the denied PR. Write a fresh `ship.md` **without** the `reopened:`
  marker, so the item derives `shipped` and satisfies its dependents again.

If `$ARGUMENTS` is empty, ask which work item to ship, or list candidates from
`work/`.

Never merge, approve, force-push, or push to the default branch. If `gh` is
unavailable or unauthenticated, make the local commits and report the exact
commands for the user to run. End with the handoff block.
