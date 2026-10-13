---
feature: 0011-recursive-bootstrap/0004-recursive-readiness
phase: tasks
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Tasks — Readiness, derived state, and status across recursion

Ordered, dependency-aware. One task ≈ one focused commit. The deliverable is
framework documentation/prompts; every `Verify:` is the committed suite (scoped
to the touched areas) plus a content check. No new test file is added (spec
non-goal), so the suite is the executable gate throughout.

- [x] **T1** — Author the recursive readiness rule in `docs/workflow.md` →
  `### Dependencies and readiness`: state sibling-only-at-every-level (`Depends
  on` names only a sibling local id in the same `Children` table; a non-sibling
  target is a `DANGLING-DEP` integrity finding, no new edge kind), per-level
  independent application, and the decomposing-target-own-signal-only rule; root
  the algorithm's `child_dir` at the node's own canonical reference
  (`work/<node-ref>/<dep_local_id>/`) while preserving the `satisfied(dep_local_id):`
  marker and every commented branch line; keep the shipped phrases
  `even if unshipped`, `presence is the sole shipped signal`,
  `` `ship.md` presence takes precedence ``, the recalled-item sentence, and
  `A child in a cycle is never \`ready\``. [AC1, AC2, AC3, AC8]
      Verify: `FRAMEWORK_TEST_AREAS=10-readiness,80-cycle-fixture,87-backtrack-guards bash tests/run.sh` exits 0; `grep -c 'satisfied(dep_local_id):' docs/workflow.md` is 1 and `grep -rl 'satisfied(dep_local_id):' .opencode/` is empty.

- [x] **T2** — Generalize the report shape in `docs/workflow.md` →
  `### Status reporting`: an indented recursive tree to arbitrary depth, every
  node showing its derived phase and `ready`/`blocked: <local ids>`, and each
  decomposing node showing `<ready>/<total> ready` over its immediate children
  plus a phase distribution tally; keep the integrity bullet list verbatim and
  the exact phrases `integrity findings rather than failing` and `cycle members
  are never reported ready`. [AC6, AC7]
      Verify: `FRAMEWORK_TEST_AREAS=20-lifecycle,80-cycle-fixture bash tests/run.sh` exits 0; `grep -q 'indented' docs/workflow.md` and `grep -q '<ready>/<total> ready' docs/workflow.md` succeed.

- [x] **T3** — Add the recursive derived-phase rule to `docs/workflow.md` →
  `## Derived state`: own-phase-artifacts-first with `roadmap` only for a
  manifest with no own artifacts; qualify the `roadmap.md` table row to
  `| \`roadmap.md\` present and no own phase artifacts (check before \`spec.md\`) | roadmap |`;
  state that the shipped precedence (earliest `stale:` → `reopened:` → unshipped
  open-challenge overlay → artifact-presence/verdict rows) is unchanged with no
  new `phase` value; generalize the closing paragraph to a decomposing node and
  keep a `.gitkeep`-only node `not started`. [AC4, AC5, AC8, AC9]
      Verify: `FRAMEWORK_TEST_AREAS=20-lifecycle,87-backtrack-guards bash tests/run.sh` exits 0; `grep -q 'not started' docs/workflow.md` succeeds and the `roadmap.md` row now reads `no own phase artifacts (check before spec.md)`.

- [x] **T4** — Generalize `.opencode/agent/status.md` per the design: `<role>`,
  `<mission>`, `<operating_principles>`, `<inputs>`, `<process>` (steps 2–4, 10),
  `<readiness>`, `<quality_bar>`, `<output_format>`, `<rules>` — arbitrary-depth
  tree, own-artifacts-first derived phase, per-level readiness (sibling-only;
  decomposing target own-signal-only), while keeping the deferral to
  `Dependencies and readiness`, `CYCLIC-DEP`, `informational and never fatal`,
  `A child in a cycle is never \`ready\``, the flattened `members of a cycle are
  never reported` phrase, and the `## Declared-conflict check` reference. [AC2, AC4, AC6, AC7, AC9, AC10] [depends: T1, T2, T3]
      Verify: `FRAMEWORK_TEST_AREAS=10-readiness,20-lifecycle,80-cycle-fixture,85-conflict-guards bash tests/run.sh` exits 0; `grep -q 'Dependencies and readiness' .opencode/agent/status.md` and `grep -q 'own phase artifacts' .opencode/agent/status.md` succeed.

- [x] **T5** — Minimal recursive restatement in `.opencode/command/status.md`:
  replace the two-level "roadmap parent" language with arbitrary-depth
  decomposition and add the own-artifacts-first derived-phase and per-level
  readiness clauses; keep `Report them without failing`, the lowercase `a child
  in a cycle is never \`ready\``, `CYCLIC-DEP`, the `## Declared-conflict check`
  reference, and `Usage: /status [item-ref]`. [AC6, AC10] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=80-cycle-fixture,96-signature-sweep bash tests/run.sh` exits 0; `grep -q 'Usage: /status \[item-ref\]' .opencode/command/status.md` and `grep -q 'blocked' .opencode/command/status.md` succeed.

- [x] **T6** — Minimal recursion restatement in
  `.opencode/skill/workflow-lifecycle/SKILL.md` → `## Derived states`: add that a
  decomposing node derives its own phase from its own artifacts first (only a
  manifest with no own artifacts derives `roadmap`) and that readiness is derived
  independently at every level; keep the `docs/workflow.md` deferral, all routing
  literals, and all artifact names. [AC4, AC5, AC9, AC10] [depends: T3]
      Verify: `FRAMEWORK_TEST_AREAS=20-lifecycle,96-signature-sweep bash tests/run.sh` exits 0; `grep -q 'own phase artifacts' .opencode/skill/workflow-lifecycle/SKILL.md` succeeds.

- [x] **T7** — Full-suite gate, backward-compatibility, and scope check: run the
  whole committed suite and confirm the change touches only the four authorized
  surfaces (outside `work/`), with no new command/agent/skill and no inventory
  count change. [AC9, AC10, AC11] [depends: T1, T2, T3, T4, T5, T6]
      Verify: `bash tests/run.sh` prints `TOTAL: <n> passed, 0 failed` and exits 0; `git diff --name-only -- . ':(exclude)work/'` lists exactly `docs/workflow.md`, `.opencode/agent/status.md`, `.opencode/command/status.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`.
