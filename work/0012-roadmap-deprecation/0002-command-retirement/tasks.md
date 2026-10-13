---
feature: 0012-roadmap-deprecation/0002-command-retirement
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Tasks — Retire the `/roadmap` command and agent; `/plan` becomes the sole recursive writer

Ordered, dependency-aware. One task ≈ one focused commit. The change is
prompt/document/test text only; no code, command, agent, or skill is added, and
no read-side prose, fixture, `docs/artifact-conventions.md`, or committed `work/`
artifact is touched (AC14). Preserve verbatim every literal the suite pins,
especially `docs/workflow.md`'s backtrack/readiness phrases and the
`spec | design | build | test | review` substring pinned by
`tests/checks/87-backtrack-guards.sh:950-986`, and keep the six-column `Children`
header and the `conflicts-with` grammar unchanged. Reconcile the surfaces with
greps at T1–T6 and run the affected non-`96` areas; T7 edits the signature
registry and T8 runs the full suite, because `96` cannot pass until both the
surfaces and its registry agree.

- [x] **T1** — Remove the retired command and agent. Delete
      `.opencode/command/roadmap.md` and `.opencode/agent/roadmap.md`. [AC1, AC2]
      Verify: `ls .opencode/command .opencode/agent` lists no `roadmap.md`;
      `grep -rn 'agent: roadmap' .opencode/command` returns nothing.

- [x] **T2** — Move the create mode into the planning step and modernize the
      writer. In `.opencode/command/plan.md`, set the `description:` usage string
      to `Usage: /plan <item-ref or initiative>` (`:2`) and add the create-mode
      branch to the body (`:18,31-45`). In `.opencode/agent/architect.md`, re-home
      the create mode as a process step (empty argument → ask; existing
      `work/<item-ref>/` → existing-item path; otherwise a non-resolving
      argument — including an item-ref-shaped typo — takes the create path:
      recon `work/` for a likely duplicate to surface under `## Open issues`,
      allocate the next top-level `NNNN` + kebab slug, author `manifest.md` with
      `phase: manifest`, reserve child `.gitkeep`s, write no child phase
      artifact, recommend `/spec` for a single feature), and adopt the manifest
      spelling throughout — `manifest.md`, `phase: manifest`, `stale: manifest`,
      `### Revising a decomposition` (`:37,44,80,101,125-136,175-188,204,210,216-218,240`).
      [AC3, AC4, AC5, AC6] [depends: T1]
      Verify: `grep -nF 'Usage: /plan <item-ref or initiative>' .opencode/command/plan.md`
      prints the line; `grep -n 'manifest.md\|phase: manifest\|stale: manifest\|Revising a decomposition' .opencode/agent/architect.md .opencode/command/plan.md`
      shows the modern vocabulary; `grep -nF '/roadmap' .opencode/agent/architect.md .opencode/command/plan.md`
      returns nothing.

- [x] **T3** — Retire the `/roadmap` command-alias prose and update the
      Design-phase signature in `docs/workflow.md`. Rewrite the alias clauses at
      `:72-75`, `:193-194`, `:353-360`, `:430`, and the routing-heuristics bullet
      at `:1346-1351` so `/plan` is the sole recursive writer exposing
      `/plan <item-ref or initiative>`; change the Design heading at `:463` so it
      reads `### 2. Design — /plan <item-ref or initiative>`. Leave the legacy
      `roadmap.md` / `phase: roadmap` artifact-alias notes (`:53-57`, `:133`,
      `:190-191`, `:1225`, `:1254`, `:1297`, `:1470`) in place. [AC4, AC5, AC7]
      [depends: T2]
      Verify: `grep -nF '/roadmap' docs/workflow.md` returns nothing;
      `grep -n '### 2. Design' docs/workflow.md` shows the dual form;
      `grep -n 'roadmap.md' docs/workflow.md` shows only the recognized-deprecated-alias
      notes.

- [x] **T4** — Reconcile `README.md`. Rewrite the multi-feature prose (`:183-189`)
      to name `/plan <item-ref or initiative>` and `manifest.md`; change the
      lifecycle mermaid `/plan` label (`:140`) to the dual form; remove the
      `/roadmap` Commands-table row (`:203`) and set the `/plan` row (`:196`) to
      the dual form; remove the `roadmap` Agents-table row (`:215`); update the
      Layout counts (`:273-274`) to `13` agents and `12` commands (skills stay
      `11`). [AC4, AC5, AC8] [depends: T2]
      Verify: `grep -nF '/roadmap' README.md` returns nothing;
      `grep -nF '/plan &lt;item-ref or initiative&gt;' README.md` matches;
      `grep -n '# 13 role prompts\|# 12 slash commands' README.md` matches;
      `FRAMEWORK_TEST_AREAS='40-inventory,30-permissions' bash tests/run.sh` passes.

- [x] **T5** — Reconcile `AGENTS.md` and `template/AGENTS.md` identically.
      Set the Design row (`AGENTS.md:36` / `template/AGENTS.md:38`) to
      `/plan <item-ref or initiative>`; remove the `/roadmap` clause from the
      supporting-commands list (`:47` / `:49`); remove the `roadmap` agent from
      the supporting-agents list (`:51` / `:53`); and modernize the
      artifact-contract prose (`:67-78` / `:69-80`) to the decomposing-node /
      `manifest.md` vocabulary while retaining the legacy `roadmap.md` /
      `phase: roadmap` as the recognized deprecated artifact alias. Keep the two
      files byte-identical outside `## Project profile`. [AC4, AC5, AC9]
      [depends: T2]
      Verify: `grep -nF '/roadmap' AGENTS.md template/AGENTS.md` returns nothing;
      `FRAMEWORK_TEST_AREAS='95-split-guard,40-inventory' bash tests/run.sh` passes.

- [x] **T6** — Reconcile the `workflow-lifecycle` skill
      (`.opencode/skill/workflow-lifecycle/SKILL.md`). Replace the `/roadmap`
      routing line (`:31`) with the `/plan <item-ref or initiative>` route and
      update every other `/plan` signature in the routing block (`:33,40,42,46,48`)
      to the same dual form; modernize the decomposing-node paragraph (`:22-26`)
      to `manifest.md`; and update the derived-state view (`:60,63-66,88`) so the
      container phase is `manifest`, the artifact is `manifest.md`, and the token
      is `stale: manifest` (legacy `stale: roadmap` accepted as deprecated).
      [AC5, AC7, AC10] [depends: T2]
      Verify: `grep -nF '/roadmap' .opencode/skill/workflow-lifecycle/SKILL.md`
      returns nothing; `grep -n 'manifest.md\|manifest\b\|stale: manifest' .opencode/skill/workflow-lifecycle/SKILL.md`
      matches; `FRAMEWORK_TEST_AREAS='20-lifecycle,10-readiness' bash tests/run.sh` passes.

- [x] **T7** — Reconcile the signature guard `tests/checks/96-signature-sweep.sh`:
      change the `/plan` registry entry to `/plan <item-ref or initiative>`
      (`:40`), delete the `/roadmap` registry entry (`:47`), and remove
      `/roadmap` from `AGENTS_REQUIRED` (`:226`), `README_REQUIRED` (`:228`),
      `SKILL_REQUIRED` (`:230`), and `ALL_COMMANDS` (`:270`). Do not relax any
      other assertion. [AC4, AC11] [depends: T4, T5, T6]
      Verify: `grep -nF 'roadmap' tests/checks/96-signature-sweep.sh` returns
      nothing; `bash tests/run.sh` passes (all areas, `0 failed`).

- [x] **T8** — Verify the whole change: run the suite, confirm the scope, and
      confirm no new surface or rewritten artifact. [AC12, AC13, AC14]
      [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` → `TOTAL: <n> passed, 0 failed`;
      `git diff --name-only` over the implementation files lists exactly the
      removed `.opencode/command/roadmap.md` and `.opencode/agent/roadmap.md` and
      the edited `.opencode/command/plan.md`, `.opencode/agent/architect.md`,
      `README.md`, `AGENTS.md`, `template/AGENTS.md`,
      `.opencode/skill/workflow-lifecycle/SKILL.md`, `docs/workflow.md`, and
      `tests/checks/96-signature-sweep.sh`; `ls .opencode/agent .opencode/command .opencode/skill`
      shows 13 agents / 12 commands / 11 skills with no new entry; confirm no
      read-side prompt, fixture, `docs/artifact-conventions.md`, or committed
      `work/` artifact changed.
