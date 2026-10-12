---
feature: 0011-recursive-bootstrap/0001-recursive-model
phase: design
status: final
created: 2026-10-12
updated: 2026-10-12
conflicts-with: "docs/workflow.md, AGENTS.md"
parent: 0011-recursive-bootstrap
---

# Design — Recursive lifecycle model

## Summary

State the recursive lifecycle model once, as a new authoritative section in
`docs/workflow.md`, and cross-reference it from `AGENTS.md`. The model
generalizes the existing single-level lifecycle and the depth-limited roadmap
special case into one uniform rule: a **node** is any work item, it may
decompose into children to unbounded depth, and the six-phase cycle applies at
every node. The new section is composed entirely by reference to the shipped
authorities (phases, readiness, declared conflicts, backtracking, derived
state), so it introduces no second state model, no new vocabulary, and no
implementation.

## Approach

The deliverable is framework documentation, so the "interface" is a document
contract. The design adds **one** new section and makes two minimal,
non-destructive edits elsewhere:

1. **New section `## The recursive lifecycle model` in `docs/workflow.md`**,
   placed immediately after `## Mental model` and before `## The work item
   directory`, so the vocabulary is established before the directory layout and
   the `## Roadmaps` section. It is the single authority for the model and
   contains required normative statements covering AC1–AC9 (listed under
   "Interfaces and data model").

2. **A deferral note at the top of the existing `## Roadmaps` section.** The
   current section opens by defining "A **roadmap** is a parent work item that
   plans a broad, multi-feature initiative". Left as-is, that is a second,
   competing definition of the term (AC6). The edit prepends a short note that
   `roadmap` is the deprecated alias, that the new model section is the
   authority for the term, and that this section describes the shipped,
   depth-limited concrete spelling. The existing operational text is preserved
   verbatim (it contains literals pinned by the suite; see Risks).

3. **A cross-reference in `AGENTS.md`**, added to `## The artifact contract`
   beside the existing roadmap paragraph, plus the **identical** body edit in
   `template/AGENTS.md`. `tests/checks/95-split-guard.sh` requires the two files
   to be byte-identical outside the `## Project profile` section, so the edit is
   made to both in the same commit.

Composition is by reference, never by restatement. The section names the
shipped authorities (`## Phases`, `### Dependencies and readiness`,
`### Declared conflicts (conflicts-with)`, `## Phase reversal (backtracking)`,
`## Derived state`) and states that the recursive model reuses them unchanged.
It does **not** repeat the readiness algorithm, the conflict grammar, the
backtrack record shapes, or any command signature — those are single-source
pinned by the committed suite.

## Alternatives considered

- **Option A (chosen) — one new authority section plus minimal deferral edits.**
  Pros: satisfies "stated once as the single authority" (AC1, AC6, AC10) with
  the smallest diff; touches no pinned contract text; every downstream owner
  (`0002`, `0003`, `0004`) consumes a stable section. Cons: a reader still sees
  the depth-limited `## Roadmaps` text and must follow the deferral note to the
  model.
- **Option B — rewrite the `## Roadmaps`, `### Dependencies and readiness`,
  `### Declared conflicts`, `## Derived state`, and `## Phase reversal`
  sections to be recursive in this item.** Rejected: those sections are the
  reference grammar (`0002-recursive-schema`), the recursive writer
  (`0003-recursive-writer`), and readiness/derived state (`0004-recursive-readiness`)
  by the spec's own non-goals and sibling boundaries; rewriting them would fork
  sibling-owned decisions and risk breaking the single-source guards
  (`tests/checks/10-readiness.sh`, `80-cycle-fixture.sh`, `85-conflict-guards.sh`,
  `87-backtrack-guards.sh`).
- **Option C — a new standalone document (or skill) for the model.** Rejected:
  AC10 requires the workflow authority (`docs/workflow.md`) to state the model
  once; a second document is itself a competing surface, and a new skill would
  change the documented skill inventory, violating AC11.
- **Option D — generalize the model inline across the existing sections with no
  new section.** Rejected: the model could not then be "stated once as its single
  authority" (AC1, AC6), and duplicate fragments across sections would drift.

## Interfaces and data model

### New `docs/workflow.md` section

- **Heading:** `## The recursive lifecycle model` (a `##` heading, not
  `### <n>.`, so `tests/checks/96-signature-sweep.sh`'s phase-heading extractor
  is unaffected). Placed after `## Mental model`, before `## The work item
  directory`.
- **Subsections** (proposed `###` headings; none begins with a digit+dot):
  `### Terms`, `### The cycle applies at every node`, `### Where decomposition
  is authored and recorded`, `### Granularity and hybrid nodes`,
  `### Composition with the shipped model`.

Required normative statements, mapped to acceptance criteria:

- **AC1** — The standard six-phase cycle applies uniformly at every node. Define:
  a **node** is any work item in the recursive plan tree; a **leaf** is a node
  with no children; a **decomposition** is a node's enumerated child set.
- **AC2** — The model imposes no maximum recursion depth: any node may decompose
  into children, and both a one-segment standalone item (`NNNN-slug`) and a
  nested child (`NNNN-slug/MMMM-slug`) are valid instances of the same model.
- **AC3** — A node's child set is authored and recorded in the planning (design)
  step — the `/plan` (`architect`) step. `/roadmap` is retained as a deprecated
  alias for that step. A decomposing node's child set is **committed plan
  state**. The concrete writer's command/agent wiring is owned by
  `0003-recursive-writer`; this item fixes only the model.
- **AC4** — A plan may decompose into a **hybrid** of tasks, features,
  initiatives, and larger items. Fine-grained `tasks.md` entries remain a
  leaf's internal work list and are **not** nodes; a planner creates a child by
  explicitly decomposing an item, never by promoting a task.
- **AC5** — A node may carry its own phase artifacts and a child set at the same
  time. The standard cycle applies to the node's own artifacts independently of
  its children; no node is required to be a pure container.
- **AC6** — The section states the model vocabulary once as the single
  authority — **work item**, **node**, **leaf**, **decomposition**, **plan** —
  and defines `roadmap` only as a deprecated alias for a decomposing node. No
  other surface states a competing definition (enforced by the `## Roadmaps`
  deferral note and the `AGENTS.md` cross-reference).
- **AC7** — The shipped backtracking/re-entry model
  (`## Phase reversal (backtracking)`) applies per node, on the same unshipped
  work item: the reverse edges, `stale:` marking, re-entry, recall, and the
  ownership invariant are reused unchanged. The recursive model introduces no
  second state model, no new `phase` value, and no new reversal mechanism for a
  decomposition.
- **AC8** — The model reuses the shipped `Depends on`/readiness vocabulary
  (`### Dependencies and readiness`) and declared-conflict vocabulary
  (`### Declared conflicts (conflicts-with)`) without change. Readiness,
  reporting, and derived state across levels are owned by
  `0004-recursive-readiness`; the reference grammar, per-level sequence
  allocation, and the `parent` chain by `0002-recursive-schema`. The model adds
  no new dependency edge, conflict class, or state vocabulary.
- **AC9** — A one-segment standalone work item behaves exactly as before with no
  forced migration; existing committed `work/` content, including today's
  roadmap parents and their nested children, remains valid under the model.

**Must-not-restate list** (to preserve single-source guards): the readiness
algorithm literal `satisfied(dep_local_id):`
(`tests/checks/10-readiness.sh` requires it exactly once, in the `## Roadmaps`
section); the conflict classes/codes and finding-line grammar
(`tests/checks/85-conflict-guards.sh` scopes those to `## Declared-conflict
check`); the backtrack record/field/marker literals
(`tests/checks/87-backtrack-guards.sh`); the cycle literals owned by
`tests/checks/80-cycle-fixture.sh`; and every command signature
(`tests/checks/96-signature-sweep.sh`). The new section references these
authorities by name.

### `## Roadmaps` deferral note (`docs/workflow.md`)

Prepend, before the existing first paragraph, a short note to the effect of:

> `roadmap` is the deprecated alias for a decomposing node; "The recursive
> lifecycle model" is the authority for the term. This section describes its
> shipped, depth-limited concrete spelling.

The existing prose from "A **roadmap** is a parent work item..." onward is left
verbatim, so the literals pinned by `10-readiness.sh` and `80-cycle-fixture.sh`
are untouched.

### `AGENTS.md` cross-reference and `template/AGENTS.md` mirror

In `## The artifact contract`, after the existing roadmap paragraph, add one
sentence, e.g.:

> Every work item is a **node** in a recursive plan: a node may decompose into
> children to unbounded depth, and may carry its own phase artifacts and a child
> set at the same time. `docs/workflow.md` → "The recursive lifecycle model" is
> the single authority; `roadmap` is a deprecated alias for a decomposing node.

The **identical** sentence is added at the same position in `template/AGENTS.md`
(the two files differ only inside `## Project profile`, enforced by
`tests/checks/95-split-guard.sh`). The sentence is prose, not a markdown table
row, so `96-signature-sweep.sh`'s AGENTS-table/`Supporting commands:` extractors
are unaffected.

### Declared conflicts

`conflicts-with: "docs/workflow.md, AGENTS.md"` — the same set the parent
roadmap cell declares (`work/0011-recursive-bootstrap/roadmap.md:103`), so the
child's declared set (the union of own and cell) does not trigger a spurious
`DRIFT-FACT`. `template/AGENTS.md` is an affected surface (a mechanical parity
mirror of the `AGENTS.md` edit) but is deliberately not separately declared,
because declaring a set unequal to the parent cell would itself be reported as
declaration drift. This is documented here rather than asserted as a second
authority.

### Backward compatibility

No artifact format, frontmatter field, reference, or command changes. The new
section is prose plus an alias statement. No migration is required (AC9).

## Affected areas

- `docs/workflow.md` — **new** `## The recursive lifecycle model` section
  (after `## Mental model`, before `## The work item directory`); a prepended
  deferral note in `## Roadmaps`. No existing pinned literal is edited.
- `AGENTS.md` — one cross-reference sentence in `## The artifact contract`.
- `template/AGENTS.md` — the byte-identical mirror of the `AGENTS.md` sentence.
- No other file. No agent, command, or skill is added or changed; no test file
  is added (committed guards are deferred to a successor roadmap per the spec's
  non-goals); no inventory count changes.

Out of scope (documented follow-ups, not tasks here): the concrete recursive
writer (`0003-recursive-writer`), the recursive schema/reference/allocation
(`0002-recursive-schema`), readiness/derived-state/`/status`
(`0004-recursive-readiness`), and roadmap deprecation/migration (a successor
roadmap).

## Risks and mitigations

- **Breaking a single-source guard by restating pinned vocabulary.** —
  Likelihood: medium / Impact: high / Mitigation: compose by reference only;
  enforce the "must-not-restate list"; verify `10-readiness.sh`,
  `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `87-backtrack-guards.sh`, and
  `96-signature-sweep.sh` stay green.
- **`AGENTS.md`/`template/AGENTS.md` body-parity break.** — Likelihood: medium /
  Impact: high / Mitigation: make both edits in one commit; T6 verifies
  `95-split-guard.sh` green.
- **A competing `roadmap` definition remains.** — Likelihood: medium / Impact:
  medium / Mitigation: the model section owns the term; the `## Roadmaps`
  deferral note and the `AGENTS.md` sentence both defer to it.
- **Accidental inventory or contract change (AC11).** — Likelihood: low /
  Impact: high / Mitigation: no new command/agent/skill and no count line edit;
  verify `40-inventory.sh` and `96-signature-sweep.sh` green and the full suite
  passing.
- **New content is scanned by a narrow suite extractor.** — Likelihood: low /
  Impact: medium / Mitigation: use a `##` heading and non-numeric `###`
  subsections; place the section outside the `85-conflict-guards.sh` and
  `96-signature-sweep.sh` extraction scopes.
- **The section bloats `docs/workflow.md` (always-loaded).** — Likelihood: low /
  Impact: low / Mitigation: keep it normative and terse; state rules once and
  reference authorities rather than repeating them.

## Test strategy

The deliverable is documentation. The spec explicitly defers committed
fixtures/agreement areas to a successor roadmap, so **no new test file is
added**; this item is verified by the existing committed suite plus review of
the authored text.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Review + grep: uniform six-phase statement and the node/leaf/decomposition definitions in the new section. |
| AC2 | Review + grep: no maximum depth; any node may decompose; standalone and nested are instances. |
| AC3 | Review + grep: planning-step authoring, `/roadmap` deprecated alias, committed plan state, `0003-recursive-writer` pointer. |
| AC4 | Review + grep: hybrid granularity; `tasks.md` entries are not nodes. |
| AC5 | Review + grep: own artifacts + children; cycle applies independently; no pure-container requirement. |
| AC6 | Review + grep: five terms stated once; `roadmap` only as a deprecated alias; the `## Roadmaps` deferral and `AGENTS.md` sentence remove the competing definition. |
| AC7 | Review + grep: per-node composition statement referencing `## Phase reversal (backtracking)`; `87-backtrack-guards.sh` green. |
| AC8 | Review + grep: readiness/conflict reuse by reference; `10-readiness.sh` and `85-conflict-guards.sh` green (single-source preserved). |
| AC9 | Review + grep: backward compatibility / no forced migration; `80-cycle-fixture.sh` green. |
| AC10 | Review + grep: section present in `docs/workflow.md`; cross-reference present in `AGENTS.md`; `95-split-guard.sh` and `96-signature-sweep.sh` green. |
| AC11 | `bash tests/run.sh` exits 0; `40-inventory.sh` and `96-signature-sweep.sh` confirm no inventory/command change; the six core commands, `phase` set, and `Depends on`/readiness and declared-conflict text unchanged. |
