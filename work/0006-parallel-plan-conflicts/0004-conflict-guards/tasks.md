---
feature: 0006-parallel-plan-conflicts/0004-conflict-guards
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Tasks — Committed guards for the declared-conflict model and check

Ordered, dependency-aware. One task ≈ one focused commit. After every task,
`bash tests/run.sh` must stay green.

- [x] **T1** — Roll the cyclic fixture and its check onto the current `Children`
      layout: in `tests/fixtures/cyclic-roadmap/roadmap.md` change the header to
      `| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |`
      and add a `—` cell to each row; in `tests/checks/80-cycle-fixture.sh` update
      the exact-header assertion (line ~31) to the same 6-column header. Do not
      change the `dep = a[5]` parse or the Kahn cycle proof, and do not touch the
      cycle data. [AC1]
      Verify: `bash tests/run.sh` → exit 0 (`AC13` cycle assertion still passes);
      `grep -n 'Depends on | conflicts-with' tests/fixtures/cyclic-roadmap/roadmap.md tests/checks/80-cycle-fixture.sh`;
      `grep -n 'dep = a\[5\]' tests/checks/80-cycle-fixture.sh`.

- [x] **T2** — Add the `tests/fixtures/declared-conflicts/items/` fixture-local
      item tree exactly as designed: the 6-column `9001-roadmap-a/roadmap.md`
      (rows `0001-shared` cell `docs/artifact-conventions.md, 0002-sibling`;
      `0002-sibling` cell `0001-shared`; `0003-drift` cell `docs/workflow.md`
      with own `design.md` `docs/customization.md`; `0004-shipped` cell
      `docs/artifact-conventions.md` with `ship.md`; `0005-self` cell
      `0005-self`; `0006-unspecced` cell `tests/fixtures`), the `9002-roadmap-b`
      cross-roadmap control, the legacy 5-column `9003-roadmap-old/roadmap.md`,
      the top-level decoy `0001-shared/spec.md`, and the standalone items
      `9010-surface-shared` … `9020-shares-silent` with their `spec.md`/
      `design.md` frontmatter values per design §3. Child dirs carry `.gitkeep`;
      no live `work/**` path is referenced. [AC2, AC3, AC4, AC5, AC6, AC7, AC13]
      Verify: `bash tests/run.sh` → exit 0 (no new check yet);
      `test -f tests/fixtures/declared-conflicts/items/9001-roadmap-a/roadmap.md`
      and `test -f tests/fixtures/declared-conflicts/items/9001-roadmap-a/0004-shipped/ship.md`;
      `grep -rn 'work/' tests/fixtures/declared-conflicts` prints nothing.

- [x] **T3** — Add `tests/checks/85-conflict-guards.sh` (stable token `AC23`,
      pure bash/awk, Bash 3.2 compatible, sourced by `run.sh`, never `exit`):
      implement the four analyzers (`fixture_resolution`, `fixture_conflicts`,
      `fixture_unresolved`, `fixture_drift`) over
      `tests/fixtures/declared-conflicts/items/`, resolving item refs against the
      fixture `items/` root and surface paths against the repository copy root;
      compare each to its expected block (design §3); assert the fixture 6-column
      header (`AC23 column-layout`) and `Depends on` at pipe-field 5
      (`AC23 positional-parse`); assert the reporting vocabulary and negative
      controls on `docs/workflow.md` → `## Declared-conflict check`,
      `.opencode/skill/merge-conflict/SKILL.md`, and the `status`/`conflicts`/
      `build` prompts (`AC23 reporting-vocabulary`); assert the check reads no
      live `work/**` and adds no executable production checker. [AC2, AC3, AC4,
      AC5, AC6, AC7, AC8, AC9, AC13]
      Verify: `bash tests/run.sh` → exit 0 with `85-conflict-guards.sh`'s `AC23`
      lines present; each analyzer's output block matches the expected block; the
      `AC23 negative-control` assertions pass.

- [x] **T4** — Extend `tests/mutation.sh`: in `stage()` add
      `cp -R "$REPO_ROOT/tests/fixtures/declared-conflicts" "$COPY/tests/fixtures/declared-conflicts"`;
      add the five mutation blocks from design §5, each followed by
      `restore_file` and an `assert_clean_absent`, using the expected sub-area
      substrings (`AC23 column-layout`, `AC23 positional-parse`,
      `AC23 cell-resolution`, `AC23 pair-predicate`, `AC23 reporting-vocabulary`);
      update the header comment's covered-area list to include `AC23`. [AC11]
      [depends: T3]
      Verify: `bash tests/mutation.sh` → exit 0, with five `AC23` mutation lines
      reported "caught and named"; every clean run passes.

- [x] **T5** — Document the new area in `tests/README.md`: add the Checks-table
      row `| `tests/checks/85-conflict-guards.sh` | declared-conflict declaration
      model and check guards (suite token `AC23`) |`; add the paragraph mapping
      stable token `AC23` to this item's acceptance criteria (spec AC1 → AC23,
      …), in the style of the `AC21`/`AC22` paragraphs; record the manual
      residual (a live `/conflicts`/`/status`/`/build`-gate model run is not
      executable in CI, like the cycle diagnostic's LLM-run residual). [AC12,
      AC9] [depends: T3]
      Verify: `bash tests/run.sh` → exit 0;
      `grep -n 'AC23' tests/README.md` shows the Checks row and the mapping
      paragraph, and the existing area list/tokens `AC18`–`AC22` are unchanged.

- [x] **T6** — Final integration pass, no new behavior: confirm the new area is
      independent of the existing agreements and fresh-clone-clean. [AC10, AC13,
      AC11] [depends: T1, T4, T5]
      Verify: `bash tests/run.sh` → exit 0 (`10-readiness`, `80-cycle-fixture`,
      `40-inventory` green; no `AC23` assertion duplicates readiness/cycle/
      inventory); `bash tests/mutation.sh` → exit 0; the clean mutation copy has
      no `work/` yet exits 0; `git status --porcelain -- docs .opencode README.md
      AGENTS.md template opencode.json` is empty (no production surface touched).
