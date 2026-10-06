---
feature: 0003-framework-quality-hardening/0006-committed-tests-ci
phase: tasks
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "T1 is the shared harness; T2–T9 are independent agreement checks that each add one file under tests/checks/. T6 and T7 each include a one-sentence documentation addition required to satisfy AC10/AC11 as written. Do not touch any existing work/** artifact or suite (AC17)."
---

# Tasks — Committed test harness and CI

Ordered, dependency-aware. One task ≈ one focused commit. Every task writes only
under `tests/`, `.github/`, `README.md`, or `docs/customization.md`; no task
modifies `.opencode/**`, `docs/workflow.md`, `docs/artifact-conventions.md`,
`AGENTS.md`, `opencode.json`, or any existing `work/**` file.

- [x] **T1** — Create the shared harness and canonical entry point:
      `tests/lib.sh` (counters `pass`/`fail`/`skip`; `ok`/`bad`/`skip`/`need`/
      `needE`/`fm`/`flat`; agent/command/skill name extractors; optional-tool
      probes `have_py`/`have_opencode`/`have_npm`/`have_net` with
      `FRAMEWORK_TEST_NO_PY`/`_OPENCODE`/`_NPM` overrides), `tests/run.sh`
      (resolve repo root from an optional first argument else git top level;
      source `lib.sh` then every `tests/checks/*.sh` in order in one process;
      print `TOTAL: <p> passed, <f> failed, <s> skipped`; exit `0`/`1`/`2`), and
      an initial `tests/README.md` documenting the canonical command, the exit
      contract, and the skip policy. Do not read `work/**`. [AC1, AC3]
      [depends: none]
      Verify: `bash tests/run.sh; echo "exit=$?"` prints a `TOTAL:` summary and
      `exit=0`; `bash tests/run.sh /nonexistent; echo "exit=$?"` prints a setup
      error and `exit=2`.

- [x] **T2** — Add `tests/checks/10-readiness.sh` asserting that the readiness
      algorithm (`satisfied(dep_local_id):`) is stated exactly once and only in
      `docs/workflow.md`; that `.opencode/agent/status.md`,
      `.opencode/command/status.md`, and `.opencode/agent/product.md` defer by
      naming `Dependencies and readiness`; that approved-but-unshipped
      satisfaction and `ship.md` precedence are stated; and that no candidate
      surface contradicts them. [AC6] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC6 …` line reads `ok`.

- [x] **T3** — Add `tests/checks/20-lifecycle.sh` asserting the six core
      commands appear in `AGENTS.md`, `docs/workflow.md`, `README.md`, and the
      `workflow-lifecycle` skill; that command→agent pairs agree between the
      `AGENTS.md` lifecycle table and the `README.md` commands table; that the
      seven core derived-state routing conditions agree between
      `docs/workflow.md` and the skill; and that the core derived-state artifact
      names appear in all three of workflow, README's state diagram, and the
      skill. Do not compare command argument signatures. [AC7] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC7 …` line reads `ok`.

- [x] **T4** — Add `tests/checks/30-permissions.sh` deriving each agent's edit
      class and bash class from its frontmatter and comparing them (plus `mode`)
      to its row in `README.md`'s Agents table, using the fixed class mapping in
      the design; fail naming the agent and both classes on any mismatch.
      [AC8] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC8 …` line reads `ok`.

- [x] **T5** — Add `tests/checks/40-inventory.sh` asserting the `README.md`
      Layout counts equal the on-disk `.opencode/agent/*.md`,
      `.opencode/command/*.md`, and `.opencode/skill/*/` counts, and that
      membership agrees in both directions (every on-disk item appears in its
      README table; every README table row resolves to an on-disk item).
      [AC9] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC9 …` line reads `ok`.

- [x] **T6** — Add `tests/checks/50-instructions.sh` comparing the
      `opencode.json` `instructions` set to the set named in
      `docs/customization.md`'s "Always-loaded instructions" table and in the
      `README.md` Configuration section, asserting every named path exists and
      no divergent always-loaded path is claimed; then add the missing explicit
      instruction-file list to `README.md`'s Configuration section (the only
      documentation change needed for AC10). [AC10] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC10 …` line reads `ok`;
      `grep -n 'docs/artifact-conventions.md' README.md` finds it in the
      Configuration section.

- [x] **T7** — Add `tests/checks/60-default-agent.sh` extracting `default_agent`
      from `opencode.json` and asserting `README.md` and `docs/customization.md`
      each name the same value as the default agent, that the agent file exists
      and is not disabled, and (when `opencode` is present) that
      `opencode debug agent <name>` resolves; then add the one-sentence
      default-agent mention to `docs/customization.md` (the only documentation
      change needed for AC11). [AC11] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC11 …` line reads `ok`.

- [x] **T8** — Add `tests/checks/70-pin.sh` extracting every
      `@playwright/mcp@<spec>` from `opencode.json`, `docs/customization.md`,
      and the `browser-verification` skill; asserting one distinct exact
      `x.y.z` semver pin, no floating tag, and agreement across all three; and
      probing the registry only when `npm`/network are available (skip
      otherwise). Never hardcode the version. [AC12] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC12 …` line reads `ok`.

- [x] **T9** — Commit `tests/fixtures/cyclic-roadmap/roadmap.md` (a roadmap
      artifact whose `Children` `Depends on` graph is genuinely cyclic) and add
      `tests/checks/80-cycle-fixture.sh` that parses the fixture with pure
      `awk`/bash, proves the cycle via DFS, and asserts the documented
      "cycle members are never ready" / non-fatal `CYCLIC-DEP` rule text in
      `docs/workflow.md` and `.opencode/agent/status.md` +
      `.opencode/command/status.md`. [AC13] [depends: T1]
      Verify: `bash tests/run.sh` exits `0` and every `AC13 …` line reads `ok`;
      re-running `bash tests/run.sh` twice produces identical summaries
      (idempotent, no writes to `work/` or the fixture).

- [x] **T10** — Add `.github/workflows/ci.yml` triggered on `push` (all
      branches) and `pull_request`, with one `ubuntu-latest` job that checks out
      the repo and runs `bash tests/run.sh` with no secrets. [AC4, AC5]
      [depends: T1]
      Verify: `grep -nE 'on:|push:|pull_request:|runs-on: ubuntu-latest|bash tests/run.sh' .github/workflows/ci.yml`
      shows all five; the workflow file parses as YAML (e.g. `python3 -c "import yaml,sys;yaml.safe_load(open('.github/workflows/ci.yml'))"`,
      or skip if PyYAML is absent).

- [x] **T11** — Document the maintainer-only boundary: add a short note to
      `README.md` (Quickstart/Commands area) that the quickstart copy set
      intentionally excludes `tests/` and `.github/` and that the test suite and
      CI are framework-maintainer-only, and state the same in `tests/README.md`.
      [AC16] [depends: T1, T6]
      Verify: `grep -niE 'maintainer-only' README.md tests/README.md` finds both;
      the quickstart copy list in `README.md` still names only
      `.opencode/{agent,command,skill}`, `AGENTS.md`, `opencode.json`,
      `.gitignore`, and `docs/*.md`.

- [x] **T12** — Add `tests/mutation.sh` (opt-in maintainer tooling, not part of
      `run.sh` or CI) that copies the live surfaces without `work/` under the
      ignored `scratch/`, asserts the clean copy passes (AC2), asserts a run
      with `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1`
      passes with visible skips (AC14), then applies exactly one mutation per
      area AC6–AC13, asserting each makes the suite exit non-zero and names the
      expected `ACn` check, restoring the file and re-passing between
      mutations; cleans up `scratch/` on exit. [AC2, AC14, AC15] [depends: T2, T3, T4, T5, T6, T7, T8, T9]
      Verify: `bash tests/mutation.sh; echo "exit=$?"` reports every mutation
      caught and `exit=0`; `git status --short work/` shows no mutation residue.

- [x] **T13** — End-to-end validation and scope guard: run the canonical command
      on a clean tree and confirm exit `0`; confirm `work/**` is not required by
      running the suite against a copy with no `work/`; run the forced-absent
      tools command and confirm exit `0` with skips; confirm `git diff --stat`
      shows no change under `.opencode/**`, `docs/workflow.md`,
      `docs/artifact-conventions.md`, `AGENTS.md`, `opencode.json`, or any
      existing `work/**` file (only `tests/**`, `.github/**`, `README.md`, and
      `docs/customization.md` are added/changed). [AC1, AC2, AC14, AC17]
      [depends: T10, T12]
      Verify: `bash tests/run.sh; echo "exit=$?"` → `exit=0`;
      `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh; echo "exit=$?"` → `exit=0`;
      `git diff --stat -- .opencode docs/workflow.md docs/artifact-conventions.md AGENTS.md opencode.json 'work/**'` is empty.
