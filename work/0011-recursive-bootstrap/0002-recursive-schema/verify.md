---
feature: 0011-recursive-bootstrap/0002-recursive-schema
phase: test
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
notes: "Documentation-only item. Per spec non-goals the committed suite stays green as a constraint, not a deliverable, and committed fixtures/guards pinning the recursive schema are deferred to a successor roadmap — so no test file was added. Content criteria are verified by read-only grep over the authored surfaces plus the existing committed suite for the pinned single-source guards."
---

# Verification — Recursive work-item schema, references, and sequence allocation

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 489 passed, 0 failed, 0 skipped` — full committed suite baseline |
| `FRAMEWORK_TEST_AREAS='10-readiness,20-lifecycle,40-inventory,80-cycle-fixture,85-conflict-guards,87-backtrack-guards,96-signature-sweep' bash tests/run.sh` | PASS | `TOTAL: 364 passed, 0 failed, 0 skipped` — the single-source guards named by the spec/design |
| `FRAMEWORK_TEST_AREAS='80-cycle-fixture' bash tests/run.sh` | PASS | 15 passed, 0 failed (six-column `Children` header, `CYCLIC-DEP`) |
| `FRAMEWORK_TEST_AREAS='85-conflict-guards' bash tests/run.sh` | PASS | 43 passed, 0 failed (conflict declaration/vocabulary grammar) |
| `FRAMEWORK_TEST_AREAS='87-backtrack-guards' bash tests/run.sh` | PASS | 103 passed, 0 failed (pinned `stale:`/`reopened:`/record literals) |
| `FRAMEWORK_TEST_AREAS='96-signature-sweep' bash tests/run.sh` | PASS | 90 passed, 0 failed (command signatures, phase headings, no new `### <n>.`) |
| `FRAMEWORK_TEST_AREAS='40-inventory' bash tests/run.sh` | PASS | 41 passed, 0 failed (documented inventory counts equal disk) |
| `git diff --name-only -- ':!work/**'` | ONLY 2 FILES | `docs/artifact-conventions.md`, `docs/workflow.md` |
| `git status --porcelain -- .opencode` | EMPTY | no new/changed agent, command, or skill |
| regex sample check (below) | PASS | recursive regex accepts any-depth paths; rejects trailing slash / empty segment / non-conforming |

No test file was added. This is deliberate and spec-directed: the spec's
non-goals defer committed fixtures/agreement areas and mutation coverage pinning
the recursive schema to a successor roadmap, and state the committed suite stays
green as a constraint, not a deliverable. Adding a guard here would exceed the
item's scope. The content criteria are therefore verified by read-only review
commands, recorded per criterion below.

### Regex sample check

The recursive regex authored in `docs/artifact-conventions.md:85` was executed
against representative references (throwaway shell check, no file written):

```
REF='^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$'
VALID   : 0001-a
VALID   : 0002-billing/0001-model
VALID   : 0002-billing/0001-model/0003-deep   # depth 3
INVALID : billing/0001-x                       # no leading NNNN
INVALID : 0001-a/                              # trailing slash
INVALID : 0001-a//0002-b                       # empty segment
INVALID : 0001-a/000                           # non-conforming segment
INVALID : /0001-a                              # leading empty segment
INVALID : 0001-A                               # uppercase
```

This confirms the grammar is genuinely recursive (depth 3 accepted) and that the
malformed-reference edge case is excluded by the stated grammar.

## Acceptance coverage

`AC` = acceptance criterion in `work/0011-recursive-bootstrap/0002-recursive-schema/spec.md`.
`grep` evidence is read-only review of the authored surfaces (docs), which the
spec names as the deliverable; behavior is documentation content, not runtime.

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 — recursive canonical reference; one-segment unchanged; two-segment a special case | `docs/artifact-conventions.md:75-97` (grammar `item-ref ::= NNNN-slug ( "/" MMMM-slug )*`, regex `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`, "**special case** … not a maximum depth"); `docs/workflow.md:138-144` restatement defers to "Work item references"; old two-level grammar/regex absent (`grep` for `item-ref ::= standalone \| child` and `(...)?$` → none) | PASS |
| AC2 — resolve by following nested segments; `feature:`/`parent:` shape | `docs/artifact-conventions.md:33-38` (`feature` = full canonical reference at any depth), `:92-95` (resolves to `work/<item-ref>/` by segments; depth-3 example), `:106-110` (nested children set `feature`/`parent`); `docs/workflow.md:138-144` | PASS |
| AC3 — per-level `MMMM` scoped to immediate parent at every depth | `docs/artifact-conventions.md:670-676` ("Every further level allocates its own children's `MMMM` the same way, scoped to its **immediate** parent … arbitrary depth … never reused within that parent"); top-level `NNNN` rule at `:659-668` unchanged | PASS |
| AC4 — `parent:` names immediate parent; one segment at depth 2, full ref at depth ≥3; chain derivable from path; standalone omits | `docs/artifact-conventions.md:24` (template comment), `:35-40` (rules bullet: "one segment (`<NNNN-slug>`) at depth two, and the parent's full multi-segment reference at depth three or deeper … derivable from the directory path … Standalone items omit it"), `:106-110` | PASS |
| AC5 — manifest = generic enumeration source; `roadmap.md`/`phase: roadmap` at every depth; no new file/`phase`/presence row | `docs/artifact-conventions.md:119-132` ("A **manifest** is the child-enumeration artifact of any node that decomposes … generic … **at every depth** … shipped concrete spelling is `roadmap.md` with `phase: roadmap` at **every** depth; no new file name, `phase` value, or artifact-presence row"); `phase:` value set unchanged (`git diff` untouched) | PASS |
| AC6 — six-column positional `Children` header preserved (`Depends on` field 5, `conflicts-with` field 6); canonical ref resolves to child dir; `Depends on` sibling-only and acyclic | `docs/artifact-conventions.md:155` header byte-identical; `:178-193` `Local id`/`Canonical reference`/`Depends on` bullets; `80-cycle-fixture` (15/15) and `85-conflict-guards` (43/43) green | PASS |
| AC7 — `conflicts-with` grammar preserved unchanged; depth-generalization deferred | `docs/artifact-conventions.md:194-199` (points to the shipped grammar; deferral sentence to the successor roadmap); `docs/workflow.md` `## Declared conflicts (conflicts-with)` section **untouched** (`git diff` shows only `## The work item directory`); `85-conflict-guards` green | PASS |
| AC8 — each child directory reserved with `.gitkeep` at every depth | `docs/artifact-conventions.md:186-188` ("**Child reservation** — each child directory is reserved with a `.gitkeep` at that level (`work/<parent-ref>/<MMMM-slug>/.gitkeep`), at every depth, not only the top level") | PASS |
| AC9 — backward compatible; no forced migration; no second grammar/state model/edge/conflict class | `docs/artifact-conventions.md:96-97` (one-segment unchanged; two-segment special case) and `:102-104` (one-segment behaves exactly as before); `80-cycle-fixture` green (existing `work/` layout valid); no new grammar introduced (regex grep) | PASS |
| AC10 — configured test command passes; no new command/agent/skill; inventory counts unchanged; six phase commands and `phase` set and `Children`/`conflicts-with`/readiness contracts unchanged | `bash tests/run.sh` → 489 passed / 0 failed; `40-inventory`, `20-lifecycle`, `10-readiness`, `80-cycle-fixture`, `85-conflict-guards`, `96-signature-sweep` all green; `git status --porcelain -- .opencode` empty (14 agents / 13 commands / 11 skills unchanged) | PASS |
| AC11 — schema in `docs/artifact-conventions.md`; minimal `docs/workflow.md` restatements consistent; writer/readiness/status/migration surfaces untouched; no competing grammar/manifest | `git diff --name-only -- ':!work/**'` = exactly `docs/artifact-conventions.md`, `docs/workflow.md`; `docs/workflow.md` diff confined to `## The work item directory` (layout note `:131-132` + canonical-reference bullet `:138-144`); `## Roadmaps`, readiness/derived-state/backtrack authorities byte-untouched; no second reference grammar (`grep` for the old two-level-only regex → only the untouched conflict-target `SiblingOrItemRef` in `docs/workflow.md:263`, which is the shipped grammar AC7 preserves) | PASS |

## Edge-case coverage

| Edge case (spec) | Evidence | Result |
| ---------------- | -------- | ------ |
| Deep chain (depth ≥3) | `docs/artifact-conventions.md:95` depth-3 example; `:670-674` per-level allocation; regex sample check accepts a 3-segment path | PASS |
| One-segment standalone item | `docs/artifact-conventions.md:96-97`, `:102-104`; `:35-40` standalone omits `parent` | PASS |
| Existing two-level roadmap parent/child | `docs/artifact-conventions.md:96-97`; `80-cycle-fixture` green | PASS |
| Hybrid node (own artifacts + manifest) | `docs/artifact-conventions.md:123-128` ("a node that carries a manifest alongside its own phase artifacts … a hybrid node may carry both at once") | PASS |
| `.gitkeep`-only child representable at any depth | `docs/artifact-conventions.md:186-188` | PASS |
| Repeated local id text at different levels = distinct nodes | identity is the full canonical path: `docs/artifact-conventions.md:181-185` + `:87-90` (each `MMMM` local to its immediate parent) | PASS |
| Bare local id resolution sibling-first | `docs/artifact-conventions.md:189-193` (`Depends on` names only sibling local ids in the same table); shipped `conflicts-with` precedence in `docs/workflow.md` untouched | PASS |
| Malformed recursive reference (trailing slash / empty / non-conforming) | regex sample check above; grammar stated at `docs/artifact-conventions.md:79-85` | PASS (via grammar; no explicit prose sentence) |
| `conflicts-with` target deeper than two segments | explicitly out of scope; deferred at `docs/artifact-conventions.md:197-199` and AC7 | PASS (deferred as documented) |
| Per-parent exhaustion/collision | `docs/artifact-conventions.md:670-676` (greatest-ever-plus-one, never reused); cross-branch recursive duplicate detection is deferred (unchanged `### Renumbering after a parallel merge`) | PASS |
| Shipped node out of scope for re-scope/re-sequence | shipped backtracking/roadmap-revision model in `docs/workflow.md` untouched by the diff | PASS |

## Gaps and residual risk

- **No committed guard pins the recursive schema.** Intentional and spec-directed
  (non-goals defer committed fixtures/agreement areas and mutation coverage to a
  successor roadmap). The recursive grammar, allocation, `parent` chain, manifest
  wording, `.gitkeep` rule, and the AC7 deferral are therefore verified by review
  only and could regress silently until the successor roadmap adds fixtures.
  This is a documented scope boundary, not a defect.
- **Malformed-reference edge case is covered only implicitly.** The authored
  `## Work item references` section states the grammar and regex but does not add
  the design's explicit sentence "a trailing slash, an empty segment, or a
  non-conforming segment is not a valid reference." The stated regex excludes all
  such forms (verified above), so AC1 is met; only the prose is more terse than
  the design's interface note. Low risk; noted for the successor guard work.
- **Other `.opencode`/`README`/skill surfaces still describe the two-level form**
  (e.g. `.opencode/agent/*.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`,
  `README.md`). The spec explicitly defers the agent/command/inventory surface
  sweep to a successor roadmap (Roadmap 4), so this is expected and not a
  competing grammar introduced by this item; those surfaces predate the change
  and were not edited.
- **No defect found.** The implementation satisfies AC1–AC11 and the edge-case
  set; the full committed suite (489 assertions) is green and every pinned
  single-source guard stayed green without being edited.
- No `challenges.md` exists for this item; no challenge requires adjudication.
- No `visual.md` pass: the item is documentation-only and has no user-facing UI.
