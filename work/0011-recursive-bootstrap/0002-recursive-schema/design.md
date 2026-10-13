---
feature: 0011-recursive-bootstrap/0002-recursive-schema
phase: design
status: final
created: 2026-10-12
updated: 2026-10-12
conflicts-with: "docs/artifact-conventions.md, docs/workflow.md, tests/checks/80-cycle-fixture.sh"
parent: 0011-recursive-bootstrap
---

# Design — Recursive work-item schema, references, and sequence allocation

## Summary

Generalize the work-item schema **in place** in its existing authority,
`docs/artifact-conventions.md`: turn the two-level canonical reference into a
recursive path, apply per-level sequence allocation at every depth, generalize
the frontmatter `parent:` chain, and recast `roadmap.md` as the generic
**manifest** every decomposing node carries at every depth — preserving the
six-column `Children` header and the `conflicts-with` grammar unchanged. Two
minimal `docs/workflow.md` restatements (the work-item layout and the
canonical-reference bullet) are reconciled with it; no file name, `phase` value,
artifact-presence row, command, agent, skill, or test file is added.

## Approach

The deliverable is framework documentation, so the "interface" is a document
contract. The design extends the shipped grammar rather than forking it, using
the smallest diff that satisfies AC1–AC11:

1. **`docs/artifact-conventions.md` — the schema authority (primary).** Five
   places carry the schema, all generalized in place:
   - the top-of-file layout sentence (lines 3–4);
   - the `## Frontmatter` template comments and rules for `feature:` and
     `parent:` (lines 18, 24, 32–36, 96–98);
   - the `## Work item references` section (lines 68–98) — the canonical
     reference grammar and its resolution rule;
   - the `## Sequence allocation` section (lines 630–647) — the per-level
     allocation rule;
   - the `### roadmap.md` template section (lines 107–179) — recast as the
     **manifest** of a decomposing node at every depth, plus the `.gitkeep`
     reservation rule.

2. **`docs/workflow.md` — two minimal restatements only.** Per AC11 the schema
   is stated in `docs/artifact-conventions.md`; `docs/workflow.md`'s
   restatements of the **reference grammar** and the **work-item layout** are
   made consistent with it:
   - the canonical-reference bullet in `## The work item directory`
     (lines 135–138), generalized from a two-level maximum to the recursive
     path and pointed at `docs/artifact-conventions.md` → "Work item
     references";
   - the directory-layout block in the same section (lines 113–129), plus one
     sentence noting the layout repeats at every level.

   Nothing else in `docs/workflow.md` is edited. In particular the pinned
   authority sections — `### Dependencies and readiness`,
   `### Declared conflicts (conflicts-with)`, `## Declared-conflict check`,
   `## Phase reversal (backtracking)`, `## Derived state`, the `## Roadmaps`
   operational text, and the phase headings — are left byte-for-byte.

Composition is **extend, do not fork**: the one-segment reference stays valid
and is stated as the special case of the recursive path; the two-segment form
becomes a special case rather than a maximum; `roadmap.md`/`phase: roadmap`
remains the manifest's shipped spelling. The `conflicts-with` grammar
(`SiblingOrItemRef` and the exact surface-path form, the reference-vs-path
discriminator, sibling-first precedence) is preserved unchanged and its
generalization is explicitly deferred to the successor roadmap (AC7).

### Why `docs/artifact-conventions.md` is the home

The reference grammar, sequence allocation, frontmatter fields, and manifest
template already live there; the spec's "Deliverable surfaces" names those three
sections plus the frontmatter. Keeping the single recursive statement there and
having `docs/workflow.md` defer to it by name preserves the single-source
discipline the committed suite enforces.

## Alternatives considered

- **Option A (chosen) — generalize the existing authority in place, with two
  minimal `docs/workflow.md` restatements.** Pros: smallest diff; no fork of the
  reference grammar or manifest; every pinned literal in the workflow authority
  stays untouched; the sibling owners (`0003`, `0004`) consume a stable,
  extended grammar. Cons: a reader of `docs/workflow.md` alone sees a pointer
  rather than the full grammar (acceptable — that is already how the canonical
  reference regex is documented).
- **Option B — put the recursive schema in a new authoritative section in
  `docs/workflow.md` (or a new document) and make `docs/artifact-conventions.md`
  defer to it.** Rejected: AC11 names `docs/artifact-conventions.md` as the
  deliverable; moving the reference grammar would fork the schema across surfaces
  and risk a *competing* grammar, which AC11 forbids. A new document would also
  be a second surface.
- **Option C — introduce a new machine-readable manifest file (or
  `.manifest.yml`) and/or a new `phase` value.** Rejected by the resolved
  open question and AC5: `roadmap.md` with `phase: roadmap` remains the shipped
  spelling at every depth; no new file name, `phase` value, or artifact-presence
  row. Renaming/retiring `roadmap.md` is Roadmap 2.
- **Option D — generalize every surface that restates the two-level grammar now
  (the conflict-target regex, the `status`/`product` agents, the
  `workflow-lifecycle` skill, `README.md`, the roadmap agent/command).**
  Rejected: out of scope. Conflicts-at-depth is Roadmap 3, the surface sweep is
  Roadmap 4, and the guard work is Roadmap 5; editing those surfaces now would
  touch pinned literals and contradict AC7/AC11. They are recorded as
  follow-ups.

## Interfaces and data model

### Canonical reference (recursive path)

Replaces the two-level grammar in `docs/artifact-conventions.md` → "Work item
references" (and the workflow layout's restatement):

```
item-ref ::= NNNN-slug ( "/" MMMM-slug )*          # one segment = standalone
                                                   # two segments = the special case
segment  ::= [0-9]{4}-[a-z0-9-]+
reference regex: ^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$
```

- The **first** segment is the top-level `NNNN`, allocated across the whole
  `work/` tree as today.
- Each **further** `MMMM` segment is local to its **immediate** parent (the
  preceding segment), independent of the top-level sequence and of every other
  node.
- A reference resolves to `work/<item-ref>/` by following its segments.
- The one-segment standalone form is unchanged; the two-segment form is a
  special case, not a maximum.
- A trailing slash, an empty segment, or a non-conforming segment is not a valid
  reference.

### Frontmatter (`feature`, `parent`)

- `feature` is the item's full canonical reference: one segment for a standalone
  item, two or more for a nested child. (AC2)
- `parent` is optional and set only on a nested child; its value is the
  **immediate** parent's canonical reference — one segment (`NNNN-slug`) at
  depth two, and the parent's full multi-segment reference at depth three or
  deeper. The full ancestor chain is derivable from the directory path. A
  standalone item omits `parent`. (AC4)
- The template comment for `parent:` and the two rules bullets are updated to
  say this; `stale: ""`, `reopened: ""`, and the
  `spec | design | build | test | review` literal are left untouched (pinned by
  `tests/checks/87-backtrack-guards.sh`).

### Manifest (child enumeration)

- A node that decomposes into children records them in its **manifest**: the
  generic child-enumeration source for any decomposing node.
- The manifest's shipped concrete spelling is `roadmap.md` with
  `phase: roadmap`, at **every** depth. No new file name, `phase` value, or
  artifact-presence row is introduced (AC5).
- The `Children` table remains the machine-readable source, with its
  **six-column positional header unchanged** — `Depends on` at pipe-field 5 and
  `conflicts-with` at pipe-field 6 (AC6). Each row's `Canonical reference`
  resolves to that child's directory; `Depends on` names only sibling local ids
  in the same table with the stored graph acyclic (unchanged text).
- Each child directory is reserved with a `.gitkeep` at that level
  (`work/<parent-ref>/<MMMM-slug>/.gitkeep`), at every depth (AC8).
- The `conflicts-with` bullet is preserved and gains one deferral sentence: the
  shipped two-level `SiblingOrItemRef`/surface grammar is unchanged, and
  generalizing conflict targets to arbitrary depth is deferred to the successor
  roadmap that owns "`conflicts-with` at every level" (AC7).

### Sequence allocation (per level)

Generalizes `docs/artifact-conventions.md` → "Sequence allocation":

- Top-level `NNNN`: unchanged (greatest 4-digit prefix ever committed under
  `work/`, plus one).
- Every further level: a parent node's children's local `MMMM` is the greatest
  4-digit prefix ever committed under `work/<parent-ref>/`, plus one, never
  reused within that parent; the same contract applies at every level, scoped to
  the **immediate** parent (AC3).
- `### Renumbering after a parallel merge` is left unchanged: cross-branch
  duplicate detection for recursive trees is a successor roadmap (Roadmap 3),
  not this item.

### Backward compatibility

No artifact format, reference, frontmatter field, command, or `phase` value is
removed or changed in a breaking way. A one-segment standalone item and every
existing committed two-level roadmap parent/child remain valid with **no forced
migration**; the two-segment grammar is a special case of the recursive path, so
no existing reference changes meaning (AC9).

## Affected areas

- `docs/artifact-conventions.md` — top-of-file layout sentence (3–4);
  `## Frontmatter` `feature`/`parent` comments and rules (18, 24, 32–36, 96–98);
  `## Work item references` (68–98); `## Sequence allocation` (630–647);
  `### roadmap.md` template section intro and bullets (107–179). The fenced
  template block, the six-column header line (137–138), and the
  `stale: ""`/`reopened: ""` literals are preserved.
- `docs/workflow.md` — `## The work item directory` only: the directory-layout
  block plus one sentence (113–129) and the canonical-reference bullet
  (135–138). No other section is touched.
- No other file. No agent/command/skill is added or changed; no test file is
  added (committed guards are deferred to a successor roadmap per the spec's
  non-goals); no inventory count changes.

**Must-not-restate / must-not-touch (single-source guards):**

- `docs/workflow.md`: `satisfied(dep_local_id):` (exactly once,
  `tests/checks/10-readiness.sh`); `even if unshipped`,
  `presence is the sole shipped signal`, `ship.md` precedence (10-readiness);
  `A child in a cycle is never \`ready\``, `integrity findings rather than
  failing`, `CYCLIC-DEP`, `cycle members are never reported ready` (80-cycle-fixture);
  the whole `## Declared-conflict check` section's codes/classes/grammar
  `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT`, `(a)`/`(b)`/`(d)`, and the
  finding-line grammar, with no `(e)`/`DECLARED-`/`PLAN-`/`CONFLICT-` (85-conflict-guards);
  the reverse-edge table rows, the derived-state labels `` `P` (backtracked) ``,
  `` `P` (reopened) ``, `challenged (blocked)`, `build (rework)`, `stale: design`,
  `stale: spec`, `finding | severity | acceptance-criterion` (87-backtrack-guards);
  the derived-state table row literals and the artifact names (20-lifecycle);
  and any command signature / phase heading
  (96-signature-sweep — do not add a `### <n>. ` heading).
- `docs/artifact-conventions.md`: the `backtracks.md`/`challenges.md` record
  shapes and their pinned literals (`record: backtracks`, `record: challenges`,
  `- detecting phase:`, `- target phase:`, `- affected:`, `- status: open`,
  `- resolves: Finding <n>`, `- revision:`, the `## Challenge/Withdrawal/Reversal`
  headers, `- withdraws: Challenge <n>`, `- reverses: Response <n>`,
  `- adjudicator:`, `- decision:`, `` `finding` ``, `` `severity` ``,
  `` `acceptance-criterion` ``, `spec | design | build | test | review`,
  `stale: ""`, `reopened: ""`) — all pinned by `tests/checks/87-backtrack-guards.sh`.
- `tests/checks/80-cycle-fixture.sh` is a declared conflict surface and stays
  green unedited; it pins the six-column positional header, whose form this
  design preserves.

Out of scope (documented follow-ups, not tasks here): the concrete recursive
writer (`0003-recursive-writer`); readiness/derived-state/`/status`
(`0004-recursive-readiness`); roadmap deprecation and migration (Roadmap 2);
`conflicts-with` at every level and recursive-tree duplicate detection/renumbering
(Roadmap 3); the agent/command/inventory surface sweep (Roadmap 4); committed
recursive-workflow guards (Roadmap 5).

**Declared conflicts.** `conflicts-with:
"docs/artifact-conventions.md, docs/workflow.md, tests/checks/80-cycle-fixture.sh"`
— the same set as this child's parent `Children` row cell
(`work/0011-recursive-bootstrap/roadmap.md:104`), so the declaration is one-sided
and does not report `DRIFT-FACT`. The declaration is advisory and adds no
readiness edge.

## Risks and mitigations

- **Breaking a single-source guard by restating pinned vocabulary.** —
  Likelihood: medium / Impact: high / Mitigation: edit only the named
  schema/restatement spots; enforce the must-not-touch lists above; verify
  `10-readiness.sh`, `20-lifecycle.sh`, `80-cycle-fixture.sh`,
  `85-conflict-guards.sh`, `87-backtrack-guards.sh`, and `96-signature-sweep.sh`
  stay green and `bash tests/run.sh` exits 0.
- **`docs/workflow.md` contradicts the generalized grammar (a competing
  reference grammar).** — Likelihood: medium / Impact: medium / Mitigation: the
  layout's canonical-reference bullet is rewritten and explicitly defers to
  `docs/artifact-conventions.md` → "Work item references"; no other
  `docs/workflow.md` bullet restates the reference grammar.
- **Editing the conflict grammar or its section by accident (AC7).** —
  Likelihood: low / Impact: high / Mitigation: leave the `## Declared-conflict
  check` section and the conflict-target regex untouched; put the AC7 deferral
  sentence in `docs/artifact-conventions.md` (unscanned by
  `85-conflict-guards.sh`).
- **A new `### <n>. ` heading trips the signature sweep.** — Likelihood: low /
  Impact: medium / Mitigation: no new heading is added to `docs/workflow.md`'s
  phase list; the layout edit is prose plus a code block.
- **`.gitkeep` reservation stated without a guard could drift.** —
  Likelihood: low / Impact: low / Mitigation: stated once in the manifest
  section; committed guards are a successor roadmap's concern (spec non-goal),
  and the recovery signal is that `/status` already treats a `.gitkeep`-only
  child as `not started`.
- **Accidental inventory or contract change (AC11).** — Likelihood: low /
  Impact: high / Mitigation: no new command/agent/skill and no count-line edit;
  verify `40-inventory.sh`, `96-signature-sweep.sh`, and the full suite green;
  `git diff --name-only` lists only the two documentation files.

## Test strategy

The deliverable is documentation and the spec explicitly defers committed
fixtures/agreement areas to a successor roadmap, so **no new test file is
added**. Verification is the existing committed suite (which stays green) plus
review/grep of the authored text.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Review + grep: `docs/artifact-conventions.md` → "Work item references" states the recursive path, keeps the one-segment form, and calls the two-segment form a special case. |
| AC2 | Review + grep: the resolution bullet maps `work/<item-ref>/` by segments; the frontmatter rules set `feature:` to the full reference and `parent:` to the immediate parent. |
| AC3 | Review + grep: "Sequence allocation" scopes `MMMM` to the immediate parent at every level. |
| AC4 | Review + grep: `parent:` names the immediate parent's canonical reference; one segment at depth two, the multi-segment reference at depth ≥ 3; derives from the path; standalone omits. |
| AC5 | Review + grep: the `roadmap.md` section states the manifest as the generic enumeration source and `roadmap.md`/`phase: roadmap` as its spelling at every depth; no new file/`phase`/presence row. |
| AC6 | Review + grep: the six-column positional header is preserved; `80-cycle-fixture.sh` and `85-conflict-guards.sh` green. |
| AC7 | Review + grep: the `conflicts-with` grammar is unchanged and the deferral sentence is present; `85-conflict-guards.sh` green. |
| AC8 | Review + grep: `.gitkeep` reservation at every depth is stated. |
| AC9 | Review + grep: backward-compatibility statement; one-segment and two-level forms valid with no migration; `80-cycle-fixture.sh` green. |
| AC10 | `bash tests/run.sh` exits 0 with `TOTAL: <p> passed, 0 failed`; `40-inventory.sh`, `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `96-signature-sweep.sh` green; no new command/agent/skill; inventory counts unchanged. |
| AC11 | Review + grep: the schema is stated in `docs/artifact-conventions.md` and only the reference/layout restatements are made in `docs/workflow.md`; `git diff --name-only` lists exactly `docs/artifact-conventions.md` and `docs/workflow.md`; no competing grammar/manifest definition. |
