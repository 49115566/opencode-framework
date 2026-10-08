---
name: pr-workflow
description: Use when creating or describing a pull request during /ship. Covers PR titles, description templates, linking artifacts, gh commands, and review etiquette.
---

# Pull request workflow

A PR is a handoff to a human reviewer. It should let them understand and trust
the change without reconstructing the whole workflow.

## Preconditions

- The branch is up to date with the base branch, or the divergence is explained.
- Tests, lint, and typecheck pass; cite the evidence.
- The diff contains no secrets, debug code, or unrelated changes.
- `work/<item-ref>/review.md` records an approving verdict (or the override is noted).
  A fix-landing PR (`/ship fix`) has no work item and no `review.md`, so this
  precondition does not apply to it: a fix is gated on an established
  reproduction, a regression test that fails before the change and passes after,
  and green test/lint/typecheck instead.

## Title

Same convention as commits: `<type>(<scope>): <imperative summary>`. Keep it
under ~72 characters. The PR title will become the squash-merge subject.

## Description template

```markdown
## Summary

<What this changes and why, in two or three sentences. Link the work item.>

## Changes

- <Notable change, grouped by area.>

## Testing

- `<command>` → <result>
- Acceptance criteria covered: <AC1, AC2, ...>

## Conflict detection

- <The read-only pre-flight result: one line per finding in the
  `[<CODE>] (<class>) <offender(s)> — <detail>` form (classes (a)–(d)), or
  `No conflicts detected`.>

## Reconcile

- Result: <reconciled | no-op (already up to date) | blocked: <reason>>
- Resolved paths:
  - `<path>` — <how both branches' intents were preserved>
- Re-verification: <the repository's own configured test command — the Project profile `Test:` value> → <result>; <item checks> → <result>

## Risks

- <Risk and mitigation, or "None identified.">

## Artifacts

Workflow artifacts under `work/` are committed working state, so these paths
exist on the branch and resolve for a reviewer who does not share the author's
working tree:

- Spec: `work/<item-ref>/spec.md`
- Design: `work/<item-ref>/design.md`
- Verification: `work/<item-ref>/verify.md`
- Review: `work/<item-ref>/review.md`
```

## Fix PR description template

A `/fix` landed with `/ship fix` has no work item, so its pull request uses this
body instead. It has **no** `## Artifacts` section, because no `work/` artifact
exists; the evidence travels in the description:

```markdown
## Summary

<What changed and why, in one or two sentences.>

## Reproduction

<The failing test or exact repro.>

## Root cause

<One sentence.>

## Change

- <Notable changes.>

## Testing

- `<command>` → <result>
- Regression test: fails without the change, passes with it.

## Risks

- <Risk and mitigation, or "None identified.">
```

If the user explicitly accepts a missing regression test, state that acceptance
here so the gap is recorded for the reviewer.

## Plan PR description template

A plan published by `/ship plan <item-ref>` before development begins uses this
body. It omits the ship-time `## Conflict detection` and `## Reconcile` sections,
which are merge-time only, and it has no `verify.md`/`review.md` links because
those artifacts do not exist yet. Its `Declared conflicts` value is the item's
`design.md` frontmatter `conflicts-with` value; the grammar is the single
authority in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)" and is
not restated here.

```markdown
## Summary

<The work item's plan, published before development begins. Ref: <item-ref>.>

## Declared conflicts

- <the item's `design.md` `conflicts-with` value, or `—`>

## Plan artifacts

- Spec: `work/<item-ref>/spec.md`
- Design: `work/<item-ref>/design.md`
- Tasks: `work/<item-ref>/tasks.md`

## Testing

- <the project's configured test command result, or "plan-only; no code changed">
```

## Commands

```bash
gh auth status                                   # confirm authentication
gh repo view --json defaultBranchRef -q .defaultBranchRef.name
git switch -c feat/0001-add-dark-mode
# ... commits ...
git push -u origin HEAD
gh pr create --title "feat: add dark mode" --body-file <(cat <<'EOF'
...
EOF
)
```

Or pass `--body` with the rendered description. Prefer `--body-file` for
multi-line bodies.

## Etiquette

- Do not merge your own PR unless the user asks.
- Do not force-push a branch under review. Add commits instead; collapse only if
  the reviewer asks.
- Keep the description current when the change evolves.
- Respond to review findings with changes or a reasoned decline, never silence.

## If gh is unavailable

Complete the local commits, then give the user the exact commands to push and
open the PR. Do not leave the work uncommitted without saying so.
