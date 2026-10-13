---
feature: 0012-roadmap-deprecation/0001-deprecation-contract
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
conflicts-with: "docs/workflow.md, docs/artifact-conventions.md"
parent: 0012-roadmap-deprecation
---

# Design — Deprecation contract: the generic manifest replaces the special `roadmap` concept

## Summary

Make the **manifest** the one child-enumeration artifact of a decomposing node at
every depth: fix its concrete spelling as `manifest.md` with `phase: manifest`,
recognize `roadmap.md`/`phase: roadmap` as a deprecated alias so no existing node
migrates, rename the derived container phase and the `stale` token to `manifest`,
and retire the "roadmap" concept vocabulary in the two authority documents. The
change is document-only — `docs/workflow.md` and `docs/artifact-conventions.md` —
and reuses the shipped state model, reference grammar, conflict taxonomy, and
finding vocabulary unchanged.

## Approach

The contract has four parts, all applied inside the two authority documents.

1. **Artifact identity.** The new spelling is `work/<item-ref>/manifest.md`,
   frontmatter `phase: manifest`, H1 `# Manifest — <initiative title>`. The
   template heading in `docs/artifact-conventions.md` becomes
   `` ### `manifest.md` (manifest) — the manifest of a decomposing node ``. Every
   surface that names the concrete file, its `phase` value, or the template
   heading points at the new spelling.

2. **Legacy alias.** `work/<item-ref>/roadmap.md` with `phase: roadmap` stays a
   **recognized deprecated alias** for a manifest: a node holding it is still a
   decomposing node, derives the same container phase, and is never rewritten or
   migrated. It is named only in explicit backward-compatibility notes. New
   manifests always use `manifest.md`/`phase: manifest`.

3. **Precedence and reporting.** When one node directory holds both spellings,
   `manifest.md` is authoritative and the node is derived from it; the redundant
   `roadmap.md` is reported by the `/status` integrity window as an inconsistency
   and is never merged, dropped, normalized, or auto-repaired. A manifest whose
   spelling and `phase` value disagree (`manifest.md` + `phase: roadmap`, or
   `roadmap.md` + `phase: manifest`) is reported the same way. The report reuses
   the shipped **`(d)`** class and **`DRIFT-FACT`** code (the "one manifest per
   node" derived fact disagrees with disk); no new code, class, or policy is
   introduced.

4. **State and vocabulary.** The derived container phase is renamed
   `roadmap` → `manifest`; own phase artifacts still take precedence over the
   manifest at every depth. The `stale` token and parent-manifest reverse-edge
   label are renamed `roadmap` → `manifest` (`stale: manifest` maps to `spec`; a
   legacy `stale: roadmap` is accepted as the deprecated equivalent and maps to
   `spec`). The `phase` value list reads `manifest` in place of `roadmap`. In both
   documents the `roadmap` term as concept vocabulary is retired: the
   `## Roadmaps` section is retitled to the generic decomposing-node/manifest
   term, `### Revising a roadmap` becomes `### Revising a decomposition`, and the
   concept nouns ("roadmap parent", "roadmap child", "intra-roadmap sibling",
   "roadmap metadata", "A roadmap authored before") become the generic terms.
   Occurrences that are **not** concept vocabulary are retained: the literal
   legacy spellings (`roadmap.md`, `phase: roadmap`, `stale: roadmap`), the
   deprecated `/roadmap` command alias (which `0002-command-retirement` removes),
   and existing/illustrative work-item slugs. The retained legacy spellings live
   only inside explicit deprecated/backward-compatibility notes.

The change is mechanical documentation editing with a precise verified list of
surfaces (below); it introduces no code, no runtime state, and no new dependency.

## Alternatives considered

- **Rename the spelling but keep `phase: roadmap`.** Pros: smaller derived-state
  and token diff. Cons: the spec fixes the `phase` value rename (AC7) and the
  derived container phase follows it (AC6); keeping it would fork the state model
  on a spelling/`phase` combination — the exact two-names-for-one-concept cost the
  item exists to remove. Rejected.
- **Minimal vocabulary change — retitle `## Roadmaps` and rename only the
  `phase` value and the `stale` token, leaving adjectival uses ("roadmap parent",
  "roadmap child", "intra-roadmap") in place.** Pros: the smallest safe diff, no
  risk of re-touching identifiers, and the derived-state/token semantics still
  land. Cons: AC9 requires the `roadmap` term to appear only in a
  historical/backward-compatibility note and no document surface to define a
  standalone "roadmap" concept; leaving the adjectival concept nouns keeps a
  second live name for the same concept and leaves the maintainer dilemma intact.
  Rejected on AC9.
- **Keep the manifest's shown state but reject the alias — require migration of
  the seven existing parents here.** Pros: one spelling, no alias branching.
  Cons: violates AC3/AC11 (no forced migration, existing parents remain valid) and
  would duplicate `0003-parent-migration`'s scope, and the committed fixtures that
  carry `roadmap.md` (e.g. `tests/fixtures/cyclic-roadmap/roadmap.md`, pinned by
  `tests/checks/80-cycle-fixture.sh:30`) would have to change, breaking AC13's
  fixture safety. Rejected.
- **Chosen:** the four-part contract above — full identity + alias + precedence +
  vocabulary retirement, extending the shipped vocabulary and state model rather
  than forking them.

## Interfaces and data model

This item's "interface" is the artifact contract. Concretely:

- **File name** — new: `work/<item-ref>/manifest.md`; deprecated alias:
  `work/<item-ref>/roadmap.md` (accepted, never written by new plans).
- **Frontmatter `phase` value** — new: `manifest`; deprecated alias: `roadmap`.
  The documented `phase` value set becomes
  `spec | design | manifest | tasks | test | visual | review | ship`
  (`docs/artifact-conventions.md:20`).
- **`stale` token** — new: `manifest` (maps to `spec` when a child's phase is
  derived); deprecated: `roadmap` (accepted as the equivalent, maps to `spec`).
  The token list in the `stale` frontmatter note keeps the shipped
  `spec | design | build | test | review` substring intact and names `manifest`
  in place of `roadmap` for the phase→parent-manifest backtrack.
- **Container phase** — `manifest` replaces `roadmap` in the derived-state prose,
  row, and the decomposing-node paragraph; own-phase-artifact precedence is
  unchanged.
- **Precedence / integrity** — `manifest.md` authoritative over a redundant
  `roadmap.md`; the inconsistency is reported through the existing `/status`
  integrity window and the `(d)`/`DRIFT-FACT` invariant set; no repair.
- **Unchanged** — the six-column `Children` table, the `conflicts-with` grammar,
  the `Depends on`/readiness contract, the reference grammar, and the finding
  code set are not altered.

No API, schema, migration, or runtime interface changes; the only consumers are
the framework's own documents and prompts, which read the terms by name.

## Affected areas

`docs/workflow.md` (in scope by section):

- `## The recursive lifecycle model` intro (`32-33`); `### Terms` deprecated-alias
  paragraph (`53-55`); `### Where decomposition is authored and recorded`
  (`66-97`, file/`phase`/heading refs); backward-compat paragraph (`129-132`).
- `## The work item directory` diagram (`144-145`).
- `## Roadmaps` section (`174-192`) — retitled; `### Dependencies and readiness`
  manifest parenthetical (`196`); `### Declared conflicts` concept nouns
  (`260`, `267`, `285`, `288`); `### Status reporting` integrity list
  (`329-334`); `### Starting a blocked child` (`338-339`);
  `### Revising a roadmap` (`345-433`) — retitled, tokens, template refs.
- `### 2. Design` entry/exit/artifact (`462-500`).
- `## Plan publication` (`600-613`).
- `## Declared-conflict check` compared set and pair predicate
  (`745-765`, `796`).
- `## Phase reversal (backtracking)` reverse-edge rule/table/exceptions
  (`871-894`); `### Taking an edge` (`934`, `972`); `## Derived state` prose, row,
  token note, decomposing-node paragraph (`1216-1230`, `1246`, `1288-1292`).
- `## Routing heuristics` `/roadmap` bullet concept nouns (`1336-1341`);
  `## Multiple work items` (`1371-1372`); `## Merge conflicts` taxonomy
  (`1392`), lifecycle placement (`1405`), merge-integrity guard invariant table
  (`1454-1455`).

`docs/artifact-conventions.md`:

- Frontmatter `phase` value list (`20`); `stale` token note (`51-57`).
- `## Work item references` roadmap paragraph and illustrative path (`95-109`).
- `### `roadmap.md` (roadmap) — the manifest of a decomposing node` heading
  (`124`) and body (`126-137`, `139-181` template); `conflicts-with` successor
  wording (`204`); "Revising a roadmap" refs (`211`, `216`).
- `### Renumbering after a parallel merge` "roadmap parent"/"roadmap `Children`"
  (`692`, `702`).

Boundary (not touched): `.opencode/{command,agent}/roadmap.md` and the inventory
surfaces (`README.md`, `AGENTS.md`, `template/AGENTS.md`, the `workflow-lifecycle`
skill, `tests/checks/40-inventory.sh`, `96-signature-sweep.sh`) belong to
`0002-command-retirement`; the existing `work/*/roadmap.md` parents and the
fixtures/guards that load them belong to `0003-parent-migration`. The `/roadmap`
command alias clause in `docs/workflow.md`'s alias prose is left for `0002`; this
item only retires the concept nouns around it.

## Risks and mitigations

- **An existing committed pin breaks.** The suite pins several literal strings in
  the two documents (`tests/checks/87-backtrack-guards.sh:950-986`, e.g.
  `spec | design | build | test | review`, the `backtracks.md`/`challenges.md`
  record shapes, the derived-state routing literals, the readiness algorithm
  text). — Likelihood medium / impact high. Mitigation: preserve the pinned
  substrings verbatim; keep the readiness algorithm and record-shape blocks
  untouched; run `bash tests/run.sh` after every edit and fix immediately.
- **The vocabulary sweep touches a literal identifier and creates a dangling
  reference.** Example identifiers such as `work/0002-agentic-roadmaps/...` and
  `0004-roadmap-revision` are not concept vocabulary. — Likelihood medium /
  impact medium. Mitigation: change only concept nouns; leave item slugs and
  illustrative paths unless the path is itself the illustrative example being
  modernized (`docs/artifact-conventions.md:97`); final sweep reviews every
  remaining hit and classifies it as legacy-note or identifier.
- **Alias handling is under-specified and a reviewer reads it as new vocabulary.**
  — Likelihood medium / impact medium. Mitigation: fix the contract here —
  legacy `roadmap.md`/`phase: roadmap` recognized, `manifest.md` authoritative,
  mismatched pairing reported — and route the report through the existing
  `(d)`/`DRIFT-FACT` vocabulary so AC10 holds.
- **A retitle breaks a cross-reference.** `## Roadmaps` and
  `### Revising a roadmap` are referenced from `docs/workflow.md:96,480,883` and
  `docs/artifact-conventions.md:211,216`. — Likelihood medium / impact medium.
  Mitigation: update the heading and every reference in the same task; verify by
  grep that no stale heading reference remains.
- **Scope creep into `0002`/`0003`.** Retiring the term tempts edits to the
  `/roadmap` command/agent, the inventories, the fixtures, and the seven existing
  parents. — Likelihood medium / impact high. Mitigation: the explicit boundary
  above; AC12 is verified by the change-set diff (`git diff --name-only` reports
  only the two documents).
- **The `stale` token note edit breaks the pinned contiguous substring.** —
  Likelihood low / impact medium. Mitigation: keep
  `spec | design | build | test | review` contiguous and add `manifest` in the
  surrounding clause.

## Test strategy

Documentation-only change: there is no unit-testable behavior and the spec's
non-goals exclude new committed guards, so verification is the existing suite plus
targeted, observable document checks. No new test file is added.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | Review that the two documents define only the manifest as the child-enumeration artifact; grep that `## Roadmaps` no longer exists and no standalone "roadmap" concept section remains. |
| AC2 | Grep `manifest.md` and `phase: manifest` in both docs; confirm the template heading and H1 read `manifest`. |
| AC3 | Review the alias/backward-compatibility notes; confirm `roadmap.md`/`phase: roadmap` are named only as deprecated. |
| AC4 | Review the writer/plan-publication prose; confirm new manifests are written as `manifest.md`/`phase: manifest`. |
| AC5 | Review the precedence rule and the `/status` integrity report; confirm `manifest.md` is authoritative and no auto-repair is implied. |
| AC6 | Review the derived-state prose and row; confirm container phase `manifest` and unchanged own-artifact precedence. |
| AC7 | Grep the frontmatter `phase` value list; confirm `manifest` replaces `roadmap` and the legacy value is documented as deprecated. |
| AC8 | Grep `stale: roadmap`/`stale: manifest`; confirm the label and token read `manifest`, map to `spec`, and only legacy notes mention `roadmap`. |
| AC9 | Full `roadmap` sweep of both docs; every remaining hit is a legacy/backward-compatibility note or an existing identifier. |
| AC10 | Diff review: six-column `Children` header, `conflicts-with` grammar, reference grammar, and the finding code set are unchanged; the new report reuses `DRIFT-FACT` `(d)`. |
| AC11 | Review: standalone items, legacy parents, and shipped items are unmodified and un-migrated. |
| AC12 | `git diff --name-only` reports only `docs/workflow.md` and `docs/artifact-conventions.md`. |
| AC13 | `bash tests/run.sh` passes; no command/agent/skill or inventory count changes. |

## Acceptance criteria coverage map

AC1→T4,T7 · AC2→T1,T3 · AC3→T1,T3,T5 · AC4→T3 · AC5→T5 · AC6→T5 · AC7→T1,T5 ·
AC8→T2,T5,T6 · AC9→T2,T4,T6,T7 · AC10→T5,T8 · AC11→T1,T3,T5,T8 ·
AC12→T6,T8 · AC13→T8.
