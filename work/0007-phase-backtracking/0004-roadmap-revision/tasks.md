---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Tasks — Parent-roadmap revision from child phases

Ordered, dependency-aware. One task ≈ one focused commit. This item edits
documentation, prompts, a command, and one test literal only; it adds no command,
agent, skill, fixture, or runtime dependency.

- [ ] **T1** — In `docs/workflow.md`, add `### Revising a roadmap` as the final subsection of `## Roadmaps`, stating once: the `/roadmap revise <item-ref>` invocation and roadmap-owner-only writing (a non-parent reference is refused); the four operations — re-scope, add, withdraw, re-sequence; the local-number allocation rule (greatest ever-committed `MMMM` under the parent + 1, never reused) and the new child `.gitkeep`; the withdrawal record under `## Open issues` (directory and spent number preserved); the post-revision validation predicate (every `Depends on` names another row, no self-dependency, acyclic, every canonical reference resolves to a directory, every active child is a row, sequencing after all dependencies, six-column layout and well-formed cells) and the cycle fallback (store no cyclic edge, record under `## Open issues`); the `stale: roadmap` invalidation of affected unshipped children and the shipped-child refusal; and the provenance rule (`backtracks.md` finding/resolution plus the parent revision note and `updated`). Reference `## Phase reversal (backtracking)` and `docs/artifact-conventions.md` → "`backtracks.md`" rather than restating them. Add the deliberate-withdrawal recognition clause to `### Status reporting`, and update the `## Phase reversal (backtracking)` edge-row pointer to name the new subsection. [AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10, AC12, AC15]
      Verify: read the new subsection; `grep -n 'Revising a roadmap' docs/workflow.md` returns it; `grep -n` confirms the four operation names, the validation invariants, `stale: roadmap`, the shipped-child refusal, and a reference to "Phase reversal (backtracking)"; confirm no new `phase` value or finding code was introduced.

- [ ] **T2** — In `docs/artifact-conventions.md` → the `roadmap.md` template, document the withdrawal record and the revision note under `## Open issues`: the withdrawal entry shape (retained directory, spent local number never reused, rationale), and that a revision changes `updated` and appends a revision note. Add no new template section or frontmatter field. [AC4, AC10] [depends: T1]
      Verify: read the `roadmap.md` template; `grep -n 'Withdrawn child' docs/artifact-conventions.md` and the revision-note wording match T1's authority; confirm no new frontmatter field is introduced.

- [ ] **T3** — In `.opencode/agent/roadmap.md`, add the revise-mode branch to `<mission>`, `<inputs>`, `<process>`, `<quality_bar>`, `<rules>`, and `<handoff>`: resolve and require a parent `roadmap.md` (else refuse); load the triggering child's `backtracks.md` finding when present; apply re-scope/add/withdraw/re-sequence in one pass; allocate the next local `MMMM` from committed history; create new child `.gitkeep` files; validate the graph and recompute `## Sequencing`; mark each affected unshipped child's five artifacts `stale: roadmap`; record the withdrawal and revision note under `## Open issues`; append the triggering child's resolution entry; refuse a shipped-child re-scope; treat an empty revision as a no-op; write no child phase artifact. [AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC10, AC12] [depends: T1]
      Verify: read the prompt; `grep -n 'revise' .opencode/agent/roadmap.md` shows the branch in process/quality-bar/rules/handoff; `grep -n 'backtracks.md'` shows the resolution rule; confirm the rules still forbid writing a child's spec/design/tasks/verify/review and still require only `work/`.

- [ ] **T4** — In `.opencode/command/roadmap.md`, set the `description` usage string to the canonical `/roadmap <initiative> | /roadmap revise <item-ref>`, add an argument-grammar block (`/roadmap <initiative>` creates; `/roadmap revise <item-ref>` revises an existing parent and refuses a non-parent), and describe the autonomous revise mode with no pre-write approval gate. [AC12, AC13] [depends: T1]
      Verify: `grep -n 'Usage: /roadmap <initiative> | /roadmap revise <item-ref>' .opencode/command/roadmap.md` matches; read the grammar block and confirm the non-parent refusal and the no-pre-write-gate statement.

- [ ] **T5** — In `.opencode/agent/product.md` and `.opencode/agent/architect.md`, add a rule that when recon finds the parent roadmap wrong, the phase names the sanctioned `/roadmap revise <parent-ref>` route, records the finding in the item's `backtracks.md` (target phase `roadmap`), and does not edit the parent `roadmap.md`. Reference the authority; add no reverse-edge vocabulary. [AC11] [depends: T1]
      Verify: `grep -n '/roadmap revise' .opencode/agent/product.md .opencode/agent/architect.md` matches in both; `grep -n 'backtracks.md'` matches; confirm neither prompt instructs editing `roadmap.md`.

- [ ] **T6** — In `.opencode/agent/status.md` and `.opencode/command/status.md`, add the AC8 recognition clause: an `UNLISTED-CHILD` observation for a child directory named as withdrawn under the parent's `## Open issues` is a deliberate withdrawal, reported report-only and never auto-repaired, not a possible rename. Touch no other finding code and do not restate the readiness algorithm. [AC8] [depends: T1]
      Verify: `grep -n 'deliberate withdrawal' .opencode/agent/status.md .opencode/command/status.md` matches; `bash tests/run.sh` stays green for `10-readiness.sh` and `80-cycle-fixture.sh`.

- [ ] **T7** — Update the `/roadmap` canonical signature to `/roadmap <initiative> | /roadmap revise <item-ref>` on every signature surface in one change: `tests/checks/96-signature-sweep.sh` (`canonical_signature`), `AGENTS.md`, `template/AGENTS.md`, `README.md` (escaped `\|` in the Commands table cell), `.opencode/skill/workflow-lifecycle/SKILL.md` (routing block), and the `docs/workflow.md` routing bullet. Add no command row and change no Layout count. [AC13] [depends: T1]
      Verify: `bash tests/run.sh` → `96-signature-sweep.sh` and `40-inventory.sh` green; `grep -rn '/roadmap <initiative> | /roadmap revise <item-ref>' AGENTS.md template/AGENTS.md README.md .opencode/skill/workflow-lifecycle/SKILL.md .opencode/command/roadmap.md tests/checks/96-signature-sweep.sh` matches each surface; confirm README still has 13 command rows.

- [ ] **T8** — Verify the whole change: run the suite, confirm the six `phase` values, the derived-state contract, and the `Depends on`/readiness semantics are unchanged, confirm no documented inventory count changed, and confirm the six-column `Children` contract and the cycle/conflict guards stay green. [AC9, AC14] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` → exit 0 with `TOTAL: … 0 failed` (in particular `10-readiness.sh`, `20-lifecycle.sh`, `40-inventory.sh`, `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `96-signature-sweep.sh` green); `git diff --stat` lists only the planned surfaces (`docs/workflow.md`, `docs/artifact-conventions.md`, the four `.opencode` prompts/commands, the skill, AGENTS/template/README, and `tests/checks/96-signature-sweep.sh`); `grep -rn` finds no new `phase` value or new finding code.
