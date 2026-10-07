---
feature: 0005-merge-conflict-workflow/0005-merge-integrity-guards
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/doc-only behavior contract. Verification is the project's own configured suite (bash tests/run.sh, the Project profile Test: value) plus read-only surface inspection, per the spec's resolved open question and AC4 — no committed tests/check area and no verify-tests.sh are added. No test was weakened, skipped, or deleted. One edge case is a documented residual risk: the guard delegates to the Project profile Test: value but does not restate the `none` convention."
parent: 0005-merge-conflict-workflow
---

# Verification — Merge-integrity guard as a portable behavior contract

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`, exit `0`. Full output: `scratch/verify-0005-0005/suite.out`. |
| `bash scratch/verify-0005-0005/final.sh` | PASS | Read-only surface inspection (75 assertions, 0 failed, exit `0`). Scratch is gitignored; the assertions are literal greps reproduced in "Acceptance coverage" and "Surface-inspection predicates". |
| `git diff --name-only -- tests/` | PASS | Empty — `tests/**` unchanged. |
| `git diff --name-status` | PASS | Only the 7 design-named files modified (5 prompts/skills + `docs/workflow.md` + `docs/artifact-conventions.md`); no file added or removed. |

**No test files were added or updated.** This is deliberate and required by the
spec: AC4 states `tests/` gains no agreement area and no mutation case, and the
spec's resolved open question states verification is the project's own configured
suite plus surface inspection, with no standalone `verify-tests.sh`. Adding a
committed `tests/checks/**` contract would have *failed* AC4. The surface
inspection below is therefore the verification method, and its predicates are
recorded inline so any reader can re-run them.

### Surface-inspection predicates

Each row of the matrix was exercised by grep over the live surfaces. The
representative predicate set (from `scratch/verify-0005-0005/final.sh`) is:

- `grep -F -- '### Merge-integrity guard' docs/workflow.md`
- the seven-invariant table, checked code-by-class:
  `DUPLICATE-PREFIX (c)`, `DUPLICATE-CHILD (c)`, `DANGLING-DEP (b)`,
  `CYCLIC-DEP (b)`, `MISSING-CHILD (b)`, `UNLISTED-CHILD (b)`, `DRIFT-FACT (d)`
- AC2/AC3 literal set in `docs/workflow.md`: `prompt behavior only`,
  `no committed checker, script, helper, or executable tool`,
  `no tests/ agreement area`, `no separate checker exists`,
  `neither defines a separate guard`, `observes the same invariant set`,
  `offline and read-only`, `post-merge integrity pass`,
  `after a merge to the default branch`,
  `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`,
  `non-fatal`, `never silently dropped`, `never truncated`, `not auto-repaired`,
  `modifies no file`, `no second vocabulary`, `no second policy`
- AC5: `configured test command` and `Project profile` present on
  `docs/workflow.md`, `docs/artifact-conventions.md`,
  `.opencode/skill/merge-conflict/SKILL.md`,
  `.opencode/skill/pr-workflow/SKILL.md`, `.opencode/agent/shipper.md`; and
  `bash tests/run.sh` absent from all of them except the shipper's bash
  **allowlist pattern** (`"bash tests/run.sh*": allow`, a permission grant, not a
  guard instruction — design R5/T5/T7).
- AC5: `observable offline through \`/status\`` in `docs/workflow.md`.
- AC7: each of the seven guard codes present in `docs/workflow.md`,
  `.opencode/skill/merge-conflict/SKILL.md`, and `.opencode/agent/status.md`, and
  no guard code absent from the skill's canonical `### Finding grammar` table.
- AC10: `ls .opencode/command/*.md` = 12, `.opencode/agent/*.md` = 14,
  `.opencode/skill/*/` = 11; `git diff --quiet` for `README.md`, `AGENTS.md`,
  `template/AGENTS.md`, `opencode.json`, `docs/customization.md`; no added
  executable; no changed `### N.` phase heading.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 | surface inspection: `docs/workflow.md:395-416` `### Merge-integrity guard` table carries all seven invariant rows with their `0002` codes and `0001` classes (`final.sh` AC1) | PASS |
| AC2 | surface inspection: `docs/workflow.md:397-406` states prompt-only / no committed checker / no `tests/` area / no separate checker and the two points `/status` offline+read-only and `/ship` post-merge pass; skill and shipper restate report-only (`final.sh` AC2) | PASS |
| AC3 | surface inspection: `docs/workflow.md:418-425` grammar + code/class/offender + non-fatal + never-dropped/never-truncated + not-auto-repaired + modifies-no-file; `status.md:137-140,212-214`, `command/status.md:37-39`, `SKILL.md:124-127,277-280` (`final.sh` AC3) | PASS |
| AC4 | `git status`/`git diff` inspection: no new `.opencode/` file, no new untracked file outside `work/`, no added executable, `tests/` diff empty; contract text states no tool (`final.sh` AC4) | PASS |
| AC5 | surface inspection: `configured test command` + `Project profile` on all five guard/re-verify surfaces, no maintainer-only literal on any; `docs/workflow.md:430-431` states the drift invariant is observable offline through `/status` (`final.sh` AC5) | PASS |
| AC6 | surface inspection: contract in `docs/workflow.md`; referenced from `SKILL.md:124-127`, `status.md:57-60,139-140`, `command/status.md:37-39`, `shipper.md:234-237` (`final.sh` AC6) | PASS |
| AC7 | surface inspection: seven codes/classes agree across `docs/workflow.md`, `SKILL.md` `### Finding grammar`, `status.md`; no guard code outside the canonical table; `no second vocabulary` / `no second policy` present (`final.sh` AC7) | PASS |
| AC8 | surface inspection: `docs/workflow.md:423-425` states empty `work/` tree and already-up-to-date branch report no findings and do not error; `SKILL.md:132-135` up-to-date no-op (`final.sh` AC8) | PASS |
| AC9 | `bash tests/run.sh` → 285 passed / 0 failed / 0 skipped, exit 0; `git diff -- tests/` empty; `tests/checks/*.sh` count still 11 (no area added, removed, or duplicated) | PASS |
| AC10 | suite green; counts 12 commands / 14 agents / 11 skills; lifecycle/inventory surfaces (`README.md`, `AGENTS.md`, `template/AGENTS.md`, `opencode.json`, `docs/customization.md`) unchanged; no phase heading changed; `docs/artifact-conventions.md` diff is only the illustrative `Re-verification:` command; no executable added (`final.sh` AC10) | PASS |

Coverage: **10/10 acceptance criteria covered and passing.**

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Empty `work/` tree | `docs/workflow.md:423-425` no-op (no findings, does not error) | PASS |
| Duplicate prefix, different slugs | invariant row `DUPLICATE-PREFIX` `(c)` (`docs/workflow.md:410`); `SKILL.md:69-72` compares directory names even when slugs differ | PASS |
| Same canonical reference, differing content | `DUPLICATE-PREFIX` invariant + report-only "not auto-repaired / modifies no file" contract (`docs/workflow.md:420-424`); guard reports rather than repairs | PASS |
| Dangling `Depends on` | invariant row `DANGLING-DEP` `(b)` (`docs/workflow.md:412`) | PASS |
| Cycle in the graph | invariant row `CYCLIC-DEP` `(b)` (`docs/workflow.md:413`) + suite-pinned "a child in a cycle is never `ready`" and "cycle members are never reported ready" (`80-cycle-fixture.sh`, green) | PASS |
| Unlisted or missing child | rows `MISSING-CHILD`/`UNLISTED-CHILD` `(b)` (`docs/workflow.md:414-415`) | PASS |
| Both sides changed same duplicated fact to same value | `SKILL.md:129-130` "not drift: report no class (d) finding" | PASS |
| Up-to-date branch | AC8 no-op | PASS |
| Adopter without the maintainer suite | AC5 portable reference + `observable offline through /status` | PASS |
| No configured test command (`Test:` = `none`) | see "Gaps and residual risk" — the guard delegates to the Project profile `Test:` value but does not restate the `none` convention | RISK |
| Large collision set | `docs/workflow.md:422` "never truncated"; `SKILL.md:105-107,306-307` | PASS |
| Concurrent guard runs | `/status` described as `offline and read-only` (`docs/workflow.md:400`); `status.md:215-219` "takes no lock, and writes nothing"; `SKILL.md:27-29` two pre-flights do not interfere | PASS |
| Guard disagreement between `/status` and post-merge pass | `docs/workflow.md:406` "observes the same invariant set at both points, and neither defines a separate guard" | PASS |

## Gaps and residual risk

1. **No committed test guards the contract text (deliberate).** AC4 forbids a
   `tests/checks/**` agreement area and a mutation case, and the spec's resolved
   open question selects the project suite + surface inspection. Consequence: a
   later edit that drops or rewrites a guard literal would not be caught by CI.
   The existing `80-cycle-fixture.sh` still pins the adjacent `CYCLIC-DEP`,
   `integrity findings rather than failing`, and cycle-not-ready literals, and
   `bash tests/run.sh` stays green. This limit is spec-approved.
2. **`No configured test command` edge case under-stated.** The guard's
   verification instruction names the repository's own configured test command
   (the Project profile `Test:` value) but does not itself say what happens when
   that value is `none`. The convention is defined elsewhere
   (`project-discovery/SKILL.md:59`, `bootstrap.md:140`: write `none` and say
   what it implies). AC5 is fully met (the instruction is portable and not a
   maintainer-only path); this is a low-impact content gap worth a follow-up, not
   a blocker.
3. **Live `/status` emission is prose, not executable.** An LLM `/status` run
   actually printing the findings is not CI-executable — the same documented
   residual as `tests/README.md` records for `CYCLIC-DEP`. The invariant set,
   grammar, and report-only contract are verified by inspection; the committed
   fixture and suite pin the adjacent rules.
4. **Shipper bash allowlist (design R8).** An adopter's configured test command
   may fall outside the shipper's `bash=git-gh` allowlist. Pre-existing and out
   of scope: AC5 requires the *instruction* to name the configured command, and
   the shipper's permission frontmatter is deliberately unchanged (changing it
   would regress `30-permissions.sh`).
5. **Scratch evidence is not committed.** `scratch/verify-0005-0005/` is
   gitignored by design; the predicates are reproduced inline above so the
   evidence is re-runnable from the repository alone.

No acceptance criterion is blocked, no test failed, and no test was weakened,
skipped, or deleted.
