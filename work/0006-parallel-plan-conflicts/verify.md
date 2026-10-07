---
feature: 0006-parallel-plan-conflicts
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc-only behavior contract. Verified by a new read-only item suite work/0006-parallel-plan-conflicts/verify-tests.sh (144 assertions, 0 failed) over the normative docs/workflow.md contract, the format authority docs/artifact-conventions.md, the canonical .opencode/skill/merge-conflict/SKILL.md vocabulary, the operational derivatives, and the adopter references, plus the project's own configured suite bash tests/run.sh (285 passed, 0 failed, 0 skipped). No production file was changed by this pass; the only added file is the item suite. No committed tests/checks/ area was added (spec AC14 / non-goal). Three spec edge cases are satisfied by implication rather than an explicit contract sentence and are recorded as low residual risk."
---

# Verification — Parallel-development plan conflicts and a `Conflicts with` roadmap column

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`, exit `0`. Full output: `scratch/verify-0006/suite.out`. |
| `bash work/0006-parallel-plan-conflicts/verify-tests.sh` | PASS | `TOTAL: 144 passed, 0 failed`, exit `0`. Full output: `scratch/verify-0006/item-suite.out`. |
| `bash -n work/0006-parallel-plan-conflicts/verify-tests.sh` | PASS | Bash syntax OK. |
| `git status --porcelain` | PASS | Only the builder's 14 modified surfaces plus the untracked `work/0006-parallel-plan-conflicts/`; the tester added no production change. |
| `git diff --name-only \| grep -E '\.sh$'` | PASS | Empty — no executable/script in the tracked diff (AC14). |
| `git diff --diff-filter=A --name-only` | PASS | Empty — no tracked file added (AC14). |

The project's canonical test command is `bash tests/run.sh` (confirmed in
`AGENTS.md` → Project profile). It was already known and did not require
`project-discovery`.

## Acceptance coverage

Every acceptance criterion maps to assertions in the new item suite
`work/0006-parallel-plan-conflicts/verify-tests.sh`; AC15 also exercises the
committed suite.

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — `Conflicts with` column alongside `Depends on`; comma-separated local ids or `—`; intra-roadmap only | `verify-tests.sh` AC1: exact header in `docs/artifact-conventions.md:110` and `tests/fixtures/cyclic-roadmap/roadmap.md:26`; append-after-`Canonical reference` header regex; matching separator segment; `Conflicts with` bullet (`:134-140`); workflow Roadmaps prose (`docs/workflow.md:77-83`); roadmap agent + `/roadmap` command; both fixture rows end `| — |` | PASS |
| AC2 — unresolvable or self naming reports a non-fatal finding naming roadmap/row/reference; not rejected or aborted | `verify-tests.sh` AC2: `status.md` validates every name against the same table, requires another row, forbids self, emits `DANGLING-CONFLICT (b)`, names roadmap+row+invalid reference, "neither rejected nor aborted"; `/status` command and canonical skill carry the code | PASS |
| AC3 — `Conflicts with` never changes readiness or the dependency graph | `verify-tests.sh` AC3: `docs/workflow.md:93-95` readiness-neutral sentence; readiness derived from `Depends on` alone; roadmap agent quality bar; unchanged readiness algorithm; `tests/checks/10-readiness.sh` green in AC15 | PASS |
| AC4 — `/status` reports invalid declarations in the existing grammar and non-fatal contract, offline/read-only/no file | `verify-tests.sh` AC4: `status.md:185-186` offline/read-only/modifies-no-file; `No file was modified.`; `/status` command names the finding and keeps the merge-integrity window | PASS |
| AC5 — committed machine-readable surface declaration discoverable by canonical reference | `verify-tests.sh` AC5: `## Surface declaration` in the `design.md` template; grammar (no leading `/`, no `..`, optional backticks, trailing `/` = directory, absent/empty = no surfaces); `docs/workflow.md:462-473` names `work/<item-ref>/design.md` and "committed before development begins" | PASS |
| AC6 — `/build` compares before implementation against every other ready in-flight item | `verify-tests.sh` AC6: `docs/workflow.md:496` trigger; `builder.md` process step 3; `/build` command wiring; comparison against "every other ready in-flight item" | PASS |
| AC7 — a declared `Conflicts with` edge is reported naming both items | `verify-tests.sh` AC7: `### Detection` **Declared edge** bullet; current→sibling and sibling→current; symmetric/tolerant wording; `DECLARED-CONFLICT` in workflow, skill, and builder | PASS |
| AC8 — same concrete path or ancestor/descendant overlap is reported | `verify-tests.sh` AC8: **Surface overlap by path** bullet; equal-path; ancestor-of-or-equal; `docs/` vs `docs/workflow.md` example; `SURFACE-OVERLAP` naming both + surface | PASS |
| AC9 — same shared framework surface class is reported | `verify-tests.sh` AC9: **Shared framework surface** bullet; all six class members (`README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`); `SURFACE-OVERLAP` naming both + surface | PASS |
| AC10 — finding carries code, class, offenders, detail in the existing grammar; no drop/truncation | `verify-tests.sh` AC10: canonical grammar in the skill; workflow shorthand grammar; the three new codes with classes in both the workflow table and the skill's canonical table; code+class+offender+detail; no-drop and never-truncated literals; "no second vocabulary" | PASS |
| AC11 — report-only: never blocks, modifies no file, no auto-repair, read-only | `verify-tests.sh` AC11: workflow report-only contract (`docs/workflow.md:458-460, 538-546`); never resolves/serializes; `/build` always continues; builder process, rules, and `/build` command all state read-only/no-repair/never-blocks | PASS |
| AC12 — no peer / no declaration / no surfaces reports no conflicts and does not error | `verify-tests.sh` AC12: all three conditions; `reports \`no conflicts\` and does not error`; a peer without a declaration is "could not compare", never treated as no surfaces; builder repeats it | PASS |
| AC13 — build handoff records declarations assessed and conflicts or explicit "no conflicts" | `verify-tests.sh` AC13: `builder.md:116` `Plan conflicts: <declarations assessed> — <conflicts found or "no conflicts">`; `/build` command handoff line; workflow handoff requirement | PASS |
| AC14 — prompt/config/doc only; no executable checker/script/helper; no new command/agent/phase; no new committed test agreement area | `verify-tests.sh` AC14: counts 12 commands / 14 agents / 11 skills; `tests/checks` still 11 and untouched; `git diff --diff-filter=A` empty; no `.sh`/`.py`/`.js`/`.ts`/`.rb` in the diff; every modified path within the design's declared surfaces; no seventh phase; exactly 6 numbered headings; new section non-numbered | PASS |
| AC15 — `bash tests/run.sh` exits `0`, including the Children-table/format assertion, cycle fixture, inventory, readiness/lifecycle; pinned surfaces updated only as needed | `verify-tests.sh` AC15 runs the canonical suite (`285 passed, 0 failed, 0 skipped`, exit `0`) and spotlights AC6 readiness, AC9 inventory, AC13 cycle fixture; fixture retains the pinned header substring and `Depends on` is still awk field 5 | PASS |

**Coverage: 15/15 acceptance criteria covered and passing.**

## Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Empty `work/` or single in-flight item | `docs/workflow.md:490-492` "no other ready in-flight item … reports `no conflicts` and does not error"; `verify-tests.sh` AC12 | PASS |
| Declaration absent | `docs/workflow.md:472-473,516-517` absent/empty = no surfaces, peer "could not compare", never assumed empty; `verify-tests.sh` AC12 | PASS |
| Self-declaration | `status.md` "must not name the declaring row itself"; vocabulary "names its own row"; `verify-tests.sh` EDGE | PASS |
| One-directional declaration | `docs/workflow.md:501-506` symmetric, one direction suffices, both directions not an error | PASS |
| Duplicate id in a cell | Implicit: `status.md` validates *resolution* (`validate every named local id against the same Children table`), so a repeated valid id yields no finding. No explicit "treated once" sentence. | PASS (implicit) |
| Overlap by directory | `docs/workflow.md:507-510` `docs/` vs `docs/workflow.md` | PASS |
| Shared surface class | `docs/workflow.md:511-514` six class members | PASS |
| Blocked or shipped item outside the universe | `docs/workflow.md:480-487` universe requires no `ship.md`; shipped/blocked/cyclic excluded | PASS |
| Conflicting and sequential at once | `docs/workflow.md:93-95` independence ("never changes … readiness or … the dependency graph"); declared-edge detection is separate from readiness | PASS (implicit) |
| Declaration changes after the check | `docs/workflow.md:496` the check runs once per build, before implementation; no result is stored, so each run re-assesses. No explicit "stale result is never current" sentence. | PASS (implicit) |
| Standalone item with no roadmap | `docs/workflow.md:483` universe includes "a standalone item" | PASS |
| Concurrent check runs | `docs/workflow.md:542-543` "Two concurrent check runs take no lock, write nothing, and do not interfere" | PASS |
| Large overlap set | `docs/workflow.md:535-536` "the list is never truncated, even for a large overlap set" | PASS |

## Gaps and residual risk

1. **Three edge cases rely on implication, not an explicit contract sentence.**
   *Duplicate id in a cell*, *conflicting and sequential at once*, and
   *declaration changes after the check* have no dedicated sentence in any
   surface. In each case the required behavior follows from stated rules
   (resolution-based validation, readiness neutrality, and per-build execution
   with no stored result), so no acceptance criterion is affected. A future edit
   could still remove the enabling sentence without a literal check catching it.
   Low impact; worth a follow-up only if the spec wants these spelled out.

2. **The workflow's finding-grammar quote is a shorthand of the skill's canonical
   grammar.** `docs/workflow.md:521-522` quotes
   `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`, while the
   skill's `### Finding grammar` (`SKILL.md:99`) reads
   `- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>`.
   This paraphrase is pre-existing: the shipped 0005 `### Merge-integrity guard`
   (`docs/workflow.md:428-430`) uses the same shorthand. It is consistent with the
   established convention and semantically equivalent, and the item suite asserts
   both forms. Not a regression.

3. **`docs/customization.md` cost-table token figures are approximate, not
   AC-gated.** Byte totals are exact (7.8 + 30.6 + 14.6 = 53.0 KB = 54,261 bytes;
   the table's `~53.0 KB` total is correct), but the token figures (1.9k / 7.6k /
   3.7k / 13.2k) sit slightly below a strict 4-bytes-per-token computation
   (≈2.0k / 7.8k / 3.7k / 13.6k), as the pre-existing table already did. T8's
   refresh is documentation consistency only and is not an acceptance criterion;
   `tests/checks/50-instructions.sh` validates set membership, not the sizes.
   Low impact.

4. **The check itself is LLM-executed prose, not CI-executable.** There is no
   runtime harness for document content and the spec's AC14 forbids adding one,
   so AC1–AC14 are verified by literal-presence assertions over the finished
   surfaces plus inspection for coherence. The committed suite independently
   pins the adjacent format, readiness, inventory, lifecycle, and cycle rules.
   This limit is spec-approved and matches the 0005 precedent.

5. **DANGLING-CONFLICT is intentionally not added to the merge-integrity guard's
   seven-invariant table** (`docs/workflow.md:418-426`). The skill and workflow
   describe it as reported by `/status` "alongside the merge-integrity findings",
   i.e. a sibling status finding rather than a guard invariant — the same
   treatment `TEXTUAL-CONFLICT` already receives. No contradiction found; noted
   so a reviewer sees it was examined.

No acceptance criterion is blocked, no test failed, and no test was weakened,
skipped, or deleted.
