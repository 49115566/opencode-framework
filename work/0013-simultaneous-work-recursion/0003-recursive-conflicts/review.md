---
feature: 0013-simultaneous-work-recursion/0003-recursive-conflicts
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Review — Recursive `conflicts-with` at every level

## Verdict

**approve** — the two authority documents generalize the declared-conflict grammar,
discriminator, compared set, resolution precedence, `own ∪ cell` union, and
`DRIFT-FACT` rule to arbitrary depth exactly as the spec requires; every acceptance
criterion is met, the prior `M1` narrowing is fixed in the working tree, and no
finding of any severity survives.

## Base ref and diff

The working tree carries the builder's uncommitted edits, which are the subject of
this review. Commands used:

- `git merge-base HEAD origin/main` → `85189569c55b55b7f1a1ac7b19a50316f9e5e74a0b8`, equal to `HEAD` and `origin/main`; so the item has no committed divergence and the review range is the uncommitted working tree.
- `git status --short` → `M docs/artifact-conventions.md`, `M docs/workflow.md`, `M work/0013-simultaneous-work-recursion/0003-recursive-conflicts/tasks.md`, `?? .../verify.md`, `?? .../review.md`.
- `git diff -- docs/workflow.md`
- `git diff -- docs/artifact-conventions.md`
- `git diff -- work/0013-simultaneous-work-recursion/0003-recursive-conflicts/tasks.md`
- `git diff --stat` → 3 files, 76 insertions, 62 deletions.

The code diff is the two authority-document edits plus the `tasks.md` check-box
flips; `verify.md` is the new test artifact. This matches the spec's docs-only
scope. `tests/checks/85-conflict-guards.sh` and `tests/fixtures/declared-conflicts/`
are untouched, as `git status` confirms.

There is no `challenges.md` for this item, so no open challenge required
adjudication before ordinary forward work.

## Acceptance criteria

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 — arbitrary-depth references well-formed | met | `docs/workflow.md:286` — `SiblingOrItemRef ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )*`; the old trailing `?` is gone (grep for `)?` in `docs/` returns none). |
| AC2 — discriminator recognizes arbitrary depth | met | `docs/workflow.md:307` — `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`. |
| AC3 — compared set recurses | met | `docs/workflow.md:763-768` — a node's rows are entities keyed by full canonical reference and a row whose child dir holds a manifest (`manifest.md` or legacy `roadmap.md`) is "also a decomposition whose rows are recursed the same way — to arbitrary depth". |
| AC4 — entity kinds at depth | met | `docs/workflow.md:771-785` — child entity incl. `.gitkeep`-only, nested decomposing child both entity and recursed, standalone `spec.md` item with no manifest. |
| AC5 — bare-token precedence = immediate parent then root | met | `docs/workflow.md:310-315` — "**declaring entity's immediate parent's `Children` table first, then `work/<token>/` at the repository root**", with the explicit no-parent root-only fallback. |
| AC6 — multi-segment root-relative | met | `docs/workflow.md:309-310` and `:296-298` — "A reference containing `/` is **root-relative**"; resolves from the repository root independent of the declaring node. |
| AC7 — cross-level naming permitted; distinct resolutions distinct | met | `docs/workflow.md:296-299` (ancestor/descendant/different subtree) and `:815-817` (equal tokens resolving to different items are not the same target). |
| AC8 — `own ∪ cell` union at depth | met | `docs/workflow.md:778` — "The child's declared set is `own ∪ cell`, at every depth." |
| AC9 — `DRIFT-FACT` at depth | met | `docs/workflow.md:779-782` (both-present-unequal, one-sided is union) and the findings table row `:844` ("immediate parent's cell disagree"). |
| AC10 — pair predicate between any two unshipped entities | met | `docs/workflow.md:809-823` — "any two **unshipped entities at any depth**"; one-sided naming of a silent counterpart; one finding per pair (`:825`). |
| AC11 — shipped handling unchanged | met | `docs/workflow.md:773-774`, `:791-793` — still **resolves** as a target but is excluded as a counterpart; no new `reopened`/`recalled` handling introduced. |
| AC12 — malformed/unresolved at depth reported | met | `docs/workflow.md:303-305` (empty/whitespace malformed), `:299-300` (no glob/`..`/absolute), `:316-318` (self-reference, repeated target), `:319-322`/`:802-805` (`DANGLING-DEP`, never dropped/auto-repaired). |
| AC13 — no new vocabulary | met | grep of `docs/workflow.md` for `(e)`, `DECLARED-`, `PLAN-`, `CONFLICT-` → **none**; codes/classes/finding-line grammar retained (`:832-844`). |
| AC14 — advisory, read-only, no readiness effect | met | `docs/workflow.md:851-860` — offline/local/read-only, no lock, modifies no file, no readiness edge; `:740-744` unchanged. |
| AC15 — backward compat + green suite + guard/fixture unchanged | met (suite result accepted from `verify.md`; not independently re-run) | Guard/fixture byte-unchanged per `git status`. `?`→`*` is a strict superset. The only live-authority assertions in `tests/checks/85-conflict-guards.sh:592-620` are the vocabulary checks, verified by inspection against the edited section. `bash tests/run.sh` (`495/0/0`) is accepted from `verify.md`. |
| AC16 — empty compared set is a no-op | met | `docs/workflow.md:875-876`. |
| AC17 — authority states the recursive contract; deferral removed | met | `docs/workflow.md` grammar/discriminator/compared set as above; `docs/artifact-conventions.md:204-211` no longer defers and references the recursive grammar (`NNNN-slug(/MMMM-slug)*`); `grep -F 'deferred to the successor' docs/artifact-conventions.md` → none. |

### Guard interaction (AC13/AC15)

`tests/checks/85-conflict-guards.sh:592-620` extracts the live
`## Declared-conflict check` section (lines 746–877, up to the next `## `) and
asserts the finding-line grammar, the three codes, classes `(a)`/`(b)`/`(d)`, and
the absence of `(e)`, `DECLARED-`, `PLAN-`, `CONFLICT-`. The edited section states
the exact grammar string and all three codes/classes, and a repository-wide search
finds none of the forbidden literals anywhere in `docs/workflow.md`. The guard's
fixture-scoped resolver (its own two-segment regex at `:173`) and fixtures are
unchanged, so its expected blocks are unaffected. No other committed check greps
the edited phrases: the only committed test reading `docs/workflow.md` conflict
text is `85-conflict-guards.sh`; `40-inventory.sh`, `96-signature-sweep.sh`, and
`87-backtrack-guards.sh` read unrelated surfaces, and the `tests/mutation.sh`
conflict jobs mutate fixture files and the `merge-conflict` skill, not the edited
authority lines. No operative surface (`.opencode/agent/status.md`,
`.opencode/command/{status,conflicts,build}.md`, `merge-conflict` skill) restates
the superseded two-level cap.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None. The prior review's `M1` (`docs/workflow.md:293` read "one or more nested",
  contradicting the `*`) is **fixed** in the current working tree: the live line now
  reads "optionally followed by nested `/<MMMM-slug>` segments", matching the `*`
  and the canonical-reference definition. No contradicting phrase remains
  (`grep -F 'one or more nested' docs/workflow.md` → none).

### Nits

- None.

## Not reviewed / out of scope

- `bash tests/run.sh` cannot be executed in this review sandbox (bash is restricted
  to the read-only git/ls/cat allowlist); AC15's suite result is accepted from
  `verify.md` and corroborated by inspection of the sole live-authority guard.
- The generic `NNNN-slug/MMMM-slug` shorthand repeated in phase agents/commands
  (e.g. `.opencode/agent/reviewer.md:63`) is a pre-existing simplification of the
  recursive canonical reference, not the declared-conflict grammar, and is outside
  this item's declared surfaces (`design.md:166-171` scopes it out).
- The `merge-conflict` skill and `status` agent restate the three planning-time
  finding meanings in summary form (`.opencode/skill/merge-conflict/SKILL.md:125-136`,
  `.opencode/agent/status.md:234-250`). They reference the authority and state no
  depth cap, so the untouched surfaces remain consistent with the generalized
  grammar; editing them is out of this item's declared scope.
