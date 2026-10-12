---
feature: 0011-recursive-bootstrap/0001-recursive-model
phase: test
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Verification — Recursive lifecycle model

## Summary

The work item is documentation-only. It adds one authoritative section,
`## The recursive lifecycle model`, to `docs/workflow.md` (lines 28–109, placed
after `## Mental model` and before `## The work item directory`), prepends a
deprecation deferral note to `## Roadmaps` (lines 147–149), and adds one
cross-reference sentence to `AGENTS.md` (lines 75–78) and its byte-identical
mirror `template/AGENTS.md` (lines 77–80). All three tracked edits are **pure
additions** — `git diff --numstat` shows `5/0`, `87/0`, `5/0` and no removed
lines — so no shipped contract text is rewritten.

Every acceptance criterion AC1–AC11 is satisfied by direct inspection of the
authored text (the design's stated verification level: "Review + grep") plus the
existing committed suite. The full suite is green. No defect was found, so no
`## Finding` entry is recorded and nothing routes to `/build`, `/plan`, or
`/spec`. No `challenges.md` exists for this item and no open `backtracks.md`
finding targets `/test`, so no challenge adjudication was required and this run
is ordinary forward progression.

**Tests added/updated: none.** The design (`Test strategy`) and the spec
(non-goal: "Committed fixtures, agreement areas, and mutation coverage pinning
the model — a successor roadmap") explicitly defer a committed guard for the
model to a successor roadmap. Adding a `tests/checks/*.sh` agreement area would
violate that scope decision, so this item is verified by the existing suite
(regression safety) plus reproducible grep evidence against the authored text
(behavioural verification of the ACs). This is called out here rather than
silently skipped.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 489 passed, 0 failed, 0 skipped`; exit 0 |
| `FRAMEWORK_TEST_AREAS='10-readiness' bash tests/run.sh` | PASS | 8 passed, 0 failed |
| `FRAMEWORK_TEST_AREAS='80-cycle-fixture' bash tests/run.sh` | PASS | 15 passed, 0 failed |
| `FRAMEWORK_TEST_AREAS='85-conflict-guards' bash tests/run.sh` | PASS | 43 passed, 0 failed |
| `FRAMEWORK_TEST_AREAS='87-backtrack-guards' bash tests/run.sh` | PASS | 103 passed, 0 failed |
| `FRAMEWORK_TEST_AREAS='95-split-guard' bash tests/run.sh` | PASS | 28 passed, 0 failed; `AGENTS.md`/`template/AGENTS.md` body parity holds |
| `FRAMEWORK_TEST_AREAS='96-signature-sweep' bash tests/run.sh` | PASS | 90 passed, 0 failed; new `##` heading not extracted by the phase-heading sweep |
| `FRAMEWORK_TEST_AREAS='40-inventory' bash tests/run.sh` | PASS | 41 passed, 0 failed; 14 agents / 13 commands / 11 skills unchanged |
| `grep -c 'satisfied(dep_local_id):' docs/workflow.md` | PASS | `1` — readiness literal still stated exactly once |
| `grep -n '^## Mental model\|^## The recursive lifecycle model\|^## The work item directory' docs/workflow.md` | PASS | section at line 28, between 8 and 111 |
| `grep -nF '<each AC phrase>' docs/workflow.md` (per-criterion; see matrix) | PASS | node/leaf/decomposition, uniform cycle, unbounded depth, planning-step authoring, `/roadmap` deprecation, hybrid, per-node backtracking, reuse, backward compat |
| `grep -n 'recursive plan\|deprecated alias' AGENTS.md template/AGENTS.md` | PASS | cross-reference at `AGENTS.md:75–78`, mirror at `template/AGENTS.md:77–80` |
| `git diff --numstat -- AGENTS.md docs/workflow.md template/AGENTS.md` | PASS | `5/0`, `87/0`, `5/0` — additions only |
| `git ls-files --others --exclude-standard \| grep -v '^work/'` | PASS | empty — no new agent/command/skill/test/packaging file |
| `git diff --name-only` | PASS | only `AGENTS.md`, `docs/workflow.md`, `template/AGENTS.md`, and `tasks.md` (box ticks) |

## Acceptance coverage

| Criterion | Evidence | Result |
| --------- | -------- | ------ |
| AC1 uniform cycle + node/leaf/decomposition | `docs/workflow.md:33` "applies **uniformly at every node**"; `:43` node def; `:46` leaf def; `:48` decomposition def | PASS |
| AC2 unbounded depth; standalone and nested instances | `docs/workflow.md:60` "imposes **no maximum recursion depth**"; `:60` "any node may decompose into children"; `:61–63` standalone and nested are "valid instances of the same model" | PASS |
| AC3 planning-step authoring, `/roadmap` alias, committed plan state, `0003` pointer | `docs/workflow.md:68` "authored and recorded in the planning (design) step"; `:69` "`/roadmap` command is retained only as a **deprecated alias**"; `:70` "**committed plan state**"; `:72–74` "owned by `0003-recursive-writer`" | PASS |
| AC4 hybrid granularity; tasks are not nodes | `docs/workflow.md:78` "**hybrid** of tasks, features, initiatives, and larger items"; `:79–81` "are **not** nodes … never by promoting a task" | PASS |
| AC5 own artifacts + children; independent cycle; no pure-container requirement | `docs/workflow.md:81–84` "may carry its own phase artifacts and a child set at the same time — the standard cycle applies … independently of its children — and no node is required to be a pure container" | PASS |
| AC6 five terms once; `roadmap` only a deprecated alias | `docs/workflow.md:41` work item, `:43` node, `:46` leaf, `:48` decomposition, `:50` plan; `:53` "`roadmap` is a **deprecated alias** for a decomposing node"; `:30` claims single authority; `## Roadmaps` deferral at `:147–149` removes the competing connotation | PASS |
| AC7 per-node composition with shipped backtracking; no second model/phase/reversal | `docs/workflow.md:88–94` "per node, on the same unshipped work item: the reverse edges, `stale:` marking, re-entry, recall, and the ownership invariant are reused unchanged … no second state model, no new `phase` value, and no new reversal mechanism" | PASS (plus `87-backtrack-guards` 103/0) |
| AC8 reuse of readiness/declared-conflict vocabulary; no new edge/class/state | `docs/workflow.md:96–104` "reused unchanged: the model adds no dependency edge, conflict class, or state vocabulary"; names `### Dependencies and readiness` and `### Declared conflicts (conflicts-with)` by reference; ownership to `0004`/`0002` | PASS (plus `10-readiness` 8/0, `85-conflict-guards` 43/0) |
| AC9 backward compatibility, no forced migration | `docs/workflow.md:106–109` "behaves exactly as before with no forced migration"; existing roadmap parents/children "remains valid under the model"; `## Roadmaps` retained | PASS (plus `80-cycle-fixture` 15/0) |
| AC10 workflow authority states it once; `AGENTS.md` cross-references; no conflicting rule | `docs/workflow.md:28` section present; `AGENTS.md:75–78` and `template/AGENTS.md:77–80` cross-reference the authority and name `roadmap` the deprecated alias; `95-split-guard` confirms body parity | PASS |
| AC11 suite green; no new command/agent/skill; no inventory/contract change | `bash tests/run.sh` 489/0; `40-inventory` 41/0; `96-signature-sweep` 90/0; `git ls-files --others` empty outside `work/`; tracked diff is additions only, so six core commands, `phase` set, `Depends on`/readiness and declared-conflict text are unchanged | PASS |

### Edge cases

| Edge case | Where addressed | Result |
| --------- | --------------- | ------ |
| Leaf is a valid terminal | `docs/workflow.md:46–47` "A leaf is a valid terminal" | PASS |
| Pure container | `:83–84` "no node is required to be a pure container"; `## Roadmaps` retains the pure-container spelling | PASS |
| Own artifacts, no children | `:41–42` every directory under `work/` is a work item / instance of the model | PASS (implied by the term) |
| Deep chain | `:60–64` unbounded depth; "Depth changes no node's phase semantics" | PASS |
| Self-containment / acyclic decomposition tree | Not stated as an explicit sentence; the model calls it a "recursive plan tree" (`:43`) and "a decomposition may nest without limit" (`:61`), which entail acyclicity. Explicit cycle detection for recursive trees is deferred (spec non-goal: simultaneous-work guarantees) | PASS by implication; see residual risk |
| Thick hybrid | `:81–83` own in-progress artifacts + children; cycle applies independently | PASS |
| Task mistaken for a node | `:79–81` tasks are not nodes; create a child only by decomposition | PASS |
| Backtrack on a decomposing node | `:91–92` "takes the same reverse edge to the planning step" | PASS |
| Shipped node | `:89` "on the same unshipped work item" — shipped items excluded by the shipped backtracking model, referenced not restated | PASS (by reference) |
| Historical roadmap parent | `:53–55` retained for backward compatibility; `:107–109` existing content remains valid | PASS |
| Parallel nodes | `:70–71` decomposition is committed plan state on the node's own item; `:96–97` adds no dependency edge and reuses readiness unchanged | PASS (by reference) |
| No convergence requirement | `:60` sets no maximum depth and imposes no minimum; convergence is left to planning judgment | PASS (implied) |

## Gaps and residual risk

- **No committed guard for the model.** The ACs are asserted only by suite
  regression (the existing suite does not read the new section) and by the
  reproducible grep evidence above. This is the design's explicit choice
  (`Test strategy`: "no new test file is added") and the spec's explicit non-goal
  ("Committed fixtures, agreement areas, and mutation coverage pinning the model
  — a successor roadmap"). A future regression that silently rewrites the section
  would not be caught by `bash tests/run.sh`. Follow-up owned by a successor
  roadmap; not a defect here.
- **Concrete-spelling surfaces retain pre-model `roadmap` wording.**
  `docs/artifact-conventions.md:88/109` ("A **roadmap** is a parent work item…",
  "A roadmap is the first-class planning artifact…") and the `/roadmap`
  command/agent prompts still present `roadmap` as a first-class facility with no
  deprecation marker. A very literal reading of AC6's "no surface states a
  competing definition" could flag this. It is **not** recorded as a defect
  because the spec explicitly defers deprecating/removing `/roadmap` and
  `roadmap.md` and migrating existing parents to **Roadmap 2**, and the model
  section itself frames those surfaces as "its shipped, depth-limited concrete
  spelling" (`docs/workflow.md:55`). Flagged for `/review` as a judgment point.
- **`## Mental model` defines "work item" too.** `docs/workflow.md:10` ("A
  **work item** is one unit of change — a feature, a behavior change, or a
  sizable bug") coexists with the authoritative Terms definition at `:41`. The
  two are consistent (the mental-model prose is the single-level framing the
  model generalizes and is placed above it), so it is not treated as a competing
  definition; noted for transparency under AC6.
- **Acyclicity of the decomposition tree is implicit.** The spec edge case
  "a node's decomposition may not reach the node itself" is covered only by the
  word "tree"; no explicit normative sentence was added. Explicit recursive cycle
  detection is assigned to a successor roadmap by the spec non-goals. Low risk
  for a model statement that defines no runtime behaviour.
- Scope stayed within the deliverable surfaces named by the parent roadmap
  (`work/0011-recursive-bootstrap/roadmap.md:103`: "Author the contract in
  `docs/workflow.md` and cross-reference it from `AGENTS.md`"): only
  `docs/workflow.md`, `AGENTS.md`, and the parity mirror `template/AGENTS.md`
  changed.
