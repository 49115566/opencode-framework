---
feature: 0006-parallel-plan-conflicts
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc only; no executable checker, no new command/agent/phase, no new committed test agreement area. Resolves the spec's deferred questions: (1) The Conflicts with column is appended after Canonical reference, which keeps tests/checks/80-cycle-fixture.sh:31's exact header substring and the awk Depends on field index a[5] intact; (2) the surface declaration lives in a new optional `## Surface declaration` section of design.md; (3) the finding vocabulary extends the canonical table in .opencode/skill/merge-conflict/SKILL.md with DANGLING-CONFLICT (b), DECLARED-CONFLICT (b), SURFACE-OVERLAP (a)/(b); (4) the check is a step in /build implemented as content in docs/workflow.md + builder.md + /build, with no new skill and no inventory change; (5) 'ready in-flight' = has design.md, has no ship.md, and is ready (standalone, or a nested child whose Depends on are satisfied and is not in a cycle)."
---

# Design — Parallel-development plan conflicts and a `Conflicts with` roadmap column

## Summary

Add a `Conflicts with` column to the roadmap `Children` table (appended after
`Canonical reference` so the pinned fixture assertions stay intact) and a new
optional `## Surface declaration` section to `design.md`, then define a
report-only pre-development check that `/build` runs before it implements a
task: it compares the item's declared surfaces against every other ready
in-flight item and reports `DECLARED-CONFLICT`, `SURFACE-OVERLAP`, and invalid
`Conflicts with` references (`DANGLING-CONFLICT`) in the existing `0005` finding
grammar. The capability is entirely documents, prompts, and configuration — no
executable checker, no new command, agent, phase, or committed test area.

## Approach

**One normative source, operational derivatives.** `docs/workflow.md` is the
workflow authority. The contract for this capability is a new
`## Parallel-development plan conflicts` section placed after `## Merge
conflicts` (workflow.md:337-438) and before `## Resuming and interruption`
(workflow.md:439). The `0005` pattern is reused exactly: `docs/workflow.md`
carries the normative prose, and the operational surfaces
(`.opencode/agent/builder.md`, `.opencode/command/build.md`,
`.opencode/agent/status.md`, `.opencode/skill/merge-conflict/SKILL.md`) defer to
it and define no second policy. The roadmap `Children` table contract is
extended in `docs/artifact-conventions.md` (authority, currently :108-133) and
described once in `docs/workflow.md` → `## Roadmaps` (:62-133).

**Roadmap column (AC1, AC3, AC15).** Append `| Conflicts with |` to the
`Children` header after `Canonical reference`. This is deliberately
append-only:

- `tests/checks/80-cycle-fixture.sh:31` asserts the header by fixed substring
  `| Local id | Title | Scope | Depends on | Canonical reference |`; the
  extended header still *contains* that substring, so the assertion keeps
  passing.
- `tests/checks/80-cycle-fixture.sh:44-64` parses `Depends on` as awk field
  `a[5]`; an appended sixth data column does not shift it.
- A mid-table insertion beside `Depends on` would break both, forcing edits to a
  pinned check. Appending needs none.

The cell grammar mirrors `Depends on`: comma-separated sibling local ids, or
`—` for none; intra-roadmap only (names another row in the same table, never its
own row). `Conflicts with` never changes readiness and is not part of the
dependency graph — `docs/workflow.md` → `### Dependencies and readiness` gains an
explicit sentence, and `### Dependencies and readiness`'s algorithm is untouched
(`tests/checks/10-readiness.sh` stays green).

**Surface declaration (AC5).** A new optional `## Surface declaration` section in
`design.md` — the architect's committed plan, written before `/build`, so it is
"committed before development begins" and "discoverable by the item's canonical
reference without reading implementation code" (`work/<item-ref>/design.md`).
Grammar:

```
## Surface declaration

- docs/workflow.md
- .opencode/agent/
```

- Each entry is one repository-relative path (no leading `/`, no `..`),
  optionally wrapped in backticks; a trailing `/` marks a directory entry that
  covers every path beneath it; any other entry is a concrete path.
- The section is optional. Absent or empty means the item declares no surfaces;
  the check reports that it could not compare and does not error (AC12).
- Shared framework surfaces are recognized by the `0005` class (a) set:
  `README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`,
  `template/**`, `tests/checks/**`.

**Pre-development check (AC6-AC13).** `/build` runs the check once, before it
edits anything, after selecting the task and before implementing. It is
LLM-executed prose (no script), read-only, takes no lock, writes no file, and
never blocks. The comparison universe — **ready in-flight items** — is:

1. not a roadmap parent (no `roadmap.md`),
2. has a committed `design.md` (a plan exists),
3. has no `ship.md` (not shipped),
4. is `ready`: a standalone item, or a nested child whose `Depends on` are all
   satisfied and which is not in a cycle.

Shipped items and blocked/cyclic children are outside the universe, matching the
spec's edge cases and non-goals. The current item is excluded from its own peer
set. An in-flight peer whose `design.md` lacks a declaration is reported as
"could not compare", never treated as "no surfaces" (AC12).

Algorithm:

1. Read the current item `R`'s `## Surface declaration` (empty if absent).
2. Enumerate the universe; read each peer's declaration.
3. **Declared edge (AC7).** If `R` is a nested child, read
   `work/<parent>/roadmap.md`'s `Children` table. For each ready in-flight
   sibling `S`, report `DECLARED-CONFLICT` when `R`'s `Conflicts with` names
   `S`'s local id **or** `S`'s names `R`'s (the relation is symmetric for
   detection; one direction suffices, both is not an error). An unresolvable
   reference is `DANGLING-CONFLICT`, owned by `/status`, not this check.
4. **Surface overlap (AC8, AC9).** For every current entry against every peer
   entry, overlap holds when the paths are equal; one is a directory entry that
   is an ancestor of (or equal to) the other; or both fall under the same shared
   framework surface class. Report `SURFACE-OVERLAP` naming both items and the
   overlapping surface(s).
5. Report every finding in the grammar
   `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`. Nothing
   is silently dropped or truncated, including a large overlap set (AC10).
6. Record the result in the build handoff: the declarations assessed and the
   conflicts found, or an explicit `no conflicts` (AC13).

**Finding vocabulary (AC10).** Extend the canonical table in
`.opencode/skill/merge-conflict/SKILL.md` (:109-127), which `/status` already
repeats and the merge-integrity guard consumes, with three pre-development codes;
no second vocabulary is created.

| Code | Class | Reported by | Meaning |
| ---- | ----- | ----------- | ------- |
| `DANGLING-CONFLICT` | `(b)` | `/status` | a `Conflicts with` local id resolves to no other row in the same `Children` table, or names its own row |
| `DECLARED-CONFLICT` | `(b)` | pre-development check | two ready in-flight items where one plan declares a `Conflicts with` edge naming the other |
| `SURFACE-OVERLAP` | `(a)` or `(b)` | pre-development check | two ready in-flight items declare the same concrete path, an ancestor/descendant directory overlap, or the same shared framework surface; class `(b)` when both entries are under `work/`, otherwise class `(a)` |

The existing codes (`DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`,
`CYCLIC-DEP`, `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DRIFT-FACT`,
`TEXTUAL-CONFLICT`) are unchanged.

**`/status` validation (AC2, AC4).** The status agent already parses the
`Children` table (:80-89). It gains validation of each `Conflicts with` cell
against the same table and reports `DANGLING-CONFLICT` `(b)` alongside its
existing findings — non-fatal, offline, read-only, modifying no file.

**Adopter reach and delivery form (AC14).** The behavior lives in
`.opencode/agent/**`, `.opencode/command/**`, `.opencode/skill/**`, and
`docs/*.md`, all of which adopters receive verbatim (`tests/README.md:5-16`), so
no migration is needed. No skill, command, agent, phase, artifact beyond
`design.md`/`roadmap.md`, or committed check is added.

**Backward compatibility.** Nothing migrates. Existing items without a
`## Surface declaration` are reported as "could not compare" and are never
errored. Existing roadmaps without the `Conflicts with` column are readable (the
column is additive); the committed test fixture's header is updated to the new
format because it is the representative roadmap document, while the historical
`work/0002`, `work/0005` roadmaps are left as committed records.

## Surface declaration

- `docs/workflow.md`
- `docs/artifact-conventions.md`
- `docs/customization.md`
- `.opencode/agent/`
- `.opencode/command/`
- `.opencode/skill/merge-conflict/`
- `tests/fixtures/cyclic-roadmap/roadmap.md`
- `README.md`
- `AGENTS.md`
- `template/AGENTS.md`

## Alternatives considered

- **A new `plan-conflict` skill as the check's home.** Pros: a focused,
  description-matched skill a builder naturally loads. Cons: it changes the
  README Layout count (`# 11 knowledge skills` → 12) and the Skills table,
  enlarges exactly the shared surfaces parallel items collide on, and risks a
  second vocabulary for the same findings. **Rejected** — the spec permits a new
  skill only with its inventory updates, and the smaller, single-vocabulary
  design (workflow authority + builder prompt + the existing `merge-conflict`
  canonical table) fully satisfies AC6-AC13.
- **A dedicated declaration artifact or frontmatter field (`surfaces:` / a new
  `surfaces.md`).** Pros: cleanly separated and machine-readable. Cons: adds a
  new artifact format (and its `docs/artifact-conventions.md` template), touches
  the derived-state/`/status` model, and requires a new file per item; the spec
  says the declaration lives in the item's committed *plan*, and `design.md`
  already exists at `/plan` time and is architect-owned. **Rejected.**
- **Insert `Conflicts with` mid-table beside `Depends on`.** Pros: the two
  coordination relations are adjacent. Cons: it breaks the exact fixture header
  assertion (`tests/checks/80-cycle-fixture.sh:31`) and shifts the `Depends on`
  awk field index (`a[5]`), forcing edits to a pinned check and fixture.
  **Rejected** — appending after `Canonical reference` keeps both pinned
  surfaces untouched.
- **An executable checker (a script) and a committed `tests/checks/` agreement
  area.** Pros: deterministic and regression-guarded. Cons: explicitly named
  spec non-goals — no executable tooling and no new committed test agreement
  area — and the suite is read-only and never reads live `work/**`
  (`tests/README.md:29`). **Rejected** by the spec's resolved delivery fork.

## Interfaces and data model

No runtime interfaces change. The concrete contracts are the document, prompt,
and configuration content each surface must carry, so the builder and tester can
verify by reading.

### `docs/artifact-conventions.md`

- `### roadmap.md` template: the `## Children` header becomes
  `| Local id | Title | Scope | Depends on | Canonical reference | Conflicts with |`
  with a matching separator segment and `—` in the example rows.
- A new bullet after the `Depends on` bullet (`:129-133`): **Conflicts with**
  names local ids of other rows in the same table only, comma-separated or `—`;
  intra-roadmap only; a row may not name itself; it never affects readiness or
  the dependency graph.
- `### design.md` template (`:187-227`): add an optional
  `## Surface declaration` section (placed after `## Approach`) whose body is a
  bullet list of repository-relative paths; a trailing `/` is a directory.
- Prose defining the declaration grammar and that it is compared by the
  pre-development check in `docs/workflow.md`.

### `docs/workflow.md`

- `## Roadmaps` (`:62-133`): describe the `Conflicts with` column alongside the
  other `Children` columns and its intra-roadmap, readiness-neutral semantics.
- `### Dependencies and readiness` (`:77-109`): one sentence stating a
  `Conflicts with` entry never changes readiness or the graph.
- New `## Parallel-development plan conflicts` after `## Merge conflicts`:
  - `### Surface declaration` — the format and where it lives, deferring the
    exact grammar to `docs/artifact-conventions.md`.
  - `### Comparison universe` — the ready in-flight definition above.
  - `### Detection` — the three conditions (declared edge, path/ancestor
    overlap, shared framework surface) and the `/build` trigger.
  - `### Finding vocabulary` — the three new codes with classes, deferring the
    canonical table to the `merge-conflict` skill.
  - `### Report-only contract` — non-fatal, read-only, no lock, modifies no
    file, auto-repairs nothing, never blocks the build; the result is recorded
    in the build handoff.
  - No `### N. ` numbered heading is introduced, so
    `tests/checks/96-signature-sweep.sh` does not extract it.

### `.opencode/skill/merge-conflict/SKILL.md`

- Extend the canonical vocabulary table (and the "pre-flight vocabulary"
  paragraph) with `DANGLING-CONFLICT`, `DECLARED-CONFLICT`, `SURFACE-OVERLAP`,
  marking the latter two pre-development-only (like `TEXTUAL-CONFLICT` is
  pre-flight-only) and pointing to `docs/workflow.md` →
  `## Parallel-development plan conflicts` as the check's authority. No existing
  merge-time code or procedure changes.

### `.opencode/agent/builder.md`

- `<process>`: after "Select work" and before "Implement", add a step that runs
  the pre-development check per `docs/workflow.md` → `## Parallel-development
  plan conflicts`: read the current `design.md` declaration, bind the ready
  in-flight universe, report declared edges and surface overlaps (or that a peer
  could not be compared), and proceed regardless.
- `<handoff>`: add a `Plan conflicts:` line naming the declarations assessed and
  the conflicts found or `no conflicts`.
- `<rules>`: the check is read-only, modifies no file, and never blocks the
  build.

### `.opencode/command/build.md`

- One bullet wiring the check in before implementation and one handoff mention.

### `.opencode/agent/status.md` and `.opencode/command/status.md`

- `status.md` `<process>` step 4: validate each `Conflicts with` cell against
  the same `Children` table. `<findings>`: add `DANGLING-CONFLICT` `(b)`, whose
  detail names the roadmap, the offending row, and the invalid reference (the
  roadmap is neither rejected nor aborted). `<quality_bar>`: include the new
  validation. `<output_format>`: add an example finding line.
- `command/status.md`: one bullet naming `DANGLING-CONFLICT`.

### Other surfaces

- `README.md` `## The lifecycle` roadmap paragraph (`:183-188`): name the
  `Conflicts with` column and the pre-build check. Framework-repo docs
  consistency; not in the adopter copy set.
- `AGENTS.md` and `template/AGENTS.md` `## Reference` (`:131-136` /
  `:133-138`): one bullet pointing at `docs/workflow.md` →
  `## Parallel-development plan conflicts`.
- `tests/fixtures/cyclic-roadmap/roadmap.md:26`: append `| Conflicts with |` to
  the header, a matching separator segment, and `—` to each row. No change to
  `tests/checks/80-cycle-fixture.sh` is required or made.
- `docs/customization.md` `## Always-loaded instructions` (`:56-62`): refresh the
  `docs/workflow.md` and `docs/artifact-conventions.md` rows and the total,
  per that table's own refresh instruction.

## Affected areas

- `docs/workflow.md` — `## Roadmaps`, `### Dependencies and readiness`, new
  `## Parallel-development plan conflicts` section (insert before `:439`).
- `docs/artifact-conventions.md` — roadmap template/column bullets
  (`:108-133`); design template (`:187-227`) and declaration prose.
- `.opencode/skill/merge-conflict/SKILL.md` — canonical vocabulary table
  (`:109-127`) and a pointer subsection.
- `.opencode/agent/builder.md` (`:55-68`, `:86-95`, `:97-103`) and
  `.opencode/command/build.md` (`:10-28`).
- `.opencode/agent/roadmap.md` (`:61-102`, `:104-120`, `:122-137`) and
  `.opencode/command/roadmap.md` (`:17-23`).
- `.opencode/agent/status.md` (`:54-111`, `:124-158`) and
  `.opencode/command/status.md` (`:28-39`).
- `README.md` (`:183-188`), `AGENTS.md` (`:131-136`),
  `template/AGENTS.md` (`:133-138`), `docs/customization.md` (`:56-62`).
- `tests/fixtures/cyclic-roadmap/roadmap.md` (`:26-29`).
- Read for context, not changed: `tests/checks/10-readiness.sh`,
  `tests/checks/20-lifecycle.sh`, `tests/checks/40-inventory.sh`,
  `tests/checks/80-cycle-fixture.sh`, `tests/checks/96-signature-sweep.sh`,
  `tests/README.md`, `work/0005-merge-conflict-workflow/**`.

## Risks and mitigations

- **Vocabulary drift across four surfaces (skill, workflow, status, builder).**
  Likelihood medium / impact medium. Mitigation: the `merge-conflict` skill
  remains the single canonical table; T4 extends it first, T5/T6/T7 reference it
  rather than restating, and T9 greps all surfaces for the three codes.
- **Pinned fixture/awk breakage.** Appending the column could still surprise the
  `Children` parser. Likelihood low / impact high. Mitigation: append-only column
  preserves the exact substring and `a[5]`; T2's Verify runs
  `bash tests/run.sh` and asserts no `FAIL AC13` line.
- **`Conflicts with` accidentally changing readiness.** A reader or `/status`
  might fold it into the dependency graph. Likelihood low / impact high.
  Mitigation: T1 adds the explicit readiness-neutral sentence and T9 runs
  `tests/checks/10-readiness.sh` green.
- **Always-loaded cost table drift.** `docs/workflow.md` and
  `docs/artifact-conventions.md` grow. Likelihood high / impact low. Mitigation:
  T8 recomputes at ~4 bytes/token and updates the total.
- **A new numbered heading or signature edit trips `96-signature-sweep.sh` /
  `20-lifecycle.sh`.** Likelihood low / impact high. Mitigation: the new section
  uses `##`/`### ` non-numbered headings only; no command signature or
  `### N. ` phase heading changes; T9 runs the full suite.
- **Scope creep into executable tooling or a new test area.** Likelihood medium /
  impact high. Mitigation: every task edits only `docs/`, `.opencode/**`,
  `README.md`, `AGENTS.md`, `template/AGENTS.md`, or the fixture; T9 asserts no
  script, no new command/agent/skill, and no new `tests/checks/` file.
- **The check is misread as blocking.** A builder might stop on a finding.
  Likelihood medium / impact medium. Mitigation: the report-only literals are
  required in T5 and T7 and asserted in T9.

## Test strategy

The capability is prose and configuration, so there is no unit harness. Content
is verified by literal-presence assertions in an item-level read-only
`work/<item-ref>/verify-tests.sh` (the `0005` precedent), and the committed
suite verifies the pinned format, readiness, inventory, and lifecycle
invariants. No committed check is added (spec non-goal).

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | content: roadmap template and `docs/workflow.md` grep the `Conflicts with` header/cell contract |
| AC2 | content: `status.md`/`command/status.md` grep `DANGLING-CONFLICT`, the invalid-reference rule, and non-fatal wording |
| AC3 | content + integration: `docs/workflow.md` grep readiness-neutral sentence; `tests/checks/10-readiness.sh` green |
| AC4 | content: `status.md` grep offline/read-only/modifies-no-file findings contract and `DANGLING-CONFLICT` |
| AC5 | content: `docs/artifact-conventions.md` design template grep `## Surface declaration`; `docs/workflow.md` grep the declaration requirement |
| AC6 | content: `docs/workflow.md` + `builder.md` + `command/build.md` grep the before-implementation check |
| AC7 | content: `docs/workflow.md`/`builder.md` grep declared-edge detection and `DECLARED-CONFLICT` |
| AC8 | content: grep equal-path and ancestor/descendant overlap + `SURFACE-OVERLAP` |
| AC9 | content: grep the shared framework surface classes and `SURFACE-OVERLAP` class `(a)` |
| AC10 | content: grep the grammar `- [<CODE>] (<class>) <refs> — <detail>` and every new code; no-drop/no-truncation literals |
| AC11 | content: grep report-only / non-fatal / modifies-no-file / never-blocks literals |
| AC12 | content: grep the empty/no-declaration no-error path |
| AC13 | content: `builder.md` grep the `Plan conflicts:` handoff line |
| AC14 | content + integration: listing shows 12 commands / 14 agents / 11 skills; no new `tests/checks/` file; no executable helper |
| AC15 | integration: `bash tests/run.sh` exits 0, including AC6 readiness, AC9 inventory, AC13 cycle fixture |

`bash tests/run.sh` is the project's canonical command (`AGENTS.md` Project
profile) and is run after every task; the tester re-runs it independently for
AC14/AC15.
