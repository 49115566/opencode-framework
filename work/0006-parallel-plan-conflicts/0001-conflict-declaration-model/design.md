---
feature: 0006-parallel-plan-conflicts/0001-conflict-declaration-model
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "User resolved both spec open questions on 2026-10-08: (1) a missing conflicts-with column is treated as no declared conflicts (no migration); (2) a surface target is an exact repository-relative file or directory path, no globs or prefixes."
---

# Design — Declared planning-time conflict model and `conflicts-with` column

## Summary

State one authoritative, storage-independent grammar for a **declared conflict
target list** in `docs/workflow.md`, then add a `conflicts-with` column to the
roadmap `Children` table in `docs/artifact-conventions.md` that instantiates it.
Make the roadmap agent prompt and the roadmap command describe the column and
reference that authority. No new taxonomy, readiness edge, finding code, live
`work/` migration, or test change is introduced — the committed suite's only
positional parser keeps `Depends on` at its current field index.

## Approach

### The model

A **planning-time conflict** is a *declared, committed claim* by one plan (a
roadmap row, or a child/standalone item's own declaration) that it expects to
collide with one or more **targets**. The model is defined by four properties:

- **Declared, not detected.** It records intent at plan time; it does not detect
  an actual collision. The class of a conflict is assigned when it is *detected*
  (child `0003-conflict-check`), never when it is declared.
- **Distinct from the merge-time contract.** The shipped `docs/workflow.md` →
  `## Merge conflicts` contract acts on branches after they exist. A declared
  conflict is plan state. The two are complementary; this item does not fork or
  reopen the merge-time contract.
- **Distinct from `Depends on`.** `Depends on` is a readiness edge; a declaration
  is advisory. The declared set never adds, removes, or reorders a `Depends on`
  edge and never changes any child's readiness. Only `Depends on` gates readiness.
- **One-sided.** If either side names the other, the pair is a declared conflict;
  reciprocity is not required.

### The grammar (single authoritative statement)

`docs/workflow.md` gets a new `### Declared conflicts (conflicts-with)`
subsection under `## Roadmaps` (inserted after `### Dependencies and readiness`,
before `### Status reporting`). It defines the normative `ConflictTargetList`
used by the `conflicts-with` cell *and* by any child/standalone item's own
declaration. Storage of the item-level declaration is deliberately not decided
here (owned by `0002-plan-record`); the grammar is defined independently of it.

```
ConflictTargetList ::= "—"                              # no declared conflicts
                    | ConflictTarget ("," ConflictTarget)*

ConflictTarget     ::= SiblingOrItemRef | SurfacePath
SiblingOrItemRef   ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )?
SurfacePath        ::= repository-relative file or directory path
```

- **Absent column** — a roadmap authored before this change has no
  `conflicts-with` column; absence is treated as "no declared conflicts"
  (`—` for every row), so historical roadmaps stay valid with no migration.
- **Empty value** — a cell that is `—` (em dash, the same convention as
  `Depends on`) declares no conflicts. An empty or whitespace-only cell is
  **malformed**, not equivalent to `—`.
- **Separation** — targets are comma-separated; each target is trimmed of
  surrounding whitespace. Repository paths and references contain no comma, so a
  comma always separates targets.
- **Three target kinds** — each target is exactly one of:
  1. an **intra-roadmap sibling local id** (`MMMM-slug`) naming a different row
     in the same `Children` table;
  2. a **canonical work-item reference** — a top-level `NNNN-slug` (including a
     roadmap parent) or a nested `NNNN-slug/MMMM-slug` — resolving to
     `work/<ref>/`;
  3. a **repository-relative surface path** — an exact file or directory path
     (for example `docs/workflow.md`, `tests/checks`). No glob metacharacters,
     no `..`, no absolute paths. (User-confirmed: exact path only.)
- **Reference-vs-path discriminator** — a target matching
  `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$` is a reference (kind 1 or 2);
  any other target is a surface path (kind 3). For a no-slash reference,
  resolution precedence is: **sibling row in the same table first, then
  `work/<token>/`**. This makes a bare `MMMM-slug` deterministic when a sibling
  row and a top-level item could share the same text.
- **Well-formedness constraints** — a reference may not name the declaring row's
  own `Local id` (no self-reference); a list may not repeat a target (after
  trimming).
- **Unresolved declarations** — a malformed cell or a target that resolves to no
  sibling row, no `work/<ref>/` directory, and no existing path is an
  **unresolved declaration**. It is reported by a later read-only check
  (`0003-conflict-check`), never silently dropped, and never auto-repaired.
- **Reporting vocabulary is reused, not redefined** — a declared conflict, when
  reported, uses the shipped `(a)`–`(d)` class labels and the single finding-line
  grammar defined in `docs/workflow.md` → `## Merge conflicts` and
  `.opencode/skill/merge-conflict/SKILL.md`. This item defines **no new class,
  finding code, or policy** for declarations.

### Column position

The template becomes:

```
| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
```

`conflicts-with` is inserted **immediately after `Depends on`**. The only
positional consumer in the repository is the awk parser in
`tests/checks/80-cycle-fixture.sh:48-50`, which reads `Depends on` from pipe-field
index 5 (`dep = a[5]`). Inserting the new column after `Depends on` keeps that
index unchanged; `Canonical reference` shifts from index 6 to 7 but is not read
positionally anywhere (the `/status` agent and the fixture parser both use the
header or ignore that column). Therefore **no positional consumer must move**,
satisfying AC10 without a code/test edit in this item.

### Surface ownership

- `docs/workflow.md` — the single normative statement of the model and grammar.
- `docs/artifact-conventions.md` — the template carries the column; the column
  note states what the column means and what the empty value is, and points to
  the workflow authority for the grammar, rather than restating it.
- `.opencode/agent/roadmap.md` and `.opencode/command/roadmap.md` — describe the
  column and its empty convention in terms consistent with the authority and
  reference it; neither states a conflicting grammar.

### Out-of-scope surfaces (recon correction)

`AGENTS.md`, `README.md`, and the `workflow-lifecycle` skill name no `Children`
columns today and render no table, so they are unchanged. `tests/**` is owned by
`0004-conflict-guards`; this item changes no test. Historical `work/**/roadmap.md`
and `work/**/design.md` artifacts are committed history and stay valid via the
absence rule.

## Alternatives considered

- **Make `docs/artifact-conventions.md` the grammar authority.** Pros: co-locates
  the grammar with the template that renders it. Cons: splits the semantic
  authority away from the readiness/`Depends on` authority in `docs/workflow.md`;
  contradicts AC12's "stated once and referenced elsewhere" pattern; AC4 requires
  the grammar to be defined independently of where a declaration is stored, which
  an artifact-shape document undercuts. **Rejected.**
- **Tagged/namespaced targets (`sibling:`, `item:`, `path:`).** Pros: removes the
  bare-reference resolution ambiguity outright. Cons: invents new vocabulary,
  contradicting AC3's three plain target kinds and the "reuse the shipped
  vocabulary unchanged" mandate (AC1, AC7); the existing `Depends on` grammar is
  untagged. **Rejected** in favor of deterministic resolution precedence.
- **A new planning-conflict class or finding code** (for example `(e)` /
  `DECLARED-CONFLICT`). Pros: an explicit code for declarations. Cons: directly
  forbidden by AC7 and the non-goals. **Rejected.**
- **Model declarations as readiness-like edges** (a second `Depends on`). Pros:
  reuses the existing graph machinery. Cons: violates AC6 (advisory only) and the
  roadmap's "declared claim, not a dependency" assumption. **Rejected.**
- **Append `conflicts-with` after `Canonical reference`.** Pros: no existing
  column shifts. Cons: separates the two relationship columns (`Depends on` and
  `conflicts-with`) with the identity column; provides no churn benefit because
  `Canonical reference` is not read positionally and `Depends on` stays at index 5
  under either placement. **Rejected** for readability.

## Interfaces and data model

**`Children` table schema** (roadmap artifact):

| Column | Values | Notes |
| ------ | ------ | ----- |
| Local id | `MMMM-slug` | unchanged |
| Title | text | unchanged |
| Scope | text | unchanged |
| Depends on | local ids, comma-separated, or `—` | unchanged; sole readiness input |
| conflicts-with | `ConflictTargetList` | new; advisory; absent column = `—` |
| Canonical reference | `NNNN-slug/MMMM-slug` | unchanged semantics; shifts index |

**`ConflictTargetList` / `ConflictTarget`** — as defined under "The grammar"
above. No frontmatter field, artifact `phase` value, or registry file is added.

**Resolution algorithm** (normative; consumed by `0003-conflict-check`):

```
resolve(token, row, table):
  if token == "" or token is whitespace-only -> malformed (unresolved declaration)
  if token matches ^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$:
     if token has no "/" and token == row.Local id       -> self-reference (unresolved)
     if token has no "/" and token is another row's Local id -> sibling  (resolved)
     else if work/<token>/ exists                            -> canonical ref (resolved)
     else                                                    -> unresolved
  else:
     if repo-relative exact path token exists (file or dir) -> surface (resolved)
     else                                                   -> unresolved
  duplicate targets within one list (after trim)            -> malformed (unresolved)
```

**Readiness** — unchanged. `satisfied(dep_local_id)`, `ready(child)`, and
`blocked_by(child)` in `docs/workflow.md` → `### Dependencies and readiness` take
no `conflicts-with` input. The section is not edited; the new subsection states
the advisory relationship explicitly.

**Reporting** — no new vocabulary. A detected declared conflict is classified
into the shipped `(a)`–`(d)` labels and rendered with the existing
`- [<CODE>] (<class>) <offender> — <detail>` grammar; an unresolved declaration is
reported the same way by the later check. Code selection is `0003`'s design,
constrained to an existing code.

## Affected areas

- `docs/workflow.md` — insert `### Declared conflicts (conflicts-with)` inside
  `## Roadmaps`, after `### Dependencies and readiness` (currently ends at
  `:108`) and before `### Status reporting` (`:110`). No edit to
  `## Merge conflicts`.
- `docs/artifact-conventions.md` — roadmap template header (`:110`), the two
  example rows (`:112-113`), and the column notes after `:133`.
- `.opencode/agent/roadmap.md` — operating principles/process step where
  `Depends on` is recorded (`:77-82`), and the quality bar (`:104-120`).
- `.opencode/command/roadmap.md` — the bullet list (`:10-23`).

## Backward compatibility and migrations

- **No migration.** An absent `conflicts-with` column reads as `—` for every
  row, so this roadmap, `0001`–`0005`, and all committed roadmaps stay valid. The
  committed suite never reads live `work/**` (`tests/README.md:29`), so live
  artifacts cannot break it.
- The template gains a column, but `Depends on` keeps its positional index, so
  existing parsers are unaffected.
- A present but empty cell is malformed rather than `—`; this only matters once
  the column exists, and is a stated vocabulary distinction, not a migration.
- No runtime, dependency, service, or toolchain change.

## Risks and mitigations

- **Positional-parser breakage** (`tests/checks/80-cycle-fixture.sh:50` reads
  `Depends on` at field 5 and asserts an exact 5-column header) — likelihood
  medium / impact high. Mitigation: insert `conflicts-with` after `Depends on` so
  field 5 is unchanged; `0004-conflict-guards` updates the fixture header and
  fixture; run `bash tests/run.sh` as the gate.
- **Bare-reference ambiguity** (a sibling local id and a top-level item can share
  `NNNN-slug`) — likelihood medium / impact medium. Mitigation: normative
  sibling-first resolution precedence in the authority grammar, so resolution is
  deterministic for any input.
- **A later check invents a new finding code** — likelihood medium / impact high.
  Mitigation: the authority explicitly reuses `(a)`–`(d)` and the existing
  grammar and states that no new class/code/policy is defined (AC7); `0003` is
  the consumer and must comply.
- **`conflicts-with` leaks into readiness** — likelihood low / impact high.
  Mitigation: state the advisory rule and keep the readiness algorithm untouched;
  verify by read and by the green suite (AC6, AC10).
- **Template/fixture skew between this item and `0004`** — likelihood certain /
  impact low. The template gains a column while the committed fixture still has
  five; the suite reads the fixture, not the template, so it stays green.
  Mitigation: record the skew; `0004` reconciles the fixture/check in its own
  change; no live `work/**` is read.
- **Exact-path surfaces too restrictive for a future need** — likelihood low /
  impact low. Mitigation: user confirmed exact paths; broader patterns can be
  added later as a grammar extension without forking the taxonomy.

## Test strategy

This item changes documents/prompts only; the committed guards for the new column
are child `0004-conflict-guards`, and the reporting behavior is child
`0003-conflict-check`. Verification here is therefore content/consistency
inspection plus the existing suite as a regression gate.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | Read `docs/workflow.md` → "Declared conflicts": planning-time conflict defined as declared committed claim, explicitly distinct from `## Merge conflicts` and `Depends on`, referencing the shipped classes. |
| AC2 | Read `docs/artifact-conventions.md` template: `conflicts-with` column present; column note explains meaning and the empty value. |
| AC3 | Read the authority grammar: three target kinds, comma separation, `—` empty value. |
| AC4 | Same grammar stated independently of storage; no container/field decided. |
| AC5 | Authority states one-sided declaration is a conflict (no reciprocity). |
| AC6 | Authority states no readiness effect; readiness algorithm/`Depends on` parsing unchanged; `bash tests/run.sh` green. |
| AC7 | Authority references `(a)`–`(d)` and the finding grammar; states no new class/code/policy. |
| AC8 | Authority states no self-reference and no duplicate target; resolution algorithm handles both as malformed. |
| AC9 | Read `.opencode/agent/roadmap.md` and `.opencode/command/roadmap.md`: both describe the column consistently and reference the authority. |
| AC10 | Design analysis: `Depends on` stays at field 5; no positional consumer must move. `bash tests/run.sh` exit 0. |
| AC11 | Authority states unresolved targets are reported later, never dropped. |
| AC12 | Cross-surface read: one authoritative grammar in `docs/workflow.md`; template note and agent/command reference it; none states a conflicting grammar. |

Manual/consistency checks are the observable form for the doc criteria; `0004`
later converts them into fixture-based committed guards.
