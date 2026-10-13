---
feature: 0013-simultaneous-work-recursion/0001-recursive-allocation
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
notes: "Documentation-only change (two authority docs). No committed test file was added: the spec's non-goals explicitly defer committed recursive-duplicate guards/fixtures to Roadmap 5 and state 'this item adds no test file' (spec.md:87-89, 279). Verification is static content inspection plus the repository's own suite. No open challenge (challenges.md absent); no prior verify.md defect. Ordinary forward work, item unshipped."
---

# Verification — Per-level sequence allocation and recursive duplicate detection

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | exit 0; `TOTAL: 495 passed, 0 failed, 0 skipped` |
| `FRAMEWORK_TEST_AREAS=40-inventory bash tests/run.sh` | PASS | exit 0; `TOTAL: 39 passed, 0 failed, 0 skipped` (inventory counts intact) |
| `git diff --name-only` | PASS | `docs/workflow.md`, `docs/artifact-conventions.md`, `work/.../0001-recursive-allocation/tasks.md` (builder boxes only) |
| `git diff --stat -- README.md` | PASS | empty — no documented inventory/count surface touched |
| `git diff -U0 -- docs/workflow.md docs/artifact-conventions.md \| grep '^@@'` | PASS | exactly two hunks: `@@ -1380,9 +1380,30 @@` (Multiple work items) and `@@ -688,0 +689,5 @@` (Sequence allocation insertion); none under an excluded heading |
| `grep -nE 'every node\|own immediate children\|top level is checked against the top-level items' docs/workflow.md` | PASS | matches at 1381–1384 |
| `grep -nE 'DUPLICATE-PREFIX\|DUPLICATE-CHILD' docs/workflow.md` | PASS | rule mapping at 1391–1395 |
| `grep -n 'scan the top-level' docs/workflow.md` | PASS | no match — old two-level wording removed |
| `grep -c 'detected by the recursive rule stated once' docs/artifact-conventions.md` | PASS | `1` — single cross-reference, no restatement |

## Acceptance coverage

For a prose deliverable, each criterion's test is a targeted static-content
assertion against the two authority documents (`file:line` cited), backed by the
full suite. Each assertion was executed; see "Commands run".

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — rule reaches arbitrary depth | static: `docs/workflow.md:1381-1386` ("checked at **every node** of the recursive tree, not only the top level plus one child layer", "each decomposing node at any depth") | PASS |
| AC2 — per-node scan model | static: `docs/workflow.md:1382-1384` ("its own immediate children, independently", "the top level is checked against the top-level items", "No node's check depends on another's") | PASS |
| AC3 — code mapping at every depth | static: `docs/workflow.md:1391-1395` (`DUPLICATE-PREFIX` = top-level `NNNN`; `DUPLICATE-CHILD` = same-parent `MMMM`, "at any depth"; mutual exclusion stated) | PASS |
| AC4 — depth ≥ 3 derived and named | static: `docs/workflow.md:1395-1399` ("both offenders by their **full canonical reference**"; depth ≥ 3 grandchild example; "**shared parent and shared local prefix** in the detail") | PASS |
| AC5 — shipped vocabulary reused | static: `docs/workflow.md:1392,1400-1401` (class `(c)` label + "finding grammar of `## Merge conflicts`"; "introduces no new code, class, or vocabulary"); referenced grammar exists at `.opencode/skill/merge-conflict/SKILL.md:94-100,118-119` | PASS |
| AC6 — single authority, no competing rule | static: rule stated once in `docs/workflow.md` "Multiple work items" (`:1368`); `docs/artifact-conventions.md:689-692` is a pointer only ("this section defines no duplicate-detection rule of its own"); no other new duplicate-detection prose | PASS |
| AC7 — allocation unchanged | static: `git diff` shows the only `artifact-conventions.md` hunk is the 5-line insertion after the per-level `MMMM` paragraph; allocation paragraph `docs/artifact-conventions.md:670-687` byte-identical | PASS |
| AC8 — scope and boundary | static: `git diff --name-only` = docs + builder's `tasks.md` only; the two hunks are in "Multiple work items" and "Sequence allocation"; nothing inside `## Merge conflicts`, `### Lifecycle placement`, or `### Renumbering after a parallel merge`; no new command/agent/skill | PASS |
| AC9 — suite green, inventory unchanged | `bash tests/run.sh` → exit 0, 495/0/0; `FRAMEWORK_TEST_AREAS=40-inventory` → 39/0/0; `README.md` unmodified; no `work/**` shipped file or `ship.md` touched | PASS |
| AC10 — backward compatibility | static: diff changes no allocation text, `Depends on`, readiness, or the renumber procedure; the new rule is a strict generalization of the removed two-level sentence (standalone `NNNN-slug` and two-level parent/child remain covered) | PASS |

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Grandchild collision (depth 3) | `docs/workflow.md:1396-1399` — explicit `<parent>/<MMMM-slug>-a` / `<parent>/<MMMM-slug>-b` example | PASS |
| Deeper collision (depth ≥ 4) | `docs/workflow.md:1381-1382` — "every node … at any depth"; no special case | PASS |
| Top-level collision | `docs/workflow.md:1391,1394` — `DUPLICATE-PREFIX`, "never reported as `DUPLICATE-CHILD`" | PASS |
| Same local id under different parents | `docs/workflow.md:1384-1386` — "identity is the full canonical path, not the trailing segment" | PASS |
| Pure container vs. hybrid node | `docs/workflow.md:1382` — "each decomposing node at any depth is checked against its own immediate children" (no distinction) | PASS |
| Parent with zero or one child | Derived: no same-parent pair exists, so no collision — a consequence of the per-node scan (`:1382-1384`); no explicit sentence required by any AC | MANUAL (derived) |
| Already-shipped offender / report-only, no readiness change | Out of scope by design: the non-fatal, report-only guard contract is `0002-recursive-merge-integrity`'s (spec non-goals; AC8). This rule adds no readiness edge and blocks no phase (`docs/workflow.md:1403-1409` routes handling through renumber/`## Merge conflicts`) | MANUAL (out of scope) |
| Empty `work/` tree | Derived: no nodes → no pairs → no finding, no error (same per-node scan semantics); not separately required by an AC | MANUAL (derived) |
| Concurrency | Derived: the rule reads committed `work/` state and is local/report-only; enforcement is the `status`/guard surface owned elsewhere, not this rule text | MANUAL (derived) |

## Gaps and residual risk

- **No committed regression test was added — by design, not omission.** The
  spec's non-goals explicitly defer committed fixtures/agreement areas/mutation
  coverage pinning the recursive duplicate rule to a successor roadmap and state
  "this item adds no test file" (`spec.md:87-89, 279`). Adding one would violate
  the spec's scope. Evidence therefore rests on the static-content assertions
  above plus the unchanged green suite. This is the expected verification level
  for a documentation-only deliverable.
- **Sibling surfaces still carry the older two-level wording** — the `status`
  agent's duplicate step and the `merge-conflict` skill's "per-parent roadmap
  child numbers" (`.opencode/skill/merge-conflict/SKILL.md:69-90`). The spec
  defers this sweep to Roadmap 4 / `0002` (non-goals, `spec.md:83-86`), and the
  surfaces are report-only and not contradictory in effect. Recorded, not a
  defect here.
- **The design's concrete sample finding line** (`design.md:136-138`,
  `- [DUPLICATE-CHILD] (c) <parent>/0002-api, <parent>/0002-web — …`) is not
  reproduced verbatim in the authored rule. The prose requirement it illustrated
  (full canonical reference for both offenders; shared parent + shared local
  prefix at depth ≥ 3) is present at `docs/workflow.md:1395-1399`, and no
  acceptance criterion requires the literal example. Observation only; no AC is
  affected.
- **Derived edge cases** (parent with 0/1 child, empty tree, concurrency,
  shipped-offender report-only) are consequences of the scan semantics or
  enforcement surfaces owned by other items; no acceptance criterion requires
  their explicit statement. Low residual risk.
- **Verification is read-only and did not exercise runtime behavior** — there is
  none; the deliverable is normative prose. A reviewer should confirm the prose
  is the intended normative contract.

No failing tests, no defects, no open challenges. `tasks.md` T1–T4 are all `[x]`.
