---
feature: 0007-phase-backtracking/0007-backtracking-guards
phase: tasks
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Tasks — Committed backtracking and reopen guards

Ordered, dependency-aware. One task ≈ one focused commit. After every task,
`bash tests/run.sh` must stay green. Design authority: `design.md`.

- [ ] **T1** — Add the `tests/fixtures/backtracking/items/` fixture-local item
      tree exactly as designed (design §3): the record/edge items
      `9101-build-design` … `9108-malformed`, the challenge items
      `9109-challenge-open` … `9112-shipped-challenge`, the derived-state items
      `9113-reopened`/`9114-forward`, and the roadmap parents
      `9120-revised-roadmap`/`9121-readiness` with their child dirs. Give each
      item its `spec.md`/`design.md`/`tasks.md`/`verify.md`/`review.md`/`ship.md`
      as tabulated, with the exact frontmatter `stale:`/`reopened:` markers, the
      `backtracks.md`/`challenges.md` entries, the roadmap `Children` tables, and
      the `## Open issues` withdrawal/revision notes. No fixture file may contain
      the literal `work/`. [AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC10]
      Verify: `bash tests/run.sh` → exit 0 (no new check yet);
      `test -f tests/fixtures/backtracking/items/9101-build-design/backtracks.md`
      and `test -f tests/fixtures/backtracking/items/9121-readiness/0001-recalled/ship.md`;
      `grep -rn 'work/' tests/fixtures/backtracking` prints nothing.

- [ ] **T2** — Add `tests/checks/87-backtrack-guards.sh` (stable token `AC24`,
      pure bash/awk, Bash 3.2 compatible, sourced by `run.sh`, never `exit`):
      write the file header (fixture-scoped test code; references
      `10-readiness.sh`/`20-lifecycle.sh`/`80-cycle-fixture.sh`/
      `85-conflict-guards.sh`/`96-signature-sweep.sh` by name); implement the
      shared parsers and the record sub-areas `reverse-edge`
      (`fixture_backtrack_findings`), `record-status`
      (`fixture_backtrack_status`/`fixture_backtrack_malformed`), and
      `stale-downstream` (`fixture_stale_map`), comparing each to its expected
      block (design §4) and asserting the live reverse-edge table; add the
      structural `fixture-existence` loop (fails, never skips, on a missing
      fixture) and the `read-only-contract` assertion over
      `tests/fixtures/backtracking`. Every assertion is labelled
      `AC24 <sub-area>`. [AC1, AC2, AC3, AC10]
      Verify: `bash tests/run.sh` → exit 0 with the `AC24 reverse-edge`,
      `AC24 record-status`, and `AC24 stale-downstream` `ok` lines present; each
      analyzer's output block matches its expected block.

- [ ] **T3** — Append to `tests/checks/87-backtrack-guards.sh` the sub-areas
      `challenge-loop` (`fixture_challenge_entries`/`fixture_challenge_status`/
      `fixture_challenge_malformed`), `roadmap-revision` (`fixture_revision` plus
      its positive revision-note/withdrawal assertions), `readiness-revocation`
      (`fixture_readiness`/`fixture_readiness_blocked`), and `derived-state`
      (`fixture_derived`), with the expected blocks in design §4. The
      `roadmap-revision` sub-area references `80-cycle-fixture.sh` and
      `85-conflict-guards.sh` by name and restates none of their authority
      phrases. [AC4, AC5, AC6, AC7, AC8]
      Verify: `bash tests/run.sh` → exit 0 with the `AC24 challenge-loop`,
      `AC24 roadmap-revision`, `AC24 readiness-revocation`, and
      `AC24 derived-state` `ok` lines present; each analyzer's output block
      matches its expected block.

- [ ] **T4** — Append to `tests/checks/87-backtrack-guards.sh` the
      `contract-pins` sub-area (design §4): the documented record/field/marker/
      token/derived-label strings on `docs/artifact-conventions.md` and
      `docs/workflow.md`, referencing the authorities by name and restating
      neither the readiness algorithm nor the command signatures. [AC9]
      Verify: `bash tests/run.sh` → exit 0 with the `AC24 contract-pins` `ok`
      lines present; each pinned literal is found in its named surface.

- [ ] **T5** — Extend `tests/mutation.sh`: in `stage()` add
      `cp -R "$REPO_ROOT/tests/fixtures/backtracking" "$COPY/tests/fixtures/backtracking"`;
      add the eight mutation blocks from design §5, each followed by
      `restore_file` and `assert_clean_absent`, asserting the expected sub-area
      substrings (`AC24 reverse-edge`, `AC24 record-status`,
      `AC24 stale-downstream`, `AC24 challenge-loop`, `AC24 roadmap-revision`,
      `AC24 readiness-revocation`, `AC24 derived-state`, `AC24 contract-pins`);
      update the header comment's covered-area list to include `AC24`. [AC11]
      [depends: T2, T3, T4]
      Verify: `bash tests/mutation.sh` → exit 0, with eight `AC24` mutation lines
      reported "caught and named" and every clean run passing.

- [ ] **T6** — Document the new area in `tests/README.md`: add the Checks-table
      row `| `tests/checks/87-backtrack-guards.sh` | backtracking and reopen
      guards (suite token `AC24`) |`; add the paragraph mapping stable token
      `AC24` to this item's acceptance criteria (`spec AC1 → AC24 reverse-edge`,
      …), declaring the sub-areas, the `tests/fixtures/backtracking/` fixture
      root, the fixture-based and never-reads-`work/**` contract, and the
      mutation coverage, in the style of the `AC23` paragraph; record the manual
      residual (a live `/status` render, a real backtrack, or a `/ship recall` is
      not executable in CI, like the cycle diagnostic's LLM-run residual). [AC13]
      [depends: T2, T3, T4]
      Verify: `bash tests/run.sh` → exit 0; `grep -n 'AC24' tests/README.md`
      shows the Checks row and the mapping paragraph, and the existing area
      list/tokens `AC18`–`AC23` are unchanged.

- [ ] **T7** — Final integration pass, no new behavior: add the `no-duplication`
      structural assertion to `tests/checks/87-backtrack-guards.sh` (the file
      negates the exact literals owned by `10-readiness.sh`
      — `satisfied(dep_local_id):`, `presence is the sole shipped signal` —
      `20-lifecycle.sh` — `` `spec.md` missing ``, `No spec.md?` — and
      `96-signature-sweep.sh` — `` `/build [item-ref or task-id]` `` — and
      references those areas by name); confirm the new area is independent of the
      existing agreements and fresh-clone-clean; confirm only `tests/**` changed.
      [AC12, AC14] [depends: T5, T6]
      Verify: `bash tests/run.sh` → exit 0 (existing areas green; `AC24
      no-duplication` `ok`); `bash tests/mutation.sh` → exit 0; the clean
      mutation copy has no `work/` yet exits 0; `git status --porcelain --
      docs .opencode README.md AGENTS.md template opencode.json
      work/0007-phase-backtracking/roadmap.md` is empty (no production surface
      touched).
