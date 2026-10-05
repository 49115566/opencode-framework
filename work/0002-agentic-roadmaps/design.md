---
feature: 0002-agentic-roadmaps
phase: design
status: final
created: 2026-10-04
updated: 2026-10-04
notes: "Prompt/config-only work item: a new /roadmap command + roadmap agent, a nested child work-item layout, a first-class roadmap.md artifact, and live readiness reporting in /status. No runtime code or dependency is added."
---

# Design — Agentic multi-feature roadmaps

## Summary

A roadmap becomes a first-class **parent work item** at `work/<NNNN-slug>/` whose
`roadmap.md` artifact enumerates child features, records intra-roadmap
dependencies, and states assumptions; each child is a real, empty work-item
directory nested at `work/<NNNN-slug>/<MMMM-slug>/` that later runs the existing
per-feature lifecycle unchanged. A new `/roadmap` command backed by a new
`roadmap` agent authors the roadmap and creates the child directory skeletons
autonomously. The `/status` agent derives each child's phase and readiness
(`ready`/`blocked`, naming blockers) live from files, and the `/spec` path
refuses to start a blocked child without an explicit override. The shared model —
canonical reference syntax, artifact shapes, readiness rule, and derived-state
additions — lives in the always-loaded `docs/artifact-conventions.md` and
`docs/workflow.md` so every agent reads one definition.

## Approach

Six coordinated changes, all confined to prompts, docs, and the ignore/permission
surface. The existing `status` agent + `/status` command and the `product`
agent + `/spec` command are the templates; nothing about the single-feature
lifecycle changes.

### 1. Work-item references: one grammar, resolved to a path (AC8, AC11)

Introduce a single reference grammar, documented once in the always-loaded
`docs/artifact-conventions.md`:

```
item-ref  ::= standalone | child
standalone ::= NNNN-slug                     e.g. 0007-billing
child      ::= NNNN-slug "/" MMMM-slug       e.g. 0002-agentic-roadmaps/0001-roadmap-model
```

- The **canonical reference** of an item is its path relative to `work/`:
  `NNNN-slug` for a standalone item, `NNNN-slug/MMMM-slug` for a roadmap child.
- Any item-ref resolves to the directory `work/<item-ref>/`.
- Every phase agent and command already receives `$ARGUMENTS`; each gains a
  one-line rule to resolve a two-segment reference to the nested path. A
  one-segment reference behaves exactly as today (AC11).
- `feature` frontmatter is the canonical reference (equal to the directory name
  for standalone items, the parent/child path for nested items), so it stays
  globally unique. Nested artifacts MAY additionally set `parent: <NNNN-slug>`.

Because `work/*` is already git-ignored (`.gitignore:7`), nested content is
covered with no ignore change, and `work/**` + `**/work/**` already covers every
nested path in the permission model (`docs/customization.md:107-125`). No new
grant is needed.

### 2. The roadmap artifact (AC2, AC3, AC4)

New artifact `work/<NNNN-slug>/roadmap.md`, frontmatter `phase: roadmap`:

```yaml
---
feature: 0002-agentic-roadmaps
phase: roadmap
status: final
created: 2026-10-04
updated: 2026-10-04
notes: ""
---
```

Body sections, in order:

```markdown
# Roadmap — <initiative title>

## Initiative
<one paragraph: what the initiative is and who it serves>

## Assumptions
- <each assumption the decomposition relied on>

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-model | Core model | <scope sufficient to author a spec> | — | 0002-x/0001-model |
| 0002-api   | API layer  | ...                                 | 0001-model | 0002-x/0002-api |

## Sequencing
1. 0001-model
2. 0002-api

## Open issues
- <cycle / non-decomposable / duplicate / single-feature / unresolved>
```

- **Local id** is the child's directory name `MMMM-slug`; it is the key used in
  `Depends on` (dependencies are intra-roadmap only, a spec Non-goal).
- **Canonical reference** is the full item-ref; status and phase commands address
  the child by it.
- The **Children** table is the single machine-readable source for the child set
  and the dependency graph. Status parses this table; there is no second file.
- Dependencies must name an existing local id, never self. If the initiative's
  dependency graph contains a cycle, the agent does **not** write the cyclic edges
  into `Depends on`; it records the intended cycle under `## Open issues` and
  leaves the stored graph acyclic (AC4). A cyclic stored graph is therefore a
  manual-edit defect that status detects defensively (§5).

### 3. Child directory skeletons (AC3, AC12)

For every enumerated child, the roadmap agent creates
`work/<NNNN-slug>/<MMMM-slug>/.gitkeep` and nothing else. Writing the placeholder
creates the intermediate directory (the same mechanism the `product` agent
already uses to create `work/<NNNN-slug>/` for `spec.md`), so no `mkdir` bash
grant is required. `.gitkeep` is not a phase artifact: the directory contains no
spec, design, tasks, verify, or review (AC3). Child local numbers are allocated
per parent, independent of the flat top-level sequence and of other roadmaps
(spec edge case: numbering collisions).

### 4. `/roadmap` command and `roadmap` agent (AC1, AC14)

New primary agent `.opencode/agent/roadmap.md` (frontmatter in §"Interfaces and
data model") and a thin `.opencode/command/roadmap.md`. The agent:

1. Restates the initiative. If it is empty, asks for it and creates nothing
   (empty-initiative edge case). If it decomposes to a single feature,
   recommends `/spec <feature>` instead of a one-child roadmap unless the user
   insists (AC14, single-feature edge case).
2. Recons existing items (`ls`/`rg` over `work/*/spec.md`, `work/*/roadmap.md`)
   and surfaces a likely duplicate initiative rather than silently creating a
   second roadmap (duplicate edge case).
3. Decomposes into children, assigns local ids, and detects dependency cycles and
   non-decomposable initiatives. If the initiative cannot be decomposed, it
   records that under `## Open issues` and fabricates nothing (AC14).
4. Allocates the next top-level `NNNN` (highest existing `work/` number + 1) and
   writes `work/<NNNN-slug>/roadmap.md` and each child `.gitkeep` — autonomously,
   with no pre-write approval gate (AC1). It may ask one batched clarifying round
   when the initiative is too ambiguous to decompose.
5. Writes no child specs and performs no child phase work (AC12, spec Non-goals).

The agent's `edit` permission is limited to `work/**` + `**/work/**`; it cannot
touch source. Bash is a read-only allowlist. Handoff recommends the next command
per ready child, e.g. `/spec 0002-x/0001-model`.

### 5. Status: roadmap rows, readiness, and integrity findings (AC5, AC6, AC7, AC10, AC15)

`status` determines an item is a roadmap parent by the presence of
`roadmap.md`; otherwise it is a single-feature item. Nothing is written (AC10).

**Readiness algorithm** (documented in `docs/workflow.md`, executed by status and
by the `product` gate in §6):

```
satisfied(dep_local_id):
  child_dir = work/<parent>/<dep_local_id>/
  if child_dir does not exist        -> dangling; not satisfied
  if child_dir/ship.md exists        -> satisfied        # shipped
  if child_dir/review.md exists
       and its verdict == "approve"  -> satisfied        # approved, even if unshipped
  otherwise                          -> not satisfied

ready(child)      = every dependency of child is satisfied AND child is not in a cycle
blocked_by(child) = [dep_local_id for each unsatisfied dependency]
```

A child with no dependencies is ready (AC6). A `request-changes` review, a
review that does not exist yet, and an approved-but-unshipped review boundary are
all handled explicitly: only `approve` or shipped satisfies (AC6).

**Integrity findings** (reported, never fatal — AC15):
- `DANGLING-DEP` — a `Depends on` local id with no child directory or no table row.
- `MISSING-CHILD` — a table row whose canonical reference/directory is absent.
- `UNLISTED-CHILD` — a child directory present under the parent but absent from
  the Children table (possible rename).
- `CYCLIC-DEP` — status's defensive cycle check finds a cycle in a manually
  edited graph; cycle members are never reported ready (cycle edge case).

**Output shape** — roadmaps reported separately from their children, with the
roadmap summary carrying both readiness (`<ready>/<total> ready`) and the
distribution of children across phases (AC7):

```
| Item                                   | Phase       | Progress            | Next command                          |
| -------------------------------------- | ----------- | ------------------- | ------------------------------------- |
| 0002-agentic-roadmaps                  | roadmap     | 1/3 ready           | /status 0002-agentic-roadmaps         |
|   0001-roadmap-model                   | test        | 3/3 tasks           | /review 0002-.../0001-roadmap-model   |
|   0002-spec-phase                      | not started | blocked: 0001-model | /spec 0002-.../0002-spec-phase        |

Roadmap 0002-agentic-roadmaps: 1/3 ready · phases: test 1, not started 2
```

The roadmap row's "progress" is `<ready>/<total> ready`, followed by a phase
distribution tally (`<phase> <n>, ...`) so the roadmap is never presented as a
single-feature item; a standalone row keeps `checked/total tasks` and has no
tally.

### 6. Blocked-start gate on the spec path (AC9)

The `product` agent, when the reference is a nested child, resolves the parent
`roadmap.md`, runs the §5 readiness algorithm, and if the child is blocked:
reports the specific blocking children and **stops** before writing `spec.md`.
It proceeds only on an explicit user override, and then records the override and
the blocking dependencies in the new `spec.md` frontmatter `notes` for
traceability. Refusing touches no existing file. Status continues to compute
readiness from the roadmap graph, so a started-but-blocked child remains visible
as blocked even after an override (override edge case). The refusal is a
**hard stop with an override**, not a warning: AC9 requires "an explicit user
override".

## Alternatives considered

- **Flat children with a top-level registry** (keep children at
  `work/<NNNN-slug>/`, list them in a `work/ROADMAPS.md` or `roadmap.yaml`).
  Pros: no nesting, so no reference-resolution changes anywhere; phase commands
  work untouched. Cons: the spec's resolved Work-item-hierarchy decision fixes
  nested children at `work/<parent>/<child>/`, and a global registry is a second
  state file that can drift from the tree, against the derived-state rule.
  Rejected on the recorded user decision.
- **Fold authoring into `/spec` + `product`** (detect a large request and emit a
  roadmap instead of a spec). Pros: one entry point; no new counted agent or
  command. Cons: the spec's resolved Invocation decision requires a new command
  while `/spec` stays single-feature; it also conflates requirements (what/why)
  with decomposition (how many pieces and in what order), which the `product`
  agent is explicitly told not to do. Rejected on the user decision and cohesion.
- **A dedicated `roadmap-lifecycle` skill** for the shared reference/readiness
  model instead of always-loaded docs. Pros: a focused, matchable operational
  guide. Cons: `docs/workflow.md` and `docs/artifact-conventions.md` are already
  loaded into every agent via `opencode.json:6-10`, so a skill adds a counted
  artifact and a second copy of the same rules without adding reach; AC13 names
  only a new command and agent. Rejected for duplication and a smaller diff.
- **Precompute readiness into `roadmap.md`.** Pros: status does no graph work.
  Cons: readiness changes as children advance, so any stored value is a stale
  state file and violates the derived-state rule (AC10) and AC6's live boundary.
  Rejected.

## Interfaces and data model

No runtime code, schema, or migration; the "data model" is the artifact formats
and the reference grammar.

**New `.opencode/agent/roadmap.md` frontmatter** (the AC12 enforcement):

```yaml
description: Roadmap authoring agent. Decomposes a multi-feature initiative into interdependent child work items, writes the roadmap artifact, and creates child directory skeletons. Runs /roadmap.
mode: primary
permission:
  edit:
    "*": deny
    "work/**": allow
    "**/work/**": allow
  bash:
    "*": deny
    "git log*": allow
    "git diff*": allow
    "git show*": allow
    "ls*": allow
    "cat*": allow
    "rg*": allow
    "find*": allow
    "tree*": allow
  question: allow
```

No write-capable bash pattern and no source edit; `.gitkeep` creation flows
through the `work`-scoped edit permission.

**New `.opencode/command/roadmap.md` frontmatter**:

```yaml
description: "Decompose a multi-feature initiative into a roadmap and nested child work items. Usage: /roadmap <initiative>"
agent: roadmap
```

**Roadmap frontmatter** — `feature` (canonical ref), `phase: roadmap`, `status`,
`created`, `updated`, `notes`. Add `roadmap` to the `phase` enum in
`docs/artifact-conventions.md`.

**Nested child artifacts** — same templates as standalone, with:
- `feature: <parent-NNNN-slug>/<child-MMMM-slug>` (canonical reference), and
- optional `parent: <parent-NNNN-slug>`.

Both additions are optional, so existing standalone artifacts and their required
fields are unchanged (AC11). No migration: existing `work/` content is untouched.

**Roadmap Children table row contract** (parsed by status):

| Column | Type | Rule |
| --- | --- | --- |
| Local id | `MMMM-slug` | unique within the roadmap; equals the child directory name |
| Title | free text | human label |
| Scope | free text | enough to author a spec later |
| Depends on | local ids, comma-separated, or `—` | each must name another row; no self; acyclic |
| Canonical reference | `NNNN-slug/MMMM-slug` | resolves to `work/<ref>/` |

**Reference grammar** (regex for agent self-checks):
`^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$`.

## Affected areas

New:
- `.opencode/agent/roadmap.md` — roadmap authoring agent.
- `.opencode/command/roadmap.md` — `/roadmap` command.

Docs (always-loaded — the single source of truth):
- `docs/artifact-conventions.md` — `roadmap` phase; optional `parent`; reference
  grammar; nested layout; `roadmap.md` template.
- `docs/workflow.md` — Roadmaps section; derived-state additions; readiness
  algorithm; blocked-start protocol; `/roadmap` routing; nested work-item layout.
- `AGENTS.md` — supporting commands/agents lists; a nested-work-item note.
- `README.md` — Agents table (`roadmap`), Commands table (`/roadmap`), layout
  counts (`# 14 role prompts`, `# 12 slash commands`), roadmap mention.

Agents (canonical-reference resolution; `product` also gets the AC9 gate):
- `.opencode/agent/product.md`, `architect.md`, `builder.md`, `tester.md`,
  `reviewer.md`, `shipper.md`, `visual.md`, `status.md`.

Commands (item-ref/path notes):
- `.opencode/command/spec.md`, `plan.md`, `build.md`, `test.md`, `review.md`,
  `ship.md`, `visual.md`, `status.md`.

Skill:
- `.opencode/skill/workflow-lifecycle/SKILL.md` — quick-view decision table row
  for roadmaps and nested refs.

Unchanged: `opencode.json`, `.gitignore` (nested `work/` already ignored), all
other agents (scout, scribe, doctor, bootstrap, ask), lifecycle phase tables, and
all phase semantics for standalone items.

## Risks and mitigations

- **Readiness is computed by an LLM agent and can be non-deterministic or miss a
  branch** — likelihood: medium / impact: high. Mitigation: the algorithm is
  written once in the always-loaded `docs/workflow.md`; status follows an explicit
  decision list (no-dep ⇒ ready; approve or `ship.md` ⇒ satisfied; else blocked);
  the tester seeds each boundary (approved-unshipped, request-changes, no review,
  dangling, cycle) in task T10 and records results.
- **A broad mechanical edit across 8 agents and 8 commands drifts or is applied
  inconsistently** — likelihood: medium / impact: medium. Mitigation: the rule
  lives in the always-loaded docs and each agent/command gets one identical
  sentence pointing at it; T9 greps every phase file for the two-segment
  reference rule.
- **`phase: roadmap` and nested items confuse existing phase derivation** —
  likelihood: medium / impact: medium. Mitigation: derived-state additions are
  explicit (a directory with `roadmap.md` is a roadmap parent); status treats
  children as ordinary items; `docs/workflow.md` gains the row.
- **`.gitkeep` is mistaken for a phase artifact, or a child directory is missed**
  — likelihood: low / impact: low. Mitigation: AC3's wording is applied literally;
  T10 asserts each child dir exists and contains only `.gitkeep`.
- **Cycle handling is bypassed by a manual edit** — likelihood: low / impact:
  medium. Mitigation: the roadmap agent never stores a cyclic graph; status's
  `CYCLIC-DEP` check detects a manually introduced cycle and refuses to mark
  members ready.
- **Duplicate-initiative detection is best-effort** (no index) — likelihood:
  medium / impact: low. Mitigation: the agent scans `work/*/roadmap.md` and
  `work/*/spec.md` titles and surfaces a possible duplicate as an open issue
  rather than blocking.
- **Adding an agent and command without updating inventories reintroduces
  `/doctor` drift** — likelihood: high / impact: medium. Mitigation: T8 updates
  README and AGENTS.md and the counts; T9 requires `/doctor` to print
  `No findings — repository is consistent.`
- **`status` is read-only but could be tempted to "fix" a dangling ref** —
  likelihood: low / impact: medium. Mitigation: status keeps `edit: deny` and its
  rules forbid modification; AC10 is checked by `git status` in T9.

## Test strategy

There is no test runner in this repo (no root `package.json`/`pyproject.toml`;
`0001-framework-consistency-hardening/design.md:289-292`). Framework verification
is read-only shell assertions plus real agent invocation recorded in `verify.md`.
Every AC gets a shell assertion where the fact is static, and a manual agent run
where the behavior is LLM-driven.

| AC | Verification | Level |
| --- | --- | --- |
| AC1 | Manual: run `/roadmap <multi-feature initiative>`; confirm a new top-level `work/<NNNN-slug>/roadmap.md` exists with no separate approval prompt. | manual |
| AC2 | `rg` the roadmap artifact for Initiative, Assumptions, and a Children row carrying local id, scope, and canonical reference; manual read. | shell + manual |
| AC3 | `ls work/<parent>/*/` shows each child dir; `find work/<parent> -mindepth 2 -name '*.md'` finds no phase artifact, only `.gitkeep`. | shell |
| AC4 | `rg`/manual: each `Depends on` value is another row's local id, no self-dependency; a seeded cycle appears only under Open issues, and the stored graph is acyclic. | manual |
| AC5 | Manual: `/status <parent>` prints `ready`/`blocked` per child and names blockers; T10 crosses each boundary. | manual |
| AC6 | T10 seeds approved-unshipped, request-changes, and no-review children; only approve/ship counts satisfied; no-dep child is ready. | manual |
| AC7 | Manual: `/status` shows the roadmap row separately with `<ready>/<total> ready` and a phase distribution tally, children listed beneath. | manual |
| AC8 | `rg` each phase agent/command for the two-segment reference rule; manual: run the lifecycle on a child by canonical ref and confirm artifacts land under the nested path with unchanged semantics. | shell + manual |
| AC9 | Manual: request `/spec` for a blocked child; agent refuses and names blockers; explicit override proceeds; no file is deleted. | manual |
| AC10 | `rg`/manual: no state file is written; `git status --porcelain` is unchanged after `/status`. | shell + manual |
| AC11 | `git diff` shows no change to standalone phase semantics; manual: create and advance a flat item; frontmatter has no `parent`. | shell + manual |
| AC12 | After `/roadmap`, `git status --porcelain` shows no tracked source change and no child phase artifact exists. | shell |
| AC13 | README counts (`14 role prompts`, `12 slash commands`) match `ls`; `roadmap` appears in README and AGENTS.md; `/doctor` prints the clean line. | shell + manual |
| AC14 | Manual: a single-feature request recommends `/spec`; a vague request records assumptions/open questions and invents no scope. | manual |
| AC15 | T10 removes/renames a child ref; `/status` reports `DANGLING-DEP`/`MISSING-CHILD`/`UNLISTED-CHILD` without failing. | manual |

Manual criteria are justified: the roadmap and status behaviors are LLM-driven
prompts, which this repo cannot exercise from a CI runner. Residual risk is
recorded in `verify.md`.
