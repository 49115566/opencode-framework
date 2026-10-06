---
feature: 0003-framework-quality-hardening/0003-readonly-permissions
phase: tasks
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Tasks — Read-only agent permissions and enforcement claims

Ordered, dependency-aware. One task ≈ one focused commit. All work is
prompt/config/documentation only; do not touch `opencode.json`,
`docs/workflow.md`, or `docs/artifact-conventions.md`.

- [x] **T1** — Remove the write/execute bash tokens from the six read-only
      agents. In `.opencode/agent/product.md`, `architect.md`, `roadmap.md`,
      `status.md`, `reviewer.md`, and `doctor.md`, delete the `"rg*": allow` and
      `"find*": allow` lines from `permission.bash`, leaving the leading
      `"*": deny` and every inspection/git-read entry unchanged. [AC1, AC2]
      Verify: `rg -n '"find\*"|"rg\*"' .opencode/agent/product.md .opencode/agent/architect.md .opencode/agent/roadmap.md .opencode/agent/status.md .opencode/agent/reviewer.md .opencode/agent/doctor.md`
      returns no matches, and `rg -F -c '"*": deny'` on each of the six files
      returns 1.

- [x] **T2** — Add the canonical read-only guard bullet to the end of the
      `<rules>` section of each of the six agents (same files as T1). Use the
      exact wording from `design.md` → "Approach §2" (guard, not sandbox; never
      write/move/delete via bash; use the Read, Grep, and Glob tools). [AC3, AC4]
      [depends: T1]
      Verify: `rg -l 'Read-only guard' .opencode/agent/{product,architect,roadmap,status,reviewer,doctor}.md`
      lists all six, and `rg -c 'not a sandbox' <each file>` returns 1.

- [x] **T3** — Correct the README's enforcement claims. In `README.md`:
      (a) rewrite the guardrail sentence at `:23-24` so read-only agents cannot
      create/modify/delete source through the file tools; (b) change the six
      `read-only allowlist` cells at `:166,167,168,172,175,179` to
      `read-only, best-effort †`; (c) add the footnote pointing to
      `docs/customization.md` under the Agents table; (d) rewrite the Permissions
      paragraph at `:181-188` to scope enforcement to `edit` and describe bash
      rules as command-prefix best-effort, unable to stop redirection or output
      flags. [AC5, AC6, AC7]
      Verify: `rg -n 'cannot touch source|read-only allowlist' README.md` returns
      nothing; `rg -n 'best-effort|not a sandbox|command prefix|redirection' README.md`
      returns matches; the Agents table still lists all 14 agents.

- [x] **T4** — Expand the customization guide's permission caveat
      (`docs/customization.md:133-136`) so it states the blocks are not a bash
      sandbox and cannot prevent redirection/output flags; names `bootstrap`,
      `scout`, `tester`, and `visual` as broad-bash agents that can modify files
      through the shell; names `scout`'s broad access as a deliberate, accepted
      residual; and does not list `ask`. [AC8]
      Verify: `rg -n 'scout|bootstrap|tester|visual|not a sandbox|residual' docs/customization.md`
      shows the four agents and the non-sandbox/residual wording, and
      `rg -n 'ask' docs/customization.md` shows no broad-bash listing for `ask`.

- [x] **T5** — Broaden the tester's file-tool allowlist. In
      `.opencode/agent/tester.md`, after `"**/__tests__/**": allow`, add both
      path forms for each of `e2e/`, `spec/`, `integration/`, `cypress/`, and
      `playwright/` (ten patterns, per `design.md` → "Approach §5"). Change
      nothing else in the file. [AC9]
      Verify: `rg -n '"(e2e|spec|integration|cypress|playwright)/\*\*"' .opencode/agent/tester.md`
      matches the five relative forms and
      `rg -n '"\*\*/(e2e|spec|integration|cypress|playwright)/\*\*"' .opencode/agent/tester.md`
      matches the five absolute forms.

- [x] **T6** — Verify the whole change: run the framework's permission
      diagnostic and confirm it is clean, and confirm scope. Run
      `opencode run --agent doctor "run the framework consistency diagnostic"`
      and confirm it prints `No findings — repository is consistent.`; re-run
      `bash work/0002-agentic-roadmaps/verify-tests.sh` and
      `bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh`
      to confirm the existing suites still pass. If `opencode` is unavailable,
      substitute a static check that each of the six agents' bash block matches
      the table in `design.md` and that the README cells/paragraph agree.
      [AC10, AC11] [depends: T1, T2, T3, T4, T5]
      Verify: the doctor line above; `git diff --name-only` lists only the nine
      expected files plus `work/` paths and does not include `opencode.json`,
      `docs/workflow.md`, or `docs/artifact-conventions.md`.
