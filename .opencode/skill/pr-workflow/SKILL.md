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
- `work/<slug>/review.md` records an approving verdict (or the override is noted).

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

## Risks

- <Risk and mitigation, or "None identified.">

## Artifacts

- Spec: `work/NNNN-slug/spec.md`
- Design: `work/NNNN-slug/design.md`
- Verification: `work/NNNN-slug/verify.md`
- Review: `work/NNNN-slug/review.md`
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
