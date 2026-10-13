---
feature: 0013-simultaneous-work-recursion/0001-recursive-allocation
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Review — Per-level sequence allocation and recursive duplicate detection

## Verdict

**approve** — the recursive duplicate-detection rule is authored once in
`docs/workflow.md` → "Multiple work items", the code mapping and depth-≥ 3 naming
satisfy AC1–AC5, the "Sequence allocation" cross-reference satisfies AC6/AC7,
scope is confined to the two authority documents (plus this item's own
artifacts), and no finding of any severity survives scrutiny.

## Diff reviewed

- Base ref: `git merge-base HEAD origin/main` →
  `85189569c55b7f1a1ac7b19a50316f9e5e74a0b8`, identical to `HEAD` and
  `origin/main` (the plan for this item was merged as PR #69). The build change is
  **uncommitted working-tree state**, so the diff is `git diff` (there is no
  `base...HEAD` range). Commands run: `git log --oneline -15`, `git status`,
  `git merge-base HEAD origin/main`, `git diff`, plus Read/Grep over
  `docs/workflow.md`, `docs/artifact-conventions.md`,
  `.opencode/skill/merge-conflict/SKILL.md`, `.opencode/agent/status.md`, the
  parent `work/0013-simultaneous-work-recursion/manifest.md`, and `tests/checks/*`.
- Change set (tracked): `docs/workflow.md` (the "Multiple work items" paragraph,
  old lines 1379–1388, replaced by the recursive rule at lines 1379–1409),
  `docs/artifact-conventions.md` (one 5-line cross-reference sentence inserted
  after the per-level `MMMM` paragraph, lines 689–692), and this item's own
  `tasks.md` (check-boxes T1–T4 → `[x]`). New untracked file: this item's
  `verify.md`. No other file is touched (`git status`).
- No `work/0013-simultaneous-work-recursion/0001-recursive-allocation/challenges.md`
  exists, so there was no open challenge to adjudicate.
- No `visual.md` exists (documentation-only item; no UI surface).

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — rule reaches arbitrary depth | **met** | `docs/workflow.md:1380-1386`: "Duplicate `4`-digit prefixes are checked at **every node** of the recursive tree, not only the top level plus one child layer; each decomposing node at any depth is checked against **its own immediate children**". The old two-level sentence ("scan the top-level `work/` directories — and each decomposing parent's child directories") is removed (grep for `scan the top-level` returns nothing). |
| AC2 — per-node scan model | **met** | `docs/workflow.md:1382-1386`: "each decomposing node at any depth is checked against **its own immediate children**, independently, and the top level is checked against the top-level items. No node's check depends on another's" — names both tree positions and the independence. |
| AC3 — code mapping at every depth | **met** | `docs/workflow.md:1388-1395`: `DUPLICATE-PREFIX` = "two **top-level** `NNNN` prefixes are equal"; `DUPLICATE-CHILD` = "two **same-parent** `MMMM` prefixes are equal, at any depth"; mutual exclusion stated ("never reported as `DUPLICATE-CHILD`" / "never reported as `DUPLICATE-PREFIX`"). Consistent with the shipped canonical table (`.opencode/skill/merge-conflict/SKILL.md:118-119`). |
| AC4 — depth-≥ 3 derived and named | **met** | `docs/workflow.md:1395-1399`: a `DUPLICATE-CHILD` finding "names both offenders by their **full canonical reference**; when the collision is at depth ≥ 3 — for example two grandchildren, `<parent>/<MMMM-slug>-a` and `<parent>/<MMMM-slug>-b` — it also names the **shared parent and shared local prefix** in the detail". |
| AC5 — shipped vocabulary reused | **met** | `docs/workflow.md:1399-1401`: "Findings use the class `(c)` label and the finding grammar of `## Merge conflicts`; this rule introduces no new code, class, or vocabulary." The referenced grammar is `- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>` (`.opencode/skill/merge-conflict/SKILL.md:94-100`). No new code/class/severity token is introduced. |
| AC6 — single authority, no competing rule | **met** | The rule is stated in `docs/workflow.md` → "Multiple work items" (`:1368`); `docs/artifact-conventions.md:689-692` is a pointer only ("detected by the recursive rule stated once in `docs/workflow.md` → 'Multiple work items'; this section defines no duplicate-detection rule of its own"). No second rule is added; the `## Merge conflicts` section and "Renumbering after a parallel merge" are explicitly `0002`'s and untouched. |
| AC7 — allocation unchanged | **met** | The only `docs/artifact-conventions.md` hunk is the 5-line insertion after the per-level `MMMM` paragraph (`:681-687`); the allocation contract (`:670-687`) and `### Renumbering after a parallel merge` (`:694-725`) are byte-identical (`git diff`). |
| AC8 — scope and boundary | **met** | `git status` / `git diff --name-only` = `docs/workflow.md`, `docs/artifact-conventions.md`, and this item's own `tasks.md` (builder boxes) only. `## Merge conflicts`, `### Lifecycle placement`, `### Renumbering after a parallel merge`, `.opencode/agent/status.md`, `.opencode/skill/merge-conflict/SKILL.md`, `README.md`, and every fixture are untouched; no new command/agent/skill. The two hunks fall only under `## Multiple work items` and `## Sequence allocation`. |
| AC9 — suite stays green, inventory unchanged | **met (on reported evidence + static audit)** | `verify.md` reports `bash tests/run.sh` → `TOTAL: 495 passed, 0 failed, 0 skipped` and `FRAMEWORK_TEST_AREAS=40-inventory` → `39/0/0`, with `README.md` unmodified. This read-only session cannot execute the suite (bash is restricted to git/ls/cat), so I audited the guards that read these two documents (see "Not reviewed") — none pins a literal this diff removed or altered. `40-inventory.sh` reads only `README.md` counts and `.opencode/{agent,command,skill}/`; none is touched, so no documented inventory count can drift. |
| AC10 — backward compatibility | **met** | The change is a strict generalization of the removed two-level sentence: a standalone `NNNN-slug` and an existing two-level parent/child remain covered by the per-node scan; no allocation text, `Depends on` edge, readiness rule, or renumber procedure changed (`git diff`), and no committed `work/` item or `ship.md` is modified. |

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Grandchild collision (depth 3) | `docs/workflow.md:1396-1399` explicit `<parent>/<MMMM-slug>-a` / `<parent>/<MMMM-slug>-b` example | met |
| Deeper collision (depth ≥ 4) | `docs/workflow.md:1381-1382` "every node … at any depth"; no special case | met |
| Top-level collision | `docs/workflow.md:1391,1394` `DUPLICATE-PREFIX`, "never reported as `DUPLICATE-CHILD`" | met |
| Same local id text under different parents | `docs/workflow.md:1384-1386` "identity is the full canonical path, not the trailing segment" | met |
| Pure container vs. hybrid node | `docs/workflow.md:1382` checks "each decomposing node … against its own immediate children" (no distinction) | met |
| Parent with zero or one child | Derives from the per-node scan: no same-parent pair exists, so no collision; the rule's no-op/never-error behavior is the guard's (report-only) contract owned by `0002` | deferred (owned by `0002`) |
| Empty `work/` tree | Derives from the per-node scan: no nodes → no pairs; the report-only, no-error behavior is `0002`'s guard contract | deferred (owned by `0002`) |
| Already-shipped offender / report-only | Detection is report-only and adds no readiness edge; the non-fatal guard contract is `0002`'s | deferred (owned by `0002`) |
| Concurrency | The rule reads committed `work/` state, local and report-only; enforcement lives on the guard surface owned elsewhere | deferred (owned by `0002`) |

## Findings

### Blockers

- none.

### Major

- none.

### Minor

- none.

### Nits

- none.

## Observations (not raised as findings)

- **The inserted cross-reference sentence's scope word "this section".** The
  sentence lives inside `## Sequence allocation` (`docs/artifact-conventions.md:668`),
  whose nested `### Renumbering after a parallel merge` subsection (`:694-721`)
  includes a "Detect" step that describes identifying a duplicate `4`-digit
  prefix. Strictly, "this section defines no duplicate-detection rule of its own"
  reads slightly broader than the allocation contract it means. This is **not
  raised**: the spec explicitly assigns "Renumbering after a parallel merge" to
  `0002-recursive-merge-integrity` and fixes this exact pointer sentence in
  `design.md:89-92`; the sentence's "of its own" qualifier makes it a
  single-authority pointer, not a claim about the sibling-owned procedure, and no
  acceptance criterion is affected. Recorded for transparency only.
- **The design's sample finding line is not reproduced verbatim.**
  `design.md:136-138` illustrates `- [DUPLICATE-CHILD] (c) <parent>/0002-api,
  <parent>/0002-web — …`; the authored rule states the same *requirement* in prose
  (`docs/workflow.md:1395-1399`) rather than the literal example. No AC requires
  the literal example, so this is not a defect; `verify.md:75-81` already notes it.

## Not reviewed

- Independent execution of `bash tests/run.sh`: the read-only bash allowlist
  denies arbitrary program execution, so AC9 rests on `verify.md`'s recorded
  `495/0/0` (plus the `40-inventory` subset) and on a static audit of the guards
  that read the changed documents. I read `10-readiness.sh` (readiness literals in
  "Dependencies and readiness"), `20-lifecycle.sh` (derived-state routing and
  command↔agent pairs), `80-cycle-fixture.sh` (`CYCLIC-DEP` / cycle literals),
  `85-conflict-guards.sh` (`## Declared-conflict check`), `87-backtrack-guards.sh`
  (the `$CONV`/`$WF` contract-pin tables, all in untouched sections),
  `96-signature-sweep.sh` (extracts only `### <n>. ` phase headings and the
  `/visual` routing bullet, so the changed prose cannot feed its sweep), and
  `40-inventory.sh` (reads only `README.md` counts + `.opencode/` sets). No pinned
  literal is removed or altered by this diff.
- The `status` agent's duplicate step/bullets, the `merge-conflict` skill's
  "per-parent roadmap child numbers" restatement, `README.md`, `AGENTS.md`,
  `template/AGENTS.md`, and the fixtures — explicitly deferred by the spec's
  non-goals to `0002-recursive-merge-integrity` and Roadmap 4; untouched by the
  diff.
- `conflicts-with` at every level (`0003`), parallel plan publication / `/build`
  plan gate (`0004`), and committed recursive-duplicate guards/fixtures
  (Roadmap 5) — explicitly deferred by the spec's non-goals; untouched.
- UI/visual pass: documentation-only item, no user-facing surface; no `visual.md`
  exists and none is expected.
- `challenges.md` does not exist for this item; no challenge required
  adjudication.

## Notes on review method

- **Correctness.** The rule is a strict generalization of the removed sentence:
  the per-node scan, the top-level-vs-same-parent code mapping, the mutually
  exclusive reporting, and the depth-≥ 3 full-canonical-reference + shared
  parent/prefix naming are each present and internally consistent with the shipped
  `merge-conflict` skill vocabulary. The `docs/workflow.md` block quotes the exact
  prose fixed in `design.md:41-71`; the `docs/artifact-conventions.md` insertion
  matches `design.md:89-92`.
- **Security / secrets.** Documentation-only; no code, credential, token, or
  executable surface is introduced.
- **Tests.** No committed test was added — by design, not omission: the spec's
  non-goals defer committed recursive-duplicate guards/agreement areas/mutation
  coverage to Roadmap 5 and state "this item adds no test file"
  (`spec.md:87-89,279`). Verification is the tester's static-content assertions
  plus the unchanged suite.
- **Scope.** `git status` confirms the two authority documents plus this item's own
  phase artifacts; the `tasks.md` diff is check-box ticks only. No scope creep and
  no unrelated change.
- **Backward compatibility.** No allocation, readiness, `Depends on`, renumber, or
  shipped-item change; the two-segment form remains a covered special case of the
  recursive rule.
