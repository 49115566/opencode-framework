---
feature: 0003-framework-quality-hardening/0001-state-model
phase: spec
status: final
created: 2026-10-04
updated: 2026-10-04
parent: 0003-framework-quality-hardening
---

# Artifact persistence and state model

## Problem

The framework's contract and its repository configuration disagree about where a
work item's state lives. `docs/workflow.md:16` states that "the repository's
`work/` directory plus the code diff is the complete state of the work," and the
lifecycle derives every phase from artifacts on disk, yet `.gitignore:5-8`
excludes `work/*` so those artifacts never enter version control; `AGENTS.md:65`
and `docs/workflow.md:55` reinforce the exclusion by calling artifacts "working
state" that is "git-ignored." Two concrete failures follow for framework
maintainers, adopters, and reviewers:

- **Dead handoffs.** The ship phase opens pull requests whose description links
  the work item's artifacts by repository path (`shipper.md:37,84`;
  `pr-workflow/SKILL.md:43-49`, `README.md:16-18`). A reviewer who does not share
  the author's machine cannot open those paths, so the spec, verification, and
  review are invisible at the moment they are most needed.
- **False durability.** "State survives across sessions" holds on one machine
  only. A teammate, a CI job, or a fresh clone starts from no state and cannot
  derive an item's phase or shipped status.

The same exclusion makes two adjacent guarantees unverifiable: the "never reuse a
number, even if the directory was deleted" rule (`docs/artifact-conventions.md:413-420`)
has no durable ledger, and "keep items on separate branches"
(`docs/workflow.md:273-276`) does not say what happens to artifacts when those
branches merge. The external review named this contradiction the framework's
central finding.

**Decision (user, 2026-10-04):** artifacts use the **committed** model. `work/`
workflow artifacts — including nested child reservation placeholders and visual
evidence (screenshots) — are version-controlled; only the temporary workspace
(`scratch/`) and opencode's own generated state remain ignored. The alternative
(local-only artifacts with artifact links removed from PR bodies) was considered
and rejected because it weakens the framework's core "artifacts are the state"
claim and its PR handoff.

## Goals

- One persistence model is documented and enforced everywhere: workflow
  artifacts are committed working state, not ignored local scratch.
- The "complete state" claim in the workflow contract becomes true for a fresh
  clone, a teammate, and CI.
- Pull-request artifact links resolve for a reviewer who does not have the
  author's working tree.
- Numbering is durable: a fresh clone continues the sequence and cannot reuse an
  allocated number.
- Parallel work items on separate branches remain mergeable, and a numbering
  collision has a defined, reference-preserving resolution.
- The existing artifact corpus (`0001-*`, `0002-*`, `0003-*`) and future visual
  evidence are brought under version control.
- Temporary and generated paths (`scratch/`, `.playwright-mcp/`, opencode's own
  state) stay ignored; no second state store is introduced.

## Non-goals

- Choosing or supporting the local-only model. Committed is the framework
  default; a project-specific local-only posture is an override outside the
  framework's supported behavior, not a second mode.
- Rewriting previously authored artifacts to retroactively reflect the new
  model. Historical `work/` records are immutable; only the owning phase may
  edit an artifact.
- Readiness/shipped-state semantics and the fate of `ship.md` (sibling child
  `0002-readiness-ship-state`).
- Relocating the committed test suite or adding CI (sibling child
  `0006-committed-tests-ci`).
- `/doctor`'s audience, scope, or diagnostic catalogue (sibling child
  `0004-doctor-scope`).
- Default-agent, model, or MCP configuration hardening (sibling child
  `0007-config-hardening`).
- Binary size policy: no Git LFS, `.gitattributes`, or file-size limits for
  committed screenshots.
- Artifact formats, phase definitions, the lifecycle, or the no-state-file
  design.
- The permission model and read-only enforcement claims (sibling child
  `0003-readonly-permissions`).

## Users and stories

- **As a** framework maintainer, **I want** one unambiguous, enforced
  persistence model, **so that** the framework's "artifacts are the state" claim
  is true and auditable rather than contradicted by its own configuration.
- **As an** adopting engineer, **I want** the documented behavior and the shipped
  ignore rules to agree, **so that** I do not get dead PR links or silently
  lost artifacts after running the adoption flow.
- **As a** teammate or reviewer, **I want** workflow artifacts committed, **so
  that** I can open the spec, verification, and review linked from a pull request
  without access to the author's machine.
- **As a** returning maintainer on a fresh clone, **I want** the committed tree
  to continue the sequence and carry shipped state, **so that** I never reuse an
  allocated number or misreport an item's phase.
- **As a** UI-work maintainer, **I want** visual evidence committed alongside the
  report, **so that** a UI review and its screenshots travel together.

## Acceptance criteria

1. **AC1 — Artifacts are trackable.** Given the repository's ignore rules after
   this change, when any lifecycle phase writes an artifact under the artifact
   root, then version control treats it as trackable — it appears as a new or
   modified file rather than being reported as ignored.

2. **AC2 — Only non-artifact paths stay ignored.** Given the repository's ignore
   rules, when the temporary workspace and tooling-output paths are evaluated,
   then they remain ignored, and when any path under the artifact root is
   evaluated, then it is not ignored.

3. **AC3 — Reservation placeholders persist.** Given a roadmap parent whose child
   directories hold only a placeholder file, when the repository is inspected,
   then each placeholder is trackable, so the reserved child directory and its
   number persist in version control.

4. **AC4 — Every current surface states one model.** Given the framework's
   current docs, README, always-loaded contract, agent prompts, commands, and
   skills, when searched for claims that artifacts are git-ignored, are not
   deliverables, or are invisible to teammates or CI, then no such claim remains,
   and every current surface that describes persistence describes artifacts as
   committed working state. Previously authored artifacts under the artifact root
   are excluded from this sweep (see non-goals).

5. **AC5 — Adoption yields the committed model.** Given an adopter runs the
   framework's adoption flow on a fresh repository, when configuration
   completes, then the artifact root exists, artifacts are trackable, and only
   non-artifact paths (temporary workspace, tooling output, generated
   environment state) remain ignored.

6. **AC6 — Consistency audit stays clean.** Given the framework's read-only
   consistency audit runs against this repository, when it evaluates the
   ignore-rule policy, then it reports no ignore-policy finding introduced by the
   committed model.

7. **AC7 — Shipped PR links resolve.** Given a work item is shipped, when its
   pull-request body links the item's artifacts by repository path, then every
   linked path exists in the branch and a reviewer who does not have the author's
   working tree can open it.

8. **AC8 — Fresh-clone state parity.** Given artifacts are committed, when the
   lifecycle state of an item is derived on a fresh clone or by a teammate, then
   the derived phase, task progress, verdict, and shipped state match those
   derived where the artifacts were produced.

9. **AC9 — Numbers are unique and durable.** Given the committed artifact tree,
   when a new work item is allocated a number, then the allocated number is
   greater than every number already present in the committed tree and unused by
   any other item; no two distinct work items share a canonical number at any
   point in the merged history.

10. **AC10 — Parallel branches reconcile without collisions.** Given two branches
    each create a work item and are merged, when their artifact trees combine,
    then each item occupies its own directory and either their numbers are
    distinct or exactly one item is renumbered, with every reference to the old
    number updated, so that after the merge no two items share a canonical
    reference.

11. **AC11 — Visual evidence is committed.** Given a UI-bearing work item, when
    visual QA produces screenshots and a visual report under the artifact root,
    then both are trackable and committed rather than ignored.

12. **AC12 — Derived state is preserved.** Given the committed model, when an
    item's phase is derived, then it continues to be derived from the existence
    and content of artifacts, and no separate state file or registry is
    introduced.

## Edge cases

- **Empty artifact root.** Only the root placeholder exists; allocation starts at
  the first number.
- **Two branches allocate the same next number.** Deterministic resolution: one
  item keeps the number, the other is renumbered, and every canonical reference
  (directory name, frontmatter `feature`, `parent` references from children,
  roadmap `Children` table rows, handoff paths) is updated in the same change.
- **A number's directory is deleted in a later commit.** The number remains
  visible in history and is never reused.
- **Placeholder retained next to a real artifact.** The placeholder may stay or
  be removed once the directory holds real content; either way the directory
  remains tracked and the number reserved.
- **Adopter merging `.gitignore`.** A pre-existing rule that ignores the artifact
  root must be corrected by the adoption flow; an adopter who deliberately wants
  local-only artifacts is running an unsupported override and must be told what
  will not work (PR links, fresh-clone state).
- **Binary evidence growth.** Committing screenshots increases repository size
  with no size policy in scope; this is an accepted trade-off of the committed
  model and is surfaced to adopters.
- **Historical artifacts describe the old model.** Previously authored artifacts
  under the artifact root may still mention the ignored model; they are
  immutable records and are out of the consistency sweep.
- **Shared framework surfaces change alongside artifacts.** Docs, config, and
  prompts are shared across branches and may conflict on merge; artifacts
  themselves do not, because each item is its own directory.

## Open questions

- [ ] Is committed the *sole* supported model, or should the framework also ship
      a documented local-only override for adopters? — owner: user, needed by:
      plan. Working assumption: committed is the sole model; a local-only posture
      is an unsupported project override. Recorded per the roadmap, which frames
      this as one choice.
- [ ] Is a binary-evidence size policy (Git LFS or `.gitattributes`) needed now?
      — owner: user, needed by: plan. Working assumption: out of scope; note the
      trade-off and revisit only if repository size becomes a problem.

## Dependencies and constraints

- **Readiness:** this child has no dependencies and is `ready`.
- **Downstream consumers:** `0002-readiness-ship-state` and `0005-fix-landing`
  depend on this decision; both may assume artifacts (including a committed ship
  record) are visible to a fresh clone. `0009-surface-consistency` sweeps the
  surfaces this item settles.
- **Contradicting surfaces to reconcile (grounding, not prescription):**
  `docs/workflow.md:16,55`, `.gitignore:5-8`, `AGENTS.md:65`, `README.md:210`,
  `.opencode/agent/bootstrap.md:93,107`, `docs/artifact-conventions.md:413-420`,
  `docs/workflow.md:273-276`, `.opencode/skill/pr-workflow/SKILL.md:43-49`, and
  `shipper.md:37,55,84`.
- **Audit compatibility:** the framework's consistency audit already expects only
  tooling and scratch paths to be ignored (`.opencode/agent/doctor.md:61,108-112`),
  so the committed model does not conflict with it; that agent is owned by sibling
  `0004-doctor-scope`.
- **Existing static suite:** `work/0002-agentic-roadmaps/verify-tests.sh` asserts
  item-ref grammar and permissions, not the ignore rules, so it must continue to
  pass; sibling `0006-committed-tests-ci` relocates it to a committed location.
- **Immutability:** previously authored artifacts are not edited to reflect the
  new model; `scratch/` remains the in-repo temporary location and stays ignored.
- **No runtime change:** docs, prompts, commands, and configuration only; no
  dependency is introduced.
- **Assumptions:** the cited contradiction is accurate against current files
  (verified during recon); committed is the user's decision (2026-10-04); the
  existing corpus and visual screenshots are committed per the user's choice.
