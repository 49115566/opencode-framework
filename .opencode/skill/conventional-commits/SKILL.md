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

A work item's branch name is derived from its canonical reference
(`NNNN-slug`, or `NNNN-slug/MMMM-slug` for a nested child) by one collision-free,
reversible rule — **`flatten(ref)`** — which joins the reference's
`/`-separated segments with `+`:

```
flatten(ref) = ref.split("/").join("+")
```

A canonical reference segment is `[0-9]{4}-[a-z0-9-]+`, so it can never contain
`+`. That makes `+` a reserved boundary and the mapping an exact inverse:
`ref.split("/").join("+")` and `flat.split("+")` round-trip, so two distinct
references at **any depth** always flatten to two distinct strings. A
single-segment reference is unchanged by the rule.

The **same** flattened token names both branch kinds; only the prefix differs:

- a **ship branch** is `<type>/<flatten(ref)>`, where `<type>` is the commit type
  (`feat`, `fix`, `docs`, …);
- a **plan-publication branch** — `/ship plan <item-ref>` before development
  begins (see `docs/workflow.md` → "Plan publication") — is
  `plan/<flatten(ref)>`. The fixed `plan` prefix replaces the `<type>` segment and
  marks the branch as the pre-development plan rather than the item's final ship
  branch: never reuse the plan branch for the ship.

| Canonical reference | `flatten(ref)` |
| ------------------- | -------------- |
| `0001-add-dark-mode` | `0001-add-dark-mode` |
| `0002-billing/0001-invoice-model` | `0002-billing+0001-invoice-model` |
| `0001-a/0002-b/0003-c` | `0001-a+0002-b+0003-c` |

Examples: `feat/0001-add-dark-mode`,
`feat/0002-billing+0001-invoice-model`,
`plan/0002-billing+0001-invoice-model`, `fix/login-timeout`,
`docs/update-readme`.

**Superseded form.** An older rule joined a nested reference by replacing `/`
with `-` (`0002-billing-0001-invoice-model`). Because `-` is legal
**inside** a segment, that mapping was not injective: a nested child and a
distinct top-level item literally named `NNNN-slug-MMMM-slug` could share one
branch name. `flatten` above replaces it; a pre-existing, unmerged branch under
the superseded form is not recognized (see `docs/workflow.md` → "Plan
publication").

A fix with no work item — a `/fix` landed with `/ship fix` — has no canonical
reference, so name its branch `fix/<short-description>`: the `fix` type plus a
short kebab-case description of the defect, e.g. `fix/login-timeout`. Never reuse
a work item's branch for a fix.

## Rules

- Never commit secrets, generated artifacts, or `.env` files.
- Never amend or force-push a commit that has been pushed.
- Reference artifacts in the body when useful: `Refs: work/0001-add-dark-mode`.
