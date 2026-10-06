---
feature: 0003-framework-quality-hardening/0006-committed-tests-ci
phase: review
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
---

# Review — Committed test harness and CI

## Verdict

**approve** — the spec's 17 acceptance criteria are met by a read-only, fresh-clone-runnable bash suite and a push/PR workflow, and the only findings are non-blocking documentation and robustness nits.

## Diff base and commands

The item reference was empty; the only in-flight work item is this one (the other
roadmap children and the two flat items are shipped), so this review targets
`0003-framework-quality-hardening/0006-committed-tests-ci`.

Commands used:

- `git merge-base HEAD origin/main` → `18fe4b906b54fddb94029b1b566df08f0798a0e6`
- `git rev-parse --abbrev-ref HEAD` → `main`
- `git status --short`, `git diff`, `git log --oneline -10`

Base is `18fe4b9`, which **is** `HEAD`, so the change set is entirely uncommitted:
`git diff` shows `README.md` and `docs/customization.md` modified; the new
`tests/**`, `.github/workflows/ci.yml`, and the four item artifacts are untracked
but not ignored (`.gitignore` contains no rule matching either). This is expected
under the workflow — the builder never commits; trackedness materializes at
`/ship`.

I could not execute the suite myself: the Review phase's read-only bash guard
denies arbitrary `bash`, so `bash tests/run.sh` / `tests/mutation.sh` were not run
here. The findings below rest on static analysis of every new file and on the
tester's recorded evidence in `verify.md`.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 canonical command, one process, exit 0/non-zero | Met | `tests/run.sh:36-52` sources `lib.sh` then `checks/*.sh` in one process and exits on `[ "$fail" -eq 0 ]`; setup errors exit 2 at `:22,:29,:32`. |
| AC2 committed & self-contained, no `work/**` needed | Met | Suite lives at `tests/**` + `.github/**`, not a per-item dir; no check reads `work/**` (only permission-pattern string literals in `30-permissions.sh:45,144`). `tests/mutation.sh:59-68` stages a copy with no `work/` and `:156-157` asserts it passes. Trackedness lands at `/ship` (noted in `verify.md`). |
| AC3 per-assertion result + passed/failed/skipped summary | Met | `lib.sh:22-24` print `ok`/`FAIL`/`skip`; `run.sh:51` prints `TOTAL: <p> passed, <f> failed, <s> skipped`, derived from the same counters that set the exit status. |
| AC4 CI on push | Met (static) | `.github/workflows/ci.yml:7` `push:`, `:20-21` runs `bash tests/run.sh`. Live GitHub status only observable post-`/ship` (correctly flagged MANUAL in `verify.md:42`). |
| AC5 CI on pull request | Met (static) | `ci.yml:8` `pull_request:`, same job/command. Same post-ship caveat. |
| AC6 readiness agreement | Met | `10-readiness.sh:22-32` asserts `satisfied(dep_local_id):` occurs once and only in `docs/workflow.md` (confirmed: sole live occurrence is `docs/workflow.md:90`); `:35-37` asserts status/command/product defer; `:41-43` assert approved-but-unshipped + `ship.md` precedence; `:48-54` contradiction sweep. |
| AC7 lifecycle/derived-state agreement | Met | `20-lifecycle.sh:23-27` six commands in all four surfaces; `:48-56` command→agent pairs AGENTS.md↔README; `:60-78` seven routing conditions workflow↔skill; `:83-90` artifact names. All literals verified present in the live files. |
| AC8 permission agreement | Met | `30-permissions.sh:22-99` derive edit/bash classes from frontmatter, `:102-167` map README cells, `:171-213` compare both directions. Spot-checked shipper (git-gh), tester (tests+work), bootstrap (config+work), product/scribe/ask/scout (as declared). Coarseness is a documented trade-off (see M3). |
| AC9 inventory agreement | Met | `40-inventory.sh:28-42` counts README Layout (14 agents / 12 commands / 10 skills) against disk; `:81-101` membership both directions. Disk counts confirmed (14/12/10). |
| AC10 instruction-set agreement | Met | `50-instructions.sh:63-114` compares `opencode.json` (`AGENTS.md`, `docs/workflow.md`, `docs/artifact-conventions.md`), the customization table, and the new README marker line; all three sets match and the paths exist. |
| AC11 default-agent agreement | Met | `60-default-agent.sh:30-120` compares `opencode.json` `default_agent: product`, the README `(default)` marker, and customization.md naming; file exists and is not in the disabled map. Resolution probe skips when `opencode` is absent. |
| AC12 pin agreement | Met | `70-pin.sh:30-85` extracts `@playwright/mcp@0.0.83` from all three surfaces, asserts one exact `x.y.z` spec and no floating token; registry check is best-effort. (Flake risk: M2.) |
| AC13 cycle rule + fixture | Met | `70...`/`80-cycle-fixture.sh:27-98` validates the committed fixture and proves the 2-cycle with Kahn's algorithm; `:102-129` asserts the "never `ready`" and non-fatal `CYCLIC-DEP` contract across workflow/agent/command. Fixture is genuinely cyclic (`tests/fixtures/cyclic-roadmap/roadmap.md:28-29`) and lives outside `work/`. |
| AC14 optional-tool skips never fail | Met | `lib.sh:54-83` probes; `80...`/`60-default-agent.sh:129-130` and `70-pin.sh:95-96` call `skip`, not `bad`. Forced-absent run recorded `158 passed, 0 failed, 2 skipped`. (`have_py` is inert — M1.) |
| AC15 mutation sensitivity | Met | `tests/mutation.sh` applies one mutation per AC6–AC13, asserts non-zero exit and the naming substring, restores and re-passes (`:154-248`). Construction verified line-by-line. |
| AC16 maintainer-only boundary | Met | `README.md:67-71` excludes `tests/`+`.github/` from the copy set and states maintainer-only; `tests/README.md:5-8` repeats it. Quickstart copy list (`README.md:44-51`) unchanged. |
| AC17 shipped artifacts untouched | Met | `git diff --stat -- .opencode docs/workflow.md docs/artifact-conventions.md AGENTS.md opencode.json` empty; `git status --short -- 'work/**/verify-tests.sh'` empty; no existing `work/**` modified. |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] `have_py` is dead code and `FRAMEWORK_TEST_NO_PY` is inert, but both are documented as live.**
  `tests/lib.sh:54-59` defines `have_py` and honors `FRAMEWORK_TEST_NO_PY`, and
  `tests/README.md:49` advertises it as a probe that forces a skip — but no check
  in `tests/checks/` ever reads `have_py`. Consequently AC14's "a scripting
  runtime" case is never actually exercised, and a maintainer following
  `tests/README.md` will run `FRAMEWORK_TEST_NO_PY=1` expecting a visible skip
  that never appears. This is a documentation/behavior divergence, not a
  functional break. Fix: either use the probe (e.g. for JSON parsing in
  `50`/`60`/`70`) or delete `have_py`, the override, and the `tests/README.md`
  row so the documented contract matches the code. Recommended: delete — the
  checks parse JSON with `awk` on purpose, and removing the dead probe keeps the
  design's portability claim honest.

- **[M2] AC12's published-version probe can redden CI on a transient registry error.**
  `tests/checks/70-pin.sh:89-94` runs a *second*, independent `npm view` after
  `lib.sh:78-83` already probed reachability; if that second call fails for a
  transient network reason while the pin is valid, the check calls `bad` and the
  whole run exits non-zero. The spec's edge case (AC14) intends network absence
  to skip, never fail, and AC12's stated failure conditions are a floating tag or
  a divergent string — not an unreachable registry. Fix: treat any non-success
  from `npm view` as `skip` (optionally retry once), and keep `bad` only where a
  definitive "version does not exist" can be distinguished from a transport
  error.

- **[M3] AC8's class mapping is coarse enough to miss same-class relocations.**
  `tests/checks/30-permissions.sh:22-99` compares capability *classes*, not the
  exact pattern sets, so moving, e.g., a `git` write pattern between agents whose
  README cells share a class — or swapping one read-only pattern for another —
  passes. The design (`design.md:281-286`) and `verify.md:84-87` explicitly accept
  this trade-off, and the mutation self-check proves the check bites on a real
  disagreement, so this is not merge-blocking. It is worth a follow-up to compare
  allow/deny *sets* (or at least the presence of specific high-risk patterns)
  rather than the collapsed class, because "documented vs declared" is the
  criterion's whole point.

### Nits

- **[N1] `hasE` is defined and never used** — `tests/lib.sh:28`. Remove it, or use
  it in a check that currently greps twice.
- **[N2] `actions/checkout@v4` is a floating major tag** — `.github/workflows/ci.yml:19`.
  Given this item's own exact-pin ethos (AC12), pinning the action to a commit
  SHA would be consistent; out of scope here.
- **[N3] The directory extractors are brittle** — `tests/lib.sh:35-37` pipe
  `ls` into `xargs -n1 basename`; on an empty or pruned directory tree (or a
  filename containing whitespace) this emits stderr / runs `basename` with no
  argument. Harmless in this repository but easy to harden with `find`/globbing.
- **[N4] A check file that fails to `source` is not detected** — `tests/run.sh:44-49`
  has no `set -e` and does not verify the `. "$c"` result; a syntax error in a
  future check would be printed to stderr but could still leave `fail` at 0.

## Scope and conventions

- Scope is exactly as designed: only `tests/**`, `.github/workflows/ci.yml`,
  `README.md`, and `docs/customization.md` change. `git diff --stat` over
  `.opencode/**`, `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`,
  `opencode.json`, and `work/**` is empty (AC17).
- The two documentation additions are minimal and match their stated purpose:
  `README.md:264` names the instruction set for AC10, and
  `docs/customization.md:17-19` names the default agent for AC11. Neither edits
  another phase's artifact or a prohibited surface.
- The suite follows the existing suite conventions (`set -u`, optional repo-root
  argument, `ok`/`FAIL` output, non-zero exit) and reuses `tester`'s existing
  `tests/**` edit grant with no permission change, as the spec requires.
- No secrets, credentials, or `.env` content appear in the diff; CI needs none
  and sets `permissions: contents: read`.
- Historical `work/**/verify-tests.sh` suites are untouched and are never
  executed by the new harness, honoring the spec's non-goals and immutability
  rule.

## Not reviewed

- Independent execution of `tests/run.sh` and `tests/mutation.sh` (blocked by the
  read-only bash guard). The tester's recorded results are plausible and the
  suite's logic was read line-by-line, but the pass counts were not reproduced
  here.
- Live GitHub Actions behavior for AC4/AC5 — not observable until `/ship`
  commits and pushes; `verify.md` correctly carries this as a residual.
- The historical per-item suites themselves, per the item's non-goals.
