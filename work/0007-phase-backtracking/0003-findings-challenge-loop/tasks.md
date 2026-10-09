---
feature: 0007-phase-backtracking/0003-findings-challenge-loop
phase: tasks
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Tasks — Contestable findings and adjudication loop

Ordered, dependency-aware. One task ≈ one focused commit. Deliverable is
documentation and prompts; no new command, agent, skill, phase value, or state
file. Committed fixtures and mutation coverage are `0007-backtracking-guards`.

- [x] **T1** — In `docs/workflow.md`, add `## Findings challenge and adjudication`
      immediately after `## Phase reversal (backtracking)` and before
      `## Derived state`, stating once as the single authority: what is
      challengeable (`review.md` findings and `verify.md` defects, including a
      defect that is really a spec/design fault; no finding = nothing blocks);
      raising a challenge via the current phase surface with a `Challenge <n>`
      entry in `challenges.md` and the never-edit-the-producing-artifact rule;
      the challenged blocked condition (the record's open-entry marker + the
      derived `challenged` label, no new `phase` value, no advance including
      `/ship`, escalation to the user); adjudication (producing phase re-evaluates
      first, user breaks a tie, challenger never adjudicates its own challenge,
      a `Response` records decision/basis/adjudicator); sustained vs rejected
      outcomes and routing (verdict recomputed `approve` iff no Blocker/Major;
      rejected resumes `request-changes` → `/build`; a revealed wrong AC routes
      upstream via the backtrack model); and ownership. Also add the challenged
      condition and its precedence to `## Derived state` (before the
      forward-action/verdict/ship rows) and refuse a challenged item in the
      `### 6. Ship` entry. Add no `### <digit>. ` heading and change none of the
      seven route literals checked by `tests/checks/20-lifecycle.sh:58-78`.
      [AC1, AC2, AC3, AC4, AC5, AC6, AC9, AC11, AC12, AC13]
      Verify: read the new section; `grep -n 'challenged\|challenges.md' docs/workflow.md` returns the condition and record; `grep -c '^### [0-9]' docs/workflow.md` is unchanged; `bash tests/run.sh` exits 0.

- [x] **T2** — In `docs/artifact-conventions.md`, add a
      `### \`challenges.md\` (challenges) — per-item challenge record` template
      after the `backtracks.md` template (`:471-520`): the minimal frontmatter
      (`feature`, `record: challenges`, `created`, `updated`) with no `phase`;
      the `Challenge`/`Response`/`Withdrawal`/`Reversal` entry shapes and fields
      (`challenger`, `challenged`, `type` ∈ `finding|severity|acceptance-criterion`,
      `evidence`, `rationale`, `status: open`; `resolves`, `adjudicator`,
      `decision` ∈ `sustained|rejected`, `basis`, `outcome`); the append-only
      rule and the malformed out-of-order rule; and the challenged condition
      derived from an open entry. Reuse the existing severity and verdict
      vocabulary; introduce no state file. [AC1, AC2, AC10, AC13]
      Verify: read the template; `grep -n 'challenges.md' docs/artifact-conventions.md` returns it; confirm the record frontmatter has no `phase:`; `bash tests/run.sh` exits 0.

- [x] **T3** — In `.opencode/agent/builder.md` (operating principles, process,
      rules, handoff) and `.opencode/command/build.md`, add the challenger
      surface: when the author disputes a `review.md` finding or a `verify.md`
      defect, append a `Challenge <n>` entry to `challenges.md` (type, evidence,
      rationale), never edit the producing phase's artifact, and hand off to the
      producing phase — `Next: /review <item-ref>` for a review finding,
      `Next: /test <item-ref>` for a verify defect — instead of `/build`
      addressing a disputed blocker. Leave the existing `/build`→`/plan` reverse
      edge and the plan-gate text intact. [AC1, AC2, AC3, AC9] [depends: T1, T2]
      Verify: `grep -n 'challeng\|challenges.md' .opencode/agent/builder.md .opencode/command/build.md` finds the route; `grep -n 'Usage: /build \[item-ref or task-id\]' .opencode/command/build.md` still matches; `bash tests/run.sh` exits 0.

- [x] **T4** — In `.opencode/agent/reviewer.md` (process, quality bar, rules,
      handoff) and `.opencode/command/review.md`, add adjudication: before
      ordinary forward work, read `challenges.md` for an open challenge against a
      `review.md` finding and re-evaluate it against the spec and diff; append a
      `## Response <n>` recording `adjudicator`, `decision`, `basis`, and
      `outcome`; when sustained, revise `review.md` (overturn/re-severity the
      finding, recompute the verdict `approve` iff no Blocker/Major remains) and
      route by the recomputed verdict; when rejected, leave the finding and
      verdict unchanged and resume normal routing; when unresolved, escalate on
      the question surface and record the user's decision (`adjudicator: user`);
      never adjudicate a challenge the reviewer raised. Keep the read-only-on-code
      rule (it still writes only `review.md`). [AC3, AC5, AC6, AC9] [depends: T1, T2]
      Verify: `grep -n 'challeng\|Response' .opencode/agent/reviewer.md .opencode/command/review.md` finds the steps; read the verdict-recomputation clause; `bash tests/run.sh` exits 0.

- [x] **T5** — In `docs/workflow.md` `## Phase reversal (backtracking)`, wire the
      `/test` edges: remove `/test` from the `### Taking an edge` step-1
      "not taken here" exception list; add `/test`→`/build`, `/test`→`/plan`, and
      `/test`→`/spec` to the concrete per-edge marker table with their affected
      artifacts, `stale:` marker sets (`/plan`→`stale: design`, `/spec`→
      `stale: spec`), and handoffs; present `/test`→`/build` as the existing
      implementation-defect rework with no forced record or marker; update the
      "only the two edges above are wired" note and the `### 4. Test` `Next` line.
      Leave the seven pinned route literals unchanged. [AC7, AC8] [depends: T1]
      Verify: `grep -n '/test' docs/workflow.md` shows the three edges in the table; read the marker sets; `bash tests/run.sh` exits 0.

- [x] **T6** — In `.opencode/agent/tester.md` (operating principles, process,
      handoff) and `.opencode/command/test.md`, add the `/test` classification and
      the verify-defect adjudication: classify each defect as an implementation
      fault (route to `/build` as today) or a spec/design fault (take the
      `/test`→`/plan` or `/test`→`/spec` edge per T5 — append a `backtracks.md`
      `Finding <n>` entry, apply the downstream `stale:` markers, do not edit the
      upstream artifact, hand off `Next: /plan <item-ref>` or
      `Next: /spec <item-ref>`), and when classification is unresolved record the
      question and escalate rather than guess; for an open challenge against a
      `verify.md` defect, re-evaluate and append a `Response`, revising
      `verify.md` only when sustained. Preserve the "owns tests, not production
      code" rule. [AC2, AC3, AC7, AC8, AC9] [depends: T1, T2, T5]
      Verify: `grep -nE 'challeng|spec or design|Next: .\/plan' .opencode/agent/tester.md .opencode/command/test.md` finds the classification and edges; `grep -nF 'Usage: /test [item-ref]' .opencode/command/test.md` still matches; `bash tests/run.sh` exits 0.

- [x] **T7** — In `.opencode/skill/code-review/SKILL.md`, reference the
      challenge/adjudication authority and the verdict-recomputation rule as the
      recorded route for a disputed finding, reusing the existing severity scale
      and `approve`/`request-changes` verdict; state no second severity or verdict.
      [AC11, AC12] [depends: T1]
      Verify: `grep -n 'challeng\|adjudicat' .opencode/skill/code-review/SKILL.md` finds the reference; confirm no new severity/verdict token; `bash tests/run.sh` exits 0.

- [x] **T8** — In `.opencode/skill/workflow-lifecycle/SKILL.md`
      `## Which command now?`, add route lines for an open challenge (adjudicate via
      the producing phase's command, e.g. `/review <item-ref>` or
      `/test [item-ref]`) and for a `/test` spec/design fault (`/plan <item-ref>`
      or `/spec <item-ref>`); use canonical signatures only and place trailing
      prose after two spaces so the `96-signature-sweep` extractor truncates it.
      [AC1, AC4, AC7, AC12] [depends: T1, T2, T5]
      Verify: read the block; `bash tests/run.sh` exits 0 (96-signature-sweep green).

- [x] **T9** — Final acceptance gate (no code change): confirm no command, agent,
      or skill was added or removed and the six phase command→agent pairings and
      the seven routing literals are unchanged; confirm no surface states a
      conflicting challenge rule and `.opencode/agent/status.md` is untouched
      (`0006` owns reporting); run the configured suite. [AC11, AC12, AC14]
      [depends: T3, T4, T5, T6, T7, T8]
      Verify: `bash tests/run.sh` exits 0 with `0 failed`; `git status --porcelain` touches only `docs/workflow.md`, `docs/artifact-conventions.md`, `.opencode/agent/{builder,reviewer,tester}.md`, `.opencode/command/{build,review,test}.md`, the two edited skills, and `work/0007-phase-backtracking/0003-findings-challenge-loop/**`; `git diff --stat` shows no `.opencode/agent/status.md`, no `README.md`, no `AGENTS.md`/`template/AGENTS.md`, and no `tests/**` change.
