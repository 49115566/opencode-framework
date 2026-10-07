---
feature: 0004-adoption-template-split/0003-split-guard-tests
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Ordered by dependency. T1 creates the new check file and its shared parsers; T2-T4 add the remaining guards to that same file; T5 documents the area; T6 adds the mutation; T7 is the AC1 gate. Every task keeps bash tests/run.sh green. Scope is tests/** only; no other check, run.sh, lib.sh, or non-tests surface changes."
---

# Tasks — Committed split guards

Ordered, dependency-aware. One task ≈ one focused commit. A task is complete only
when its `Verify:` step passes. `AC1` is the final gate; `AC2`–`AC6` are the
guards themselves; `AC7` and `AC8` are the documentation and mutation
requirements.

- [x] **T1** — Create `tests/checks/95-split-guard.sh` with the area header
      (`echo "== AC21 adoption split guard =="`), the shared helpers
      (`quickstart_pairs`, `contract_sources`), and the AC2 + AC5 guards: for each
      of `AGENTS.md`, `opencode.json`, `.gitignore`, assert the first ```` ```bash ````
      block in `README.md` has a copy pair `template/<file>` → `./<file>` (or
      `<file>`), reject any root-source copy and any whole-`template/` directory
      copy, fail naming `README.md` when the block or a required `template/<file>`
      is missing, and assert `docs/customization.md`'s split-contract table names
      the same `template/<file>` source. Implement the loop expansion and
      normalization exactly as designed. [AC2] [AC5]
      Verify: `bash tests/run.sh` → exit 0, and its output contains `ok` lines
      beginning `AC21` for the quickstart source and contract-agreement
      assertions.

- [x] **T2** — Extend `tests/checks/95-split-guard.sh` with the AC3 pristine
      placeholder guard: require `template/AGENTS.md`'s `## Project profile`
      section and, for each of the ten field labels (`Purpose`,
      `Primary language(s)`, `Package manager`, `Install`, `Test`, `Lint`,
      `Typecheck`, `Format`, `Build`, `Key directories`), a value matching
      `^_.*_$`; fail naming `template/AGENTS.md` and the offending field
      otherwise. Inspect only `template/AGENTS.md`, never root `AGENTS.md`.
      [AC3] [depends: T1]
      Verify: `bash tests/run.sh` → exit 0 with an `AC21` `ok` line for the
      placeholder profile; temporarily replacing one `template/AGENTS.md`
      placeholder value (e.g. `_e.g. \`pnpm install\`_`) with a concrete value
      like `pnpm install` makes the suite exit non-zero and print
      `AC21 template/AGENTS.md` (restore the file afterwards).

- [x] **T3** — Extend `tests/checks/95-split-guard.sh` with the AC4 copy-set
      guard over `README.md`, `docs/customization.md`, `tests/README.md`, and
      `CONTRIBUTING.md`: each surface must name `template/AGENTS.md`,
      `template/opencode.json`, and `template/.gitignore`, and must have no line
      matching the wrong-claim scan (one of the three filenames + a copy verb +
      a root marker + no negation); fail naming the surface and the offending
      line. Tune only if the clean tree does not exit 0. [AC4] [depends: T1]
      Verify: `bash tests/run.sh` → exit 0 with `AC21` `ok` lines for each of the
      four surfaces; appending `The framework's root AGENTS.md is copied to
      adopters.` to `README.md` makes the suite exit non-zero and name
      `README.md`.

- [x] **T4** — Extend `tests/checks/95-split-guard.sh` with the AC6 bootstrap
      deny guard: parse `.opencode/agent/bootstrap.md`'s `permission.edit` map
      into an ordered rule list and implement last-match `resolve_edit`. Assert
      `template/AGENTS.md`, `template/opencode.json`, `template/.gitignore`,
      `template/sub/AGENTS.md`, and `/repo/template/AGENTS.md` resolve deny, while
      `AGENTS.md`, `opencode.json`, `.gitignore`, and `/repo/AGENTS.md` resolve
      allow; fail naming `bootstrap` otherwise. [AC6] [depends: T1]
      Verify: `bash tests/run.sh` → exit 0 with `AC21 bootstrap` `ok` lines;
      moving the `"**/AGENTS.md": allow` rule after the `template/**` deny in
      `.opencode/agent/bootstrap.md` makes the suite exit non-zero and name
      `bootstrap` (restore the file afterwards).

- [x] **T5** — Add the area to `tests/README.md`: a Checks-table row for
      `95-split-guard.sh` and, after the existing `AC18`–`AC20` mapping
      paragraph, an `AC21` mapping paragraph (spec AC2 quickstart source,
      AC3 `template/AGENTS.md` placeholder, AC4 copy-set surfaces, AC5
      quickstart↔contract, AC6 bootstrap deny). Do not remove or reword the
      packaging descriptions. [AC7] [depends: T1, T2, T3, T4]
      Verify: `grep -q '95-split-guard.sh' tests/README.md && grep -q 'AC21' tests/README.md && grep -q 'AC18' tests/README.md && grep -q 'AC20' tests/README.md && bash tests/run.sh` → exit 0.

- [x] **T6** — Add one mutation for the new area to `tests/mutation.sh`: a
      section after the `AC20` block that runs
      `replace_first "$COPY/README.md" 'template/AGENTS.md' 'AGENTS.md'`, then
      `check_mutation AC21` with the single-line expected substring
      ``AC21 README.md quickstart does not source AGENTS.md from template/AGENTS.md``
      and the description `repointed the quickstart at the root copy`, then
      `restore_file README.md` and `assert_clean_absent`. Extend the header
      comment's area list to include `AC21`. [AC8] [depends: T1]
      Verify: `bash tests/mutation.sh` → exit 0 with `MUTATION TOTAL: … 0 failed`
      and a line matching `mutation AC21 caught and named`.

- [x] **T7** — Final gate on the completed change: run the full committed suite
      and the opt-in mutation self-check, including the forced-absent-tools run,
      and confirm no existing agreement regressed. [AC1] [depends: T1, T2, T3, T4, T5, T6]
      Verify: `bash tests/run.sh` → exit 0 (`TOTAL: … 0 failed`);
      `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh` → exit 0;
      `bash tests/mutation.sh` → exit 0 (`MUTATION TOTAL: … 0 failed`).
