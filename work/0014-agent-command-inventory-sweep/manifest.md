---
feature: 0014-agent-command-inventory-sweep
phase: manifest
status: final
created: 2026-10-13
updated: 2026-10-13
---

# Manifest — Agent, command, and inventory surface sweep

## Initiative

This is **Roadmap 4** of the bootstrapped multi-roadmap plan that
`work/0011-recursive-bootstrap/roadmap.md` launched (its "Multi-roadmap sequence",
`work/0011-recursive-bootstrap/roadmap.md:125-149`). Roadmap 1
(`0011-recursive-bootstrap`) shipped the minimal recursive facility — model,
schema, writer, and readiness/derived state; Roadmap 2 (`0012-roadmap-deprecation`)
retired the special `roadmap` concept and made the generic **manifest** the sole
child-enumeration artifact; and Roadmap 3 (`0013-simultaneous-work-recursion`)
generalized allocation, duplicate detection, declared conflicts, merge integrity,
and plan publication to arbitrary depth. What remains of the original initiative
is the **surface sweep**: bring every agent, command, and skill prompt that still
carries the retired vocabulary or a two-level assumption onto the recursive model,
and reconcile the documented inventories and counts with the files on disk.

The recursive authority is already shipped and is the single source of truth:
`docs/workflow.md` → "The recursive lifecycle model", "Where decomposition is
authored and recorded", "Revising a decomposition", "Dependencies and readiness",
and "Derived state", together with `docs/artifact-conventions.md` → "Work item
references" and "`manifest.md` — the manifest of a decomposing node". This roadmap
does not redefine any of it; it removes the residual drift those focused roadmaps
left behind.

It serves **framework maintainers**, who must be able to read any agent or command
prompt and trust that it teaches the same recursive model the authority documents;
and **adopters**, who inherit every prompt verbatim and today would still be told
about "roadmap children", a `/roadmap revise` route that no longer exists, and a
container phase `roadmap` that is now `manifest`.

Concretely, the sweep targets the remaining retired vocabulary and gaps:
`product.md` still names a "parent roadmap", the deleted `/roadmap revise` route,
and target phase `roadmap`; the `status` agent and `/status` command still detect a
decomposing node by `roadmap.md` and render a `roadmap` phase; `shipper.md` and
`merge-conflict/SKILL.md` still say "roadmap graph"/"roadmap `Children`", and
`merge-conflict/SKILL.md:349` instructs a re-check "In every `roadmap.md`" — a
substantive bug, not only wording; fourteen prompts carry the item-ref boilerplate
"for a roadmap child"; and `tests/checks/96-signature-sweep.sh:250` still counts
"thirteen" commands after `0012` retired `/roadmap`. Each is a genuine single
feature, so this node is a **pure container** with no lifecycle artifacts of its
own.

Deliberately **out of scope**: the **committed recursive-workflow guards**
(Roadmap 5) — fixture-based guards pinning the recursive model, references,
allocation, readiness, status, and conflicts. This roadmap keeps the existing
committed fixtures green (`tests/checks/40-inventory.sh`,
`96-signature-sweep.sh`, `30-permissions.sh`, `50-instructions.sh`,
`60-default-agent.sh`, `95-split-guard.sh`) and adds no new fixture area.

## Assumptions

- **Framework-internal, prompt/doc/test only.** No installed runtime dependency,
  service, network access, or new toolchain is introduced. Surfaces in scope:
  `.opencode/agent/`, `.opencode/command/`, `.opencode/skill/`, `README.md`,
  `docs/customization.md`, and `tests/checks/`.
- **Roadmap 4 of the sequence.** Roadmaps 1–3 (`0011`, `0012`, `0013`) have
  shipped all of their children; this roadmap is the next stage specified at
  `work/0011-recursive-bootstrap/roadmap.md:140-142` and
  `work/0013-simultaneous-work-recursion/manifest.md:119-120`. Roadmap 5
  (committed guards) remains a separate, later invocation.
- **Extend, do not fork.** The recursive vocabulary, reference grammar, per-level
  allocation, manifest, readiness, and derived state shipped by `0011`–`0013` are
  the seed this roadmap applies. It defines no second model, vocabulary,
  reference grammar, conflict taxonomy, or finding code; each swept surface
  references the authority rather than restating it, per `AGENTS.md` → "The
  artifact contract".
- **Shared sweep vocabulary (fixed here; consumed by every child).** The retired
  terms map one-to-one onto the shipped recursive terms, and every child applies
  the same mapping so the surfaces cannot drift apart:
  - the item-ref boilerplate "`NNNN-slug` for a standalone item, or
    `NNNN-slug/MMMM-slug` for a roadmap child" becomes the canonical recursive
    form — a canonical reference, `NNNN-slug` for a standalone item or a nested
    `NNNN-slug/MMMM-slug` at any depth — per `docs/artifact-conventions.md` →
    "Work item references", stated once and identically in every prompt that
    accepts an item-ref;
  - "parent roadmap" becomes the parent's **manifest** / the planning step's
    decomposition;
  - the `/roadmap revise <parent-ref>` route becomes the `/plan <item-ref>`
    revise route (`docs/workflow.md` → "Revising a decomposition");
  - target phase `roadmap` and container phase `roadmap` become `manifest`;
  - `work/<parent-ref>/roadmap.md` becomes `work/<parent-ref>/manifest.md`;
  - "roadmap graph" and "roadmap `Children`" become the manifest's dependency
    graph and the `Children` table.
  A deliberate **legacy-alias mention** of `roadmap.md` — the deprecated concrete
  spelling retained for backward compatibility
  (`docs/artifact-conventions.md:124-137`) — is sanctioned and may remain where it
  is clearly labelled as the legacy alias; a bare `roadmap` used as if current is
  stale and is swept.
- **Each child is genuinely one feature.** A surface family (the lifecycle
  agents, the supporting agents, the commands, the skills, or the
  inventories/doctor) is specifiable, buildable, and reviewable on its own, and
  nothing here is a sub-initiative. If a child still proves too large at `/spec`,
  the sanctioned remedy is `/plan 0014-agent-command-inventory-sweep` to re-slice
  at the same level.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every
  step. The suite is read-only and never reads live `work/**`, so the sweep is
  validated against the live prompt surfaces and the fixtures; committed
  recursive fixtures are Roadmap 5.
- **Shipped work is context.** Every `0011`–`0013` child and every other shipped
  item is out of scope for rewriting; the sweep extends their decisions and does
  not reopen them.
- **No new surfaces; counts are stable.** The sweep adds, renames, and retires no
  agent, command, or skill, so the README inventories stay 13 agents / 12
  commands / 11 skills and `40-inventory.sh` stays green.
- **Child numbers are local** to this parent and independent of the top-level
  sequence and of every other node.
- **The user owns the policy forks.** Whether the sanctioned legacy-`roadmap.md`
  alias mentions are retained anywhere in the prompts, whether the
  `conventional-commits` illustrative reference is renamed, and whether
  `docs/customization.md` gains a recursive-authoring note are user decisions
  owned by the relevant children, not decided here.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-lifecycle-agent-sweep | Lifecycle-agent recursive sweep | Sweep the six lifecycle/phase agent prompts — `product`, `architect`, `builder`, `tester`, `reviewer`, `shipper` — onto the recursive model. Apply the shared mapping: `product.md`'s "parent roadmap" and its `/roadmap revise <parent-ref>` finding route become the parent manifest and the `/plan <item-ref>` revise route, target phase `roadmap` becomes `manifest`, and `work/<parent-ref>/roadmap.md` becomes `manifest.md` (`product.md:77-78,116-124`); `shipper.md`'s "roadmap graph" and "roadmap `Children`" become the manifest's dependency graph and `Children` table (`shipper.md:132,202,376`). Refresh the item-ref boilerplate in all six files, and repair any prompt that reads `work/<item-ref>/` without naming the manifest, nested children, or canonical reference (`tester.md`, `reviewer.md`). Preserve each prompt's frontmatter, permission block, handoff block, and phase behavior; change prose only. Evidence: `.opencode/agent/{product,architect,builder,tester,reviewer,shipper}.md`; `docs/workflow.md` "The recursive lifecycle model", "Where decomposition is authored and recorded", "Revising a decomposition"; `docs/artifact-conventions.md` "Work item references". Excludes the supporting agents (`0002`), the commands (`0003`), the skills (`0004`), and the inventories (`0005`). | — | — | 0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep |
| 0002-supporting-agent-sweep | Supporting-agent recursive sweep | Sweep the six supporting agent prompts — `status`, `scout`, `scribe`, `ask`, `bootstrap`, `visual` — onto the recursive model. `status.md` is the substantive one: detect a decomposing node and derive its phase from its **manifest** (`manifest.md`) rather than `roadmap.md`; map the container phase `roadmap` to `manifest` and pair the `stale: roadmap` mention with `stale: manifest`; name the manifest template in `docs/artifact-conventions.md`; and refresh the rendered output example so its tree shows the `manifest` phase and manifest vocabulary rather than a `roadmap` phase (`status.md:48-58,90,104,120,128,244,265,296-313,327,337,340`). Refresh the item-ref boilerplate where present and add canonical-reference coverage where a prompt reads `work/<item-ref>/` without it. Preserve each prompt's frontmatter, permission block, and handoff block; change prose only. Excludes `.opencode/agent/doctor.md` (owned by `0005`). Evidence: `.opencode/agent/{status,scout,scribe,ask,bootstrap,visual}.md`; `docs/workflow.md` "Derived state", "Status reporting", "Dependencies and readiness"; `docs/artifact-conventions.md` "`manifest.md`". Excludes `0001`, `0003`, `0004`, `0005`. | — | — | 0014-agent-command-inventory-sweep/0002-supporting-agent-sweep |
| 0003-command-sweep | Command-surface recursive sweep | Sweep the command prompts — `spec`, `plan`, `build`, `test`, `review`, `ship`, `fix`, `status`, `conflicts`, `bootstrap`, `visual` — onto the recursive model, consuming the agent sweep's wording so a command and its agent never diverge. Refresh the item-ref boilerplate ("for a roadmap child" → the canonical recursive form); fix `command/status.md`'s decomposing-node detection to `manifest.md`, its container phase to `manifest`, and its `stale: roadmap` mention to pair with `stale: manifest` (`command/status.md:15,19-20,28`); fix `command/spec.md`'s nested-child allocation wording (`command/spec.md:23`); and fix `command/ship.md`'s "roadmap dependency graph" (`command/ship.md:39`). Preserve every command's `Usage:` signature and `agent:` frontmatter; the sweep changes prose only and keeps `tests/checks/96-signature-sweep.sh` green. Excludes `.opencode/command/doctor.md` (owned by `0005`). Evidence: `.opencode/command/*.md`; the paired agent prompts; `tests/checks/96-signature-sweep.sh`. Excludes `0001`, `0002`, `0004`, `0005`. | 0001-lifecycle-agent-sweep, 0002-supporting-agent-sweep | — | 0014-agent-command-inventory-sweep/0003-command-sweep |
| 0004-skill-sweep | Skill recursive sweep | Sweep the skill surfaces — `.opencode/skill/**/SKILL.md` — onto the recursive model. `merge-conflict/SKILL.md` is the substantive one: rename the "Roadmap graph faults" heading and its `roadmap` labels and rows to manifest terms (`merge-conflict/SKILL.md:80-81,121,124,141,220,258,333`) and fix the substantive instruction "In every `roadmap.md`" (`merge-conflict/SKILL.md:349`) to every manifest at any depth. Confirm `workflow-lifecycle/SKILL.md` — the skill this roadmap's charter names — is fully recursive and correct any residual, keeping its routing block canonical for `tests/checks/96-signature-sweep.sh`. Optionally replace `conventional-commits/SKILL.md`'s illustrative retired reference (`0002-agentic-roadmaps/0001-roadmap-model`, `conventional-commits/SKILL.md:80,84-85,89`) with a non-retired example. Preserve the canonical finding codes and classes. Excludes the prompts (`0001`–`0003`) and the inventories (`0005`). Evidence: `.opencode/skill/{merge-conflict,workflow-lifecycle,conventional-commits}/SKILL.md`; `.opencode/agent/status.md`; `tests/checks/96-signature-sweep.sh`. | — | — | 0014-agent-command-inventory-sweep/0004-skill-sweep |
| 0005-inventory-and-doctor-sweep | Inventory, count, and doctor reconciliation | Reconcile the documented inventories, counts, and the `doctor` diagnostic with the recursive model and with disk. Update the `doctor` agent (`.opencode/agent/doctor.md`) and `/doctor` command (`.opencode/command/doctor.md`) so their read-only inventory/count/permission checks remain correct against the recursive surfaces and their prose does not contradict the recursive manifest; fix the stale count in `tests/checks/96-signature-sweep.sh:250` ("thirteen" commands → twelve); and re-verify the `README.md` Layout counts and Agents/Commands/Skills tables against disk (13/12/11) together with the `docs/customization.md` extension guide. Confirm `README.md`, `AGENTS.md`, and `template/AGENTS.md` stay in recursive agreement and `bash tests/run.sh` passes. Excludes the content sweeps (`0001`–`0004`). Evidence: `README.md:192-293`; `.opencode/agent/doctor.md`; `.opencode/command/doctor.md`; `docs/customization.md`; `tests/checks/{40-inventory,96-signature-sweep,30-permissions,50-instructions,60-default-agent,95-split-guard}.sh`; `tests/README.md`. | 0001-lifecycle-agent-sweep, 0002-supporting-agent-sweep, 0003-command-sweep, 0004-skill-sweep | — | 0014-agent-command-inventory-sweep/0005-inventory-and-doctor-sweep |

## Sequencing

1. 0001-lifecycle-agent-sweep
2. 0002-supporting-agent-sweep
3. 0003-command-sweep
4. 0004-skill-sweep
5. 0005-inventory-and-doctor-sweep

`0001-lifecycle-agent-sweep`, `0002-supporting-agent-sweep`, and
`0004-skill-sweep` touch disjoint file sets (the lifecycle agents, the supporting
agents, and the skills) and have no unmet prerequisite; they may proceed in
parallel. `0003-command-sweep` consumes both agent sweeps because each command
prompt mirrors its agent prompt (`/spec`↔`product`, `/plan`↔`architect`,
`/build`↔`builder`, `/test`↔`tester`, `/review`↔`reviewer`, `/ship`↔`shipper`,
`/status` and `/conflicts`↔`status`), so the agent wording settles first and the
command cannot diverge from it. `0005-inventory-and-doctor-sweep` reconciles the
documented inventories and re-verifies the suite against the settled swept
surfaces, so it follows all four sweeps. The stored graph is acyclic:
`{0001, 0002}` → `0003` → `0005`, with `0004` → `0005`.

### Multi-roadmap sequence

This is **Roadmap 4**. The successor roadmap is authored by a separate planning
invocation after the preceding stage ships:

1. **Roadmap 1 — `0011-recursive-bootstrap` (shipped).** The minimal recursive
   facility: model, schema, writer, readiness/status.
2. **Roadmap 2 — `0012-roadmap-deprecation` (shipped).** Retire `/roadmap` and its
   agent; make the generic manifest the sole enumeration source.
3. **Roadmap 3 — `0013-simultaneous-work-recursion` (shipped).** Allocation,
   duplicate detection, declared conflicts, merge integrity, renumbering, and
   parallel plan publication under recursion.
4. **Roadmap 4 — `0014-agent-command-inventory-sweep` (this).** Sweep every agent,
   command, and skill prompt to the recursive model and reconcile the documented
   inventories and counts.
5. **Roadmap 5 — Committed recursive-workflow guards.** Fixture-based guards
   pinning the recursive model, references, allocation, readiness, status, and
   conflicts.

Cross-roadmap ordering is **not** encoded as a dependency (dependencies are
sibling-only within a node); it is recorded here as prose and re-derived when the
successor is authored.

## Open issues

- **Single-feature check.** The initiative is genuinely multi-feature — the
  lifecycle-agent sweep, the supporting-agent sweep, the command sweep, the skill
  sweep, and the inventory/doctor reconciliation — so a decomposing node is the
  right vehicle rather than a standalone `/spec`.
- **Re-homes a withdrawn child; no number reuse.** This is the scope of
  `0010-recursive-plan-cycle/0007-agent-surface-update`, withdrawn on 2026-10-12
  and preserved as a `.gitkeep`-only directory
  (`work/0010-recursive-plan-cycle/roadmap.md:197-203`). Its directory and spent
  local number `0007` are **not** reused, and `0010` remains a superseded
  container; this roadmap is a fresh top-level node.
- **No duplicate node.** Recon of `work/` found thirteen existing top-level items
  (`0001`–`0013`) before this node; the sequence's predecessor is
  `0013-simultaneous-work-recursion`. The nearest shipped scope is
  `0012/0002-command-retirement`, which retired `/roadmap` and reconciled only the
  surfaces it deleted; no node performs the remaining agent, command, skill, and
  inventory sweep. Recorded so the choice of a new top-level node rather than a
  nested child is explicit.
- **Boundary with Roadmap 5 (committed guards).** Fixture-based committed guards
  pinning the recursive workflow are Roadmap 5. This roadmap keeps the existing
  committed fixtures green (`tests/checks/40-inventory.sh`,
  `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `87-backtrack-guards.sh`,
  `96-signature-sweep.sh`) but adds no new fixture area of its own. The boundary is
  recorded so scope is not silently widened.
- **No shared edited surface; advisory conflicts are `—`.** Unlike the preceding
  roadmaps, whose rows all edited `docs/workflow.md`, these five rows edit
  disjoint file sets, so every `conflicts-with` cell is `—`. The shared recursive
  authority docs (`docs/workflow.md`, `docs/artifact-conventions.md`) are
  **read** references and are not edited by any child, so declaring them would
  produce a false `TEXTUAL-CONFLICT`. Recorded so the empty declared-conflict set
  is intentional rather than an omission.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`{0001,0002}`→`0003`→`0005`; `0004`→`0005`); no `CYCLIC-DEP` is expected.
  Recorded because the planning step never stores a cycle.
- **Unresolved user decision — legacy-alias mentions.** Whether the prompts keep
  the sanctioned legacy-`roadmap.md` alias mentions (`status.md`, `plan.md`,
  `architect.md`) or drop them entirely, and whether the `stale: roadmap` mention
  is retained or removed once paired with `stale: manifest`, is owned by the
  relevant children and materially changes their diffs.
- **Unresolved user decision — illustrative references.** Whether
  `conventional-commits/SKILL.md` renames its illustrative retired item reference
  and whether `docs/customization.md` gains a recursive-authoring note are owned
  by `0004-skill-sweep` and `0005-inventory-and-doctor-sweep` respectively.
- **Unresolved user decision — doctor recursive coverage.** Whether the `doctor`
  diagnostic gains recursive-model awareness (manifest, nested children) or stays
  a pure inventory/count/permission checker is owned by
  `0005-inventory-and-doctor-sweep`; its function is drift detection, so a
  recursive-tree readiness view would duplicate `/status`.
- **One create call, one parent.** This node was authored as a single top-level
  decomposing node (the next top-level `0014`); Roadmap 5 remains a separate later
  invocation. Recorded so the staging is explicit rather than silently absent.
