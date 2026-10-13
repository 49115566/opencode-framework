---
feature: 0012-roadmap-deprecation/0002-command-retirement
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
conflicts-with: "docs/workflow.md, README.md, AGENTS.md, template/AGENTS.md"
parent: 0012-roadmap-deprecation
---

# Design — Retire the `/roadmap` command and agent; `/plan` becomes the sole recursive writer

## Summary

Delete the retired `.opencode/command/roadmap.md` and `.opencode/agent/roadmap.md`,
move the brand-new-top-level-node **create mode** into the planning step
(`/plan`, `architect`) under the dual-form canonical signature
**`/plan <item-ref or initiative>`**, and reconcile every in-scope documented
surface to the manifest vocabulary fixed by `0001` (`manifest.md`,
`phase: manifest`, `stale: manifest`, "Revising a decomposition"). This is a
prompt/document/test change only: it adds no command, agent, skill, runtime
dependency, or state model, and edits no read-side prose, fixture, or committed
`work/` artifact.

## Approach

The change has three parts, applied to the surfaces the spec names.

1. **Remove the retired pair (AC1, AC2).** Delete `.opencode/command/roadmap.md`
   and `.opencode/agent/roadmap.md`. The shipped command set loses its only
   `agent:` reference to the retired `roadmap` agent
   (`.opencode/command/roadmap.md:3`), and the shipped agent set loses one
   prompt, so the on-disk counts become 13 agents and 12 commands (11 skills
   unchanged).

2. **Move the create mode and modernize the writer (AC3, AC5, AC6).** The
   planning step is already the recursive writer for the author and revise paths
   (`docs/workflow.md` → "Where decomposition is authored and recorded" and
   "Revising a decomposition"), but the **create mode** the alias owned lives
   only in the deleted command/agent. Re-home it, unchanged in behavior, into
   `.opencode/command/plan.md` and `.opencode/agent/architect.md`:
   - when `$ARGUMENTS` is empty → ask which item to plan / initiative to create;
   - when `$ARGUMENTS` resolves to an existing `work/<item-ref>/` → the
     existing-item path (single-feature design, or author/revise of that node's
     decomposition);
   - otherwise → **create mode**: reconnoitre `work/` so the request neither
     collides with nor duplicates an item, allocate the next top-level `NNNN`
     (greatest 4-digit prefix ever committed under `work/` plus one) and a
     kebab-case slug, author `work/<NNNN-slug>/manifest.md` carrying
     `phase: manifest`, and reserve each enumerated child as
     `work/<NNNN-slug>/<MMMM-slug>/.gitkeep` — writing no child phase artifact.
     A request that is really one feature recommends `/spec <feature>` and
     creates nothing.

   This closes the spec's deferred question (`spec.md:254-257`) about a
   non-resolving, item-ref-shaped argument: a token that resolves to no
   `work/<item-ref>/` **is not an existing item and takes the create path**, so a
   typo cannot silently edit anything. To keep a typo from silently creating a
   duplicate, the create path reconnoitres `work/` (titles and specs) and, on a
   likely duplicate, surfaces it under `## Open issues` rather than creating a
   second node; the shaped number is not reused (the next greatest-ever `NNNN` is
   allocated), and no confirmation gate is added — the rule is stated in the two
   writer prompts. A create-path argument that matches no likely duplicate
   proceeds autonomously, exactly as the retired alias did.

   In the same pass the writer's own prose adopts the `0001` spelling — the
   author/revise paths produce and revise `manifest.md` / `phase: manifest`, mark
   affected unshipped children `stale: manifest`, and name
   `### Revising a decomposition` rather than the retired "Revising a roadmap".

3. **Reconcile every named surface (AC4, AC7–AC11), then verify (AC12–AC14).**
   Bring the canonical `/plan` signature and the `/roadmap` removal into
   agreement across `README.md`, `AGENTS.md`, `template/AGENTS.md`, the
   `workflow-lifecycle` skill, `docs/workflow.md`'s command-alias prose and
   Design-phase heading, and the `96-signature-sweep.sh` registry; then run the
   whole suite. The `0001` deprecation contract — the modern manifest spelling
   and the recognized legacy `roadmap.md` / `phase: roadmap` **artifact** alias —
   is consumed as fixed and is not restated or changed.

## Alternatives considered

- **Keep a thin `/roadmap` redirect (a command/agent that forwards to `/plan`).**
  Pros: no inventory removal and no muscle-memory break. Cons: the user resolved
  the command/agent fate as **deletion, no redirect** (spec Open questions;
  `spec.md:245-247`), and a retained command/agent pair keeps the retired concept
  alive in exactly the inventories, signature registry, and always-loaded
  contracts this item exists to reconcile — and would still need the create mode
  in `/plan`. Rejected on the user decision and AC1/AC2.
- **Keep the canonical `/plan` signature single-form and document the create mode
  as an undocumented extra form.** Pros: smallest signature diff. Cons: the spec
  fixes the canonical signature as the dual form `/plan <item-ref or initiative>`
  (AC4) and the registry must assert it (AC11); a second, unasserted form would
  fork the signature and let drift return silently. Rejected.
- **Update only the surfaces the spec lists by name and leave the other
  `/plan`-signature occurrences the guard scans.** This is not actually
  available: `96-signature-sweep.sh` extracts *every* `/plan` signature in the
  skill routing block and the README mermaid labels and compares each to the
  canonical (`.opencode/.../96-signature-sweep.sh:150-170,252-262`), so a
  partially-updated block fails. The design therefore updates every scanned
  occurrence. Not an option.
- **Migrate the seven existing parents and the `roadmap.md`-loading fixtures
  here.** Pros: one spelling everywhere. Cons: that is `0003-parent-migration`'s
  scope, and AC14 fences it; touching the fixtures would also change `80`/`85`/
  `87`. Rejected.
- **Chosen:** the three-part change above — deletion + create-mode re-home +
  surface reconciliation, reusing the `0001` contract unchanged.

## Interfaces and data model

This item's "interface" is the framework's own command/doc/test surfaces.

- **Canonical signature registry** (`tests/checks/96-signature-sweep.sh:37-52`):
  the `/plan` entry becomes `/plan <item-ref or initiative>`; the `/roadmap`
  entry is deleted.
- **Required sets and the usage-string loop**
  (`tests/checks/96-signature-sweep.sh:226,228,230,270`): `/roadmap` is removed
  from `AGENTS_REQUIRED`, `README_REQUIRED`, `SKILL_REQUIRED`, and
  `ALL_COMMANDS`; the `/plan` canonical value is the dual form of AC4.
- **Command usage string** (the per-command usage loop at
  `tests/checks/96-signature-sweep.sh:271-281`): `.opencode/command/plan.md`'s
  `description:` line states `Usage: /plan <item-ref or initiative>`.
- **Architect create-mode algorithm** (new prose in `.opencode/agent/architect.md`
  and referenced from `.opencode/command/plan.md`):

  ```
  plan(argument):
    if argument is empty            -> ask, create nothing
    if work/<argument>/ exists      -> existing-item path
        (spec.md present            -> single-feature design)
        (manifest.md present, or no own spec.md -> author/revise decomposition)
    else                            -> create mode
        recon work/ (no collide / duplicate)
        allocate next top-level NNNN = greatest 4-digit prefix ever
          committed under work/ + 1
        choose 2-4 word kebab-case slug
        write work/<NNNN-slug>/manifest.md (phase: manifest)
        reserve work/<NNNN-slug>/<MMMM-slug>/.gitkeep per child
        write no child phase artifact
        if the request is one feature -> recommend /spec, create nothing
  ```

  This is the retired alias's create rule with the modern spelling; it is stated
  in the two writer prompts, not as a second algorithm in `docs/workflow.md`.
- **Vocabulary** (consumed from `0001`, not redefined): `manifest.md`,
  `phase: manifest`, `stale: manifest`, `### Revising a decomposition`. The
  legacy `roadmap.md` / `phase: roadmap` alias stays documented as a recognized
  deprecated **artifact** alias (AC7).
- **README inventory**: Layout counts become 13 agents / 12 commands / 11 skills;
  the Commands table loses its `/roadmap` row and its `/plan` row states the dual
  form; the Agents table loses its `roadmap` row.
- **Byte-parity twin**: `AGENTS.md` and `template/AGENTS.md` receive identical
  edits outside `## Project profile` (`95-split-guard.sh:288-315`).

No API, schema, migration, or runtime interface changes; the only consumers are
the framework's own prompts, documents, and guards, which read the surfaces by
name.

## Affected areas

Removed:

- `.opencode/command/roadmap.md` (whole file).
- `.opencode/agent/roadmap.md` (whole file).

Writer prompts:

- `.opencode/command/plan.md` — `description:` usage string (`:2`); body gains the
  create-mode branch and adopts `manifest` vocabulary / "Revising a
  decomposition" (`:18,31-45`).
- `.opencode/agent/architect.md` — mission/process/handoff manifest spelling
  (`:37,44,80,101,125-136`), quality-bar spelling (`:175-188`), rules
  (`:204,210,216-218`), handoff (`:240`), plus the new create-mode process step.

Authority document (this item's in-scope parts only):

- `docs/workflow.md` — command-alias prose (`:72-75`, `:193-194`, `:353-360`,
  `:430`, `:1346-1351`) and the Design-phase heading signature (`:463`). The
  legacy `roadmap.md` / `phase: roadmap` artifact-alias notes (`:53-57`, `:133`,
  `:190-191`, `:1225`, `:1254`, `:1297`, `:1470`) are retained.

Inventories and contracts:

- `README.md` — multi-feature prose (`:183-189`), Commands table (`:196`,`:203`),
  Agents table (`:215`), lifecycle mermaid `/plan` label (`:140`), Layout counts
  (`:273-274`).
- `AGENTS.md` — Design row (`:36`), supporting commands (`:47`), supporting agents
  (`:51`), artifact-contract prose (`:67-78`).
- `template/AGENTS.md` — the same edits at `:38`, `:49`, `:53`, `:69-80`
  (byte-identical outside the Project profile).
- `.opencode/skill/workflow-lifecycle/SKILL.md` — decomposing-node paragraph
  (`:22-26`), routing block (`:31,33,40,42,46,48`), derived-state view
  (`:60,63-66,88`).

Guard:

- `tests/checks/96-signature-sweep.sh` — registry (`:40,47`), required sets
  (`:226,228,230`), `ALL_COMMANDS` (`:270`).

Boundary (not touched, per AC14): `status`/`product`/`reviewer`/`visual`/
`builder`/`tester`/`shipper`/`scribe` prompts and their commands, the
`merge-conflict` skill, `docs/artifact-conventions.md`, the `roadmap.md`-loading
fixtures and `80`/`85`/`87` guards, `tests/README.md`, `CHANGELOG.md`,
`CONTRIBUTING.md`, and every committed `work/` artifact.

## Risks and mitigations

- **The guard scans signature positions AC4 does not name.** `96` extracts every
  `/plan` signature in the skill routing block (`:150-170`) and the README
  mermaid labels (`:138-148`), so leaving any of them single-form fails AC22.
  — Likelihood high / impact high. Mitigation: update every `/plan` signature
  occurrence in the skill routing block and the README mermaid label to the dual
  form; run `FRAMEWORK_TEST_AREAS=96-signature-sweep bash tests/run.sh` at T7 and
  the full suite at T8.
- **`AGENTS.md` / `template/AGENTS.md` drift apart.** Any shared-body edit applied
  to only one copy fails `95-split-guard.sh:288-315`. — Likelihood medium /
  impact high. Mitigation: apply the identical edit to both files in one task;
  `FRAMEWORK_TEST_AREAS=95-split-guard bash tests/run.sh`.
- **Inventory counts or tables drift from disk.** `40-inventory.sh` asserts
  README Layout counts and table membership against disk
  (`40-inventory.sh:40-42,99-100`), and `30-permissions.sh` asserts the Agents
  table against declarations. — Likelihood medium / impact medium. Mitigation:
  change the counts and both table rows in the same task as the file removals
  land; run `FRAMEWORK_TEST_AREAS='40-inventory,30-permissions' bash tests/run.sh`.
- **Scope creep into the read-side, fixtures, or committed artifacts.** The
  retirement tempts edits to `status`/`product`/`merge-conflict` and to the
  `roadmap.md`-loading fixtures. — Likelihood medium / impact high. Mitigation:
  the explicit boundary above; AC14 is verified by `git diff --name-only` at T8.
- **The `/roadmap` deletion leaves a dangling in-scope reference.** A heading or
  routing line still naming `/roadmap` would contradict AC5/AC7. — Likelihood
  medium / impact medium. Mitigation: after T3/T6, `grep -nF '/roadmap'` over
  `docs/workflow.md`, the skill, README, the two AGENTS files, and the writer
  prompts returns nothing; the legacy **artifact** alias `roadmap.md` /
  `phase: roadmap` is deliberately retained.
- **The pinned contract substrings in `docs/workflow.md` regress.**
  `87-backtrack-guards.sh:975-986` pins `stale: design`, `stale: spec`,
  `build (rework)`, `challenged (blocked)`, `P (backtracked)`, `P (reopened)`,
  and the readiness/backtrack phrases; the alias-prose edits must not disturb
  them. — Likelihood low / impact high. Mitigation: edit only the alias prose and
  the Design heading; run the full suite (which includes `87`).
- **The guard and the surfaces are reconciled out of order.** Editing `96` before
  the surfaces (or vice versa) leaves the suite red mid-change. — Likelihood
  medium / impact low. Mitigation: T1–T6 verify with greps and the non-96 areas;
  T7 edits the registry; T8 runs the full suite.

## Test strategy

The change is prompt/document/test text with no unit-testable runtime behavior,
so verification is the committed suite plus targeted, observable checks. No new
test area is added and no fixture changes.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | `ls .opencode/command` shows no `roadmap.md`; `grep -rn 'agent: roadmap' .opencode/command` returns nothing. |
| AC2 | `ls .opencode/agent` shows no `roadmap.md`; `40-inventory.sh` passes (documented agent inventory == disk). |
| AC3 | Review the `/plan` command + architect create-mode prose; exercise the create branch on a fresh `work/` tree (manual): `/plan <initiative>` authors `manifest.md` `phase: manifest` and reserves children, an existing ref takes the item path, a non-resolving item-ref-shaped arg takes the create path, and a single feature recommends `/spec`. |
| AC4 | `96-signature-sweep.sh` passes: the `/plan` dual form agrees across AGENTS, template AGENTS, the workflow Design heading, README table + mermaid, the skill routing block, the `/plan` usage string, and the registry. |
| AC5 | `grep -rnF '/roadmap'` over the in-scope surfaces returns nothing; `grep -rn 'roadmap'` over agent/command prompt files returns no `roadmap` agent name. |
| AC6 | Grep the writer surfaces for `manifest.md`, `phase: manifest`, `stale: manifest`, and `Revising a decomposition`; no `roadmap.md`/`phase: roadmap` writer path or `stale: roadmap` remains. |
| AC7 | `grep -nF '/roadmap' docs/workflow.md .opencode/skill/workflow-lifecycle/SKILL.md` returns nothing, while `grep -n 'roadmap.md' docs/workflow.md` still shows the recognized-deprecated-alias notes. |
| AC8 | `40-inventory.sh` passes; README Layout reads 13 agents / 12 commands; Commands table has no `/roadmap` row and its `/plan` row is the dual form; Agents table has no `roadmap` row. |
| AC9 | `95-split-guard.sh` passes (byte-parity outside the Project profile); `grep -nF '/roadmap' AGENTS.md template/AGENTS.md` returns nothing; the Design row is the dual form. |
| AC10 | Grep the skill: routing block offers `/plan <item-ref or initiative>`, and the decomposing-node/derived-state view uses `manifest.md` / container phase `manifest`. |
| AC11 | `grep -nF 'roadmap' tests/checks/96-signature-sweep.sh` returns nothing; the `/plan` registry entry is the dual form. |
| AC12 | `bash tests/run.sh` → `TOTAL: <n> passed, 0 failed`; `ls .opencode/agent .opencode/command .opencode/skill` shows 13 / 12 / 11 and no new entry. |
| AC13 | Diff review: no second state model, reference grammar, conflict taxonomy, finding vocabulary, dependency edge, command, agent, or skill; the six-column `Children` header and `conflicts-with` grammar unchanged; no committed `work/` artifact or `ship.md` rewritten. |
| AC14 | `git diff --name-only` (implementation files) lists exactly the removed pair plus `.opencode/command/plan.md`, `.opencode/agent/architect.md`, `README.md`, `AGENTS.md`, `template/AGENTS.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`, `docs/workflow.md`, and `tests/checks/96-signature-sweep.sh`. |

## Acceptance criteria coverage map

AC1→T1 · AC2→T1 · AC3→T2 · AC4→T2,T3,T4,T5,T6,T7 · AC5→T2,T3,T4,T5,T6 ·
AC6→T2 · AC7→T3,T6 · AC8→T4 · AC9→T5 · AC10→T6 · AC11→T7 · AC12→T8 ·
AC13→T8 · AC14→T8.
