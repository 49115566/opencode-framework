---
feature: 0007-phase-backtracking/0002-reverse-phase-routing
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Review — Reverse phase routing and upstream re-entry

## Verdict

**approve** — all twelve acceptance criteria are met by the documented surfaces;
no Blocker or Major finding survives scrutiny; the only findings are two
stale-marker lifecycle gaps inherited from the `0001` derived-state model plus
wording nits, all of which are non-blocking and route onward to
`0001`/`0006`/`0007`.

## Base and scope reviewed

The change is entirely uncommitted on `main`; the committed diff is empty.

```
$ git rev-parse HEAD                 → 117bbde56919198ad1f489a817941356a6cb8c99
$ git merge-base HEAD origin/main    → 117bbde56919198ad1f489a817941356a6cb8c99  (HEAD == origin/main)
$ git status --porcelain             → 10 modified files + untracked work/<ref>/verify.md
$ git diff --stat                    → 9 surfaces + tasks.md, 215 insertions / 41 deletions
```

Reviewed range: the full working-tree diff (`git diff`) plus the untracked
`verify.md`, against the base `117bbde`. The plan artifacts (`spec.md`,
`design.md`, `tasks.md`) already sit in the base commit (`7bd457c`, merged via
PR #33). Scope is framework-internal prose/prompt wiring only: the nine planned
surfaces — `docs/workflow.md`, `AGENTS.md`, `template/AGENTS.md`,
`.opencode/agent/{builder,architect,product}.md`,
`.opencode/command/{build,plan}.md`,
`.opencode/skill/workflow-lifecycle/SKILL.md` — plus `tasks.md` tick boxes. No
file was added, removed, or renamed under `.opencode/`, `README.md`, `tests/`, or
`docs/artifact-conventions.md` (verified with `git diff --stat` scoped to those
paths, which is empty).

## Acceptance criteria coverage

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 `/build`→`/plan` record + handoff | **met** | `.opencode/agent/builder.md:38-42,86-92,133-134`; `.opencode/command/build.md:35-42`; `docs/workflow.md:261-264` (Build Next), `:666-674` (step 5 + table row). Fields are detecting `/build`, target `/plan`, affected `design.md`/`tasks.md`, `status: open`; handoff `Next: /plan <item-ref>`. |
| AC2 `/plan`→`/spec` record + handoff | **met** | `.opencode/agent/architect.md:46-53,77-83,132-135,148-149`; `.opencode/command/plan.md:18-22,47-49`; `docs/workflow.md:220-223` (Requirements Next), `:240-245` (Design Next), `:669-674`; `.opencode/skill/workflow-lifecycle/SKILL.md:41,43`. Handoff `Next: /spec <item-ref>`. |
| AC3 detector never edits target; record precedes edge; owner revises | **met** | `docs/workflow.md:611-614,648-667` (steps 2 & 4, "A recorded finding precedes the edge"); `.opencode/agent/builder.md:91-92`; `.opencode/agent/architect.md:48-49,82`; `.opencode/command/plan.md:22`. |
| AC4 downstream marked `stale:`; item derives P; non-destructive | **met** | `docs/workflow.md:634-639` (invalidation, now "When the reverse edge is taken"), `:658-674` (step 3 + concrete marker sets), `:718` (derived-state precedence unchanged). Target-owned artifacts excluded; no delete/rewrite language. See F1 for the scoped no-downstream case. |
| AC5 re-entry: read open finding, revise, resolution, resume | **met** | `docs/workflow.md:682-700` (`### Re-entry`); `.opencode/agent/architect.md:51-53,70-76`; `.opencode/agent/product.md:61-69`; `.opencode/command/plan.md:10-15`. Resolution shape matches the untouched `docs/artifact-conventions.md` record. |
| AC6 no open finding → ordinary, no fabricated backtrack | **met** | `docs/workflow.md:695-697`; `.opencode/agent/product.md:66-69`; `.opencode/agent/architect.md:76`. |
| AC7 denied/changes-requested plan PR → re-run `/plan` + republish, not a backtrack | **met** | `docs/workflow.md:357-364` (new Plan-publication bullet), `:240-243`; `.opencode/agent/architect.md:97-102,149-151`; `.opencode/command/plan.md:38-41`. Same-branch commit, new PR if pruned, never force-push, "not a backtrack". |
| AC8 all named surfaces state routing; no forward-only leftover | **met** | Named surfaces all updated: builder/architect prompts, build/plan commands, workflow phase `Next:` lines, `AGENTS.md:98-101,127-134`, skill `:40-44,67-70`, `template/AGENTS.md:100-103,129-136`. A grep for `stop and report\|route back` over the touched surfaces returns only unrelated secret/ship-precondition/`/test` uses (see Not reviewed). |
| AC9 six commands/pairings unchanged; no add/remove; no count/signature change | **met (static)** | `git status --porcelain` shows only `M` entries under `.opencode/{agent,command,skill}` and no `A`/`D`/`??`; agent/command frontmatter `description`/`Usage` lines unchanged. `40-inventory.sh` and the `96-signature-sweep` registries are content-driven and unaffected (see Tests). |
| AC10 model stays single authority; no new phase/state/readiness | **met** | All wiring is added inside the existing `## Phase reversal (backtracking)` section; `docs/artifact-conventions.md` untouched (`git diff --stat` empty), Derived-state table byte-unchanged (`:716-730`), no new file. |
| AC11 `/test`, parent-`roadmap`, post-ship not wired | **met** | `docs/workflow.md:648-651` (step 1 excludes them), `:676-680` ("Only the two edges above are wired"); `.opencode/agent/product.md:68-69` scopes re-entry to `/plan`→`/spec`; no `/test`→/roadmap-revise/reopen route added to any prompt or the skill block. The `/test` rows in the edge table are pre-existing `0001` content. |
| AC12 configured suite passes; root↔template agree | **met (not re-run here)** | `verify.md` records `bash tests/run.sh` → `340 passed, 0 failed, 0 skipped`; independently I confirmed the affected checks' predicates hold and the `AGENTS.md`/`template/AGENTS.md` bodies are identical outside `## Project profile` (see Tests). |

## Findings

### Blockers

- none.

### Major

- none.

### Minor

- **[F1] `/build`→`/plan` can leave the item deriving `build`/`test`, not `/plan`, when no downstream artifact exists** — `docs/workflow.md:658-663,673,718`
  Step 3 marks only *existing* artifacts strictly downstream of the target and
  excludes target-owned artifacts. At build time the typical state has
  `spec.md`, `design.md`, `tasks.md` (target-owned, excluded) and no `verify.md`
  or `review.md`, so the detecting builder writes **no** `stale: design` marker.
  The derived-state row at `:718` keys only on the earliest `stale:` marker, so
  with no marker the item falls through to "tasks.md present, some boxes
  unchecked" → `build` (or `test`), while the handoff tells the user
  `Next: /plan <item-ref>`. The route and `/status` then disagree.
  AC4 is *met* because it is scoped to "artifacts downstream of P" and derived
  state is explicitly reserved for `0006`/`0001` (spec Non-goals; design
  `## Affected areas`), so this is not a failure of this item — but it is a real
  operational hole in the route this item wires. `verify.md:74-85` already
  records it as inherited residual risk.
  **Recommended fix (route to `0001`/`0006`, not this item):** derive the target
  phase from an open `backtracks.md` finding, or sanction marking the
  target-owned artifact when no downstream artifact exists. Do not change the
  derived-state table inside `0002` (that would breach AC10).

- **[F2] Downstream `stale:` marker clearing is only stated for the target phase's owner, so `/plan`→`/spec` markers can outlive the resolution** — `docs/workflow.md:689-697`; `.opencode/agent/architect.md:70-76`; `.opencode/command/plan.md:10-15`
  For a `/spec` target, the marked set is `design.md`, `tasks.md`, `verify.md`,
  `review.md` — none owned by the target's owner (`product` owns only the
  unmarked `spec.md`). The Re-entry clearing clause ("clears the `stale:` marker
  on any artifact it owns and has just re-run") sits inside the *Open finding
  present* branch, which fires only for a phase that is itself the target of the
  open finding. The downstream owners (`architect` re-running `/plan`, `tester`
  re-running `/test`) re-enter as "ordinary forward progression" and are told to
  "record no finding" but not to clear their own `stale: spec` markers. If a
  re-run preserves the frontmatter field rather than re-authoring it away, the
  item keeps deriving `spec`. The design's intent is the clean general rule
  ("Cleared by the owning phase when it re-runs", `design.md` Interfaces), but
  the authority's text does not state it for non-target phases.
  **Recommended fix:** state in `### Re-entry` (and mirror in
  `architect.md`/`plan.md`) that any phase re-authoring an artifact it owns
  clears that artifact's `stale:` marker, even when no open finding targets its
  phase. Small, in-scope docs/prompt change.

### Nits

- **[N1] Step-1 wording is over-broad inside the model authority** —
  `docs/workflow.md:648-651`. The general "Taking an edge" procedure says a
  `/test` edge "is not taken here", while `:676-680` says the `/test` edges
  "follow this same procedure when their items land". "Here" is ambiguous in
  the single-authority section. Prefer "not wired by this item" (or move the
  exclusion list to the per-edge table) so the procedure remains general.
- **[N2] Inconsistent "existing" qualifier** — `.opencode/agent/builder.md:39-40`
  says "mark the downstream artifacts `stale: design`"; the authority
  (`docs/workflow.md:658`) and the builder's own process step
  (`builder.md:89-90`) correctly say "every existing artifact". Add "existing"
  to the operating-principle line.
- **[N3] Timing change to the `0001` invalidation clause is undocumented in the
  model's own wording** — `docs/workflow.md:634`: "When the owner revises" became
  "When the reverse edge is taken". AC4 requires edge-time invalidation and the
  design documents the reconciliation, so this is accepted; a half-sentence
  naming the detecting phase as the marker writer would remove the last
  ambiguity (overlaps with F2).

## Scope, security, and tests

- **Scope:** no scope creep. Exactly the nine surfaces named in `design.md` →
  `## Affected areas` plus `tasks.md` tick boxes. `README.md`,
  `docs/artifact-conventions.md`, `.opencode/command/ship.md`,
  `.opencode/agent/{shipper,tester,reviewer}.md`, `tests/**`, and the parent
  `roadmap.md` are untouched (verified by scoped `git diff --stat`).
- **Security:** the change is Markdown/prompt prose; no executable code, no new
  dependency, no secret or credential material. Nothing to flag.
- **Tests:** the read-only review environment denies arbitrary bash execution, so
  `bash tests/run.sh` could not be re-run here; `verify.md` records a green run
  (`340 passed, 0 failed, 0 skipped`). I independently read and reasoned over
  the affected checks: `20-lifecycle.sh` (the seven pinned route literals at
  `:60-78` and the Derived-state table are byte-unchanged; the new skill lines
  only add routes), `40-inventory.sh` (no file added/removed, so counts equal
  disk), `95-split-guard.sh` (root and `template/AGENTS.md` bodies are identical
  outside `## Project profile`), and `96-signature-sweep.sh` (every new skill
  route token parses to a canonical signature — `/plan <item-ref>` and
  `/spec <feature or problem description | item-ref>`). No test was weakened,
  skipped, or deleted.
- **`visual.md`:** absent; this item has no user-facing UI, so the optional
  visual pass is correctly skipped.

## Not reviewed

- `work/0007-phase-backtracking/0002-reverse-phase-routing/verify.md` content is
  taken as the tester's evidence, not re-derived line by line.
- The two residual stale-marker gaps (F1, F2) are inherited from the shipped
  `0001` model / reserved `0006` derived-state work; they are reported here for
  routing but do not block this item, whose spec explicitly fences them off.
- `/test`→… reverse edges, parent-`roadmap` revision, and post-ship reopen are
  `0003`/`0004`/`0005` scope (AC11); their absence is expected, not a gap.
- The remaining `stop and report` hits outside the named surfaces
  (`.opencode/command/test.md:18`, `.opencode/agent/shipper.md:78,108,130,150`,
  `.opencode/agent/{visual,bootstrap}.md`, `AGENTS.md:108` secret guardrail) are
  unrelated to reverse-edge routing or are `/test` scope (`0003`).
