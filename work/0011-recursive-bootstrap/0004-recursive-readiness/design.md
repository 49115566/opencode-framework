---
feature: 0011-recursive-bootstrap/0004-recursive-readiness
phase: design
status: final
created: 2026-10-12
updated: 2026-10-12
conflicts-with: "docs/workflow.md, .opencode/agent/status.md"
parent: 0011-recursive-bootstrap
---

# Design — Readiness, derived state, and status across recursion

## Summary

Generalize readiness, derived state, and the `/status` report **in place** in
their existing authorities: the two `docs/workflow.md` sections named by the spec
(`### Dependencies and readiness`, `## Derived state`), the report-shape section
that feeds them (`### Status reporting`), and the `status` agent
(`.opencode/agent/status.md`). The shipped single-level rule is extended so every
node of a recursive plan applies it independently; the corresponding
`.opencode/command/status.md` and the `workflow-lifecycle` skill receive only the
minimal restatement needed so no live surface contradicts the authority. No new
`phase` value, readiness algorithm, dependency edge kind, report artifact, or
file is introduced.

## Approach

The deliverable is framework documentation and prompts, so the "interface" is a
document contract. The design extends the shipped text with additive sentences
and one qualified table row, preserving every literal the committed suite pins.
Six edits, composed **by reference** to the shipped authorities:

1. **`docs/workflow.md` → `### Dependencies and readiness` (lines 170–208)** —
   generalize the readiness rule to a recursive tree:
   - Keep the six-column `Children` table as the single machine-readable source
     of the child set and dependency graph.
   - State **sibling-only at every level** (AC1): a `Depends on` cell names only
     a **sibling local id in the same `Children` table**; an ancestor,
     descendant, cousin, or cross-tree target is not a valid dependency edge, and
     is reported by the shipped integrity window (`DANGLING-DEP`) rather than
     accepted. No new dependency edge kind.
   - State **the same rule at every level, independently** (AC2): each
     decomposing node applies readiness to its own immediate children; a child
     directory resolves against the node's own canonical reference.
   - State **decomposing target — own signal only** (AC3): a `Depends on` target
     that is itself a decomposing node is satisfied if and only if its own
     shipped signal holds (`ship.md` present with no `reopened:` marker, or
     `review.md` verdict `approve`); its descendants are not consulted (no
     recursive propagation).
   - In the algorithm block, change **only** the `child_dir` path token so the
     lookup is rooted at the decomposing node's own canonical reference
     (`work/<node-ref>/<dep_local_id>/`); the marker `satisfied(dep_local_id):`
     and every commented branch line stay byte-for-byte.
   - Keep the shipped prose and its pinned phrases: `even if unshipped`,
     `presence is the sole shipped signal`, `` `ship.md` presence takes
     precedence ``, the recalled-item revocation sentence, and
     `A child in a cycle is never \`ready\``.

2. **`docs/workflow.md` → `### Status reporting` (lines 279–292)** — generalize
   the report shape to arbitrary depth (AC6, AC7):
   - `/status` renders each decomposing node followed by its descendants
     **indented to arbitrary depth**; every node at every level shows its derived
     phase and its readiness as `ready` or `blocked: <local ids>`.
   - Each decomposing node's row shows `<ready>/<total> ready` across its
     **immediate** children plus a distribution tally of those children across
     phases (`<phase> <n>, ...`); each blocked child names the specific siblings
     that block it; readiness is derived live and never stored.
   - Keep the integrity bullet list (`DANGLING-DEP`, `MISSING-CHILD`,
     `UNLISTED-CHILD`, `CYCLIC-DEP`) verbatim and the exact phrases
     `integrity findings rather than failing` and `cycle members are never
     reported ready`.

3. **`docs/workflow.md` → `## Derived state` (lines 1126–1197)** — add the
   recursive derivation rule (AC4, AC5, AC9):
   - A node that has children derives its phase from **its own phase artifacts
     first**; only a node with a manifest (`roadmap.md`) **and no own phase
     artifacts** derives the container phase `roadmap`. Own artifacts take
     precedence over the manifest at every depth.
   - Qualify the table row `| `roadmap.md` present (check before `spec.md`) |
     roadmap |` to `| `roadmap.md` present and no own phase artifacts (check
     before `spec.md`) | roadmap |`; keep it in the same precedence position.
   - State that this composes with the **unchanged** shipped precedence: the
     structural `stale:` and `reopened:` rows, then the unshipped open-challenge
     blocked overlay, then the artifact-presence and verdict rows; no new
     `phase` value and no second state model.
   - Generalize the closing paragraph (lines 1194–1197): a directory containing
     `roadmap.md` is a **decomposing node**; its own artifacts take precedence;
     a `.gitkeep`-only node is `not started`.
   - Keep every pinned literal: `P (backtracked)`, `P (reopened)`,
     `challenged (blocked)`, `build (rework)`, and the artifact-presence row
     literals (`\`spec.md\` missing`, `\`spec.md\` present, \`design.md\`
     missing`, …).

4. **`.opencode/agent/status.md`** — generalize the reporting agent, deferring to
   the authority by name (AC2, AC4, AC6, AC7, AC9, AC10):
   - `<role>`/`<mission>`: descend to arbitrary depth and report the tree; each
     node shows its derived phase and readiness.
   - `<operating_principles>`: replace the "a directory containing `roadmap.md`
     is a roadmap **parent**" rule with "a **decomposing node** (at any depth)"
     and add the own-artifacts-first / manifest→`roadmap` fallback derivation.
   - `<inputs>`: reference `## The recursive lifecycle model` and the
     readiness/derived-state authority at every depth.
   - `<process>`: classify recursively; apply readiness at every level
     (sibling-only; a decomposing dependency target is satisfied by its own
     signal only); render the indented recursive tree.
   - `<readiness>`: keep the deferral sentence to `Dependencies and readiness`
     and the shipped recap; add per-level independence and the
     decomposing-target-own-signal-only rule; keep
     `A child in a cycle is never \`ready\``.
   - `<quality_bar>`/`<output_format>`: show a tree indented to at least three
     levels, each node with its phase and `ready`/`blocked`.
   - Keep `CYCLIC-DEP`, `informational and never fatal`, the flattened
     `members of a cycle are never reported` phrase, and the
     `## Declared-conflict check` reference.

5. **`.opencode/command/status.md`** — minimal coherent restatement (AC6, AC10):
   generalize the "roadmap parent"/two-level language to arbitrary depth and add
   the own-artifacts-first derived-phase rule and per-level readiness. Keep
   `Report them without failing`, the lowercase `a child in a cycle is never
   \`ready\``, `CYCLIC-DEP`, the `## Declared-conflict check` reference, and the
   `Usage: /status [item-ref]` description string.

6. **`.opencode/skill/workflow-lifecycle/SKILL.md` → `## Derived states`
   (lines 56–88)** — minimal coherent restatement (AC4, AC5, AC9, AC10): add
   that a decomposing node derives its own phase from its own phase artifacts
   first (only a manifest with no own artifacts derives `roadmap`) and that
   readiness is derived independently at every level. Keep the section's
   `docs/workflow.md` deferral, every routing literal, and every artifact name.

Composition is **extend, do not fork**: the shipped algorithm, labels, finding
codes, and readiness literals are reused unchanged; the recursive rule is stated
once in the authority and every other surface points at it.

### Declared conflicts

`conflicts-with: "docs/workflow.md, .opencode/agent/status.md"` — the same set as
this child's parent `Children` row cell
(`work/0011-recursive-bootstrap/roadmap.md:106`), so the declaration is one-sided
and does not report `DRIFT-FACT`. `.opencode/command/status.md` and
`.opencode/skill/workflow-lifecycle/SKILL.md` are **not** separately declared:
they are mechanical coherence restatements of the two declared authorities, and
declaring a set unequal to the parent cell would itself be reported as
declaration drift. The declaration is advisory and adds no readiness edge.

## Alternatives considered

- **Option A (chosen) — generalize in place in the two authority sections plus
  the report-shape section, and generalize the `status` agent, with minimal
  command/skill restatements.** Pros: satisfies "stated once as the single
  authority" (AC10); smallest diff; keeps the readiness marker exactly once in
  `docs/workflow.md` (the `10-readiness` single-source guard); every pinned
  literal is preserved; the sibling owners and the `/status` consumers read a
  stable, extended contract. Cons: a reader of the `status` command/skill alone
  sees a pointer to the authority rather than the full rule (acceptable — that is
  already their documented posture).
- **Option B — author a new `## Recursive readiness and reporting` authority
  section and make the existing sections defer to it.** Rejected: the spec names
  the deliverable surfaces (`### Dependencies and readiness` and `## Derived
  state`); a new section would duplicate the readiness algorithm, breaking the
  `tests/checks/10-readiness.sh` assertion that `satisfied(dep_local_id):` occurs
  exactly once and in the authority, and would create a second surface to drift.
- **Option C — generalize the `status` agent and command only, leaving
  `docs/workflow.md` untouched.** Rejected: readiness and derived state are
  authority-owned and the agent defers by name
  (`tests/checks/10-readiness.sh`); an agent-only change would state a competing
  rule and fail AC10.
- **Option D — sweep every surface that mentions readiness/derived state now
  (`product`, `builder`, `reviewer`, `tester`, `visual`, the `roadmap`
  agent/command, `README.md`, `AGENTS.md`).** Rejected as out of scope: the
  broad agent/command/inventory surface sweep is Roadmap 4's concern (spec
  non-goal), and those files carry literals pinned by
  `tests/checks/40-inventory.sh`, `50-instructions.sh`, and
  `96-signature-sweep.sh`. They are recorded as follow-ups, not tasks here.

## Interfaces and data model

This item changes no artifact format, frontmatter field, reference, command
signature, `phase` value, or dependency edge kind. The "interfaces" are the
document-contract statements below.

### Readiness (authority: `docs/workflow.md` → `### Dependencies and readiness`)

- `Depends on` scope: a **sibling local id in the same `Children` table**, at
  every depth; no ancestor/descendant/cousin/cross-tree edge; a non-sibling value
  is a `DANGLING-DEP` integrity finding, not an accepted edge (AC1).
- Per-level independence: every decomposing node applies the shipped rule to its
  own immediate children; `child_dir` resolves under the node's own canonical
  reference `work/<node-ref>/<dep_local_id>/` (AC2).
- Decomposing target: satisfied by its own `ship.md` (no `reopened:`) or
  `approve` verdict only; descendants are not consulted (AC3).
- Unchanged and reused: `satisfied(dep_local_id):` marker (exactly once, in the
  authority), the recalled-`ship.md` revocation, `approve`-even-if-unshipped,
  `ship.md`-precedence, and `A child in a cycle is never \`ready\`` (AC8).

### Report shape (authority: `docs/workflow.md` → `### Status reporting`)

- An indented recursive tree to arbitrary depth; each node shows its derived
  phase plus `ready` or `blocked: <local ids>` (AC6).
- Each decomposing node row: `<ready>/<total> ready` over its immediate children
  plus a phase distribution tally `<phase> <n>, ...`; blocked children name their
  blocking siblings; readiness is derived live, never stored (AC7).
- Unchanged: the integrity finding list and its non-fatal, read-only, local-only
  contract.

### Derived state (authority: `docs/workflow.md` → `## Derived state`)

- Own-artifacts-first: a node with children derives its phase from its own phase
  artifacts; `roadmap` applies only to a manifest with no own phase artifacts
  (AC4).
- The table row becomes
  `| `roadmap.md` present and no own phase artifacts (check before `spec.md`) | roadmap |`,
  preserving its position.
- Precedence unchanged: earliest `stale:` → `reopened:` → unshipped
  open-challenge blocked overlay → artifact-presence/verdict rows; no new
  `phase` value, no second state model (AC5).
- Unchanged labels: `P (backtracked)`, `P (reopened)`, `challenged (blocked)`,
  `build (rework)`.

### Backward compatibility

A one-segment standalone item and every existing two-level roadmap parent/child
derive and report exactly as before with no migration (AC9): the only changed
row is the `roadmap.md` row, which for a pure container still matches
(`roadmap.md` present, no own artifacts → `roadmap`), and one- and two-level
items carry no deeper tree. The shipped derived labels, readiness literals, and
pinned contract text remain valid.

## Affected areas

- `docs/workflow.md` — `### Dependencies and readiness` (170–208);
  `### Status reporting` (279–292); `## Derived state` (1126–1197). No other
  section is touched.
- `.opencode/agent/status.md` — `<role>`, `<mission>`, `<operating_principles>`,
  `<inputs>`, `<process>` (steps 2–4, 10), `<readiness>`, `<quality_bar>`,
  `<output_format>`, `<rules>`.
- `.opencode/command/status.md` — the two-level "roadmap parent" language and
  the derived-phase/readiness clauses; the `Usage:` string and finding clauses
  are preserved.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — `## Derived states` (56–88)
  only; the `## Which command now?` routing block is untouched.
- **No other file.** No agent, command, or skill is added; no test file is added
  (committed guards are deferred to a successor roadmap per the spec
  non-goal); no inventory count changes.

**Must-not-restate / must-not-touch (single-source guards):**

- `tests/checks/10-readiness.sh`: `satisfied(dep_local_id):` occurs exactly once,
  in `docs/workflow.md`, and never in `status.md`, `command/status.md`,
  `product.md`, or the skill; the authority keeps `even if unshipped`,
  `presence is the sole shipped signal`, and `` `ship.md` presence takes
  precedence ``; no surface carries the contradiction phrase
  `approved-but-unshipped … not satisfied`.
- `tests/checks/20-lifecycle.sh`: the seven derived-state routing literals
  (`\`spec.md\` missing`, `\`spec.md\` present, \`design.md\` missing`, …), the
  six core commands, and the artifact names stay present in
  `docs/workflow.md`/`README.md`/the skill.
- `tests/checks/80-cycle-fixture.sh`: `A child in a cycle is never \`ready\``
  (authority and `status.md`), the lowercase form in `command/status.md`,
  `CYCLIC-DEP`, `integrity findings rather than failing`, `informational and
  never fatal`, and the flattened `members of a cycle are never reported` phrase
  stay present.
- `tests/checks/87-backtrack-guards.sh`: `P (backtracked)`, `P (reopened)`,
  `challenged (blocked)`, `build (rework)`, `stale: design`, `stale: spec`,
  `finding | severity | acceptance-criterion`, and the full-marker phrases stay
  present in `docs/workflow.md`.
- `tests/checks/85-conflict-guards.sh`: the `## Declared-conflict check` section
  and its vocabulary are untouched, and `status.md`/`command/status.md` still
  reference it.
- `tests/checks/96-signature-sweep.sh`, `40-inventory.sh`, `50-instructions.sh`:
  no command signature, inventory count, or always-loaded path changes; no new
  `### <n>. ` phase heading is added to `docs/workflow.md`.

Out of scope (documented follow-ups, not tasks here): `conflicts-with` at every
level and recursive-tree duplicate detection/renumbering (Roadmap 3); roadmap
deprecation/migration (Roadmap 2); the broad agent/command/inventory surface
sweep (Roadmap 4); committed recursive-readiness guards and fixtures (Roadmap 5).

## Risks and mitigations

- **Breaking a single-source guard by restating pinned vocabulary.** —
  Likelihood: medium / Impact: high / Mitigation: compose by reference only;
  enforce the must-not-restate list; verify the targeted areas
  (`10-readiness`, `20-lifecycle`, `80-cycle-fixture`, `85-conflict-guards`,
  `87-backtrack-guards`, `96-signature-sweep`, `40-inventory`) and the full
  suite stay green.
- **Introducing a competing readiness/derived-state rule in `status.md`,
  `command/status.md`, or the skill (AC10).** — Likelihood: medium / Impact:
  medium / Mitigation: the marker stays only in the authority; each other surface
  defers by name and its recap is kept consistent with the authority; no second
  branch sequence or `roadmap`-always rule is added.
- **The qualified `roadmap.md` derived-state row mis-derives a pure container or
  a hybrid node (AC4, AC9).** — Likelihood: medium / Impact: medium / Mitigation:
  state the own-artifacts-first/manifest-fallback rule explicitly next to the
  table and in the closing paragraph; confirm a manifest-with-no-own-artifacts
  node still derives `roadmap` and a `.gitkeep`-only node still derives
  `not started`.
- **Editing a pinned routing literal while touching the derived-state table.** —
  Likelihood: low / Impact: high / Mitigation: change only the `roadmap.md` row's
  condition; leave every artifact-presence row and label untouched; verify
  `20-lifecycle` and `87-backtrack-guards`.
- **Scope creep into the Roadmap 4 surface sweep.** — Likelihood: medium /
  Impact: medium / Mitigation: limit edits to the four authorized surfaces;
  verify `git diff --name-only` names only those four outside `work/`.
- **Accidental inventory or contract change (AC11).** — Likelihood: low /
  Impact: high / Mitigation: no new command/agent/skill, no count-line edit, no
  new phase heading; verify `40-inventory.sh` and `96-signature-sweep.sh` green
  and `bash tests/run.sh` exits 0.

## Test strategy

The deliverable is documentation and prompts, and the spec explicitly defers
committed recursive-readiness fixtures/agreement areas to a successor roadmap, so
**no new test file is added**. Verification is the existing committed suite
(which stays green) plus review/grep of the authored text.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Review + grep: `### Dependencies and readiness` states sibling-only-at-every-level and that a non-sibling target is a `DANGLING-DEP` finding, no new edge kind. |
| AC2 | Review + grep: per-level independence and the `<node-ref>`-rooted `child_dir`; `10-readiness.sh` green (marker exactly once); `status.md`/`command/status.md` defer. |
| AC3 | Review + grep: a decomposing target is satisfied by its own ship/approve signal only; no recursive propagation. |
| AC4 | Review + grep: own-artifacts-first/manifest-fallback rule and the qualified `roadmap.md` table row; `status.md` and the skill restate it; `20-lifecycle.sh`/`87-backtrack-guards.sh` green. |
| AC5 | Review + grep: precedence sentence (stale/reopened → challenged overlay → rows), no new `phase` value; `87-backtrack-guards.sh` labels green. |
| AC6 | Review + grep: `### Status reporting` states an arbitrary-depth indented tree with phase + ready/blocked at every level; `status.md`/`command/status.md`/`80-cycle-fixture.sh` green. |
| AC7 | Review + grep: `<ready>/<total> ready` + phase distribution over immediate children, blocked children name blocking siblings, readiness never stored. |
| AC8 | Review + grep: the shipped algorithm, labels, codes, and vocabulary are reused; `10-readiness.sh`/`85-conflict-guards.sh` green (single-source preserved). |
| AC9 | Review + grep: backward-compatibility statement; a pure container still derives `roadmap`, a `.gitkeep`-only node still `not started`; `20-lifecycle.sh`/`80-cycle-fixture.sh` green. |
| AC10 | Review + grep: rules stated once in `docs/workflow.md`, `status.md` defers; only `command/status.md` and the skill are also updated; `git diff --name-only` (outside `work/`) lists exactly the four surfaces. |
| AC11 | `bash tests/run.sh` exits 0; `40-inventory.sh` and `96-signature-sweep.sh` confirm no inventory/command change; the readiness marker and derived-state routing literals are unchanged. |
