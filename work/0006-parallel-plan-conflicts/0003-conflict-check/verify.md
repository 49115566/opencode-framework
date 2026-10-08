---
feature: 0006-parallel-plan-conflicts/0003-conflict-check
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "Final re-verification after the prior blocked pass [D1] and the review's [B1]. The builder fixed the operative prompt .opencode/agent/status.md:105-106 (step 8) to reference the authority instead of restating the narrowed compared set; the old phrase 'unshipped plans with a non-empty declaration' is gone from every live surface. Both the canonical suite (291/0, exit 0) and the item suite (123/0, exit 0) are green. This pass added a focused regression guard: a positive assertion that the authority considers every unshipped item, and a negative control for the narrowing phrase across all six operative prompt surfaces (not only status.md). No production surface was modified; only verify-tests.sh and this artifact changed."
---

# Verification — Pre-development parallel-plan conflict check

## Summary

This pass independently re-verifies the item after `/review` returned
`request-changes` ([B1]) and the prior `/test` pass returned `blocked` ([D1]).
Both defects shared one root cause: the compared set for the declared-conflict
check was narrowed to plans that themselves declare something, dropping the
one-sided case where plan `A` names a silent unshipped plan `B`.

- The authority (`docs/workflow.md` → `## Declared-conflict check`) already
  considered *every* unshipped item and treated a silent unshipped item as a
  one-sided counterpart (`docs/workflow.md:444, 466-472, 497-502`).
- The operative prompt that actually executes the check —
  `.opencode/agent/status.md` step 8 — now **references the authority** and no
  longer restates the narrowed compared set. The forbidden phrase
  `unshipped plans with a non-empty declaration` is absent from every live
  surface. **[D1] and [B1] are resolved.**
- The item suite was the thing that caught [D1]; this pass strengthens its
  regression guard from a single `status.md` negative control to all six
  operative prompt surfaces, plus a positive assertion on the corrected compared
  set.

The deliverable is documentation and prompts only (no runtime code, no committed
checker). The automatable evidence is the read-only item suite
`work/0006-parallel-plan-conflicts/0003-conflict-check/verify-tests.sh` plus the
canonical committed suite as the regression gate.

Results: canonical suite **291 passed, 0 failed, 0 skipped** (exit `0`); item
suite **123 passed, 0 failed** (exit `0`); `bash -n` clean. All 16 acceptance
criteria and all 18 listed edge cases are covered; no test was weakened, skipped,
or deleted.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS (exit 0) | `TOTAL: 291 passed, 0 failed, 0 skipped`; includes `40-inventory` and `96-signature-sweep` |
| `bash work/0006-parallel-plan-conflicts/0003-conflict-check/verify-tests.sh` | PASS (exit 0) | `TOTAL: 123 passed, 0 failed` |
| `bash -n work/0006-parallel-plan-conflicts/0003-conflict-check/verify-tests.sh` | PASS | shell syntax OK |
| `rg -n 'non-empty declaration' . --glob '!.git'` | control | Only `work/` phase artifacts (design.md, tasks.md, review.md, this file's prior text) remain; no live surface |
| `rg -n 'It considers every \*\*unshipped item\*\*' docs/workflow.md` | control | `444:` present — the corrected compared set |
| `git diff .opencode/agent/status.md` | control | Confirms step 8 was rewritten to reference the authority; the narrowing phrase removed |
| `git status --porcelain` | control | Modified surfaces match `design.md` "Affected areas"; no new agent; no out-of-scope surface |

## Acceptance coverage

Each "Test(s)" cell names the assertion group in `verify-tests.sh`. Criteria
whose behavior is a live LLM run are split: the documented contract is asserted
as content (deterministic), and the live run is listed as manual below the table.
The deliverable has no executable behavior, so content/consistency inspection is
the design's stated test strategy (`design.md` → "Test strategy").

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — no-arg report of every declared conflict, read-only, writes no file | AC1 (11 assertions: authority + command + read-only contract + `edit: deny` + no git-write tokens) | PASS (content); live run manual |
| AC2 — item-ref focuses on that item and names each counterpart | AC2 (4) | PASS |
| AC3 — `ship.md` excludes; absence includes; shipped still resolves | AC3 (3) | PASS |
| AC4 — conflict iff shared (resolved) target or one-sided naming; one finding per pair; silent unshipped counterpart | AC4 (14: pair-predicate, one-sided-suffices, silent counterpart, "every unshipped item", identity-by-resolution, once-per-pair, plus the narrowing-phrase negative control on all six operative surfaces) | PASS |
| AC5 — child set = own `design.md` ∪ parent `Children` cell; cell alone when no own | AC5 (3) | PASS |
| AC6 — shipped grammar and `(a)`–`(d)` class; no new class/code/policy | AC6 (10 + negative-control scan for `(e)`/new codes) | PASS |
| AC7 — malformed/unresolvable target reported, never dropped or repaired | AC7 (3) | PASS |
| AC8 — both present, sets differ → discrepancy, prefers neither | AC8 (3) | PASS |
| AC9 — no phase blocked; `/build` proceeds; informational only | AC9 (7 + readiness algorithm intact with no `conflicts-with` input) | PASS |
| AC10 — `/status` reports the same findings, modifies no file | AC10 (5) | PASS (content); live run manual |
| AC11 — `/build` gate surfaces the item's findings, advisory | AC11 (4) | PASS (content); live run manual |
| AC12 — committed `work/` + local repo only; no fetch/remote/merge/dry-run/lock/write | AC12 (11 + negative controls) | PASS |
| AC13 — planning-time only; does not reproduce pre-ship detection | AC13 (4) | PASS |
| AC14 — no declaration → no finding; historical items valid, no migration | AC14 (3) | PASS |
| AC15 — command + usage signature in every inventory; suite agreements green | AC15 (11) + `bash tests/run.sh` **291/0** (`40-inventory`, `96-signature-sweep`) | PASS |
| AC16 — one authoritative statement, referenced elsewhere, not restated | AC16 (8: authority counted once, grammar/predicate single-sourced, five surfaces reference the authority) | PASS |

Coverage: **16/16 acceptance criteria met.** AC15 was verified end-to-end by the
canonical suite, not only by inspection.

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| No unshipped plans / no declarations — empty report, no error | EDGE + AC14 | PASS |
| All plans shipped — compared set empty | EDGE | PASS |
| Declaration naming a shipped item — resolves, not a counterpart, no conflict/unresolved | AC3 + EDGE | PASS |
| Declaration naming a silent unshipped item (the [B1] case) — one-sided counterpart reported | AC4 (authority + all six operative surfaces) | PASS |
| Bare reference ambiguity — sibling-first precedence, not reinterpreted | EDGE | PASS |
| Existing directory target — resolved surface target | EDGE (consumed grammar) | PASS |
| Malformed surface target — glob / `..` / absolute | EDGE | PASS |
| Duplicate target in one list — malformed | EDGE (consumed grammar) | PASS |
| Empty/whitespace-only cell — malformed, not `—` | EDGE (consumed grammar) | PASS |
| Absent `conflicts-with` column — treated as `—` | AC5 + AC14 | PASS |
| Unspecced roadmap child with a parent declaration | EDGE | PASS |
| Both sides name each other — exactly one finding | AC4 | PASS |
| Both share a surface and name each other — one finding | AC4 | PASS |
| Many conflicts for one item — never truncated | EDGE | PASS |
| Concurrent invocations — no lock, write nothing | EDGE | PASS |
| Repeated runs — identical findings | EDGE | PASS |
| Cross-roadmap overlap — resolved like any in-flight item | AC4 + EDGE | PASS |

## Defect resolution

### [D1]/[B1] silent unshipped counterpart — RESOLVED

- **Was:** `.opencode/agent/status.md:105-106` instructed the agent to "build the
  set of unshipped plans with a non-empty declaration", excluding silent items
  and dropping the one-sided case that AC4 and the consumed `0001` authority
  require ("even if the other side is silent").
- **Now:** status step 8 reads: "Run the declared-conflict check
  (`docs/workflow.md` → `## Declared-conflict check`) … Reference that authority —
  do not restate its compared set, resolution, or pair predicate here."
  (`git diff .opencode/agent/status.md`). This also resolves the reviewer's [M3]
  (partial restatement) and [M1] (the class summary now includes `(a)`).
- **Proof:** the item suite's new negative control asserts the narrowing phrase is
  absent from all six operative surfaces (`status.md`, the merge-conflict skill,
  `conflicts.md`, `command/status.md`, `builder.md`, `command/build.md`) and its
  positive assertion confirms `docs/workflow.md` "considers every **unshipped
  item**". Both pass.

No open defects against the acceptance criteria remain.

## Gaps and residual risk

1. **The check is prompt behavior and cannot be executed deterministically
   offline (by design).** There is no committed checker, script, helper, or
   executable tool and no committed fixture/agreement area (AC12/AC13; spec
   non-goals). The item suite asserts the documented contract on every live
   surface; a real `/conflicts`, `/status`, or `/build`-gate run remains manual.
   Manual steps: run `/conflicts` (expect no findings in this tree); run
   `/conflicts 0006-parallel-plan-conflicts/0003-conflict-check` (focused form,
   named counterparts); on a throwaway branch, add two unshipped `design.md`
   files declaring the same surface and run `/conflicts` (expect one
   `[TEXTUAL-CONFLICT] (a)` line per pair), then one declaring a silent item
   (expect one `[TEXTUAL-CONFLICT] (b)` line).
2. **Identity-by-resolution narrows AC4's parenthetical "equal after trimming"
   (reviewer [M2]).** The authority defines target identity by resolution
   (`docs/workflow.md:491-496`), so equal reference tokens that resolve to
   different items are deliberately not shared. This is documented in
   `design.md` "Alternatives considered" and is consistent with the spec's `Bare
   reference ambiguity` / `Cross-roadmap overlap` edge cases, but it is a
   semantic reading of AC4 not among the user-resolved open questions. Not a
   blocker; the product agent should align the AC4 wording or record the
   interpretation.
3. **`design.md` §2 still states the superseded compared set.** `design.md:46`
   says the compared set is "unshipped plans with a non-empty declaration", which
   the review-driven authority correction to "every unshipped item"
   (`docs/workflow.md:444`) supersedes. The design is a historical architect-owned
   phase artifact; the tester does not edit another phase's file. Flagged for the
   architect/reviewer so the plan record does not contradict the shipped contract.
4. **The item suite is not wired into `tests/run.sh`; committed fixture/mutation
   coverage is deferred to `0004-conflict-guards` (deliberate).** A future edit
   that drops a check literal would not be caught by CI until `0004` lands; it is
   caught now only by re-running `verify-tests.sh` manually. It keys structural
   assertions on `git status --porcelain`, so it is meaningful only against the
   uncommitted working tree of this item (reviewer [N3]).
5. **Content criteria are literal-presence checks, not semantic proofs.** A
   passing assertion proves the mandated content is present, not that the
   surrounding prose is coherent end to end — which is why a contradictory
   paraphrase was able to slip past an earlier pass. This pass narrows that gap
   for the known [B1] phrasing across all operative surfaces, but a novel
   paraphrase could still evade. A reviewer should still read the contract.
6. **No UI, so no visual pass.** Documentation and prompts beneath a CLI
   lifecycle; `/visual` does not apply.

No test was weakened, skipped, or deleted; the regression guard was strengthened
(one assertion replaced by seven covering all operative surfaces and the
corrected compared set). Both suites are green, so this artifact is
`status: final`.
