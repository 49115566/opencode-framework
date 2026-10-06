---
feature: 0003-framework-quality-hardening/0006-committed-tests-ci
phase: design
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "Resolves the spec's deferred open question: canonical command is the shell command `bash tests/run.sh` (not a slash command); CI is push + pull_request only; the suite is a modular bash harness under `tests/`, one check file per agreement area. Two minimal documentation additions are required to satisfy AC10/AC11 as written and are called out in the tasks (README Configuration names the instruction set; customization.md names the default agent)."
---

# Design — Committed test harness and CI

## Summary

Commit a read-only, provider-neutral bash harness under `tests/` whose canonical
entry point is `bash tests/run.sh`. It runs eight agreement checks in one process
plus a committed cycle fixture, prints `ok`/`FAIL`/`skip` per assertion and a
passed/failed/skipped summary, and exits non-zero iff at least one assertion
failed. A GitHub Actions workflow at `.github/workflows/ci.yml` runs that exact
command on every push and pull request. The harness asserts cross-surface
agreement of duplicated framework facts rather than frozen values, so a genuine
fact change made everywhere at once still passes while a single stale copy fails
(AC6–AC15). Historical `work/**/verify-tests.sh` suites are neither moved,
executed, nor edited.

## Approach

### Canonical command and layout

```
tests/
  run.sh                       # canonical entry point: resolves repo root, sources lib + checks, exits on failure count
  lib.sh                       # counters, ok/bad/skip, optional-tool probes, text extractors
  README.md                    # maintainer-only: command, check inventory, skip policy, mutation procedure
  mutation.sh                  # opt-in self-check: no-work/ run, forced-absent-tools run, one mutation per agreement area
  fixtures/
    cyclic-roadmap/
      roadmap.md               # committed fixture whose Children graph actually contains a cycle
  checks/
    10-readiness.sh            # AC6
    20-lifecycle.sh            # AC7
    30-permissions.sh          # AC8
    40-inventory.sh            # AC9
    50-instructions.sh         # AC10
    60-default-agent.sh        # AC11
    70-pin.sh                  # AC12
    80-cycle-fixture.sh        # AC13
.github/workflows/ci.yml       # AC4, AC5
```

- `tests/run.sh [repo-root]` defaults to the git top level (same argument
  convention as existing suites, e.g. `work/0002-agentic-roadmaps/verify-tests.sh:13-25`),
  so the mutation self-check can point it at a copy.
- `run.sh` sources `lib.sh`, then sources every `tests/checks/*.sh` in filename
  order **in one bash process** (AC1). Adding a check is adding a file; no edit
  to `run.sh` is needed, which keeps each agreement area in one focused commit.
- `tests/` (not `scripts/`) is chosen because the `tester` agent's edit allowlist
  already covers `tests/**` and `**/tests/**`
  (`.opencode/agent/tester.md:9-10`), so the framework's own `/test` phase can
  author and run the suite with no permission change (spec, Dependencies).
- The suite never reads `work/**`: it reads only `opencode.json`, `README.md`,
  `.opencode/{agent,command,skill}`, `docs/*.md`, and its own fixture. This is
  what makes it fresh-clone runnable (AC2) and keeps it independent of the
  immutable historical suites.

### Harness contract (`tests/lib.sh`)

- Counters `pass`, `fail`, `skip`; helpers `ok`, `bad`, `skip`, `need`
  (literal), `needE` (regex), `flat` (one-line a file), `fm` (extract
  frontmatter), and name extractors for agents/commands/skills — the same
  vocabulary as the existing suites, so the conventions carry over.
- Optional-tool probes are overridable so skips are deterministic:
  `have_py`, `have_opencode`, `have_npm`, `have_net`. Each is forced to `0` when
  `FRAMEWORK_TEST_NO_PY`, `FRAMEWORK_TEST_NO_OPENCODE`, `FRAMEWORK_TEST_NO_NPM`
  is `1`, otherwise detected via `command -v`. `have_net` is only probed when
  `npm` is present and is a best-effort registry reachability check.
- A check that depends on an absent optional tool **must** call `skip` and must
  not increment `fail` (AC14). Skips are always printed.
- `run.sh` prints `TOTAL: <p> passed, <f> failed, <s> skipped` and executes
  `[ "$fail" -eq 0 ]`. Exit `0` = pass, `1` = assertion failure, `2` = setup
  error (not a git repo / cannot cd). The summary is therefore a function of the
  machine-readable exit status (AC3).
- Avoid bash 4-only features (no associative arrays, no `mapfile`) so the suite
  runs on macOS bash 3.2 as well as CI's bash 5.

### Agreement checks (AC6–AC12)

Every check asserts agreement among **live** surfaces (explicitly enumerated
candidate lists, never `work/**`), so a real change applied everywhere passes
and a lone stale copy fails. Each check prefixes its assertion labels with a
stable `ACn` token that `tests/mutation.sh` matches.

- **AC6 readiness** (`10-readiness.sh`). The authority marker
  `satisfied(dep_local_id):` occurs exactly once across `docs/workflow.md`,
  `.opencode/agent/status.md`, `.opencode/command/status.md`,
  `.opencode/agent/product.md`, `docs/artifact-conventions.md`, and the
  `workflow-lifecycle` skill, and it is in `docs/workflow.md`. The other
  readiness surfaces defer by naming `Dependencies and readiness`; the authority
  states approved-but-unshipped satisfaction (`even if unshipped`) and shipped
  signal precedence (`presence is the sole shipped signal`,
  `ship.md presence takes precedence`). No candidate contains a contradicting
  `approved-but-unshipped … not satisfied` claim. Mirrors the already-proven
  pattern at `work/0002-agentic-roadmaps/verify-tests.sh:240-274`.
- **AC7 lifecycle/derived state** (`20-lifecycle.sh`). (a) The six core commands
  `/spec /plan /build /test /review /ship` each appear in `AGENTS.md`,
  `docs/workflow.md`, `README.md`, and the lifecycle skill. (b) Command→agent
  pairs agree between the `AGENTS.md` lifecycle table and the `README.md`
  commands table for every command both tables name. (c) The seven core routing
  conditions exist in both `docs/workflow.md`'s derived-state table and the
  skill's "Which command now?" block (e.g. "`spec.md` present, `design.md`
  missing" ↔ "spec.md, no design.md? → /plan"; "all boxes checked, `verify.md`
  missing" ↔ "all tasks checked, no verify.md? → /test"; "`review.md` verdict
  `request-changes`" ↔ "→ /build (rework)"). (d) The core derived-state artifact
  names `spec.md design.md tasks.md verify.md review.md ship.md` appear in all
  three of workflow, README's state diagram, and the skill; `visual.md` is
  checked only where the optional phase is described. The check intentionally
  compares the phase **set and routing**, not argument signatures, because the
  `item-ref` usage strings are owned by `0009-surface-consistency`.
- **AC8 permissions** (`30-permissions.sh`). For every `.opencode/agent/*.md`,
  derive an edit class and a bash class from the effective frontmatter and
  compare them to the agent's row in `README.md`'s Agents table. Classes are
  fixed and documented in `tests/README.md`:
  - edit: `none` (`edit: deny` or a `"*": deny` map with no allow), `work`
    (work patterns only), `tests+work` (work + at least one test-layout pattern),
    `config+work` (work + at least one of `AGENTS.md`/`opencode.json`/`.gitignore`),
    `any` (`edit: allow`).
  - bash: `none`, `read-only` (`"*": deny` + only read patterns), `git-gh`
    (`"*": deny` + a git-write or `gh ` allow), `allow` (`"*": allow`).
  - README cells map deterministically: `none`; `any source`; a cell containing
    `test` and `work/**`; a cell containing `config` and `work/**`; a cell
    containing `work/**`; and for bash `none`, `git/gh allowlist`, `allow`, or
    prefix `read-only`. The frontmatter `mode` is compared to the README Mode
    cell as well. A mismatch fails with the agent name and both class names.
- **AC9 inventory** (`40-inventory.sh`). Counts from `README.md`'s Layout block
  (`# N role prompts`, `# N slash commands`, `# N knowledge skills`) must equal
  the on-disk counts of `.opencode/agent/*.md`, `.opencode/command/*.md`, and
  `.opencode/skill/*/`. Both directions of membership are checked: every on-disk
  item appears in the matching README table, and every README table row resolves
  to an on-disk file/directory. Fails on a stale count or an undocumented item.
- **AC10 instruction set** (`50-instructions.sh`). Extract the `instructions`
  array from `opencode.json`; assert every path exists; assert
  `docs/customization.md`'s "Always-loaded instructions" table names exactly that
  set; assert the `README.md` Configuration section names the same set; assert no
  third always-loaded path is claimed anywhere in those surfaces. (The current
  README names the section but not the files, so the task adds one explicit
  sentence here — a documentation-only change.)
- **AC11 default agent** (`60-default-agent.sh`). Extract `default_agent` from
  `opencode.json`; assert `README.md` and `docs/customization.md` each name that
  same value as the default agent; assert the named agent's file exists and is
  not disabled in `opencode.json`'s `agent` map; when `opencode` is present,
  `opencode debug agent <name>` resolves (otherwise skip). (`docs/customization.md`
  currently documents the default *model* but never names the default *agent*, so
  the task adds one factual sentence — a documentation-only change.)
- **AC12 pin** (`70-pin.sh`). Extract every `@playwright/mcp@<spec>` occurrence
  from `opencode.json`, `docs/customization.md`, and the `browser-verification`
  skill; assert exactly one distinct spec, that it matches
  `^@playwright/mcp@[0-9]+\.[0-9]+\.[0-9]+$`, and that no `latest`/`*`/`^`/`~`
  floating token appears on any of the three. When `npm` and the registry are
  reachable, confirm the exact version is published; otherwise skip. The check
  is value-agnostic: it never hardcodes `0.0.83`, so bumping the pin in all three
  surfaces together passes.

### Cycle rule and fixture (AC13)

Commit `tests/fixtures/cyclic-roadmap/roadmap.md`: a roadmap artifact whose
`Children` table encodes a real cycle (e.g. `0001-a` depends on `0002-b` and
`0002-b` depends on `0001-a`). `80-cycle-fixture.sh` parses the fixture's
`Depends on` column with pure `awk`/bash (no optional runtime) and runs a small
DFS that asserts the graph is genuinely cyclic; it then asserts the documented
rule text in `docs/workflow.md` (cycle members are never `ready`; a cycle is a
non-fatal integrity finding) and the `CYCLIC-DEP` finding in
`.opencode/agent/status.md` and `.opencode/command/status.md`. The fixture lives
under `tests/`, not `work/`, so it never pollutes the artifact tree; the suite
is read-only, so repeated runs are idempotent. The residual — that the actual
LLM `/status` run reports the cycle — is documented in `tests/README.md` and
`verify.md`, per the spec's explicit LLM residual allowance.

### CI (AC4, AC5)

`.github/workflows/ci.yml` observes `push` (all branches) and `pull_request`, has
one job on `ubuntu-latest` that checks out the repo and runs `bash tests/run.sh`.
No secrets, no matrix, no cached state. The provider-specific part is the
workflow file only; `tests/run.sh` stays provider-neutral (edge case: CI provider
replaced). Job status is the commit/PR status GitHub reports.

### Documentation boundary (AC10, AC11, AC16)

`tests/README.md` is the maintainer-facing reference: canonical command, the
check inventory and what each asserts, the optional-tool skip policy, the
mutation procedure, and a statement that `tests/` and `.github/` are
framework-maintainer-only. `README.md`'s Quickstart/Commands area gains a short
maintainer-only note that the copy set intentionally excludes `tests/` and
`.github/`, and the Configuration section names the three instruction files
(AC10). `docs/customization.md` gains the one-sentence default-agent mention
(AC11). No agent, command, skill, lifecycle rule, permission, or artifact format
changes.

### Mutation and environment self-check (AC2, AC14, AC15)

`tests/mutation.sh` is opt-in maintainer tooling (not part of `run.sh`, not run
by CI) that builds a pristine copy of the live surfaces **without** `work/` under
the ignored `scratch/`, then:

1. runs `bash tests/run.sh <copy>` and asserts exit `0` — evidences AC2;
2. runs it with `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1`
   and asserts exit `0` with visible skips — evidences AC14;
3. for each agreement area (AC6–AC12) plus AC13, applies exactly one mutation
   (append a contradicting readiness sentence; delete a routing condition; flip a
   README permission cell; change an inventory count; drop an instruction path;
   change the README default-agent value; change the customization pin; rename
   the fixture/remove the cycle rule), asserts the suite exits non-zero **and**
   the output names the expected `ACn` check, restores the file, and asserts the
   clean copy passes again — evidences AC15;
4. exits non-zero if any mutation is not caught or any clean run fails, and
   cleans up its `scratch/` subtree.

## Alternatives considered

- **Single monolithic `tests/run.sh`.** Pros: one file, minimal new surface.
  Cons: ~600 lines across nine concerns, unreadable, every change conflicts in
  one file, and an acceptance criterion cannot map cleanly to one commit.
  Rejected: the modular harness costs one `lib.sh` and buys per-area isolation,
  stable `ACn` labels, and independently verifiable tasks.
- **Reuse or extend `work/0002-agentic-roadmaps/verify-tests.sh` in place and
  point CI at it.** Pros: no new test code. Cons: it lives in a per-item artifact
  directory (violates AC2), reads historical assumptions, and editing or
  executing it would modify shipped evidence (violates AC17 and the spec's
  non-goals). Rejected.
- **Adopt a real test runner (`bats`, `shunit2`, `node --test`).** Pros: nicer
  reporting and assertions. Cons: adds a runtime/toolchain dependency and a
  package manifest the framework does not have, violating the non-goal of "no
  general-purpose test runner, package manager, or runtime dependency", and
  reduces fresh-clone portability. Rejected.
- **Chosen:** a modular bash harness under `tests/` with a shared `lib.sh`, one
  check file per agreement area, a committed fixture, a provider-specific CI
  wrapper, and an opt-in mutation self-check.

## Interfaces and data model

- **CLI:** `bash tests/run.sh [repo-root]`. Exit `0` pass, `1` assertion
  failure, `2` setup error. Env overrides `FRAMEWORK_TEST_NO_PY`,
  `FRAMEWORK_TEST_NO_OPENCODE`, `FRAMEWORK_TEST_NO_NPM` force optional-tool
  skips for deterministic testing.
- **Harness functions (from `lib.sh`):** `ok <msg>`, `bad <msg>`, `skip <msg>`,
  `need <file> <literal> <msg>`, `needE <file> <regex> <msg>`, `fm <file>`,
  `flat <file>`, `agent_names`, `cmd_names`, `skill_names`, `have_py`,
  `have_opencode`, `have_npm`, `have_net`. Counters `pass`, `fail`, `skip` are
  global; check files are sourced and must not call `exit`.
- **Check contract:** sourced in filename order; each emits `ok`/`FAIL`/`skip`
  lines labelled with its `ACn`; each is self-contained (no shared mutable state
  beyond the counters).
- **Fixture shape:** `tests/fixtures/cyclic-roadmap/roadmap.md` follows the
  `roadmap.md` template (`docs/artifact-conventions.md`) with a `Children` table
  whose `Depends on` cells form a 2-cycle, and a `feature:` value that is
  explicitly a fixture id (never a real item-ref if placed under `work/`; it is
  not, so no allocation applies).
- **No persisted data model, no migration, no schema change.** Backward
  compatibility: historical `work/**` suites and their artifacts are untouched
  and never executed by the new suite; `.opencode/agent/tester.md`'s existing
  `tests/**` grant is reused, so no permission change is required; the adopter
  quickstart copy set is unchanged (`tests/` and `.github/` were never copied)
  and the boundary is merely documented.

## Affected areas

New files: `tests/run.sh`, `tests/lib.sh`, `tests/README.md`, `tests/mutation.sh`,
`tests/checks/{10-readiness,20-lifecycle,30-permissions,40-inventory,50-instructions,60-default-agent,70-pin,80-cycle-fixture}.sh`,
`tests/fixtures/cyclic-roadmap/roadmap.md`, `.github/workflows/ci.yml`.

Modified files (documentation only): `README.md` (name the instruction set in
Configuration; add the maintainer-only boundary note), `docs/customization.md`
(one factual sentence naming the default agent).

Deliberately untouched: `.opencode/agent/**`, `.opencode/command/**`,
`.opencode/skill/**`, `docs/workflow.md`, `docs/artifact-conventions.md`,
`AGENTS.md`, `opencode.json`, and every existing `work/**` artifact and
`work/**/verify-tests.sh`.

## Risks and mitigations

- **The AC8 permission-class mapping is a heuristic and drifts from README
  prose** — likelihood medium / impact medium. Mitigation: classes and the
  README-cell mapping are fixed and documented in `tests/README.md`; a mismatch
  names the agent and both classes, so the fix is to update the declaration and
  its row together; the mutation self-check flips a README cell to prove the
  check bites.
- **The two required documentation additions overlap sibling
  `0009-surface-consistency`** — likelihood low / impact low. Mitigation: keep
  them to one sentence each, add nothing about `item-ref` usage or the Project
  profile (0009's scope), and note the overlap in the handoff.
- **`opencode`/`npm`/registry absent makes some assertions skip, weakening a
  local run** — likelihood medium / impact low. Mitigation: every JSON-literal
  agreement (AC10–AC12) is grep-based and always runs; only live resolution and
  the published-version probe skip; CI's `ubuntu-latest` has `python3`, so the
  full suite runs there; skips are always printed.
- **A future check silently re-introduces a `work/**` dependency, breaking
  fresh-clone runnability** — likelihood low / impact high. Mitigation:
  `tests/mutation.sh` runs the whole suite against a copy with no `work/`; the
  boundary is stated in `tests/README.md`; `run.sh` resolves only live paths.
- **CI red on a fact that is genuinely mid-change in another branch** —
  likelihood low / impact medium. Mitigation: checks assert agreement, not frozen
  values; the only intentionally fixed literal is "exact semver" (the version
  itself is read from config), and a documented refactor updates all surfaces in
  one commit.
- **Bash portability (macOS 3.2) or missing `timeout`** — likelihood low /
  impact low. Mitigation: no bash 4 features; `timeout` is used only when
  present; the network probe is best-effort and skips.
- **The cycle fixture parser may be brittle to template formatting** —
  likelihood low / impact low. Mitigation: the fixture and parser land together,
  the parser tolerates the documented `| a | b | … |` row shape, and a missing
  fixture data row fails loudly rather than passing vacuously.

## Test strategy

| AC | Verification level | How |
| -- | ------------------ | --- |
| AC1 | integration | `bash tests/run.sh` exits `0` on a clean tree; a forced failing check (via mutation) exits `1`. |
| AC2 | integration + review | `tests/mutation.sh` runs the suite against a copy with no `work/`; review confirms no `work/**` reads. |
| AC3 | integration | Inspect `ok`/`FAIL`/`skip` lines and `TOTAL: p passed, f failed, s skipped`; exit derived from failure count. |
| AC4 | manual/CI | `.github/workflows/ci.yml` has a `push` trigger and runs `bash tests/run.sh`; the Actions run reports the job status. |
| AC5 | manual/CI | Same workflow has a `pull_request` trigger and reports status on the PR. |
| AC6 | unit (suite) + mutation | `10-readiness.sh` assertions; mutation appends a contradicting readiness line and expects an AC6 failure. |
| AC7 | unit (suite) + mutation | `20-lifecycle.sh` assertions; mutation deletes a routing condition and expects an AC7 failure. |
| AC8 | unit (suite) + mutation | `30-permissions.sh` class comparison; mutation flips a README cell and expects an AC8 failure. |
| AC9 | unit (suite) + mutation | `40-inventory.sh` count + membership both directions; mutation changes a count and expects an AC9 failure. |
| AC10 | unit (suite) + mutation | `50-instructions.sh` set comparison; mutation drops an instruction path and expects an AC10 failure. |
| AC11 | unit (suite) + mutation | `60-default-agent.sh` value agreement + resolution; mutation changes the README value and expects an AC11 failure. |
| AC12 | unit (suite) + mutation | `70-pin.sh` one-exact-semver agreement; mutation changes a pin and expects an AC12 failure. |
| AC13 | unit (suite) | `80-cycle-fixture.sh` DFS proves the fixture is cyclic and the rule/finding text is present. |
| AC14 | integration | `FRAMEWORK_TEST_NO_PY/NO_OPENCODE/NO_NPM=1 bash tests/run.sh` exits `0` with visible skips. |
| AC15 | integration | `tests/mutation.sh` applies one mutation per agreement area and asserts each is caught and named. |
| AC16 | review | Inspect `README.md`'s maintainer-only note, `tests/README.md`, and the quickstart copy set. |
| AC17 | review + command | `git diff --stat` shows no change under `.opencode/**`, `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`, `opencode.json`, or existing `work/**`. |
