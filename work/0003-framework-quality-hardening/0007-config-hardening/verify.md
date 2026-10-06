---
feature: 0003-framework-quality-hardening/0007-config-hardening
phase: test
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "All 8 acceptance criteria and all 6 spec edge cases PASS; item suite 51/0. This pass re-verified the reworked tree after the prior blocked pass: the builder added the bump-the-pin supersession guidance to docs/customization.md, and this pass strengthened the previously word-presence-only EDGE supersession guard to assert the actual sanctioned-path prose. No production file changed by this pass; only verify-tests.sh (test) and verify.md."
---

# Verification — Default config safety and reproducibility

## Summary

The change is config/doc-only: `opencode.json` (default agent `builder` →
`product`, Playwright MCP pinned `@latest` → `@0.0.83`), `docs/customization.md`
(always-loaded instruction rationale + model-capability note + MCP pin and
bump-pin guidance), `README.md` (default-agent and model summary, Agents table),
`.opencode/agent/builder.md` (drop the stale `(default)` claim), and the copied
MCP example in `.opencode/skill/browser-verification/SKILL.md`.

**All 8 acceptance criteria and all 6 spec edge cases pass.** The prior test pass
(status `blocked`) found one major defect: the spec's pin-supersession edge case
required documentation making *bumping the pin* the sanctioned upgrade path, and
no shipped doc said so. The builder reworked `docs/customization.md` (see
`tasks.md` frontmatter, "Rework 2026-10-05"), and this pass independently
re-verified the fixed tree. The suite is now **51/0**.

### Test command determination

There is no committed test runner. Confirmed via the `project-discovery` skill:
no root `package.json`, `pyproject.toml`, `Makefile`, `Cargo.toml`, `go.mod`,
`justfile`, or `Taskfile.yml`; no `.github/workflows/`; the only `package.json`
is `.opencode/package.json` (`{"dependencies":{"@opencode-ai/plugin":"1.18.34"}}`,
no `scripts.test`). `AGENTS.md` → "Project profile" is an unfilled template.

Matching the framework's established pattern
(`work/0001-framework-consistency-hardening`, `work/0002-agentic-roadmaps`,
`0003/0001-state-model`, `0003/0002-readiness-ship-state`), verification is
read-only shell assertions plus real `opencode debug` invocation. This item's
focused suite is
`work/0003-framework-quality-hardening/0007-config-hardening/verify-tests.sh`
(51 assertions). No product test harness was added — the spec assigns the
committed harness/CI to `0006-committed-tests-ci`.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0003-framework-quality-hardening/0007-config-hardening/verify-tests.sh` | PASS (51 passed, 0 failed, 0 skipped) | full AC1–AC8 + edge-case coverage |
| `opencode debug config` | PASS | parses; `default_agent` = `product`; `instructions` exactly the three files; Playwright command `["npx","-y","@playwright/mcp@0.0.83","--headless","--isolated"]`; disabled built-ins `[build, plan, general, explore]` |
| `opencode debug agent product` | PASS | `name: product`, `mode: primary`, not disabled; `edit` = `*` deny, `work/**` allow, `**/work/**` allow |
| `npm view @playwright/mcp@0.0.83 version` | PASS | `0.0.83` — the pin is a published version |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | `TOTAL: 179 passed, 0 failed` (framework suite) |
| `bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh` | PASS | `TOTAL: 69 passed, 0 failed` |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | `TOTAL: 51 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | FAIL (pre-existing) | `TOTAL: 99 passed, 4 failed`; reproduced on a detached clean `HEAD` (`ff5a2fa`) worktree — unrelated to this item (see Gaps) |
| 4 mutation runs on a throwaway `/tmp/opencode/mut-0007` copy | PASS (mutations bite) | each targeted guard failed as designed; see "Mutation evidence" |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 default agent `product`, enabled `primary`, edit limited to work artifacts | `AC1 opencode.json default_agent is product`; `AC1 product is not among the disabled built-ins`; `AC1 'opencode debug config' exits 0`; `AC1 'opencode debug agent product' resolves`; `AC1 product resolves as mode primary`; `AC1 product debug is not disabled`; `AC1 product edit is * deny then work/** and **/work/** allow`; `AC1/AC8 resolved default_agent is product`; `opencode debug config`; `opencode debug agent product` | PASS |
| AC2 every live default-agent mention agrees; no builder-as-default | `AC2 README Configuration names product as the default agent`; `AC2 README Agents table marks product primary (default)`; `AC2 builder.md description dropped (default)`; `AC2 builder.md no longer claims to be the default agent`; `AC2 broad sweep: 42 live surfaces say product, never builder` | PASS |
| AC3 Playwright MCP one exact published version; no floating tag; same version in docs | `AC3 one distinct Playwright spec across config + docs`; `AC3 spec is an exact semver pin`; `AC3 no floating tag (@latest/*/^/~) in any Playwright command`; `AC3 customization.md mirrors the exact pin`; `AC3 browser-verification SKILL mirrors the exact pin`; `AC3 pin @playwright/mcp@0.0.83 is published (npm)` | PASS |
| AC4 always-loaded instructions exactly the three quickstart-copied files | `AC4 instructions are exactly the three contract files`; `AC4 instruction path exists: …` ×3; `AC4 quickstart copies AGENTS.md`; `AC4 quickstart copies docs/*.md` | PASS |
| AC5 each entry's purpose + per-request cost (and total) stated | `AC5 customization has an Always-loaded instructions section`; `AC5 section names …` ×3; `AC5 … purpose stated` ×3; `AC5 at least three per-entry cost figures present`; `AC5 section states the total per-request cost`; `AC5 section states the always-loaded cost model` | PASS |
| AC6 model docs: vision-capable, strongest, no overrides; no text-only-degradation claim | `AC6 customization states the default is vision-capable`; `AC6 customization states it is the strongest shipped option`; `AC6 customization states /visual and /reviewer need no overrides`; `AC6 README states vision-capable, strongest, and no per-agent overrides`; `AC6 broad sweep: 42 live surfaces carry no text-only-degradation claim`; independent `grep` found no degradation wording on live surfaces | PASS |
| AC7 no agent declares its own `model` override | `AC7 no agent frontmatter declares model:; all inherit the default`; independent frontmatter scan of all 14 `.opencode/agent/*.md` | PASS |
| AC8 config parses; default resolves without a disabled agent | `AC8 'opencode debug config' parses without error`; `AC8 default agent resolves and names no disabled agent`; `opencode debug config`; `opencode debug agent product` | PASS |

## Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Merged rather than overwritten config; intended default clear | `EDGE merged config: README documents merge-not-overwrite` (README:53-54); README Configuration names `product` (`README.md:225`) and marks it `primary (default)` (`README.md:166`) | PASS |
| Pinned version later yanked or superseded; bumping the pin is the sanctioned path | `EDGE supersession: docs make bumping the pin the sanctioned path and forbid floating tags` — strengthened this pass to require both the bump-the-pin instruction and the floating-tag prohibition (`docs/customization.md:195-200`) | PASS |
| Partial instruction copy — set limited to quickstart-guaranteed files | `EDGE partial copy: every instruction path is quickstart-copied`; AC4 checks; quickstart copy lines `README.md:40-47` copy `AGENTS.md` and `docs/*.md` | PASS |
| Default agent disabled or renamed by a user — validation surfaces it | manual: mutate a copy's `default_agent` to a disabled built-in; `opencode debug agent <default>` reports `Agent X not found`. Note: `opencode debug config` alone does not reject it — opencode behavior, not introduced here (validation/repair of a user-broken default is outside this item) | PARTIAL/MANUAL |
| `small_model` interaction unchanged and equal to global model | `EDGE small_model unchanged and equal to model` (`opencode.json` both `deepseek/deepseek-flash`) | PASS |
| No vision model available — `--headless`/`--isolated` QA still runs | `EDGE no-vision fallback: headless browser QA documented`; `EDGE no-vision fallback: isolated profile documented` (`docs/customization.md:191-193`) | PASS |

## Changes made this pass

Test-only. No production code, config, or other phase's artifact was modified.

1. **Rework re-verified.** The prior pass's one failure ("no shipped doc says how
   to move the pinned version") is resolved by
   `docs/customization.md:195-200`, which now says to bump the pin and never
   restore a floating tag. Re-ran the full item suite: `51 passed, 0 failed`.
2. **Strengthened the supersession guard** in `verify-tests.sh`. The previous
   assertion was `grep -riE 'bump|pin(ned)?|floating'` over README and
   customization — it would have passed on an incidental occurrence of any of
   those words. It now requires both an explicit "bump the pin" instruction and
   an explicit floating-tag prohibition in `docs/customization.md`, so removing
   the sanctioned-path prose fails the guard (proved by mutation M1).

## Mutation evidence

Each run mutated a throwaway copy under `/tmp/opencode/mut-0007` (production tree
untouched) and ran the item suite against the copy's absolute path. Baseline on
an untouched copy was `51 passed, 0 failed`. Every targeted guard failed as
designed.

| Mutation | Expected guard | Observed |
| -------- | -------------- | -------- |
| Delete the bump-pin supersession sentence in `docs/customization.md` | EDGE supersession | BITES — `50 passed, 1 failed` |
| Restore `@playwright/mcp@latest` in `opencode.json` | AC3 | BITES — `49 passed, 2 failed` |
| `default_agent` `product` → `builder` | AC1 | BITES — `49 passed, 2 failed` |
| Add a `model:` override to `.opencode/agent/product.md` | AC7 | BITES — `50 passed, 2 failed` |

## Gaps and residual risk

- **Scoping of AC2/AC6 versus historical `work/**` records.** The spec phrases
  AC2 as "no file still states that `builder` is the default" and AC6 as "no file
  claims visual QA degrades because the default is text-only." The live sweep
  excludes immutable historical `work/**` artifacts, per `design.md` and the
  artifact contract. The only residual mentions are historical:
  `work/0003-framework-quality-hardening/roadmap.md` (planning record carrying the
  disproven text-only premise and `default_agent: builder`) and this item's own
  `spec.md`/`design.md`/`tasks.md` quoting the old premise to correct it. They
  are superseded and are never rewritten by a later phase (rewriting another
  phase's artifact is forbidden). Independently confirmed: no live surface
  (`README.md`, `AGENTS.md`, `opencode.json`, `.opencode/agent`, `.opencode/command`,
  `.opencode/skill`, `docs`) pairs `builder` with default status or claims
  text-only degradation.
- **Disabled-default validation is opencode behavior, not added here.** A manual
  mutation shows `opencode debug config` still exits 0 when `default_agent` names
  a disabled agent; the break surfaces only at `opencode debug agent <default>`
  (`Agent X not found`). AC8 is met for the shipped config (the default
  resolves); validating/repairing a user-broken default is outside this item.
  Recorded so `/review` can judge whether a doc pointer is wanted.
- **Token-cost figures are approximate.** `docs/customization.md:189-193` states
  the measurement basis (current file size ÷ ~4 bytes/token) and asks for a
  refresh when a listed file changes; AC5 does not require exact integers.
- **Pre-existing, unrelated:** `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh`
  fails 4 assertions (99/4). Independently reproduced in a detached clean `HEAD`
  (`ff5a2fa`) worktree. Its `AC1`/`AC3` checks assert that that item's own
  artifacts appear in `git status` (i.e. are untracked/modified), which is false
  once they are committed — a snapshot-state check belonging to that item's
  committed-artifact transition / `0006-committed-tests-ci`, not caused by this
  item's five-file config/doc diff.
- **No production file was modified by this pass.** The only changes are to the
  test suite (`verify-tests.sh`) and this `verify.md`; all suite failures were
  investigated and none were silenced, skipped, or deleted.

## Self-check

- [x] Every acceptance criterion appears in the coverage matrix.
- [x] Each covered criterion names the specific test that covers it.
- [x] Manual/untestable criteria say so and why, with steps (disabled-default
      edge; `opencode debug agent <default>`).
- [x] Commands run are recorded verbatim with results.
- [x] Residual risk and known gaps are stated plainly.
- [x] No test was weakened, skipped, or deleted to obtain a pass (the strengthened
      supersession guard is strictly stronger than the prior pass's).
