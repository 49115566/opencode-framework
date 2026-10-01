# Artifact conventions

Every workflow artifact is a Markdown file under `work/<NNNN-slug>/` with YAML
frontmatter. Agents must follow these formats exactly so that other phases and
`/status` can parse them deterministically.

## Frontmatter

Every artifact begins with:

```yaml
---
feature: 0001-add-dark-mode   # <NNNN-slug>, matches the directory name
phase: spec                   # spec | design | tasks | test | visual | review | ship
status: draft                 # draft | final | blocked
created: 2026-01-31           # ISO-8601 date, first creation
updated: 2026-02-04           # ISO-8601 date, last edit
notes: ""                     # optional: skipped phases, caveats
---
```

Rules:

- `feature` is always the directory name, not the title.
- `created` never changes; `updated` changes on every edit.
- `status: final` means the owning agent considers the artifact complete for its
  phase. `blocked` means work cannot proceed without user input; say why in the
  body.
- Never remove frontmatter. Never edit a file owned by another phase.

## Task IDs

Tasks are `T1`, `T2`, … within an item. Reference them in commit messages and
in `[depends: T1]` annotations. Check boxes are `- [ ]` / `- [x]`.

## Templates

### `spec.md` (product)

```markdown
---
feature: NNNN-slug
phase: spec
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# <Feature title>

## Problem

Why this matters, who is affected, and what is painful or missing today.

## Goals

- <Outcome-oriented, verifiable.>

## Non-goals

- <Explicitly out of scope, to prevent scope creep.>

## Users and stories

- **As a** <role>, **I want** <capability>, **so that** <benefit>.

## Acceptance criteria

Numbered so design tasks and tests can reference them.

1. **AC1** — Given <context>, when <action>, then <observable result>.
2. **AC2** — ...

## Edge cases

- <Unusual inputs, empty states, errors, concurrency, limits.>

## Open questions

- [ ] <Question> — owner: <user/agent>, needed by: <phase>.

## Dependencies and constraints

- <External systems, existing features, deadlines, compatibility.>
```

Acceptance criteria must be observable and testable. If a criterion cannot be
turned into a test, rewrite it or move it to non-goals.

### `design.md` (architect)

```markdown
---
feature: NNNN-slug
phase: design
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Design — <Feature title>

## Summary

The chosen approach in two or three sentences.

## Approach

How the change works, with the interfaces, types, and data flow it touches.

## Alternatives considered

- **<Option>** — pros / cons / why rejected.

## Interfaces and data model

Signatures, schemas, migrations, public API changes, backward compatibility.

## Affected areas

Files, modules, and systems expected to change. Cite existing paths.

## Risks and mitigations

- **<Risk>** — likelihood / impact / mitigation.

## Test strategy

How each acceptance criterion will be verified (unit, integration, e2e, manual).
```

### `tasks.md` (architect; builder updates boxes)

```markdown
---
feature: NNNN-slug
phase: tasks
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Tasks — <Feature title>

Ordered, dependency-aware. One task ≈ one focused commit.

- [ ] **T1** — <Imperative description>. [AC1]
      Verify: <command or observable check>.
- [ ] **T2** — <description>. [AC2] [depends: T1]
      Verify: <...>.
```

Each task names the acceptance criteria it satisfies and how to verify it. A
task is not done until its `Verify:` step passes.

### `verify.md` (tester)

```markdown
---
feature: NNNN-slug
phase: test
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Verification — <Feature title>

## Commands run

| Command        | Result | Notes |
| -------------- | ------ | ----- |
| `<test cmd>`   | PASS   | ...   |

## Acceptance coverage

| Criterion | Test(s)                        | Result |
| --------- | ------------------------------ | ------ |
| AC1       | `path/to/test.ts::case`        | PASS   |
| AC2       | manual: <steps / reason>       | MANUAL |

## Gaps and residual risk

- <Untested cases, flaky areas, follow-ups.>
```

### `visual.md` (visual) — optional, for UI-bearing work

Only produced when the work item has a user-facing surface. Screenshots live
beside it under `work/<slug>/visual/`.

```markdown
---
feature: NNNN-slug
phase: visual
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Visual QA — <Feature title>

## Environment

- URL: <url>
- Server: <how it was started, or "already running">
- Model vision: <image-aware | text-only>
- Viewports: 375×812, 768×1024, 1440×900

## Console and network

- Console errors: <n or none> — <summary>
- Failed core requests: <n or none> — <summary>

## Acceptance coverage (UI)

| Criterion | Route / flow | Result |
| --------- | ------------ | ------ |
| AC1       | `/settings`  | PASS   |

## Findings

### Blockers

- **[VB1] <title>** — `<route>` <element>, <viewport/state>
  What is wrong. Evidence: `visual/<file>.png`.

### Major

- ...

### Minor

- ...

### Nits

- ...

## Evidence

- `work/<slug>/visual/desktop.png`, `mobile.png`, ...

## Verdict

**approve** | **request-changes** — one sentence.
```

Severity uses the same Blocker / Major / Minor / Nit scale as `review.md`.

### `review.md` (reviewer)

```markdown
---
feature: NNNN-slug
phase: review
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Review — <Feature title>

## Verdict

**approve** | **request-changes** — one sentence of justification.

## Findings

### Blockers

- **[B1] <title>** — `path:line`
  Why it blocks. Recommended fix.

### Major

- **[M1] <title>** — `path:line` ...

### Minor

- ...

### Nits

- ...

## Not reviewed

- <Anything deliberately out of scope for this pass.>
```

Severity meanings:

- **Blocker** — incorrect, insecure, or breaks an acceptance criterion. Must fix.
- **Major** — a real defect or design problem likely to cause trouble. Fix before
  merge unless the user accepts the risk.
- **Minor** — worth fixing; not merge-blocking.
- **Nit** — style or preference; take it or leave it.

### `ship.md` (shipper, optional but recommended)

```markdown
---
feature: NNNN-slug
phase: ship
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Ship record — <Feature title>

- Branch: `<branch>`
- PR: <url>
- Commits: <short hashes + subjects>
```

## Sequence allocation

To allocate `NNNN`, list `work/`, parse the numeric prefix of each directory,
take the maximum, and add one. If `work/` is empty, start at `0001`. Never reuse
a number, even if the directory was deleted.
