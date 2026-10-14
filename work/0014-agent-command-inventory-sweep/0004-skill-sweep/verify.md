---
feature: 0014-agent-command-inventory-sweep/0004-skill-sweep
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Verification — Skill-surface recursive sweep

## Summary

All fourteen acceptance criteria and every spec edge case are verified against
the **current working tree** by the full committed suite plus an independent,
read-only, falsifiable assertion harness (67 assertions, `0 failed`). **No
acceptance-criterion defect was found.** The implementation diff matches the
AC14 scope fence exactly: only the three named `.opencode/skill/**/SKILL.md`
files and this item's `tasks.md` are modified, and no unexpected untracked file
exists. The committed suite is green (`503 passed, 0 failed, 0 skipped`).

There is no `work/0014-agent-command-inventory-sweep/0004-skill-sweep/challenges.md`,
so there was no open challenge to adjudicate. There is no `backtracks.md` for this
item, so no open finding targeted its phases.

Verification reads the working tree: the change is uncommitted (`/build` does not
commit), and if a later edit changes the tree before `/review`, this record must
be re-confirmed. No production file was modified by this phase.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | **PASS** | `TOTAL: 503 passed, 0 failed, 0 skipped`; exit `0`. Full committed suite against the working tree (AC13). |
| `FRAMEWORK_TEST_AREAS=96-signature-sweep bash tests/run.sh` | **PASS** | `TOTAL: 86 passed, 0 failed, 0 skipped` (AC9). |
| `FRAMEWORK_TEST_AREAS=40-inventory bash tests/run.sh` | **PASS** | `TOTAL: 39 passed, 0 failed, 0 skipped` (AC13; 11 skills intact). |
| `FRAMEWORK_TEST_AREAS=85-conflict-guards,88-renumber-sweep bash tests/run.sh` | **PASS** | `TOTAL: 57 passed, 0 failed, 0 skipped` (AC6 contract pins). |
| `FRAMEWORK_TEST_AREAS=20-lifecycle,25-review-severity-bar,10-readiness bash tests/run.sh` | **PASS** | `TOTAL: 113 passed, 0 failed, 0 skipped` (AC7/AC9 routing/derived-state surfaces). |
| independent harness (67 assertions, run via stdin) | **PASS** | `HARNESS TOTAL: 67 passed, 0 failed`. AC1–AC12, AC14 and the edge cases; detail below. |
| `grep -rni roadmap .opencode/skill/` | 5 hits, all labelled | AC12: only `merge-conflict`/`workflow-lifecycle`; every hit is a `roadmap.md` alias or `stale: roadmap` equivalent; `conventional-commits` has none. |
| `git diff --name-only` / `git ls-files --others --exclude-standard` | 4 tracked, 0 untracked | AC14: exactly the three skills + this item's `tasks.md`; no test/agent/command/doc/README file. |
| `git diff -U0 .opencode/skill/workflow-lifecycle/SKILL.md` | changes at `:25-30` only | AC9: no change inside the `## Which command now?` fenced block (`:32`). |

The independent harness was run directly through `bash` (stdin), not committed:
the spec's Non-goals (`Adding new committed fixtures (Roadmap 5)`) and AC14 fence
the change set, and the parent manifest assigns committed recursive guards to
Roadmap 5, a separate later invocation. No committed test file was added,
modified, or deleted — consistent with the sibling `0012-roadmap-deprecation/0002`
precedent.

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 — `merge-conflict` graph-fault heading is a manifest term and resolves each `Depends on` against the node's manifest | Harness: `**Manifest graph faults.**` present; `Roadmap graph faults` absent; `resolve every `Depends on`` and `in **its own** `Children` table`. `merge-conflict/SKILL.md:80-86`. | PASS |
| AC2 — DANGLING-DEP / CYCLIC-DEP / DRIFT-FACT rows use manifest terms; classes unchanged | Harness: exact row `DANGLING-DEP (b) a manifest `Depends on`…`; `CYCLIC-DEP (b) a cycle in a manifest dependency graph`; `DRIFT-FACT (d)` row unchanged; `a roadmap `Depends on`` and `a cycle in a roadmap dependency graph` absent. `:121,124,127`. | PASS |
| AC3 — planning-time DRIFT-FACT bullet names a decomposing child, not a roadmap child | Harness: `a decomposing child's own `design.md` declaration and its` + `parent `Children` `conflicts-with` cell`; `a roadmap child's own` absent. `:141-143`. | PASS |
| AC4 — reconcile procedure / `work/` reconcile subsection in manifest terms, behaviour unchanged | Harness: `re-checks the manifest dependency graph`, `manifest `Children` / `Depends on` tables`, `**Manifest `Children` rows**`; `roadmap dependency graph`, `roadmap `Children``, `Roadmap `Children`` absent. `:220,258,333`. | PASS |
| AC5 — graph re-check covers every manifest at any depth; no bare "In every `roadmap.md`" | Harness: `Re-check the manifest dependency graph.`, `For every decomposing node at any depth`, `its `manifest.md`` + `clearly-labelled legacy `roadmap.md` alias`; `In every `roadmap.md`` absent. `:349-350`. | PASS |
| AC6 — every finding code, class label, and the grammar line unchanged vs the authority | Harness: all eight codes present; `TEXTUAL-CONFLICT (a)/(b)`, `MISSING-CHILD (b)`, `UNLISTED-CHILD (b)`, `DUPLICATE-PREFIX (c)`, `DUPLICATE-CHILD (c)`, `DRIFT-FACT (d)`; grammar line byte-identical; no `(e)`/`DECLARED-`/`PLAN-`/`CONFLICT-`. Suite: `85-conflict-guards` green (pins `:106` grammar + `planning-time`). Authority rows `docs/workflow.md:1519-1526,858-861` match. | PASS |
| AC7 — `workflow-lifecycle` decomposing node nests to arbitrary depth; a child may decompose | Harness: `A decomposing node and its descendants nest to`, `**arbitrary depth**`, `a child may itself decompose`, `one further `/<MMMM-slug>` segment per`, `resolves to `work/<item-ref>/``. `:22-30`. | PASS |
| AC8 — legacy `roadmap.md` alias and `stale: roadmap` equivalent retained and labelled | Harness: `the legacy `roadmap.md` is the recognized` + `deprecated alias` (`:23`); `legacy `roadmap.md` alias` in derived-states (`:68`); `legacy `stale: roadmap` is accepted as` + `deprecated equivalent` (`:93`). | PASS |
| AC9 — routing block targets/signatures unchanged; `96-signature-sweep` still passes | Harness: fenced `## Which command now?` block extracted from working tree byte-equals `HEAD`; `git diff -U0` touches only `:25-30`. Suite: `96-signature-sweep` `86 passed, 0 failed`. | PASS |
| AC10 — `conventional-commits` example has no `roadmap`; round-trips through `flatten` and the superseded form | Harness: no `roadmap` in file; table row `0002-billing/0001-invoice-model` → `0002-billing+0001-invoice-model`; `feat/` and `plan/` examples use it; superseded `0002-billing-0001-invoice-model`; flatten/unflatten round-trips; `work/0002-billing` absent. `:77-94`. | PASS |
| AC11 — graph-fault bullet retains the clearly-labelled legacy alias with the manifest primary | Harness: `` `manifest.md`, or the legacy `roadmap.md` alias `` present within `**Manifest graph faults.**`. `:80-81`. | PASS |
| AC12 — every remaining case-insensitive `roadmap` occurrence is a labelled legacy-alias/equivalent mention | Harness: all 5 occurrences (merge-conflict `:81,350`; workflow-lifecycle `:23,68,93`) match `legacy|deprecated`; `grep -rni roadmap .opencode/skill/` finds no others. | PASS |
| AC13 — `bash tests/run.sh` exits 0, including `96` and `40` | Suite: `503 passed, 0 failed, 0 skipped`, exit `0`; `96` 86/0 and `40` 39/0 individually. | PASS |
| AC14 — only the three `.opencode/skill/**/SKILL.md` files changed (plus this item's `work/`) | Harness: `git diff --name-only` equals exactly the three skills + `work/0014-agent-command-inventory-sweep/0004-skill-sweep/tasks.md`; `git ls-files --others` empty. | PASS |

### Edge cases

| Edge case (spec) | How verified | Result |
| ---------------- | ------------ | ------ |
| Both manifest spellings | `:349-350` names `manifest.md` **and** the clearly-labelled legacy `roadmap.md` alias; harness asserts both. | PASS |
| Nested decomposition (depth ≥ 3) | Re-check/heading phrase "for every decomposing node at any depth" (`:80,349`); harness asserts the "any depth" wording. | PASS |
| Routing-block fixture parsing | Fenced block byte-identical to `HEAD`; `96-signature-sweep` extracts the routes and passes (`86/0`). Added depth prose is above the `## Which command now?` heading. | PASS |
| Example round-trip | Harness flattens `0002-billing/0001-invoice-model` → `0002-billing+0001-invoice-model`, unflattens back; `work/0002-billing` absent so no real-item collision. | PASS |
| Substrings | All 5 `roadmap` occurrences are labelled alias/equivalent; no bare current-concept term remains. | PASS |
| Cross-child consistency | Swept `DRIFT-FACT` wording ("a decomposing child's own `design.md` declaration and its parent `Children` `conflicts-with` cell") matches the authority clause (`docs/workflow.md:861`); `status.md` (owned by sibling `0002`) is untouched and still aligned-able. | PASS |
| Empty / no-op | `conventional-commits` was fully swept to zero `roadmap`; the two remaining files retain only labelled aliases. No already-correct text was churned beyond the spec'd scope. | PASS |
| Concurrency / UI | N/A by design: static prompt/doc text only; no runtime surface, so no `/visual` pass. | N/A |

## Gaps and residual risk

1. **No committed test area added — by design, with a coverage caveat.** The
   spec's Non-goal (`Adding new committed fixtures (Roadmap 5)`) and AC14 fence the
   change set to the three skill files; the parent manifest assigns committed
   recursive guards to **Roadmap 5**, a separate later invocation, and the design
   "Test strategy" plans verification by "those checks plus targeted greps". The
   focused per-AC assertions therefore live in the ephemeral, uncommitted harness
   recorded above (reproducible by re-running its commands), and the structural
   parts (routing block, finding vocabulary pins, inventory) remain guarded by the
   committed `96`, `85`, `88`, and `40`. A later regression that re-introduced a
   bare `roadmap term in one of these three skills would not be caught by the
   committed suite. Follow-up candidate for Roadmap 5: a committed skill-vocabulary
   guard. Recorded, not a defect of this item.
2. **Cross-child vocabulary alignment is pending.** `.opencode/agent/status.md:244`
   still says "a roadmap child's own `design.md` declaration" (and other bare
   `roadmap` terms); it is owned by sibling `0014-.../0002-supporting-agent-sweep`,
   which is not yet built (0 checked tasks). This sweep's wording matches the
   authority so `0002` can align without divergence; `status.md` is out of this
   item's scope (spec Non-goals; AC14). Not a defect here.
3. **Out-of-scope retired illustration remains.** `CONTRIBUTING.md:77` carries the
   same retired `0002-agentic-roadmaps+0001-roadmap-model` example, outside this
   spec's file scope; the design records it as a follow-up. Not a defect here.
4. **Uncommitted working tree.** Verification reads the working tree; `/build`
   does not commit. If a later edit changes the tree before `/review`, this record
   must be re-confirmed.
5. **Harness brittleness observed and corrected.** Three initial harness
   assertions failed on false positives — one inverted predicate and two patterns
   that spanned source line breaks (grep is line-based). Each was re-checked
   directly against the file and confirmed to be an assertion bug, not an
   implementation fault; the corrected harness is 67/0. No test was weakened,
   skipped, or deleted to obtain a pass.

## Not verified / out of scope

- `.opencode/agent/status.md`, other agent/command prompts (`0001`–`0003`), the
  inventories/doctor surfaces (`0005`), `CONTRIBUTING.md`/README/docs prose, and
  `tests/**` — all excluded by AC14; verified only that they were left untouched.
- The mutation self-check (`tests/mutation.sh`) was not run: this change adds no
  committed test area to mutate, and the committed suite is the verification
  vehicle.
- No UI surface: `/visual` is not applicable.
