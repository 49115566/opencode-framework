---
feature: 0005-merge-conflict-workflow/0005-merge-integrity-guards
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Nested roadmap child; dependencies 0001-conflict-model and 0002-conflict-detection are satisfied (both have ship.md present), so it is ready. Re-scoped by user decision (2026-10-07) from the roadmap's fixture-based tests/checks guards: the merge-integrity guard is delivered as a portable, prompt-observable behavior contract enforced by /status and the /ship post-merge integrity pass; no new framework checker, no tests/checks agreement area, and no tests/mutation.sh coverage. Verification uses the project's own configured test suite plus surface inspection, not a standalone verify-tests.sh."
parent: 0005-merge-conflict-workflow
---

# Merge-integrity guard as a portable behavior contract

## Problem

After a reconcile or a merge to the default branch, a set of framework integrity
invariants can be silently violated: two `work/` items can share a 4-digit
sequence prefix, a roadmap `Depends on` can stop resolving, the stored dependency
graph can become cyclic, a child can become dangling/missing/unlisted, or a
duplicated inventory/count fact can drift. Sibling `0002-conflict-detection`
delivered detection as prompt behavior — the `merge-conflict` skill's read-only
pre-flight and the `status` agent's offline findings
(`.opencode/skill/merge-conflict/SKILL.md:64-126,277-399`,
`.opencode/agent/status.md:86-104,122-151`) — and siblings `0001`/`0003`/`0004`
delivered the reconcile contract. What is missing is the **guard**: a durable,
portable statement of the invariants, where they are enforced, and how a reader
observes a violation after a merge.

The roadmap scoped this guard as new fixture-based agreement areas in
`tests/checks/` plus `tests/mutation.sh` coverage
(`work/0005-merge-conflict-workflow/roadmap.md:77,130-133`). That vehicle cannot
serve the people who need the guard. `tests/` is explicitly
framework-maintainer-only and is never copied to adopters
(`tests/README.md:3-16`, `README.md:82-90,289`), and the framework deliberately
ships no literal tooling to adopters, so a `tests/checks/` guard would protect
only the framework repository while adopters inherit the detection vocabulary
with no portable guarantee. The gap is visible in the delivered procedure: the
merge-conflict re-verification tells the reader to run `bash tests/run.sh`
(`.opencode/skill/merge-conflict/SKILL.md:206-213`,
`docs/workflow.md:385-391`), a maintainer-only path an adopter does not have.
**Framework maintainers** who reconcile roadmap-child branches and **adopters**
running parallel work items therefore both lack a guard they can actually rely
on and verify.

## Goals

- A single, portable merge-integrity **guard contract**: the invariant set, the
  points at which the guard runs, and how a violation is observed and reported.
- Enforcement is prompt behavior only: the `/status` offline integrity findings
  and the `/ship` post-merge integrity pass. No checker, script, or tool is
  shipped, and no committed test area is added.
- The guard is report-only: a violation is a named, non-fatal finding carrying
  its class and offending canonical reference; no finding is silently dropped and
  none is auto-repaired.
- The guard is adopter-observable without any maintainer-only tooling: the
  duplicated-inventory/count-fact invariant is observable offline, and the
  guard's verification/re-verification step names the repository's own configured
  test command rather than a maintainer-only path.
- The contract reaches adopters through the surfaces shared verbatim with them.
- No regression: the committed suite stays green, and no new command, agent,
  skill, phase, artifact format, or executable tooling is introduced.

## Non-goals

- **New `tests/checks/` agreement areas and `tests/mutation.sh` cases** — the
  roadmap's original vehicle, superseded by the user's re-scope decision. `tests/`
  is unchanged by this child.
- **Re-specifying detection.** The finding codes and grammar
  (`DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, `CYCLIC-DEP`,
  `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DRIFT-FACT`, `TEXTUAL-CONFLICT`) are
  sibling `0002`'s; this child consumes them and defines no second vocabulary.
- **Reconcile mechanics, renumbering, and graph repair** — siblings `0003` and
  `0004`; this child guards, it does not resolve.
- **Any executable checker, script, helper, runtime code, or adopter-installed
  test tooling.** The framework provides no literal guard tooling to adopters.
- **Changing the `0001` contract's policy** — the taxonomy, lifecycle placement,
  ownership, resolution principles, and the normative "Renumbering after a
  parallel merge" rule are unchanged. Generalizing the guard's test-command
  reference for portability (AC5) does not alter that policy; the design must
  confirm it is an additive clarification, escalating to the user if it is not.
- **Making the guard fatal or blocking** beyond the escalation paths `0001`
  already defines, or auto-repairing a violation.
- **Structurally de-duplicating the shared surfaces** so parallel branches stop
  colliding — a deliberate roadmap omission.
- **Reopening the state model, readiness model, permission-class model, or the
  shipped work of other roadmaps** (`0003-framework-quality-hardening`,
  `0004-adoption-template-split`).

## Users and stories

- **As a** framework maintainer who just reconciled or merged a branch, **I want**
  to observe that the merge-integrity invariants still hold, **so that** a silent
  violation is caught before I record or ship.
- **As the** shipper agent, **I want** a defined post-merge integrity pass whose
  findings I report, **so that** the guard runs inside the existing reconcile
  procedure without a separate tool.
- **As the** status agent, **I want** the integrity invariants and their finding
  vocabulary to be complete and canonical, **so that** my offline report is the
  guard's read-only window.
- **As an** adopter running parallel work items, **I want** the guard to work in my
  repository with my own test command, **so that** I am not required to obtain or
  run the framework's maintainer-only suite.
- **As a** reviewer, **I want** the guard contract present on the surfaces I
  receive, **so that** I can confirm the invariants were observed after a merge.

## Acceptance criteria

1. **AC1** — Given the merge-integrity guard contract, when it is read, then it
   enumerates the invariant set: no two top-level `work/` items share a 4-digit
   `NNNN` prefix; no two children of one roadmap parent share a 4-digit `MMMM`;
   every roadmap `Depends on` resolves to an existing `Children` row and child
   directory; the stored dependency graph is acyclic; no child is dangling,
   missing, or unlisted; and the duplicated inventory/count facts agree with disk.

2. **AC2** — Given the guard contract, when its enforcement points are read, then
   it states the guard runs as prompt behavior at two points — `/status` reports
   the integrity findings offline and read-only on demand, and the `/ship`
   post-merge integrity pass runs after a merge to the default branch — and it
   states that no separate checker exists.

3. **AC3** — Given the guard runs and finds a violation, when it reports, then the
   finding names its code, its class, and the offending canonical reference, is
   non-fatal, is never silently dropped, and is not auto-repaired; and no file is
   modified by the guard.

4. **AC4** — Given the repository after the change, when the delivered surfaces are
   inspected, then the framework ships no checker, script, helper, or executable
   tool for the guard, `tests/` gains no agreement area and no mutation case, and
   no adopter instruction requires obtaining or running maintainer-only tooling to
   get the guard.

5. **AC5** — Given the guard's verification/re-verification instruction, when read,
   then it names the repository's own configured test command (the Project profile
   `Test:` value — the adopter's own suite) rather than a maintainer-only path, so
   an adopter can follow it; and the duplicated-inventory/count-fact invariant is
   observable offline through the guard without that suite.

6. **AC6** — Given the repository after the change, when the adopter-shared
   surfaces are inspected, then the guard contract and its invariant set are
   present on surfaces copied verbatim to adopters (`docs/*.md` and/or
   `.opencode/**`), so the guard travels with the copy and requires no migration.

7. **AC7** — Given the guard contract and the existing detection surfaces, when
   both are read, then the invariant names and finding codes agree with the
   canonical vocabulary delivered by sibling `0002`, and no second vocabulary or
   second policy is defined.

8. **AC8** — Given an item branch already up to date with the default branch and
   no integrity collision, when the guard runs, then it reports no findings, does
   not error, and mutates nothing.

9. **AC9** — Given the repository after the change, when `bash tests/run.sh` runs,
   then it exits `0`, including the inventory, lifecycle, permission, instruction,
   signature, packaging, and readiness/lifecycle agreements; no committed check
   area is added, removed, or duplicated.

10. **AC10** — Given the repository after the change, when the lifecycle phases,
    artifact formats, readiness/state models, and the command, agent, and skill
    inventories are inspected, then none gains or loses an entry, no new phase,
    command, agent, skill, or artifact format exists, and no executable file is
    added.

## Edge cases

- **Empty `work/` tree.** No items to guard: report no findings and do not error.
- **Duplicate prefix, different slugs.** Two top-level items share `NNNN` but
  differ in slug: still a violation; report both canonical references.
- **Same canonical reference, differing content.** Two branches added the same
  directory name: a content conflict beyond the prefix collision; the guard
  reports it rather than repairing it.
- **Dangling `Depends on`.** The named local id has no row or no child directory:
  report it as a finding; the guard does not guess the intended target.
- **Cycle in the graph.** Two children depend on each other: report it as a finding
  and never report a cycle member `ready`.
- **Unlisted or missing child.** A child directory has no `Children` row, or a row
  has no directory: report it; the guard does not silently add or drop a record.
- **Both sides changed the same duplicated fact to the same value.** Not drift:
  report no finding.
- **Up-to-date branch.** No violations and no collision: a no-op that reports no
  findings and does not error (AC8).
- **Adopter without the maintainer suite.** The guard's drift invariant is still
  observable through the offline report, and the verification step does not point
  at a path the adopter lacks (AC5).
- **No configured test command.** The Project profile's `Test:` value is `none`:
  the verification step states what that implies rather than assuming a command.
- **Large collision set.** Every violation is reported; the list is never
  truncated.
- **Concurrent guard runs.** Two read-only runs take no lock, write nothing, and
  do not interfere.
- **Guard disagreement between `/status` and the post-merge pass.** One surfaces a
  violation the other does not: the contract states they observe the same
  invariant set rather than defining divergent guards.

## Open questions

- [x] **Guard vehicle** — **resolved (user):** a portable behavior contract; no
      new checker, no `tests/checks/` agreement area, and no `tests/mutation.sh`
      coverage.
- [x] **Enforcement locus** — **resolved (user):** prompt behavior only — the
      `/status` offline integrity findings and the `/ship` post-merge integrity
      pass.
- [x] **Verification of this item** — **resolved (user):** the project's own
      configured suite (`bash tests/run.sh` for this repository) plus
      surface inspection; no standalone `verify-tests.sh` and no new tooling.
- [ ] **Exact surface placement and wording** of the consolidated guard contract —
      which of `docs/workflow.md`, `.opencode/skill/merge-conflict/SKILL.md`,
      `.opencode/agent/status.md`, `/status`, `/ship`, `AGENTS.md`, and `README.md`
      carry it, and the exact phrasing of the portable test-command reference. —
      owner: architect, needed by: design. **Deferred.**
- [ ] **Boundary with the shipped `0001`/`0003` contract text.** Whether
      generalizing the re-verification step's `bash tests/run.sh` wording to the
      repository's own configured test command is an additive clarification or a
      change to the `0001` normative contract, and whether it needs explicit user
      sign-off. — owner: architect (escalate to user if it changes `0001`
      policy), needed by: design. **Deferred.**

## Dependencies and constraints

- **Dependencies satisfied, item is ready.** The parent `roadmap.md` lists this
  child as `Depends on: 0001-conflict-model, 0002-conflict-detection`; both child
  directories contain `ship.md`, so both dependencies are satisfied and this child
  is ready (`docs/workflow.md:87-108`).
- **Consumes the `0001` contract.** The taxonomy, lifecycle placement, ownership,
  merge-forward principle, structural-auto/semantic-escalate rule, and
  re-verification requirement are authoritative in `docs/workflow.md` →
  `## Merge conflicts` and operational in the `merge-conflict` skill; this child
  defines no second policy.
- **Consumes the `0002` vocabulary and detection.** `DUPLICATE-PREFIX`,
  `DUPLICATE-CHILD`, `DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`,
  `CYCLIC-DEP`, `DRIFT-FACT`, and `TEXTUAL-CONFLICT` are already defined and
  reported (`.opencode/skill/merge-conflict/SKILL.md:109-121`,
  `.opencode/agent/status.md:135-147`); this child assembles them into the guard
  contract, not a re-specification of detection.
- **Supersedes the roadmap's guard vehicle.** `work/.../roadmap.md:77,130-133`
  scoped a `tests/checks/` area; the user re-scoped it to a prompt-observable
  contract, so `tests/**` and `tests/README.md` are unchanged.
- **Suite is maintainer-only and not shipped.** `tests/` and `.github/` are
  framework-maintainer-only and deliberately outside the adopter copy set
  (`tests/README.md:3-16`, `README.md:82-90,289`); the suite is read-only,
  provider-neutral, and never reads `work/**` (`tests/README.md:18-30`), so the
  guard cannot be a live-tree committed check and needs no new one.
- **Adopter's own suite.** `/bootstrap` writes the real `Test:` command into the
  adopter's Project profile (`.opencode/agent/bootstrap.md:83-98`; this
  repository's is `bash tests/run.sh`, `AGENTS.md:17`), so the guard's
  verification instruction must resolve to that command, not to a maintainer-only
  path.
- **Adopter reach.** `.opencode/**` and `docs/*.md` have a single source and are
  shared verbatim with adopters; `template/AGENTS.md` is the adopter-pristine
  source (`README.md:8-16`, `tests/README.md:5-16`). The guard contract must land
  on those shared surfaces to reach adopters.
- **Inventory and signature constraints.** `tests/checks/40-inventory.sh` and
  `docs/workflow.md`'s signature guards must stay green; this child adds no agent,
  command, or skill, so those counts and signatures must not change.
- **Shipped siblings are context, not scope.** `0003-shared-surface-reconcile` and
  `0004-artifact-reconcile` are shipped; this child consumes their reconcile and
  renumber procedures and does not re-open them except where the guard contract
  must reference them.
- **Assumption:** the guard is a property of the delivered prompt/doc surfaces and
  the behavior they prescribe; because the framework is prompt-driven, acceptance
  criteria name required content and observable behavior rather than
  implementation choices.
- **Assumption:** `/status` and the `/ship` post-merge pass are the only guard
  execution points; no scheduled job, hook, or CI step is added.
