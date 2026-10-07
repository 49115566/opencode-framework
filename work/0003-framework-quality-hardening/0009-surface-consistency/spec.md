---
feature: 0003-framework-quality-hardening/0009-surface-consistency
phase: spec
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "Withdrawal record, not an implementation spec. User decision (2026-10-06): nullify this roadmap child and re-home its scope. The re-verified scope is (a) the command signature/usage-string sweep across AGENTS.md, docs/workflow.md, README.md, and the workflow-lifecycle skill (including the stale /visual [url|slug] spelling), (b) the non-conforming ask.md description, and (c) the framework's own Project profile — whose correct resolution is a maintainer-vs-adopter bootstrapped-file split, not a surface edit. That split is an adoption-architecture change and must be planned by a successor roadmap authored via /roadmap; /roadmap only creates a new parent (it cannot amend the existing one). This item makes no product change. Dependencies 0001-state-model, 0003-readonly-permissions, and 0004-doctor-scope are all shipped, so readiness was satisfied; withdrawal is a scope decision, not a dependency block. Number 0009 remains spent."
---

# Surface consistency — withdrawn

## Problem

The parent roadmap assigned this child a surface-consistency sweep and listed the
framework's own `AGENTS.md` Project profile among the findings to fix
(`work/0003-framework-quality-hardening/roadmap.md`, child `0009-surface-consistency`).
Recon re-verified every cited finding against the current files and found the
profile finding is not a surface-text problem at all.

`AGENTS.md` is both the framework repository's live always-loaded contract and the
template the adoption quickstart copies into other repositories
(`README.md:49`, `.opencode/agent/bootstrap.md:70-73`). Filling its Project profile
with the framework's verified values would therefore ship the maintainers'
bootstrapped configuration to every adopter — the opposite of what `/bootstrap`
exists to do. The correct resolution is to separate maintainer-bootstrapped files
from adopter-pristine templates and rework `/bootstrap` and the adoption path
around that split: an adoption-architecture change spanning
`.opencode/agent/bootstrap.md`, the quickstart copy set, `opencode.json`, the
committed test suite, and `/doctor`.

That change cannot be specified as one more bullet in a text sweep, and a
standalone flat work item would act before the split exists — filling `AGENTS.md`
and breaking adopters, exactly as this child would. The remaining surface
findings (the command signature/usage-string surface and the non-conforming
`ask.md` description) are well understood but are entangled with the same
`AGENTS.md`/`README.md`/`docs/workflow.md` files the split will touch, so doing
them piecemeal invites conflicting edits.

The parent roadmap cannot absorb the additional child in place: `/roadmap`
allocates the next top-level `NNNN` and writes a new parent, with no amend form
(`.opencode/command/roadmap.md:20-22`, `.opencode/agent/roadmap.md:89-99`).

**Decision (user, 2026-10-06):** withdraw this work item. Preserve its scope for a
successor roadmap, authorize no product change here, and leave nothing that
lets a maintainer or agent mistake this child for active work.

## Goals

- This work item is formally withdrawn: it authorizes no change to any agent,
  command, skill, doc, `README.md`, `AGENTS.md`, `opencode.json`, `.gitignore`, or
  test.
- The withdrawal is explicit and discoverable, so an agent reading this item does
  not plan, build, or implement its former scope.
- The former scope is preserved in a form a successor roadmap can re-decompose,
  rather than silently dropped.
- After the withdrawal is landed, workflow status no longer presents this child as
  an active or ready work item.
- The top-level number 0009 stays spent, preserving the allocation ledger.

## Non-goals

- The command signature/usage-string sweep (including the stale `/visual [url|slug]`
  and `/visual [url]` spellings) and the `ask.md` description change.
- The maintainer-vs-adopter bootstrapped-file split, or any part of it: the
  Project profile, `/bootstrap`, the quickstart copy set, `opencode.json`, the
  committed suite, or `/doctor`.
- Editing `work/0003-framework-quality-hardening/roadmap.md` or any other
  phase-owned artifact. The parent roadmap is the roadmap phase's artifact and
  must be updated by its owner.
- Designing the successor roadmap's shape, child set, or dependencies.
- Changing the lifecycle, artifact formats, permission model, or state model.
- Reusing or renumbering 0009.

## Users and stories

- **As a** framework maintainer, **I want** the withdrawal recorded unambiguously,
  **so that** neither I nor an agent implements a half-scoped item that would ship
  maintainer configuration to adopters.
- **As a** framework maintainer planning the successor work, **I want** the
  former scope preserved, **so that** the signature sweep, the `ask.md` fix, and
  the adoption split are re-decomposed deliberately instead of lost.
- **As an** adopting engineer, **I want** the maintainer/adopter bootstrap split
  designed as one coherent change, **so that** I never receive a repository
  already bootstrapped for the framework's maintainers.

## Acceptance criteria

1. **AC1** — Given this work item after the withdrawal, when its directory is
   inspected, then it contains no `design.md`, `tasks.md`, `verify.md`,
   `review.md`, or `ship.md`, and its sole artifact is this specification
   recording the withdrawal.

2. **AC2** — Given the repository after the withdrawal is landed, when the
   product surfaces (`AGENTS.md`, `README.md`, `docs/`, `.opencode/`,
   `opencode.json`, `.gitignore`, and `tests/`) are compared against the
   pre-withdrawal revision, then this item has changed none of them.

3. **AC3** — Given the withdrawal is landed, when `/status` next reports the
   `0003-framework-quality-hardening` roadmap and its children, then
   `0009-surface-consistency` is no longer presented as a ready or active child
   (it is absent, or explicitly marked withdrawn/superseded).

4. **AC4** — Given a successor roadmap is authored for the re-homed work, when
   this item is read, then it names the whole former scope — the command
   signature/usage-string sweep, the non-conforming `ask.md` description, and the
   maintainer-vs-adopter bootstrapped-file split — so the successor can enumerate
   it without re-deriving it from history.

5. **AC5** — Given the sequence-allocation contract, when the committed `work/`
   tree and its history are inspected after the withdrawal, then the number 0009
   is still spent and is not assigned to any other work item.

## Edge cases

- **Empty directory.** If the item is left as its `.gitkeep` plus this spec, the
  parent roadmap still lists a child whose artifacts indicate an active `spec`
  phase; AC3's outcome must be achieved by the owner that lands the withdrawal,
  not assumed.
- **Deleted directory.** If the item directory is removed entirely, the parent
  roadmap's `Children` row becomes a dangling reference (`UNLISTED-CHILD` /
  `MISSING-CHILD`); the number 0009 still stays spent in git history (AC5).
- **Withdrawal not recorded upstream.** If the parent roadmap row is not updated,
  workflow status continues to present 0009 as active even though this spec
  withdraws it; the withdrawal is not complete until AC3 holds.
- **Successor roadmap omits part of the scope.** The signature sweep and `ask.md`
  finding are small and easy to lose; AC4 requires them to be named on the record
  so the successor's decomposition, not this item, decides their fate.
- **A later agent treats the spec as active.** A `phase: spec` artifact normally
  invites `/plan`; this document's title, `notes`, and Problem must make the
  withdrawal unmistakable so no downstream phase is started.
- **No stored state for "withdrawn."** The lifecycle has no withdrawn phase; the
  withdrawal must be conveyed through the artifact and the roadmap record, not a
  new state file or status value.

## Open questions

- [x] Which vehicle carries the re-homed split — a new roadmap or a flat item?
      **Resolved (user, 2026-10-06):** a successor roadmap authored via
      `/roadmap`; `/roadmap` cannot amend the existing parent, and a flat item
      would act before the split exists.
- [ ] Does the successor carry the *entire* former 0009 scope (signature sweep and
      `ask.md` fix as well as the split), or only the split? — owner: user, needed
      by: successor roadmap. **Assumption:** the whole scope is re-homed; the
      successor's decomposition decides whether to split it across children.
- [x] How the withdrawal is recorded in the parent roadmap — **deferred** to
      whoever lands it (the user's planned `/fix`); this spec fixes only the
      observable outcome in AC3, not the mechanism.

## Dependencies and constraints

- **Parent roadmap child.** Canonical reference
  `0003-framework-quality-hardening/0009-surface-consistency`; `parent:
  0003-framework-quality-hardening`.
- **Readiness was satisfied.** The roadmap's `Depends on` cell names
  `0001-state-model`, `0003-readonly-permissions`, and `0004-doctor-scope`; all
  three contain a `ship.md`, so each dependency is satisfied. Withdrawal is a user
  scope decision, not a dependency block.
- **Read-only guard.** This item writes only `work/**` (this specification) and
  changes no source, docs, config, or test.
- **Parent roadmap is owned by another phase.** `roadmap.md` must not be edited by
  the product agent; AC3 depends on its owner recording the withdrawal.
- **Re-homed scope (for the successor, cited not prescribed):**
  `ask.md:2`; the `AGENTS.md` lifecycle table (`AGENTS.md:37-42`) and
  supporting-commands list (`AGENTS.md:50`, the `/visual [url|slug]` spelling);
  `docs/workflow.md` phase headings (`docs/workflow.md:139,153,170,184,204,217`)
  and the routing bullet (`docs/workflow.md:306`); `README.md` commands table
  (`README.md:180-186`), lifecycle mermaid (`README.md:125-135`), and quickstart
  example (`README.md:109-116`); and the `workflow-lifecycle` skill's routing block
  (`.opencode/skill/workflow-lifecycle/SKILL.md:31-39`). Recon confirmed the
  `/test`, `/review`, and `/ship` command frontmatter already carry `[item-ref]`.
- **No new dependency.** Withdrawal introduces no runtime, build, or CI change.
- **Assumption:** the three cited findings are accurate against the current files
  (re-verified during recon); the successor roadmap must re-verify them again
  before acting, consistent with the parent roadmap's staleness caveat.
