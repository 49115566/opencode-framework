---
feature: 0012-roadmap-deprecation/0001-deprecation-contract
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Verification — Deprecation contract: the generic manifest replaces the special `roadmap` concept

## Summary

This is a documentation-only contract change to `docs/workflow.md` and
`docs/artifact-conventions.md`. All thirteen acceptance criteria and all ten
spec edge cases are verified against the **current working tree** by a committed
suite run plus independent, read-only, falsifiable document assertions. No
acceptance-criterion defect was found.

This run re-verifies the tree because the two documents were edited after the
earlier `verify.md` was written. The two conditions the downstream review pass
reported — a stale "depth-limited" qualifier in the model intro (M1) and a
rewritten reference example that reused a top-level sequence number (N1) — are
confirmed **absent** by direct grep (see "Commands run"); this `verify.md`
supersedes the earlier one.

There is no `work/0012-roadmap-deprecation/0001-deprecation-contract/challenges.md`,
so there was no open challenge to adjudicate.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | **PASS** | `TOTAL: 489 passed, 0 failed, 0 skipped`; exit 0. Includes `AC24 contract-pins`, `AC22 signature agreement`, and the `80`/`85`/`87` guard areas that load legacy `roadmap.md` fixtures. |
| `bash scratch/verify-0012-0001.sh` | 39 PASS / 1 FAIL | Read-only document-contract harness asserting AC1–AC12. The single failure is a **harness scoping bug**, not an AC failure: its AC11 assertion excluded only this item's `tasks.md`, so it counted this item's own new (untracked) `review.md`/`verify.md` as "other `work/` files". Corrected inline below. Every real AC assertion passes. |
| `git status --short -- work/ \| grep -v 'work/0012-roadmap-deprecation/0001-deprecation-contract/'` | PASS (empty) | AC11: no other `work/` item's file is changed. |
| `git status --short -- work/ \| grep 'ship.md'` | PASS (empty) | AC11: no `ship.md` touched. |
| `git diff --name-only -- . ':(exclude)work'` | `docs/artifact-conventions.md`, `docs/workflow.md` | AC12: implementation scope is the two documents only. |
| `git status --short -- .opencode README.md AGENTS.md template/ tests/` | PASS (empty) | AC12/AC13: no command, agent, skill, inventory, fixture, or README change. |
| `grep -n -i roadmap docs/workflow.md docs/artifact-conventions.md` | 19 + 3 hits, all classified | AC9: every remaining `roadmap` occurrence is a legacy/BC literal, the deprecated `/roadmap` command alias, or an identifier (full classification below). |
| `grep -rn 'depth-limited' docs/` | none | M1 condition absent. |
| `grep -nE '## Roadmaps\|Revising a roadmap\|"Roadmaps"' docs/*.md` | none | AC9: retired headings absent. |
| Finding-code set diff (`TEXTUAL-CONFLICT…DRIFT-FACT`, HEAD vs worktree, both docs) | identical | AC10: no new/removed finding code. |
| `git diff -U0 docs/` filtered for the six-column `Children` header | unchanged | AC10. |
| `git diff -U0 docs/` filtered for `ConflictTargetList`/`ConflictTarget ::=`/`SiblingOrItemRef`/`SurfacePath ::=` | unchanged | AC10: `conflicts-with` grammar untouched. |

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 sole child-enumeration artifact | Harness `AC1` group (4 assertions). `docs/workflow.md:188-191` ("The manifest is the sole child-enumeration artifact of a decomposing node, at every depth"); `docs/artifact-conventions.md:129-142` generic definition; no `## Roadmaps` heading; no competing `A **roadmap** is …`/`roadmap metadata` definition (`grep` → none). | PASS |
| AC2 concrete spelling and `phase` value | Harness `AC2` group (5). Template heading `docs/artifact-conventions.md:127` (`` ### `manifest.md` (manifest) — the manifest of a decomposing node ``), template body `:147` (`phase: manifest`), H1 `:153` (`# Manifest — <initiative title>`), concrete-spelling sentence `:137-138`; writer path `docs/workflow.md:77-83`. | PASS |
| AC3 legacy alias recognized | Harness `AC3` group (3). `docs/workflow.md:53-57` and `:190-191`; `docs/artifact-conventions.md:138-141` ("recognized deprecated alias", "never used for a new manifest"). Corroborated by the suite: `80-cycle-fixture`, `85-conflict-guards`, `87-backtrack-guards` load legacy `roadmap.md` fixtures and pass unchanged. | PASS |
| AC4 new manifests use modern spelling | Harness `AC4` (1). `docs/workflow.md:56-57` ("new manifests always use `manifest.md` with `phase: manifest`") and writer prose `:77-83`. | PASS |
| AC5 precedence when both present | Harness `AC5` group (4). `docs/workflow.md:340` (DRIFT-FACT: both spellings / mismatched spelling+`phase` reported, `manifest.md` authoritative, "never silently merged, dropped, normalized, or auto-repaired"); merge-integrity invariant `:1470`. | PASS |
| AC6 derived container phase | Harness `AC6` group (3). `docs/workflow.md:1222-1228` ("derives the container phase `manifest`"; "Own artifacts take precedence over the manifest at every depth"); table row `:1237` → `manifest`; decomposing-node paragraph `:1297-1301`. | PASS |
| AC7 `phase` value set recognizes rename | Harness `AC7` group (3). `docs/artifact-conventions.md:20` (`# spec \| design \| manifest \| tasks \| test \| visual \| review \| ship`); legacy `phase: roadmap` documented as deprecated `:138-141`. | PASS |
| AC8 parent-manifest label and `stale:` token renamed | Harness `AC8` group (4). Reverse-edge row `docs/workflow.md:890` (`| any child phase | parent `manifest.md` | `manifest.md` (see `### Revising a decomposition`) |`); `stale: manifest` maps to `spec` with legacy `stale: roadmap` accepted `:1253-1256`; `docs/artifact-conventions.md:53-58` keeps `spec \| design \| build \| test \| review` contiguous. | PASS |
| AC9 vocabulary retires to generic term | Harness `AC9` group (3). No `## Roadmaps`, `### Revising a roadmap`, or `"Roadmaps"`; new headings at `docs/workflow.md:176`, `:351`. Full `roadmap` sweep: all 22 hits classified (below). No surface defines a standalone "roadmap" concept. | PASS |
| AC10 extend, do not fork | Harness `AC10` group (4) + inline diffs. Six-column `Children` header unchanged (`docs/artifact-conventions.md:165` == HEAD `:160`); `conflicts-with` grammar, reference grammar, and finding-code set identical to HEAD; new inconsistency reuses `DRIFT-FACT` `(d)` (`docs/workflow.md:340,1470`). | PASS |
| AC11 backward compatibility | Corrected AC11 check (inline, PASS — see Commands run); harness `AC11` assertions "one-segment standalone form unchanged" and "no `ship.md` touched" PASS. Only this item's own artifacts changed; no other parent rewritten, no spent number or `ship.md` change. | PASS |
| AC12 scope | Harness `AC12` group (3) + inline. `git diff --name-only -- . ':(exclude)work'` → the two documents only; `.opencode/command/roadmap.md` and `.opencode/agent/roadmap.md` untouched; existing `work/` parents untouched. | PASS |
| AC13 suite stays green | `bash tests/run.sh` → 489 passed, 0 failed, 0 skipped; `git status` reports no `.opencode/`, `README.md`, `AGENTS.md`, `template/`, or `tests/` change, so no documented inventory count changed. | PASS |

### AC9 — full `roadmap` sweep (classification of every remaining hit)

`grep -n -i roadmap docs/workflow.md docs/artifact-conventions.md` (19 + 3 hits):

- `docs/workflow.md` — legacy literal / backward-compatibility handling:
  `53`, `56` (Terms legacy-alias note); `133` (backward-compat paragraph);
  `190`, `194` (legacy alias at the retitled section); `340` (DRIFT-FACT
  reporting rule naming both literal spellings, required by AC5); `1225`, `1237`,
  `1254`, `1297` (derived-state legacy alias); `1470` (merge-integrity
  one-manifest invariant).
- `docs/workflow.md` — deprecated `/roadmap` **command alias** (left for
  `0002-command-retirement` per the design boundary): `72`, `73`, `74`, `354`,
  `360`, `430`, `1346`.
- `docs/workflow.md` — existing identifier: `901` (`0004-roadmap-revision`).
- `docs/artifact-conventions.md` — legacy / backward-compatibility only: `55`
  (`stale: roadmap` deprecated equivalent), `105` (legacy `roadmap.md` alias),
  `139` (`roadmap.md` with `phase: roadmap` recognized deprecated alias).

No hit uses the term as a live concept noun; the retired section and sub-heading
are absent.

### Edge cases

| Edge case (spec) | How verified | Result |
| ---------------- | ------------ | ------ |
| Legacy-only parent | AC3 alias + AC6 `derives the container phase manifest`; suite `80`/`85`/`87` areas load legacy `roadmap.md` fixtures and pass | PASS |
| Both spellings present | AC5 `manifest.md` authoritative + "never silently merged, dropped, normalized, or auto-repaired"; DRIFT-FACT rule / derived-state precedence | PASS |
| Mismatched spelling and value | AC5/AC10: `workflow.md:340` names `manifest.md` + `phase: roadmap` and `roadmap.md` + `phase: manifest` as reported, not normalized | PASS |
| Modern-only node | AC2 (`manifest.md`/`phase: manifest` is the primary shape, `artifact-conventions.md:137-138`) | PASS |
| Deep nesting | AC2/AC6 language states "at every depth"; no depth-specific fork exists | PASS |
| Hybrid node | `workflow.md:181-186` (hybrid carries own artifacts alongside the manifest); own artifacts win (`:1226-1227`) | PASS |
| Shipped parent | AC11 — no `ship.md` touched; no rewrite performed | PASS |
| Standalone item | AC11 "one-segment standalone form is unchanged" (`artifact-conventions.md:102-103`) | PASS |
| `.gitkeep`-only child | `workflow.md:1297-1301` — a child with only `.gitkeep` is `not started`; no manifest | PASS |
| Concurrency | Not applicable: document-only change, no runtime state or shared resource (stated in spec) | N/A |

## Gaps and residual risk

1. **No committed guard was added — by design.** `design.md` → "Test strategy"
   states *"No new test file is added"*, and the spec's non-goals assign committed
   recursive-workflow guards to Roadmap 5. Consequence: the rename is asserted by
   this item's read-only, uncommitted harness plus the suite's generic contract
   pins (`87-backtrack-guards` AC24); a later regression renaming `manifest.md`
   back would not be caught by the committed suite. Follow-up: Roadmap 5.
2. **Dangling cross-references in out-of-scope prompt surfaces.** Retitling
   `## Roadmaps` → `## Decomposing nodes and the manifest` and `### Revising a
   roadmap` → `### Revising a decomposition` leaves the old heading names
   referenced from surfaces this item is forbidden to edit — e.g.
   `.opencode/agent/architect.md:44,80,125,210,218`, `.opencode/agent/product.md:123`,
   `.opencode/agent/roadmap.md`, `.opencode/command/plan.md:18`,
   `.opencode/command/roadmap.md` (16 hits via `git grep`). The spec explicitly
   defers these to `0002-command-retirement`/Roadmap 4 (Open questions,
   "Deferred — production surfaces that name the retired spelling/token"; AC12
   boundary). This is a **deferred interim incoherence, not an AC violation**;
   the reviewer should be aware that prompt cross-references are stale until
   `0002`/Roadmap 4 land.
3. **Two functional lines name the legacy literal** (`docs/workflow.md:340`,
   `:1470`). They are the `DRIFT-FACT` precedence/reporting rules required by AC5
   and are backward-compatibility handling, not a standalone concept definition,
   so AC9 holds; a strict reading of "only in a historical/backward-compatibility
   note" could question them. Recorded for the reviewer; no action recommended.
4. **Harness scoping bug (test artifact, not product).** The harness's AC11
   assertion excluded only `tasks.md` and so counted this item's own new
   `review.md`/`verify.md` as foreign changes. It was corrected inline
   (excluding the item's whole directory) and passes; the committed behavior
   under test was never at fault.

## Not verified / out of scope

- The `/roadmap` command and `roadmap` agent retirement, the documented
  inventories (`README.md`, `AGENTS.md`, `template/AGENTS.md`,
  `40-inventory.sh`, `96-signature-sweep.sh`), the seven existing decomposing
  parents, and the fixtures/guards that load `roadmap.md` — all explicitly
  `0002`/`0003`/Roadmap 4/5 scope. Verified only that this item left them
  untouched (AC12).
- No UI surface: `/visual` is not applicable.
