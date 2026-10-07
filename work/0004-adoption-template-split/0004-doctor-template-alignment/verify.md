---
feature: 0004-adoption-template-split/0004-doctor-template-alignment
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Verified statically and with real /doctor runs (opencode 1.18.35). No committed tests added: the spec makes tests/checks/** and committed split guards child 0003's scope, and design.md's test strategy is static + diagnostic runs. Scratch-clone injections were used for the behavioural ACs (2/3/4) and discarded."
---

# Verification — Doctor alignment with the adoption template split

## Summary

All 11 acceptance criteria and all edge cases pass. The diff is prompt/doc-only
(`.opencode/agent/doctor.md`, `.opencode/command/doctor.md`, `README.md`); the
committed suite is green (182 passed, 0 failed, 0 skipped) and a real `/doctor`
run on the framework repository is clean (14 agents / 12 commands / 10 skills,
no findings). Three behavioural injections in a throwaway clone each produced the
expected finding with the expected file/line and no cascade. No defects found.

No user-facing UI: the work item changes agent/command prompts and one README
paragraph, so `/visual` does not apply.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 182 passed, 0 failed, 0 skipped`; exit 0 (AC11, AC5 counts, AC7 permissions) |
| `opencode run --agent doctor "Run the framework consistency diagnostic."` (framework repo) | PASS | `No findings — repository is consistent.`; counts `agents 14, commands 12, skills 10`; exit 0 |
| Static sweep of `.opencode/agent/doctor.md` `<inputs>`/`<completeness_rule>`, `.opencode/command/doctor.md`, `README.md`, `AGENTS.md`, template/AGENTS.md, `docs/workflow.md` | PASS | 25/25 assertions passed (see matrix) |
| Scratch-clone: append `/tmp/doctor-probe.txt` to `template/AGENTS.md`, run `/doctor` | PASS | `[TEMP-PATH-OUTSIDE-WORKSPACE] temp-file policy <-> template/AGENTS.md:139: directs temporary output to "/tmp/doctor-probe.txt" instead of … scratch/.` |
| Scratch-clone: rename `template/AGENTS.md` → `.bak`, run `/doctor` | PASS | Exactly one `[SURFACE-MISSING] template/AGENTS.md: absent or unreadable; dependent template-list checks skipped.`; no per-item cascade; unrelated temp-path finding still fired |
| Scratch-clone: drop `doctor` from `template/AGENTS.md` supporting-agents list, run `/doctor` | PASS | `[AGENT-UNDOCUMENTED] .opencode/agent/doctor.md <-> template/AGENTS.md supporting-agents list: not named.` |
| `git status --porcelain` before/after a `/doctor` run | PASS | Identical (only the 3 intended modified files + untracked `work/` artifacts; `scratch/` is gitignored) |
| Independent template-coverage check: every `.opencode/agent/*.md` and `.opencode/command/*.md` basename appears in `template/AGENTS.md` | PASS | `missing=0`; 14 agents / 12 commands covered |
| `diff -q template/opencode.json opencode.json`; `diff -q template/.gitignore .gitignore` | PASS | Byte-identical (the pristine case AC6 says must not be reported) |

Environment: `opencode 1.18.35`, Bash, git. All `/doctor` runs were read-only;
the inject-and-run cycles happened only in a copy under `scratch/` (gitignored)
that was deleted afterwards.

## Acceptance coverage

| Criterion | Test(s) / mechanism | Result |
| --------- | ------------------- | ------ |
| AC1 — declared doc surfaces include `template/AGENTS.md` beside root `AGENTS.md` and `README.md` | static: extract `<inputs>` from `.opencode/agent/doctor.md`; grep `template/AGENTS.md`, `README.md`, `` `AGENTS.md` `` | PASS |
| AC2 — temp-path check scans `template/`, reports an absolute system-temp path with file and line | static: `<inputs>` item 6 and check 8 both list `template/`; integration: scratch-clone injection `/tmp/doctor-probe.txt` → `TEMP-PATH-OUTSIDE-WORKSPACE … template/AGENTS.md:139` | PASS |
| AC3 — `template/AGENTS.md` is a required surface; absent/unreadable = exactly one finding, no cascade, unrelated checks still run | static: `<completeness_rule>` names it, "exactly one", skip clause, finding example; integration: scratch-clone rename → one `SURFACE-MISSING`, no per-item cascade, temp-path check still ran | PASS |
| AC4 — supporting-list divergence is reported naming surface and item | static: checks 1–2 require a name in both `AGENTS.md` files; integration: scratch-clone drops `doctor` from the template list → `AGENT-UNDOCUMENTED … <-> template/AGENTS.md supporting-agents list: not named.` | PASS |
| AC5 — checked counts agree with disk; no `COUNT-MISMATCH`/inventory finding from the `template/` Layout entry | real `/doctor` run reports 14/12/10 with no findings; `bash tests/run.sh` AC9 count/membership checks pass; suite AC20 Layout↔disk passes; `template/` Layout lines carry none of the unit phrases | PASS |
| AC6 — expected pristine state (placeholder profile, byte-identical config, maintainer-only template) produces no finding | static: pristine clause in `<inputs>`/`<completeness_rule>`; integration: clean `/doctor` run; `diff` confirms `template/opencode.json` and `template/.gitignore` are byte-identical and still not reported | PASS |
| AC7 — README Agents-table `doctor` row labeled maintainer-only, compared cells unchanged | static: `git show HEAD:README.md` doctor row == working-tree row (byte-identical); the maintainer-only note follows the table | PASS |
| AC8 — every documented `/doctor` / `doctor` surface carries the marker, none omits it | static: README Commands row, README Agents note, root `AGENTS.md` supporting commands+agents, `docs/workflow.md`, both frontmatter descriptions, `template/AGENTS.md`; broad `grep -ri doctor` sweep shows only context/removal lines without a marker | PASS |
| AC9 — `/doctor` writes nothing; read-only guarantee unchanged | frontmatter permission block identical to `HEAD`; `git status --porcelain` identical before/after the real run; `/doctor` command line confirms read-only | PASS |
| AC10 — agent and command describe the same surfaces/codes, audience unchanged, catalogue preserved not replaced | static: both name `template/AGENTS.md`, `template/`, keep "nine checks", and carry the full code set; maintainer-only audience unchanged | PASS |
| AC11 — `bash tests/run.sh` exits 0 | `bash tests/run.sh` → `182 passed, 0 failed, 0 skipped`, exit 0 | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Expected placeholder profile not treated as drift | clean `/doctor` run + explicit clause (`doctor.md:58-60`, `:173-176`) | PASS |
| Byte-identical pristine `opencode.json`/`.gitignore` not reported | `diff -q` shows identical; clean run; explicit "not compared" clause | PASS |
| Missing/unreadable template surface → one finding, no cascade, no suppression | scratch-clone rename run | PASS |
| Adopter context (no `template/`) | inferred from the rename run (single `SURFACE-MISSING`) plus the per-surface skip clause; `template/` absent means the temp scan simply finds nothing | PASS (partly inferred) |
| Layout-block confusion | suite AC20 + clean run; `# N role prompts`-style lines appear only on `agent/`, `command/`, `skill/` | PASS |
| Drift in the adopter copy (both directions) | scratch-clone name removal produced the finding; the template currently covers all 14/12 names (`missing=0`) so no phantom/undocumented finding in the pristine run | PASS |
| Self-reference (doctor's own temp-path policy not flagged) | clean `/doctor` run reported no `TEMP-PATH-OUTSIDE-WORKSPACE` on its own definition | PASS |
| No new always-loaded instruction file | `opencode.json` unchanged vs `HEAD`; suite AC10 passes | PASS |
| Wrong working directory | process step 0 (resolve via `git rev-parse --show-toplevel`) unchanged; not separately exercised — manual only | MANUAL (unchanged behavior) |
| Concurrent activity | `/doctor` run created/edited nothing (`git status` unchanged) | PASS |

## Gaps and residual risk

- **No committed regression guard for the doctor prompt's new coverage.** The
  spec explicitly makes committed split guards `tests/checks/**` child `0003`'s
  scope and `design.md` prescribes static inspection + diagnostic runs. The
  behavioural ACs (2/3/4) were exercised by real `/doctor` runs in a throwaway
  clone, but nothing in the committed suite will catch a future edit that drops
  the `template/AGENTS.md` surface. This is a known, spec-sanctioned gap until
  child `0003` adds its guards.
- **LLM-driven diagnostic.** `/doctor` is a prompt executed by a model; its
  behaviour is best-effort and not deterministic. Each injected scenario produced
  the expected finding with the correct file/line, but the reliability of a
  specific run is not guaranteed by construction.
- **Directory-level temp scan over `template/` is broader than "documentation
  surfaces".** While `template/AGENTS.md` was renamed to `.bak`, a `/tmp` string
  inside the `.bak` file was still reported. That matches the declared
  directory-level scan (`doctor.md:120-124`, `:65-66`) and is not a defect, but
  it means any future non-document file placed under `template/` is scanned.
- **`wrong working directory` not separately exercised.** The process step that
  resolves the root is unchanged by this diff; verified by inspection, not by an
  invocation from a subdirectory.
- **No tests were added or updated** — deliberately, per the spec's
  `0003-split-guard-tests` boundary and `design.md`'s "no test file changes".
  This is not a weakened, skipped, or deleted test; the existing suite is
  untouched and green.

Follow-up suggestion (not required by this spec): when child `0003` adds split
guards, include a check that `.opencode/agent/doctor.md` still names
`template/AGENTS.md` in its inputs and completeness rule, so the detector's
coverage cannot silently regress.
