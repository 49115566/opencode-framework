---
feature: 0004-adoption-template-split/0001-adopter-template-split
phase: test
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0004-adoption-template-split
notes: "Independent verification. No committed split guards were added: the spec's Non-goals assign them to child 0003-split-guard-tests, so this item is verified by the committed suite plus explicit per-AC commands, not by new tests. All seven acceptance criteria and all eight edge cases pass."
---

# Verification — Adopter/maintainer template split

## Scope and method

The work item adds an adopter-pristine source (`template/AGENTS.md`,
`template/opencode.json`, `template/.gitignore`), fills the framework's own
`AGENTS.md` Project profile, documents the split contract in
`docs/customization.md`, and keeps the committed agreements green via `README.md`
`## Layout` and `tests/mutation.sh` staging.

The spec's **Non-goals** explicitly defer "committed guard tests for the split" to
child `0003-split-guard-tests`. Adding a guard to `tests/checks/**` here would
pre-empt that sibling and violate the item's scope, so no new tests were written.
Each criterion below is instead verified by a reproducible command against the
live tree, with the exact invocation recorded. This is the correct coverage for a
"stand up the split" item whose permanent guards are a separate work item.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 182 passed, 0 failed, 0 skipped`; includes `AC20 README Layout ...` all `ok` |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 25 checked passed, 0 failed` |
| `opencode debug config` | PASS | exit 0; output is valid JSON; `instructions = ["AGENTS.md","docs/workflow.md","docs/artifact-conventions.md"]`; zero `template/` references |
| T1 verify command (below) | PASS | pristine sources exist; `diff -q` identical for `opencode.json`/`.gitignore`; `template/AGENTS.md` holds placeholders |
| T3 verify command (below) | PASS | root profile fully bootstrapped; no placeholder/example text; config parses |
| T4 verify command (below) | PASS | contract names all three pristine sources and `shared verbatim` |

Exact commands for the focused checks (run from the repo root):

```sh
# T1 / AC1 / AC3
for f in AGENTS.md opencode.json .gitignore; do test -f "template/$f" || exit 1; done \
  && grep -q 'one or two sentences on what this project does' template/AGENTS.md \
  && grep -q '_e.g. pnpm' template/AGENTS.md \
  && grep -q '"enabled": false' template/opencode.json \
  && grep -q 'scratch/' template/.gitignore \
  && diff -q opencode.json template/opencode.json \
  && diff -q .gitignore template/.gitignore
# -> exit 0

# T3 / AC2 / AC5 / AC7
! grep -qE 'one or two sentences on what this project does|_e\.g\.|replaces the placeholders below' AGENTS.md \
  && grep -q 'bash tests/run.sh' AGENTS.md \
  && grep -q '\*\*Purpose\*\*' AGENTS.md \
  && grep -q '\*\*Key directories\*\*' AGENTS.md \
  && grep -q 'one or two sentences on what this project does' template/AGENTS.md \
  && diff -q opencode.json template/opencode.json \
  && diff -q .gitignore template/.gitignore \
  && grep -q '"AGENTS.md"' opencode.json \
  && ! grep -q 'template/AGENTS.md' opencode.json \
  && opencode debug config >/dev/null
# -> exit 0

# T4 / AC4
grep -q 'template/AGENTS.md' docs/customization.md \
  && grep -q 'template/opencode.json' docs/customization.md \
  && grep -q 'template/.gitignore' docs/customization.md \
  && grep -qi 'shared verbatim' docs/customization.md
# -> exit 0

# Root files unchanged vs the previous commit (edge: already-adopted repos)
git diff --quiet HEAD -- opencode.json && git diff --quiet HEAD -- .gitignore
# -> exit 0 (both unchanged)
```

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 — adopter-pristine source for each of `AGENTS.md`, `opencode.json`, `.gitignore` exists and holds no framework-bootstrapped value | `test -f template/<file>` (all three present); `template/AGENTS.md` is byte-identical to `HEAD:AGENTS.md` (placeholder profile); `diff -q opencode.json template/opencode.json` and `diff -q .gitignore template/.gitignore` byte-identical | PASS |
| AC2 — root `AGENTS.md` profile holds verified values / explicit `none`, no placeholder or example text | `! grep -qE 'one or two sentences on what this project does\|_e\.g\.\|replaces the placeholders below' AGENTS.md`; all 10 field labels present (`Purpose`, `Primary language(s)`, `Package manager`, `Install`, `Test`, `Lint`, `Typecheck`, `Format`, `Build`, `Key directories`); `Test` = `bash tests/run.sh`, rest `none` | PASS |
| AC3 — pristine `AGENTS.md` still presents the placeholder template with no framework values | `grep -q 'one or two sentences on what this project does' template/AGENTS.md`; `grep -q '_e.g. pnpm' template/AGENTS.md`; `! grep -q 'bash tests/run.sh' template/AGENTS.md` | PASS |
| AC4 — contract names both copies for all three files and states `docs/*.md` shared verbatim; no copied file ambiguous | `docs/customization.md` "Adopter-pristine sources and framework copies": table rows `template/AGENTS.md` / root `AGENTS.md`, `template/opencode.json` / root `opencode.json`, `template/.gitignore` / root `.gitignore`; sentence "has a single source and is shared verbatim"; "`docs/*.md` are never templated." | PASS |
| AC5 — no maintainer-bootstrapped value in the framework copy appears in the pristine source | `template/AGENTS.md` lacks root's `Purpose` sentence, `Test` value, and `none (opencode prompt/config files...)` value (grep returns no match); `opencode.json`/`.gitignore` byte-identical with no bootstrapped value to leak | PASS |
| AC6 — `bash tests/run.sh` passes; packaging/inventory/instruction agreements not regressed | `bash tests/run.sh` → `TOTAL: 182 passed, 0 failed, 0 skipped` (`AC9`/`AC10`/`AC19`/`AC20` all `ok`); `bash tests/mutation.sh` → `MUTATION TOTAL: 25 checked passed, 0 failed` | PASS |
| AC7 — configuration loads/parses, root (bootstrapped) `AGENTS.md` is the contract in effect, pristine source not loaded | `opencode debug config` exits 0, output parses as JSON, `instructions` is exactly the three root paths with zero `template/` references; `grep -q '"AGENTS.md"' opencode.json` and `! grep -q 'template/AGENTS.md' opencode.json` | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Byte-identical copies (pristine may equal framework copy) | `opencode.json`/`.gitignore` are byte-identical and are still explicitly designated in the contract table | PASS |
| Prompt-only repository (explicit `none` fields valid) | Root profile uses `none` for eight fields and names the committed suite; no placeholder mistaken for a value | PASS |
| Unprotected intermediate window (acceptance holds without `0002`) | AC1/AC5 are scoped to the pristine source, which exists and is placeholder; the contract names the intended `template/<file>` target for `0002` to consume | PASS |
| Ambiguous copy globs (pristine and maintainer copy both copied) | Contract's single-source sentence covers `.opencode/{agent,command,skill}` and `docs/*.md`; the quickstart glob `"$FRAMEWORK"/docs/*.md` cannot reach `template/`; no glob catches both copies | PASS |
| Already-adopted repositories (no merge-semantics change) | `git diff --quiet HEAD -- opencode.json` and `... -- .gitignore` both exit 0; only additive `template/` and a content-only `AGENTS.md` profile change exist | PASS |
| Always-loaded instruction cost (no new loaded file) | `opencode.json` `instructions` still exactly three root paths; the new contract section lives in non-loaded `docs/customization.md`; cost table refreshed from measured sizes | PASS |
| Root layout agreement | `bash tests/run.sh` `AC20` green: `template/` and its files documented in `README.md` and present on disk | PASS |
| Partially filled profile | All 10 profile fields carry a value or explicit `none`; no half-converted placeholder remains | PASS |

## Gaps and residual risk

- **No committed regression guard yet — by design.** The spec's Non-goals assign
  split guards to child `0003-split-guard-tests`. Consequently nothing in
  `tests/run.sh` will fail if the pristine/framework split later drifts or if
  `template/` is removed. This is expected for `0001`; `0003` closes it. The
  reviewer should confirm `0003` remains sequenced before any release.
- **Intermediate quickstart leak window is real.** `README.md` Quickstart still
  copies root `AGENTS.md`, which is now the bootstrapped maintainer copy, until
  child `0002` rewires it. The spec accepts this; no release or cutover may
  happen between `0001` and `0002`.
- **AC1/AC5 for `opencode.json` and `.gitignore` are satisfied only because the
  framework's copies are not yet bootstrapped.** Their pristine copies are
  byte-identical. If the framework later bootstraps them (e.g. enables the
  Playwright MCP), divergence must be introduced and `0003`'s guards must cover
  it. Not a defect today; recorded so it is not silently forgotten.
- **Minor scope observation (not an AC failure):** the `docs/customization.md`
  always-loaded table also refreshes the `docs/workflow.md` and
  `docs/artifact-conventions.md` rows and the total, beyond T4's stated
  `AGENTS.md` row. The refreshed values match the current measured sizes
  (7.4 / 17.9 / 12.9 KB; total ~38.2 KB) and the three-path instruction set is
  unchanged, so no acceptance criterion is violated.
- **No manual-only criteria.** Every acceptance criterion is covered by a
  reproducible command or integration run; none is left to untestable judgment.
