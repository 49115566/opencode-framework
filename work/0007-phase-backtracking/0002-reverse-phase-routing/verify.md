---
feature: 0007-phase-backtracking/0002-reverse-phase-routing
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
notes: "Deliverable is documentation/prompt wiring. AC1-AC11 are verified by recorded inspection of the named surfaces (the design's test strategy, and the spec non-goal that reserves committed fixtures/agreement areas/mutation coverage for 0007-backtracking-guards); AC12 is verified by the committed suite. No test files were added because the spec explicitly assigns routing guards to 0007. One inherited residual risk is noted (build->plan derivation when no verify/review artifact exists)."
---

# Verification — Reverse phase routing and upstream re-entry

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 340 passed, 0 failed, 0 skipped`; includes `20-lifecycle.sh` (AC7), `40-inventory.sh` (AC9), `96-signature-sweep.sh` (AC22), `95-split-guard.sh` shared-body parity (AC21) |
| `git diff --stat` | PASS | only the 9 planned surfaces + `tasks.md` changed; no added/removed files |
| `git ls-files --others --exclude-standard` | PASS | empty — no new file (no command/agent/skill/state file) |
| `git status --porcelain -- .opencode/agent .opencode/command .opencode/skill README.md tests/` | PASS | only `M` (modified) entries; no `A`/`D`/`??` |
| `grep -rn "stop and report\|route back\|stop and route"` over the named surfaces | PASS | only unrelated hits (secret guardrail, ship preconditions); no forward-only routing phrasing remains |
| `diff` of `AGENTS.md` vs `template/AGENTS.md` Handoff / artifact-contract / Backtracking sections | PASS | identical (`HANDOFF-OK`, `ARTIFACT-OK`, `BACKTRACK-OK`) |
| `git diff docs/workflow.md` on the Derived-state table rows | PASS | unchanged (exit 1 = no matching diff lines) |
| `git diff --stat -- docs/artifact-conventions.md` | PASS | empty — the 0001 record/marker authority is untouched |
| `grep -n "Solving..." phase Next lines` (`docs/workflow.md:220,240,261`) | PASS | Requirements, Design, Build `Next:` lines carry the reverse routes |

Inspection commands used per criterion are named in the matrix below. Because the
deliverable is prose/prompt wiring, every AC except AC12 is a recorded manual
inspection rather than a committed behavioral test; committed fixtures and
mutation coverage for the routing are explicitly `0007-backtracking-guards`'
scope (`spec.md` → Non-goals; `design.md` → Test strategy "The deliverable is
documentation/prompts …").

## Acceptance coverage

| Criterion | Test(s) / inspection evidence | Result |
| --------- | ------------------------------ | ------ |
| AC1 (`/build`→`/plan` record + `Next: /plan`) | `docs/workflow.md:261-264` (Build `Next`) and `:641-674` (Taking an edge + per-edge table, `/build`→`/plan` row); `.opencode/agent/builder.md:38-41,86-92,133`; `.opencode/command/build.md:36-42`. Fields are detecting `/build`, target `/plan`, affected `design.md`/`tasks.md`, `status: open`; handoff `Next: \`/plan <item-ref>\`` | PASS |
| AC2 (`/plan`→`/spec` record + `Next: /spec`) | `docs/workflow.md:220-223` (Requirements `Next`) and `:240-245` (Design `Next`) and `:669-674` (`/plan`→`/spec` row); `.opencode/agent/architect.md:46-49,78-83,148`; `.opencode/command/plan.md:18-22,44-48`; `.opencode/skill/workflow-lifecycle/SKILL.md:41` (canonical `/spec <feature or problem description \| item-ref>`). Handoff `Next: \`/spec <item-ref>\`` | PASS |
| AC3 (detector never edits target; record before edge; owner revises) | `docs/workflow.md:611-622` (recorded-finding precondition; ownership) and `:644-667` (steps 2 and 4); `.opencode/agent/builder.md:91-92` ("do not edit `design.md`, `tasks.md`, or `spec.md`"); `.opencode/agent/architect.md:48,82` ("never edit `spec.md`"); `.opencode/command/plan.md:22` | PASS |
| AC4 (downstream marked `stale:`; item derives P; non-destructive) | `docs/workflow.md:634-639` (invalidation clause) and `:658-674` (step 3 + per-edge marker sets); derived-state precedence unchanged at `:718` ("earliest `stale:` marker … → `P` (backtracked)"). Target-owned `design.md`/`tasks.md` excluded; no delete/rewrite language | PASS |
| AC5 (re-entry: read open finding, revise, append resolution, resume) | `docs/workflow.md:682-700` (`### Re-entry`); `.opencode/agent/architect.md:51-52,70-76`; `.opencode/agent/product.md:61-68`; `.opencode/command/plan.md:10-15`. Resolution format `## Resolution <n>` / `resolves:` / `revision:` matches `docs/artifact-conventions.md` (untouched) | PASS |
| AC6 (no open finding → ordinary, no fabricated backtrack) | `docs/workflow.md:695-697` ("No open finding … records no finding"); `.opencode/agent/product.md:67-68` ("re-entry is not triggered without an open finding"); `.opencode/agent/architect.md:76` ("With no open finding, continue as ordinary planning") | PASS |
| AC7 (denied/changes-requested plan PR → `/plan` + republish; not a backtrack) | `docs/workflow.md:357-363` (new Plan-publication bullet) and `:240-243` (Design `Next`); `.opencode/agent/architect.md:98-102,150-151`; `.opencode/command/plan.md:38-41`. States commit to same `plan/<ref>` branch, new PR if pruned, never force-push, "explicitly not a backtrack" | PASS |
| AC8 (all named surfaces state routing; no forward-only leftover) | `/build` prompt `.opencode/agent/builder.md:38-41,86-92,133`; `/plan` prompt `.opencode/agent/architect.md:46-52,70-83,148`; `/build` command `.opencode/command/build.md:36-42`; `/plan` command `.opencode/command/plan.md:10-22,38-41`; phase `Next:` `docs/workflow.md:220-223,240-245,261-264`; `AGENTS.md:98-101,127-134`; skill `.opencode/skill/workflow-lifecycle/SKILL.md:40-44,67-70`; `template/AGENTS.md:100-103,129-136`. Grep for `stop and report`/`route back` finds only unrelated secret/ship-precondition uses | PASS |
| AC9 (six commands/pairings unchanged; no command/agent/skill add/remove; no count/signature change) | `bash tests/run.sh` → `20-lifecycle.sh` pairings agree; `40-inventory.sh` counts equal disk; `96-signature-sweep.sh` all signatures canonical. Independent `git status --porcelain` shows only modified files, no added/removed under `.opencode/{agent,command,skill}`, `README.md`, or `tests/`; no new untracked file | PASS |
| AC10 (0001 model remains single authority; no new phase value/state file/readiness change) | `git diff --stat -- docs/artifact-conventions.md` empty (record + markers untouched); `docs/workflow.md` Derived-state table `:716-731` byte-unchanged (six `phase` values); operational procedure stated once at `:641-700` and referenced elsewhere; no new file (`git ls-files --others` empty) | PASS |
| AC11 (parent-`roadmap.md`, post-ship, and `/test` edges not wired) | `docs/workflow.md:648-651` (step 1 excludes self/`/test`/parent-`roadmap`/post-ship) and `:676-680` ("Only the two edges above are wired"); `.opencode/agent/product.md:68-69` scopes re-entry to `/plan`→`/spec`; grep over the touched prompts/commands finds no `/test`→, roadmap-revision, or post-ship route (exit 1) | PASS |
| AC12 (configured test command passes; lifecycle/inventory/signature; root↔template agree) | `bash tests/run.sh` → `340 passed, 0 failed, 0 skipped`; `95-split-guard.sh` → "AC21 AGENTS.md and template/AGENTS.md agree outside the Project profile"; independent section `diff`s also identical | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Reverse edge before downstream artifacts exist (`/plan`→`/spec` with only `spec.md`) | `docs/workflow.md:658-661` marks only *existing* artifacts; Derived-state row `spec.md present, design.md missing → spec` (`:722`) derives `spec` naturally | PASS |
| Sequential backtracks preserve order / derive earliest outstanding target | 0001 model (`docs/workflow.md:196-198` narrative, derived table `:718`); 0002 adds no competing rule and does not alter the table | PASS |
| Self-target refused / not offered | `docs/workflow.md:648-651` (step 1); no self-edge in the skill routing block `.opencode/skill/workflow-lifecycle/SKILL.md:40-44` | PASS |
| Shipped item excluded | `docs/workflow.md:648-649,702-709`; no reverse edge conditioned on a shipped item in any surfaced route | PASS |
| Finding recorded but target never re-entered | `docs/workflow.md:684-694` (open iff no resolution) + `:718` (stale marker derives target); nothing resumes automatically | PASS (with residual risk below) |
| `/build` has no upstream artifact to edit; `/build`→`/plan` is wired, not `/build`→`/build` | `.opencode/agent/builder.md:91-92`; `docs/command/build.md:40-42`; no `/build`→`/build` edge in any surface | PASS |
| Plan PR denied after its plan already merged | `docs/workflow.md:357-363` (re-run `/plan`, republish; "not a backtrack"); produces no code-phase reopen and no `ship.md` | PASS |
| Plan branch pruned | `docs/workflow.md:360-361` ("opens a new one when the branch was pruned … never a force-push") | PASS |
| `gh` unavailable | `docs/workflow.md` "Plan publication" retains the existing local-commit path; the new bullet degrades to local commits + push/PR commands (shipper revision step unchanged) | PASS |
| Two items in parallel | routing writes only its own item's `backtracks.md`/frontmatter and adds no readiness edge (`docs/workflow.md:676-680`; 0001 readiness unchanged) | PASS |
| Ordinary forward re-run mistaken for a backtrack | `.opencode/agent/product.md:67-68`; `.opencode/agent/architect.md:76`; `docs/workflow.md:695-697` (AC6) | PASS |

## Gaps and residual risk

- **No committed routing tests — deliberate.** The spec's Non-goals place
  committed fixtures, agreement areas, and mutation coverage for the routing with
  `0007-backtracking-guards`, and the design's test strategy makes AC1–AC11 manual
  inspections. No test file was added; this is a scoped deferral, not a coverage
  claim. AC12 is covered by the existing committed suite.
- **Inherited derivation gap for `/build`→`/plan` with no downstream artifact.**
  `docs/workflow.md:658-661` marks only *existing* artifacts strictly downstream
  of the target and excludes the target-owned `design.md`/`tasks.md`. At build
  time `verify.md`/`review.md` usually do not exist yet, so a `/build`→`/plan`
  reversal can leave no `stale: design` marker and the item then derives
  `build`/`test` rather than `plan` (the derived table at `:718` keys only on the
  earliest `stale:` marker). This is a pre-existing property of the shipped `0001`
  derived-state model (whose AC6/AC7 own derivation and whose record "does not by
  itself determine the derived phase"), not a behavior this item changed; AC4 as
  written is scoped to a scenario that *has* downstream artifacts, so it is not a
  failure of this item. Flagged for `0001`/`0006`/`0007` rather than as a defect
  here.
- **Step-1 wording is slightly over-broad.** `docs/workflow.md:648-651` says a
  `/test` edge "is not taken here" inside the general model authority, while
  `:676-680` says the `/test` edges "follow this same procedure when their items
  land". This is a clarity nit only; it correctly leaves `/test` unwired (AC11).
- **All routing behavior is prompt-following prose.** As the design itself notes,
  correctness depends on agents following `docs/workflow.md`; there is no
  executable guard in this item (0007's scope).

## Verdict

All 12 acceptance criteria and all 11 edge cases are covered by recorded
inspection or the committed suite; the suite is green (`340 passed, 0 failed, 0
skipped`). No test was weakened, skipped, or deleted. `status: final`.
