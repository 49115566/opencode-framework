---
feature: 0001-framework-consistency-hardening
phase: test
status: final
created: 2026-10-02
updated: 2026-10-02
notes: "No test harness exists in this repo; automatable criteria are verified by a read-only shell assertion suite plus real /doctor agent runs. See Gaps and residual risk."
---

# Verification — Framework consistency and permission hardening

## Summary

All 12 acceptance criteria are satisfied. An independent read-only assertion
suite (51 assertions) passes, and the `doctor` agent was exercised on the clean
repository, on three deliberately drifted copies, and from a subdirectory. No
defects were found in the implementation.

The executable suite lives at
`work/0001-framework-consistency-hardening/verify-tests.sh` (git-ignored with the
rest of `work/`). It is placed there because the tester agent's edit permission
grants `**/tests/**` but not the relative `tests/**` — the same path-form class
this work item fixed for `work/` — so a root-level `tests/` file is denied by the
permission engine. That gap is recorded under Gaps.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | 51 passed, 0 failed |
| `git check-ignore -v .playwright-mcp/x scratch/y` | PASS | printed `.gitignore:21` and `.gitignore:22` |
| `mkdir -p scratch .playwright-mcp && touch scratch/dev-server.log .playwright-mcp/trace.zip && git status --porcelain` | PASS | neither directory appeared; probe dirs removed afterward |
| `opencode debug agent product` / `opencode debug agent doctor` | PASS | resolved `edit` rules include `work/**` + `**/work/**` (product) and `edit: deny` (doctor) |
| `opencode run --agent doctor "run the consistency diagnostic"` (clean repo) | PASS | `No findings — repository is consistent.`; counts 13/11/10 |
| `opencode run --agent doctor ...` (drift probe A) | PASS | detected `AGENT-UNDOCUMENTED`, `AGENT-PHANTOM` |
| `opencode run --agent doctor ...` (drift probe B) | PASS | detected `AGENT-UNDOCUMENTED`, `COUNT-MISMATCH`, `PERMISSION-WORK-PATTERN`, `PERMISSION-TABLE-MISMATCH` |
| `opencode run --agent doctor ...` (drift probe C) | PASS | detected `SKILL-NAME-MISMATCH` only; padded README rows produced no false positives |
| `opencode run --agent doctor ...` (cwd = `docs/`) | PASS | resolved repo root via `git rev-parse`; clean result |
| Mutation test: run suite against a copy with 4 seeded defects | PASS | suite exited 1 and flagged AC1, AC4, AC5, AC7 |
| `git status --porcelain` before/after the clean `/doctor` run | PASS | identical; no files modified by the diagnostic |
| `git diff` of `docs/workflow.md`, `AGENTS.md` | PASS | only an added `/doctor` bullet / supporting-list rows / scratch bullet; no phase input/output/exit change |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — artifact-writers grant `work/**` + `**/work/**`; create+update under `work/<slug>/` succeeds; diagnostic flags a missing form | `verify-tests.sh` AC1 (7 agents, work-bearing completeness, doctor has no work grant); behavioral create+update via edit tool on relative `work/0001-.../.perm-probe` (created then updated); `opencode debug agent product` resolved both rules; drift probe B reported `PERMISSION-WORK-PATTERN` | PASS |
| AC2 — documented agent/command/skill inventories match disk | `verify-tests.sh` AC2 (13 agents in README + AGENTS.md, 11 commands in README + AGENTS.md, 10 skills in README; `docs/workflow.md` named lifecycle agents exist) | PASS |
| AC3 — `ask` documented with read-only profile | `verify-tests.sh` AC3 (README row, AGENTS.md name, `none`/`none`, frontmatter denies edit and bash) | PASS |
| AC4 — stated agent-prompt count equals disk | `verify-tests.sh` AC4 (13/11/10) | PASS |
| AC5 — README permission table matches enforcement; both work forms | `verify-tests.sh` AC5 (work-granting set == documented set; read-only rows say `none`); clean `/doctor` reported `PERMISSION-TABLE-MISMATCH` clean; drift probe B raised it when stale | PASS |
| AC6 — `edit` covers create/write/patch; both path forms documented | `verify-tests.sh` AC6 (`docs/customization.md` and README) | PASS |
| AC7 — `.playwright-mcp/` and `scratch/` ignored without the dirs existing | `verify-tests.sh` AC7; `git check-ignore -v`; create-dirs-and-files `git status` probe | PASS |
| AC8 — temp-file guidance points in-repo; no `/tmp` instruction | `verify-tests.sh` AC8 (no `/tmp` under README/AGENTS/docs/agents/commands/skills; scratch guidance present) | PASS |
| AC9 — diagnostic reports seeded drift naming source of truth and stale location | manual: drift probes A/B/C via real `/doctor` runs | PASS |
| AC10 — consistent repo yields a clean result | manual: real `/doctor` run on the clean repo (and from `docs/`) printed exactly `No findings — repository is consistent.` + counts 13/11/10 | PASS |
| AC11 — diagnostic is read-only | static (`verify-tests.sh` AC11: `edit: deny`, bash catch-all deny, no write patterns) + behavioral (`git status` identical before/after a `/doctor` run; no new files) | PASS |
| AC12 — no lifecycle phase behavior changes | manual `git diff` review of `docs/workflow.md` and `AGENTS.md` | PASS |

## Edge cases

| Edge case | Result | Evidence |
| --------- | ------ | -------- |
| Empty `work/` | PASS (N/A) | The diagnostic never reads `work/`; an empty work tree cannot affect any check. |
| Newly added, undocumented item | PASS | Drift probe B: `[AGENT-UNDOCUMENTED] .opencode/agent/_drift-probe.md <-> README.md ...`. |
| Documented but deleted item | PASS | Drift probe A: `[AGENT-PHANTOM] .opencode/agent/ask.md <-> README.md Agents table "ask" row ...`. |
| Consistent addition | PASS | Clean run lists all 13/11/10 items with no findings. |
| Skill metadata mismatch | PASS | Drift probe C: `[SKILL-NAME-MISMATCH] .opencode/skill/python/ ... name: "python-tooling"`. |
| Ignore rules without the directories | PASS | `git check-ignore` matched both rules with neither dir present; no tracked side effects. |
| Wrong working directory | PASS | `/doctor` run with cwd `docs/` resolved the root via `git rev-parse` and printed the clean result. |
| Formatting noise | PASS | Padded README table rows in drift probe C produced no false positives from `/doctor`; the shell suite also passes on a padding-only copy. |
| Intentional omissions | PASS | Clean run does not flag `ask` having no command or the deferred backlog. |
| Concurrent activity | PASS (by construction) | `edit: deny` + no write-capable bash; a run cannot corrupt state. Not exercised with a concurrent writer. |

## Defects

None. No acceptance criterion is blocked.

## Self-checks

- The assertion suite was mutation-tested: against a copy with a missing
  `**/work/**`, a stale README permission row, a wrong count, and a dropped
  `scratch/` ignore, it exited 1 and flagged AC1, AC4, AC5, AC7 — so it is not
  vacuous.
- No test was weakened, skipped, or deleted to obtain a pass.

## Gaps and residual risk

1. **LLM-driven checks (AC9–AC11).** The diagnostic is a prompt, so its results
   are not deterministic in principle and cannot run in CI. `temperature: 0`
   reduces variance; the actual runs above produced the expected codes and the
   exact clean string. This is the design's acknowledged residual risk.
2. **Bash pipes are blocked in `doctor`.** Its allowlist matches whole command
   strings, so a piped command such as `ls ... | wc -l` is denied (`wc` is not
   allowlisted). During the clean run the agent noted "The piped counts were
   blocked" and worked around it with `ls`. The diagnostic completed correctly,
   but a future hardening could add `wc*` to the read-only allowlist.
3. **Same-class path-form gap outside `work/` (follow-up).** The tester's
   test-file patterns use `**/tests/**`, `**/test/**`, etc. without the relative
   `tests/**` form, so the edit tool denies a root-level `tests/...` path. This is
   the identical relative-vs-absolute bug the spec fixed for `work/`, but the
   spec deliberately scoped the fix to `work/`. Recommend a follow-up work item
   to add the relative forms for test/config patterns (and to confirm the same
   for `builder`'s and `bootstrap`'s other patterns).
4. **End-to-end product-agent write not exercised.** A synthetic `.perm-probe`
   request was declined by the `product` agent as outside its artifact contract
   (a model-policy refusal, not a permission denial). AC1's behavioral half was
   instead verified directly through the edit tool on the tester's identical
   permission shape, and `opencode debug agent product` shows both `work/**` and
   `**/work/**` resolving to `allow`. The denial is not reproducible evidence of
   a defect.
5. **Shell suite scope.** The assertion suite is a fast pre-check of the
   inventory/permission/ignore/temp facts; the `doctor` agent remains the
   semantic authority (e.g. full permission-table matching, phantom detection).
   The suite is not a substitute for `/doctor`.
