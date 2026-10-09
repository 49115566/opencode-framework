---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Review — Parent-roadmap revision from child phases

## Verdict

**approve** — all fifteen acceptance criteria are met on the named surfaces, the
change is additive and scoped to the planned files, and the committed contract
surfaces it depends on (signature sweep, inventory, readiness, cycle/conflict
guards, AGENTS/template parity) are untouched or updated consistently; the
remaining findings are minor clarity/coverage points, not defects that block
merge.

## Base and range

The work is uncommitted on `main`, which is level with `origin/main`; there is no
feature branch to diff against, so the review range is the working tree versus
`HEAD`.

| Command | Result |
| ------- | ------ |
| `git merge-base HEAD origin/main` | `117bbde56919198ad1f489a817941356a6cb8c99` |
| `git rev-parse HEAD origin/main` | `117bbde…` (both) — base equals tip |
| `git status` | modified: 13 tracked surfaces + `tasks.md`; untracked: `verify.md` |
| `git diff` | the reviewed change (318 insertions, 45 deletions, 14 files) |
| `git diff --stat -- tests/` | `tests/checks/96-signature-sweep.sh` only, +1/−1 |

No ambiguity in the base: `HEAD == origin/main`, and the only change is the
uncommitted working tree. `git diff` is the complete reviewed range.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — revise parent in place; canonical ref/`feature`/child numbering unchanged; no new top-level item | met | `docs/workflow.md:205-215` (existing parent, sole writer, non-parent refused); `.opencode/agent/roadmap.md:196-201` (quality bar: canonical ref/`feature`/child numbering unchanged, no new top-level item); `.opencode/command/roadmap.md:40-42` (non-parent refused). |
| AC2 — re-scope updates row in place, preserves local id/dir, invalidates child | met | `docs/workflow.md:220-221`; invalidation `:259-268`; `.opencode/agent/roadmap.md:133-134`. |
| AC3 — add allocates next committed `MMMM`, never reuses, creates dir, ref resolves | met | `docs/workflow.md:222-227`; `.opencode/agent/roadmap.md:135-139`; `.opencode/command/roadmap.md:45-46`; allocation contract unchanged (`docs/artifact-conventions.md` → "Sequence allocation"). |
| AC4 — withdraw drops row from `Children`/`Sequencing`, preserves dir+number, records under Open issues | met | `docs/workflow.md:228-233`; template shape `docs/artifact-conventions.md:143-148`; matches precedent `work/0003-framework-quality-hardening/roadmap.md:87-95`. |
| AC5 — affected existing unshipped child artifacts marked `stale: roadmap`; unaffected untouched; non-destructive | met (one optional artifact omitted — M1) | `docs/workflow.md:259-268`; `.opencode/agent/roadmap.md:157-164,240-241`. `stale: roadmap`→`spec` mapping is the pre-existing `docs/workflow.md` derived-state clause. |
| AC6 — `## Sequencing` lists every child after all deps | met | `docs/workflow.md:234-236,247`; `.opencode/agent/roadmap.md:144-151`. |
| AC7 — dependency/table/dir validation; no self-dep; acyclic; cycle recorded | met | `docs/workflow.md:238-257`; `.opencode/agent/roadmap.md:147-156`. |
| AC8 — retained withdrawn dir recognized as deliberate withdrawal, report-only | met | `docs/workflow.md:191`; `docs/artifact-conventions.md:166-172`; `.opencode/agent/status.md:159-163`; `.opencode/command/status.md:30-33`. |
| AC9 — six-column table, pipe-field 5/6, well-formed `conflicts-with`; guards green | met | `docs/workflow.md:248-250`; no header/fixture change (`git diff --stat`); `80-cycle-fixture.sh`/`85-conflict-guards.sh` untouched. |
| AC10 — child backtrack finding+resolution; parent `updated` + revision note; history recoverable | met | `docs/workflow.md:275-287`; template shapes `docs/artifact-conventions.md:143-176` and `:466-513`; `.opencode/agent/roadmap.md:165-170`. |
| AC11 — product/architect name the route, record finding, do not edit parent | met | `.opencode/agent/product.md:107-115` and `.opencode/agent/architect.md:108-116` (both name `/roadmap revise <parent-ref>`, `backtracks.md`, "Never edit the parent `roadmap.md`"). |
| AC12 — autonomous, no pre-write approval gate | met | `docs/workflow.md:213-214`; `.opencode/command/roadmap.md:57-60`; agent revise mode has no approval step. |
| AC13 — one consistent signature; no new command; signature agreement green | met | canonical literal `tests/checks/96-signature-sweep.sh:47`; surfaces `AGENTS.md:47`, `template/AGENTS.md:49`, `README.md:203` (escaped `\|`) + `:184`, `SKILL.md:31`, `.opencode/command/roadmap.md:2`, `docs/workflow.md:794`; no new file under `.opencode/command/` (13 rows unchanged). |
| AC14 — configured test command passes; phase/derived-state/readiness unchanged; no inventory-count change | met (suite result taken from `verify.md`; see "Not reviewed") | `verify.md` records `bash tests/run.sh` → `TOTAL: 335 passed, 0 failed, 0 skipped`; I independently confirmed the changed check is a one-line registry literal and that the touched surfaces keep the inventory/phase/derived-state contracts intact. |
| AC15 — authority references the `0001` model, no second vocabulary | met | `docs/workflow.md:209-212,275-287` reference `## Phase reversal (backtracking)` and `docs/artifact-conventions.md` → `backtracks.md`; only the pre-existing `UNLISTED-CHILD` code appears in added lines. |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] Optional `visual.md` is outside the stale-marking enumeration** — `docs/workflow.md:262`, `.opencode/agent/roadmap.md:159-160`
  AC5 says *every* affected unshipped child's artifacts are marked stale per the `0001` model, and `docs/workflow.md` → "Phase reversal (backtracking)" defines invalidation as marking *each artifact downstream of the target phase*. The implementation enumerates the five phase artifacts (`spec.md`, `design.md`, `tasks.md`, `verify.md`, `review.md`) but omits `visual.md`, which is a produced artifact and downstream of `spec`. A UI-bearing child whose row is re-scoped keeps a `visual.md` that is not invalidated. Impact is low (`docs/workflow.md` derived state says `visual.md` does not change the item's phase, and the child re-runs the visual pass at review), but the AC wording is broader than the implementation. Fix: add `visual.md` to the enumeration in both the authority and the agent, or state explicitly that an optional, phase-neutral artifact is left unmarked by design.

- **[M2] The item knowingly ships a live `DRIFT-FACT` on itself** — `work/0007-phase-backtracking/0004-roadmap-revision/design.md:9`
  The design's `conflicts-with` list is a strict superset of the parent `Children` row's cell for `0004-roadmap-revision` (`work/0007-phase-backtracking/roadmap.md:86`). Per `docs/workflow.md` → "Declared-conflict check", when both are present and unequal the read-only check reports `DRIFT-FACT`; the design and `verify.md` both acknowledge this. It is advisory, prompt-only, blocks no phase, and is a defensible trade (the design's set is the more accurate one). Still, `/status` and `/conflicts` will now surface a fault against the item as built. Fix (owner-level, not this phase): have the roadmap owner run the new revise route to sync the parent cell, or narrow the design declaration to the parent's three surfaces until then.

- **[M3] "explicitly re-sequences it" is not operationally defined** — `docs/workflow.md:259-261`, `.opencode/agent/roadmap.md:157-158`
  Every revision rewrites `## Sequencing` as a topological order, so it is unclear whether moving a child in that list (without changing its `Depends on` cell) counts as "explicitly re-sequenced" and therefore marks it stale. Two runs of the route could diverge on which children are invalidated. Fix: define the trigger concretely, e.g. "marked stale when any `Children` cell changes, or when the revision changes that child's position relative to a dependency" (or state that the topological rewrite alone never marks a child).

### Nits

- **[N1] Backtrack `target phase` label is `roadmap` while the record template uses slash-prefixed labels** — `docs/workflow.md:277`, `docs/artifact-conventions.md:500`
  The `backtracks.md` template's finding entry shows `- target phase: \`/plan\``; the new roadmap-target entry uses the bare `stale` token `roadmap`. The choice is coherent with the `stale` token, but a reader comparing the two may stumble. Consider documenting the label once (`roadmap`, matching the `stale` token) in the template.

- **[N2] The reverse-edge bullet still attributes the route to a work item** — `docs/workflow.md:678-679`
  The reverse-edge table row now points to `### Revising a roadmap`, but the exceptions bullet still says the route "is owned by `0004-roadmap-revision`". This was left unchanged by design and remains true as provenance, but after this ships the forward pointer to the subsection reads better than a build-item number.

- **[N3] Create-mode trailing paragraph applies awkwardly in revise mode** — `.opencode/command/roadmap.md:62-65`
  The closing instructions ("If `$ARGUMENTS` is empty, ask for the initiative… If the request is really a single feature, recommend `/spec`…") are create-mode concerns but sit after both mode blocks. A revise invocation that is mis-typed as empty could be read as a create request. Consider scoping the paragraph to create mode.

## Scope and conventions

- **Scope:** the diff touches exactly the design's Affected areas — `docs/workflow.md`, `docs/artifact-conventions.md`, the four `.opencode` agent/command files, the `workflow-lifecycle` skill, `AGENTS.md`, `template/AGENTS.md`, `README.md`, `tests/checks/96-signature-sweep.sh`, plus `tasks.md`/`verify.md`. No unrelated refactor, no new command/agent/skill/file, no dependency, no inventory-count change.
- **Convention fit:** the new `### Revising a roadmap` subsection sits under `## Roadmaps`, before `## Phases`; the frontmatter field set is unchanged (no new `phase` value, no new frontmatter field); the `backtracks.md` record and `stale`/`roadmap` token reuse the `0001` vocabulary rather than forking it.
- **Security / secrets:** no credentials, tokens, or `.env` content; the roadmap agent's permission remains `work/**` + `**/work/**` and its bash allowlist is unchanged. No security concern.
- **Backward compatibility:** additive; existing roadmaps need no migration, allocation and readiness semantics are unchanged.
- **Performance:** not applicable (docs/prompt/test-literal change).
- **Tests:** the only test change is the required one-line canonical registry literal; no assertion was removed, weakened, skipped, or deleted. Committed fixtures/mutation coverage are explicitly assigned to `0007-backtracking-guards` by the spec's non-goals and the design's Test strategy, so the absence of a new check area is sanctioned. I also confirmed the AGENTS/template shared-body parity guard (`tests/checks/95-split-guard.sh:288-315`) still holds because both files received the identical edit.

## Not reviewed

- The suite was **not independently executed**: the review environment's bash
  allowlist is read-only and forbids running `tests/run.sh`. The 335/0/0 result
  is taken from `verify.md`; I separately traced `96-signature-sweep.sh`
  extraction/normalization for every changed signature surface, `40-inventory.sh`
  command-name parsing, `10-readiness.sh` (the new text adds no readiness branch),
  `20-lifecycle.sh`, `50-instructions.sh`, and the `95-split-guard.sh` parity
  guard, and found no failing path.
- `visual.md` is intentionally absent (non-UI, docs-only item), so no visual pass
  applies.
- Live `/roadmap revise` behavior (the operations, stale marking, and provenance
  entries) is LLM/prompt behavior and is not executable in CI; it is a documented
  residual for `0007-backtracking-guards`.
