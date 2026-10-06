---
name: conventional-commits
description: Use when writing commit messages or naming branches for /ship and /fix. Covers Conventional Commits types, scopes, breaking changes, and branch naming.
---

# Conventional commits and branch naming

## Commit message format

```
<type>(<optional scope>): <imperative subject>

<optional body: what and why, wrapped at 72 columns>

<optional footer: BREAKING CHANGE, Refs, Co-authored-by>
```

- Subject in the imperative mood: "add token refresh", not "added" or "adds".
- Subject lower-case, no trailing period, at most ~72 characters.
- The body explains *why*, not *what* (the diff shows what). Leave a blank line
  after the subject.
- One logical change per commit. If you need "and" in the subject, split it.

## Types

| Type       | Use for                                             |
| ---------- | --------------------------------------------------- |
| `feat`     | A new user-facing capability.                       |
| `fix`      | A bug fix.                                          |
| `docs`     | Documentation only.                                 |
| `refactor` | Behavior-preserving code change.                    |
| `perf`     | Performance improvement.                            |
| `test`     | Adding or fixing tests only.                        |
| `style`    | Formatting, whitespace, no behavior change.         |
| `build`    | Build system or dependencies.                       |
| `ci`       | CI configuration.                                   |
| `chore`    | Maintenance not covered above.                      |
| `revert`   | Reverting a previous commit.                        |

## Scopes

Use the affected module or area when it clarifies: `feat(auth): add token
refresh`. Keep scopes short and consistent with the repo's vocabulary.

## Breaking changes

Add `!` after the type/scope and a footer: `feat(api)!: drop v1 endpoints`
followed by `BREAKING CHANGE: <migration notes>`.

## Branch naming

```
<type>/<ref-or-short-description>
```

`<ref>` is the work item's canonical reference: `NNNN-slug` for a standalone
item, or `NNNN-slug/MMMM-slug` for a roadmap child with the `/` replaced by `-`
(`NNNN-slug-MMMM-slug`). Joining the two segments keeps the branch a single ref —
two children of one roadmap must not map to the same branch — while still
identifying the exact child work item.

A fix with no work item — a `/fix` landed with `/ship fix` — has no canonical
reference, so name its branch `fix/<short-description>`: the `fix` type plus a
short kebab-case description of the defect, e.g. `fix/login-timeout`. Never reuse
a work item's branch for a fix.

Examples: `feat/0001-add-dark-mode`,
`feat/0002-agentic-roadmaps-0001-roadmap-model`, `fix/login-timeout`,
`docs/update-readme`.

## Rules

- Never commit secrets, generated artifacts, or `.env` files.
- Never amend or force-push a commit that has been pushed.
- Reference artifacts in the body when useful: `Refs: work/0001-add-dark-mode`.
