---
feature: 0007-phase-backtracking/0006-status-and-derived-state
phase: design
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "Reports the 0001/0002/0003/0005 state shapes through `/status` on the four AC9 surfaces, changing no model. Resolves the spec's deferred rendering item and adopts its two user-owned assumptions, which the spec body already states (reporting only; `/status` reports, never adjudicates). Rendering (user-resolved): the Phase column mirrors the `## Derived state` Phase cell verbatim — base phases plus `P (backtracked)`, `P (reopened)`, `build (rework)`, and `challenged (blocked)` — and a Notes line names the revised artifact and the invalidated downstream artifacts (or `none`), the recall for a reopened item, and the open challenge id(s) for a challenged item. AC7's precedence fix is an unshipped precondition on the challenged overlay, not a reordering: the overlay keeps its blocking force for unshipped items while a `ship.md`-present item derives `shipped`/`P (reopened)` and its open challenge is surfaced as out-of-scope. Readiness stays single-source in `docs/workflow.md`; the status agent/command defer by name and add no algorithm statement or stored value. No new phase value, command, agent, skill, state file, finding code, or test fixture is added (committed guards are 0007's scope). conflicts-with lists the true edited surface set; it is a superset of the parent 0006 row's cell, so the read-only declaration check reports an advisory DRIFT-FACT by design — updating the parent cell is the roadmap owner's write."
conflicts-with: "docs/workflow.md, .opencode/agent/status.md, .opencode/command/status.md, .opencode/skill/workflow-lifecycle/SKILL.md"
---

# Design — Status, derived state, and readiness for backtracked items

## Summary

`/status` reports the state shapes that `0001`/`0002`/`0003`/`0005` fixed by
mirroring the `## Derived state` Phase cell verbatim — the base phases plus
`P (backtracked)`, `P (reopened)`, `build (rework)`, and `challenged (blocked)` —
and by adding a Notes line that names, for a backtracked item, the target phase
and affected upstream artifact from the open `backtracks.md` finding and the
downstream artifacts the backtrack invalidated (the `stale:`-marked ones, or
`none`); for a reopened item, the recall; and for an open challenge, the
challenge id(s). The challenged overlay is made **unshipped-only** in the
authority, so a `ship.md`-present item reports `shipped` (or `P (reopened)`) and
its open challenge is surfaced as out-of-scope. Readiness continues to defer to
the single `satisfied(dep_local_id)` authority in `docs/workflow.md`, which is
extended only with a reporting sentence naming the recalled dependency a blocked
dependent is waiting on. The change touches exactly four surfaces — the
authority, the status agent, the `/status` command, and the `workflow-lifecycle`
skill — and adds no new `phase` value, command, agent, skill, state file, finding
code, or committed fixture.

## Approach

### 1. The derived labels come from the authority, verbatim (AC1, AC3, AC6, AC8)

The `/status` Phase column mirrors the `## Derived state` table's Phase cell.
Base phases stay `not started`, `spec`, `design`, `build`, `test`, `review`,
`ship`, `shipped`, `roadmap`; the derived states render as the table names them:

| Derived state | Phase-column label |
| ------------- | ------------------ |
| earliest `stale:` target `P` | `P (backtracked)` |
| `ship.md` `reopened:` phase `P` | `P (reopened)` |
| `review.md` verdict `request-changes` | `build (rework)` |
| open challenge, unshipped | `challenged (blocked)` |

- The existing `request-changes` → `build (rework)` row and its routing literal
  are **unchanged**; the report simply renders the authority's cell. `rework`
  stays a distinct label from `backtracked`, and no second rework state is
  introduced (AC6). The status agent's current bare `rework` vocabulary token is
  replaced by the authority's `build (rework)` cell so the report and the table
  cannot disagree; this is a wording alignment, not a behavior change.
- The exact tokens `backtracked`, `reopened`, and `challenged` (inside the
  parenthesized labels) are the authority's; no new `phase` value is implied
  (AC8). The parenthesized label is a rendering of the derived **condition**, not
  a seventh `phase` value.

### 2. Derivation inputs: read the records and markers (AC1, AC2, AC3, AC5)

The status agent today derives from artifact presence, `tasks.md` boxes, the
`review.md` verdict, and `ship.md`. It gains two inputs and one precedence
application, all read-only:

- Read each item's frontmatter `stale:` field and the `ship.md` `reopened:` field.
- Read `work/<item-ref>/backtracks.md` where present: a finding's effective status
  is `open` iff no matching `## Resolution n` exists; `open` is what makes a
  finding reportable.
- Read `work/<item-ref>/challenges.md` where present: an open challenge is a
  `## Challenge <n>` with no matching `Response n`/`Withdrawal n`.
- Apply the authority's precedence in order: earliest `stale:` target `P` →
  `P (backtracked)`; `reopened: P` → `P (reopened)`; an open challenge **on an
  unshipped item** → `challenged (blocked)`; then the artifact-presence and
  verdict rows. A `ship.md`-present item never takes the challenged row (AC7).
- `stale: roadmap` maps to `spec` when the item's phase is derived, matching the
  authority (edge case).
- **Sequential backtracks:** the report names the earliest outstanding target the
  item currently derives and does not silently drop a later open finding; the
  later finding is listed under the same item.
- **Malformed / out-of-order record:** a resolution recorded before its finding,
  or a response before its challenge, is reported as an integrity observation and
  never reordered. No new finding code is invented for it (AC8, AC12); it is a
  plain Notes observation naming the item and the out-of-order entry, mirroring
  the existing `backtracks.md`/`challenges.md` rule.
- **Backtrack and challenge both open:** the blocked overlay shows
  `challenged (blocked)` and the Notes still carry the backtrack detail, so both
  conditions are reported (edge case).

### 3. The report names the detail (AC2, AC3, AC5, AC7)

The main table keeps its four columns `| Item | Phase | Progress | Next command |`;
only the Phase value changes. A **Notes** line per item carries the detail. The
content is fixed here; the exact wording is the builder's, but each line must
contain:

- **Backtracked:** the target phase being revised, the affected upstream artifact
  from the open finding (`affected:`), and the downstream artifacts the backtrack
  invalidated (the artifacts carrying the `stale:` marker), or explicitly that
  **nothing** was invalidated when no downstream artifact exists. Example content:
  `backtracked; revising design (affected: design.md); invalidated: verify.md, review.md`.
- **Reopened:** that the item is recalled and the phase it re-enters. Example
  content: `reopened; recalled; re-entering spec — ship.md carries reopened marker`.
- **Challenged (unshipped):** the open challenge id(s) and that the item is blocked
  pending adjudication. Example content:
  `challenged (blocked); open challenge: #1 — awaiting review adjudication`.
- **Shipped with an open challenge (AC7):** the Phase stays `shipped`; the Notes
  surface the open challenge as out-of-scope (post-ship reversal is recall's
  domain). Example content:
  `shipped; open challenge #1 out of scope on a shipped item — post-ship reversal is /ship recall`.

### 4. The challenged overlay is unshipped-only (AC7)

The one behavior change to an existing rule is the precedence clarification. In
`docs/workflow.md` → `## Derived state`:

- The challenged row's **Observed state** gains the unshipped precondition:
  an open challenge on an item **that has no `ship.md`**.
- The precedence paragraph states that the overlay applies to **unshipped items
  only**; a `ship.md`-present item derives `shipped` (or `P (reopened)` when
  recalled) and its open challenge is **out-of-scope for a challenge** because
  post-ship reversal is recall's domain (`0005`). Therefore no shipped item is
  ever reported `challenged`.

The overlay keeps its position — after the `stale:`/`reopened:` structural rows
and before the artifact-presence/verdict rows — so a live challenge on an
unshipped item still blocks advancement and shipping (AC5). This is why the fix
is a precondition rather than a reordering: moving the overlay below the
`ship.md`/verdict rows could let a forward row mask a live unshipped challenge.

### 5. Readiness reporting stays single-source (AC4, AC10)

`docs/workflow.md` → `### Dependencies and readiness` remains the only statement
of `satisfied(dep_local_id)`; the recalled-item branch is `0005`'s and is not
re-derived here. The section gains one **reporting** sentence: a recalled
dependency does not satisfy the dependency, and its dependents are reported
`blocked`, **naming the recalled item** as the unsatisfied dependency, until it
re-ships. A non-recalled `ship.md` presence and a `review.md` verdict of
`approve` still report the dependency satisfied exactly as before, and no stored
readiness value is introduced.

The status agent and `/status` command keep their existing `<readiness>` /
readiness bullets (which already state the recalled exclusion and defer to
`Dependencies and readiness` by name). They gain only the reporting phrasing —
the blocked child names the recalled dependency in its `blocked: <local ids>`
cell — and add no second algorithm statement.

### 6. Four surfaces, consistent (AC9)

| Surface | Change |
| ------- | ------ |
| `docs/workflow.md` | `## Derived state`: unshipped precondition, precedence paragraph, and the `/status` reporting statement (the labels + Notes content) replacing the `...remain the scope of 0006...` forward pointer; `### Dependencies and readiness`: the recalled-dependency reporting sentence. |
| `.opencode/agent/status.md` | Mission, inputs, process (records + markers + precedence + malformed handling), readiness reporting, findings (malformed observation), quality bar, output format (labels + Notes), and phase vocabulary. |
| `.opencode/command/status.md` | The same derivation/reporting bullets and the derived labels, deferring to `docs/workflow.md`. |
| `.opencode/skill/workflow-lifecycle/SKILL.md` | A new `## Derived states` section, outside the routing fenced block, mirroring the labels and the unshipped precedence. |

The authority is referenced by name everywhere; the status agent and command do
not restate the derived-state table or the readiness algorithm.

### 7. Scope fences (AC10, AC11, AC12)

No new `phase` value, command, agent, skill, state file, finding code, committed
fixture, or inventory count. No edit to `README.md`, `AGENTS.md`,
`template/AGENTS.md`, `docs/artifact-conventions.md`, `tests/**`, or
`opencode.json`. The seven pinned route literals and the core derived-state
artifact names in `tests/checks/20-lifecycle.sh` stay byte-identical; the
`satisfied(dep_local_id):` marker stays exactly once; the six command→agent
pairings, the command signatures, and the documented inventories are unchanged.

## Alternatives considered

- **Chosen — parenthesized Phase label plus a Notes detail line, derived live.**
  Pros: matches the user-resolved output shape exactly; the Phase cell and the
  authority's Phase cell are the same string, so they cannot drift; no new
  section, column, field, or state file. Cons: the labels are duplicated across
  four prompt/doc surfaces and can drift, which is why `0007-backtracking-guards`
  owns committed guards.
- **Rejected — a separate `## Backtrack and challenge report` section beneath the
  table.** Pros: keeps the Phase column as the plain base phase. Cons: contradicts
  the user-resolved "parenthesized label in the Phase column" shape and creates a
  second render surface that can state a condition the Phase column denies.
- **Rejected — a separate `State` column beside `Phase`.** Pros: separates the
  base phase from the derived condition. Cons: forks the authority's single Phase
  cell into two truths, and the user resolved for the parenthesized Phase label.
- **Rejected — continue the current bare-token style (`rework`, `backtracked`,
  `reopened`, `challenged`).** Pros: smallest vocabulary edit. Cons: contradicts
  AC1's "matching the label in `docs/workflow.md` → 'Derived state'" and the
  user-resolved parenthesized shape.
- **Rejected — fix AC7 by moving the challenged overlay below the `ship.md` and
  verdict rows.** Pros: one line moved. Cons: a live challenge on an unshipped item
  could then be masked by an artifact-presence or `approve` verdict row, so the
  item could be reported ready to advance or ship — contradicting AC5. The
  unshipped precondition keeps the overlay's blocking force where it belongs.
- **Rejected — add a dedicated finding code for malformed records.** Pros: a
  uniform report line. Cons: violates the no-new-finding-code constraint (AC8,
  AC12); the existing records already say "malformed and is reported, not
  reordered", which a plain Notes observation satisfies.

## Interfaces and data model

### Derived-state Phase labels (from the authority, mirrored by the report)

```
base phases     : not started | spec | design | build | test | review | ship | shipped | roadmap
derived labels  : <P> (backtracked) | <P> (reopened) | build (rework) | challenged (blocked)
```

### Status row and Notes (content fixed; wording is the builder's)

```markdown
| Item       | Phase               | Progress   | Next command              |
| ---------- | ------------------- | ---------- | ------------------------- |
| 0003-foo   | design (backtracked)| 0/4 tasks  | /plan 0003-foo            |
| 0005-bar   | spec (reopened)     | 2/3 tasks  | /spec 0005-bar            |
| 0006-baz   | challenged (blocked)| 1/3 tasks  | /status 0006-baz          |
| 0007-qux   | shipped             | 3/3 tasks  | /status 0007-qux          |

Notes
- 0003-foo: backtracked; revising design (affected: design.md); invalidated: verify.md, review.md.
- 0005-bar: reopened; recalled; re-entering spec — ship.md carries reopened marker.
- 0006-baz: challenged (blocked); open challenge: #1 — awaiting review adjudication.
- 0007-qux: shipped; open challenge #1 out of scope on a shipped item — post-ship reversal is /ship recall.
```

A backtracked item with no downstream artifact reports `invalidated: none`.

### Inputs read (all committed, all read-only)

- `stale:` in each phase artifact's frontmatter.
- `reopened:` in `ship.md` frontmatter.
- `backtracks.md` `## Finding <n>` / `## Resolution <n>` entries (effective status).
- `challenges.md` `## Challenge <n>` / `## Response <n>` / `## Withdrawal <n>` entries.

### No new data

No new frontmatter field, record, artifact-presence row, state file, `phase`
value, finding code, command, agent, or skill. The declared-conflict grammar is
untouched.

### Backward compatibility

An item with no `backtracks.md`, no `challenges.md`, and no `stale:`/`reopened:`
marker is reported byte-identically to today; historical items need no migration.

## Affected areas

- `docs/workflow.md` — `## Derived state` (`:1027-1082`): the challenged row's
  unshipped precondition, the precedence-paragraph clarification, the `/status`
  reporting statement (labels + Notes), and replacement of the `...remain the
  scope of 0006-status-and-derived-state` forward pointer at `:1076-1077`;
  `### Dependencies and readiness` (`:104-114`): the recalled-dependency reporting
  sentence. The seven pinned route literals (`:1038-1046`) and the core artifact
  names are preserved byte-identically.
- `.opencode/agent/status.md` — `<mission>`, `<inputs>`, `<process>`,
  `<readiness>`, `<findings>`, `<quality_bar>`, `<output_format>` (row examples,
  Notes examples, phase vocabulary).
- `.opencode/command/status.md` — the derivation/reporting bullets and derived
  labels.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — a new `## Derived states`
  section after the `## Which command now?` fenced block (the block and its
  canonical route signatures stay byte-identical).
- **Not touched (scope fence, AC12):** `README.md`, `AGENTS.md`,
  `template/AGENTS.md`, `docs/artifact-conventions.md`, `tests/**`,
  `opencode.json`, and every sibling child's surfaces.

## Risks and mitigations

- **Pinned lifecycle literals** — `tests/checks/20-lifecycle.sh:60-78` pins seven
  workflow/skill route literals and the derived-state artifact names.
  *Likelihood medium / impact high / mitigation:* add no table row removal and
  change no pinned literal; the `/status` reporting statement is prose; run
  `bash tests/run.sh`.
- **Readiness single-source** — `tests/checks/10-readiness.sh` requires
  `satisfied(dep_local_id):` exactly once (in `docs/workflow.md`), requires the
  `Dependencies and readiness` deferral in the status agent/command, and fails on
  the regex `approved-but-unshipped.*not satisfied`.
  *Likelihood medium / impact high / mitigation:* add only the recalled-dependency
  reporting sentence; keep the status agent/command deferral literal; phrase the
  readiness additions so `approved-but-unshipped` and `not satisfied` never share
  a line; run the suite.
- **Signature-sweep coupling** — `tests/checks/96-signature-sweep.sh` parses the
  skill's routing fenced block and every command usage string.
  *Likelihood low / impact high / mitigation:* add no route line and no command
  signature; put the skill's new content in a separate `## Derived states`
  section; run the suite.
- **Inventory drift** — `tests/checks/40-inventory.sh` counts agents, commands,
  and skills. *Likelihood low / impact high / mitigation:* edit existing files
  only; add no file under `.opencode/`; run the suite.
- **Derived-label drift across four surfaces** — the labels live in the authority,
  the agent, the command, and the skill. *Likelihood medium / impact medium /
  mitigation:* state the labels once in the authority and mirror them verbatim;
  `0007-backtracking-guards` owns the committed fixture that pins them.
- **AC7 precedence regression** — the unshipped precondition could be written so
  broadly that it weakens the challenge block. *Likelihood medium / impact high /
  mitigation:* keep the overlay's position and scope it to "no `ship.md`"; the
  edge case "shipped with an open challenge" is a required verification example.
- **Inventing a finding code for malformed records** — the edge case says
  "reported as a finding". *Likelihood medium / impact medium / mitigation:* state
  explicitly in the design and tasks that no new code is added; report it as a
  plain Notes observation.
- **Prompt-only contract** — correctness depends on agents following the authority
  text; there is no runtime enforcement. *Likelihood high / impact low /
  mitigation:* the reporting and precedence are stated once in the authority;
  residual is the ordinary one for a prompt-driven contract and is recorded for
  `0007`.
- **No committed guard for the report (deliberate)** — fixtures and mutation
  coverage are `0007-backtracking-guards`. *Likelihood high / impact low /
  mitigation:* the test strategy maps every AC to a suite run or a recorded
  surface inspection and records the residual.

## Test strategy

The deliverable is framework documentation and prompts; committed fixtures and
mutation coverage are `0007-backtracking-guards`. Verification is the configured
suite plus observable inspection of the four named surfaces.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Manual: `docs/workflow.md` `## Derived state` names `P (backtracked)`; the status agent derives the earliest `stale:` target and renders it. Suite: `20-lifecycle.sh` route/artifact literals green. |
| AC2 | Manual: the status agent reads the open `backtracks.md` finding and the Notes name target phase, affected upstream artifact, and the `stale:`-marked downstream set (or `none`). |
| AC3 | Manual: the status agent reads the `reopened:` marker, derives `P (reopened)`, and the Notes name the recall and re-entry phase; does not report `shipped`. |
| AC4 | Suite + manual: `10-readiness.sh` green; the authority names the recalled dependency a blocked dependent names; the status agent/command defer by name; no stored readiness value. |
| AC5 | Manual + suite: an unshipped open challenge derives `challenged (blocked)` with the open challenge id(s) named and is not reported ready; `20-lifecycle.sh` green. |
| AC6 | Manual + suite: the `request-changes` row and route literal are unchanged; the report renders `build (rework)`, distinct from `backtracked`; `20-lifecycle.sh` green. |
| AC7 | Manual + suite: the authority states the unshipped precondition and the precedence; a `ship.md`-present item with an open challenge derives `shipped`/`P (reopened)` and surfaces it out-of-scope; `20-lifecycle.sh` green. |
| AC8 | Manual: the status vocabulary includes `backtracked`, `reopened`, and `challenged`; no new `phase` value, finding code, or state file. |
| AC9 | Manual grep of all four surfaces; suite green; none contradicts the derived-state table or the readiness authority. |
| AC10 | Suite: `10-readiness.sh` (single algorithm + deferrals), `20-lifecycle.sh` (seven route literals + artifact names), `40-inventory.sh`, `96-signature-sweep.sh` all green. |
| AC11 | Suite: `bash tests/run.sh` → exit 0, `0 failed`; six command→agent pairings unchanged; no command/agent/skill added or removed; no inventory count or signature changes. |
| AC12 | Manual + `git diff --stat` / `git ls-files --others --exclude-standard`: only the four surfaces; no fixture; no sibling re-open. |

## Compatibility and migration

- **Additive.** An item without `stale:`/`reopened:` markers and without the records
  is byte-identical behavior; no migration is required.
- **Precedence.** The only rule change is the AC7 unshipped precondition, which
  makes the documented shipped-item edge case true and leaves every unshipped
  behavior unchanged.
- **Readiness.** The single authority is referenced, not forked; no stored value.
- **No new dependency.** Docs and prompts only; no runtime, build, or CI change.

## Follow-ups (out of scope; no expansion without user approval)

- `0007-backtracking-guards` owns fixture-based agreement areas and mutation
  coverage for the derived labels, the backtrack/reopened/challenged reporting,
  and the unshipped precedence.
- If desired later, the parent `0006-status-and-derived-state` `Children` row's
  `conflicts-with` cell can be updated to match this item's four-surface
  declaration; the roadmap owner owns that write (the current disagreement is an
  advisory `DRIFT-FACT` by design).
