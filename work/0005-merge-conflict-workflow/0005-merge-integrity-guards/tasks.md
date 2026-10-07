---
feature: 0005-merge-conflict-workflow/0005-merge-integrity-guards
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Ordered by dependency. T1 authors the single guard contract; T2-T6 attach the portable test-command reference and the pointers on the adopter-shared surfaces; T7 is the independent gate. Every task runs the project's configured test command (bash tests/run.sh) for its touched scope. No task adds a tests/** check, a verify-tests.sh, an executable, or a new command/agent/skill; tests/**, README.md, AGENTS.md, template/AGENTS.md, opencode.json, and every permission frontmatter are unchanged."
parent: 0005-merge-conflict-workflow
---

# Tasks — Merge-integrity guard as a portable behavior contract

Ordered, dependency-aware. One task ≈ one focused commit. Dependencies use
`[depends: Tn]`; every task ends with `Verify:`.

- [x] **T1** — Add the `### Merge-integrity guard` subsection to
      `docs/workflow.md` inside `## Merge conflicts`, after `### Verification`
      (ends at line 391) and before `### Relationship to renumbering`. It must
      state: the guard is prompt behavior only with no committed checker, script,
      helper, or executable tool and no `tests/` agreement area; the two
      enforcement points (`/status` offline and read-only; the `/ship`
      post-merge integrity pass after a merge to the default branch) observing
      the same invariant set and defining no separate guard; the seven-invariant
      table with codes `DUPLICATE-PREFIX` `(c)`, `DUPLICATE-CHILD` `(c)`,
      `DANGLING-DEP` `(b)`, `CYCLIC-DEP` `(b)`, `MISSING-CHILD` `(b)`,
      `UNLISTED-CHILD` `(b)`, `DRIFT-FACT` `(d)`; the finding grammar
      `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>` with
      non-fatal, never-silently-dropped/never-truncated, not-auto-repaired, and
      modifies-no-file semantics; that the vocabulary is the `merge-conflict`
      skill's `### Finding grammar` with no second vocabulary and no second
      policy; the empty-`work/` and already-up-to-date no-op (no findings, does
      not error); and the portability statement that verification names the
      repository's own configured test command — the Project profile `Test:`
      value — with the drift invariant observable offline through `/status`.
      Do not remove the existing `integrity findings rather than failing`,
      `CYCLIC-DEP`, `cycle members are never reported ready`, or `A child in a
      cycle is never \`ready\`` literals. [AC1] [AC2] [AC3] [AC5] [AC7] [AC8]
      Verify: `grep -qF -- '### Merge-integrity guard' docs/workflow.md && for s in 'no committed checker, script, helper, or executable tool' 'observes the same invariant set' 'offline and read-only' 'post-merge integrity pass' 'DUPLICATE-PREFIX' 'DUPLICATE-CHILD' 'DANGLING-DEP' 'CYCLIC-DEP' 'MISSING-CHILD' 'UNLISTED-CHILD' 'DRIFT-FACT' 'not auto-repaired' 'modifies no file' 'no second vocabulary' 'no second policy' 'configured test command' 'Project profile' 'does not error'; do grep -qF -- "$s" docs/workflow.md || exit 1; done && bash tests/run.sh` → exit 0, with `80-cycle-fixture.sh` (`CYCLIC-DEP`, `integrity findings rather than failing`, `cycle members are never reported ready`) and `20-lifecycle.sh` still green.

- [x] **T2** — Generalize the re-verification test-command reference in
      `docs/workflow.md`: replace the literal `bash tests/run.sh` in
      `### Lifecycle placement` (line 363, post-merge pass) and `### Verification`
      (line 387) with the repository's own configured test command — the Project
      profile `Test:` value. Keep the requirement ("both must be green before the
      resolved merge is recorded or shipped") and the surrounding prose intact.
      [AC5] [depends: T1]
      Verify: `! grep -n 'bash tests/run.sh' docs/workflow.md && grep -qF -- 'configured test command' docs/workflow.md && grep -qF -- 'Project profile' docs/workflow.md && grep -qF -- 'Both must be green before the resolved merge is recorded or shipped' docs/workflow.md && bash tests/run.sh` → exit 0.

- [x] **T3** — In `.opencode/skill/merge-conflict/SKILL.md`, replace the four
      `bash tests/run.sh` re-verification literals with the configured
      test-command reference (sub-step 1.8 line 206; procedure step 4 line 248;
      post-merge pass step 6 line 267; `work/` reconcile hand-back line 396). At
      `### Finding grammar` (lines 94-125) add a sentence naming
      `docs/workflow.md` → `### Merge-integrity guard` as the single statement
      of the invariant set and enforcement points, with no second vocabulary and
      no second policy and no file modified by the guard. At the post-merge pass
      step (lines 261-267) state the pass is report-only — it reports every
      finding and modifies no file. Keep the existing pre-flight, finding
      grammar, and `### Up to date and degraded paths` no-op text. [AC3] [AC5]
      [AC6] [AC7] [depends: T1]
      Verify: `! grep -n 'bash tests/run.sh' .opencode/skill/merge-conflict/SKILL.md && grep -qF -- 'configured test command' .opencode/skill/merge-conflict/SKILL.md && grep -qF -- 'Project profile' .opencode/skill/merge-conflict/SKILL.md && grep -qF -- '### Merge-integrity guard' .opencode/skill/merge-conflict/SKILL.md && grep -qF -- 'no second vocabulary' .opencode/skill/merge-conflict/SKILL.md && grep -qF -- 'modifies no file' .opencode/skill/merge-conflict/SKILL.md && bash tests/run.sh` → exit 0.

- [x] **T4** — Add the guard-contract pointer to the read-only window. In
      `.opencode/agent/status.md` add `docs/workflow.md` → `### Merge-integrity
      guard` to `<inputs>` (lines 54-66) as the canonical invariant set and
      enforcement points, and add to `<findings>`/`<rules>` (lines 122-151,
      193-215) that the offline integrity report is the guard's read-only window
      — report-only, non-fatal, never auto-repaired, modifies no file. In
      `.opencode/command/status.md`, extend the findings bullet (lines 28-40)
      with the same pointer and that the report is non-fatal and modifies no
      file. Preserve `Dependencies and readiness`, `integrity findings rather
      than failing`, `CYCLIC-DEP`, `cycle members are never reported ready`,
      `a child in a cycle is never \`ready\``, `Report them without failing`, and
      the local-only/no-fetch/no-dry-run literals. [AC2] [AC3] [AC6] [AC7]
      [depends: T1]
      Verify: `grep -qF -- '### Merge-integrity guard' .opencode/agent/status.md && grep -qF -- '### Merge-integrity guard' .opencode/command/status.md && grep -qF -- 'Dependencies and readiness' .opencode/agent/status.md && grep -qF -- 'integrity findings rather than failing' docs/workflow.md && grep -qF -- 'CYCLIC-DEP' .opencode/agent/status.md .opencode/command/status.md && grep -qF -- 'Report them without failing' .opencode/command/status.md && bash tests/run.sh` → exit 0 (`10-readiness.sh`, `80-cycle-fixture.sh` green).

- [x] **T5** — In `.opencode/agent/shipper.md`, replace the `bash tests/run.sh`
      re-verification literal in work-item process step 2 (line 173) with the
      configured test-command reference, and add to `<rules>` (lines 220-250)
      that the post-merge integrity pass is the report-only guard per
      `docs/workflow.md` → `### Merge-integrity guard` — report every finding,
      never auto-repair, never mutate a file for it. Change no permission
      frontmatter. [AC2] [AC3] [AC5] [depends: T1]
      Verify: `grep -qF -- 'configured test command' .opencode/agent/shipper.md && grep -qF -- 'Project profile' .opencode/agent/shipper.md && grep -qF -- '### Merge-integrity guard' .opencode/agent/shipper.md && [ "$(grep -n 'bash tests/run.sh' .opencode/agent/shipper.md | grep -vc allow)" -eq 0 ] && bash tests/run.sh` → exit 0 (`30-permissions.sh` still reports the shipper `bash=git-gh`; the bash allowlist pattern is intentionally retained and is the only remaining `bash tests/run.sh` occurrence).

- [x] **T6** — Generalize the illustrative `Re-verification:` command in the two
      reconcile-record templates: `docs/artifact-conventions.md` line 419 (the
      `ship.md` template) and `.opencode/skill/pr-workflow/SKILL.md` line 54 (the
      PR description's `## Reconcile` section). Replace the literal
      `bash tests/run.sh` with the configured-test-command reference (the
      repository's own configured test command — the Project profile `Test:`
      value). Change no field name, field order, or template shape. [AC5]
      [depends: T1]
      Verify: `! grep -n 'bash tests/run.sh' docs/artifact-conventions.md .opencode/skill/pr-workflow/SKILL.md && grep -qF -- 'configured test command' docs/artifact-conventions.md .opencode/skill/pr-workflow/SKILL.md && grep -qF -- '- Re-verification:' docs/artifact-conventions.md .opencode/skill/pr-workflow/SKILL.md && grep -qF -- '- Result:' docs/artifact-conventions.md .opencode/skill/pr-workflow/SKILL.md && bash tests/run.sh` → exit 0.

- [x] **T7** — Independent gate. Confirm the committed suite exits 0; confirm
      the guard contract and its invariant set are present on the adopter-shared
      surfaces (`docs/workflow.md`, `.opencode/skill/merge-conflict/SKILL.md`,
      `.opencode/agent/status.md`) and that their codes agree with the skill's
      `### Finding grammar`; confirm no maintainer-only `bash tests/run.sh`
      *instruction* survives on an adopter-shared surface (the literal remains
      only in `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`,
      `tests/**`, and the shipper's bash allowlist pattern); confirm `tests/**`
      is unchanged and inventories are 12 commands / 14 agents / 11 skills with
      no new executable. [AC4] [AC6] [AC7] [AC8] [AC9] [AC10] [depends: T2]
      [depends: T3] [depends: T4] [depends: T5] [depends: T6]
      Verify: `bash tests/run.sh` → exit 0 with `TOTAL: … 0 failed`; `test -z "$(git diff --name-only -- tests/)"` (no `tests/**` change); `test "$(ls .opencode/command/*.md | wc -l)" -eq 12 && test "$(ls .opencode/agent/*.md | wc -l)" -eq 14 && test "$(ls -d .opencode/skill/*/ | wc -l)" -eq 11`; `! grep -rn 'bash tests/run.sh' docs/workflow.md docs/artifact-conventions.md .opencode/skill/merge-conflict/SKILL.md .opencode/skill/pr-workflow/SKILL.md` and the shipper's only occurrence is the allowlist `[ "$(grep -n 'bash tests/run.sh' .opencode/agent/shipper.md | grep -vc 'allow')" -eq 0 ]`; `grep -qF -- 'DRIFT-FACT' docs/workflow.md .opencode/skill/merge-conflict/SKILL.md .opencode/agent/status.md`.
