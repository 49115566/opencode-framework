---
feature: 0007-phase-backtracking/0002-reverse-phase-routing
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
notes: "Wires the /build->/plan and /plan->/spec reverse edges plus the plan-publication round trip onto the shipped 0001 model, with no new command, agent, skill, state file, phase value, or readiness change. Resolves the spec's deferred mechanics: (a) the detecting phase applies the stale: markers when it takes the edge, to artifacts strictly downstream of the target that the target does not own, so a finding-only item still derives the target phase; (b) re-entry is a per-phase check for an open finding targeting that phase; (c) the plan-PR-denied route re-runs /plan and republishes via /ship plan, explicitly not a backtrack. The root AGENTS.md and template/AGENTS.md routing reference is kept in agreement. Committed fixtures/mutation coverage remain 0007's scope."
conflicts-with: "docs/workflow.md, .opencode/agent/builder.md, .opencode/agent/architect.md, 0003-findings-challenge-loop"
---

# Design — Reverse phase routing and upstream re-entry

## Summary

Give the two sanctioned intra-item reverse edges an operational entry point
without adding a command: the detecting phase records the finding in the item's
`backtracks.md`, mechanically marks the artifacts strictly downstream of the
target phase `stale:` (the target's own artifacts are revised, not marked), does
not edit the target artifact, and ends with a `Next:` handoff naming the target
phase command. Re-entry is a per-phase check: the target phase's owning agent
reads an open finding targeting its phase, revises its own artifact, appends a
resolution entry, clears the `stale:` markers on artifacts it owns, and resumes
forward; with no such finding it behaves as ordinary progression. The plan
round trip is stated separately as plan-publication revision, never a backtrack.

## Approach

### 1. Invocation surface — no new command (the resolved user fork)

The reverse edges reuse the existing phase commands as the entry point: the
detecting agent records the finding and its handoff routes the user to re-run the
target phase command (`/plan <item-ref>` or `/spec <item-ref>`). No `/revise`,
`/reopen`, or other command/agent/skill is added, so the six core command→agent
pairings, the documented inventories, and the command signatures are unchanged
(AC9). This is the user's resolved invocation-surface decision and the spec's
non-goal.

### 2. Taking a reverse edge

When a detecting phase finds an earlier artifact wrong, it performs five steps,
in order, and then hands off. This procedure is stated once in
`docs/workflow.md` → `## Phase reversal (backtracking)` (a new `### Taking an
edge` subsection) and only referenced elsewhere.

1. **Confirm the edge is sanctioned.** The target is strictly earlier, the item
   is unshipped (`ship.md` absent), and the edge is one this item wires
   (`/build`→`/plan` or `/plan`→`/spec`). A self-target or a `/test`/parent-
   `roadmap`/post-ship edge is not taken here (AC11).
2. **Record the finding.** Append a `Finding <n>` entry to
   `work/<item-ref>/backtracks.md`, creating the record with the 0001 frontmatter
   (`feature`, `record: backtracks`, `created`, `updated`) when absent. The entry
   names the detecting phase, the target phase, the affected artifact(s), the
   observable evidence, and `status: open`; numbering is sequential and
   append-only (AC1, AC2, AC3).
3. **Apply the `stale:` markers mechanically.** Mark every existing artifact that
   is **strictly downstream of the target phase and not owned by the target
   phase** with `stale: <target-phase-label>`. "Downstream" follows the
   artifact-presence order (`spec.md` < `design.md` < `tasks.md` < `verify.md` <
   `review.md`); the target's own artifacts are revised by their owner, not
   marked. This is non-destructive metadata, not an authorship edit, and it is
   the one mechanical cross-owner write the model sanctions (AC4).
4. **Never edit the target artifact.** The detecting phase does not touch the
   file it is sending back; the owner revises it on re-entry (AC3).
5. **Hand off.** End with `Next: /plan <item-ref>` (from `/build`) or
   `Next: /spec <item-ref>` (from `/plan`) (AC1, AC2).

The two wired edges are concrete:

| Edge | Detecting phase | Finding entry (`backtracks.md`) | Existing artifacts marked `stale:` | Handoff |
| ---- | --------------- | ------------------------------- | ---------------------------------- | ------- |
| `/build`→`/plan` | builder | detecting `/build`; target `/plan`; affected `design.md`, `tasks.md` | `verify.md`, `review.md` → `stale: design` (design.md/tasks.md are target-owned, not marked; typically absent at build time) | `Next: /plan <item-ref>` |
| `/plan`→`/spec` | architect | detecting `/plan`; target `/spec`; affected `spec.md` | `design.md`, `tasks.md`, `verify.md`, `review.md` → `stale: spec` (whichever exist) | `Next: /spec <item-ref>` |

The target-phase labels for the marker are the existing vocabulary: target
`/plan` → `stale: design`; target `/spec` → `stale: spec`. The derived phase
precedence and the marker's non-destructive role remain 0001's (AC10).

Reconciliation with 0001: the shipped model says "when the owner revises the
artifact, each artifact downstream of the target phase is marked". AC4 and the
"finding recorded but target never re-entered" edge case require the marking to
exist *before* re-entry, so this item makes the timing and actor concrete —
marking happens **when the edge is taken**, by the detecting phase, and the owner
clears a marker on an artifact it owns when it re-runs. The invalidation
subsection's opening clause is adjusted to say "when the reverse edge is taken"
instead of "when the owner revises"; nothing else in the model changes.

### 3. Re-entry (AC5)

Every phase that owns a wired target reads for an open finding targeting its own
phase before doing forward work. For this item that is `/plan` (architect) and
`/spec` (product).

- **Open finding present.** The owning agent reads the finding, revises the
  affected artifact(s), appends a `## Resolution <n>` entry
  (`resolves: Finding <n>`, `revision: <what changed>`) to `backtracks.md`,
  clears the `stale:` marker on any artifact it owns and has just re-run, and
  resumes the forward lifecycle from its phase as if the later phases had not
  run. The resolver is the target phase's owner; the detector is never the
  resolver of its own finding (AC3, AC5).
- **No open finding.** Ordinary forward progression/revision; the agent records
  no finding and touches `backtracks.md` only if one already exists for another
  phase (AC6).

This rule is stated once in the workflow authority (a new `### Re-entry`
subsection) and applied in the `/plan` and `/spec` agent prompts. The
`/build`→`/plan` case is the architect's re-entry; the `/plan`→`/spec` case is
the product's.

### 4. Ordinary forward re-run (AC6)

The check is conditional on an open finding whose target is the running phase.
Absent one, the phase command behaves exactly as today and fabricates no finding;
this prevents a routine re-run from being mistaken for a backtrack.

### 5. Plan-publication round trip (AC7)

A `plan/<ref>` pull request that is denied, closed, or sent back for changes is
**not** a backtrack and writes nothing to `backtracks.md`. The documented route is
to re-run `/plan <item-ref>` to revise the plan and republish with
`/ship plan <item-ref>`, which adds a commit to the existing `plan/<ref>` branch
and updates its PR (or opens a new PR when the branch was pruned) — never a
force-push. This is the existing plan-publication **revision** flow
(`docs/workflow.md` → "Plan publication"; `.opencode/agent/shipper.md:263-268`,
`.opencode/command/ship.md:112-115`) with its missing inbound route added. It is
stated as a new bullet in `## Plan publication` and referenced from the `/plan`
surfaces; the shipper's existing revision step is not changed.

### 6. Single authority and references (AC8, AC10)

The reverse-edge set, ownership, record, and marker stay 0001's single authority
in `docs/workflow.md`; this item adds only the operational entry point and
re-entry procedure to that same section and references it from every surface a
maintainer reads: the `/build` and `/plan` agent prompts and commands, the phase
`Next:` handoffs, the `AGENTS.md` lifecycle/routing reference and its
adopter-pristine `template/AGENTS.md` copy, and the `workflow-lifecycle` routing
block. No second mechanism, `phase` value, state file, or readiness change is
introduced.

## Alternatives considered

- **Chosen — reuse existing phase commands; detecting agent records and hands
  off.** Pros: keeps the six-command inventory, the command→agent pairings, the
  documented counts, and the signature sweep byte-compatible (AC9); matches the
  user's resolved fork; minimal and additive. Cons: the route is carried by
  prompt prose rather than a hard command, so correctness depends on the agents
  following the authority.
- **Rejected — a new `/revise <item-ref> <target-phase>` (or `/backtrack`)
  command.** Pros: one explicit mechanical entry point; the argument names the
  target. Cons: adding a command changes the README Layout count and `## Commands`
  table, the AGENTS `Supporting commands:` line, the command→agent pairings, the
  96-signature-sweep registry and required sets, and `/doctor`'s inventories —
  directly violating AC9 and the spec non-goal "no new command … including a
  `/revise` or `/reopen` command", and the user resolved against it.
- **Rejected — the target owner applies the `stale:` markers on re-entry.**
  Pros: keeps marker writes entirely with the artifact owners. Cons: fails the
  spec's "finding recorded but the target phase never re-entered" edge case and
  AC4's "the item derives phase P" — with no marker, the item would still derive
  its prior phase until re-entry. Rejected because the invalidation must be
  observable at edge-taking.
- **Rejected — overload `status`/frontmatter or add a `backtracked` phase
  value.** Forbidden by AC10 and 0001; would also break the phase-set and
  signature agreements. The optional `stale:` marker already exists.

## Interfaces and data model

All shapes are 0001's; this item only fixes the operational values.

- **Record — `work/<item-ref>/backtracks.md`** (unchanged shape, 0001 /
  `docs/artifact-conventions.md:451-500`): minimal frontmatter `feature`,
  `record: backtracks`, `created`, `updated`; append-only `Finding <n>` /
  `## Resolution <n>` entries; effective status `resolved` iff a matching
  resolution exists, else `open`.
- **Finding entries written by this item's edges:**
  - `/build`→`/plan`: `- detecting phase: /build`, `- target phase: /plan`,
    `- affected: \`design.md\`, \`tasks.md\``, `- evidence: …`, `- status: open`.
  - `/plan`→`/spec`: `- detecting phase: /plan`, `- target phase: /spec`,
    `- affected: \`spec.md\``, `- evidence: …`, `- status: open`.
- **Marker rule:** `stale: <target-phase-label>` on existing artifacts strictly
  downstream of the target and not owned by the target; the target-owned artifact
  is revised, not marked. Cleared by the owning phase when it re-runs.
- **Re-entry predicate:** `backtracks.md` contains an entry whose target phase is
  the running phase and that has no matching resolution — i.e. its effective
  status is `open`. When false, forward behavior is unchanged.
- **Handoff strings:** the detecting handoff is exactly `Next: /plan <item-ref>`
  or `Next: /spec <item-ref>`; the `.opencode/skill/workflow-lifecycle/SKILL.md`
  routing block states the same routes with canonical signatures.
- **Backward compatibility / migration:** additive documentation only. Items
  without `backtracks.md` are unaffected; a finding-less re-run is ordinary; the
  existing `review.md` `request-changes`→`/build` path, the `Depends on`
  readiness contract, the shipped signal, and the six `phase` values are
  untouched. No artifact migration is required.

## Affected areas

- `docs/workflow.md` —
  - `## Phase reversal (backtracking)` (`:557-631`): add `### Taking an edge`
    and `### Re-entry` and adjust the invalidation subsection's opening clause
    (`:617`) to "when the reverse edge is taken"; the edge table, exceptions,
    ownership, and derived-state precedence stay as shipped.
  - `## Plan publication` (`:312-349`): add the denied/changes-requested plan-PR
    revision bullet.
  - Phase `Next:` handoffs: Requirements (`:220`), Design (`:237-238`), Build
    (`:254-255`) name the reverse-edge routing and the plan republish route.
  - Must not add a `### <digit>. ` heading and must not alter the seven routing
    literals checked by `tests/checks/20-lifecycle.sh:60-78`.
- `AGENTS.md` — extend the Working-agreements `Backtracking` bullet (`:125-128`)
  to name the two wired edges, the record, the `stale:` marking, and re-entry;
  reword the Handoff-protocol "stop and report" line (`:98-99`) to reference the
  sanctioned route. Add no lifecycle-table row and no `Supporting commands:`
  token (96-signature-sweep parses both).
- `template/AGENTS.md` — mirror the same Working-agreements bullet and Handoff-
  protocol wording so the root and adopter-pristine routing reference agree
  (AC12); leave the Project-profile placeholders.
- `.opencode/agent/builder.md` — `operating_principles` (`:38`) and `process`
  and `handoff` (`:117-123`): the `/build`→`/plan` detecting route.
- `.opencode/agent/architect.md` — operating principles, `process`, `handoff`,
  and the `rules` line (`:106`): the `/plan`→`/spec` detecting route, the `/plan`
  re-entry, and the denied plan-PR republish route.
- `.opencode/agent/product.md` — `process` (`:60-82`): the `/spec` re-entry
  (AC5). Scoped strictly to the `/plan`→`/spec` target; no roadmap-revision
  routing (0004).
- `.opencode/command/build.md` — detecting route bullet.
- `.opencode/command/plan.md` — detecting route, re-entry, and denied plan-PR
  republish bullets.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — `## Which command now?`
  (`:30-44`) reverse-edge/re-entry/plan-republish routes (canonical signatures
  only), and the `rules` "stop and report" line (`:62`).
- **Not touched:** `README.md` (no inventory/signature/mermaid edit, not an AC8
  surface), `docs/artifact-conventions.md` (0001 already fixed the record and
  markers), `.opencode/command/ship.md`, `.opencode/agent/shipper.md`,
  `.opencode/agent/tester.md`, `.opencode/agent/reviewer.md`, `tests/**`,
  `opencode.json`, and the parent `roadmap.md` (0004/0005/0007 scope).

## Risks and mitigations

- **Signature-sweep coupling (`tests/checks/96-signature-sweep.sh`)** — the
  sweep parses AGENTS/template table rows and the `Supporting commands:` block,
  workflow `### <digit>. ` headings, the `/visual` routing bullet, README
  commands/mermaid, and the skill routing block. *Likelihood medium / impact
  high / mitigation:* route only through prose bullets and existing scanned
  positions; in the skill block use canonical signatures (`/plan <item-ref>`,
  `/spec <item-ref>`) and put any trailing prose after two spaces so the extractor
  truncates it; add no AGENTS table row or supporting-command token. Run
  `bash tests/run.sh`.
- **Lifecycle literal drift (`tests/checks/20-lifecycle.sh:60-78`)** — seven
  workflow/skill route literals are byte-pinned. *Likelihood medium / impact
  high / mitigation:* leave those literal lines and the Derived-state table
  untouched; augment the phase `Next:` lines and add new skill lines only. Run
  the suite.
- **Inventory drift (`tests/checks/40-inventory.sh`)** — counts of agents,
  commands, and skills must equal disk. *Likelihood low / impact high /
  mitigation:* add no file under `.opencode/`; edit existing files only.
- **Root vs adopter-pristine `AGENTS.md` drift (AC12)** — `template/AGENTS.md`
  currently lacks even 0001's `Backtracking` bullet, so the two already differ.
  *Likelihood medium / impact medium / mitigation:* add the same routing bullet
  and reworded Handoff line to both, leaving only the intended Project-profile
  difference; verify by diffing the two Working-agreements/Handoff sections.
- **Cross-owner `stale:` marker writes (AC3)** — the detecting phase marks
  downstream artifacts (e.g. `verify.md`) it does not own. *Likelihood medium /
  impact medium / mitigation:* the target's own artifact is never touched; the
  marker is mechanical, additive metadata explicitly sanctioned by the model as
  invalidation (not authorship), and the owning phase clears it on re-run. The
  design states this so no builder improvises.
- **Ambiguity of "downstream" and target-owned exclusion** — `tasks.md` is
  written by `/plan` but derives the build state. *Likelihood low / impact medium
  / mitigation:* the concrete per-edge table pins the marked set (target
  `/plan`: `verify.md`/`review.md`; target `/spec`: `design.md`/`tasks.md` plus
  later artifacts); no task requires a judgment call.
- **Over-editing the 0001 authority (AC10)** — the model must stay the single
  authority. *Likelihood medium / impact high / mitigation:* add only the two
  operational subsections and the timing clause; introduce no new edge, marker,
  phase value, state file, or readiness rule; `0006`/`0007` own derived-state
  reporting and guards.
- **Scope creep into sibling children** — `/test`, parent-`roadmap`, and
  post-ship routes are 0003/0004/0005. *Likelihood medium / impact medium /
  mitigation:* wire only the two edges, keep `product.md` to the `/plan`→`/spec`
  target, and leave the shipper/test/reviewer prompts unchanged; AC11 asserted in
  the final task.
- **No committed guard for this item's routing** — deliberately 0007's scope.
  *Likelihood high / impact low / mitigation:* the test strategy maps every AC to
  a suite run or a recorded inspection command.

## Test strategy

The deliverable is documentation/prompts; committed fixtures and mutation
coverage are `0007-backtracking-guards`. Verification is the existing suite plus
recorded inspection of the named surfaces in `verify.md`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Manual: builder prompt/command/`Next:` handoff and `docs/workflow.md` Build Next name `/build`→`/plan`, the finding fields, and `Next: /plan <item-ref>`. |
| AC2 | Manual: architect prompt and `/plan` command and `docs/workflow.md` Design Next name `/plan`→`/spec` and `Next: /spec <item-ref>`; skill route present. |
| AC3 | Manual: the edge procedure states the detector never edits the target artifact; builder/architect rules keep the never-edit invariant. |
| AC4 | Manual: the marker rule + per-edge table present; target-owned artifacts excluded; non-destructive; derived precedence left to 0001. |
| AC5 | Manual: `### Re-entry` in `docs/workflow.md`; architect `/plan` and product `/spec` process steps read the open finding and append a resolution. |
| AC6 | Manual: the re-entry check is explicitly conditional; no fabricated finding on a finding-less re-run. |
| AC7 | Manual: `## Plan publication` denied-PR bullet; `/plan` surfaces name re-run-and-republish, explicitly not a backtrack; shipper revision step unchanged. |
| AC8 | Manual grep of all six named surfaces; suite green. |
| AC9 | Suite + `git diff --stat`: no command/agent/skill file added; six pairings and inventories unchanged (`40-inventory.sh`, `96-signature-sweep.sh`, `20-lifecycle.sh`). |
| AC10 | Manual: no new `phase` value, state file, or readiness rule; model still single authority; `docs/artifact-conventions.md` untouched. |
| AC11 | Manual: no `/test`/parent-`roadmap`/post-ship route added; `product.md` edit is the `/spec` re-entry only. |
| AC12 | Suite: `bash tests/run.sh` → exit 0 with `0 failed`; root vs `template/AGENTS.md` routing sections agree. |

## Follow-ups (out of scope; no expansion without user approval)

- `0003-findings-challenge-loop` owns the `/test` reverse edges and contesting a
  finding; `0004-roadmap-revision` the parent-`roadmap.md` route;
  `0005-post-ship-pr-denial` reopen; `0006-status-and-derived-state` the
  `backtracked`/`reopened` reporting; `0007-backtracking-guards` the committed
  fixture and mutation coverage. The product-prompt `/spec` re-entry added here
  is limited to the `/plan`→`/spec` target and does not touch roadmap routing.
