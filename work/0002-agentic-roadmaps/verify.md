---
feature: 0002-agentic-roadmaps
phase: test
status: final
created: 2026-10-04
updated: 2026-10-04
notes: "Re-verification after the builder addressed the review's M1/m1-m4. No test runner exists (prompt/config-only); automatable facts are covered by a read-only 169-assertion shell suite, and LLM-driven behavior by fresh real agent runs against a tester-built scratch fixture. The prior review found /visual writing to work/<slug>/; the current code uses work/<item-ref>/ everywhere and the suite now asserts it. See Gaps and residual risk."
---

# Verification — Agentic multi-feature roadmaps

## Summary

All 15 acceptance criteria are satisfied against the **current** working tree
(26 modified files, 523 insertions / 135 deletions, plus 2 new roadmap files).
This pass re-verified the code after the builder's response to the review's M1
(`/visual` nested path), m1 (branch naming), m2 (ship/PR readiness), m3
(multi-dependency delimiter), and m4 (stale handoff tokens); every one of those
fixes is now covered by the assertion suite and is mutation-sensitive.

Independent evidence:

- The read-only assertion suite (`work/0002-agentic-roadmaps/verify-tests.sh`)
  passes **169/169**, up from 139; the 30 added assertions cover exactly the
  review findings. Against a copy seeded with seven defects (a `/visual` path
  regression, a dropped nested branch mapping, a dropped PR-satisfaction branch, a
  dropped multi-dep delimiter, an added agent permission, and an added
  write-capable bash token), it exits 1 and flags all seven.
- A fresh, tester-built scratch roadmap (`work/0003-tester-probe/`, removed after)
  was reported by the real `status` agent as `7/13 ready` with every readiness
  boundary correct and all four integrity findings emitted.
- A fresh multi-feature `/roadmap` run created `work/0004-user-accounts/` with a
  valid roadmap artifact and four `.gitkeep`-only children; a single-feature run
  recommended `/spec` and wrote nothing; `/spec` on a blocked child refused and
  named its blocker, and the explicit override then wrote a nested spec.
- `/doctor` printed `No findings — repository is consistent.` (agents 14,
  commands 12, skills 10).
- `git status --porcelain` was byte-for-byte identical before and after every
  agent run (26 modified tracked files + the 2 untracked roadmap files).

No defects were found in the current implementation. No production file was
modified by any verification step.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | 169 passed, 0 failed — `scratch/tester2-verify-tests.out` |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` (mutated copy `/tmp/opencode/mut2`) | PASS (mutation) | exit 1, 7 failures after 7 seeded defects — `scratch` evidence; all new assertions fired |
| `opencode run --agent status "…work/0003-tester-probe…"` | PASS | `7/13 ready`; blockers `0002-changes`, `0003-noreview`, dangling `0099-missing`; cycle never ready; all 4 findings — `scratch/tester2-status-probe.log` |
| `opencode run --agent roadmap "Add a user accounts system. Features: …"` | PASS | created `work/0004-user-accounts/roadmap.md` + 4 `.gitkeep`-only children, acyclic deps — `scratch/tester2-roadmap-multi.log` |
| `opencode run --agent product "Write the spec for work/0004-user-accounts/0004-gdpr-deletion"` | PASS | refused, named `0002-auth-flow`, child still held only `.gitkeep` — `scratch/tester2-spec-blocked.log` |
| `opencode run --agent product "Explicit user override: … write the spec …"` | PASS | wrote nested `spec.md` with `feature: 0004-user-accounts/0004-gdpr-deletion`, `parent:`, and the override + blocker in `notes` — `scratch/tester2-spec-override.log` |
| `opencode run --agent roadmap "Add a dark mode toggle to the settings page."` | PASS | recommended `/spec add-dark-mode`, created nothing — `scratch/tester2-roadmap-single.log` |
| `opencode run --agent status "Report the status of every work item under work/."` | PASS | flat items `0001`/`0002` derived normally with no roadmap metadata — `scratch/tester2-status-all.log` |
| `opencode run --agent doctor "Run the framework consistency diagnostic…"` | PASS | `No findings — repository is consistent.`; counts 14/12/10 — `scratch/tester2-doctor.log` |
| `git status --porcelain` / `git diff --stat` before and after all agent runs | PASS | identical: 26 modified files, 523 insertions / 135 deletions, 2 untracked roadmap files; no tracked source touched by authoring, status, or spec |
| `find work/0004-user-accounts -mindepth 2 -type f -not -name '.gitkeep'` | PASS | empty — no child phase artifact |
| `git check-ignore work/0003-tester-probe/roadmap.md work/0004-user-accounts/roadmap.md` | PASS | both ignored; probe fixtures cleaned up afterward |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — `/roadmap` creates a top-level roadmap item with the next number, no approval gate | `verify-tests.sh` AC1 (command file, `agent: roadmap`, primary, both work grants, NNNN allocation, autonomy/no-gate text); behavioral `tester2-roadmap-multi` (created `work/0004-user-accounts` after `0003`) | PASS |
| AC2 — roadmap identifies initiative, assumptions, and per-child id/scope/reference | `verify-tests.sh` AC2 (Initiative/Assumptions/Children/Sequencing/Open issues, all five columns, agent quality bar); read of the produced artifact (4 rows with local id, scope, canonical reference) | PASS |
| AC3 — each child is a nested work-item dir with no phase artifact | `verify-tests.sh` AC3 (agent creates child `.gitkeep`, quality bar forbids phase artifacts, status treats `.gitkeep` as a placeholder); behavioral `find … -not -name .gitkeep` = empty | PASS |
| AC4 — deps name existing same-roadmap children, no self, acyclic; cycles reported | `verify-tests.sh` AC4 + new multi-dep-delimiter assertion; behavioral `tester2-roadmap-multi` (acyclic graph), `tester2-status-probe` (`CYCLIC-DEP`) | PASS |
| AC5 — status reports every child `ready`/`blocked` and names blockers | `verify-tests.sh` AC5/6 algorithm tokens in `docs/workflow.md` and `status.md`; behavioral `tester2-status-probe` (`0006-dep-changes` blocked by `0002-changes`; `0007` by `0003`; `0012` dangling; cycle members blocked) | PASS |
| AC6 — only approve or shipped satisfies; no-dep child is ready | `verify-tests.sh` AC6 (approve/ship/request-changes + new PR-detection branch); behavioral `tester2-status-probe`: `0005-dep-approved` ready (approve, unshipped), `0009-dep-shipped` ready (`ship.md`), `0006` blocked, `0007` blocked, `0004-ready` ready | PASS |
| AC7 — roadmap reported separately with ready count and phase tally | `verify-tests.sh` AC7 (`<ready>/<total> ready`, `phases:`, distribution tally, parent-only phase); behavioral `tester2-status-probe` (`7/13 ready · phases: rework 1, spec 1, ship 1, shipped 1, not started 8, missing 1`) | PASS |
| AC8 — per-feature commands work on a child by canonical reference | `verify-tests.sh` AC8 (grammar regex; all 7 phase agents and all 7 phase commands carry the two-segment rule) + new sweep: `/visual` agent/command/skill use `work/<item-ref>` and no `work/<slug>`, handoffs name item-ref, branch naming maps nested refs; behavioral `tester2-spec-override` (nested spec at `work/0004-user-accounts/0004-gdpr-deletion/spec.md`) | PASS |
| AC9 — blocked child start refuses and requires explicit override; non-destructive | `verify-tests.sh` AC9 (refuse and stop, explicit override, notes recording, no-touch, workflow section); behavioral `tester2-spec-blocked` (refused, named `0002-auth-flow`, only `.gitkeep` remained) + `tester2-spec-override` (nested spec with override + blocker in `notes`) | PASS |
| AC10 — every conclusion from files; no state file; read-only report | `verify-tests.sh` AC10 (`edit: deny`, no write tokens, derived-live/never-stored, no state file); behavioral: status report + baseline-identical `git status`, readiness recomputed live each run | PASS |
| AC11 — standalone items unchanged; no roadmap metadata required | `verify-tests.sh` AC11 (parent optional, standalone omits it, spec template unchanged, one-segment refs, derived-state rows) + new guard that no existing agent permission block changed vs `HEAD`; behavioral `tester2-status-all` (flat `0001`/`0002` derived with no roadmap metadata) | PASS |
| AC12 — only roadmap artifact + child dirs created; no source/child phase work | `verify-tests.sh` AC12 (exactly one artifact, never modifies source, no child specs, command forbids child phase work, edit default deny) + new no-write-capable-bash-token check; behavioral `tester2-roadmap-multi` + `find` + unchanged `git diff --stat` | PASS |
| AC13 — command/agent documented and counted; consistency check clean | `verify-tests.sh` AC13 (14/12/10 counts match disk; `roadmap` row in README; `/roadmap` in README + AGENTS.md; every on-disk agent/command/skill re-checked); behavioral `tester2-doctor` (`No findings — repository is consistent.`) | PASS |
| AC14 — single-feature recommends `/spec`; vague/fragile records or asks without inventing scope | `verify-tests.sh` AC14 (recommend `/spec`, fabricate no children, decline empty, surface duplicates); behavioral `tester2-roadmap-single` (recommended `/spec add-dark-mode`, created nothing), `tester2-roadmap-multi` (recorded an admin-console auth open issue instead of inventing a dependency) | PASS |
| AC15 — dangling/missing/unlisted/cyclic references reported as findings, not failures | `verify-tests.sh` AC15 (all four codes defined in status and workflow; findings non-fatal; never auto-repaired); behavioral `tester2-status-probe` (all four codes emitted and the report completed) | PASS |

## Edge cases

| Edge case | Result | Evidence |
| --------- | ------ | -------- |
| Empty initiative | PASS (prior pass) | `scratch/tester-roadmap-empty.log`: asked for the initiative, created nothing; static `verify-tests.sh` EDGE check. Not re-run this pass (question tool unavailable non-interactively). |
| Single-feature initiative | PASS | `tester2-roadmap-single.log`: recommended `/spec add-dark-mode`, created nothing |
| No decomposable features | PASS (prior pass) | `scratch/tester-roadmap-vague.log`: recorded the ambiguity, asked one batched round, fabricated no children; `tester2-roadmap-multi` recorded an unresolved admin-auth dependency as an open issue rather than inventing one |
| Self-dependency and cycles | PASS | `tester2-status-probe.log`: `0010-cycle-a ↔ 0011-cycle-b` reported `CYCLIC-DEP`; neither member ready. Static rule forbids storing self-deps (AC4) |
| Dependency on a missing/removed child | PASS | `tester2-status-probe.log`: `[DANGLING-DEP] 0012-dangling → 0099-missing` |
| Satisfaction boundaries (approve / request-changes / no review / approved-unshipped / shipped) | PASS | `tester2-status-probe.log`: approve-unshipped → ready; shipped → ready; request-changes → blocked; no review → blocked; no-dep → ready |
| Blocked-start override | PASS | `tester2-spec-blocked.log` refusal wrote nothing; `tester2-spec-override.log` wrote nested spec with override + blocker in `notes`; no file deleted |
| Numbering collisions | PASS | `verify-tests.sh` EDGE (never reuse; child numbers never reused within parent); `tester2-roadmap-multi` allocated `0004` after existing `0003`; child ids `0001..0004` local to the parent |
| Empty work tree | PASS (static) | `verify-tests.sh` EDGE (status handles empty; roadmap allocates `0001` when empty). Not behaviorally re-seeded this pass |
| Coexistence with flat items | PASS | `tester2-status-all.log` reported flat `0001`/`0002` normally while roadmap parents nest children |
| Concurrent activity / read-only | PASS (by construction) | `status` has `edit: deny` and no write-capable bash token (`verify-tests.sh` AC10); tracked `git status` identical after every agent run. Not exercised with a live concurrent writer |
| Large roadmap | PASS (bounded) | Rule-based with no fixed child cap; the 14-row probe rendered readable output and a correct tally |
| Duplicate initiative | PASS | `tester2-roadmap-multi.log` performed duplicate recon over `work/*/roadmap.md`/`work/*/spec.md` and recorded the existing items under Open issues; static rule surfaces a possible duplicate |

## Review-fix verification (the rework this pass re-tested)

| Finding | Fix | Test |
| ------- | --- | ---- |
| **M1** `/visual` wrote to `work/<slug>/…` | `visual.md` agent, `/visual` command, and the `browser-verification` skill now use `work/<item-ref>/` | `verify-tests.sh` AC8 nested sweep (asserts `work/<item-ref>` present and `work/<slug>` absent in all three) |
| **m1** `/ship` branch collides across siblings | `conventional-commits` skill, `/ship` command, and `shipper` map `NNNN-slug/MMMM-slug` → `NNNN-slug-MMMM-slug` | `verify-tests.sh` AC8 branch-naming assertions (all three files) |
| **m2** readiness missed a detected PR | `satisfied()` now includes `if a PR is detected for the child` | `verify-tests.sh` AC6 PR-detection assertions (workflow + status) |
| **m3** `Depends on` delimiter undocumented | `docs/workflow.md` and `docs/artifact-conventions.md` state comma-separated | `verify-tests.sh` AC4 multi-dep delimiter assertions |
| **m4** stale `work/<NNNN-slug>` handoff tokens | phase-agent handoffs now use `<item-ref>`; no `work/<slug>` remains | `verify-tests.sh` AC8 handoff + no-`work/<slug>` sweep |

## Defects

None in the current implementation. No acceptance criterion is blocked.

## Self-checks

- The suite is not vacuous: against `/tmp/opencode/mut2`, seeded with seven
  defects (a `/visual` path regression, a dropped nested branch mapping, a
  dropped PR-satisfaction branch, a dropped multi-dep delimiter, an added agent
  permission entry, and an added write-capable bash token), it exited 1 and
  flagged all seven. The permission-regression check was tightened after it first
  missed an added permission entry.
- The behavioral fixture (`work/0003-tester-probe/`) was built by this tester,
  not the builder, and was removed afterward; `work/0004-user-accounts/` was
  produced by a live `/roadmap` run and likewise removed.
- No test was weakened, skipped, or deleted to obtain a pass. New assertions were
  added for the review findings; none of the existing 139 were relaxed.

## Gaps and residual risk

1. **LLM-driven behavior is non-deterministic.** The roadmap, product-gate, and
   status behaviors are prompts, so they cannot run in CI and one run is not a
   proof of universal behavior. This pass used one run per scenario and the
   observed results exactly matched the documented algorithm. `roadmap`/`product`
   carry no explicit `temperature: 0` (only `doctor` does), so variance is
   possible — the design's acknowledged residual risk.
2. **Nested lifecycle beyond `/spec`.** AC8's behavioral evidence covers the
   product/spec path; plan, build, test, review, ship, and visual on a nested
   child were verified statically (every command/agent carries the two-segment
   resolution rule and, for `/visual`, the `work/<item-ref>` path). Running all
   seven end to end would require advancing a child through the whole lifecycle,
   which is out of scope for this pass.
3. **AC11 behavioral half.** Standalone semantics were confirmed by static
   assertions, the unchanged spec template, the permission-regression check, and
   by status deriving the existing flat items `0001`/`0002` normally. A brand-new
   standalone item was not created during this pass to avoid polluting `work/`.
4. **PR-detection readiness branch (m2).** Exercised only statically; producing a
   real "detected PR with no `ship.md`" would require an actual shipped child.
   `ship.md`-based satisfaction is behaviorally proven.
5. **Vague/empty initiative prompts.** Not re-run this pass because the `question`
   tool is unavailable in non-interactive `opencode run`; the prior pass recorded
   the same acceptance behavior (asked, invented no scope, created nothing), and
   the current roadmap agent still encodes it.
6. **Suite location.** The suite lives under `work/0002-agentic-roadmaps/`
   (git-ignored) because the tester permission block grants `**/tests/**` but not
   the relative `tests/**` — the same path-form gap recorded in
   `work/0001-framework-consistency-hardening/verify.md` (gap 3). It is read-only
   and run directly with `bash`.
7. **No CI test command.** `AGENTS.md`'s Project profile is still the bootstrap
   template and the repo has no runner, so "run the suite" means running the
   assertion script above plus the recorded agent runs; there is no single project
   test command to wire into CI.
8. **The existing `review.md` is stale.** It records `request-changes` for M1,
   which the current code has fixed; `/status` therefore still derives `0002` as
   `build (rework)` from that file. That is correct derived-state behavior, but
   the next `/review` must re-assess against the current tree.
