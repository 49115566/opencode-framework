# Artifact conventions

Every workflow artifact is a Markdown file under `work/<NNNN-slug>/` — or, for a
nested roadmap child, `work/<NNNN-slug>/<MMMM-slug>/` — with YAML frontmatter.
Agents must follow these formats exactly so that other phases and `/status` can
parse them deterministically.

Workflow artifacts under `work/` are **committed working state**:
version-controlled so a fresh clone, a teammate, and CI derive the same phase.
Only `scratch/` and opencode's generated state are ignored.

## Frontmatter

Every artifact begins with:

```yaml
---
feature: 0001-add-dark-mode   # canonical reference: <NNNN-slug>, or <NNNN-slug>/<MMMM-slug> for a nested child
phase: spec                   # spec | design | roadmap | tasks | test | visual | review | ship
status: draft                 # draft | final | blocked
created: 2026-01-31           # ISO-8601 date, first creation
updated: 2026-02-04           # ISO-8601 date, last edit
notes: ""                     # optional: skipped phases, caveats
parent: ""                    # optional: the parent <NNNN-slug> when this item is a nested roadmap child
---
```

Rules:

- `feature` is the item's canonical reference, not the title: the directory name
  `<NNNN-slug>` for a standalone item, or `<NNNN-slug>/<MMMM-slug>` for a child
  nested under a roadmap (see "Work item references").
- `parent` is optional and set only on a nested child's artifacts to the parent
  roadmap's `<NNNN-slug>`. Standalone items omit it.
- `created` never changes; `updated` changes on every edit.
- `status: final` means the owning agent considers the artifact complete for its
  phase. `blocked` means work cannot proceed without user input; say why in the
  body.
- `conflicts-with` is optional and appears only on `design.md`; it holds one
  `ConflictTargetList` declaring the item's intended conflict targets. Absent or
  `—` means no declared conflicts, and the declaration is advisory — it never
  affects phase derivation or readiness. The grammar is defined in
  `docs/workflow.md` → "Declared conflicts (`conflicts-with`)".
- Never remove frontmatter. Never edit a file owned by another phase.

## Work item references

A work item is addressed by a **canonical reference** — its path relative to
`work/`:

```
item-ref   ::= standalone | child
standalone ::= NNNN-slug                    e.g. 0007-billing
child      ::= NNNN-slug "/" MMMM-slug      e.g. 0002-agentic-roadmaps/0001-roadmap-model
```

Reference regex:
`^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$`.

- `NNNN` is the top-level sequence number. `MMMM` is the child's **local**
  sequence number, allocated per parent and independent of the top-level
  sequence and of other roadmaps.
- Any reference resolves to the directory `work/<item-ref>/`:
  `work/0007-billing/` for a standalone item, or
  `work/0002-agentic-roadmaps/0001-roadmap-model/` for a nested child.
- A **roadmap** is a parent work item identified by its `roadmap.md` artifact.
  Its child features are nested at `work/<NNNN-slug>/<MMMM-slug>/`. The parent
  holds only `roadmap.md`; each child later runs the ordinary per-feature
  lifecycle unchanged.
- Phase commands accept an `item-ref` wherever a `<slug>` was accepted before. A
  one-segment reference behaves exactly as it did before nesting existed, and
  standalone items require no `parent` and no roadmap metadata.

Nested children's artifacts set `feature` to the full canonical reference
(`<parent-NNNN-slug>/<child-MMMM-slug>`) and MAY set `parent:` to the parent's
`<NNNN-slug>`.

## Task IDs

Tasks are `T1`, `T2`, … within an item. Reference them in commit messages and
in `[depends: T1]` annotations. Check boxes are `- [ ]` / `- [x]`.

## Templates

### `roadmap.md` (roadmap) — parent item

A roadmap is the first-class planning artifact of a parent work item. It
enumerates child features and their intra-roadmap dependencies and is authored
before any child spec. It is not a single-feature artifact: the parent has no
spec, design, tasks, verification, or review of its own. The `Children` table is
the machine-readable source of the child set and dependency graph; `/status`
parses it directly.

```markdown
---
feature: NNNN-slug
phase: roadmap
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Roadmap — <initiative title>

## Initiative

What the initiative is and who it serves.

## Assumptions

- <each assumption the decomposition relied on>

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-model | Core model | <scope sufficient to author a spec> | — | — | NNNN-slug/0001-model |
| 0002-api   | API layer  | ...                                 | 0001-model | — | NNNN-slug/0002-api |

## Sequencing

1. 0001-model
2. 0002-api

## Open issues

- <cycles / non-decomposable initiative / duplicate / single-feature / unresolved>
```

- **Local id** is the child's directory name, `MMMM-slug`, and is the key used
  in `Depends on`.
- **Canonical reference** is the full item-ref; phase commands and `/status`
  address the child by it.
- **Depends on** names local ids of other rows in this same table only, as a
  comma-separated list when there are two or more (`—` when there are none). A
  dependency may not name its own row, and the stored graph must be acyclic. If
  the initiative's dependencies form a cycle, record the cycle under
  `## Open issues` and leave the stored graph acyclic.
- **conflicts-with** declares the targets the row expects to collide with. Use `—`
  when the row declares none, or one `ConflictTargetList`. The grammar is defined
  in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)". The declaration
  is advisory and never changes `Depends on` or readiness.

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
conflicts-with: "—"           # optional: one ConflictTargetList; `—` or absent = none
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
beside it under `work/<item-ref>/visual/`.

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

- `work/<item-ref>/visual/desktop.png`, `mobile.png`, ...

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

### `ship.md` (shipper) — the shipped-state record

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
- PR: <url or "not created">
- Commits: <short hashes + subjects>

## Reconcile

- Result: <reconciled | no-op (already up to date) | blocked: <reason>>
- Resolved paths:
  - `<path>` — <how both branches' intents were preserved>
- Re-verification: <the repository's own configured test command — the Project profile `Test:` value> → <result>; <item checks> → <result>
```

Its **presence** is the one shipped signal consumed by readiness — defined in
`docs/workflow.md` → "Dependencies and readiness" — and is keyed on the file
existing, never on its contents.

## Sequence allocation

To allocate a top-level `NNNN`, take the greatest 4-digit prefix that has **ever**
appeared in the committed history of `work/` and add one, zero-padded to four
digits. The source set is the union of directory names under `work/` at `HEAD`
and every path ever committed under `work/`, read with
`git log --all --name-only --pretty=format: -- work/`. When the set is empty,
start at `0001`. Git history is the durable ledger: Never reuse a number, even
if its directory was later deleted, because the deleted number stays visible in
the committed history and therefore in the source set. Do not create a registry
or any other allocation file; the committed tree and its history are the only
source.

To allocate a child's local `MMMM`, apply the same contract within
`work/<parent-NNNN-slug>/`: take the greatest 4-digit prefix ever present in that
parent's committed history and add one. Child numbers are scoped to their parent:
they are independent of the top-level sequence and of other roadmaps, and are
never reused within that parent.

### Renumbering after a parallel merge

Two branches may each allocate the same next number; because they create distinct
directories, the merge produces no conflict and can silently leave two items
sharing a canonical reference. Resolve it on the merged tree before either item
ships:

1. **Detect.** Any two top-level `work/` directories whose 4-digit prefix is
   equal are a collision; likewise any two canonical references that differ only
   by slug under the same number. Check each roadmap parent's child numbers the
   same way.
2. **Choose one.** Renumber the item that is not yet approved or shipped; if both
   are unshipped, renumber the one whose directory was added later by commit time
   (`git log --diff-filter=A`), breaking ties by slug order. The chosen number
   stays spent and is never reassigned.
3. **Renumber.** `git mv work/<old>/ work/<new>/` using the allocation contract
   above.
4. **Update every reference in the same change:** the directory name; the
   artifact `feature:` frontmatter value; a nested child's `parent:` value; the
   roadmap `Children` table `Canonical reference` cells; `ship.md` and
   PR/handoff paths; and any prose that names the old reference.
5. **Record.** Note the renumber in the item's newest artifact frontmatter
   `notes` (or the PR description when the artifacts are already immutable
   history).

Renumbering is the one sanctioned mechanical cross-phase edit: it changes
references, never decisions or content. It happens at merge time, before the item
ships, so it does not rewrite historical records.

Duplicate sequence numbers are one class of merge conflict; the full contract,
including the non-renumbering classes, lives in `docs/workflow.md` →
`## Merge conflicts`.
