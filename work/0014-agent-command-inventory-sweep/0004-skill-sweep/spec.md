---
feature: 0014-agent-command-inventory-sweep/0004-skill-sweep
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
notes: "Resolved user decisions: (1) retain clearly-labelled legacy `roadmap.md` / `stale: roadmap` alias mentions; (2) rename the `conventional-commits` illustrative retired reference to a neutral example; (3) file scope is the three named skills only; (4) generalize `workflow-lifecycle` depth wording to arbitrary depth. Child has no dependencies and was ready."
---

# Skill-surface recursive sweep

## Problem

The framework's **skill** prompts (`SKILL.md` files) are inherited verbatim by
every adopter and are loaded whenever an agent performs the matching task. Three
of them still carry retired vocabulary or a two-level depth assumption that
contradicts the recursive authority shipped by `0011`–`0013`, so a maintainer or
adopter reading them is taught a model the rest of the framework no longer uses.

The substantive defect is in `merge-conflict/SKILL.md:349`. The `work/`
artifact-reconcile procedure instructs the shipper to re-check the dependency
graph "In every `roadmap.md`". Since `0012-roadmap-deprecation` made `manifest.md`
the sole child-enumeration artifact and kept `roadmap.md` only as a deprecated
alias, that instruction would **silently skip every decomposing node whose
manifest is spelled `manifest.md`** — i.e. every new node. This is a behavioural
bug in the merge-time integrity procedure, not merely stale wording.

The same skill also labels graph faults "Roadmap graph faults" and describes the
canonical finding rows with bare `roadmap` terms — `DANGLING-DEP` "a roadmap
`Depends on`" (`:121`), `CYCLIC-DEP` "a cycle in a roadmap dependency graph"
(`:124`), `DRIFT-FACT` "a roadmap child's own `design.md`" (`:141`), plus
"re-checks the roadmap dependency graph" (`:220`), "roadmap `Children` /
`Depends on` tables" (`:258`), and "Roadmap `Children` rows" (`:333`).

`workflow-lifecycle/SKILL.md:22-28` frames a decomposing node as a fixed
`work/<NNNN-slug>/` + `work/<NNNN-slug>/<MMMM-slug>/` shape, implying a two-level
limit even though the model nests to arbitrary depth and a child may itself
decompose. `conventional-commits/SKILL.md:80,84-85,89` uses the retired
`0002-agentic-roadmaps/0001-roadmap-model` path as its `flatten(ref)`
illustration, leaking retired vocabulary into a generic, adopter-facing skill.

Affected: **framework maintainers**, who must trust each skill prompt to teach
the recursive model consistently, and **adopters**, who inherit the prompts and
the retired terms.

## Goals

- Every in-scope skill teaches the recursive model and contains no bare `roadmap`
  term used as if it were the current concept.
- `merge-conflict/SKILL.md` names the manifest (not `roadmap`) for its graph-fault
  heading and vocabulary, and its graph re-check covers **every manifest at any
  depth** — fixing the substantive stale-spelling bug — while preserving the
  canonical finding codes, classes, and grammar.
- `workflow-lifecycle/SKILL.md` describes a decomposing node as nesting to
  arbitrary depth with children that may themselves decompose, while its routing
  block stays canonical.
- `conventional-commits/SKILL.md` illustrates `flatten(ref)` with a non-retired
  reference.
- Clearly-labelled, sanctioned legacy-`roadmap.md` / `stale: roadmap` alias
  mentions are retained where they already are.
- The committed suite stays green.

## Non-goals

- Editing `.opencode/skill/pr-workflow/SKILL.md` or
  `.opencode/skill/browser-verification/SKILL.md` — they carry no retired
  vocabulary. (User decision: named three files only.)
- Editing any agent or command prompt (owned by `0001`–`0003`) or the
  inventories/doctor surfaces (owned by `0005`).
- Redefining the recursive model, reference grammar, conflict taxonomy, or finding
  codes. The authority in `docs/workflow.md` and `docs/artifact-conventions.md` is
  referenced, never restated.
- Removing the sanctioned legacy alias where it is clearly labelled as
  deprecated.
- Renaming, adding, or retiring any skill, or changing any skill's frontmatter
  `name`/`description`. The inventory stays 11 skills.
- Reintroducing a `/roadmap` command or a `roadmap` phase.
- Adding new committed fixtures (Roadmap 5).

## Users and stories

- **As a** framework maintainer, **I want** the merge-conflict skill to identify
  graph faults against a node's actual manifest, **so that** a post-merge
  integrity pass does not silently skip every decomposing node.
- **As an** adopter, **I want** every inherited skill to describe the recursive
  model the same way the authority does, **so that** I am not taught retired
  `roadmap` vocabulary.
- **As a** framework maintainer, **I want** the workflow-lifecycle skill to be
  fully recursive, **so that** its quick view does not imply a two-level limit.

## Acceptance criteria

1. **AC1** — Given `merge-conflict/SKILL.md`, when the graph-fault bullet of the
   framework-integrity subsection is read, then its heading uses a manifest term
   rather than "Roadmap graph faults", and it describes resolving each
   `Depends on` local id against a decomposing node's manifest.
2. **AC2** — Given the `merge-conflict/SKILL.md` pre-flight finding-vocabulary
   table, when the `DANGLING-DEP`, `CYCLIC-DEP`, and `DRIFT-FACT` rows are read,
   then each describes a manifest / decomposing child rather than a bare `roadmap`
   term, and the codes and their class labels (`(b)`, `(d)`) are unchanged.
3. **AC3** — Given the planning-time `DRIFT-FACT` bullet in
   `merge-conflict/SKILL.md`, when read, then it names a decomposing child's own
   declaration and its parent's `Children` cell rather than "a roadmap child".
4. **AC4** — Given the reconcile procedure and the `work/` artifact-reconcile
   subsection in `merge-conflict/SKILL.md`, when "roadmap dependency graph",
   "roadmap `Children` / `Depends on` tables", and "Roadmap `Children` rows" are
   read, then they are stated in manifest terms, with the procedure's behaviour
   otherwise unchanged.
5. **AC5** — Given `merge-conflict/SKILL.md`, when the graph re-check step is
   read, then it instructs re-checking the dependency graph of every decomposing
   node's manifest (the current `manifest.md` spelling, or the clearly-labelled
   legacy `roadmap.md` alias) at arbitrary depth, such that no node using the
   current spelling is skipped; no bare "In every `roadmap.md`" instruction
   remains.
6. **AC6** — Given the `merge-conflict/SKILL.md` finding vocabulary and the
   finding-grammar line, when compared with `docs/workflow.md` → "Merge
   conflicts" and "Declared-conflict check", then every finding code
   (`TEXTUAL-CONFLICT`, `DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`,
   `CYCLIC-DEP`, `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DRIFT-FACT`), its class
   label, and the finding-line grammar are unchanged.
7. **AC7** — Given `workflow-lifecycle/SKILL.md`, when the decomposing-node
   definition is read, then it states that a decomposing node and its descendants
   nest to arbitrary depth and that a child may itself decompose.
8. **AC8** — Given `workflow-lifecycle/SKILL.md`, when the manifest definition and
   the derived-states section are read, then the legacy `roadmap.md` alias and the
   `stale: roadmap` equivalent remain present and are explicitly labelled as the
   deprecated alias/equivalent.
9. **AC9** — Given `workflow-lifecycle/SKILL.md`, when its "Which command now?"
   routing block is read, then its routing targets and their canonical signatures
   are unchanged, such that `tests/checks/96-signature-sweep.sh` still passes.
10. **AC10** — Given `conventional-commits/SKILL.md`, when the `flatten(ref)`
    table, examples, and superseded-form note are read, then no illustrative
    canonical reference contains `roadmap` and the replacement still demonstrates
    a nested reference round-tripping through `flatten` (and the superseded
    non-injective `-` form) correctly.
11. **AC11** — Given `merge-conflict/SKILL.md`, when the graph-fault bullet is
    read, then the clearly-labelled legacy `roadmap.md` alias mention is retained
    alongside the manifest as primary.
12. **AC12** — Given each of `merge-conflict/SKILL.md`,
    `workflow-lifecycle/SKILL.md`, and `conventional-commits/SKILL.md`, when each
    is searched for `roadmap` (case-insensitive), then every remaining occurrence
    is part of a clearly-labelled legacy-alias mention (`roadmap.md` as the
    deprecated alias, or `stale: roadmap` as the deprecated equivalent); no bare
    `roadmap` term used as if it were the current concept remains.
13. **AC13** — Given the swept skill files, when `bash tests/run.sh` runs, then it
    exits 0, including `tests/checks/96-signature-sweep.sh` and
    `tests/checks/40-inventory.sh`.
14. **AC14** — Given the change set, when inspected, then only the three named
    files under `.opencode/skill/` are modified; no agent, command, README, docs,
    test, or other skill file is changed (beyond this item's `work/` artifact).

## Edge cases

- **Both manifest spellings.** The graph re-check must cover a node using the new
  `manifest.md` spelling and one using the legacy `roadmap.md` alias; neither is
  skipped.
- **Nested decomposition.** A node whose child itself decomposes (depth ≥ 3) must
  be covered by the "at any depth" phrasing.
- **Routing-block fixture parsing.** `tests/checks/96-signature-sweep.sh` extracts
  the workflow-lifecycle routes from the fenced block, terminating each arrow
  target at two-or-more spaces; added depth prose must not disturb that block or
  its arrow/target shape.
- **Example round-trip.** The `conventional-commits` replacement example must
  remain a valid canonical reference whose `flatten` and un-flatten round-trip,
  and it must not collide with a real current item reference.
- **Substrings.** The sweep targets the retired *vocabulary*, not the substring
  `roadmap` in an unrelated word; a clearly-labelled legacy-alias mention is
  allowed to contain it.
- **Cross-child consistency.** The `merge-conflict` finding vocabulary is shared
  with the `status` agent (`merge-conflict/SKILL.md:116`); the swept wording must
  stay consistent with the authority so that the sibling `0002-supporting-agent-sweep`
  can align `status.md` without divergence. `status.md` is not edited here.
- **Empty / no-op.** If a scan confirms a file already contains no stale term and
  needs no depth correction, it is left unchanged; the sweep must not churn
  already-correct text.

## Open questions

- None. The four user-owned forks — legacy-alias retention, the
  `conventional-commits` example, the file scope, and the `workflow-lifecycle`
  depth wording — were resolved with the user and are recorded under Dependencies
  and constraints.

## Dependencies and constraints

- **Read references (not edited):** `docs/workflow.md` → "The recursive lifecycle
  model", "Multiple work items", "Merge conflicts" → "Merge-integrity guard",
  "Declared-conflict check", "Derived state"; `docs/artifact-conventions.md` →
  "Work item references", "`manifest.md` — the manifest of a decomposing node".
  These are read, so no declared conflict is raised.
- **Readiness:** this child has no `Depends on` (`—`) and is `ready`; no
  dependency gates it.
- **Fixture constraint:** `tests/checks/96-signature-sweep.sh` scopes the
  workflow-lifecycle routing block and the command usage strings; the fixture is
  not edited here (its stale command count is owned by `0005`). `bash tests/run.sh`
  must stay green.
- **Disjoint surfaces:** sibling sweeps `0001`, `0002`, and `0003` edit agent and
  command files, so the file sets do not overlap and no `conflicts-with` is
  declared; the `merge-conflict`/`status` shared vocabulary is a read-consistency
  concern, not a shared edited surface.
- **Framework-internal, prompt/doc/text only.** No runtime dependency, service,
  network access, or new toolchain is introduced.
- **Resolved user decisions (recorded):** (1) retain clearly-labelled legacy
  `roadmap.md` / `stale: roadmap` alias mentions; (2) rename the
  `conventional-commits` illustrative retired reference to a neutral example;
  (3) file scope is the three named skills, excluding `pr-workflow` and
  `browser-verification`; (4) generalize the `workflow-lifecycle` depth wording
  to arbitrary depth.
