---
feature: 0011-recursive-bootstrap/0001-recursive-model
phase: review
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Review — Recursive lifecycle model

## Verdict

**approve** — The diff authors the required `## The recursive lifecycle model`
section, the `## Roadmaps` deferral note, and the `AGENTS.md` /
`template/AGENTS.md` cross-reference exactly as `design.md` specifies; every
acceptance criterion AC1–AC11 is met within the item's mandated surfaces, and no
defect survives scrutiny. The one judgment point (`roadmap` is still defined
first-class on other documents) sits only on surfaces the spec's non-goals and
the parent roadmap explicitly assign to `0002-recursive-schema` and successor
Roadmaps 2 and 4, so it is residual risk, not a finding against this item.

## Findings

None. No Blocker, Major, Minor, or Nit survived scrutiny.

## Base and change set

Commands run (read-only):

- `git merge-base HEAD origin/main` → `b3214e6fba17b83b7cce7ebaa728d077893350f2`
- `git diff b3214e6...HEAD --stat` → empty. `HEAD` equals the merge base: the
  plan (`spec.md`/`design.md`/`tasks.md`) was already merged to `origin/main`
  through PR #52 (merge `3afe4df`).
- `git diff` → the tracked build output (uncommitted, since the builder never
  commits).
- `git status --porcelain` → tracked modifications plus untracked artifacts.

The reviewed change set is therefore the working tree, not a committed range:

| File | Δ | What |
| ---- | - | ---- |
| `docs/workflow.md` | +87/−0 | new `## The recursive lifecycle model` section (lines 28–109) and the `## Roadmaps` deferral note (lines 147–149) |
| `AGENTS.md` | +5/−0 | one cross-reference paragraph (lines 75–78) |
| `template/AGENTS.md` | +5/−0 | byte-identical mirror of the `AGENTS.md` paragraph (lines 77–80) |
| `work/0011-recursive-bootstrap/0001-recursive-model/tasks.md` | 12 boxes | `[ ]` → `[x]`, no other edit |

All three code-file edits are pure additions (`git diff --numstat` `87/0`,
`5/0`, `5/0`); no shipped line is rewritten. No file outside the design's
"Affected areas" is touched, and no new agent, command, skill, or test file is
added.

## Acceptance criteria

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 uniform six-phase cycle; node/leaf/decomposition defined | met | `docs/workflow.md:33` "the same six-phase cycle applies **uniformly at every node**"; `:43` node ("any work item in a recursive plan tree"); `:46` leaf ("a node with no children"); `:48` decomposition ("a node's enumerated child set") |
| AC2 no maximum depth; standalone and nested are instances | met | `docs/workflow.md:60` "imposes **no maximum recursion depth**: any node may decompose into children"; `:61–63` "A one-segment standalone item (`NNNN-slug`) and a nested child (`NNNN-slug/MMMM-slug`) are valid instances of the same model" |
| AC3 authoring in the planning step; `/roadmap` alias; committed plan state; `0003` pointer | met | `docs/workflow.md:68` "authored and recorded in the planning (design) step — the `/plan` (`architect`) step"; `:69` "`/roadmap` command is retained only as a **deprecated alias** for that step"; `:70` "**committed plan state**"; `:72–74` "owned by `0003-recursive-writer`" |
| AC4 hybrid granularity; `tasks.md` entries are not nodes | met | `docs/workflow.md:78` "**hybrid** of tasks, features, initiatives, and larger items"; `:79–81` "`tasks.md` entries remain a leaf's internal work list and are **not** nodes … never by promoting a task" |
| AC5 own artifacts + children; cycle applies independently; no pure-container requirement | met | `docs/workflow.md:81–84` "may carry its own phase artifacts and a child set at the same time … independently of its children … no node is required to be a pure container" |
| AC6 five terms stated once; `roadmap` only a deprecated alias | met (scoped) | `docs/workflow.md:41` work item, `:43` node, `:46` leaf, `:48` decomposition, `:50` plan; `:53` "`roadmap` is a **deprecated alias** for a decomposing node"; `:30` claims single authority; `## Roadmaps` deferral note at `:147–149` removes the competing definition **in the workflow authority**. See "Residual risk" for the surfaces the spec defers. |
| AC7 per-node composition with shipped backtracking; no second model/phase/reversal | met | `docs/workflow.md:88–94` "per node, on the same unshipped work item: the reverse edges, `stale:` marking, re-entry, recall, and the ownership invariant are reused unchanged … no second state model, no new `phase` value, and no new reversal mechanism" |
| AC8 readiness / declared-conflict reuse; no new edge/class/state | met | `docs/workflow.md:96–104` "reused unchanged: the model adds no dependency edge, conflict class, or state vocabulary"; names `### Dependencies and readiness` and `### Declared conflicts (conflicts-with)`; assigns ownership to `0004`/`0002` |
| AC9 backward compatibility; no forced migration | met | `docs/workflow.md:106–109` "behaves exactly as before with no forced migration … existing committed `work/` content … remains valid under the model"; `## Roadmaps` retained |
| AC10 workflow authority states it once; `AGENTS.md` cross-references; no conflicting recursive rule | met | `docs/workflow.md:28` section present; `AGENTS.md:75–78` and `template/AGENTS.md:77–80` cross-reference the authority and name `roadmap` the deprecated alias; both bodies updated identically |
| AC11 suite green; no new command/agent/skill; no inventory or contract change | met | Diff is additions-only docs plus box ticks; no tracked or untracked non-`work/` file added (`git status`); unaffected command/`phase`/readiness/declaration text; `verify.md` records `bash tests/run.sh` → 489 passed / 0 failed. Static audit of the suite below. |

### Edge cases

| Edge case | Where addressed | Result |
| --------- | --------------- | ------ |
| Leaf is a valid terminal | `docs/workflow.md:46–47` | met |
| Pure container | `:83–84`; `## Roadmaps` retains the concrete container spelling | met |
| Own artifacts, no children | `:41–42` every directory is a work item / instance | met |
| Deep chain | `:59–64` no maximum depth; "Depth changes no node's phase semantics" | met |
| Self-containment / acyclic tree | implicit in "recursive plan tree" (`:43`) and "may nest without limit" (`:61`); explicit recursive cycle detection is deferred by the spec's non-goal | met-by-implication; no defect |
| Thick hybrid | `:81–83` | met |
| Task mistaken for a node | `:79–81` | met |
| Backtrack on a decomposing node | `:91–92` "takes the same reverse edge to the planning step" | met |
| Shipped node excluded | `:89` "on the same unshipped work item"; shipped exclusion referenced, not restated | met |
| Historical roadmap parent | `:53–55`, `:107–109` | met |
| Parallel nodes | `:70–71`, `:96–97` | met |
| No convergence requirement | `:59–60` sets no max and imposes no min | met |

## Test audit (AC11)

I could not execute the suite: this review environment's bash allowlist denies
arbitrary command execution, so `bash tests/run.sh` was not run by me. AC11's
"suite green" rests on `verify.md`'s recorded run (489/0) plus the static audit
below. Every extractor that reads `docs/workflow.md` was checked against the new
text:

- `tests/checks/96-signature-sweep.sh:100–107` extracts phase headings with
  `^### [0-9]+[.] `. The new section is a `##` heading and its `###` subsections
  (`Terms`, `The cycle applies at every node`, `Where decomposition is authored
  and recorded`, `Granularity and hybrid nodes`, `Composition with the shipped
  model`) do not match — no phantom signature is emitted (design's stated risk
  avoided). `extract_wf_visual` scopes to `## Routing heuristics`; unaffected.
- `tests/checks/10-readiness.sh:23` requires `satisfied(dep_local_id):` exactly
  once, in `$WF`. The new section does not contain it, and the `## Roadmaps`
  body is untouched below the inserted note — still exactly once.
- `tests/checks/85-conflict-guards.sh:569–597` extracts only the
  `## Declared-conflict check` section; the new section is outside it, and it
  adds no `(e)`/`DECLARED-`/`PLAN-`/`CONFLICT-` token.
- `tests/checks/87-backtrack-guards.sh:255–262,975–986` pins reverse-edge table
  rows and derived-state literals in `$WF`; the new section restates none of the
  pinned strings and leaves the pinned sections intact.
- `tests/checks/20-lifecycle.sh`, `80-cycle-fixture.sh`, `95-split-guard.sh`,
  `50-instructions.sh`, `40-inventory.sh`, `90-packaging.sh`: all extract from
  scoped headings (`## Children`, `## Project profile`, `## Layout`, `## Agents`,
  the six-command tables) that this diff does not move or duplicate.
- `tests/checks/95-split-guard.sh:296–315` requires `AGENTS.md` and
  `template/AGENTS.md` to be byte-identical outside `## Project profile`; both
  received the identical paragraph at the same position, so body parity holds.

## Security, error handling, performance

- **Secrets:** none introduced; the diff is Markdown prose, no credentials, no
  `.env`, no debug output.
- **Error handling:** not applicable — documentation only.
- **Performance:** the new 87-line section is added to an always-loaded file,
  but it is terse, normative, and composed by reference (the design's mitigation
  for bloat); no hot-path or runtime impact exists.
- **Convention fit:** the section follows the repository's documentation voice,
  uses `##`/`###` headings as the design mandates, attributes ownership by
  canonical reference (`0002`/`0003`/`0004`), and does not restate single-source
  contracts.

## Scope

- No scope creep: five tasks, all docs, no unrelated refactor, reformat, or
  dependency.
- The declared `conflicts-with: "docs/workflow.md, AGENTS.md"` equals the parent
  `Children` row's cell (`work/0011-recursive-bootstrap/roadmap.md:103`), so the
  child's union set does not trigger a `DRIFT-FACT`. `template/AGENTS.md` is an
  undeclared mechanical mirror, deliberately so (declaring a set unequal to the
  parent cell would itself be drift) — as documented in `design.md`.
- The untracked `work/0010-*`, `work/0011-recursive-bootstrap/roadmap.md`, and
  `work/0011-recursive-bootstrap/000{2,3,4}-*` directories are other items'
  committed-later state (per the plan-publication convention recorded in commit
  `b3214e6`), not part of this item's build.

## Residual risk / not reviewed

- **Competing `roadmap` definitions remain on deferred surfaces.**
  `docs/artifact-conventions.md` ("A **roadmap** is a parent work item …", "A
  roadmap is the first-class planning artifact …") and
  `.opencode/skill/workflow-lifecycle/SKILL.md:22` still present `roadmap` as a
  first-class concept with no deprecation note. This is **not** recorded as a
  finding because the spec's non-goals defer "Deprecating or removing `/roadmap`
  and `roadmap.md`" and "the agent/command/inventory surface sweep" to successor
  roadmaps, and the parent roadmap assigns the `docs/artifact-conventions.md`
  update to `0002-recursive-schema` (`roadmap.md:104`) and the skill/agent sweep
  to Roadmap 4 (`roadmap.md:140–142`). Editing those files here would collide
  with `0002`/Roadmap 4. `verify.md` flags the same point; this review agrees.
- **No committed guard for the new section.** Verification is review-plus-grep
  only; a future silent rewrite of the section would not be caught by
  `bash tests/run.sh`. This is the design's and the spec's explicit choice
  ("Committed fixtures, agreement areas, and mutation coverage pinning the model
  — a successor roadmap"), so it is a deferred follow-up, not a defect here.
- **Suite not executed by the reviewer** (bash restricted to read-only git/ls/
  cat). AC11 relies on `verify.md`'s recorded 489/0 run and the static extractor
  audit above.
- **`## Mental model` also characterizes "work item"** (`docs/workflow.md:10`)
  alongside the new authoritative definition at `:41`. The two are consistent
  (the mental-model prose is the single-level framing the model generalizes and
  is pre-existing), so it is not treated as a competing definition under AC6.
