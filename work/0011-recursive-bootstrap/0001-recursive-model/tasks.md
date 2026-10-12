---
feature: 0011-recursive-bootstrap/0001-recursive-model
phase: tasks
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Tasks — Recursive lifecycle model

Ordered, dependency-aware. One task ≈ one focused commit. This item is
documentation-only; no test file is added (committed guards are deferred to a
successor roadmap per the spec's non-goals). `Verify:` commands that run the
suite use the project's configured test command, `bash tests/run.sh`, optionally
area-scoped via `FRAMEWORK_TEST_AREAS`.

- [x] **T1** — Add the `## The recursive lifecycle model` section to
      `docs/workflow.md`, immediately after `## Mental model` and before
      `## The work item directory`, with the `### Terms` and `### The cycle
      applies at every node` subsections: define **node**, **leaf**, and
      **decomposition**, state that the standard six-phase cycle applies
      uniformly at every node, that recursion depth is unbounded, and that both
      a one-segment standalone item and a nested child are instances of the same
      model. State the five model terms (**work item**, **node**, **leaf**,
      **decomposition**, **plan**) once as the single authority and define
      `roadmap` only as a deprecated alias for a decomposing node. Do not
      restate the readiness algorithm, conflict grammar, backtrack literals, or
      any command signature — reference the shipped authorities by name. [AC1]
      [AC2] [AC6]
      Verify: `grep -nF '## The recursive lifecycle model' docs/workflow.md`
      finds the section between `## Mental model` and `## The work item
      directory`; the node/leaf/decomposition definitions, the uniform-cycle
      statement, and the unbounded-depth statement are present;
      `FRAMEWORK_TEST_AREAS='10-readiness,20-lifecycle,96-signature-sweep' bash tests/run.sh`
      exits 0.
- [x] **T2** — Append the `### Where decomposition is authored and recorded`
      and `### Granularity and hybrid nodes` subsections to the new section:
      the child set is authored and recorded in the planning (design) step
      (`/plan`, `architect`), `/roadmap` is a deprecated alias for that step, a
      decomposing node's child set is committed plan state, and the concrete
      writer's wiring is owned by `0003-recursive-writer`; a plan may decompose
      into a hybrid of tasks, features, initiatives, and larger items;
      fine-grained `tasks.md` entries are not nodes; and a node may carry its
      own phase artifacts and a child set at the same time, with no node
      required to be a pure container. [AC3] [AC4] [AC5] [depends: T1]
      Verify: the authoring/deprecation/plan-state statements, the hybrid
      granularity rule (including "`tasks.md` entries are not nodes"), and the
      hybrid-node statement are present;
      `FRAMEWORK_TEST_AREAS='10-readiness,80-cycle-fixture,85-conflict-guards' bash tests/run.sh`
      exits 0.
- [x] **T3** — Append the `### Composition with the shipped model` subsection:
      the shipped backtracking/re-entry model applies per node on the same
      unshipped work item (reverse edges, `stale:` marking, re-entry, recall,
      ownership) with no second state model, no new `phase` value, and no new
      reversal mechanism; the model reuses the shipped `Depends on`/readiness
      and declared-conflict vocabulary unchanged, with readiness/reporting
      owned by `0004-recursive-readiness` and the reference grammar by
      `0002-recursive-schema`; and a one-segment standalone item behaves exactly
      as before with no forced migration. Reference `## Phase reversal
      (backtracking)`, `### Dependencies and readiness`, and `### Declared
      conflicts (conflicts-with)` by name; restate none of them. [AC7] [AC8]
      [AC9] [depends: T1]
      Verify: the per-node composition statement, the readiness/conflict reuse
      statement, and the backward-compatibility statement are present and name
      the shipped authorities rather than restating them;
      `FRAMEWORK_TEST_AREAS='10-readiness,80-cycle-fixture,85-conflict-guards,87-backtrack-guards' bash tests/run.sh`
      exits 0.
- [x] **T4** — Prepend a deferral note to the existing `## Roadmaps` section in
      `docs/workflow.md` stating that `roadmap` is the deprecated alias for a
      decomposing node, that `## The recursive lifecycle model` is the authority
      for the term, and that this section describes the shipped, depth-limited
      concrete spelling. Leave the existing prose from "A **roadmap** is a
      parent work item..." onward verbatim. [AC6] [depends: T1]
      Verify: `grep -nF 'deprecated alias' docs/workflow.md` shows the note in
      `## Roadmaps`; the readiness literals `satisfied(dep_local_id):`, `even if
      unshipped`, and `presence is the sole shipped signal` still appear exactly
      where they did; `FRAMEWORK_TEST_AREAS='10-readiness,80-cycle-fixture' bash tests/run.sh`
      exits 0.
- [x] **T5** — Add the cross-reference sentence to `## The artifact contract` in
      `AGENTS.md` (after the existing roadmap paragraph): a node may decompose
      into children to unbounded depth and may carry its own artifacts and a
      child set at the same time, with `docs/workflow.md` → "The recursive
      lifecycle model" as the single authority and `roadmap` the deprecated
      alias. Add the **identical** sentence at the same position in
      `template/AGENTS.md`, keeping the two bodies byte-identical outside
      `## Project profile`. The sentence must be prose, not a markdown table row
      or a `Supporting commands:` continuation. [AC10] [depends: T1]
      Verify: the sentence appears in both `AGENTS.md` and `template/AGENTS.md`;
      the two files are byte-identical outside `## Project profile`;
      `FRAMEWORK_TEST_AREAS='95-split-guard,96-signature-sweep' bash tests/run.sh`
      exits 0.
- [x] **T6** — Confirm the whole repository is green and unchanged where it must
      be: run the full committed suite, confirm no new agent/command/skill file
      exists, and confirm the six core phase commands, the `phase` value set,
      the `Depends on`/readiness contract, and the declared-conflict contract
      are unchanged. [AC11] [depends: T1, T2, T3, T4, T5]
      Verify: `bash tests/run.sh` exits 0 with `TOTAL: <p> passed, 0 failed`;
      `40-inventory.sh` reports the documented counts equal to disk;
      `git diff --name-only` lists only `docs/workflow.md`, `AGENTS.md`, and
      `template/AGENTS.md`; `ls .opencode/agent .opencode/command .opencode/skill`
      shows no added file.
