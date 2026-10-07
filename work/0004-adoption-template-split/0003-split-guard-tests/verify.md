---
feature: 0004-adoption-template-split/0003-split-guard-tests
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "All 8 acceptance criteria verified. Committed coverage: AC1 (suite), AC2-AC6 (positive AC21 assertions), AC7 (tests/README), AC8 (mutation AC21 caught and named). Negative sensitivity of AC2-AC6 independently probed in scratch (17 probes, all caught/named). Residual risk: spec AC8 caps the committed mutation at one (AC2), so the AC3-AC6 negative behaviors are not continuously mutation-guarded."
---

# Verification — Committed split guards

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 209 passed, 0 failed, 0 skipped`; exit `0`. Includes the new `== AC21 adoption split guard ==` block (28 `ok` lines). |
| `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh` | PASS | `TOTAL: 207 passed, 0 failed, 2 skipped`; exit `0`. AC21 guard uses only bash/grep/awk/sed, so it never skips; it still runs in the forced-absent tree. |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 27 checked passed, 0 failed`; exit `0`. Clean no-`work/` copy passes (AC2), forced-absent copy passes (AC14), `mutation AC21 caught and named (repointed the quickstart at the root copy)`, restore re-passes. |
| 17 scratch sensitivity probes (`bash tests/run.sh <mutated copy>`) | PASS | Each targeted regression exits non-zero and names the guarded surface; both legitimate-reformat probes exit `0`. Detail in "Independent sensitivity probes" below. |
| `grep -c '95-split-guard.sh' tests/README.md` / `AC21` / `AC18` / `AC20` | PASS | `2` / `3` / `3` / `3`; row at `tests/README.md:80`, mapping paragraph at `:87-97`; packaging descriptions retained. |
| `grep -n 'work/' tests/checks/95-split-guard.sh` | PASS | Only the comment "never work/**" (`:31`); no live `work/**` read. |
| Bash-3.2 feature scan of `tests/checks/95-split-guard.sh` | PASS | No `declare -A`, `mapfile`, `readarray`, or empty-array expansion. |

`git status --short` confirms the change surface is `tests/checks/95-split-guard.sh` (new), `tests/README.md`, `tests/mutation.sh` only — no non-`tests/` production surface was touched.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — suite exits 0 with new guards and every existing agreement still passing | `bash tests/run.sh` → `TOTAL: 209 passed, 0 failed, 0 skipped`, exit `0`; AC18–AC20, AC6–AC13 all green | PASS |
| AC2 — quickstart sources each of `AGENTS.md`, `opencode.json`, `.gitignore` from `template/<file>` to its destination, never from a root copy; a re-point fails and names the file | `95-split-guard.sh` `AC21 README.md quickstart sources <f> from template/<f>` (3); `AC21 README.md quickstart copies no whole template/ directory`; `AC21 template/<f> is missing…`. Negatives: probes E1–E6 (root re-point of each of the three, whole-dir copy, absent block, missing source) all caught and named | PASS |
| AC3 — `template/AGENTS.md` presents the unfilled placeholder Project profile; a filled/missing profile fails and names `template/AGENTS.md` | `95-split-guard.sh` `AC21 template/AGENTS.md has a Project profile section`, `…names all ten fields`, `…fields are unfilled placeholders`. Negatives: E7 (concrete `Test` value), E8 (root profile copied over template) both caught and named | PASS |
| AC4 — copy-set surfaces (`README.md`, `docs/customization.md`, `tests/README.md`, `CONTRIBUTING.md`) name the pristine sources and never claim an adopter receives a root copy; a reintroduced claim fails and names the surface | `95-split-guard.sh` `AC21 <surface> names all three adopter-pristine sources` (4); `AC21 <surface> has no claim that a root copy is an adopter source` (4). Negatives: E9–E12 appended a claim to each of the four surfaces; each caught and named | PASS |
| AC5 — quickstart per-file mapping and the `docs/customization.md` contract name the same `template/<file>` source; divergence fails and names the file | `95-split-guard.sh` `AC21 docs/customization.md contract agrees with README.md quickstart for <f>` (3). Negative: E13 diverged the `opencode.json` contract row; caught and named `opencode.json contract source` | PASS |
| AC6 — an edit under `template/` resolves deny while the adopter's root files stay allow; removing/reordering the guard fails and names `bootstrap` | `95-split-guard.sh` `AC21 bootstrap denies an edit to <path>` (5: three files + `template/sub/AGENTS.md` + `/repo/template/AGENTS.md`); `AC21 bootstrap still allows an edit to <path>` (4). Negatives: E14 (removed `template/**` deny), E15 (moved `**/AGENTS.md` allow after the denies) both caught and named `bootstrap` | PASS |
| AC7 — `tests/README.md` documents the new area and its source-of-truth mapping without displacing AC18–AC20 | `tests/README.md:80` Checks row (`95-split-guard.sh`, token `AC21`); `:87-97` mapping paragraph; AC18/AC20 text still present (`grep -c`) | PASS |
| AC8 — opt-in mutation self-check adds one mutation for the new area, caught and named, 0 failed, clean/forced-absent runs pass | `bash tests/mutation.sh` → `MUTATION TOTAL: 27 checked passed, 0 failed`, `mutation AC21 caught and named`, clean no-`work/` and forced-absent runs pass | PASS |

## Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Byte-identical pristine pair (`template/opencode.json`, `template/.gitignore`) | Guard asserts the quickstart *source path* (`template/<f>`), not a byte difference; suite passes with the pair byte-identical (`diff` confirms identical today) | PASS |
| Legitimate quickstart reformatting | Probe E16 (same-line `for … in …; do cp …; done` loop form) exits `0`; E17 (extra whitespace and `"$FRAMEWORK"/` quoting) exits `0` | PASS |
| Wholesale directory copy rejected | Probe E4 (`cp -r "$FRAMEWORK/template" .`) caught, named `README.md`, whole-directory message | PASS |
| Maintainer root copy present and bootstrapped | Root `AGENTS.md` carries a filled profile yet suite passes: AC3 inspects only `template/AGENTS.md`; probe E8 shows the root profile copied *into* template is caught, while the root file itself is not flagged | PASS |
| Shared-verbatim remainder (`.opencode/{agent,command,skill}`, `docs/*.md`) not treated as needing a `template/` source | Baseline suite green; the guard iterates only `AGENTS.md`, `opencode.json`, `.gitignore` | PASS |
| Missing/renamed pristine source fails naming it | Probe E6 (`template/.gitignore` removed) caught, named `template/.gitignore` | PASS |
| Missing/unreadable quickstart block fails naming `README.md` | Probe E5 (first ```bash fence relabelled) caught, named the block as unreadable | PASS |
| Guard ordering (broad root allow after `template/` deny) | Probe E15 reordered `**/AGENTS.md` allow after the denies; caught, named `bootstrap` | PASS |
| Over-reach: bootstrap guard does not fail legitimate root-file allows; copy-set guard does not flag AC18–AC20 packaging statements | Baseline `AC21 bootstrap still allows an edit to AGENTS.md/opencode.json/.gitignore//repo/AGENTS.md` (4) pass; `AC18`, `AC19`, `AC20` all still `ok` | PASS |
| Fresh-clone / no `work/`, optional tools forced absent | `tests/mutation.sh` `assert_clean_plain` + `assert_clean_absent`; direct forced-absent run `207 passed, 0 failed, 2 skipped` | PASS |
| Mutation sensitivity | `tests/mutation.sh` `mutation AC21 caught and named`; plus 15 independent scratch regressions all caught | PASS |

## Independent sensitivity probes

Run against staged scratch copies of the live surfaces (the same staging
`tests/mutation.sh` uses, deliberately without `work/`), each applying one
targeted regression and then `bash tests/run.sh <copy>`. All 17 passed:
15 regressions exited non-zero and named the expected surface, and 2
legitimate-reformat probes exited `0`.

| Probe | Regression | Expectation | Result |
| ----- | ---------- | ----------- | ------ |
| E1 | quickstart `AGENTS.md` re-pointed at root | caught, names `AGENTS.md` | PASS |
| E2 | quickstart `opencode.json` re-pointed at root | caught, names `opencode.json` | PASS |
| E3 | quickstart `.gitignore` re-pointed at root | caught, names `.gitignore` | PASS |
| E4 | whole `template/` directory copied | caught, whole-dir message | PASS |
| E5 | no readable ```bash block | caught, names `README.md` | PASS |
| E6 | `template/.gitignore` absent | caught, names `template/.gitignore` | PASS |
| E7 | template profile `Test` field made concrete | caught, names `template/AGENTS.md` | PASS |
| E8 | root profile copied over `template/AGENTS.md` | caught, names `template/AGENTS.md` | PASS |
| E9–E12 | root-copy claim appended to each of the four copy-set surfaces | caught, names that surface | PASS |
| E13 | `docs/customization.md` contract source diverged | caught, names the file | PASS |
| E14 | `"template/**": deny` removed | caught, names `bootstrap` | PASS |
| E15 | broad `**/AGENTS.md` allow moved after the denies | caught, names `bootstrap` | PASS |
| E16 | per-file copies rewritten as a same-line loop | clean tree exits `0` | PASS |
| E17 | extra whitespace + `"$FRAMEWORK"/` quoting | clean tree exits `0` | PASS |

## Gaps and residual risk

- **Only one committed mutation for the new area.** Spec AC8 (user decision) caps
  the new area at one mutation; the committed `tests/mutation.sh` case mutates the
  `AGENTS.md` quickstart source (AC2). The negative behaviors of AC3–AC6 are
  verified here by ad-hoc scratch probes (E7–E15) but are **not** continuously
  mutation-guarded. Adding more committed mutations would contradict AC8's "one
  mutation" decision and the design's single-token/one-mutation choice, so no
  committed test was added. Follow-up (future item) if continuous coverage is
  wanted: extend the AC21 mutation set.
- **AC4 wrong-claim scan is clause-scoped.** It splits each line at `". "` and
  flags a clause containing a filename + copy verb + root marker with no negation.
  A claim whose root marker and filename/copy verb fall in *different* clauses is
  not caught. This is the documented design trade-off (line/clause scope) chosen
  to avoid false positives on today's correct text; the four direct per-surface
  probes E9–E12 confirm the common single-clause form is caught.
- **Quickstart recognizer is bounded.** Only literal same-line `cp` and same-line
  `for … in …; do … done` forms are recognized; shell-variable indirection or
  exotic path spellings (e.g. `template/./AGENTS.md`) are not. These fail *closed*
  (the required `template/<f>` pair is reported missing), so they cannot cause a
  silent pass — they would produce a false failure a maintainer would see.
- **`resolve_edit` is a static re-implementation** of opencode's last-match
  `case`-glob resolution rather than a live `opencode debug agent` call (the CLI is
  optional). It is exercised by five deny and four allow samples plus the
  removal/reorder probes E14–E15; a divergence from opencode's real matcher on
  some unexercised pattern shape would not be detected by the suite.
- **No production defect found.** All probes and both committed runs pass; nothing
  was handed back to `/build`.

## No test was weakened

No existing test was weakened, skipped, or deleted. The new guard adds
assertions; `tests/mutation.sh` gained one AC21 case; `tests/README.md` gained
additive documentation only (AC18–AC20 text retained).
