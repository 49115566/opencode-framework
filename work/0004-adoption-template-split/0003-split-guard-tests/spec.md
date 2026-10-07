---
feature: 0004-adoption-template-split/0003-split-guard-tests
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: ""
parent: 0004-adoption-template-split
---

# Committed split guards

## Problem

Children `0001-adopter-template-split` (PR #13) and
`0002-bootstrap-quickstart-rework` (PR #14) shipped the adopter/maintainer split:
adopter-pristine sources live under `template/` (`template/AGENTS.md`,
`template/opencode.json`, `template/.gitignore`), the documented quickstart copies
those to destination names (`README.md:49-51`), the framework's own bootstrapped
copies stay at the root, and the `bootstrap` agent denies edits under `template/`
(`.opencode/agent/bootstrap.md:15-16`). Today that split is enforced only by prose
and by the pre-existing packaging/copy-set guards, which check the *packaging*
files (`LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`) and never the
bootstrap-mutable set (`tests/checks/90-packaging.sh:87-198`).

Nothing in the committed suite fails if a future edit re-points the quickstart at
the framework's root `AGENTS.md`, fills `template/AGENTS.md` with the maintainer
Project profile, reintroduces a claim that adopters receive a root copy, weakens
the `bootstrap` `template/` deny rules, or lets the documented split contract
drift from the quickstart. Each of those regressions is silent until an adopter
is contaminated — exactly the hazard the split exists to prevent
(`work/0004-adoption-template-split/0001-adopter-template-split/spec.md:15-31`).
The initiative's outcome — an adoption path that cannot ship maintainer
configuration, guarded by the committed suite
(`roadmap.md:30-37`) — is only half-delivered without these guards.

**Decisions (user, 2026-10-07):** the guards are **static assertions** (the suite
stays read-only and does not execute the quickstart); the new agreement area gets
its own **mutation self-check** case; and the guards **include** an assertion that
the `bootstrap` agent still denies `template/`.

## Goals

- The committed suite fails, naming the offending surface, if the documented
  quickstart no longer sources `AGENTS.md`, `opencode.json`, and `.gitignore` from
  their `template/` pristine sources, or sources any of them from the framework's
  root maintainer copies.
- The committed suite fails if `template/AGENTS.md` stops presenting the unfilled
  placeholder Project profile, or if a maintainer-bootstrapped value reaches a
  pristine source.
- The committed suite fails if a copy-set surface claims or implies that an
  adopter receives the framework's root maintainer copies.
- The committed suite fails if the documented split contract and the quickstart's
  copy mapping disagree.
- The committed suite fails if the `bootstrap` agent's `template/` edit guard is
  removed or weakened, while an adopter's own root files remain editable.
- The new agreement area is mutation-sensitive and documented, and every existing
  committed agreement stays green.

## Non-goals

- Changing the split itself, the `template/` layout, the quickstart commands, or
  the framework's own bootstrapped Project profile — child `0001` (shipped).
- Changing `/bootstrap`, its command, or the quickstart/copy-set prose — child
  `0002` (shipped); this item guards those surfaces, it does not rework them.
- Aligning `/doctor` with the split — child `0004-doctor-template-alignment`.
- The command-signature/usage-string sweep and the `ask.md` description — child
  `0005-surface-consistency-sweep`.
- Executing the documented quickstart, performing any copy, or otherwise writing
  inside the committed suite; the guards are static assertions (user decision).
- Templating `docs/*.md`, changing the copy-set membership, or re-opening the
  packaging/versioning decisions of `0003-framework-quality-hardening`.
- Weakening, replacing, or duplicating the existing `AC18`–`AC20` packaging
  guards, or the inventory/instruction/permission/readiness/lifecycle agreements.
- Introducing any runtime dependency, install step, network access, or CI
  workflow change.

## Users and stories

- **As a** framework maintainer, **I want** the committed suite to fail when the
  quickstart stops sourcing the pristine `template/` files, **so that** the split
  cannot silently rot between releases.
- **As an** adopting engineer, **I want** the suite to guarantee I receive the
  placeholder template and never a maintainer-bootstrapped file, **so that**
  contamination is caught before it reaches me.
- **As a** framework maintainer, **I want** the split guard and its bootstrap
  deny rules to be mutation-tested and documented, **so that** a silent removal
  or drift is caught and the new agreement area is discoverable.

## Acceptance criteria

1. **AC1** — Given the framework repository as shipped (correct split), when the
   committed suite runs, then it exits `0`, the new split guards pass, and every
   existing agreement (packaging copy-set, inventory, instructions, permission,
   readiness, lifecycle) still passes.

2. **AC2** — Given the documented quickstart in `README.md`, when the committed
   suite inspects its copy commands, then it asserts that each of `AGENTS.md`,
   `opencode.json`, and `.gitignore` is sourced from the corresponding
   `template/<file>` pristine source and delivered to its destination name, and
   that no copy command sources any of the three from the framework's root copy;
   a quickstart that re-points any of the three at a root maintainer copy fails
   the suite and names that file.

3. **AC3** — Given the adopter-pristine `template/AGENTS.md`, when the committed
   suite inspects it, then it asserts its Project profile is the unfilled
   placeholder (no maintainer-bootstrapped framework value); a `template/AGENTS.md`
   replaced with the framework's filled profile — or otherwise missing its
   placeholder profile — fails the suite and names `template/AGENTS.md`.

4. **AC4** — Given the copy-set surfaces (`README.md`, `docs/customization.md`,
   `tests/README.md`, `CONTRIBUTING.md`), when the committed suite inspects them,
   then it asserts none claims or implies that an adopter receives the framework's
   root `AGENTS.md`, `opencode.json`, or `.gitignore`; a surface that reintroduces
   such a claim fails the suite and names that surface.

5. **AC5** — Given the quickstart's per-file copy mapping and the split contract
   documented in `docs/customization.md`, when the committed suite inspects both,
   then it asserts they name the same adopter-pristine source (`template/<file>`)
   for each of the three bootstrap-mutable files; a divergence fails the suite and
   names the mismatched file.

6. **AC6** — Given the `bootstrap` agent's declared edit permissions, when the
   committed suite inspects them, then it asserts an edit to any path under
   `template/` resolves to deny (the deny rules remain in effect after the broader
   allows that would otherwise match) while the adopter's own root `AGENTS.md`,
   `opencode.json`, and `.gitignore` remain allowed; removing or weakening the
   guard fails the suite and names the agent.

7. **AC7** — Given `tests/README.md`, when read after this item, then it documents
   the new split-guard agreement area — its stable suite token and the
   source-of-truth mapping it guards — consistently with the existing Checks table
   and without displacing the `AC18`–`AC20` packaging descriptions.

8. **AC8** — Given the opt-in mutation self-check, when it is run after this item,
   then it includes one mutation for the new split-guard area that the suite
   catches and names, reports zero failed mutations, and leaves the clean-copy and
   forced-absent-tools runs passing.

## Edge cases

- **Byte-identical pristine pair.** `template/opencode.json` and
  `template/.gitignore` are currently byte-identical to the framework's root
  copies (`0001` design, "Byte-identical copies"); the guard must assert the
  quickstart's *source path*, not that the two files differ, so it passes today
  and still holds once they diverge.
- **Legitimate quickstart reformatting.** The guard asserts the outcome (each
  file's adopter source is `template/<file>` and never a root copy), not an exact
  `cp` literal, so a whitespace, quoting, or loop rewrite that preserves the
  mapping still passes.
- **Wholesale directory copy.** A single command that copies the whole `template/`
  directory rather than the three named files is not the documented per-file
  quickstart (`0002`, "per-file copy to destination names"); the guard must not
  accept it as equivalent to the three mapped copies.
- **Maintainer root copy present and bootstrapped.** The root `AGENTS.md` carries
  a real filled profile and must not be flagged merely for containing values; only
  its use as an adopter copy source, or as the pristine template, is wrong.
- **Shared-verbatim remainder.** `.opencode/{agent,command,skill}` and `docs/*.md`
  have a single source and must not be treated as needing a `template/` source or
  flagged by the new guards.
- **Missing or renamed pristine source.** If a `template/<file>` named by the
  quickstart or the contract is absent, the guard fails and names the missing
  source rather than passing vacuously.
- **Missing or unreadable quickstart block.** If `README.md` exposes no readable
  quickstart copy block, the guard fails and names `README.md`.
- **Guard ordering.** The `bootstrap` edit guard depends on its deny rules being
  evaluated last (last-match-wins); a reorder that puts the broad root-file allows
  after the `template/` denies must fail the guard.
- **Over-reach.** The `bootstrap` guard assertion must not fail an agent that
  legitimately allows the adopter's own root files, and the copy-set guard must
  not flag the packaging `AC18`–`AC20` statements.
- **Fresh-clone / no `work/`.** The new checks must pass with no `work/`
  directory present and with every optional tool forced absent, like the rest of
  the suite (`tests/README.md:29-30`, `47-52`).
- **Mutation sensitivity.** Breaking a guarded property in a scratch copy must
  make the suite exit non-zero and name the new area; a guard that no mutation can
  trip is a defect.

## Open questions

- [x] Guard depth — **Resolved (user, 2026-10-07):** static assertions only; the
      committed suite does not execute the quickstart.
- [x] Mutation self-check coverage — **Resolved (user, 2026-10-07):** add a
      mutation case for the new split-guard area.
- [x] Bootstrap deny-guard coverage — **Resolved (user, 2026-10-07):** include an
      assertion that the `bootstrap` agent still denies edits under `template/`
      while allowing the adopter's root files.
- [ ] The new agreement area's stable suite token and check-file placement —
      owner: architect, needed by: `/plan`. **Deferred:** the token number and
      whether the guard is a new check file or extends an existing area are
      design decisions; the observable guarantees and their mutation coverage are
      fixed above.

## Dependencies and constraints

- **Parent roadmap.** Canonical reference
  `0004-adoption-template-split/0003-split-guard-tests`, `parent:
  0004-adoption-template-split`. Readiness is satisfied: the `Children` table
  names `0001-adopter-template-split` and `0002-bootstrap-quickstart-rework`
  (`roadmap.md:80`), and both have a committed `ship.md` (PR #13 and PR #14), so
  their dependencies are satisfied.
- **Consumed contract.** The `0001` split contract
  (`docs/customization.md:21-40`) and the `0002` quickstart copy mapping
  (`README.md:49-51`, `60-70`) are the authorities these guards read; this item
  does not reshape them.
- **Existing committed agreements.** `tests/checks/90-packaging.sh`
  (`AC18`–`AC20`), `tests/checks/40-inventory.sh` (`AC9`),
  `tests/checks/50-instructions.sh` (`AC10`), `tests/checks/30-permissions.sh`
  (`AC8`), and `tests/checks/10-readiness.sh` (`AC6`) must stay green (AC1).
  `tests/mutation.sh` must stay green and gain the new area (AC8).
- **Suite invariants.** The suite is read-only against the repository, never reads
  `work/**`, runs on a fresh clone, is provider-neutral, and is Bash 3.2
  compatible (`tests/README.md:29-30`, `tests/lib.sh:14-15`). Adding a check is
  adding a file; the runner needs no edit (`tests/run.sh:38-49`).
- **Scope.** `tests/**` and `tests/README.md` only. No change to
  `AGENTS.md`, `opencode.json`, `.gitignore`, `template/**`, `README.md`,
  `docs/**`, `.opencode/**`, or `.github/**`; the guards assert against those
  surfaces, they do not edit them.
- **No new tooling.** No runtime dependency, install step, network access, or CI
  change; the guards use the bash+git assumptions the suite already makes.
- **Read-only guard.** The product agent writes only under `work/**` (this
  specification) and changes no source, doc, config, or test.
