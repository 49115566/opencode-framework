---
feature: 0003-framework-quality-hardening/0005-fix-landing
phase: tasks
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Tasks — Fix-track landing path

Ordered, dependency-aware. One task ≈ one focused commit. This is a
prompt/documentation change; do not edit any file under `work/` (the static
suites there are immutable shipped artifacts) and do not touch any agent's YAML
frontmatter (permission) block.

- [x] **T1** — Give `/fix` its landing step. In `.opencode/command/fix.md`,
      replace the "Never commit." ending with the same prohibition plus a
      paste-ready handoff that carries reproduction, root cause, change, files,
      and check results, and ends `Next: /ship fix` only when every check passed
      and the defect was reproduced. In `.opencode/agent/builder.md`, update the
      `<mission>` (line 26) and `<lightweight_fix_mode>` (line 77) to name the
      shipper-on-request landing while keeping `Never commit, push, or open a PR`
      (line 38). [AC1, AC5, AC10]
      Verify: `rg -n 'ship fix|shipper' .opencode/command/fix.md .opencode/agent/builder.md` shows the landing path; `rg -n 'Never commit, push, or open a PR' .opencode/agent/builder.md` still matches; read the `/fix` handoff and confirm it lists reproduction, root cause, change, files, and checks, and omits the landing step when a check fails.

- [x] **T2** — Add the shipper's fix-landing mode. In `.opencode/agent/shipper.md`,
      branch `<inputs>` and `<preconditions>` on the `/ship` argument: `item-ref`
      keeps today's path; `fix` allows landing a verified fix with no `review.md`
      on the user's explicit request, requiring an established reproduction, a
      regression test that fails before and passes after, and green
      test/lint/typecheck. Fix mode stages only the fix's files (never `git add
      -A`; ask when the boundary is unclear), scans staged content for secrets,
      branches `fix/<short-description>` (never the default branch), commits
      conventionally, opens a PR with the fix evidence, and **skips** `ship.md`.
      In `.opencode/command/ship.md`, document the grammar
      `/ship [item-ref | fix [short description]]` and the fix preconditions.
      Preserve every literal in the design's "Invariants preserved" table:
      `This is required, not optional` (shipper), `` `work/<item-ref>/` artifacts ``,
      `repository path`, `committed working state`, `NNNN-slug-MMMM-slug`, and
      `docs(work): record ship state` / `` no uncommitted `ship.md` `` /
      `This is required` / `` even when `gh` is unavailable `` in both files; do
      not change the frontmatter. The suites match these with `grep -F`, so
      preserve exact capitalization and keep each token on one line even when the
      text around it is re-scoped to work-item mode. [AC2, AC3, AC4, AC5, AC7, AC10]
      [depends: T1]
      Verify: `rg -n 'fix' .opencode/agent/shipper.md .opencode/command/ship.md` shows the mode, its explicit-request precondition, the no-review exception, the verify-before-landing gate, and the local-commit/`gh`-unavailable fallback; `rg -n 'This is required, not optional|docs\(work\): record ship state|no uncommitted .ship\.md.|NNNN-slug-MMMM-slug|work/<item-ref>/. artifacts' .opencode/agent/shipper.md` matches; `rg -n 'This is required|even when .gh. is unavailable|docs\(work\): record ship state|NNNN-slug/MMMM-slug|NNNN-slug-MMMM-slug' .opencode/command/ship.md` matches; `git diff -- .opencode/agent/shipper.md .opencode/command/ship.md` shows no frontmatter/permission change.

- [x] **T3** — Reconcile the guardrail and the lifecycle skill. In `AGENTS.md`,
      extend the guardrail at line 107 so the shipper may land a verified `/fix`
      on the user's explicit request (`/ship fix`) while every other agent still
      never performs git writes. In
      `.opencode/skill/workflow-lifecycle/SKILL.md`, update the rule at line 61-62
      and add a routing row for a verified fix ready to land (`/ship fix`). Keep
      `committed working state` and `no ship.md?` intact. [AC5, AC8, AC9, AC12]
      [depends: T2]
      Verify: `rg -n 'ship fix|verified fix|explicit request' AGENTS.md .opencode/skill/workflow-lifecycle/SKILL.md` matches; `rg -n 'committed working state|no ship.md\?' .opencode/skill/workflow-lifecycle/SKILL.md` still matches and `no PR?` is absent.

- [x] **T4** — Document the fix track in the workflow contract. In
      `docs/workflow.md`, update the `/fix` routing heuristic (lines 263-266) to
      state the shipper-on-request landing path, and add a short "## The fix
      track" section: no work item, sequence number, fix artifact, spec, design,
      tasks, verification, or review; no `ship.md`; verification failure blocks
      landing; only the shipper writes git; the PR carries the fix evidence.
      Preserve every readiness/ship token the committed suites assert
      (`presence is the sole shipped signal`, the derived-state rows,
      `satisfied(dep_local_id):`, `docs(work): record ship state`,
      `` no uncommitted `ship.md` ``, `committed working state`). [AC1, AC6, AC8, AC9, AC11, AC12]
      [depends: T2]
      Verify: `rg -n 'fix track|/ship fix|no work item|no shipped-state record' docs/workflow.md` matches; `rg -n 'presence is the sole shipped signal|satisfied\(dep_local_id\):|docs\(work\): record ship state|committed working state' docs/workflow.md` still matches.

- [x] **T5** — Add the fix PR template and branch note. In
      `.opencode/skill/pr-workflow/SKILL.md`, add a fix PR body section
      (Summary, Reproduction, Root cause, Change, Testing, Risks; no Artifacts
      section) and make the `review.md` precondition explicitly not apply to a
      fix. In `.opencode/skill/conventional-commits/SKILL.md`, note that a fix
      with no work item uses a `fix/<short-description>` branch. Keep
      `committed working state`, `resolve for a reviewer who does not share`,
      `` work/<item-ref>/spec.md ``, and `NNNN-slug-MMMM-slug`. [AC3, AC7, AC12]
      [depends: T2]
      Verify: `rg -n 'Reproduction|Root cause|/ship fix|fix/' .opencode/skill/pr-workflow/SKILL.md .opencode/skill/conventional-commits/SKILL.md` matches; `rg -n 'committed working state|resolve for a reviewer who does not share|work/<item-ref>/spec.md' .opencode/skill/pr-workflow/SKILL.md` still matches.

- [x] **T6** — Reconcile the README and run the consistency sweep. In
      `README.md`, correct line 23 ("only when you run `/ship`") to include an
      explicit request including `/ship fix`, mention the landing in line 88, and
      update the `/fix` command-table row (line 156). Keep the shipper row
      (`` `work/**` + `**/work/**` ``, not `none`), `branch, commits, PR, ship.md`,
      `Ship: branch + PR + ship.md`, and the `# 14 role prompts` /
      `# 12 slash commands` / `# 10 knowledge skills` counts. Then sweep every
      surface naming `/fix` (`.opencode/command/fix.md`, `.opencode/agent/builder.md`,
      `.opencode/agent/shipper.md`, `.opencode/command/ship.md`, `AGENTS.md`,
      `docs/workflow.md`, `README.md`, the `workflow-lifecycle`,
      `pr-workflow`, and `conventional-commits` skills) to confirm each states or
      refers to the `/ship fix` path and none is an un-landable dead end.
      [AC8, AC11, AC12] [depends: T3, T4, T5]
      Verify: `rg -n 'ship fix|/fix' README.md` shows the corrected claims; `bash work/0002-agentic-roadmaps/verify-tests.sh` reports `0 failed`; `git diff --stat` lists only the surfaces named in `design.md` and no path under `work/`; no agent frontmatter changed — `git diff -- .opencode/agent` contains no added or removed `edit:`/`bash:`/permission lines.
