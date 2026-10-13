---
feature: 0011-recursive-bootstrap/0004-recursive-readiness
phase: review
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Review — Readiness, derived state, and status across recursion

## Verdict

**approve** — the diff generalizes readiness, derived state, and the `/status`
report in place to a recursive tree, satisfies AC1–AC11, preserves every literal
the committed suite pins, and introduces no new `phase` value, dependency edge
kind, state model, command, agent, skill, or inventory count; no finding of any
severity survives.

## Base and diff

No open challenge: `work/0011-recursive-bootstrap/0004-recursive-readiness/` holds
no `challenges.md`, so there was nothing to adjudicate before forward work.

Commands run (read-only):

- `git status` / `git status --porcelain` — branch `main`, up to date with
  `origin/main`; the implementation is **uncommitted working-tree state** plus one
  untracked artifact (`verify.md`).
- `git merge-base HEAD origin/main` → `2f92a2174492aab99ebd8ec2e8066de67fd98512`
- `git rev-parse HEAD` → `2f92a2174492aab99ebd8ec2e8066de67fd98512` (equal to
  `origin/main`; the plan commit for this item, `6d40620`, is already merged)
- `git rev-parse origin/main` → `2f92a2174492aab99ebd8ec2e8066de67fd98512`
- `git diff HEAD` and `git diff --name-only HEAD` — the full change set.

Base **is** HEAD, so the reviewed range is the uncommitted working tree. Tracked
files changed (outside `work/`): `docs/workflow.md`, `.opencode/agent/status.md`,
`.opencode/command/status.md`, `.opencode/skill/workflow-lifecycle/SKILL.md` —
exactly the four authorized surfaces. `tasks.md` carries only checkbox/date
updates; `verify.md` and the parent `roadmap.md` are untracked.

I did not execute `bash tests/run.sh`: my read-only guard forbids running
arbitrary programs. Instead I read every guard that pins a literal on the four
changed surfaces and verified each pinned literal by inspection (see "Suite
verification" below).

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — `Depends on` sibling-only at every depth; non-sibling → `DANGLING-DEP`, no new edge kind | met | `docs/workflow.md:172-182` states the manifest is the source "at every depth", dependencies are "**sibling-only**", and an ancestor/descendant/cousin/cross-tree target "is reported by the integrity window as a `DANGLING-DEP` finding rather than accepted, and no new dependency edge kind is introduced." |
| AC2 — same readiness rule applied independently at every level | met | `docs/workflow.md:184-186` ("Every decomposing node applies the same readiness rule to its own immediate children, independently at every level; a child resolves under the node's own canonical reference") and the algorithm's `child_dir = work/<node-ref>/<dep_local_id>/` (`:192`). `status.md:177-179`, `command/status.md:37-38` defer by name. |
| AC3 — decomposing dependency target satisfied by its own signal only | met | `docs/workflow.md:211-213` ("satisfied by its own signal only … its descendants are not consulted; readiness does not recurse through its children"). |
| AC4 — node with children derives own phase first; `roadmap` only for manifest + no own artifacts | met | `docs/workflow.md:1149-1156`; qualified row `:1163` ("`roadmap.md` present and no own phase artifacts (check before `spec.md`)"); closing paragraph `:1221-1227`; restated in `status.md:52-55`, `command/status.md:18-20`, `SKILL.md:63-66`. |
| AC5 — shipped precedence unchanged; no new `phase` value / second state model | met | `docs/workflow.md:1153-1156` names the order stale/reopened → open-challenge overlay → artifact-presence/verdict rows and "introduces no new `phase` value and no second state model"; the table rows `:1160-1173` keep their position. |
| AC6 — `/status` renders an arbitrary-depth indented tree; each node shows phase + `ready`/`blocked: <local ids>` | met | `docs/workflow.md:292-297`; `status.md:29-32, 163-165`; `command/status.md:47-51`. |
| AC7 — decomposing row shows `<ready>/<total> ready` + phase distribution over immediate children; blocked child names siblings; derived live, never stored | met | `docs/workflow.md:299-303`; `status.md:56-58, 160-162`; `command/status.md:47-51`. |
| AC8 — reuse shipped algorithm/labels/codes; no new vocabulary | met | The `satisfied(dep_local_id):` marker, recalled-`ship.md` revocation, `approve`-even-if-unshipped, `ship.md`-precedence, `CYCLIC-DEP`/`DANGLING-DEP`, and `P (backtracked)`/`P (reopened)`/`challenged (blocked)`/`build (rework)` are all retained unchanged. |
| AC9 — backward compatibility for one-segment and two-level items | met | The only changed table row still matches a pure container (`roadmap.md` present, no own artifacts → `roadmap`), a `.gitkeep`-only child stays `not started` (`:1225-1227`), and one-/two-level items carry no deeper tree. Every pinned derived-state/routing literal is retained (see below). |
| AC10 — stated once in the authority; status agent defers; only command + skill also updated; broad sweep deferred | met | Only the four authorized surfaces changed (above). The authority single-sources the rules; `status.md`/`command/status.md` reference `Dependencies and readiness`, `Derived state`, and `## Declared-conflict check` by name. The out-of-scope surfaces (`roadmap.md` agent/provider, README, etc.) are explicitly deferred to Roadmap 4. See the Question below on one orthogonal, pre-existing sentence. |
| AC11 — configured test command passes; no new command/agent/skill; no count change; marker + routing literals single-sourced | met | No README/inventory file touched; no new `.opencode/` file; `satisfied(dep_local_id):` occurs once, in `docs/workflow.md`; the routing/label literals are unchanged (static verification below). |

## Suite verification (static)

Because I could not run the suite, I checked every guard that pins a literal on a
changed surface:

- `tests/checks/10-readiness.sh`: marker `satisfied(dep_local_id):` occurs exactly
  once, in `docs/workflow.md:191`; absent from `.opencode/`; all three deferring
  surfaces still say `Dependencies and readiness`; `even if unshipped`,
  `presence is the sole shipped signal`, and `` `ship.md` presence takes
  precedence `` all present (`:196, 206, 208`); the contradiction phrase is absent.
- `tests/checks/80-cycle-fixture.sh`: `A child in a cycle is never \`ready\`` in
  `docs/workflow.md:219` and `status.md:192`; lowercase in `command/status.md:45`;
  `integrity findings rather than failing` (`:305`), `CYCLIC-DEP` (`:310`),
  `cycle members are never reported ready` (`:310`), `informational and never
  fatal` (`status.md:202`), and the flattened `members of a cycle are never
  reported` (`status.md:224`) all retained.
- `tests/checks/20-lifecycle.sh`: the seven derived-state routing literals, the
  six core commands, and the artifact names are untouched; the changed sections
  (`### Dependencies and readiness`, `### Status reporting`, `## Derived state`)
  add no `### <n>. ` phase heading.
- `tests/checks/87-backtrack-guards.sh`: `P (backtracked)`, `P (reopened)`,
  `challenged (blocked)`, `build (rework)`, `stale: design`, `stale: spec`,
  `finding | severity | acceptance-criterion`, `carrying a \`reopened:\` marker
  does not satisfy a`, and `forces no finding record or` are all present.
- `tests/checks/85-conflict-guards.sh`: the `## Declared-conflict check` section is
  untouched and `status.md`/`command/status.md` still reference it by name.
- `tests/checks/96-signature-sweep.sh` and `40-inventory.sh`: no command
  signature, inventory count, or README/`AGENTS.md` change.

I also confirmed the change set names exactly the four authorized files outside
`work/` and adds no test file.

## Findings

### Blockers

None.

### Major

None.

### Minor

None.

### Nits

None.

## Questions

- **Q1 — Pre-existing backtrack-vs-challenge precedence in the status agent is
  outside this item's change set, but AC10 touches it obliquely.** The authority
  states the `stale:`/`reopened:` structural derivations are evaluated *before*
  the challenged overlay (`docs/workflow.md:1153-1156`), and
  `tests/checks/87-backtrack-guards.sh:917-926` pins that a stale marker outranks
  an open challenge. `.opencode/agent/status.md:121-123` still says the opposite
  — "When a backtrack and a live challenge are both open, the blocked
  `challenged (blocked)` label wins the Phase column" — and `command/status.md`
  does not carry that sentence. This sentence is present at `HEAD` (I confirmed
  via `git show HEAD:.opencode/agent/status.md`) and was already surfaced as an
  open question in `work/0007-phase-backtracking/0006-status-and-derived-state/
  review.md:74-75`; the change under review neither introduces nor worsens it, and
  it concerns backtrack/challenge precedence rather than the recursive readiness
  or derived-state rules this item generalizes. I therefore do not classify it as
  a finding here. **Question for the user/design owner:** should a
  derived-state-coherence item such as this one be required to fix that
  pre-existing sentence (which would make the repo's status agent agree with the
  authority and the committed guard), or is it correctly owned by the prior
  item's still-open question? Recording it so it is not silently carried forward.

## Not reviewed

- **The untracked parent manifest.** `work/0011-recursive-bootstrap/roadmap.md`
  is untracked on `main` (it does not appear in `git diff --name-only HEAD` or in
  the tracked tree), so the parent's `Children`/`Depends on` graph is not
  committed. This is the parent item's planning state, not this child's
  deliverable, and the committed suite never reads `work/**`, so it does not
  affect this review; flagged for the parent item's owner (the child's own
  `verify.md` records the same residual).
- **Deferred Roadmap 4 surface sweep.** `.opencode/agent/roadmap.md:96`
  ("dependencies are intra-roadmap only"), `docs/workflow.md` routing heuristics
  (`:1272`), README, and other surfaces still use the two-level "roadmap
  parent"/"intra-roadmap" vocabulary. Each is consistent with, and strictly
  weaker than, the new sibling-only rule, so none states a *competing* rule; the
  broad sweep is an explicit spec non-goal (Roadmap 4).
- **Prompt-only rendering.** AC6/AC7 name an `/status` render; like the shipped
  `CYCLIC-DEP` rule (`tests/README.md`), an LLM's actual rendered output is not
  executable in CI. Verified as contract text only.
- **No committed recursive-readiness guard.** Committed recursive fixtures and
  mutation coverage are an explicit spec non-goal (Roadmap 5); the committed suite
  is required to stay green, not extended, here.
