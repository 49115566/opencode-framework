---
feature: 0011-recursive-bootstrap/0003-recursive-writer
phase: review
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Review — Recursive decomposition writer

## Verdict

**approve** — All 13 acceptance criteria are met by the five changed surfaces;
the writer contract is single-sourced in `docs/workflow.md` and only referenced
elsewhere; and every pinned single-source guard I could read is untouched. One
non-blocking question about the path-selector wording is recorded below.

## Base and diff

Commands used:

- `git merge-base HEAD origin/main` → `2f92a2174492aab99ebd8ec2e8066de67fd98512`
- `git rev-parse HEAD origin/main` → both `2f92a21` (branch up to date)
- `git status`, `git diff --stat`, `git diff -- <path>` per changed file
- `git show --stat d39f4e4` (the merged plan for this item)

`merge-base` equals `HEAD` and `origin/main`, so `git diff <base>...HEAD` is
empty. The item's build is **uncommitted** (the `/build` phase does not commit),
so the review target is the working tree: `git diff` plus the untracked
`verify.md`. The diff is exactly the five production files the design scoped —
`docs/workflow.md`, `.opencode/agent/architect.md`, `.opencode/command/plan.md`,
`.opencode/agent/roadmap.md`, `.opencode/command/roadmap.md` — plus the eight
`tasks.md` check-box flips (`- [ ]` → `- [x]`, T1–T8). No test file, no
`AGENTS.md`/`template/AGENTS.md`, no `README.md`, and no
`docs/artifact-conventions.md` change appears in `git status`, matching the
design's "must-not-touch" list and AC10/AC12.

The test runner is blocked by my read-only bash policy, so I could not re-execute
`bash tests/run.sh`. I instead read every guard the design and AC10 name and
confirmed the diff touches none of their pinned literals (see "Verification I
performed").

## Acceptance criteria

| # | Criterion | Result | Evidence |
| - | --------- | ------ | -------- |
| AC1 | Planning step authors the node manifest at any depth | **met** | `docs/workflow.md:66-97` (rewritten `### Where decomposition is authored and recorded`) states `/plan` (`architect`) is the recursive writer "at **any** depth" and the manifest is `work/<item-ref>/roadmap.md` with `feature:` = full canonical reference and `phase: roadmap`; `.opencode/agent/architect.md:30-46,123-130,174-189`. The stale deferral sentence is gone (`grep "concrete writer's command/agent wiring" docs/ .opencode/` → no match). |
| AC2 | Child `.gitkeep` reservation, per-immediate-parent `MMMM`, appended canonical reference | **met** | `docs/workflow.md:75-81` reserves `work/<item-ref>/<MMMM-slug>/` with `.gitkeep` and defers the per-immediate-parent allocation to `docs/artifact-conventions.md` → "Sequence allocation"; the child reference is the node path with the segment appended. `.opencode/agent/architect.md:126-130,151-153`. |
| AC3 | Six-column `Children`, acyclic `Depends on`, resolving `Canonical reference`, well-formed `conflicts-with` | **met** | `docs/workflow.md:468-478` (Exit) and `.opencode/agent/architect.md:135-140,180-184` require the manifest quality bar **by reference**; no competing grammar added. |
| AC4 | No child phase artifact written | **met** | `docs/workflow.md:83-84`; `.opencode/agent/architect.md:130,203-208`; `.opencode/agent/roadmap.md:37-38,45,119-120`. |
| AC5 | Always manifest; optional hybrid; single feature → `design.md`/`tasks.md`, no manifest | **met** | `docs/workflow.md:86-90,441-482`; `.opencode/agent/architect.md:34-40,141-143`. |
| AC6 | Revision at any depth: four ops, final-state validation, `stale: roadmap`, shipped refusal, no-op | **met** | `docs/workflow.md:329-400` generalizes "the parent" to a decomposing node at any depth and preserves the four operations, validation predicate, `stale: roadmap` marking, shipped-child refusal, and no-op rule; `.opencode/agent/architect.md:131-134`; `.opencode/agent/roadmap.md:123-145`. |
| AC7 | Autonomous; no pre-write approval gate | **met** | `docs/workflow.md:84-86,339-341`; `.opencode/agent/architect.md:60-63`; `.opencode/agent/roadmap.md:70-71,135-140`; `.opencode/command/roadmap.md:52-55`. |
| AC8 | Handoff publishes then routes to ready children; node plan state publishable | **met** | `docs/workflow.md:92-97,483-485,580-611` (plan definition + `spec.md`+`design.md` **or** `roadmap.md` precondition); `.opencode/agent/architect.md:239-247`; `.opencode/agent/roadmap.md:198,204`. |
| AC9 | `/roadmap` thin deprecated alias; create top-level; revise any depth; not retired; usage preserved | **met** | `.opencode/command/roadmap.md:2` keeps `Usage: /roadmap <initiative> | /roadmap revise <item-ref>`; body states deprecation and create-top-level/revise-any-depth; `.opencode/agent/roadmap.md:20-52,192-206`; `docs/workflow.md:70-73,188-192,1306-1311`. Both files present (not retired). |
| AC10 | Configured suite green; no new command/agent/skill; no inventory count change; core contracts unchanged | **met** | Executed in `verify.md` (`TOTAL: 489 passed, 0 failed`); I re-verified the guards' pinned literals are untouched (below). `git status` shows no new `.opencode/` file and no `README.md` change. |
| AC11 | Contract stated once in the authority; surfaces defer; sole-writer reconciled | **met** | `docs/workflow.md:66-97,329-342`; the sole-writer sentence now names the planning step (`docs/workflow.md:336`) and no longer says "roadmap agent is the sole writer"; surfaces reference the authority (`.opencode/agent/architect.md:42-45`, `.opencode/agent/roadmap.md:30-33,178-179`, `.opencode/command/roadmap.md:8-11`). |
| AC12 | One-segment items and existing two-level roadmaps valid; invocations keep working; no `0001`/`0002` re-open | **met** | No signature/reference edit; `git diff --name-only` is the five files; no diff under `0001`/`0002`. |
| AC13 | Decomposition path reachable without node `spec.md` and writes none; single feature still requires `spec.md` | **met** | `docs/workflow.md:444-450,592-596`; `.opencode/agent/architect.md:76-78`; `.opencode/command/plan.md:31-36,62-66`. (A wording nuance is recorded as Q1.) |

### Edge cases

Pure container, hybrid node, single-feature-not-initiative, `.gitkeep`-only
child, deep chain, repeated local-id text, existing two-level roadmap, shipped
node, no-op revision, intended cycle, dangling-withdrawal, malformed
`conflicts-with`, malformed reference, and parallel nodes are each addressed in
the rewritten authority (`docs/workflow.md:83-97,329-400,441-482,580-611`) or
composed by reference to the shipped `0001`/`0002` grammar. No edge case is
contradicted by the diff.

### Declared-conflict hygiene (not an AC)

`work/0011-recursive-bootstrap/0003-recursive-writer/design.md:7` declares
`conflicts-with: "docs/workflow.md, .opencode/agent/roadmap.md,
.opencode/command/roadmap.md"`, byte-equal to the parent `Children` row cell at
`work/0011-recursive-bootstrap/roadmap.md:105`, so the read-only check reports no
`DRIFT-FACT`. The two additional affected surfaces (`.opencode/agent/architect.md`,
`.opencode/command/plan.md`) are deliberately not declared, which is correct — a
non-equal own set would itself be drift.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None.

### Nits

- None.

## Questions

- **[Q1] Path-selector wording differs between the planning command and the
  architect agent** — `.opencode/command/plan.md:64-66` says "a missing `spec.md`
  **alone** selects the decomposition author path", while
  `.opencode/agent/architect.md:100-106` gates the author path on "a node **that
  decomposes** and has no own `spec.md`" and then says "**otherwise** the node is
  a genuine single feature: take the single-feature path". For a node with no
  `spec.md` and no `roadmap.md` that the architect does not judge to decompose,
  the agent's `otherwise` branch selects the single-feature path, which the same
  agent and `docs/workflow.md:444-450` require a `spec.md` for, while the command
  would select author. The spec's AC13 assumption ("a genuine single feature …
  always has a `spec.md`") arguably makes this state unreachable, so I am not
  classifying it as a defect. If a reviewer reads the two surfaces as stating
  different selectors, the minimal fix is to align the agent to "no own
  `spec.md` → author" (matching the design's deterministic facilitator at
  `design.md:74-82`) or to state explicitly what a missing-spec, non-decomposing
  node does. Not blocking on this reading.

## Verification I performed

Because I could not execute `bash tests/run.sh`, I read each guard the design
names and confirmed the diff introduces none of the pinned literals:

- `tests/checks/10-readiness.sh` — `satisfied(dep_local_id):` still appears once,
  only in `docs/workflow.md`; the diff adds no occurrence and touches none of the
  `even if unshipped` / `presence is the sole shipped signal` / `ship.md presence
  takes precedence` phrases.
- `tests/checks/20-lifecycle.sh` — the six core commands, command→agent pairs, and
  derived-state route literals are untouched; the `### 2. Design — \`/plan
  <item-ref>\`` heading is unchanged.
- `tests/checks/25-review-severity-bar.sh` — none of the negative-control tokens
  (`declined`, `waived`, `not merge-blocking`, `Blocker or Major`, `the author
  may decline`) appear in `docs/workflow.md`.
- `tests/checks/40-inventory.sh` — reads only `README.md`; unchanged.
- `tests/checks/80-cycle-fixture.sh` — six-column `Children` header and
  `CYCLIC-DEP` are untouched.
- `tests/checks/85-conflict-guards.sh` — reads only the `## Declared-conflict
  check` section of `docs/workflow.md` plus fixtures; that section is untouched,
  and no `(e)`/`DECLARED-`/`PLAN-`/`CONFLICT-` token is introduced.
- `tests/checks/87-backtrack-guards.sh` — every pinned `docs/workflow.md`
  literal (`\`P\` (backtracked)`, `\`P\` (reopened)`, `challenged (blocked)`,
  `build (rework)`, `stale: design`, `stale: spec`, `finding | severity |
  acceptance-criterion`, …) is untouched, as is the reverse-edge table.
- `tests/checks/96-signature-sweep.sh` — `/plan <item-ref>` and `/roadmap
  <initiative> | /roadmap revise <item-ref>` are still present verbatim in the
  command files (`Usage:` strings preserved); the agent descriptions changed but
  that check pins only the `ask` agent description.
- `tests/checks/30-permissions.sh` — neither changed agent's `permission:` block
  changed; `README.md` is unchanged.
- `tests/checks/50-instructions.sh`, `90-packaging.sh`, `95-split-guard.sh`,
  `70-pin.sh`, `60-default-agent.sh` — read surfaces untouched by the diff.

The only executable check I could not independently reproduce is the merged
suite exit; the content-level guard analysis above is consistent with
`verify.md`'s reported `489 passed, 0 failed`.

## Not reviewed

- The untracked, unrelated working-tree entries `work/0010-recursive-plan-cycle/`,
  `work/0011-recursive-bootstrap/roadmap.md`, and
  `work/0011-recursive-bootstrap/0004-recursive-readiness/.gitkeep`. They are not
  part of this item's build (the build diff is the five production files), and
  the parent `roadmap.md` is environment state the item's spec/design reference
  but do not own.
- The optional `/visual` pass: the item has no user-facing UI, so it is not
  applicable.
- Surfaces explicitly deferred to successor roadmaps (`README.md`, the
  `workflow-lifecycle` skill, roadmap deprecation/migration, `conflicts-with` at
  every level, committed guards); they may still describe the pre-recursive
  writer and are out of scope per the spec's non-goals.
