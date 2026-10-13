# Artifact conventions

Every workflow artifact is a Markdown file under `work/<item-ref>/` — the
canonical reference, whose segments nest to any depth (see "Work item
references") — with YAML frontmatter.
Agents must follow these formats exactly so that other phases and `/status` can
parse them deterministically.

Workflow artifacts under `work/` are **committed working state**:
version-controlled so a fresh clone, a teammate, and CI derive the same phase.
Only `scratch/` and opencode's generated state are ignored.

## Frontmatter

Every artifact begins with:

```yaml
---
feature: 0001-add-dark-mode   # the item's full canonical reference: one segment for a standalone item, more when nested
phase: spec                   # spec | design | manifest | tasks | test | visual | review | ship
status: draft                 # draft | final | blocked
created: 2026-01-31           # ISO-8601 date, first creation
updated: 2026-02-04           # ISO-8601 date, last edit
notes: ""                     # optional: skipped phases, caveats
parent: ""                    # optional: the immediate parent's canonical reference when this item is a nested child
stale: ""                     # optional: the backtrack target phase that invalidated this artifact
reopened: ""                  # optional on ship.md: the phase a recalled item re-enters
---
```

Rules:

- `feature` is the item's full canonical reference, not the title: its directory
  path relative to `work/`, one segment (`<NNNN-slug>`) for a standalone item and
  one further `/<MMMM-slug>` segment per nesting level, to any depth (see "Work
  item references").
- `parent` is optional and set only on a nested child's artifacts; its value is
  the **immediate** parent's canonical reference — one segment (`<NNNN-slug>`) at
  depth two, and the parent's full multi-segment reference at depth three or
  deeper. The full ancestor chain is derivable from the directory path. Standalone
  items omit it.
- `created` never changes; `updated` changes on every edit.
- `status: final` means the owning agent considers the artifact complete for its
  phase. `blocked` means work cannot proceed without user input; say why in the
  body.
- `conflicts-with` is optional and appears only on `design.md`; it holds one
  `ConflictTargetList` declaring the item's intended conflict targets. Absent or
  `—` means no declared conflicts, and the declaration is advisory — it never
  affects phase derivation or readiness. The grammar is defined in
  `docs/workflow.md` → "Declared conflicts (`conflicts-with`)".
- `stale` is optional and marks this artifact as invalidated by a backtrack whose
  target phase is the named token. Its token is a target phase label
  (`spec | design | build | test | review`) — plus `manifest` for a
  phase→parent-manifest backtrack — not a new `phase` value. A legacy
  `stale: roadmap` is accepted as the deprecated equivalent of `stale: manifest`
  and maps to `spec` when the item's phase is derived. The owning phase clears the
  marker when it re-runs; until then the artifact is neither the item's current
  phase artifact nor a satisfied downstream prerequisite. See
  `docs/workflow.md` → "Phase reversal (backtracking)".
- `reopened` is optional and appears only on `ship.md`. It is set by
  `/ship recall <item-ref> <phase>` when a shipped item's PR is denied, closed, or
  sent back for changes (or was never opened, or its branch was abandoned), and it
  names the re-entry phase label (`spec | design | build`), which must be strictly
  earlier than ship. Its presence revokes the shipped signal **without deleting or
  rewriting the historical `ship.md`**: `ship.md` presence remains the sole shipped
  signal, but a `reopened:` marker makes that signal revoked, so the item derives
  the named phase (reopened) and no longer satisfies its dependents. The shipper
  clears the marker only when it writes a fresh `ship.md` on re-ship. See
  `docs/workflow.md` → "Phase reversal (backtracking)" → "Shipped items and
  reopen".
- `stale` and `reopened` are distinct from the frontmatter `status`
  (`draft`/`final`/`blocked`) and never overload it.
- Never remove frontmatter. Never edit a file owned by another phase.

## Work item references

A work item is addressed by a **canonical reference** — its path relative to
`work/`, a recursive path of one or more dash-slug segments:

```
item-ref   ::= NNNN-slug ( "/" MMMM-slug )*   # one segment = standalone item
                                              # two segments = the special case
segment    ::= [0-9]{4}-[a-z0-9-]+
```

Reference regex:
`^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`.

A trailing slash, an empty segment, or a non-conforming segment is not a valid
reference and is not treated as one.

- The **first** segment is the top-level `NNNN`, allocated across the whole
  `work/` tree. Each **further** `MMMM` segment is the local sequence number of a
  child of its **immediate** parent (the preceding segment), independent of the
  top-level sequence and of every other node. Any node may decompose into
  children, so the path nests to arbitrary depth.
- A reference resolves to the directory `work/<item-ref>/` by following its
  segments in order: `work/0007-billing/` for a standalone item,
  `work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/` for a
  two-segment child, and `work/<NNNN-slug>/<MMMM-slug>/<MMMM-slug>/` and deeper
  for a longer path.
- The one-segment standalone form is unchanged, and the two-segment form is a
  **special case** of the recursive path, not a maximum depth.
- A **decomposing node** is a parent work item identified by its manifest
  (`manifest.md`, or the legacy `roadmap.md` alias). Its child features are nested
  at `work/<parent-ref>/<MMMM-slug>/`, and each child later runs the ordinary
  per-feature lifecycle unchanged. A pure container holds only its manifest; a
  hybrid node that also runs its own lifecycle holds the manifest alongside its
  own phase artifacts (see "`manifest.md` — the manifest of a decomposing node").
- Phase commands accept an `item-ref` wherever a `<slug>` was accepted before. A
  one-segment reference behaves exactly as it did before nesting existed, and
  standalone items require no `parent` and no manifest metadata.

Nested children's artifacts set `feature` to the full canonical reference
(their path relative to `work/`) and MAY set `parent:` to the **immediate**
parent's canonical reference — one segment (`<NNNN-slug>`) at depth two, and the
parent's full multi-segment reference at depth three or deeper; the full ancestor
chain is derivable from the directory path.

## Task IDs

Tasks are `T1`, `T2`, … within an item. Reference them in commit messages and
in `[depends: T1]` annotations. Check boxes are `- [ ]` / `- [x]`.

## Templates

### `manifest.md` (manifest) — the manifest of a decomposing node

A **manifest** is the child-enumeration artifact of any node that decomposes
into children. It is the generic enumeration source for a decomposing node
**at every depth** — a standalone item that decomposes, a nested child that
decomposes, or a node that carries a manifest alongside its own phase artifacts
— and it is authored before any child spec. It is not a single-feature artifact:
a node that decomposes records its children in its manifest rather than in a
spec, design, tasks, verification, or review of its own, though a hybrid node may
carry both at once (see `docs/workflow.md` → "The recursive lifecycle model").
The manifest's **concrete spelling** is `manifest.md` with `phase: manifest` at
**every** depth; no new artifact-presence row is introduced. The legacy
`roadmap.md` with `phase: roadmap` remains a **recognized deprecated alias**,
accepted so an existing decomposing node stays valid with no migration, but it is
never used for a new manifest. The `Children` table is the machine-readable source
of the child set and dependency graph; `/status` parses it directly.

```markdown
---
feature: NNNN-slug
phase: manifest
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Manifest — <initiative title>

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
- **Withdrawn child — `<MMMM-slug>`.** Withdrawn by user decision on <YYYY-MM-DD>
  and removed from the Children table and Sequencing above. Its directory
  `work/<parent-NNNN-slug>/<MMMM-slug>/` and spent local number are preserved; the
  number is never reused. Rationale: <why>. Former scope: <what it covered>.
- **Revised <YYYY-MM-DD>.** Triggered by `work/<parent>/<child-ref>/` (finding in
  its `backtracks.md`). Operations: <re-scope/add/withdraw/re-sequence>.
  Invalidated: <affected child refs>. See git history for the pre-revision
  manifest.
```

- **Local id** is the child's directory name, `MMMM-slug`, scoped to the
  decomposing node that owns the manifest (the child's **immediate** parent), and
  is the key used in `Depends on`.
- **Canonical reference** is the child's full item-ref — the owning node's
  canonical reference with the child's `MMMM-slug` appended — and resolves to
  `work/<canonical-reference>/`; phase commands and `/status` address the child by
  it. A child may itself decompose, so the reference and the layout nest to
  arbitrary depth (see "Work item references").
- **Child reservation** — each child directory is reserved with a `.gitkeep` at
  that level (`work/<parent-ref>/<MMMM-slug>/.gitkeep`), at every depth, not only
  the top level.
- **Depends on** names local ids of other rows in this same table only, as a
  comma-separated list when there are two or more (`—` when there are none). A
  dependency may not name its own row, and the stored graph must be acyclic. If
  the initiative's dependencies form a cycle, record the cycle under
  `## Open issues` and leave the stored graph acyclic.
- **conflicts-with** declares the targets the row expects to collide with. Use `—`
  when the row declares none, or one `ConflictTargetList`. The recursive grammar is
  defined in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)":
  references nest to arbitrary depth (`NNNN-slug(/MMMM-slug)*`) and resolve from
  the repository root, while a bare sibling local id resolves against the
  declaring entity's immediate parent's `Children` table first, then the
  repository root. The declaration is advisory and never changes `Depends on` or
  readiness.
- **Withdrawal record** — a revision that withdraws a child removes its row from
  the `Children` table and `## Sequencing` but preserves the child directory and
  its spent local number (never reused), recording the withdrawal and its rationale
  under `## Open issues` in the shape above. The named directory is the recognition
  signal for a deliberate withdrawal: an `UNLISTED-CHILD` observation for it is
  report-only and never auto-repaired. See `docs/workflow.md` →
  "Revising a decomposition".
- **Revision note** — a revision changes the frontmatter `updated` date and appends
  a revision note under `## Open issues` naming the date, the triggering child, the
  operations applied, and the invalidated children; the pre-revision content stays
  recoverable from committed git history. See `docs/workflow.md` →
  "Revising a decomposition".

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
- **Minor** — worth fixing; blocks the item. Must be fixed or overturned through
  the challenge loop; the author cannot decline it.
- **Nit** — style or preference; blocks the item. Must be fixed or overturned
  through the challenge loop; the author cannot decline it.

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

Its **presence** is the shipped signal consumed by readiness (defined in
`docs/workflow.md` → "Dependencies and readiness"); a `reopened:` marker on the
file revokes that signal (see `docs/workflow.md` → "Phase reversal
(backtracking)" → "Shipped items and reopen").

### `backtracks.md` (backtracks) — per-item backtrack record

An item MAY carry a committed, append-only `backtracks.md` record beside its
phase artifacts. It is **not a phase artifact**: it carries no `phase` value, is
not one of the artifact-presence rows, and does not by itself determine the
item's derived phase. Its role is defined in `docs/workflow.md` → "Phase
reversal (backtracking)"; `/status` reads it for reporting, never for
derivation. An absent file means no backtracks, and historical items need no
migration.

Its frontmatter is minimal and distinct from the phase-artifact frontmatter:

```yaml
---
feature: NNNN-slug
record: backtracks
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

The body is append-only. A **finding entry** records the detecting phase, the
target phase, the affected artifact or output, the observable evidence, and a
status of `open`:

```markdown
## Finding <n> — YYYY-MM-DD

- detecting phase: `/test`
- target phase: `/plan`
- affected: `design.md`
- evidence: <observable observation>
- status: open
```

The detecting phase may be `/ship` for a post-ship recall; that finding records
the re-entry target phase and names the revoked `ship.md` as the affected output
(see `docs/workflow.md` → "Phase reversal (backtracking)" → "Shipped items and
reopen").

When the target phase's revision completes, a **resolution entry** for that
finding is appended:

```markdown
## Resolution <n> — YYYY-MM-DD

- resolves: Finding <n>
- revision: <what the target phase changed>
```

Finding and resolution entries are numbered sequentially from `1` and appended
in order. No entry is ever edited, reordered, or removed. The effective status of
finding `n` is `resolved` when a matching `Resolution n` entry exists, and `open`
otherwise. A resolution recorded before its finding is malformed and is
reported, not reordered.

### `challenges.md` (challenges) — per-item challenge record

An item MAY carry a committed, append-only `challenges.md` record beside its
phase artifacts. It is **not a phase artifact**: it carries no `phase` value, is
not one of the artifact-presence rows, and does not by itself determine the
item's derived **phase**. Its role is defined in `docs/workflow.md` →
"Findings challenge and adjudication". An absent file means nothing is
challenged, and historical items need no migration.

Its frontmatter is minimal and distinct from the phase-artifact frontmatter — it
carries no `phase`:

```yaml
---
feature: NNNN-slug
record: challenges
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

The body is append-only. A **challenge entry** records who disputed the finding,
which finding (the artifact and its finding id), the challenge type, the
evidence, the rationale, and a status of `open`:

```markdown
## Challenge <n> — YYYY-MM-DD

- challenger: `/build`
- challenged: `review.md` [M1]
- type: severity
- evidence: <observable observation>
- rationale: <why the finding or its severity is disputed>
- status: open
```

`challenger` is the phase raising the challenge; `type` is one of `finding`,
`severity`, or `acceptance-criterion`; `challenged` names the artifact that
produced the disputed item (a `review.md` finding id, or a `verify.md` defect).

When the producing phase adjudicates, a **response entry** is appended:

```markdown
## Response <n> — YYYY-MM-DD

- resolves: Challenge <n>
- adjudicator: `/review` | `user`
- decision: sustained | rejected
- basis: <spec/criterion/diff evidence>
- outcome: <overturned | severity adjusted to <X> | verdict recomputed to <approve|request-changes> | finding unchanged | reclassified as a spec or design fault>
```

`adjudicator` is the producing phase command (`/review` or `/test`) or `user`;
`decision` is `sustained` or `rejected`. The severity, finding-format, and
verdict vocabulary is the existing one (`Blocker`/`Major`/`Minor`/`Nit` and
`approve`/`request-changes`); this record introduces no second scale or verdict.

The author may withdraw a challenge by appending a **withdrawal entry**:

```markdown
## Withdrawal <n> — YYYY-MM-DD

- withdraws: Challenge <n>
- reason: <why the challenge is withdrawn>
```

A later decision that supersedes an earlier response is appended as a
**reversal entry**; it never rewrites the prior entry:

```markdown
## Reversal <n> — YYYY-MM-DD

- reverses: Response <n>
- adjudicator: <producing phase command | user>
- decision: sustained | rejected
- basis: <spec/criterion/diff evidence>
```

Entries are numbered sequentially from `1` and appended in order. No entry is
ever edited, reordered, or removed. The effective status of challenge `n` is
`open` until a matching `Response n` or `Withdrawal n` entry exists, then
`resolved` (or `withdrawn`); a `Reversal n` supersedes the recorded decision but
does not reopen the challenge. A `Response`/`Withdrawal`/`Reversal n` recorded
before its `Challenge n` is malformed and is reported, not reordered.

The **challenged condition** is derived from the record, not from a frontmatter
field: it holds while a `Challenge <n>` has no matching `Response n`/`Withdrawal
n`. The open entry is the marker and the derived label is `challenged` (blocked);
it is not a `phase` value. Its precedence in derived state — evaluated as a
blocked overlay before the forward-action and `ship.md`/verdict rows, after the
`stale:`/`reopened:` structural derivations — is stated in `docs/workflow.md` →
"Derived state".

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
`work/<parent-ref>/` (the allocating node's own canonical reference): take the
greatest 4-digit prefix ever committed under that parent and add one. Every
further level allocates its own children's `MMMM` the same way, scoped to its
**immediate** parent, so allocation applies per level to arbitrary depth. Child
numbers are scoped to their parent: they are independent of the top-level
sequence and of every other node, and are never reused within that parent.

Duplicate `4`-digit prefixes — at the top level and at every node of the tree —
are detected by the recursive rule stated once in `docs/workflow.md` →
"Multiple work items"; this section defines no duplicate-detection rule of its
own.

### Renumbering after a parallel merge

Two branches may each allocate the same next number; because they create distinct
directories, the merge produces no conflict and can silently leave two items
sharing a canonical reference. Resolve it on the merged tree before either item
ships:

1. **Detect.** Any two top-level `work/` directories whose 4-digit `NNNN`
   prefix is equal are a `DUPLICATE-PREFIX` collision; and, for **every
   decomposing node at any depth**, any two of its immediate children whose local
   4-digit `MMMM` prefix is equal are a `DUPLICATE-CHILD` collision. This is the
   recursive rule stated once in `docs/workflow.md` → "Multiple work items"; each
   offender is identified by its **full canonical reference**, and a collision at
   depth ≥ 3 also names the **shared parent and shared local prefix**.
2. **Choose one.** Renumber the item that is not yet approved or shipped; if both
   are unshipped, renumber the one whose directory was added later by commit time
   (`git log --diff-filter=A`), breaking ties by slug order. The chosen number
   stays spent and is never reassigned.
3. **Renumber.** `git mv work/<old>/ work/<new>/` using the allocation contract
   above.
4. **Update every affected reference in the same change.** When the chosen node
   is itself a decomposing node, its **whole subtree** moves with it — rewrite:
   - the directory name;
   - the node's own `feature:` frontmatter value, and **every descendant
     artifact's** `feature:` value (the full canonical reference);
   - the owning manifest's `Children` row `Local id` and `Canonical reference`
     cells for the renumbered node, and **every intermediate manifest's**
     `Children` `Canonical reference` cell on the changed path;
   - every `Depends on` cell that names the old local id;
   - every `conflicts-with` target that names the old local id or old canonical
     reference — the manifest `Children` `conflicts-with` cell and the
     `design.md` frontmatter `conflicts-with` value;
   - **every descendant's** `parent:` value on the changed path;
   - `ship.md` and PR/handoff paths; and
   - any prose that names the old reference.
   Assert that `no reference to the old canonical reference remains`, by
   scanning the repository for the old canonical reference.
5. **Record.** Note the renumber in the item's newest artifact frontmatter
   `notes` (or the PR description when the artifacts are already immutable
   history).

Renumbering is the one sanctioned mechanical cross-phase edit: it changes
references, never decisions or content. It happens at merge time, before the item
ships, so it does not rewrite historical records.

Duplicate sequence numbers are one class of merge conflict; the full contract,
including the non-renumbering classes, lives in `docs/workflow.md` →
`## Merge conflicts`.
