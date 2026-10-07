---
feature: 0006-parallel-plan-conflicts
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Read-only review of the uncommitted work item. Base = HEAD = origin/main = f16be1ce. No executable suite was run (read-only guard denies executing programs); AC15 was verified by statically reading the pinned checks. One Minor documentation inconsistency and four Nits; no Blocker or Major."
---

# Review — Parallel-development plan conflicts and a `Conflicts with` roadmap column

## Verdict

**approve** — the change is a self-consistent, prompt/config/doc-only contract that satisfies all fifteen acceptance criteria; one Minor wording inconsistency and four Nits remain, none merge-blocking.

## Base and diff

- Base ref: `HEAD` = `origin/main` = `f16be1ce6fd61c467353ce9ea58a6c45adcb4e23`.
- Commands: `git merge-base HEAD origin/main` → `f16be1ce…`; `git status` (branch `main`, up to date with `origin/main`, 14 tracked files modified, `work/0006-parallel-plan-conflicts/` untracked); `git diff --stat`; `git diff` (230 insertions, 32 deletions across 14 files); `git diff --name-only`.
- There is no item branch; the work is the uncommitted working-tree diff plus the untracked item directory. The range is therefore `git diff` against `HEAD`, which is exactly `origin/main`.
- Scope: 14 modified files, all inside the item's own declared surfaces. No file added or deleted in the tracked tree; no `tests/checks/` file touched.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — `Conflicts with` column, comma-separated local ids or `—`, intra-roadmap | **met** | `docs/artifact-conventions.md:110-113,134-140`; `docs/workflow.md:77-83`; `.opencode/agent/roadmap.md:77-85,132-135`; `.opencode/command/roadmap.md:17-21`; `tests/fixtures/cyclic-roadmap/roadmap.md:26-29` |
| AC2 — invalid/self reference → non-fatal finding naming roadmap, row, reference | **met** | `.opencode/agent/status.md:87-92,149-152,202`; `.opencode/command/status.md:31-35`; `.opencode/skill/merge-conflict/SKILL.md:121,129-130` |
| AC3 — `Conflicts with` never changes readiness or graph | **met** | `docs/workflow.md:93-95`; `.opencode/agent/roadmap.md:133-135`; readiness algorithm unchanged (`docs/workflow.md:96-109`) |
| AC4 — `/status` reports invalid declarations offline/read-only/no file | **met** | `.opencode/agent/status.md:184-186,142-145`; `.opencode/command/status.md:42-44` |
| AC5 — committed machine-readable declaration discoverable by canonical ref | **met** | `docs/artifact-conventions.md:215-221,244-250`; `docs/workflow.md:462-473` |
| AC6 — `/build` compares before implementing against every other ready in-flight item | **met** | `docs/workflow.md:496-499`; `.opencode/agent/builder.md:59-69`; `.opencode/command/build.md:16-21` |
| AC7 — declared `Conflicts with` edge reported naming both items | **met** | `docs/workflow.md:501-506`; `.opencode/skill/merge-conflict/SKILL.md:122`; `.opencode/agent/builder.md:63-64` |
| AC8 — equal path or ancestor/descendant overlap reported | **met** | `docs/workflow.md:507-510`; `.opencode/agent/builder.md:64-65` |
| AC9 — shared framework surface class reported | **met** | `docs/workflow.md:511-514` |
| AC10 — finding grammar, class, offenders, detail; no drop/truncation | **met** | `docs/workflow.md:519-536`; `.opencode/skill/merge-conflict/SKILL.md:99,121-123` |
| AC11 — report-only, non-fatal, read-only, never blocks | **met** | `docs/workflow.md:458-460,538-546`; `.opencode/agent/builder.md:66-69,106-108`; `.opencode/command/build.md:20-21` |
| AC12 — no peer / no declaration / no surfaces → no conflicts, no error | **met** | `docs/workflow.md:490-492,516-517`; `.opencode/agent/builder.md:65-66` |
| AC13 — build handoff records declarations and conflicts/`no conflicts` | **met** | `.opencode/agent/builder.md:116`; `.opencode/command/build.md:21`; `docs/workflow.md:544-546` |
| AC14 — prompt/config/doc only; no new command/agent/phase/test area | **met** | counts verified: 12 commands / 14 agents / 11 skills / 11 `tests/checks` files; `git diff --diff-filter=A` empty; no `.sh` in the tracked diff; no seventh phase and exactly 6 numbered headings in `docs/workflow.md` |
| AC15 — `bash tests/run.sh` exits 0 with pinned formats intact | **met (attested, statically cross-checked)** | `tests/checks/80-cycle-fixture.sh:31` header is a fixed substring still contained by the extended header; `:50` reads `a[5]` = `Depends on`, unshifted by the appended sixth column; `tests/checks/40-inventory.sh` counts unchanged; `tests/checks/10-readiness.sh:23` algorithm marker still unique; `tests/checks/50-instructions.sh` membership unchanged; `tests/checks/96-signature-sweep.sh` extracts only `^### [0-9]+[.] ` headings, none added |

I did not execute the suite: the read-only guard denies running programs other than the allowlisted git/ls/cat commands. I verified AC15 by reading every check the design names as pinned and confirming the changed surfaces still satisfy them.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] Absent-declaration wording is self-contradictory in the normative section** — `docs/workflow.md:471-473` vs `docs/workflow.md:516-517`
  `:471-473` says "An absent or empty section means the item declares no surfaces; the check reports that it could not compare that item and does not error." `:516-517` says an absent declaration is "reported as 'could not compare', never treated as declaring no surfaces." The first clause tells an LLM builder to treat an absent declaration as *no surfaces*; the spec's `Declaration absent` edge case (`spec.md:179-180`) requires the opposite ("it must say so rather than assume no surfaces"). The operative behavior is stated correctly in Detection, in `.opencode/agent/builder.md:65-66`, and is asserted by the item suite, so no AC fails — but the normative section's general sentence should not contradict its own Detection rule.
  Recommendation: reword `:471-473` to distinguish the two cases explicitly, e.g. "An absent or empty section means the *current* item declares no surfaces (a no-op); a *peer's* absent section is reported as 'could not compare' and is never treated as declaring no surfaces." Keep `docs/artifact-conventions.md:247-248` scoped to the declaring item.

### Nits

- **[N1] Item-level executable suite under `work/` and AC14's "no script" clause** — `work/0006-parallel-plan-conflicts/verify-tests.sh:1`
  AC14/non-goal forbids "any executable checker, script, helper, or runtime code". This 432-line Bash suite is executable and will be committed with the item. It is not part of the delivered capability and not a committed `tests/checks/` agreement area, and the design's test strategy (`design.md:334-338`) plus the `work/0005-merge-conflict-workflow/verify-tests.sh` precedent sanction it. Recording it so the interpretation is explicit; no change requested.
- **[N2] Cost-table token estimates are slightly below a strict 4 B/token** — `docs/customization.md:59-62`
  Byte figures are exact and sum correctly (7.8 + 30.6 + 14.6 = 53.0 KB; 54,261 bytes), but the token figures (1.9k / 7.6k / 3.7k / 13.2k) sit below ~2.0k / 7.8k / 3.7k / 13.6k. The table is labelled approximate and the pre-existing table did the same; `tests/checks/50-instructions.sh` checks membership, not sizes. The item's `verify.md:92-99` already discloses it.
- **[N3] Three spec edge cases are satisfied only by implication** — `work/0006-parallel-plan-conflicts/verify.md:73-80`
  *Duplicate id in a cell*, *conflicting and sequential at once*, and *declaration changes after the check* have no dedicated contract sentence. Each behavior follows from stated rules (resolution-based validation, readiness neutrality, per-build execution with no stored result) and no AC depends on a literal. Disclosed; worth a follow-up only if the spec wants them spelled out.
- **[N4] Workflow finding-grammar paraphrase vs the skill's canonical grammar** — `docs/workflow.md:521-522` vs `.opencode/skill/merge-conflict/SKILL.md:99`
  The workflow quotes `<offender canonical reference(s)> — <detail>` where the skill says `<offender path or canonical reference(s)> — <specific detail>`. Semantically equivalent and the same shorthand the shipped `0005` guard uses (`docs/workflow.md:428-430`); disclosed in `verify.md:82-90`. No action needed.

## Security and error handling

- No secrets, credentials, tokens, or `.env` content in the diff.
- No executable/runtime code added to the product surfaces; the change is documents, prompts, and configuration.
- The check is consistently specified as non-fatal, read-only, lock-free, file-modifying-free, and never blocking (`docs/workflow.md:458-460,538-546`, `builder.md:66-69,106-108`).
- `/status` remains offline, read-only, and file-modifying-free (`.opencode/agent/status.md:184-186`).

## Tests

- The committed suite is untouched, as required (AC14); the pinned `Children` header substring and `Depends on` awk field 5 are preserved by the append-only column (verified against `tests/checks/80-cycle-fixture.sh:31,50`).
- The item suite `work/0006-parallel-plan-conflicts/verify-tests.sh` (144 assertions) is a genuine content harness: it greps the normative contract, the format authority, the canonical vocabulary, all operational derivatives, and the fixture, with negative controls (`absent`) and integration assertions. Its assertions are largely literal-presence checks, which is the only executable form available for prose (spec-sanctioned, `design.md:334-338`), and it re-runs `bash tests/run.sh` for AC15.
- Residual risk is accurately recorded in `verify.md`; no test was weakened, skipped, or deleted.

## Scope

- No scope creep. All 14 modified files are within the item's own `## Surface declaration` (`design.md:150-161`), and each maps to a task in `tasks.md` (T1-T8). No dependency added, no unrelated refactor, no reformatting beyond the touched regions.

## Not reviewed

- Runtime execution of `bash tests/run.sh` and `verify-tests.sh` (read-only guard prohibits executing programs). AC15 and the item-suite pass claims are taken from `verify.md` and cross-checked statically against the pinned checks.
- The pre-development check's behavior in a live multi-item `work/` tree (it is LLM-executed prose with no runtime harness, by spec design); only the contract text and its consistency were reviewed.
