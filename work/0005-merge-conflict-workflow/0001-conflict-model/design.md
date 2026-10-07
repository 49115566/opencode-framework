---
feature: 0005-merge-conflict-workflow/0001-conflict-model
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Keystone contract. Resolves the spec's deferred open question: the post-merge integrity pass is a documented, shipper-owned checklist, not a new command; committed guards remain sibling 0005. This child writes only docs and one skill — no command, agent, artifact format, or lifecycle change."
parent: 0005-merge-conflict-workflow
---

# Design — Merge-conflict model and resolution contract

## Summary

Add a normative `## Merge conflicts` section to `docs/workflow.md` that fixes the
conflict taxonomy, lifecycle placement, ownership, resolution principles,
re-verification requirement, and composition with the existing renumbering rule;
encode the shipper's operational procedure in a new
`.opencode/skill/merge-conflict/SKILL.md`; and surface both from `AGENTS.md` /
`template/AGENTS.md` and the README Skills table. The deliverable is documents plus
one skill, so no command, agent, artifact format, readiness/state model, or
lifecycle phase changes: the README inventory count is updated so the committed
suite stays green.

## Approach

**One normative source, one operational derivative.** `docs/workflow.md` is the
authoritative workflow contract (`AGENTS.md` line 55; `tests/checks/20-lifecycle.sh`
treats it as the authority). The contract language therefore lives there, in a new
`## Merge conflicts` section placed after `## Multiple work items` (which already
points at the parallel-merge renumbering rule) and before `## Resuming and
interruption`. The `merge-conflict` skill is a thin, operational restatement of
that section; its first lines name `docs/workflow.md` as the source of truth, and
it defers to it on any disagreement. Nothing else may originate policy.

**Contract content (required literals).** The new section contains five
subsections so every acceptance criterion is observable by reading:
`### Conflict taxonomy` (a markdown table whose rows name the four classes exactly:
(a) shared-surface textual conflict, (b) `work/` artifact conflict, (c) duplicate
sequence number, (d) derived-agreement drift — each row naming at least one
affected surface); `### Lifecycle placement` (pre-ship reconcile before the
shipper's ship operations; post-merge integrity pass after a merge to the default
branch); `### Ownership` (the `shipper` is the single owner; a step inside `/ship`,
not a new command or agent); `### Resolution principles` (merge the default branch
forward; never rebase a pushed branch; never force-push; preserve both branches'
intent; never silently accept a semantic conflict and escalate intent ambiguity to
the user; auto-resolve mechanical/structural conflicts subject to re-verification);
`### Verification` (re-run `bash tests/run.sh` and the affected item's checks after a
resolution and require green before the merge is recorded or shipped); and
`### Relationship to renumbering` (duplicate sequence numbers are handled by
"Renumbering after a parallel merge"; this section defers to and extends it, never
a second rule).

**Lifecycle wiring, not phase change.** Two short cross-references make the
placement discoverable without altering the phase model: a sentence in
`## Multiple work items` pointing to the new section for non-renumbering conflicts,
and a leading sentence in the `### 6. Ship` process telling the reader to reconcile
first. Neither adds, removes, renames, or reorders a phase or command.

**Post-merge integrity pass (resolves the spec's deferred open question).** The
contract defines it as a **documented, shipper-owned checklist** executed on the
merged default branch after a merge: scan top-level and per-parent `work/`
directories for duplicate 4-digit prefixes; check every roadmap `Depends on` against
the `Children` table for dangling, missing, unlisted, or cyclic references; and
re-run `bash tests/run.sh` to surface derived-agreement drift. It is *not* a new
command and *not* a committed suite check in this child: the suite is read-only and
never reads `work/**` (`tests/README.md` line 29), and committed guards plus
pre-flight detection are siblings `0002` and `0005`. This decision is recorded in
the design because the spec deferred it (`spec.md` open questions).

**Skill.** `.opencode/skill/merge-conflict/SKILL.md` uses the existing skill format
(`docs/customization.md` lines 129-145): YAML `name` matching the folder and a
trigger-rich `description`, followed by ordered steps covering detection/
classification, resolution, re-verification, recording of resolved paths and
evidence, the post-merge pass, and an explicit stop-and-escalate path.

**Inventory.** The skill adds one on-disk entry under `.opencode/skill/`, changing
the documented count from 10 to 11. `tests/checks/40-inventory.sh` derives the
on-disk count and both directions of the README table membership, so only `README.md`
must change: the Layout line `# 10 knowledge skills` → `# 11 knowledge skills` and
one new row in the Skills table. No check file changes.

**Backward compatibility.** There is nothing to migrate. `docs/*.md` and
`.opencode/skill/**` are shared verbatim with adopters (README lines 69-70), so
adopters receive the contract and skill on the next copy; `template/AGENTS.md` is
updated so the reference travels to adopters too. No artifact in `work/` is
rewritten (AC12), and the derived-state table in `docs/workflow.md` is untouched.

## Alternatives considered

- **New `/reconcile` command plus a `reconciler` agent.** Pros: a directly
  invocable reconcile surface; a dedicated owner. Cons: it contradicts the user's
  resolved policy fork (reconcile is a step inside `/ship`, owned by the shipper),
  creates a new command and agent — violating non-goals and AC12 — and forces edits
  to `.opencode/command/`, `.opencode/agent/`, `opencode.json`, the README
  Commands/Agents tables, and `tests/checks/40-inventory.sh`. Rejected: the policy
  decision already excludes it, and it multiplies the shared surfaces parallel
  branches must reconcile.
- **Skill-only contract (no `docs/workflow.md` section).** Pros: one artifact to
  write. Cons: AC1-AC8 bind "the workflow contract", and `AGENTS.md` names
  `docs/workflow.md` as the source of truth; a skill is matched by description and
  loaded contextually, so it cannot be the normative source a reviewer or
  `tests/checks/20-lifecycle.sh` reads. Rejected: it would leave the contract
  unstated in the authoritative surface and make the ACs unverifiable.
- **Post-merge integrity pass as a committed `tests/checks/` guard.** Pros: an
  automated, regression-proof pass. Cons: the suite is read-only and never reads
  live `work/**`, so a live-tree integrity assertion is impossible as a suite check;
  committed fixture-based guards are the explicit sibling `0005-merge-integrity-guards`
  scope. Rejected for this child: out of scope and infeasible against live `work/`.

## Interfaces and data model

No runtime interfaces change. The concrete "interfaces" are the document and
inventory contracts the builder must produce.

`docs/workflow.md` — new sections and the required literals each must contain:

| Section | Required literal(s) |
| ------- | ------------------- |
| `## Merge conflicts` | the heading itself |
| `### Conflict taxonomy` | the four class names (a)-(d) and, per row, a named surface; surfaces include `README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`, roadmap `Children`/`Depends on`, top-level `work/<NNNN-slug>`, per-parent `work/<NNNN-slug>/<MMMM-slug>`, README Layout counts, README Skills table |
| `### Lifecycle placement` | `pre-ship reconcile`, `post-merge integrity pass`, `before the shipper` / ship operations, `after a merge to the default branch` |
| `### Ownership` | `shipper` is the `single owner`; `step inside /ship`; no new `command` or `agent` |
| `### Resolution principles` | `merge the default branch forward`; `never rebase a pushed branch`; `never force-push`; preserve both branches' intent; never silently accept a semantic conflict; escalate to the user; auto-resolve mechanical/structural, subject to re-verification |
| `### Verification` | `bash tests/run.sh`; the affected item's checks; green before the merge is recorded or shipped |
| `### Relationship to renumbering` | `Renumbering after a parallel merge`; defers to and extends it, does not define a second renumbering rule |

Two cross-references are also added: `## Multiple work items` gains a sentence
pointing to `## Merge conflicts` for non-renumbering conflicts, and `### 6. Ship`
gains a leading sentence to reconcile first.

`.opencode/skill/merge-conflict/SKILL.md` — new file, frontmatter
`name: merge-conflict` (folder name must equal `name`) plus a description with
trigger keywords (`merge conflict`, `reconcile`, `conflict`, `branch behind`,
`/ship`), body stating `docs/workflow.md` is the source of truth and ordered steps:
detect → classify → resolve (mechanical auto-resolve vs. semantic escalate) →
re-verify (`bash tests/run.sh` + item checks) → record resolved paths and evidence →
run the post-merge integrity pass → stop-and-escalate path.

`README.md` — one new Skills-table row naming `merge-conflict`, and Layout line
`skill/     # 10 knowledge skills` → `# 11 knowledge skills`.

`AGENTS.md` and `template/AGENTS.md` — one `## Reference` bullet each naming the
`merge-conflict` skill (and the `docs/workflow.md` `## Merge conflicts` section).
Both copies are updated so the reference reaches adopters via the pristine template.

`docs/artifact-conventions.md` — one sentence in `### Renumbering after a parallel
merge` pointing to the new `## Merge conflicts` section, so AC8's composition is
bidirectional.

`docs/customization.md` — refresh the `docs/workflow.md` row and total in the
`## Always-loaded instructions` table (recompute at ~4 bytes/token), per that
table's own instruction to refresh when a listed file changes. Documentation
consistency only; not gated by a check.

Unchanged: `.opencode/agent/*.md`, `.opencode/command/*.md`, `opencode.json`,
`tests/**`, all `work/` artifact formats, the phase list, and the derived-state
table.

## Affected areas

- `docs/workflow.md` — new `## Merge conflicts` section; cross-references in
  `## Multiple work items` and `### 6. Ship`. (lines 313-345 are the insertion
  neighbourhood)
- `.opencode/skill/merge-conflict/SKILL.md` — new.
- `README.md` — `## Skills` table (lines 251-264) and `## Layout` skill count
  (line 272).
- `AGENTS.md` (`## Reference`, lines 131-135) and `template/AGENTS.md`
  (`## Reference`, lines 133-137).
- `docs/artifact-conventions.md` — `### Renumbering after a parallel merge`
  (lines 438-465).
- `docs/customization.md` — `## Always-loaded instructions` cost table (lines
  56-62).
- Read for context, not changed: `.opencode/agent/shipper.md` (lines 105-127,
  148-158), `.opencode/command/ship.md`, `tests/checks/40-inventory.sh`,
  `tests/checks/20-lifecycle.sh`, `tests/README.md` (line 29).

## Risks and mitigations

- **Contract and skill drift.** The two restatements diverge over time. Likelihood
  medium / impact medium. Mitigation: the skill names `docs/workflow.md` as source
  of truth in its opening lines; T4 depends on T1-T3 so the skill is written from
  the finished contract.
- **README inventory drift breaks the suite.** Adding the skill without updating
  the Layout count or the Skills table fails `tests/checks/40-inventory.sh` (AC11).
  Likelihood medium / impact high. Mitigation: T5 changes the count and the table in
  one commit; T8 runs the full suite.
- **Stale always-loaded cost.** `docs/workflow.md` grows, leaving the customization
  table wrong. Likelihood high / impact low. Mitigation: T7 recomputes from file size.
- **Scope creep into executable detection or shipper git permissions.** The
  reconcile mechanics and allowlist changes belong to sibling `0003`
  (`spec.md` non-goals). Likelihood medium / impact high. Mitigation: the task list
  touches only docs and one skill; no task edits an agent or command file, and AC12
  is verified in T8.
- **The post-merge pass is mistaken for automation.** The contract could imply an
  executable guard that does not exist yet. Likelihood medium / impact medium.
  Mitigation: the contract calls it a "documented checklist" and names the committed
  guards as separate work; committed verification is explicitly deferred.
- **Root and template `AGENTS.md` diverge.** Updating only one copy hides the
  reference from adopters. Likelihood low / impact medium. Mitigation: T6 updates
  both and greps both.

## Test strategy

The committed suite is the regression level; document/skill content has no unit
harness, so each criterion is verified by reading/grepping the required literals and
by the suite for the inventory and lifecycle invariants. No new committed check is
added (sibling `0005` owns guards). The tester's `verify.md` maps:

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | content: grep/read `docs/workflow.md` taxonomy + four surfaces |
| AC2 | content: grep `### Lifecycle placement` pre-ship + post-merge literals |
| AC3 | content: grep `### Ownership` shipper / step inside `/ship` / no new command |
| AC4 | content: grep merge-forward + never rebase/force-push literals |
| AC5 | content: grep preserve intent + escalate/never silently accept literals |
| AC6 | content: grep mechanical/structural auto-resolve + re-verification |
| AC7 | content: grep `bash tests/run.sh` + item checks + green-before-record |
| AC8 | content: grep the renumbering deferral in both `docs/workflow.md` and `docs/artifact-conventions.md` |
| AC9 | content: read `.opencode/skill/merge-conflict/SKILL.md` ordered steps |
| AC10 | content: grep `merge-conflict` in `README.md`, `AGENTS.md`, `template/AGENTS.md` |
| AC11 | integration: `bash tests/run.sh` exits 0, no `FAIL AC9` inventory line |
| AC12 | integration: `bash tests/run.sh` (20-lifecycle, 40-inventory) + listing shows 12 commands / 14 agents unchanged, no new command or agent file |

`bash tests/run.sh` is the project's canonical command (`AGENTS.md` line 17) and is
run after every task; the tester re-runs it independently for AC11/AC12.
