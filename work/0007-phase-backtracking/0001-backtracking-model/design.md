---
feature: 0007-phase-backtracking/0001-backtracking-model
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
notes: "Adopts the spec's one remaining open question in favor of the record-required reading: AC4 and the 'Unrecorded backtrack' edge case make a recorded finding a precondition of a sanctioned reversal, so no unrecorded/lightweight reversal is defined. The spec's other open question (exact marker/record vocabulary) is resolved here: a per-item append-only `backtracks.md` record plus optional `stale:`/`reopened:` frontmatter markers. Nothing else in the spec is changed."
conflicts-with: "docs/workflow.md, docs/artifact-conventions.md, AGENTS.md"
---

# Design — Phase-backtracking and revision model

## Summary

A **backtrack** is a sanctioned reverse transition on the same unshipped work
item, recorded as committed state in a dedicated per-item `backtracks.md` record
(append-only finding/resolution entries) and made operable by two optional
frontmatter markers: `stale: <phase>` on every downstream artifact invalidated by
the revision, and `reopened: <phase>` on `ship.md` for the post-ship case. The
item's derived phase is the earliest `stale:` target (precedence over the
artifact-presence rows), so a stale artifact never satisfies a prerequisite; the
general later→earlier rule, its sanctioned-edge table, exceptions, and ownership
rule live once in `docs/workflow.md`, the record and markers in
`docs/artifact-conventions.md`, and `AGENTS.md` cross-references them. No new
`phase` value, command, agent, skill, state file, or runtime dependency is added,
so the committed suite and every documented inventory stay unchanged.

## Approach

### 1. The model is one new authority section in `docs/workflow.md`

Insert `## Phase reversal (backtracking)` immediately before `## Derived state`
(currently `docs/workflow.md:557`), so the derived-state table can reference the
model directly above it. The section states, once and as the single authority:

1. **Definition.** A backtrack is a sanctioned reverse transition on the same
   **unshipped** work item, triggered by a detected defect in an earlier phase's
   artifact or output (AC1). It is explicitly distinguished from (a) normal
   forward progression and (b) the plan-publication **revision** flow
   (`docs/workflow.md` → "Plan publication"), which re-issues an item's *own*
   plan forward and never moves a phase backward.
2. **General reverse-edge rule.** On an unshipped item, a later phase may target
   an earlier phase, or, for a nested child, its parent `roadmap.md`. The
   sanctioned-edge table enumerates the canonical edges and what each revises;
   the exceptions restrict the general rule (AC2).
3. **Ownership.** Control returns to the target phase; its owning agent revises
   its own artifact or output; the detecting phase records the finding and never
   edits the target artifact. The "only the owning phase writes its artifact"
   invariant is unchanged (AC3).
4. **Non-destructive invalidation.** Each artifact downstream of the target
   phase (and not owned by the target phase itself) is marked `stale: <phase>`;
   nothing is deleted or rewritten; the pre-revision content stays recoverable
   from committed git history; the item resumes at the target phase and re-runs
   forward (AC5).
5. **Shipped exclusion.** An item whose `ship.md` is present is out of scope;
   its reversal is the post-ship reopen case, a separate path (AC10).

### 2. State model: record plus markers

**Per-item record — `work/<item-ref>/backtracks.md`** (shape documented in
`docs/artifact-conventions.md`; authority for its role is the model section):

- It is **not** a phase artifact: it carries no `phase:` value, is not one of the
  artifact-presence rows, and does not by itself determine the item's derived
  phase (AC4). `/status` reads it for reporting, not for derivation.
- Frontmatter is minimal and distinct from the phase-artifact frontmatter:
  `feature`, `record: backtracks`, `created`, `updated`.
- The body is append-only. A **finding entry** records the detecting phase, the
  target phase, the affected artifact/output, the observable evidence, and
  `status: open`; a later **resolution entry** for that finding records the
  revision that completed it. The effective status of finding `n` is `resolved`
  when a `Resolution n` entry exists, otherwise `open`. Entries are never edited,
  reordered, or removed; a resolution recorded before its finding is malformed
  and is reported (not reordered).
- Absent file = no backtracks, and historical items need no migration.

**Markers — optional frontmatter fields (documented in
`docs/artifact-conventions.md`):**

```yaml
stale: <phase>       # optional on any phase artifact; invalidated by a backtrack
                     # whose target is <phase>. Cleared when its owning phase re-runs.
reopened: <phase>    # optional on ship.md; the phase a recalled item re-enters.
```

- `stale` target tokens are the existing phase vocabulary plus `roadmap`:
  `spec | design | build | test | review | roadmap`. `roadmap` is used only for a
  phase→parent-`roadmap.md` backtrack and maps to `spec` when the item's phase is
  derived. The token set adds no new `phase` value (AC7).
- The two markers are distinct from the existing frontmatter `status`
  (`draft`/`final`/`blocked`) and never overload it.
- `reopened` is a forward-declared **shape**: the model names it and gives its
  derived-state precedence so `0005-post-ship-pr-denial` and
  `0006-status-and-derived-state` can populate and report it; producing the
  marker, revoking the shipped signal, and any readiness change are owned by
  `0005`.

### 3. Derived state: precedence over artifact-presence rows

Extend the `## Derived state` table (`docs/workflow.md:562-574`) with two rows
evaluated **before** the artifact-presence rows, and a precedence note:

| Observed state                                                        | Phase               |
| --------------------------------------------------------------------- | ------------------- |
| earliest `stale:` marker among the item's artifacts names phase `P`   | `P` (backtracked)   |
| `ship.md` present with a `reopened:` marker naming phase `P`          | `P` (reopened)      |

- A stale artifact is **never** read as the item's current phase artifact and
  **never** satisfies a downstream prerequisite; `roadmap` maps to `spec` (AC6).
- The existing `review.md` verdict `request-changes` → `build (rework)` row
  (`docs/workflow.md:572`) is retained verbatim and presented as the
  pre-existing, already-rendered instance of the general model; no second rework
  mechanism is defined, and its routing literal and consumers are unchanged
  (AC8).
- `/status` continues to report what its consumers require; `0006` owns the full
  status vocabulary implementation and adds the `backtracked`/`reopened` labels
  there. `reopened` is the one row that invalidates the `ship.md` presence row;
  because readiness keys on `ship.md` **presence only** (`docs/workflow.md`
  → "Dependencies and readiness"), this model changes neither the shipped signal
  nor the readiness contract — `0005` owns any revocation.

### 4. Reconcile existing contracts and cross-reference

- **`## Failure and rollback`** (`docs/workflow.md:768-774`): reword the "route
  back" clause to reference the model as the sanctioned route, keeping its rules
  intact — report failures, never rewrite another phase's artifact to hide a
  failure, and require confirmation for destructive git recovery (AC9).
- **`AGENTS.md`** (AC11): add one **Working agreements** bullet —
  *"Backtracking. When a later phase finds an earlier phase's artifact wrong,
  record the finding and take the sanctioned reverse transition in
  `docs/workflow.md` → 'Phase reversal (backtracking)'. Never edit another
  phase's artifact."* It is added as a prose bullet, never a lifecycle-table row
  or a `Supporting commands:` line, so `tests/checks/96-signature-sweep.sh` is
  unaffected.
- **No other surface states a conflicting reverse-transition rule** (AC11). The
  `workflow-lifecycle` skill and `README.md` derived-state diagrams are
  deliberately left for `0002` (routing) and `0006` (derived-state/status); they
  currently say "stop and report", which the model subsumes rather than
  contradicts.

## Alternatives considered

- **Chosen — record + per-artifact `stale:` markers.** Derivation is a local
  property of each artifact, which matches AC6 ("derived from stale downstream
  artifacts") and keeps history non-destructive. The record is the audit trail
  and `/status` reporting input; it does not drive derivation, satisfying AC4's
  "does not by itself determine the item's derived phase".
- **Rejected — one item-level state field on a designated anchor artifact (or a
  `state:` file).** A state file is forbidden by the no-state-file contract and
  would fork derived state. A single anchor artifact duplicates item-level state
  in a phase-owned file, so it drifts from the other artifacts and cannot express
  "which downstream artifacts are stale". Frontmatter is per-artifact; only
  per-artifact markers are non-duplicative.
- **Rejected — a new `phase` value (`backtracked`) or overloading `status`.** AC7
  fixes the six `phase` values and keeps the markers distinct from `status`;
  a new phase value would also break `tests/checks/20-lifecycle.sh` (a) (the
  phase-set/command agreement) and fork the vocabulary the spec says to reuse.
- **Rejected — edit the finding entry's `status` to `resolved` in place** instead
  of appending a resolution entry. It reads as a rewrite of a prior entry and
  cannot represent the "resolution before finding" malformed case; append-only
  resolution entries honor AC4's append-only guarantee more literally.

## Interfaces and data model

### `work/<item-ref>/backtracks.md` (new committed record)

```markdown
---
feature: NNNN-slug
record: backtracks
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## Finding 1 — YYYY-MM-DD

- detecting phase: `/test`
- target phase: `/plan`
- affected: `design.md`
- evidence: <observable observation>
- status: open

## Resolution 1 — YYYY-MM-DD

- resolves: Finding 1
- revision: <what the target phase changed>
```

Numbering is sequential from `1`; entries are append-only. Effective status:
`resolved` iff a matching `Resolution n` exists, else `open`.

### Frontmatter additions (`docs/artifact-conventions.md`)

- `stale: <phase>` — optional on `spec.md`, `design.md`, `tasks.md`, `verify.md`,
  `review.md`; presence invalidates the artifact until its owning phase re-runs
  and clears it.
- `reopened: <phase>` — optional on `ship.md`; presence marks a recalled item and
  names the phase it re-enters. Distinct from `status`.

### Reverse-edge table (stated in the model section)

| Detecting phase | Target            | Revises                         |
| --------------- | ----------------- | ------------------------------- |
| `/build`        | `/plan`           | `design.md`, `tasks.md`         |
| `/plan`         | `/spec`           | `spec.md`                       |
| `/test`         | `/build`          | `tasks.md` + code (rework)      |
| `/test`         | `/plan`           | `design.md`, `tasks.md`         |
| `/test`         | `/spec`           | `spec.md`                       |
| `/review`       | `/build`          | `tasks.md` + code (rework)      |
| any child phase | parent `roadmap.md` | `roadmap.md` (owned by `0004`) |

**Exceptions that restrict the general rule:** no self-target (a phase targeting
itself is not a reversal); shipped items excluded (post-ship reopen is separate);
the target must be strictly earlier than the detecting phase; `roadmap` is a
target only for a nested child's parent and its route is owned by `0004`; a
recorded finding precedes the edge (no silent reversal); the detecting phase
never edits the target artifact.

## Affected areas

- `docs/workflow.md` — new `## Phase reversal (backtracking)` section inserted
  before `## Derived state` (`:557`); two rows + precedence note in the derived
  table (`:562-574`); a one-clause edit in `## Failure and rollback` (`:772-773`).
- `docs/artifact-conventions.md` — two optional fields in the Frontmatter block;
  a new `backtracks.md` record template under Templates; a rule that the record
  is not a phase artifact.
- `AGENTS.md` — one Working-agreements bullet (`:117-129`).
- **Not touched:** `.opencode/**`, `README.md`, `tests/**`, `template/**`,
  `opencode.json` — deferred to siblings `0002`, `0006`, `0007`.

## Risks and mitigations

- **Pinned suite literals** — `tests/checks/20-lifecycle.sh` (c) requires the
  exact `review.md` verdict `request-changes` row and the seven routing strings.
  *Likelihood high (we edit that table) / impact high (false regression) /
  mitigation:* keep each existing row and literal verbatim; add rows only; run
  `bash tests/run.sh`.
- **Signature-sweep coupling** — `tests/checks/96-signature-sweep.sh` parses
  AGENTS lifecycle-table rows and the `Supporting commands:` line. *Likelihood
  medium / impact high / mitigation:* add the `AGENTS.md` reference as a Working
  agreements bullet only, with no backticked `/command` signature in a parsed
  position; run the suite.
- **Inventory drift** — `tests/checks/40-inventory.sh` counts agents, commands,
  and skills. *Likelihood low / impact high / mitigation:* introduce no file
  under `.opencode/`; run the suite.
- **Vocabulary fork / accidental state file** — the record and markers could read
  as a second state mechanism. *Likelihood medium / impact medium / mitigation:*
  document the record as non-phase committed state with no `phase`; reuse the
  existing phase tokens; state that no new `phase` value exists.
- **Reopen hook touching the shipped signal** — `reopened` on `ship.md` could
  look like a readiness change. *Likelihood medium / impact high / mitigation:*
  state explicitly that readiness keys on `ship.md` presence only and `0005` owns
  revocation; AC10 scope.
- **Sequential-backtrack ordering ambiguity** — two open backtracks could derive
  different targets. *Likelihood low / impact medium / mitigation:* derive the
  earliest stale target; the record order is audit only; re-marking downstream
  artifacts to the earliest target keeps one unambiguous answer.
- **Truncated test coverage of a documentation deliverable** — committed
  fixture guards are `0007`'s scope, so this item's behavior is verified by the
  existing suite plus manual surface inspection. *Likelihood high / impact low /
  mitigation:* the test strategy below maps every AC to a concrete observable
  check, and the residual is recorded for `0007`.

## Test strategy

The deliverable is documentation; committed fixtures and mutation coverage are
explicitly `0007-backtracking-guards`. Verification is the existing suite plus
observable inspection of the named surfaces, recorded in `verify.md`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Manual: `## Phase reversal (backtracking)` present and defines backtrack + the two distinctions. |
| AC2 | Manual: general rule + edge table names all seven edges + exception list present. |
| AC3 | Manual: ownership paragraph present and the invariant stated unchanged. |
| AC4 | Manual: `backtracks.md` record template present, no `phase`, entry fields complete, append-only stated. |
| AC5 | Manual: non-destructive `stale:` rule present; no-delete/history-recoverable stated. |
| AC6 | Manual: derived-table `stale:` row precedes artifact-presence rows; stale-not-a-prerequisite stated. |
| AC7 | Manual: six `phase` values and `status` untouched; markers defined; derivation + precedence stated. |
| AC8 | Manual + suite: `request-changes` → `build (rework)` row retained verbatim; `20-lifecycle.sh` green. |
| AC9 | Manual: "Failure and rollback" references the model; its three rules intact. |
| AC10 | Manual: shipped exclusion + reopen-as-separate-path stated; readiness unchanged. |
| AC11 | Manual: model stated in `workflow.md`, record/markers in `artifact-conventions.md`, reference in `AGENTS.md`; grep finds no conflicting reverse-transition rule. |
| AC12 | Suite: `bash tests/run.sh` → exit 0 / 0 failed; `40-inventory.sh` and `96-signature-sweep.sh` green; `git diff --stat` shows only the three docs. |

## Follow-ups (out of scope; no expansion without user approval)

- `0002-reverse-phase-routing` owns the invocation surface and agent/command
  wiring; `0003` the challenge loop; `0004` the parent-roadmap route; `0005` the
  reopen marker production and shipped-signal revocation; `0006` the `/status`
  labels and derived-state vocabulary; `0007` the committed guards.
