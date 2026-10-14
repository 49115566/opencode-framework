---
feature: 0014-agent-command-inventory-sweep/0002-supporting-agent-sweep
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
notes: "Roadmap child of 0014-agent-command-inventory-sweep; carried Depends on: —, so it is ready and this is ordinary forward progression (no open backtrack finding). Parent scope: prose-only sweep of the supporting-agent prompts, no new surfaces."
---

# Supporting-agent recursive sweep

## Problem

The six supporting-agent prompts under `.opencode/agent/` do not all teach the
recursive model that the shipped authority (`docs/workflow.md`, `docs/artifact-
conventions.md`) now defines. **Framework maintainers** and **adopters** inherit
these prompts verbatim, so a stale teaching becomes an operationally wrong one.

Concretely:

- `status` (`.opencode/agent/status.md`) — the substantive surface — detects a
  decomposing node by `roadmap.md`, treats the container phase as `roadmap`, names
  the `roadmap.md` template, maps only `stale: roadmap` to `spec`, calls a nested
  child "a roadmap child", and its rendered output example shows a `roadmap` phase
  and "Roadmap …" summary lines (`status.md:48,53-54,58,90,104,120,128,244,265,
  296-313,327,337,340`). A maintainer or adopter reading it is taught a container
  concept that the authority retired: the phase is `manifest` and the spelling is
  `manifest.md`.
- `visual` (`.opencode/agent/visual.md:58-60`) tells the reader an item reference
  is "`NNNN-slug` for a standalone item, or `NNNN-slug/MMMM-slug` for a roadmap
  child", which understates the canonical reference grammar, which nests to
  arbitrary depth (`docs/artifact-conventions.md` → "Work item references").
- `scribe` (`.opencode/agent/scribe.md:43`) writes to `work/<item-ref>/<file>`
  without ever stating what a canonical reference is.

The cost: an agent acting on `/status` (or the paired `/status` command, which
mirrors this prompt) can key off the wrong artifact and mis-derive a node's phase;
adopters are taught the retired vocabulary and a two-level-only reference form,
and the drift between prompts and the authority returns silently.

## Goals

- Every supporting-agent prompt teaches the same recursive model as the authority,
  with no `roadmap` token used as if it were current.
- `status` derives a decomposing node from `manifest.md` and the container phase
  `manifest`, while still recognizing the deprecated `roadmap.md` / `stale:
  roadmap` spellings where they are explicitly labelled as legacy aliases.
- The item-reference boilerplate in `visual` — and the path step in `scribe` —
  states the canonical recursive reference form.
- Each edited prompt keeps its frontmatter, permission block, and handoff block;
  only prose changes.
- The committed suite (`bash tests/run.sh`) stays green.

## Non-goals

- No new, renamed, or retired agent, command, or skill; the README inventories
  stay 13 agents / 12 commands / 11 skills.
- Not the lifecycle agents (`product`, `architect`, `builder`, `tester`,
  `reviewer`, `shipper`) — owned by `0001-lifecycle-agent-sweep`.
- Not the command prompts — owned by `0003-command-sweep`.
- Not the skills — owned by `0004-skill-sweep`.
- Not the `doctor` agent/command, the inventories/counts, or `docs/customization.md`
  — owned by `0005-inventory-and-doctor-sweep`. In particular the stale
  "thirteen" command count at `tests/checks/96-signature-sweep.sh:250` is not
  this item's.
- Not editing `README.md`, `AGENTS.md`, `template/AGENTS.md`, `docs/**`, or the
  tests.
- Not restating or redefining the recursive authority; the prompts reference it.
- No behavior change beyond the vocabulary/model correction (prose only), and no
  new committed fixtures/guards (Roadmap 5).
- Not reopening any shipped work item.

## Users and stories

- **As a** framework maintainer, **I want** every supporting-agent prompt to
  teach the recursive manifest model, **so that** I can trust that a prompt's
  wording agrees with the authority before I act on it.
- **As an** adopter, **I want** the inherited `status`, `visual`, and `scribe`
  prompts to describe canonical references at any depth, **so that** I am not
  taught a retired container phase or a two-level-only reference form.
- **As a** framework maintainer, **I want** `status` to keep recognizing legacy
  `roadmap.md` / `stale: roadmap` items, **so that** pre-existing decomposing
  nodes and backtracks continue to report correctly with no migration.

## Acceptance criteria

1. **AC1** — Given the `status` agent prompt, when a reader inspects its
   decomposing-node detection, then it identifies a decomposing node by
   `manifest.md` (with the deprecated `roadmap.md` spelling labelled as the legacy
   alias) rather than by `roadmap.md` alone.

2. **AC2** — Given the `status` agent prompt, when a reader inspects the container
   phase it derives, then it states `manifest` — and never `roadmap` — as the
   phase derived by a node with a manifest and no own phase artifacts.

3. **AC3** — Given the `status` agent prompt, when a reader inspects its
   derived-state mapping, then a `stale: roadmap` token is presented together with
   `stale: manifest` (both mapping to `spec`), with `roadmap` labelled as the
   legacy alias, so the legacy mapping is not dropped.

4. **AC4** — Given the `status` agent prompt, when a reader inspects its reference
   to the artifact-conventions template, then it names the `manifest.md` template
   (the legacy `roadmap.md` alias labelled) rather than the `roadmap.md` template.

5. **AC5** — Given the `status` agent prompt, when a reader inspects the
   declaration-discrepancy (`DRIFT-FACT`) description, then it refers to a nested
   child's own `design.md` declaration rather than "a roadmap child's".

6. **AC6** — Given the `status` agent prompt's phase-vocabulary list, when read,
   then the base-phase list contains `manifest` and does not contain `roadmap` as
   a base phase.

7. **AC7** — Given the `status` agent prompt's rendered output example, when a
   reader inspects it, then its phase column, its per-node phase tally, and its
   container summary-line wording use `manifest` / manifest vocabulary rather than
   a `roadmap` phase or "Roadmap …" wording; illustrative reference identifiers
   may remain unchanged.

8. **AC8** — Given the `visual` agent prompt's item-reference input, when read,
   then it states the canonical recursive reference form — `NNNN-slug` for a
   standalone item, nested `NNNN-slug/MMMM-slug` at any depth, per
   `docs/artifact-conventions.md` → "Work item references" — and no longer says
   "for a roadmap child".

9. **AC9** — Given the `scribe` agent prompt's target-path step, when read, then
   the `work/<item-ref>/<file>` path is accompanied by the canonical recursive
   reference form.

10. **AC10** — Given the `scout`, `ask`, and `bootstrap` agent prompts, when
    examined, then they carry no `roadmap` vocabulary and are unchanged by this
    item.

11. **AC11** — Given each edited prompt, when compared with its pre-item content,
    then its YAML frontmatter (including the `permission` block), its `<handoff>`
    block, and its phase behavior are unchanged except for the swept prose.

12. **AC12** — Given each edited prompt, when scanned for the token `roadmap`,
    then every remaining `roadmap.md` or `stale: roadmap` occurrence is immediately
    labelled as the deprecated/legacy alias, and no occurrence presents `roadmap`
    as a current phase name or current manifest spelling. (Illustrative reference
    identifiers in the output example are outside this criterion.)

13. **AC13** — Given the change set for this item, when inspected, then only the
    `status`, `visual`, and `scribe` agent prompts are modified, together with this
    item's own `work/0014-agent-command-inventory-sweep/0002-supporting-agent-sweep/`
    artifacts; no `docs/**`, test, README, other-agent, or command file changes.

14. **AC14** — Given the edited prompts, when `bash tests/run.sh` is run, then the
    suite reports zero failures, including the phrases that pin the `status` agent
    (`A child in a cycle is never \`ready\``, `CYCLIC-DEP`, `informational and
    never fatal`, `members of a cycle are never reported`, `## Declared-conflict
    check`, `Dependencies and readiness`).

## Edge cases

- **Legacy item still reportable.** A decomposing node whose only manifest is the
  retained `roadmap.md` alias, and a backtrack whose only marker is
  `stale: roadmap`, must still be detected and mapped after the sweep; dropping
  the alias would misreport them with no migration path.
- **Mixed stale tokens.** `stale: roadmap` and `stale: manifest` both map to
  `spec`; a mention that pairs them must not introduce a second mapping or a new
  derived label.
- **Pinned phrases survive rewording.** Rewording a `status` sentence must not
  drop the literals the suite pins (AC14); e.g. keep "informational and never
  fatal" verbatim.
- **Hybrid node precedence.** The own-artifacts-first rule (a node with its own
  phase artifacts derives its own phase, independently of the manifest) must
  survive the sweep, so a hybrid node is still not collapsed to `manifest`.
- **Empty / clean prompts.** `scout`, `ask`, and `bootstrap` carry no work-item or
  `roadmap` vocabulary; forcing an edit there is scope creep and must not happen.
- **Example vs. live claim.** The illustrative reference names in the output
  example (`0002-agentic-roadmaps`, `0001-roadmap-model`) remain, but the example
  must not present `roadmap` as a current phase or container.
- **Nested child at any depth.** The canonical reference form must read as
  unbounded depth, not as exactly two segments.

## Open questions

- [x] Legacy-alias handling in `status` — resolved 2026-10-13: retain
  `roadmap.md` and `stale: roadmap` as explicitly labelled deprecated aliases.
- [x] Which prompts the sweep edits — resolved 2026-10-13: `status` and `visual`,
  plus canonical-reference coverage in `scribe`; `scout`/`ask`/`bootstrap`
  untouched.
- [x] Depth of the output-example sweep — resolved 2026-10-13: relabel phases and
  container vocabulary only; keep illustrative identifiers.

No open questions remain. `status: final`.

## Dependencies and constraints

- **Readiness:** no dependencies (`Depends on: —` in the parent manifest row), so
  this child is `ready`; no override is required.
- **Parent:** `work/0014-agent-command-inventory-sweep/manifest.md` row
  `0002-supporting-agent-sweep`. Sibling `0003-command-sweep` consumes this
  sweep's wording, so the prompt wording settles here first.
- **Authority cited (read-only):** `docs/workflow.md` → "The recursive lifecycle
  model", "Where decomposition is authored and recorded", "Revising a
  decomposition", "Dependencies and readiness", "Derived state", "Status
  reporting"; `docs/artifact-conventions.md` → "Work item references" and the
  `manifest.md` template.
- **Fixed shared mapping (from the parent manifest, consumed here):** the item-ref
  boilerplate becomes the canonical recursive form; "parent roadmap" becomes the
  parent's manifest; `/roadmap revise <parent-ref>` becomes the `/plan <item-ref>`
  revise route; target/container phase `roadmap` becomes `manifest`;
  `work/<parent-ref>/roadmap.md` becomes `work/<parent-ref>/manifest.md`;
  "roadmap graph"/"roadmap `Children`" become the manifest's dependency graph and
  `Children` table.
- **Constraints:** framework-internal, prompt/doc/test only; no installed runtime
  dependency, service, or toolchain. Prose-only, so each prompt's frontmatter,
  permission block, and handoff block are preserved. The suite is read-only and
  never reads `work/**` (`tests/run.sh:20`), so the sweep is validated against the
  live prompts.
- **Assumption:** the six supporting-agent prompts are the complete surface set
  for this child; `doctor` is excluded and owned by `0005`.
