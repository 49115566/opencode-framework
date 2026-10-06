---
feature: 0003-framework-quality-hardening/0006-committed-tests-ci
phase: test
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "Canonical test command is `bash tests/run.sh` (documented in tests/README.md); the AGENTS.md Project profile stays a placeholder, owned by sibling 0009-surface-consistency. No new tests were added: this item's deliverable IS the committed test suite, so editing tests/ would change the artifact under test. Verified independently by running the suite, its mutation self-check, forced-absent/exit-contract probes, and an independent out-of-band mutation reproduction."
---

# Verification — Committed test harness and CI

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 160 passed, 0 failed, 0 skipped`; exit `0`. Baseline over all eight checks. |
| `bash tests/run.sh /nonexistent` | PASS | Setup-error contract: prints `setup error: cannot cd to /nonexistent`; exit `2`. |
| `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh` | PASS | `TOTAL: 158 passed, 0 failed, 2 skipped`; exit `0`. Two visible skips: AC11 opencode resolution, AC12 published-version probe. |
| `bash tests/run.sh` (twice) | PASS | Summaries byte-identical (`TOTAL: 160 passed, 0 failed, 0 skipped`) — idempotent, read-only. |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 19 checked passed, 0 failed`; exit `0`. Clean no-`work/` copy passes (AC2), forced-absent copy passes (AC14), each of AC6–AC13 caught and named, restored copy re-passes (AC15). |
| `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` | PASS | Parses; triggers `push` + `pull_request`; one `tests` job; no `secrets.` reference. |
| `git check-ignore tests/run.sh .github/workflows/ci.yml` | PASS | No output → neither is ignored; both are committable. |
| `git check-ignore scratch/` | PASS | `scratch/` ignored (`.gitignore:20`), so mutation temp writes cannot be committed. |
| `git diff --name-only -- .opencode docs/workflow.md docs/artifact-conventions.md AGENTS.md opencode.json 'work/**'` | PASS | Empty (0 files). No immutable surface changed. |
| `git status --short -- 'work/**/verify-tests.sh'` | PASS | Empty; all 8 tracked historical suites untouched. |
| Independent mutation: move README default marker `product`→`scribe` on a throwaway no-`work/` copy, `bash tests/run.sh <copy>` | PASS | exit `1`; `FAIL AC11 README.md marks 'scribe' as default but opencode.json declares 'product'`. Reproduced outside `mutation.sh`. |

No tests were added or modified. This work item's deliverable *is* the committed
test suite (`tests/**`, `.github/workflows/ci.yml`); adding or editing check files
would alter the artifact under test rather than verify it. Verification was done
by exercising the delivered harness, its opt-in mutation self-check, and
independent out-of-band probes.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 canonical command, one process, exit 0/non-zero | `bash tests/run.sh` → `TOTAL: 160 passed…`, exit `0`; independent mutated copy → exit `1`; `bash tests/run.sh /nonexistent` → exit `2` | PASS |
| AC2 committed & self-contained, no `work/**` needed | `tests/mutation.sh` `assert_clean_plain` "clean copy (no work/) passes (AC2)"; grep of `tests/{run.sh,lib.sh,checks/*}` finds no `work/` path read (only permission-pattern literals and comments) | PASS (tracked-ness materializes at `/ship`; files are present and not gitignored) |
| AC3 per-assertion result + passed/failed/skipped summary | Observed `ok`/`FAIL`/`skip` per assertion lines and `TOTAL: <p> passed, <f> failed, <s> skipped`; forced-absent run prints `158 passed, 0 failed, 2 skipped` and exits `0` | PASS |
| AC4 CI on push | `.github/workflows/ci.yml` lines 6–8 `on: push:`; YAML parses; job runs `bash tests/run.sh` | MANUAL (static) — live GitHub status not observable until `/ship` commits and pushes |
| AC5 CI on pull request | `.github/workflows/ci.yml` line 8 `pull_request:`; same job runs the canonical command | MANUAL (static) — same caveat |
| AC6 readiness agreement | `tests/checks/10-readiness.sh` (8 assertions); `mutation.sh` "AC6 readiness" | PASS |
| AC7 lifecycle/derived-state agreement | `tests/checks/20-lifecycle.sh` (63 assertions); `mutation.sh` "AC7 lifecycle routing" | PASS |
| AC8 permission agreement | `tests/checks/30-permissions.sh` (15 assertions for 14 agents); `mutation.sh` "AC8 permission cell" | PASS |
| AC9 inventory agreement | `tests/checks/40-inventory.sh` (3 counts + 36 membership assertions); `mutation.sh` "AC9 inventory count" | PASS |
| AC10 instruction-set agreement | `tests/checks/50-instructions.sh` (6 assertions); `mutation.sh` "AC10 instruction path" | PASS |
| AC11 default-agent agreement | `tests/checks/60-default-agent.sh` (6 assertions); `mutation.sh` "AC11 default agent"; independent out-of-band mutation | PASS |
| AC12 pin agreement | `tests/checks/70-pin.sh` (7 assertions); `mutation.sh` "AC12 external pin" | PASS |
| AC13 cycle rule + committed fixture | `tests/checks/80-cycle-fixture.sh` (15 assertions), fixture `tests/fixtures/cyclic-roadmap/roadmap.md`; `mutation.sh` "AC13 cycle fixture" | PASS |
| AC14 optional-tool skips, never failures | Forced-absent run exits `0` with `skip AC11 …` and `skip AC12 …`; `mutation.sh` `assert_clean_absent` + visible-skip probe | PASS |
| AC15 mutation sensitivity | `tests/mutation.sh` 19/19 caught and named, clean restore re-passes; independent README mutation reproduced exit `1` naming AC11 | PASS |
| AC16 maintainer-only boundary | `README.md:66-70` and `tests/README.md:5-8` state maintainer-only; README quickstart copy set (lines 43-52) still copies only `.opencode/{agent,command,skill}`, `AGENTS.md`, `opencode.json`, `.gitignore`, `docs/*.md` — not `tests/` or `.github/` | PASS |
| AC17 shipped artifacts untouched | `git diff --name-only` over `.opencode`, `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`, `opencode.json`, `work/**` is empty; `git status` shows 8 tracked `verify-tests.sh`, none modified | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| No artifact tree present | `mutation.sh` stages a copy with no `work/`; suite exits `0` | PASS |
| No optional tools installed | Forced-absent run exits `0` with 2 visible skips | PASS |
| Registry/network unreachable | AC12 published-version probe skips while the local pin-agreement assertions still run (they pass in the forced-absent log) | PASS |
| Fork PR without secrets | `ci.yml` has `permissions: contents: read` and no `secrets.` reference | PASS |
| A skip must be visible | Forced-absent run prints exactly the two skip lines; `mutation.sh` asserts a `^skip  ` line exists | PASS |
| New undocumented agent/command/skill | `40-inventory.sh` checks membership in both directions (unknown item → `FAIL`); verified by reading `check_membership` | PASS (logic) |
| One surface moves a fact | `mutation.sh` applies one mutation per AC6–AC13 and each is caught | PASS |
| Cyclic fixture isolation / idempotency | Fixture lives under `tests/`, never `work/`; two runs produce identical summaries; `mutation.sh` cleans `scratch/` on exit (dir absent afterwards) | PASS |
| Concurrent CI runs | Suite is read-only; no writes outside ignored `scratch/`; no repo mutation observed | PASS |
| CI provider replaced | `tests/run.sh` is provider-neutral; only `ci.yml` is provider-specific | PASS (inspection) |
| Historical suites drift from today's facts | All 8 `work/**/verify-tests.sh` untouched and never executed by the suite | PASS |
| Framework evolves everywhere at once | Checks assert agreement, not frozen values (pin value read from config); `mutation.sh` proves single-copy drift fails | PASS |

## Gaps and residual risk

- **AC4/AC5 are unobservable pre-ship.** The workflow is statically verified
  (triggers, job, command, no secrets, valid YAML) but no hosted GitHub Actions
  run exists until `/ship` commits and pushes. Confirm the first CI run on the
  shipped PR.
- **AC15's self-check is opt-in.** `tests/mutation.sh` is deliberately not run by
  `run.sh` or CI (per design), so mutation sensitivity is proven only when a
  maintainer runs it. The agreement checks themselves run in CI. If continuous
  mutation guarantee is wanted, that is a follow-up, not a spec requirement.
- **AC8 is a coarse class heuristic.** The edit/bash class mapping compares
  capability classes, not exact pattern lists, so a relocated pattern *within the
  same class* passes. This is the documented design trade-off; the mutation
  self-check confirms the check bites on a real disagreement.
- **LLM behavioral residual (AC13).** The committed fixture plus static rule
  assertions prove the `CYCLIC-DEP` contract is documented and the fixture is
  genuinely cyclic, but a live LLM `/status` run emitting the finding is not
  executable in CI. This residual is explicitly allowed by the spec and is
  documented in `tests/README.md`.
- **"Tracked in version control" (AC2) materializes at `/ship`.** Under this
  workflow the builder never commits, so `tests/` and `.github/` are currently
  untracked-but-not-ignored new files. `git check-ignore` confirms they are
  committable; `ship.md`'s commit will make them tracked.
- **`have_net` performs a live registry probe** (≤15 s timeout) at `lib.sh` source
  time when `npm` is present; a registry outage makes the AC12 published-version
  assertion skip, by design. No failure is possible from network absence.
- **`AGENTS.md` Project profile is still a placeholder**, so its `Test:` value
  does not name `bash tests/run.sh`. Filling it is explicitly out of scope here
  (sibling `0009-surface-consistency` owns it); the canonical command is
  documented in `tests/README.md`.

No defects found. No test was weakened, skipped, or deleted.
