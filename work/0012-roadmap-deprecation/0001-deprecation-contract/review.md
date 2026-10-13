---
feature: 0012-roadmap-deprecation/0001-deprecation-contract
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Review — Deprecation contract: the generic manifest replaces the special `roadmap` concept

## Verdict

**approve** — all thirteen acceptance criteria are met by the two authority
documents, the change extends the shipped recursive vocabulary without forking
it, scope is confined to the two documents plus this item's own artifacts, and
no finding of any severity survives scrutiny (the two conditions a prior review
pass raised are resolved in the current tree).

## Diff reviewed

- Base ref: `git merge-base HEAD origin/main` → `d869557970ede87f83f261fd4028d52192a3db3c`,
  identical to `HEAD` and `origin/main`. The change is **uncommitted working-tree
  state**, so the diff is `git diff` (there is no `base...HEAD` range). Commands
  run: `git log --oneline -10`, `git status`, `git rev-parse HEAD`,
  `git merge-base HEAD origin/main`, `git diff --stat`, `git diff --name-only`,
  `git diff -- docs/artifact-conventions.md`, `git diff -- docs/workflow.md`,
  `git diff -- work/0012-roadmap-deprecation/0001-deprecation-contract/tasks.md`,
  plus Read/Grep over the two documents, `tests/checks/*`, and the fixtures.
- Change set (tracked): `docs/artifact-conventions.md` (60 lines), `docs/workflow.md`
  (201 lines), and this item's own `tasks.md` (check-boxes only, T1–T8 → `[x]`).
  New untracked files: this item's `verify.md` and `review.md`. No other file is
  touched (`git diff --name-only`).
- No `work/0012-roadmap-deprecation/0001-deprecation-contract/challenges.md`
  exists, so there was no open challenge to adjudicate.
- No `visual.md` exists (documentation-only item; no UI surface).

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — sole child-enumeration artifact | **met** | `## Roadmaps` retitled to `## Decomposing nodes and the manifest` (`docs/workflow.md:176`); "The manifest is the sole child-enumeration artifact of a decomposing node, at every depth" (`docs/workflow.md:188-191`); generic definition `docs/artifact-conventions.md:129-142`. No competing child-enumeration artifact is defined. |
| AC2 — concrete spelling and `phase` value | **met** | `phase` value list `docs/artifact-conventions.md:20`; template heading `:127`; concrete-spelling sentence `:137-138`; template body `phase: manifest` `:147`; H1 `# Manifest — <initiative title>` `:153`; writer path `docs/workflow.md:77-83`. |
| AC3 — legacy alias recognized | **met** | "`work/<item-ref>/roadmap.md` carrying `phase: roadmap` is a **recognized deprecated alias** for the manifest … never rewritten or migrated" (`docs/workflow.md:53-57`); `docs/workflow.md:190-191`; `docs/artifact-conventions.md:138-141`. Corroborated by the suite's `80`/`85`/`87` areas loading `roadmap.md` fixtures unchanged. |
| AC4 — new manifests use modern spelling | **met** | "new manifests always use `manifest.md` with `phase: manifest`" (`docs/workflow.md:56-57`); writer prose `:77-83`; `### 2. Design` prose `:467,479-483`. |
| AC5 — precedence when both spellings present | **met** | status integrity `DRIFT-FACT` rule: both spellings or a mismatched spelling/`phase` pairing reported, `manifest.md` authoritative, "never silently merged, dropped, normalized, or auto-repaired" (`docs/workflow.md:340`); merge-integrity invariant `:1470`. |
| AC6 — derived container phase | **met** | prose "derives the container phase `manifest`; Own artifacts take precedence over the manifest at every depth" (`docs/workflow.md:1223-1227`); table row `:1237` → `manifest`; decomposing-node paragraph `:1297-1301`. |
| AC7 — `phase` value set recognizes the rename | **met** | `docs/artifact-conventions.md:20` lists `manifest` in place of `roadmap`; legacy `phase: roadmap` documented as the deprecated equivalent `:138-141`. |
| AC8 — parent-manifest label and `stale:` token renamed | **met** | reverse-edge row `docs/workflow.md:890` (`parent `manifest.md`` / `manifest.md` / `### Revising a decomposition`); `stale: manifest` maps to `spec` with legacy `stale: roadmap` accepted `:1253-1256`; artifact-conventions `stale` note `:51-58` keeps `spec \| design \| build \| test \| review` contiguous. |
| AC9 — vocabulary retires to the generic term | **met** | no `## Roadmaps`, `### Revising a roadmap`, or `"Roadmaps"` remains in either document; the retitled headings exist (`docs/workflow.md:176`, `:351`). Full `roadmap` sweep of both docs (22 hits in `workflow.md`, 3 in `artifact-conventions.md`) classifies every hit as a deprecated/BC literal, the deprecated `/roadmap` command alias, or the `0004-roadmap-revision` identifier; no concept noun survives. |
| AC10 — extend, do not fork | **met** | six-column `Children` header, `conflicts-with` grammar (`ConflictTargetList`/`ConflictTarget`/`SiblingOrItemRef`/`SurfacePath`), reference grammar, and the finding-code set are unchanged; the new inconsistency reuses the shipped `(d)` class and `DRIFT-FACT` code (`docs/workflow.md:340,1470`). No new `phase` value, dependency edge, or state model. |
| AC11 — backward compatibility | **met** | only this item's own `tasks.md` shows a `work/` diff; no other item is rewritten, no spent number changes, no `ship.md` touched (`git status --short -- work/`). Standalone items keep their derivation (`docs/artifact-conventions.md:102-103`). |
| AC12 — scope | **met** | `git diff --name-only` (implementation) lists only `docs/artifact-conventions.md` and `docs/workflow.md`; `.opencode/command/roadmap.md`, `.opencode/agent/roadmap.md`, the inventories, fixtures, and existing `work/*/roadmap.md` parents are untouched. |
| AC13 — suite stays green | **met (on reported evidence)** | `verify.md` reports `bash tests/run.sh` → `TOTAL: 489 passed, 0 failed, 0 skipped`. This read-only session cannot execute the suite (bash is restricted to git/ls/cat), so I instead read the guards that pin these documents — `10-readiness.sh` (`satisfied(dep_local_id):`, `presence is the sole shipped signal`, `ship.md. presence takes precedence`), `20-lifecycle.sh` (derived-state routing literals, artifact names), `80-cycle-fixture.sh` (`phase: roadmap` fixture, `CYCLIC-DEP`, `integrity findings rather than failing`), `87-backtrack-guards.sh` (contract-pins `:950-986`, including the contiguous `spec | design | build | test | review`, `stale: ""`, `reopened: ""`, the five intra-item edge rows), `85-conflict-guards.sh` (`## Declared-conflict check`), and `96-signature-sweep.sh` (`WF_REQUIRED` excludes `/roadmap`; the routing-heuristics extraction targets only `/visual`) — none pins a literal this diff changed. |

## Findings

### Blockers

- none.

### Major

- none.

### Minor

- none.

### Nits

- none.

Both conditions a prior review pass raised are resolved in the current tree:
the stale "depth-limited" qualifier in the model intro is gone (`docs/workflow.md:32-35`
now reads "the manifest spelling described in 'Decomposing nodes and the manifest'"),
and the rewritten reference example now uses a distinct top-level number
(`docs/artifact-conventions.md:98-101` pairs `work/0007-billing/` with the real
`work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/`), removing the
`0007` collision. The `DRIFT-FACT` bullet leaves one long prose line
(`docs/workflow.md:1227`); the document already carries pre-existing prose lines of
comparable length (e.g. `docs/workflow.md:1424`, `:1451`), so this is not a
convention violation and is not raised.

## Not reviewed

- The `.opencode/agent/*`, `.opencode/command/*`, `.opencode/skill/*`, `README.md`,
  `AGENTS.md`, `template/AGENTS.md`, `tests/checks/40-inventory.sh`,
  `96-signature-sweep.sh`, and the `tests/` fixtures/guards — explicitly deferred
  by the spec's non-goals to `0002-command-retirement`, `0003-parent-migration`,
  and Roadmaps 4/5. For the record: the retitle leaves the old heading names
  referenced from `.opencode/command/plan.md`, `.opencode/command/roadmap.md`,
  `.opencode/agent/architect.md`, `.opencode/agent/product.md`, and
  `.opencode/agent/roadmap.md`; `verify.md` records this as a spec-deferred
  interim incoherence, and it is outside this item's AC9 scope (the two authority
  documents).
- The seven existing `work/*/roadmap.md` parents and their `.gitkeep` children —
  no migration is in scope (AC3/AC11); only that they are untouched was checked.
- `visual.md` — not applicable (no UI surface).
- Residual risk accepted by the design and re-stated in `verify.md`: no committed
  guard pins the rename (`design.md` → "Test strategy"; the spec's Roadmap-5
  non-goal), so the contract is asserted by the tester's read-only harness plus the
  suite's generic contract pins. Follow-up: Roadmap 5.

## Notes on review method

- Correctness: the four-part contract (identity, alias, precedence/reporting,
  state/vocabulary) is applied consistently across both documents, and the
  cross-references to the two renamed headings are updated in the same change.
- Security: documentation-only; no secrets, credentials, or executable surfaces
  introduced.
- Tests: the tester's `scratch/verify-0012-0001.sh` harness was described, not
  re-executed; the committed guards that touch these documents were read directly
  and none pins a changed literal.
- Scope: `git diff --name-only` confirms the two documents; this item's own
  `tasks.md` check-box updates and new `verify.md`/`review.md` are its own phase
  artifacts, not scope creep.
