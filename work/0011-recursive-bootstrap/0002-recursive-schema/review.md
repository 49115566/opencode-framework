---
feature: 0011-recursive-bootstrap/0002-recursive-schema
phase: review
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Review — Recursive work-item schema, references, and sequence allocation

## Verdict

**approve** — the diff generalizes the two-level schema in place to a recursive
path in its single authority, satisfies AC1–AC11, introduces no new file name,
`phase` value, artifact-presence row, command, agent, skill, or count, and no
finding of any severity survives; the two findings raised on the previous review
pass are resolved.

## Base and diff

Commands run (read-only):

- `git merge-base HEAD origin/main` → `7cf012d614f6cdedb5f75a04232e732049d9ac53`
- `git rev-parse HEAD` → `7cf012d614f6cdedb5f75a04232e732049d9ac53`
- `git rev-parse origin/main` → `4a74bb9f78e23c041288e365bbb144693e72ec27`
- `git log --oneline -12` → HEAD is `docs(plan): record plan for
  0011-recursive-bootstrap/0002-recursive-schema` (the plan commit already on
  `origin/main` as PR #54). The base **is** HEAD, so the build change is
  uncommitted working-tree state.
- `git status` → modified `docs/artifact-conventions.md`, `docs/workflow.md`,
  `work/0011-recursive-bootstrap/0002-recursive-schema/tasks.md`; untracked
  `verify.md`, `review.md`, `.gitkeep`, the parent `roadmap.md`, and the
  `0003`/`0004`/`0010` scaffolds.
- Reviewed range: `git diff` (base → working tree) plus the untracked
  `verify.md` and the parent `work/0011-recursive-bootstrap/roadmap.md`.

Scope: `git diff --stat` → `docs/artifact-conventions.md` (120 lines changed),
`docs/workflow.md` (14), `tasks.md` (12, the six task-box ticks). No source,
test, agent, command, or skill file changed; `.opencode` is untouched.

This is a re-review: `docs/artifact-conventions.md` was modified at
21:22 (after `review.md` at 21:20), and that later edit resolves the previous
pass's `M1` and `N1`.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — recursive canonical reference; one-segment unchanged; two-segment a special case | met | `docs/artifact-conventions.md:75-100`: `item-ref ::= NNNN-slug ( "/" MMMM-slug )*`, regex `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`, and "the two-segment form is a **special case** of the recursive path, not a maximum depth". The old two-level grammar/regex are gone (diff removes `standalone \| child` and `(...)?$`). |
| AC2 — resolve by segments; `feature:`/`parent:` shape | met | `docs/artifact-conventions.md:95-98` (resolves `work/<item-ref>/` by segments, depth-3 example), `:33-36` (`feature` = full canonical reference at any depth), `:111-115` (nested child sets `feature` and `parent`). `docs/workflow.md:138-144` defers to "Work item references". |
| AC3 — per-level `MMMM` scoped to immediate parent at every depth | met | `docs/artifact-conventions.md:675-681` ("Every further level allocates its own children's `MMMM` the same way, scoped to its **immediate** parent, so allocation applies per level to arbitrary depth"); top-level `NNNN` rule `:664-673` unchanged. |
| AC4 — `parent:` immediate parent; depth-2 vs depth-≥3; chain derivable; standalone omits | met | `docs/artifact-conventions.md:25` (template comment), `:37-41` (rules bullet), `:111-115`. |
| AC5 — generic manifest; `roadmap.md`/`phase: roadmap` at every depth; no new file/`phase`/row | met | `docs/artifact-conventions.md:124-137`: manifest is the generic enumeration source "**at every depth**", spelling `roadmap.md` with `phase: roadmap`, "no new file name, `phase` value, or artifact-presence row". The earlier contradictory bullet is qualified at `:101-106`. |
| AC6 — six-column positional header preserved; canonical ref resolves; `Depends on` sibling-only/acyclic | met | `docs/artifact-conventions.md:160` header byte-identical (`Depends on` field 5, `conflicts-with` field 6); bullets `:186-198`. `tests/checks/80-cycle-fixture.sh:31` and `85-conflict-guards.sh:382-401` pins statically unaffected. |
| AC7 — `conflicts-with` grammar preserved; depth-generalization deferred | met | `docs/artifact-conventions.md:199-204` keeps the shipped grammar reference and adds the deferral sentence; the `docs/workflow.md` `## Declared conflicts (conflicts-with)` section is untouched (diff confined to `## The work item directory`). |
| AC8 — `.gitkeep` reservation at every depth | met | `docs/artifact-conventions.md:191-193` (`work/<parent-ref>/<MMMM-slug>/.gitkeep`, "at every depth, not only the top level"). |
| AC9 — backward compatible; no forced migration; no second grammar/state model/edge/class | met | `docs/artifact-conventions.md:99-100`, `:107-109`; the two-segment form is a special case, so no existing reference changes meaning. |
| AC10 — configured test command passes; no new command/agent/skill; inventory/contracts unchanged | met | `verify.md:17-24` records `bash tests/run.sh` → `489 passed, 0 failed, 0 skipped`, plus the area-scoped runs. `git status` shows no `.opencode`/`tests`/`README` change, so no inventory count, command signature, or `phase` surface moved. Not independently re-executed (see "Not reviewed"). |
| AC11 — schema in `docs/artifact-conventions.md`; minimal `docs/workflow.md` restatements; no competing grammar/manifest | met (within scope) | `git diff --name-only` = the two docs plus the item's `tasks.md`; the `docs/workflow.md` diff is confined to `## The work item directory` (`:131-132` layout note, `:138-144` reference bullet). The pre-existing two-level references in README/agents/skills are the deferred surface sweep (Roadmap 4), not introduced here. |

## Findings

### Blockers

- none.

### Major

- none.

### Minor

- none. The previous pass's `M1` (the `docs/artifact-conventions.md` bullet
  asserting a decomposing parent holds *only* `roadmap.md`, contradicting the
  hybrid node) is resolved at `:101-106`, which now reads "A pure roadmap parent
  holds only `roadmap.md`; a node that also runs its own lifecycle holds the
  manifest alongside its own phase artifacts".

### Nits

- none. The previous pass's `N1` (the malformed-reference rule stated only by the
  grammar) is resolved at `docs/artifact-conventions.md:87-88`: "A trailing
  slash, an empty segment, or a non-conforming segment is not a valid reference
  and is not treated as one."

## Questions

- **Is the parent `0011-recursive-bootstrap/roadmap.md` staged by a separate
  step?** The item's `spec.md:234-238` and `design.md:235-240` cite
  `work/0011-recursive-bootstrap/roadmap.md:104` for the dependency and the
  declared-conflict cell, but that file is untracked in this working tree and
  absent from `HEAD` (`git show HEAD:work/0011-recursive-bootstrap/roadmap.md` →
  "exists on disk, but not in 'HEAD'"). The on-disk parent holds the matching
  `conflicts-with` cell (`docs/artifact-conventions.md, docs/workflow.md,
  tests/checks/80-cycle-fixture.sh`, identical to `design.md:7`), so the
  declared-conflict check reports no `DRIFT-FACT`. This is outside this item's
  diff and likely owned by the parent item — recorded as a question, not a
  finding. Confirm before `/ship` that the shipper stages only this item's
  directory and does not fold in the untracked `0003`/`0004`/`0010` scaffolds.

## Not reviewed

- The concrete recursive writer (`0003`), readiness/derived-state/`/status`
  (`0004`), roadmap deprecation/migration (Roadmap 2), `conflicts-with` at every
  level (Roadmap 3), the agent/command/inventory surface sweep (Roadmap 4), and
  committed recursive guards (Roadmap 5) — all explicitly deferred by the spec's
  non-goals and untouched by the diff.
- Independent execution of `bash tests/run.sh`: the read-only bash allowlist
  denies arbitrary program execution, so the AC10 result rests on `verify.md`'s
  recorded `489/0/0`. I instead statically audited the pinned single-source
  guards the change could disturb — `10-readiness.sh` (reads `$WF`/`$CONV`),
  `20-lifecycle.sh` (reads `$WF`), `40-inventory.sh` (reads `README.md`),
  `80-cycle-fixture.sh` (`$WF` `CYCLIC-DEP`/cycle literals),
  `85-conflict-guards.sh` (the `## Declared-conflict check` section),
  `87-backtrack-guards.sh` (the `$CONV`/`$WF` contract pins, all in untouched
  sections), and `96-signature-sweep.sh` (no new `### <n>. ` heading). No pinned
  literal is removed or altered, and the newly added prose contains none of the
  guards' forbidden negative-control tokens (`10-readiness`'s
  approved-but-unshipped contradiction pattern, `25-review-severity-bar`'s
  `Blocker or Major`/`not merge-blocking`/`the author may decline`/`waived`/
  `declined`). `docs/workflow.md` remains confined to `## The work item
  directory`.
- UI/visual pass: documentation-only item, no user-facing surface; no
  `visual.md` exists and none is expected.
- `challenges.md` does not exist for this item; no challenge required
  adjudication.
