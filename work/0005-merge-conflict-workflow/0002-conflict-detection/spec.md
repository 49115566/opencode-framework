---
feature: 0005-merge-conflict-workflow/0002-conflict-detection
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Nested roadmap child; dependency 0001-conflict-model is satisfied (ship.md present), so it is ready. User resolved three forks: deliver as prompt/config only (no executable script); /status runs offline framework-integrity detection only while the git-based textual comparison is /ship pre-flight only; committed merge-integrity guards are deferred to sibling 0005."
parent: 0005-merge-conflict-workflow
---

# Pre-flight conflict detection and classification

## Problem

`0001-conflict-model` fixed the merge-conflict contract and the `merge-conflict`
skill, but that skill's first step already reaches for a merge: it says only
"Compare the item branch against the default branch. Merge the default branch
forward." Nothing lets the shipper see and classify a conflict *before* mutating
the branch, and the shipper's own bash allowlist lacks even `git fetch` and a
read-only merge probe (`.opencode/agent/shipper.md:9-28`). So a maintainer or
adopter running parallel work items discovers a collision only after attempting
the merge, with no read-only report to review first. Two related gaps compound
this: `/status` reports roadmap dependency findings but does not report duplicate
`work/` sequence prefixes, and drift in duplicated inventory/count facts is
caught only when the committed suite eventually runs. The people affected are
**framework maintainers** shipping roadmap-child branches, who cannot assess a
merge before doing it, and **adopters** running parallel items, who inherit the
same blind spot.

## Goals

- A read-only, pre-ship detection capability that compares an item branch to the
  default branch and reports what would conflict, without merging, rebasing,
  force-pushing, or otherwise mutating the branch or working tree.
- Classification of every detection result by the four classes fixed in
  `0001-conflict-model`: (a) shared-surface textual, (b) `work/` artifact,
  (c) duplicate sequence number, (d) derived-agreement drift.
- Framework-integrity detection covering duplicate top-level `NNNN` prefixes,
  duplicate per-parent `MMMM` child numbers, roadmap `Depends on` references that
  are dangling/missing/unlisted/cyclic, and drift in duplicated inventory/count
  facts.
- Detection surfaced in `/ship`'s preconditions (pre-flight, before any ship
  operation) and on demand through `/status`, with `/status` remaining offline
  and read-only.
- The minimal read-only git permissions the pre-flight needs, granted without
  weakening the never-rebase, never-force-push guardrails.
- No regression: the committed suite stays green, and no new command, agent,
  lifecycle phase, or artifact format is introduced.

## Non-goals

- **Reconcile mechanics.** Merging the default branch forward and resolving
  conflict markers in shared surfaces is sibling `0003-shared-surface-reconcile`;
  merging `work/` artifacts and automating renumbering is sibling
  `0004-artifact-reconcile`. This child detects and reports; it does not resolve.
- **Committed merge-integrity guards and mutation coverage** — sibling
  `0005-merge-integrity-guards`. Detection behavior here is not pinned by a new
  committed check area.
- **An executable detection script or any runtime code.** The capability is
  delivered as prompts, configuration, and a skill procedure only.
- **A new command or agent.** No `/reconcile`, `/detect`, or `reconciler`; the
  parent decision is that reconciliation — and therefore its pre-flight — is a
  step inside `/ship` owned by the shipper.
- **`/status` performing the git-based textual comparison.** `/status` does not
  fetch, does not run a dry-run merge, and does not hit the network; it reports
  only locally observable integrity collisions.
- **Resolution policy** (merge-forward, auto-resolve mechanical, escalate
  semantic) — fixed by `0001-conflict-model`; this child consumes it and changes
  none of it.
- **Structurally de-duplicating the shared surfaces** so parallel items stop
  colliding — a deliberate roadmap omission.
- **Reopening the state model, readiness model, permission class model, or
  shipped sibling work.**

## Users and stories

- **As the** shipper agent, **I want** a read-only pre-flight that reports the
  merge base, the changed paths, and each classified conflict before I merge,
  **so that** I can assess what I am walking into and never mutate the branch
  during detection.
- **As a** framework maintainer, **I want** `/status` to report duplicate
  sequence prefixes and broken roadmap references on demand, **so that** I catch
  a collision before it reaches a ship.
- **As a** reviewer, **I want** the detection result recorded in the ship handoff
  and PR description, **so that** I can confirm what was assessed and how it was
  classified.
- **As an** adopter running parallel work items, **I want** the same detection to
  run before my ships, **so that** collisions surface early instead of at merge
  time.

## Acceptance criteria

1. **AC1** — Given the `merge-conflict` skill is loaded, when its detection
   section is read, then it specifies a read-only pre-flight that determines the
   merge base of the item branch and the default branch and reports the paths the
   two branches changed, and it states that the pre-flight mutates neither the
   branch nor the working tree (no merge applied, no rebase, no force-push).

2. **AC2** — Given the skill's textual-conflict check, when it runs, then it
   reports the paths on which a merge would conflict by performing a dry-run
   merge over the changed paths that does not apply to the working tree, and each
   conflicting path is classified as class (a) or (b) per the taxonomy in
   `docs/workflow.md` → `## Merge conflicts`.

3. **AC3** — Given the skill's framework-integrity checks, when they run, then
   they detect and report: duplicate top-level `work/` sequence prefixes;
   duplicate per-parent roadmap child numbers; roadmap `Depends on` references
   that are dangling, missing, unlisted, or cyclic; and drift in duplicated
   inventory/count facts.

4. **AC4** — Given detection produces a finding, when it is reported, then it
   carries the class label from the `0001` taxonomy — (a), (b), (c), or (d) —
   the affected path or canonical reference, and the specific collision or drift
   detail, and no detected finding is silently dropped.

5. **AC5** — Given the shipper agent prompt and the `/ship` command, when
   work-item-mode preconditions are read, then they include the read-only
   pre-flight before any ship operation and state that a detected conflict is
   reported and handed to the `0001` reconcile step (mechanical conflicts
   auto-resolved, semantic conflicts escalated) rather than ignored.

6. **AC6** — Given the pre-flight detects a conflict that requires a judgment
   about intent, when `/ship` reaches the reconcile step, then it stops and
   escalates to the user for explicit approval, consistent with
   `0001-conflict-model` AC5; detection never resolves such a conflict itself.

7. **AC7** — Given the shipper agent frontmatter, when its bash allowlist is
   read, then it permits the minimal read-only git operations the pre-flight
   needs (`git fetch`, a read-only dry-run merge probe, and read-only conflict
   inspection), and it still forbids rebase and force-push.

8. **AC8** — Given the status agent prompt and the `/status` command, when a
   report is produced, then it includes duplicate-sequence findings — duplicate
   top-level prefixes and duplicate per-parent child numbers — alongside the
   existing `DANGLING-DEP` / `MISSING-CHILD` / `UNLISTED-CHILD` / `CYCLIC-DEP`
   findings, reported non-fatally and without modifying any file.

9. **AC9** — Given `/status` performs its detection, when that detection runs,
   then it uses only local inspection of the repository's `work/` tree and its
   own duplicated inventory/count facts — it does not fetch a remote and does not
   perform a dry-run merge.

10. **AC10** — Given a detected collision or drift, when it is reported, then the
    finding names the specific offending canonical reference(s) and its class, so
    a user can locate and act on it without re-deriving it.

11. **AC11** — Given an item branch already up to date with the default branch,
    when the pre-flight runs, then it reports no conflicts and is a no-op that
    does not error.

12. **AC12** — Given detection has run during `/ship`, when the ship handoff and
    the PR description are written, then the detection result is recorded — the
    classes and paths found, or an explicit "no conflicts detected" — so a
    reviewer can see what was assessed.

13. **AC13** — Given the repository after the change, when `bash tests/run.sh`
    runs, then it passes, including the permission-agreement check that compares
    the README Agents table with the agent permission declarations.

14. **AC14** — Given the repository after the change, when the lifecycle phases,
    artifact formats, readiness/state models, command and agent inventories are
    inspected, then they are unchanged and no new command or agent exists.

## Edge cases

- **No remote or no default-branch reference.** `origin/HEAD` is unset, the
  remote is unreachable, or the repo is detached. The pre-flight reports that it
  could not determine the default branch instead of guessing one, and does not
  fail the whole ship on that basis alone.
- **`git fetch` unavailable or denied.** Detection reports the comparison as
  skipped with the reason; it never proceeds on a stale or partial comparison
  without saying so.
- **Empty state.** No `work/` items, or a roadmap parent with no children:
  integrity detection reports no findings and does not error.
- **Duplicate sequence number, one shipped and one not.** Class (c) is still
  reported; resolution defers to the existing renumbering contract owned by
  sibling `0004`, not to detection.
- **Overlapping classes.** A `work/` artifact that is both textually conflicting
  and duplicately numbered is reported under each applicable class rather than
  silently collapsing to one.
- **Both sides changed the same duplicated fact to the same value.** Not drift:
  detection reports no class (d) finding.
- **Clean dry-run merge.** A merge with no markers is not proof of correctness;
  detection still reports the potential derived-agreement drift for the suite to
  confirm post-merge, per the `0001` contract.
- **Detection runs concurrently.** Two read-only detection runs do not interfere,
  take no lock, and write nothing.
- **Large changed set.** Detection reports every conflicting path without
  truncating the path list, even when the diff is large.

## Open questions

- [x] **Delivery form** — **resolved (user):** prompt/config only; no executable
      detection script or runtime code.
- [x] **`/status` scope** — **resolved (user):** `/status` reports locally
      observable framework-integrity collisions only and stays offline; the
      git-based textual comparison is `/ship` pre-flight only.
- [x] **Committed guard ownership** — **resolved (user):** detection adds no new
      committed check area; all committed merge-integrity guards and mutation
      coverage are sibling `0005-merge-integrity-guards`.
- [ ] **Finding vocabulary** — the exact status finding code(s) for duplicate
      sequence prefixes and for duplicated-fact drift. The spec requires the
      finding to be named and the offender reported (AC8, AC10); the precise
      token is a design decision. — owner: architect, needed by: design.
      **Deferred.**
- [ ] **Pre-flight vs. reconcile detection boundary** — whether the read-only
      pre-flight is a distinct reported sub-step ahead of the `0001` skill's
      existing detection, or the existing step is made read-only and classified.
      Either satisfies AC1–AC2; the shape is a design decision. — owner:
      architect, needed by: design. **Deferred.**

## Dependencies and constraints

- **Dependency satisfied.** The parent `roadmap.md` lists this child as
  `Depends on: 0001-conflict-model`, and that child's `ship.md` is present, so
  the dependency is satisfied and this child is ready.
- **Consumes the `0001` contract.** The taxonomy, lifecycle placement, ownership,
  and resolution principles are authoritative in
  `docs/workflow.md` → `## Merge conflicts` and operational in
  `.opencode/skill/merge-conflict/SKILL.md`; this child reuses them and defines
  no second policy.
- **Permission surfaces.** The shipper's allowlist is
  `.opencode/agent/shipper.md:9-28`; its guardrails forbid rebase and force-push
  (`:148-158`). The status agent is read-only (`.opencode/agent/status.md:4-16`).
  `tests/checks/30-permissions.sh` compares a coarse capability class, not exact
  patterns, against the README Agents table; adding read-only git patterns must
  keep the shipper a git/gh class and the status agent a read-only class so that
  check stays green (AC13).
- **Suite constraints.** The committed suite is read-only, provider-neutral, and
  never reads `work/**` (`tests/README.md:18-30`); detection cannot be pinned by
  a new committed check in this child (deferred to `0005`), so AC verification
  here is by inspecting the delivered surfaces and by manual scenarios.
- **Inventory agreement.** `tests/checks/40-inventory.sh` and
  `tests/checks/90-packaging.sh` enforce README Layout counts and table
  membership; this child adds no agent, command, or skill, so those counts must
  not change.
- **`/status` scope extension, kept read-only.** To report duplicated-fact drift
  offline, the status agent gains a read-only consistency read of the documented
  inventory/count facts against the on-disk items it already inspects. Its
  mission (work-item reporting) and no-edit, no-fetch, no-merge constraints stay
  intact; it must not run the committed suite or modify anything.
- **Sibling sequencing.** `0003-shared-surface-reconcile` also grants the shipper
  `git fetch` (with `git merge`); because both children edit
  `.opencode/agent/shipper.md`, they should be landed in sequence, not in
  parallel, to avoid the very collision this initiative targets.
- **Assumption:** "read-only" means detection creates no commit, no branch
  change, and no working-tree change; `git fetch` updates remote-tracking refs
  only, which the `0001` contract already sanctions for the reconcile step.
- **Assumption:** because the deliverable is the framework's own prompts and
  configuration, acceptance criteria name the required content of those surfaces
  so they are testable; they state required behavior, not implementation choices.
