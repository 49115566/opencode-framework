---
feature: 0006-parallel-plan-conflicts/0002-plan-record
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "User resolved both spec open questions on 2026-10-08: (1) a plan pull request requires at least one human approval before merge — documented as a process precondition, not encoded or verified offline by the framework; (2) publication is a plan mode of /ship (`/ship plan <item-ref>`) run by the shipper, not a new command. The declaration home is the `conflicts-with` frontmatter value on `design.md`."
---

# Design — Pre-development plan publication and declared conflict record

## Summary

A work item's declaration of intended conflict targets is stored as a
`conflicts-with` value in its `design.md` frontmatter, using the shipped `0001`
`ConflictTargetList` grammar unchanged. The item's plan — `spec.md`,
`design.md`, and `tasks.md` — is published before development by a new **plan
mode of `/ship`** (`/ship plan <item-ref>`, shipper-only) on a dedicated
`plan/<ref>` branch and pull request, approved by a human and merged to the
default branch; `/build` refuses to start while the plan is unmerged. No new
artifact, phase value, command, or grammar is introduced, so derived state and
the committed suite are unchanged.

## Approach

### 1. Declaration home: `design.md` frontmatter

The declaration authored at `/plan` (spec user decision 2) lives in the
architect-owned `design.md` frontmatter:

```yaml
conflicts-with: "<ConflictTargetList>"   # e.g. "docs/workflow.md, tests/checks"
```

- The value is exactly one `ConflictTargetList` per `docs/workflow.md` →
  "Declared conflicts (`conflicts-with`)" (`:110-166`); this item adds no
  grammar. A single `—` (or the field's absence) means no declared conflicts.
- Only `design.md` carries it. `spec.md` (product-owned) and `tasks.md`
  (decomposition) do not. A roadmap **parent** has no `design.md`; its
  declaration remains the `Children` table's `conflicts-with` cells.
- `docs/workflow.md` gains the storage statement and the union rule: a roadmap
  child's declared set is the union of its own `design.md` value and its parent
  `Children` row's cell; a disagreement between the two is reported by the later
  check (`0003`), never silently resolved. Unresolved/malformed values follow the
  existing rule — reported by the later check, never dropped or auto-repaired.
- The declaration is advisory: it adds no readiness edge, reorders no child, and
  changes no readiness (`READINESS` algorithm untouched).

### 2. Plan publication: `/ship plan <item-ref>`

Publication is a new **mode of the existing `/ship` command**, run by the
`shipper` (the only git-writing agent / AC9). Argument grammar becomes:

```
/ship [item-ref | plan <item-ref> | fix [short description]]
```

Plan mode behavior:

1. **Preconditions.** `work/<item-ref>/spec.md` and `design.md` exist (the item
   has completed `/plan`; `tasks.md` is included when present). No `review.md` is
   required — plan mode is a documented exception to the approved-work-item
   precondition, like fix mode. The plan diff contains no secrets.
2. **Dedicated branch.** Create or switch to `plan/<ref>`, where `<ref>` is the
   canonical reference with `/` → `-`
   (`plan/0006-parallel-plan-conflicts-0002-plan-record`). Each item gets its own
   branch, so concurrent publications are independent and no plan is overwritten.
3. **Commit.** Stage the plan artifacts under `work/<item-ref>/` and commit them
   as one conventional commit (`docs(plan): record plan for <item-ref>`). Never
   `git add -A`.
4. **Push (ask) and open a PR** using the plan template (see interfaces). The PR
   links `spec.md`, `design.md`, and `tasks.md` by repository path and prints the
   item's declared conflicts, or `—`.
5. **Human approval, then merge.** At least one human approval is required
   before the plan PR is merged (user decision 1). The shipper neither approves
   nor merges; the merge is a human action and the repository may enforce the
   approval via branch protection.
6. **No ship record, no reconcile.** Plan mode never writes `ship.md`, never runs
   the ship pre-flight or reconcile, and never creates the final ship branch/PR.
   `ship.md` stays the sole shipped signal.
7. **Revision.** A later `/plan` revision is published through the same flow:
   add a commit to the existing `plan/<ref>` branch and update its PR (or open a
   new PR if the branch was pruned). Never force-push a pushed branch.
8. **Idempotence.** Re-invoking publication when the plan is already on the
   default branch and unchanged is a no-op: report it and create nothing.

### 3. `/build` gate before development

The `builder` runs a precondition before selecting a task. It is offline-first
and git-only (no `gh` requirement):

```
plan_gate(item_ref):
  ref        = item_ref with "/" -> "-"
  plan_branch = "plan/" + ref
  # 1. Published / merged?
  if origin exists:
      if git cat-file -e origin/<default>:work/<item_ref>/design.md  -> PROCEED
  else:
      if git cat-file -e <default>:work/<item_ref>/design.md         -> PROCEED
  # 2. An open/unmerged plan branch blocks development
  if git ls-remote --heads origin plan/<ref> returns a ref,
     or a local branch plan/<ref> exists                            -> REFUSE
  # 3. No publication recorded (historical / pre-flow item)
  otherwise                                                          -> PROCEED (note it)
```

- Case 2 is AC2: development does not begin while the plan PR is unmerged. The
  builder stops before implementing and reports the branch/PR that must be
  merged.
- Case 3 is AC10: an item with no plan PR (historical, or created before this
  change) is not blocked and needs no migration; the builder notes that no plan
  publication was found. `origin` being unreachable degrades to the same
  best-effort result and never hard-fails the build.
- The gate is documented in the workflow authority and referenced by the
  builder prompt and `/build` command, so there is no second copy of the
  algorithm.

### 4. Surfaces and consistency

The flow and the declaration's home are stated once in `docs/workflow.md`, the
frontmatter shape once in `docs/artifact-conventions.md`, and the owning prompts
(`architect`, `shipper`, `builder`) and their commands describe and reference
them without restating the grammar. `README.md`, `AGENTS.md`,
`template/AGENTS.md`, the derived-state table, the phase list, and the
`workflow-lifecycle` routing skill are unchanged: plan publication is a process
step, not a phase, and the canonical `/ship [item-ref]` signature is preserved in
every designated position.

## Alternatives considered

- **A new `/publish` command.** Pros: a name that matches the operation. Cons:
  adds a command, so the README Commands table and Layout count
  (`12 slash commands`) plus the signature-sweep registry/`ALL_COMMANDS`
  (`tests/checks/96-signature-sweep.sh`) must change in this item, and it
  competes with the command `0003-conflict-check` may add. `/ship` already owns
  the branch/commit/push/PR machinery and the sole git-writer role, so a mode is
  strictly smaller. **Rejected.**
- **Declaration in a `design.md` body section** (`## Declared conflicts`). Pros:
  human-readable in place. Cons: a later check must parse free prose, and the
  framework already reads structured values (`frontmatter`, the `Children`
  table). A body section plus frontmatter would create two sources that can
  disagree. **Rejected** for the frontmatter value.
- **Persist plan-publication state in a new frontmatter field or artifact**
  (e.g. `plan-pr:`/`plan.md`). Pros: `/build` could read a recorded URL. Cons:
  the non-goals forbid a new artifact/phase value, a shipper-written field would
  be a cross-phase edit of an architect artifact, and git already knows whether
  the plan is merged. **Rejected** for the git-derived gate.
- **Gate on `gh pr view` state instead of the default branch.** Pros: directly
  reads GitHub approval/merge state. Cons: `gh` is optional in this framework and
  the gate would break offline; the default-branch check is durable and local.
  **Rejected.**
- **A step inside `/plan` that publishes.** Pros: one command. Cons: the
  architect cannot perform git writes (AC9, AGENTS guardrails), so the shipper
  must drive it anyway. **Rejected.**
- **Change the canonical `/ship [item-ref]` signature to include plan mode.**
  Pros: the signature advertises the mode. Cons: forces edits across
  `AGENTS.md`, `template/AGENTS.md`, `README.md`, `docs/workflow.md`, the
  `workflow-lifecycle` skill, and `tests/checks/96-signature-sweep.sh`; the
  repo's own precedent keeps `fix` mode outside the canonical base. **Rejected;**
  plan mode is documented additionally, like `fix`.

## Interfaces and data model

**`design.md` frontmatter (optional field):**

| Field | Values | Notes |
| ----- | ------ | ----- |
| `conflicts-with` | one `ConflictTargetList` (quoted YAML scalar), or `—` | optional; absent or `—` = no declared conflicts; advisory; never affects phase derivation or readiness |

**Plan branch:** `plan/<ref>`, `<ref>` = canonical reference with `/` → `-`.
Examples: `plan/0007-billing`,
`plan/0006-parallel-plan-conflicts-0002-plan-record`.

**`/ship` argument grammar (adds one mode):**

```
/ship [item-ref | plan <item-ref> | fix [short description]]
  item-ref  -> work-item ship mode (unchanged)
  plan      -> plan-publication mode (new)
  fix       -> fix-landing mode (unchanged)
```

**Plan PR description template (new section in the `pr-workflow` skill):**

```markdown
## Summary

<The work item's plan, published before development begins. Ref: <item-ref>.>

## Declared conflicts

- <the item's `design.md` `conflicts-with` value, or `—`>

## Plan artifacts

- Spec: `work/<item-ref>/spec.md`
- Design: `work/<item-ref>/design.md`
- Tasks: `work/<item-ref>/tasks.md`

## Testing

- <the project's configured test command result, or "plan-only; no code changed">
```

The template omits the ship `## Conflict detection` and `## Reconcile` sections,
which are merge-time only.

**Authority additions (`docs/workflow.md`):**

- `### Declared conflicts (conflicts-with)` (`:110-166`) gains: the item-level
  declaration home (`design.md` frontmatter `conflicts-with`), the union +
  mismatch rule, and the confirmation that unresolved declarations are reported
  by the later check. The grammar itself is not restated.
- A new `## Plan publication` section inserted after the `## Phases` block
  (Phase 6 ends at `:295`) and before `## Derived state` (`:297`) states the
  flow, the `/build` gate, the revision and historical rules, and the advisory
  nature, and references the `0001` grammar.
- Phase 2 `/plan` `Next` (`:226`) and Phase 3 `/build` `Entry` (`:231`) gain
  pointers to the plan-publication step / gate.

**`docs/artifact-conventions.md`:** the Frontmatter rules (`:28-39`) gain a
`conflicts-with` bullet, and the `design.md` template (`:193-200`) shows the
optional field; both point to the workflow authority.

**Backward compatibility and migrations:** none required. An absent
`conflicts-with` field is no declared conflicts (AC6); an absent plan branch and
absent default-branch plan is "no publication recorded" and `/build` proceeds
(AC10); no new artifact, no new `phase` value, no derived-state row, no README
count, and no command signature changes, so historical items and the committed
suite are unaffected.

## Affected areas

- `docs/workflow.md` — `### Declared conflicts (conflicts-with)` addition; new
  `## Plan publication` section; Phase 2 `Next`; Phase 3 `Entry`.
- `docs/artifact-conventions.md` — Frontmatter rules bullet and `design.md`
  template field for `conflicts-with`.
- `.opencode/agent/architect.md` — author the declaration at `/plan`; quality
  bar; hand off to `/ship plan`.
- `.opencode/command/plan.md` — declaration and publication handoff text.
- `.opencode/agent/shipper.md` — plan-publication mode.
- `.opencode/command/ship.md` — plan mode in the argument grammar and usage
  (appended after the existing required usage substring).
- `.opencode/agent/builder.md` — `/build` plan gate.
- `.opencode/command/build.md` — `/build` plan gate reference.
- `.opencode/skill/pr-workflow/SKILL.md` — plan PR description template.
- `.opencode/skill/conventional-commits/SKILL.md` — `plan/<ref>` branch prefix.

**Deliberately unchanged:** `README.md`, `AGENTS.md`, `template/AGENTS.md`,
`tests/**`, `opencode.json`, the derived-state table, the `phase` vocabulary,
and the `workflow-lifecycle` skill. `AGENTS.md`'s lifecycle table and README's
Commands table keep the canonical `/ship [item-ref]` signature and need no plan
note; the flow is authoritative in `docs/workflow.md` and the owning prompts.

## Risks and mitigations

- **Signature-sweep breakage** (`tests/checks/96-signature-sweep.sh:44,286`
  pins `/ship [item-ref]` and the exact fix-landing usage substring) — likelihood
  medium / impact high. Mitigation: keep the canonical base signature on every
  designated position and append the plan mode after the required substring / in
  the command body only; run `bash tests/run.sh` after the prompt edits.
- **`/build` false-refusal when a merged plan branch is retained** — likelihood
  medium / impact medium. Mitigation: check default-branch presence first and
  refuse only when the plan is absent from default **and** a `plan/<ref>` branch
  exists; a retained merged branch is therefore not a block.
- **Historical items blocked by the gate** — likelihood medium / impact high.
  Mitigation: absence of both a default-branch plan and a plan branch proceeds
  with a note (AC10); no artifact or phase change is introduced.
- **`0003` reads the declaration differently from the parent cell** — likelihood
  medium / impact high. Mitigation: one authority statement of the home and the
  union rule in `docs/workflow.md`; `docs/artifact-conventions.md` references it;
  `0003` consumes and `0004` guards it.
- **The approval precondition is unverifiable offline** — likelihood certain /
  impact low. Mitigation: document it as a human/process gate (user decision 1)
  and have the gate verify the merge, which is the observable requirement of AC2;
  branch protection may enforce approval.
- **No-op detection misfires on a stale default branch** — likelihood low /
  impact low. Mitigation: report no-op only when the plan is present on the
  default branch and the plan artifacts are unchanged; otherwise publish a new
  commit rather than overwriting.
- **A revised plan is left unpublished** — likelihood medium / impact medium.
  Mitigation: `/plan` and the workflow state that any change to the intended
  surfaces or declared targets must be republished before development continues
  (AC11); the revision uses the same `plan/<ref>` branch and PR.

## Test strategy

This item changes documents and prompts only; it adds no runtime code and the
committed suite never reads live `work/**` (`tests/README.md:29`). The conflict
guards are child `0004-conflict-guards`, and the report is child
`0003-conflict-check`. Verification here is therefore content/consistency
inspection plus the existing suite as a regression gate; behavior that depends
on git/GitHub (publication, merge, gate) is verified by the documented
instructions and a manual dry-run, and is flagged as such.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | Read `docs/workflow.md` `## Plan publication`, `.opencode/agent/shipper.md`, `.opencode/command/ship.md`: a dedicated `plan/<ref>` branch and PR are created by `/ship plan`; `conventional-commits` names the branch. |
| AC2 | Read the `/build` gate in `docs/workflow.md`, `.opencode/agent/builder.md`, `.opencode/command/build.md`: an unmerged `plan/<ref>` refuses development. Manual dry-run: create a plan branch, confirm `/build` reports/refuses. |
| AC3 | Read `pr-workflow` plan template and `## Plan publication`: the merged plan artifacts are on the default branch and linked by PR path; public on GitHub. |
| AC4 | `rg -n 'conflicts-with' docs/artifact-conventions.md .opencode/agent/architect.md .opencode/command/plan.md` shows the `design.md` frontmatter value authored at `/plan`. |
| AC5 | Read the authority grammar reference: the list is a `ConflictTargetList` with the three shipped target kinds, comma separation, and `—`; no second grammar is stated on any surface. |
| AC6 | Read the frontmatter rule and `## Plan publication`: absence/`—` = no declared conflicts; no container/artifact required; no migration. |
| AC7 | Read `### Declared conflicts` union statement: child `design.md` value ∪ parent `Children` cell, mismatch reported. |
| AC8 | Read the authority: declaration is advisory; `READINESS` algorithm and derived-state table unchanged; `bash tests/run.sh` exits 0. |
| AC9 | Read `.opencode/agent/shipper.md` / `.opencode/command/ship.md`: plan mode is shipper-only, on explicit invocation; no other prompt instructs a git write. |
| AC10 | Read the gate: no plan branch and no default-branch plan proceeds; `bash tests/run.sh` exits 0 (no phase, count, or signature change). |
| AC11 | Read `/plan` Next and `## Plan publication`: a revised plan republished via the same `plan/<ref>` branch and PR before development continues. |
| AC12 | Read `### Declared conflicts`: a malformed/unresolved item value is reported by the later check, never dropped or auto-repaired. |
| AC13 | Cross-surface read (`rg -n` + read-through) across `docs/workflow.md`, `docs/artifact-conventions.md`, and the architect/shipper/builder prompts and plan/ship/build commands: consistent flow, one home, single `0001` grammar, consistent advisory statement; `bash tests/run.sh` exits 0. |

Manual/consistency checks are the observable form for the doc/behavior criteria;
`0004-conflict-guards` later converts the declaration grammar into fixture-based
committed guards.
