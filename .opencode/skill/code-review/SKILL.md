---
name: code-review
description: Use when reviewing a diff or pull request, classifying findings by severity, or writing review comments. Triggers during /review and whenever code quality, security, or correctness of a change is assessed.
---

# Code review

Review to protect the codebase and to teach, not to demonstrate cleverness. The
goal is a correct, secure, maintainable change that satisfies the spec.

## Order of attention

1. **Correctness** — does it do what the spec says, including edge cases?
2. **Security** — input validation, injection, authz, secret handling, unsafe
   deserialization.
3. **Tests** — do they exercise the acceptance criteria and would they fail if
   the code were wrong?
4. **Fit** — does it follow the repository's conventions and structure?
5. **Scope** — does it change only what the task requires?
6. **Performance** — only where it matters (hot paths, large data, N+1 queries).

## Severity

- **Blocker** — incorrect, insecure, or breaks an acceptance criterion. Must fix.
- **Major** — a real defect or design problem likely to cause trouble. Fix before
  merge unless the user accepts the risk.
- **Minor** — worth fixing; not merge-blocking.
- **Nit** — style or preference; the author may decline.

## Finding format

Every finding includes four things:

```
[B1] Title — `path/to/file.ts:42`
Why it matters (one or two sentences, concrete).
Recommendation: the specific change to make.
```

- Cite the exact location. A finding without one is unactionable.
- Explain the *why*, not just the *what*. Link the failure mode or the criterion.
- Be specific about the fix; do not say "consider refactoring".
- Separate facts from opinions; label preferences as nits.

## What reviewers commonly miss

- The acceptance criteria themselves — review the spec, not only the code.
- Missing tests for error and edge cases.
- Silent behavior changes in neighboring code.
- Scope creep: unrelated refactors, reformatting, or dependency additions.
- Secrets, debug logging, and commented-out code.
- Error handling that swallows failures or leaks internals.

## Verdict

- `request-changes` if any Blocker or Major survives scrutiny.
- `approve` otherwise. Approving is not a rubber stamp; state why it is ready.
- Never invent blockers to seem thorough, and never approve to be agreeable.

## Disputed findings

A finding can be disputed, and there is a recorded route for it. A `review.md`
finding — or a defect reported in `verify.md` — is contested by appending a
challenge entry to the item's committed `challenges.md`; the phase that produced
the finding re-evaluates it and appends the decision. Never silently comply with
or override a disputed finding, and never leave it as obey-or-ignore: use the
authority `docs/workflow.md` → "Findings challenge and adjudication", with the
record shapes in `docs/artifact-conventions.md`.

Adjudicating a sustained challenge recomputes the verdict: `approve` if and only
if no Blocker or Major remains. Reuse the severity scale above and the
`approve`/`request-changes` verdict — a challenge introduces no second severity
scale, finding format, or verdict.
