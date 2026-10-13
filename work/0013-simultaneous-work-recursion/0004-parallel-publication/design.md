---
feature: 0013-simultaneous-work-recursion/0004-parallel-publication
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
conflicts-with: "—"
---

# Design — Parallel plan publication under recursion

## Summary

Replace the non-injective branch flattening (`/` → `-`) with one collision-free
reversible rule: a canonical reference's `/`-separated segments are joined with
`+`, a character the reference alphabet (`[0-9]{4}-[a-z0-9-]+`) can never contain.
The rule is defined once in the `conventional-commits` skill and referenced — not
restated — by every surface that names a branch, for both the `plan/<ref>` branch
and the final ship branch. Plan publication and the `/build` plan gate are then
extended to admit a decomposing node's **manifest-only** plan, and the gate derives
its branch name through the same rule.

## Approach

### 1. One branch-flattening rule, defined once

`flatten(ref)` replaces each segment-separating `/` of a canonical reference with
`+`. Because a segment is `[0-9]{4}-[a-z0-9-]+` and therefore never contains `+`,
the `+` is a reserved boundary: `ref.split("/").join("+")` and
`flat.split("+")` are exact inverses, so two distinct references at any depth
always flatten to two distinct strings (AC1, AC2, AC3, AC10). A single-segment
reference is unchanged by the rule.

The **same** flattened token produces both branch names; only the prefix differs:
`plan/<flatten(ref)>` for the pre-development plan branch and
`<type>/<flatten(ref)>` for the final ship branch (AC2). Examples:

| Canonical reference | `flatten(ref)` |
| ------------------- | -------------- |
| `0001-add-dark-mode` | `0001-add-dark-mode` |
| `0013-simultaneous-work-recursion/0004-parallel-publication` | `0013-simultaneous-work-recursion+0004-parallel-publication` |
| `0001-a/0002-b/0003-c` | `0001-a+0002-b+0003-c` |

The classic collision (AC3) is resolved structurally: the nested child
`0013-simultaneous-work-recursion/0004-parallel-publication` flattens to
`...recursion+0004-parallel-publication`, while a distinct top-level item literally
named `0013-simultaneous-work-recursion-0004-parallel-publication` keeps its own
hyphenated name — the two differ.

The rule is stated **once** in `.opencode/skill/conventional-commits/SKILL.md`
→ "Branch naming" (the spec's designated home). Every other surface —
`docs/workflow.md`, `.opencode/agent/shipper.md`, `.opencode/command/ship.md`, the
gate mirrors `.opencode/agent/builder.md` / `.opencode/command/build.md`, and
`CONTRIBUTING.md` — references it and never forks it (AC12). The current
`/` → `-` sentences in those surfaces are replaced by the reference; where an
example is shown it uses the `+` form.

### 2. Manifest-only plan publication

Plan publication's meaning of "plan" already includes a decomposing node's
manifest in `docs/workflow.md`, but the operative shipper precondition and the
plain-language artifact list do not. The shipper's plan-mode preconditions gain
the manifest branch — a plan is publishable when the item has completed `/plan`,
i.e. `spec.md` + `design.md` exist **or** `manifest.md` exists (AC4). Its plan
commit scope is stated where the commit happens: the node's own plan state under
`work/<item-ref>/` — for a decomposing node the manifest, the node's own phase
artifacts when present, and its **immediate** child `.gitkeep` reservations, and
never a child's own in-flight phase artifacts (AC5); a nested child publishes only
its own plan state and touches no parent or sibling (AC6). No new artifact, `phase`
value, or state file is introduced (AC14).

### 3. The `/build` gate recognizes a manifest-only plan

The `plan_gate(item_ref)` algorithm in `docs/workflow.md` → "The `/build` plan
gate" derives its branch with `ref = flatten(item_ref)` (referencing the single
rule, never the ambiguous old form) and treats a plan as published when the default
branch holds `work/<item_ref>/design.md` **or** `work/<item_ref>/manifest.md`
(AC7, AC9). The content-aware unmerged/refuse behavior is unchanged (AC8): a
`plan/<ref>` branch whose plan artifacts differ from the default branch still
refuses, an advertised-but-unresolvable ref still refuses, and an unreachable
`origin` still degrades to the best-effort result.

The gate mirrors in `builder.md` / `build.md` are kept in sync in this change:
their read lists admit a decomposing node's `manifest.md`, and their gate prose
names the collision-free plan branch and recognizes a manifest-only plan as
published (AC7, AC9, AC12).

### 4. No migration

Already-merged plans are read from the default branch and stay valid. A
pre-existing **unmerged** branch under the superseded `/` → `-` joined name is
simply **not recognized** — the gate derives only the collision-free name — so it
neither blocks development nor is read as a publication; it falls to the existing
"no publication recorded" case (AC11). Historical and shipped items are not
rewritten.

### Declared conflicts

The child's `design.md` `conflicts-with` value is `—`. The parent manifest's
`Children` row for this child already declares the shared authority surfaces
(`docs/workflow.md`, `.opencode/agent/shipper.md`), so the effective declared set
is that one-sided record; declaring a divergent list here would only raise a
`DRIFT-FACT` discrepancy. The declaration stays advisory and changes no readiness
edge (AC14).

## Alternatives considered

- **Hierarchical branch names (`plan/NNNN-slug/MMMM-slug`), no flattening.**
  Pros: trivially injective and reversible with no reserved character. Cons:
  git's files ref backend cannot store a ref and a ref whose name is its prefix
  directory at once (`refs/heads/feat/0013-x` and `refs/heads/feat/0013-x/0004-y`
  are a directory/file conflict), so a node's ship branch and its child's would
  be unable to coexist and the framework nests to arbitrary depth. **Rejected**:
  the exact ref-store collision the flattening exists to avoid.
- **Detect-and-refuse the collision, keep `/` → `-`.** Pros: no rename of the
  existing convention. Cons: it leaves the branch name ambiguous and cannot let
  two concurrent publications both proceed — the spec's user decision chose a
  collision-free reversible encoding over detection. **Rejected** by that
  decision.
- **Percent-encoding (`/` → `%2F`).** Pros: reversible, legal in git refs, no new
  reserved character to document. Cons: noisier, and `%` is frequently escaped or
  re-decoded by URLs and tooling. **Rejected** in favor of a single readable
  reserved separator.

## Interfaces and data model

- **`flatten(ref)`** — the single branch-name rule.
  `flatten(ref) = ref.split("/").join("+")`; inverse `flat.split("+")`; total on
  the canonical reference grammar; injective at every depth. No data model or
  schema changes; docs and prompts only.
- **Plan branch name** — `"plan/" + flatten(ref)`.
- **Ship branch name** — `"<type>/" + flatten(ref)` (`feat/`, `fix/`, `docs/`, …).
- **Plan state (content unchanged; manifest admitted)** — a single-feature item's
  plan is `{spec.md, design.md, tasks.md when present}`; a decomposing node's plan
  is `{manifest.md} ∪ {own spec.md/design.md/tasks.md when present} ∪ {immediate
  child `<MMMM-slug>/.gitkeep` reservations}`. No child in-flight artifact is
  included.
- **Gate** — `ref = flatten(item_ref)`;
  `published = <default_ref> has work/<item_ref>/design.md or
  work/<item_ref>/manifest.md`.

## Affected areas

- `.opencode/skill/conventional-commits/SKILL.md` — the single home of the rule
  (lines ~52–78).
- `docs/workflow.md` — "Plan publication" (**Branch** bullet and a no-migration
  note) and "The `/build` plan gate" (`plan_gate` algorithm).
- `.opencode/agent/shipper.md` — plan-mode inputs, precondition, branch step, and
  staging scope; the work-item-mode branch step.
- `.opencode/command/ship.md` — the same plan-mode and work-item-mode mirrors.
- `.opencode/agent/builder.md`, `.opencode/command/build.md` — the gate mirrors
  and the manifest input.
- `.opencode/skill/pr-workflow/SKILL.md` — the plan PR template's artifact list.
- `CONTRIBUTING.md` — the nested-child branch example.

Not changed: `docs/artifact-conventions.md` and `AGENTS.md` (neither names the
flattening), the derived-state table, the merge-time conflict contract, the
`conflicts-with` grammar, and `tests/**` (no new fixture area — Roadmap 5).

## Risks and mitigations

- **A surface still forks or restates the old `/` → `-` rule.** Likelihood:
  medium / impact: high (AC12). Mitigation: define the rule in exactly one place,
  reference it everywhere else, and add a cross-surface grep + read-through task
  before the suite run.
- **A hosting provider rejects `+` in a ref.** Likelihood: low / impact: medium.
  Mitigation: `+` is legal under `git check-ref-format` and GitHub's documented
  branch rules; the separator appears in one rule, so any host objection is a
  one-line change (`_` or `.`) in that single home.
- **Historical item `verify-tests.sh` scripts assert the superseded
  `NNNN-slug-MMMM-slug` literal** (`work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh`,
  `work/0002-agentic-roadmaps/verify-tests.sh`). Likelihood: medium / impact: low.
  Mitigation: those items are shipped and out of scope (non-goal: no historical
  migration); the canonical suite `bash tests/run.sh` never reads `work/**`
  (`tests/README.md`), so AC15 is unaffected. Recorded as residual risk, not
  edited.
- **Gate regression for historical/pre-flow items.** Likelihood: low / impact:
  high. Mitigation: the "no publication recorded → proceed (note it)" case and the
  default-branch read are preserved, so an old-format branch or a pre-flow item
  neither blocks nor errors (AC11).
- **Scope creep into the Roadmap 4 surface sweep.** Likelihood: medium / impact:
  medium. Mitigation: touch only the surfaces plan publication names; no agent,
  command, or inventory sweep.

## Test strategy

The committed suite is read-only and never reads live `work/**`, and no new
committed checker or fixture is added (Roadmap 5). Verification is therefore
cross-surface read-through, a manual encoding check, and the existing suite.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1, AC3, AC10 | Manual: evaluate `flatten` on the collision pair and on depth-2/3 and sibling references; confirm distinct plan and ship names. |
| AC2 | Manual: encode/decode round-trip at depth 2 and 3; read that both prefixes share the one rule. |
| AC4, AC5, AC6 | Read: shipper/ship plan-mode precondition and staging scope. |
| AC7, AC8, AC9 | Read: the `plan_gate` algorithm and the builder/build mirrors. |
| AC11 | Read: the no-migration note and gate case 3. |
| AC12 | Manual: cross-surface grep + read showing one definition and references elsewhere. |
| AC13 | Read: shipper plan-mode rules (no `ship.md`, no reconcile, no ship branch) unchanged. |
| AC14 | Read: advisory-conflict and no-new-readiness/phase/state language unchanged. |
| AC15 | `bash tests/run.sh` → exit 0; grep confirms the suite reads no live `work/**`. |
