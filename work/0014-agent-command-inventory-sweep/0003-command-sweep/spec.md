---
feature: 0014-agent-command-inventory-sweep/0003-command-sweep
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Command-surface recursive sweep

## Problem

The slash-command prompts under `.opencode/command/` still teach the retired
two-level roadmap model, while the shipped authority
(`docs/workflow.md` → "The recursive lifecycle model"; `docs/artifact-conventions.md`
→ "Work item references") has made the generic **manifest** the sole
child-enumeration artifact at arbitrary depth. **Framework maintainers** and
**adopters** inherit these prompts verbatim, so stale teaching becomes
operationally wrong instruction. The commands also mirror their paired agent
prompts (`/spec`↔`product`, `/plan`↔`architect`, `/build`↔`builder`,
`/test`↔`tester`, `/review`↔`reviewer`, `/ship`↔`shipper`, `/status`↔`status`),
and siblings `0001-lifecycle-agent-sweep` and `0002-supporting-agent-sweep` have
already swept the agents onto the recursive model — so a command left on the old
wording now **diverges from its own agent**, which a maintainer cannot detect
without reading both.

Concretely:

- `command/status.md` — the substantive surface — detects a decomposing node by
  `roadmap.md` (`command/status.md:15`), derives the container phase `roadmap`
  (`command/status.md:19-20`), and maps only `stale: roadmap` to `spec`
  (`command/status.md:28`). A maintainer or adopter following it keys off the
  wrong artifact and derives a retired phase.
- `command/spec.md` repeats the retired item-ref boilerplate twice
  (`command/spec.md:13-15`, `:22-24`), including the nested-child allocation step
  "for a roadmap child, use the supplied `NNNN-slug/MMMM-slug` reference"
  (`command/spec.md:23`).
- `command/ship.md` instructs a reconcile step to "re-check the roadmap
  dependency graph" (`command/ship.md:39`) and repeats the boilerplate
  (`command/ship.md:21-23`).
- The seven commands `spec`, `plan`, `build`, `test`, `review`, `ship`, and
  `visual` each repeat the boilerplate "`NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child", which understates the canonical
  reference grammar that nests to arbitrary depth.

The drift is silent: someone reading a command alone is taught a container phase
and artifact the authority retired, and a command/agent pair disagree.

## Goals

- Every swept command prompt teaches the shipped recursive model and no longer
  instructs retired roadmap behavior, so a command agrees with its paired agent.
- The item-ref boilerplate is stated once and identically across the seven
  commands that carry it, mirroring the agent sweep's canonical wording, ready for
  the fixture and for maintainers to trust.
- `command/status.md` derives a decomposing node from `manifest.md` and the
  container phase `manifest`, while still recognizing the labelled legacy
  `roadmap.md` / `stale: roadmap` aliases so pre-existing nodes keep reporting.
- The sweep is prose-only: each swept command keeps its `Usage:` signature and
  `agent:` frontmatter, and its phase behavior is unchanged.
- The committed suite (`bash tests/run.sh`) stays green and the documented
  inventory stays 13 agents / 12 commands / 11 skills.

## Non-goals

- The lifecycle agents (`product`, `architect`, `builder`, `tester`, `reviewer`,
  `shipper`) — owned by `0001-lifecycle-agent-sweep`, already shipped.
- The supporting agents — owned by `0002-supporting-agent-sweep`, already shipped.
- The skills — owned by `0004-skill-sweep`.
- The `doctor` agent and `/doctor` command, the README inventories/counts, the
  stale "thirteen" count at `tests/checks/96-signature-sweep.sh:250`, and
  `docs/customization.md` — owned by `0005-inventory-and-doctor-sweep`.
- Commands that carry no retired vocabulary: `conflicts`, `fix`, and `bootstrap`
  are left byte-identical.
- Adding, renaming, retiring, enabling, or disabling any command, agent, or skill.
- Editing `docs/**`, `README.md`, `AGENTS.md`, `template/AGENTS.md`, or the tests.
- Adding any new committed fixture, guard, or executable checker — that boundary
  is Roadmap 5.
- Restating or redefining the recursive authority; the commands reference it.
- Reopening any shipped work item.

## Users and stories

- **As a** framework maintainer, **I want** each command prompt to teach the same
  recursive model as `docs/workflow.md`, **so that** I can trust a command on its
  own and know it agrees with its paired agent.
- **As an** adopter, **I want** the inherited commands to reference the parent
  **manifest** rather than a retired `roadmap.md`, **so that** the commands work
  on my nested and decomposing work items out of the box.
- **As a** framework maintainer, **I want** `command/status.md` to keep
  recognizing legacy `roadmap.md` / `stale: roadmap` items, **so that**
  pre-existing decomposing nodes and backtracks keep reporting correctly with no
  migration.

## Acceptance criteria

1. **AC1** — Given `command/status.md`, when its decomposing-node detection is
   read, then it identifies a decomposing node by `manifest.md` (with the
   deprecated `roadmap.md` spelling labelled as the legacy alias) rather than by
   `roadmap.md` alone.

2. **AC2** — Given `command/status.md`, when the container phase it derives is
   read, then it states `manifest` — and never `roadmap` — as the phase derived by
   a node with a manifest and no own phase artifacts.

3. **AC3** — Given `command/status.md`, when its derived-state mapping is read,
   then a `stale: roadmap` token is presented together with `stale: manifest`
   (both mapping to `spec`), with `roadmap` labelled as the deprecated legacy
   alias, so the legacy mapping is not dropped.

4. **AC4** — Given `command/spec.md`, when its nested-child allocation wording is
   read, then the supplied child reference is stated as the canonical recursive
   form (`NNNN-slug/MMMM-slug`, nested to arbitrary depth per
   `docs/artifact-conventions.md` → "Work item references") and the phrase "for a
   roadmap child" is gone.

5. **AC5** — Given `command/ship.md`, when its reconcile step is read, then the
   re-check of the dependency graph is stated as the manifest's dependency graph,
   with the reconcile and renumber semantics unchanged, and the phrase "roadmap
   dependency graph" is gone.

6. **AC6** — Given the seven swept commands `spec`, `plan`, `build`, `test`,
   `review`, `ship`, and `visual`, when the item-ref boilerplate sentence is
   extracted from each, then the seven sentences are byte-identical, each states
   the canonical recursive reference form (`NNNN-slug` for a standalone item or a
   nested `NNNN-slug/MMMM-slug` at any depth) resolving to `work/<item-ref>/`,
   each cites `docs/artifact-conventions.md` → "Work item references", and none
   contains the wording "roadmap child".

7. **AC7** — Given `command/plan.md`, when its planning-path selection is read,
   then it retains a clearly-labelled legacy `roadmap.md` alias mention alongside
   its `manifest.md` primary spelling, so the retained alias is not dropped.

8. **AC8** — Given the eight swept commands (`spec`, `plan`, `build`, `test`,
   `review`, `ship`, `status`, `visual`), when every occurrence of the token
   `roadmap` is inspected, then each occurrence is a clearly-labelled deprecated
   alias permitted by the parent's sanctioned-legacy-alias rule; no occurrence
   presents `roadmap` as a current phase name, current artifact path, or current
   route, and any already-correct `manifest.md` wording (for example
   `command/ship.md`'s plan-publication mode) is not regressed.

9. **AC9** — Given each of the eight swept commands, when its YAML frontmatter and
   `description:` line are compared with the pre-sweep file, then its `agent:`
   value and the `Usage:` signature embedded in its `description:` are
   byte-identical, and the change is prose-only so no command's phase behavior
   changes.

10. **AC10** — Given the change set for this item, when inspected, then only the
    eight swept command prompts are modified, together with this item's own
    `work/0014-agent-command-inventory-sweep/0003-command-sweep/` artifacts;
    `conflicts`, `fix`, `bootstrap`, and `doctor` command prompts are byte-identical,
    and no `docs/**`, README, AGENTS.md, template, test, or agent file changes.

11. **AC11** — Given the swept tree, when `bash tests/run.sh` is run, then it
    exits `0`, the `96-signature-sweep.sh` checks stay green, and the documented
    inventory remains 13 agents / 12 commands / 11 skills.

12. **AC12** — Given the swept commands, when any recursive-model statement is
    inspected, then it references the authority sections by name and introduces no
    new `phase` value, finding code, or reference grammar; the item-ref
    boilerplate content matches the canonical sentence the paired agent prompts
    carry.

## Edge cases

- `command/spec.md` carries the retired item-ref wording in two places — the
  boilerplate (`:13-15`) and the allocation step (`:22-24`); both must be swept,
  not just the first.
- `command/plan.md` retains exactly one sanctioned, clearly-labelled legacy
  `roadmap.md` alias mention (mirroring `architect.md`); it is the intentional
  exception to AC8 and must stay labelled "legacy".
- `command/status.md` already names the word "manifest" in its derived-state
  prose; the sweep must correct the phase and artifact spelling without regressing
  the parts that already reference `manifest.md`.
- `command/ship.md` already names `manifest.md` in its plan-publication and
  recall modes; the sweep must not regress that wording.
- `command/doctor.md` is deliberately excluded (owned by
  `0005-inventory-and-doctor-sweep`); it must be left unchanged even though it
  accepts no item-ref.
- The canonical command boilerplate sentence must be stable across the seven
  commands because a fixture and future sweeps pin it; a later change to it
  re-opens this item.
- A nested child must read as unbounded depth, not exactly two segments.
- The sweep edits disjoint files from `0004-skill-sweep` and `0005`, but consumes
  the already-shipped `0001`/`0002` agent wording; if that wording is later
  revised upstream, this item's mirrored sentence must be revisited.

## Open questions

- [x] **Legacy-alias treatment** — resolved 2026-10-13: keep the clearly-labelled
  legacy `roadmap.md` alias in `command/plan.md` and pair `stale: roadmap` with
  `stale: manifest` in `command/status.md`, mirroring the settled agents.
  owner: user; needed by: spec.
- [x] **Item-ref sentence identity** — resolved 2026-10-13: one identical
  canonical sentence across all seven commands, content matching the paired
  agent's canonical sentence, exact text chosen at design. owner: user;
  needed by: spec.
- [x] **Clean-command scope** — resolved 2026-10-13: sweep only the eight commands
  that carry stale vocabulary or boilerplate; leave `conflicts`, `fix`, and
  `bootstrap` unchanged. owner: user; needed by: spec.
- [ ] **Exact canonical command sentence text** — deferred to design; the spec
  fixes only the required content and the cross-command identity. owner:
  architect (`/plan`); needed by: design.

## Dependencies and constraints

- **Readiness:** the parent manifest row `0003-command-sweep` declares
  `Depends on: 0001-lifecycle-agent-sweep, 0002-supporting-agent-sweep`; both
  dependencies have shipped (`ship.md` present, no `reopened:` marker), so this
  child is `ready` and no override is required. This is ordinary forward
  progression; the child has no open backtrack finding.
- **Parent:** `work/0014-agent-command-inventory-sweep/manifest.md`, row
  `0003-command-sweep`. Its shared sweep vocabulary and its sanctioned
  legacy-alias rule are consumed here: the item-ref boilerplate becomes the
  canonical recursive form; target/container phase `roadmap` becomes `manifest`;
  `work/<parent-ref>/roadmap.md` becomes `work/<parent-ref>/manifest.md`;
  "roadmap graph"/"roadmap `Children`" become the manifest's dependency graph and
  `Children` table.
- **Authority cited (read-only):** `docs/workflow.md` → "The recursive lifecycle
  model", "Where decomposition is authored and recorded", "Revising a
  decomposition", "Dependencies and readiness", "Derived state", "Status
  reporting"; `docs/artifact-conventions.md` → "Work item references" and the
  `manifest.md` template. The legacy alias is documented at
  `docs/artifact-conventions.md:124-137`.
- **Fixture:** `tests/checks/96-signature-sweep.sh` pins every command's `Usage:`
  signature (lines 269-299) and its `agent:`-backed description; the sweep is
  prose-only and must keep those literals byte-identical.
- **Constraints:** framework-internal, prompt/doc/test only — no installed
  runtime dependency, service, network access, or new toolchain. The committed
  suite is read-only and never reads live `work/**` (`tests/run.sh:20`), so the
  sweep is validated by inspection of the live command prompts plus the suite.
- **Assumption:** the eight commands identified by recon are the complete stale
  surface set for this child; `doctor` is excluded and owned by `0005`.
