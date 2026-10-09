---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
notes: "Resolves the spec's two open items. (1) Shipped child in a re-scope: user confirmed the conservative reading (refuse and surface; never rewrite a shipped child's artifacts; the post-ship path is 0005). The design records this as the revision's shipped-exclusion refusal. (2) Exact invocation syntax and record wording (architect-owned): the route is `/roadmap revise <item-ref>`, the canonical /roadmap signature becomes `/roadmap <initiative> | /roadmap revise <item-ref>` on every signature surface, the child's backtrack entry uses target phase `roadmap`, and a withdrawal is recorded under the parent's `## Open issues`. The design's conflicts-with refines the parent Children row's cell (`docs/workflow.md`, `.opencode/agent/roadmap.md`, `.opencode/command/roadmap.md`) with the additional surfaces this plan edits and adds/removes no Depends on edge; per docs/workflow.md the read-only check reports the two-sided disagreement as DRIFT-FACT by design, and rewriting the parent cell is the roadmap owner's write, not this design's."
conflicts-with: "docs/workflow.md, docs/artifact-conventions.md, AGENTS.md, template/AGENTS.md, README.md, .opencode/agent/roadmap.md, .opencode/command/roadmap.md, .opencode/agent/product.md, .opencode/agent/architect.md, .opencode/agent/status.md, .opencode/command/status.md, .opencode/skill/workflow-lifecycle/SKILL.md, tests/checks/96-signature-sweep.sh"
---

# Design — Parent-roadmap revision from child phases

## Summary

Make a parent roadmap revisable in place by adding a **revision mode to the
existing `/roadmap` command** — `/roadmap revise <item-ref>` — implemented in the
roadmap agent and backed by one new `### Revising a roadmap` authority subsection
in `docs/workflow.md` → "Roadmaps". The mode applies four operations
(re-scope, add, withdraw, re-sequence) to the existing parent, allocates the next
local `MMMM` from the parent's committed history, creates directory skeletons for
new children, validates and topologically recomputes `## Sequencing`, records
withdrawals under `## Open issues`, marks every affected unshipped child's
artifacts `stale: roadmap` per the shipped `0001` backtrack model, and records the
triggering child's finding and resolution in its committed `backtracks.md`. No new
command, agent, skill, phase value, state file, or runtime dependency is added;
the parent's `Children` six-column layout, the readiness algorithm, and the
finding vocabulary are untouched.

## Approach

### 1. Invocation and ownership

- The revision is a **mode of the existing roadmap command**, not a new command:
  `/roadmap <initiative>` creates (unchanged); `/roadmap revise <item-ref>` revises
  an **existing** parent. `<item-ref>` is a canonical reference whose
  `work/<ref>/roadmap.md` exists; a reference that is not a parent is refused
  (the mode revises a parent, it does not create one).
- The **roadmap agent is the sole writer of the parent `roadmap.md`**, consistent
  with the `0001` ownership rule. A child phase that discovers the parent is wrong
  records a finding in its `backtracks.md` and recommends the revise route; it
  never edits the parent. The revision writes autonomously — no pre-write approval
  gate, exactly as the roadmap command does today (AC12).

### 2. The revision authority in `docs/workflow.md`

Add `### Revising a roadmap` as the final subsection of `## Roadmaps` (after
`### Starting a blocked child`). It is the single authority for the route and
states, once: the invocation/ownership rule; the four operations; the local-number
allocation rule; the withdrawal record and its report-only recognition; the
post-revision validation invariants; the sequencing recompute; the
non-destructive `stale: roadmap` invalidation and shipped exclusion; and the
provenance rule. It **references** `## Phase reversal (backtracking)` and
`docs/artifact-conventions.md` → "`backtracks.md`" rather than restating a second
reverse-transition, state, or finding vocabulary (AC15). One clause in
`### Status reporting` adds the deliberate-withdrawal recognition (AC8). The
one-line forward pointer in `## Phase reversal (backtracking)` (the edge-table row
"owned by `0004-roadmap-revision`") is updated to name the new subsection; the
model text itself is unchanged.

### 3. The four operations

Applied to the loaded parent in one pass; the graph is validated **after all four**
(AC7 edge case):

1. **Re-scope** — replace an existing row's `Title` and/or `Scope` in place; the
   `Local id`, directory, and `Canonical reference` are preserved. The child is
   invalidated per step 5 (AC2).
2. **Add** — append a new row whose `Local id` is the **next local number**: the
   greatest 4-digit `MMMM` prefix ever committed under that parent plus one, never
   a spent number (`docs/artifact-conventions.md` → "Sequence allocation", applied
   within the parent). Create `work/<parent>/<MMMM-slug>/.gitkeep` and set the
   row's `Canonical reference` to resolve to it (AC3).
3. **Withdraw** — remove the row from `Children` and from `## Sequencing`; **keep**
   the child directory and the spent local number (never reused); record the
   withdrawal and its rationale under `## Open issues` (AC4), mirroring the
   `0003`/`0009` precedent. Withdrawal does not mark the child stale — it leaves
   the active set.
4. **Re-sequence** — edit `Depends on` cells as required and rewrite `## Sequencing`
   as a topological order of the stored graph, so every child follows all of its
   dependencies (AC6). A dependent that must be re-pointed off a withdrawn child has
   its own row changed and is therefore invalidated per step 5.

### 4. Validation, sequencing, and graph integrity

After all operations, the revision runs one validation predicate over the final
state and **stores no fault** (AC7):

- every `Depends on` token names another row's `Local id` in the same table;
- no row depends on itself;
- the stored graph is acyclic;
- every row's `Canonical reference` resolves to an existing child directory;
- every active child directory (all child directories except recorded withdrawals)
  appears as a row;
- `## Sequencing` lists every active child after all of its dependencies;
- every `conflicts-with` cell is still `—` or a well-formed target list, and the
  six-column header keeps `Depends on` at pipe-field 5 and `conflicts-with` at
  pipe-field 6 (AC9).

If the intended dependencies would create a cycle, the revision stores no cyclic
edge, leaves the stored graph acyclic, and records the cycle under
`## Open issues` (AC7). If an operation would leave a dependency dangling (for
example withdrawing a depended-on child), the revision does not silently choose a
resolution: it either also re-points/withdraws the dependents or refuses and
reports the ambiguous intent (spec Edge cases).

### 5. Non-destructive invalidation and shipped exclusion

An existing unshipped child is **affected** when the revision changes any cell of
its `Children` row (`Title`, `Scope`, `Depends on`, `conflicts-with`) or
explicitly re-sequences it. For each affected existing unshipped child, the
revision marks each present phase artifact (`spec.md`, `design.md`, `tasks.md`,
`verify.md`, `review.md`) with `stale: roadmap`, per `## Phase reversal
(backtracking)`. Nothing is deleted or rewritten; the pre-revision content stays
recoverable from committed git history; `stale: roadmap` maps to `spec` when the
child's phase is derived, so the child must re-run forward (AC5). A child holding
only `.gitkeep` marks nothing and simply derives `not started`. An unaffected
child is untouched.

A **shipped** child (its `ship.md` present) is excluded from a backtrack by the
`0001` model. A revision that would re-scope or re-sequence a shipped child
**refuses and surfaces** the conflict for the user rather than rewriting the
shipped child's artifacts; the post-ship path is `0005-post-ship-pr-denial`.
(User-confirmed conservative behavior; no shipped-signal or readiness change.)

### 6. Provenance

- **Triggering child.** Its detecting phase appends a **finding entry** to
  `work/<child-ref>/backtracks.md`: detecting phase `/spec` or `/plan`; target
  phase `roadmap` (the `0001`/`stale` token); affected
  `work/<parent-ref>/roadmap.md`; observable evidence; `status: open`. When the
  revision completes, the roadmap agent appends the matching **resolution entry**
  naming what changed. `backtracks.md` is item-level backtrack state, not a phase
  artifact, so this does not violate the ownership invariant; the roadmap agent
  may append only this entry and no child phase artifact.
- **Parent roadmap.** The revision updates `updated` and appends a **revision
  note** under `## Open issues` naming the date, the triggering child, the
  operations applied, and the invalidated children. The pre-revision roadmap
  remains in git history (AC10).

### 7. Prompt, command, and template wiring

- `.opencode/agent/roadmap.md` — add the revise-mode branch to mission, inputs,
  process, quality bar, rules, and handoff. The revise branch loads the parent,
  reads the triggering child's finding when present, applies the operations,
  validates, recomputes sequencing, marks stale, creates new child skeletons,
  appends the resolution, refuses a non-parent, refuses a shipped-child re-scope,
  treats an empty revision as a no-op, and writes no child phase artifact.
- `.opencode/command/roadmap.md` — extended usage string and an argument-grammar
  block (`/roadmap <initiative>` / `/roadmap revise <item-ref>`), describing the
  autonomous revise mode and the non-parent refusal.
- `.opencode/agent/product.md` and `.opencode/agent/architect.md` — when recon
  finds the parent roadmap wrong, name the sanctioned `/roadmap revise` route,
  record the finding in the item's `backtracks.md`, and do not edit the parent
  roadmap (AC11).
- `docs/artifact-conventions.md` → the `roadmap.md` template — document the
  withdrawal record and the revision note under `## Open issues` (spent number
  preserved, `updated` changes), so the mechanism is discoverable where the
  template lives.
- `.opencode/agent/status.md` and `.opencode/command/status.md` — a focused clause:
  an `UNLISTED-CHILD` observation for a child directory named as withdrawn under
  the parent's `## Open issues` is a **deliberate withdrawal**, reported
  report-only and never auto-repaired, not a possible rename (AC8). This is the
  withdrawal-recognition clause only; the broader `/status` vocabulary remains
  `0006`'s scope.

### 8. Signature surfaces and the sweep

Because AC13 requires one consistent signature for the revise form on every
surface that states command signatures, the canonical `/roadmap` signature becomes
`/roadmap <initiative> | /roadmap revise <item-ref>`, updated together on:
`tests/checks/96-signature-sweep.sh` (registry), `AGENTS.md`,
`template/AGENTS.md`, `README.md` (escaped `\|` in the table), the
`workflow-lifecycle` skill routing block, the `docs/workflow.md` routing bullet
(consistency; not swept), and the command's own usage string. No new command is
added, so the README Layout counts and `40-inventory.sh` are unchanged (AC13,
AC14).

## Alternatives considered

- **Chosen — revision mode of `/roadmap` + roadmap agent, authority in
  `docs/workflow.md`.** It reuses the existing command/agent/permission surface,
  keeps "only the owning phase writes its artifact" intact, and adds no new
  command or inventory row. It matches the spec's resolved invocation surface.
- **Rejected — a new `/revise` (or `/roadmap-revise`) command.** It would add a
  command, change the README Layout counts and `40-inventory.sh`, and contradict
  AC13's "no new command". The spec's user decision fixes the invocation as a mode
  of the existing command.
- **Rejected — let the detecting child phase edit the parent `roadmap.md`
  directly.** It violates the `0001` ownership invariant and the "only the roadmap
  owner writes the parent" rule (AC11), and would let any child phase rewrite a
  shared plan without the roadmap agent's decomposition and validation.
- **Rejected (signature scope) — keep the canonical `/roadmap <initiative>` and
  document `| /roadmap revise <item-ref>` only on the command usage line, mirroring
  the shipped `/ship fix` special case.** It is less surface churn, but AC13 and
  the spec's command-signature constraint require the revision form to be one
  consistent signature across every surface that states a signature; a single
  canonical registry string is the more directly testable contract. The `/ship
  fix` precedent is noted, but that mode is a fix-landing path, not the canonical
  signature, and AC13 is explicit here.

## Interfaces and data model

### Invocation and canonical signature

```
/roadmap <initiative>                 # create (unchanged)
/roadmap revise <item-ref>            # revise an existing parent in place
canonical signature:
  /roadmap <initiative> | /roadmap revise <item-ref>
```

`<item-ref>` must resolve to `work/<ref>/roadmap.md`; otherwise the revision is
refused.

### Local-number allocation (AC3)

```
next_local_id(parent) =
  (max 4-digit MMMM prefix ever committed under work/<parent>/) + 1
```

Applied per `docs/artifact-conventions.md` → "Sequence allocation"; a spent number
is never reused, and the new child directory is created as
`work/<parent>/<MMMM-slug>/.gitkeep`.

### Withdrawal record (AC4, AC8)

Under the parent `roadmap.md` `## Open issues`:

```markdown
- **Withdrawn child — `<MMMM-slug>`.** Withdrawn by user decision on <YYYY-MM-DD>
  and removed from the Children table and Sequencing above. Its directory
  `work/<parent-NNNN-slug>/<MMMM-slug>/` and spent local number are preserved; the
  number is never reused. Rationale: <why>. Former scope: <what it covered>.
```

The named directory is the recognition signal for the status surfaces: an
`UNLISTED-CHILD` for a child named here is a deliberate withdrawal, reported
report-only and never auto-repaired.

### Revision note (AC10)

Under the parent `roadmap.md` `## Open issues`:

```markdown
- **Revised <YYYY-MM-DD>.** Triggered by `work/<parent>/<child-ref>/` (finding in
  its `backtracks.md`). Operations: <re-scope/add/withdraw/re-sequence>. Invalidated:
  <affected child refs>. See git history for the pre-revision roadmap.
```

The parent's frontmatter `updated` is set to the revision date.

### `backtracks.md` entries (AC10)

Per the shipped `0001`/`docs/artifact-conventions.md` shapes, with target phase
`roadmap`:

```markdown
## Finding <n> — YYYY-MM-DD

- detecting phase: `/spec`
- target phase: `roadmap`
- affected: `work/<parent-ref>/roadmap.md`
- evidence: <observable observation>
- status: open

## Resolution <n> — YYYY-MM-DD

- resolves: Finding <n>
- revision: <parent roadmap operations applied and children invalidated>
```

### Stale marking (AC5)

For each affected existing unshipped child, each present `spec.md`, `design.md`,
`tasks.md`, `verify.md`, `review.md` gets `stale: roadmap` in its frontmatter.
`stale: roadmap` derives the child's phase as `spec` (backtracked) per
`docs/workflow.md` → "Derived state".

### Validation predicate (AC7, AC9)

```
valid(parent):
  for each row r:
    r.local_id   in table
    r.local_id   != its own dependencies          # no self-dependency
    each dep d in r.depends_on:
      d is another row's local_id                 # no dangling
      d != r.local_id
    realpath(r.canonical_reference) exists as work/<...>/
  stored graph is acyclic
  active_dirs(parent) == table rows               # no unlisted active child
  sequencing covers every active child, after all deps
  header is the six columns; cells are — or well-formed
```

## Affected areas

- `docs/workflow.md` — new `### Revising a roadmap` under `## Roadmaps`; a
  deliberate-withdrawal clause in `### Status reporting`; a pointer update in
  `## Phase reversal (backtracking)`; the routing bullet at `:708`.
- `docs/artifact-conventions.md` — `roadmap.md` template: withdrawal record and
  revision note guidance.
- `.opencode/agent/roadmap.md` — revise mode throughout.
- `.opencode/command/roadmap.md` — signature and revise-mode body.
- `.opencode/agent/product.md`, `.opencode/agent/architect.md` — name the route;
  record the finding; never edit the parent.
- `.opencode/agent/status.md`, `.opencode/command/status.md` — deliberate-withdrawal
  recognition (AC8 only).
- Signature surfaces: `AGENTS.md`, `template/AGENTS.md`, `README.md`,
  `.opencode/skill/workflow-lifecycle/SKILL.md`.
- `tests/checks/96-signature-sweep.sh` — canonical `/roadmap` registry literal.

**Not touched:** `tests/checks/80-cycle-fixture.sh`, `tests/checks/85-conflict-guards.sh`,
`tests/checks/10-readiness.sh`, `tests/checks/20-lifecycle.sh`,
`tests/checks/40-inventory.sh`, `tests/fixtures/**`, `README.md` Layout counts,
`opencode.json`, and the six `phase` values. Committed backtracking guards are
`0007`'s scope.

## Risks and mitigations

- **Signature-sweep coupling** — `tests/checks/96-signature-sweep.sh` compares the
  `/roadmap` signature on AGENTS, template AGENTS, README, and the skill. Extending
  the canonical string on some surfaces but not others fails the sweep. *Likelihood
  high (we change it) / impact high (red suite) / mitigation:* change the registry
  and all four parsed surfaces in one task (T7), keep the README table's `\|`
  escaping so `normalize_sig` decodes it, and run `bash tests/run.sh`.
- **Readiness-contract drift** — `10-readiness.sh` asserts the algorithm is stated
  once and that status/product defer by name. A route clause could accidentally
  restate it. *Likelihood medium / impact high / mitigation:* reference
  "Dependencies and readiness" by name only; add no readiness branch.
- **Overlapping status edits with `0006`** — touching `status.md`/`command/status.md`
  risks colliding with `0006-status-and-derived-state`. *Likelihood medium /
  impact medium / mitigation:* keep the AC8 change to the single
  deliberate-withdrawal recognition clause, touch no finding code, and declare the
  two files as conflict targets.
- **`Children` layout regression** — `85-conflict-guards.sh` and
  `80-cycle-fixture.sh` pin the six-column header and the positional
  `Depends on`/`conflicts-with` fields. *Likelihood low / impact high /
  mitigation:* change no header or fixture; a revision reuses the six-column
  layout; T8 confirms both guards green.
- **Inventory drift** — `40-inventory.sh` counts agents, commands, skills. Adding a
  mode must not add a file under `.opencode/`. *Likelihood low / impact high /
  mitigation:* revise the existing command/agent only; T8 confirms the counts.
- **Cross-item write ambiguity** — the roadmap agent appending a resolution to the
  triggering child's `backtracks.md` could read as editing a child artifact.
  *Likelihood medium / impact medium / mitigation:* state explicitly that
  `backtracks.md` is item-level backtrack state, not a phase artifact, and that the
  roadmap agent appends only that entry.
- **Withdrawal misreported as a fault** — a retained withdrawn directory surfaces
  as `UNLISTED-CHILD`. *Likelihood high (by design) / impact medium (looks like a
  fault) / mitigation:* record the withdrawal under `## Open issues` and have the
  status surfaces recognize it as deliberate, report-only, never auto-repaired.
- **Declaration drift self-report** — the design's `conflicts-with` refines the
  parent row's three-surface cell, so the read-only check reports a `DRIFT-FACT`
  for this item. *Likelihood high (by construction) / impact low (advisory,
  prompt-only, blocks nothing) / mitigation:* documented here; updating the parent
  cell is the roadmap owner's write and is out of this phase's scope.
- **No committed guard for the new route** — committed fixtures/mutation coverage
  are `0007`'s scope, so behavior here is verified by the existing suite plus
  surface inspection. *Likelihood high / impact low / mitigation:* the test
  strategy maps every AC to an observable check; the residual is recorded for
  `0007`.

## Test strategy

The deliverable is framework documentation, prompts, and a command signature.
Committed fixture guards and mutation coverage are `0007-backtracking-guards`;
verification is the existing suite plus observable inspection of the named
surfaces, recorded in `verify.md`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Manual: `### Revising a roadmap` states in-place revision, unchanged `feature`/canonical ref/local numbering, no new top-level item; command/agent refuse non-parent. |
| AC2 | Manual: re-scope preserves `Local id`/directory and invalidates the child. |
| AC3 | Manual: add allocates the next `MMMM` from committed history, never reuses, creates the `.gitkeep`, reference resolves. |
| AC4 | Manual + suite: withdrawal drops the row from `Children`/`Sequencing`, retains the directory/number, records under `## Open issues`; `80`/`85` green. |
| AC5 | Manual: affected unshipped children's five artifacts marked `stale: roadmap`; unaffected untouched; history recoverable; shipped child refused. |
| AC6 | Manual: validation recomputes `## Sequencing` topologically. |
| AC7 | Manual: validation predicate present; cycle stored non-cyclically and recorded. |
| AC8 | Manual + suite: withdrawal recognition clause in the authority and status surfaces; `10-readiness.sh`/`80-cycle-fixture.sh` green. |
| AC9 | Suite: `80-cycle-fixture.sh` and `85-conflict-guards.sh` green (six-column layout, cycle/conflict guards). |
| AC10 | Manual: `backtracks.md` finding+resolution shape, `updated` change, revision note, history recoverable. |
| AC11 | Manual: product and architect prompts name `/roadmap revise` and the finding, and forbid editing the parent. |
| AC12 | Manual: command and agent state autonomy with no pre-write gate. |
| AC13 | Suite: `96-signature-sweep.sh` green with the extended canonical on every surface; `40-inventory.sh` green. |
| AC14 | Suite: `bash tests/run.sh` → exit 0, 0 failed; no `phase`/derived-state/readiness change; no inventory count change. |
| AC15 | Manual: the authority references `## Phase reversal (backtracking)`/`backtracks.md` and introduces no second vocabulary. |

## Compatibility and migration

- **Additive.** Existing roadmaps need no migration: an absent `conflicts-with`
  column is still `—` per row, an absent `backtracks.md` means no backtracks, and
  the readiness algorithm is unchanged.
- **Numbering.** New child numbers are allocated from committed history as before;
  no number is reused or renumbered by this item.
- **No new dependency.** Docs, prompts, and one test literal only; no runtime,
  build, or CI change.

## Follow-ups (out of scope; no expansion without user approval)

- `0007-backtracking-guards` owns committed fixture areas and mutation coverage for
  the revision (Children integrity after a revision, stale marking, the
  withdrawal recognition).
- `0006-status-and-derived-state` owns the full `/status` and derived-state
  vocabulary; this item adds only the deliberate-withdrawal recognition clause.
- `0005-post-ship-pr-denial` owns any change to a shipped child's shipped signal.
- If desired later, this item's own route can update its parent `Children` row's
  `conflicts-with` cell to match the refined declaration; editing the parent is the
  roadmap owner's write, not this design's.
