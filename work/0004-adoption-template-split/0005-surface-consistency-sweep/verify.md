---
feature: 0004-adoption-template-split/0005-surface-consistency-sweep
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Re-verified after the /build pass that resolved review M1: the spec now records `/status [item-ref]` and the guard, surfaces, and mutation case were updated. All nine acceptance criteria pass and all edge cases are covered. Tester closed two residual test-strength gaps: AC1 now asserts every command usage string (not only /spec, /ship) and the README Commands table and mermaid are checked against separate required sets. `bash tests/run.sh` = 284 passed, 0 failed; `bash tests/mutation.sh` = 29/29. No production defect."
---

# Verification — Command signature and prompt-surface sweep

## Scope of this verification

This is a fresh verification of the **current working tree** (9 modified
tracked files + new `tests/checks/96-signature-sweep.sh`). It supersedes the
prior `verify.md`, which predated the `/build` pass that resolved review **M1**.
The tree now agrees with the amended spec (`spec.md:8,89` → `/status [item-ref]`),
so the contradiction that made AC1 partial is gone.

All acceptance criteria and edge cases are covered by committed tests. The
tester added two focused assertions to the item's own guard to close gaps found
by independent probing (AC1 all-commands; AC5 table-vs-mermaid required sets).
No production file was modified in this phase.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 284 passed, 0 failed, 0 skipped`; exit `0`. New `== AC22 signature agreement ==` block emits 75 `ok` lines, 0 `FAIL`. |
| `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh` | PASS | `TOTAL: 282 passed, 0 failed, 2 skipped`; exit `0`. AC22 never skips (bash/grep only). |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 29 checked passed, 0 failed`; exit `0`. Includes the committed AC22 mutation (`README.md` `/build` cell → `/build [task]`) caught and named. |
| 12 independent scratch probes (`bash tests/run.sh <mutated copy>`) | PASS | Each targeted regression exits non-zero and names the offending file and command; detail in "Independent sensitivity probes". |
| `grep -rnF -e '/plan <feature>' -e '/build [task-id]' -e '/build [task]' -e '/visual [url|slug]' -e '/visual [url]' -e '/fix <bug>' <in-scope surfaces>` | PASS | Only `docs/workflow.md:290` `/fix <bug>` remains, an explicit spec non-goal (design `:267-270`, review n3). |
| `grep -n '96-signature-sweep\|AC22' tests/README.md` | PASS | Check row at `tests/README.md:81`; AC22 mapping paragraph at `:100-110`. |
| `bash -n tests/checks/96-signature-sweep.sh` | PASS | Syntax clean; bash-3.2-compatible (no associative arrays, no `mapfile`). |

`git status --short` confirms the change surface is documentation/prompt/test
only: the nine modified doc/prompt files, `tests/README.md`, `tests/mutation.sh`,
and new `tests/checks/96-signature-sweep.sh`. No command behavior, phase,
routing, lifecycle, or artifact format changed.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — each command's usage string states the canonical signature; no command diverges | `96-signature-sweep.sh` AC22 `ALL_COMMANDS` loop asserts `Usage: <canonical>` for all 12 command files (12 `ok`), plus the `/ship` fix-landing clause anchored to the full usage line. Probes Pb (`plan.md` → `/plan <feature>`) and Pc (`ship.md` fix form dropped) each caught, naming the file. | PASS |
| AC2 — root `AGENTS.md` lifecycle table + supporting list canonical; stale forms gone | `96-signature-sweep.sh` `run_surface AGENTS.md` (12/12). Probes P1 (`/plan <feature>`), P7 (deleted `/build` row), P9 (`/status` → bare) each caught and named. Repository grep finds no stale in-scope form. | PASS |
| AC3 — `template/AGENTS.md` mirrors AC2; `## Project profile` placeholders intact | `96-signature-sweep.sh` `run_surface template/AGENTS.md` (12/12); `95-split-guard.sh` AC21 placeholder-profile assertions; probe P2 (`/build` → `[task]`) caught and named; direct read shows all ten profile fields still `_placeholder_`. | PASS |
| AC4 — six `docs/workflow.md` headings + `/visual` routing bullet canonical; stale forms gone | `96-signature-sweep.sh` `extract_wf_headings` (6) + `extract_wf_visual` (1) = 7/7. Probes P3 (bare `/review` heading) and P4 (`/visual [url or slug]`) each caught and named. | PASS |
| AC5 — `README.md` Commands table, lifecycle mermaid, quickstart canonical; stale forms gone | `96-signature-sweep.sh` now runs **separate** required sets: `extract_readme_commands` (12, table) and `extract_readme_mermaid` (7). Probes Pd (`/build [task]` cell) and Pa (`/build T2` cell) each caught, naming `README.md` + `/build`; `40-inventory.sh` and `90-packaging.sh` stay green. Quickstart invocations are intentionally untouched. | PASS |
| AC6 — skill routing block and rules canonical | `96-signature-sweep.sh` `extract_skill_routes` (11 occurrences / 9 required); probe P5 (`/plan <feature>`) caught and named. `/ship fix` is classified as an invocation, as the spec requires. | PASS |
| AC7 — `ask` description is the exact `Q&A agent. … Read-only.` text, not `Ultra-Basic Read-Only Agent.` | `96-signature-sweep.sh` exact-description grep + stale-text grep; probe P6 reverts to the stale text and is caught. | PASS |
| AC8 — committed check fails and names file+command on divergence; `tests/README.md` documents its area and stable token | `96-signature-sweep.sh` present and sourced by `run.sh` (75 `ok` lines); probes demonstrate divergence, missing-signature, unknown-command, and missing-file failures that name the file and command; `tests/mutation.sh` AC22 case; `tests/README.md:81,100-110`. | PASS |
| AC9 — `bash tests/run.sh` exits `0`; split guard, inventory, packaging, lifecycle, instruction agreements unbroken | `bash tests/run.sh` → `284 passed, 0 failed, 0 skipped`, exit `0`; `AC21` (28 ok), `AC9` inventory, `AC18`–`AC20` packaging, `AC7` lifecycle, `AC10` instructions all green; `bash tests/mutation.sh` 29/29. | PASS |

## Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| HTML-escaped `<`/`>` in mermaid | `normalize_sig` decodes `&lt;`/`&gt;`; the README `/spec` mermaid label passes; probe P9-equivalent for mermaid is covered by the mutation AC22 case. | PASS |
| Invocations are not signatures | Prose/quickstart invocations (bare `/build`/`/test`/`/review`/`/ship`, `/spec add dark mode`, `/build T2`) and the skill's `/ship fix` are classified as invocations and skipped. A designated **signature position** that holds an invocation no longer vanishes silently: the separate required sets report the missing signature (probe Pa). | PASS |
| `/ship` alternate form | The six surfaces state `/ship [item-ref]`; the command usage line is asserted to contain `Usage: /ship [item-ref] | /ship fix [short description]`. Probe Pc (fix form dropped from the usage line) is caught. | PASS |
| Free-form `/spec` argument | Canonical `/spec <feature or problem description | item-ref>` compared exactly; no multi-word description is scanned as a signature. | PASS |
| Missing surface or command | Probe P7 (deleted `/build` lifecycle row) → `AC22 AGENTS.md does not state a signature for /build`; P8 (removed `template/AGENTS.md`) → `AC22 template/AGENTS.md is missing`; unknown command → `states a signature for an unknown command`. | PASS |
| Adopter copy profile untouched | `95-split-guard.sh` AC21 placeholder assertions green; `template/AGENTS.md` profile fields all `_placeholder_`. | PASS |
| README table parseability | `40-inventory.sh` reads each Commands row's first cell and stays green; the escaped `/spec` cell `\|` is handled by both `20-lifecycle.sh` and `40-inventory.sh`. | PASS |
| First guard of its kind / minimal environment | `96-signature-sweep.sh` reads only live paths (never `work/**`), calls no `exit`, and uses bash + grep/sed/awk; forced-absent run still emits all 75 AC22 `ok` lines with no skip. | PASS |
| Future command changes | The `ALL_COMMANDS` loop and per-surface required sets fail an unknown/missing command by design; the canonical registry and guard are updated together. | PASS |
| Concurrency | Static documentation and prompt text only; no shared mutable state. | N/A |

## Independent sensitivity probes

Run against staged work-free scratch copies (each applying one regression, then
`bash tests/run.sh <copy>`), independent of `tests/mutation.sh`:

| Probe | Regression | Observed | Result |
| ----- | ---------- | -------- | ------ |
| P0 | clean copy, no mutation | exit `0`, `284 passed, 0 failed` | PASS |
| P1 | root `AGENTS.md` `/plan <item-ref>` → `<feature>` | caught, names `AGENTS.md` + `/plan` | PASS |
| P2 | `template/AGENTS.md` `/build [item-ref or task-id]` → `[task]` | caught, names `template/AGENTS.md` + `/build` | PASS |
| P3 | `docs/workflow.md` heading `/review [item-ref]` → bare `/review` | caught, names `docs/workflow.md` + `/review` | PASS |
| P4 | `docs/workflow.md` `/visual [url or item-ref]` → `[url or slug]` | caught, names `docs/workflow.md` + `/visual` | PASS |
| P5 | skill `/plan <item-ref>` → `<feature>` | caught, names the skill + `/plan` | PASS |
| P6 | `ask.md` description → `Ultra-Basic Read-Only Agent.` | caught (stale-text and missing-canonical), names `ask.md` | PASS |
| P7 | delete the `/build` lifecycle row from `AGENTS.md` | caught, `does not state a signature for /build` | PASS |
| P8 | remove `template/AGENTS.md` | caught, `template/AGENTS.md is missing` | PASS |
| P9 | root `AGENTS.md` supporting `/status [item-ref]` → bare `/status` | caught, names `AGENTS.md` + `/status` | PASS |
| Pa | `README.md` Commands `/build` cell → `/build T2` (invocation-shaped) | caught, `README.md does not state a signature for /build` | PASS |
| Pb | `.opencode/command/plan.md` usage → `/plan <feature>` | caught, names `plan.md` + expected canonical | PASS |
| Pc | `.opencode/command/ship.md` usage drops `| /ship fix …`, body keeps it | caught, names `ship.md` + expected usage line | PASS |
| Pd | `README.md` Commands `/build` cell → `/build [task]` | caught, names `README.md` + `/build` (also the committed mutation case) | PASS |

## Tester test changes

Two test-strength gaps found by independent probing were closed in the item's own
guard; no assertion was weakened, skipped, or deleted.

- `tests/checks/96-signature-sweep.sh` — added the AC1 `ALL_COMMANDS` loop so
  **every** command usage string is compared to the canonical registry (probe
  Pb). Previously only `/spec` and `/ship` were asserted, though AC1 covers each
  command.
- `tests/checks/96-signature-sweep.sh` — split the README surface into its
  Commands-table required set (12) and mermaid required set (7), instead of
  checking the union. This matches the design's "Required sets per surface" and
  stops the table from silently dropping a signature a mermaid label supplies
  (probe Pa).
- `tests/README.md` — updated the AC22 mapping sentence to state that AC1 covers
  every command usage string.

## Gaps and residual risk

- **Closed — review M1 (`/status` contradiction).** The spec's canonical table now
  records `/status [item-ref]` (`spec.md:89`), matching
  `.opencode/command/status.md:2`; the guard registry (`96-signature-sweep.sh:48`)
  and the four stating surfaces were updated together. AC1 holds.
- **Closed — review m1 (`/ship fix` file-wide grep).** The assertion is now
  anchored to the full usage line
  `Usage: /ship [item-ref] | /ship fix [short description]`; probe Pc confirms a
  body-only fix form no longer satisfies it.
- **Closed — review m2 (invocation-shaped table cell).** Separate README required
  sets mean an invocation-shaped Commands cell is reported as a missing
  signature; probe Pa confirms.
- **Closed — review m3 (no committed mutation for AC22).** `tests/mutation.sh`
  now carries an AC22 case; the opt-in self-check is 29/29.
- **R1 — `tests/README.md` documentation is not machine-asserted.** No check reads
  the Checks-table row or AC22 paragraph; verified by `grep` and inspection only.
  Low impact.
- **R2 — mermaid raw `|` in the `/spec` label is not render-verified.** The
  guard compares decoded text; the docs change has no browser surface. The
  design flags manual render verification in the PR (`design.md:241-245`). Low
  risk.
- **R3 — extractor breadth (review n4).** `extract_agents_table` matches every
  `^|` row and `extract_agents_supporting` runs to the next blank line; neither
  misfires on the current files, but a future table or a backticked `/…` token in
  the supporting-agents list could be scanned. Low impact; worth tightening if
  the agent list ever gains a slash token.
- **R4 — deliberately out-of-scope stale forms remain.**
  `docs/workflow.md:290` still carries `/fix <bug>`, and
  `.opencode/command/status.md`, `.opencode/command/roadmap.md`,
  `.opencode/agent/status.md`, `.opencode/agent/roadmap.md` still carry
  `/spec <feature>` in prose. The spec scopes `docs/workflow.md` to the six
  headings plus the `/visual` bullet and the command/agent files to
  `spec.md`/`ship.md`/`ask.md`, so these are not violations; noted for a future
  sweep.
- **Re-review needed.** `review.md` still records `request-changes` because of
  M1, which is now resolved in the spec and implementation. The reviewer should
  re-run `/review`; this phase does not edit another phase's artifact.
- **No production defect found.** All in-scope acceptance criteria are met by the
  current tree; nothing was handed back to `/build`.

## No test was weakened

No test was weakened, skipped, or deleted. This phase strengthened the item's own
guard (AC1 all-commands; README table/mermaid required-set split) and updated its
`tests/README.md` mapping; all pre-existing checks remain green.
