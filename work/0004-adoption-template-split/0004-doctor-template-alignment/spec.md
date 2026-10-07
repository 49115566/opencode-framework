---
feature: 0004-adoption-template-split/0004-doctor-template-alignment
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Ready: Depends on 0001-adopter-template-split and 0002-bootstrap-quickstart-rework, both satisfied (ship.md present; PRs #13 and #14). User decisions (2026-10-07): extend the diagnostic's declared inputs, temp-path scan, and completeness handling to the adopter-facing template sources; close the README Agents-table maintainer-only label residual; leave the adopter template's own /doctor references as-is. Committed split guards remain child 0003's; no tests/checks change."
parent: 0004-adoption-template-split
---

# Doctor alignment with the adoption template split

## Problem

`/doctor` is the framework's only drift detector, and after the adoption-template
split its coverage no longer matches the repository it audits. The split added an
adopter-facing, always-copied `AGENTS.md` under `template/`
(`work/0004-adoption-template-split/0001-adopter-template-split/design.md:141-149`),
documented it in the README `## Layout` block (`README.md:274-277`), and pointed
the quickstart at it (`README.md:49-51`). But the diagnostic still reads a single
`AGENTS.md` and enumerates only root-level and `.opencode/` surfaces: its declared
inputs are `.opencode/**`, `README.md`, root `AGENTS.md`, `docs/workflow.md`,
`.gitignore`, and `docs/` (`.opencode/agent/doctor.md:50-62`); its temp-path scan
covers `README.md`, root `AGENTS.md`, `docs/`, and `.opencode/**` but never
`template/` (`doctor.md:112-114`); and its required-surface completeness rule names
only `README.md` and root `AGENTS.md` (`doctor.md:156-179`).

The consequence is a false-clean: an adopter-facing template that drifts from the
on-disk inventory, or that carries an instruction directing output to a system temp
path, is invisible to the detector, which can still print `No findings —
repository is consistent.` (`doctor.md:126-130`). For a detector, a clean report
that is not actually clean is worse than a finding. The users affected are
**framework maintainers**, who trust that clean output, and **adopters**, who
receive the `template/`-sourced files and would ship an inconsistency the framework
never caught.

The split also leaves the maintainer-only labeling goal from the shipped
`0004-doctor-scope` incomplete: the README Agents table's `doctor` row carries no
maintainer-only marker (`README.md:224`) even though the Commands row
(`README.md:204`), both descriptions (`doctor.md:2`,
`.opencode/command/doctor.md:2`), `AGENTS.md`, and `docs/workflow.md` do. The
shipped review flagged this as a non-blocking residual and recommended a note below
the table (`work/0003-framework-quality-hardening/0004-doctor-scope/review.md:81-92`).

## Goals

- The diagnostic's declared inputs include the split's adopter-facing template
  documents, so a drift in the adopter copy is observable to the detector rather
  than silently ignored.
- The diagnostic's out-of-workspace temp-path check covers the adopter-pristine
  template sources, so a temp instruction that would ship to adopters is reported.
- The diagnostic's required-surface handling treats the adopter-facing template as
  a surface: absent or unreadable yields one clear finding, never silence and never
  a per-item cascade.
- The diagnostic's README-derived inventory and count facts remain in agreement
  after the split, with no false findings from the new `template/` layout entry.
- Expected pristine state — an unfilled Project profile, byte-identical pristine
  config files, a maintainer-only directory — is not reported as drift.
- `/doctor` and the `doctor` agent are labeled framework-maintainer-only on every
  surface where they are documented, including the README Agents table.
- The diagnostic remains read-only and maintainer-only, and the new coverage
  extends the existing checks rather than redesigning the catalogue or duplicating
  the committed split guards owned by `0003`.

## Non-goals

- Re-opening the shipped `0004-doctor-scope` decisions: the maintainer-only
  audience, keeping `README.md` out of the always-loaded instructions, durable
  symbolic examples, and completeness derived from `docs/workflow.md` all stand.
- Adding committed split-guard tests or editing `tests/checks/**` — child
  `0003-split-guard-tests`.
- Rewriting the quickstart, `/bootstrap`, or the split contract — children `0001`
  and `0002` (shipped).
- The command-signature/usage-string sweep and the `ask.md` description — child
  `0005-surface-consistency-sweep`.
- Removing or rewording the adopter template's own `/doctor` and `doctor`
  references: they are explicitly labeled framework-maintainer-only and describe
  the framework's full surface (resolved: leave as-is, 2026-10-07).
- Making `/doctor` adopter-usable, or adding `README.md` to the always-loaded
  instruction set.
- Changing the doctor agent's read-only permission block, its audience, the
  `template/` layout, or the destination membership of the copied set.
- Introducing any runtime dependency, install step, or network access.

## Users and stories

- **As a** framework maintainer, **I want** `/doctor` to read and validate the
  adopter-facing template documents too, **so that** a clean report means the
  repository is genuinely consistent, not just the surfaces the detector happened
  to look at.
- **As an** adopter, **I want** the files the quickstart copies to be covered by
  the framework's drift detection, **so that** a temp-path instruction or a stale
  supporting list in my `AGENTS.md` is caught before it reaches my repository.
- **As a** framework maintainer, **I want** `/doctor` labeled maintainer-only
  everywhere it appears, **so that** no reader mistakes it for a command an
  adopted repository provides.

## Acceptance criteria

1. **AC1** — Given the doctor agent after this item, when its declared set of
   documentation surfaces is inspected, then the adopter-facing
   `template/AGENTS.md` is among the surfaces it reads, alongside root `AGENTS.md`
   and `README.md`.

2. **AC2** — Given the doctor agent after this item, when its out-of-workspace
   temp-path check is inspected, then the adopter-pristine template directory is a
   scanned location, so an absolute system-temp path in a template document is
   reported with its file and line.

3. **AC3** — Given the doctor agent after this item, when its required-surface
   handling is inspected, then the adopter-facing `template/AGENTS.md` is a
   required surface: absent or unreadable produces exactly one finding naming the
   missing surface, and dependent checks are skipped without emitting one finding
   per inventory item.

4. **AC4** — Given the framework repository after this item, when the adopter-facing
   template's supporting agent and command lists diverge from the on-disk
   inventory, then the diagnostic reports the divergence, naming both the surface
   and the item.

5. **AC5** — Given the framework repository after this item, when `/doctor` runs,
   then it reports the checked counts (agents, commands, skills) consistent with
   the on-disk inventory and emits no `COUNT-MISMATCH` or inventory finding caused
   by the `template/` entry in the README `## Layout` block.

6. **AC6** — Given the framework repository with its expected pristine template,
   when `/doctor` runs, then it reports no finding merely because
   `template/AGENTS.md` presents the unfilled placeholder Project profile, because
   the pristine `opencode.json` and `.gitignore` are identical to the framework's
   copies, or because the template directory is maintainer-only.

7. **AC7** — Given the README after this item, when the Agents table documenting
   `doctor` is read, then the `doctor` entry is identified as
   framework-maintainer-only, while the table's compared capability cells for that
   row are unchanged.

8. **AC8** — Given every surface where `/doctor` or the `doctor` agent is
   documented after this item — the README Commands table and Agents table, the
   `AGENTS.md` supporting-commands and supporting-agents lists, `docs/workflow.md`,
   and the agent and command descriptions — when each is read, then each identifies
   it as framework-maintainer-only and none omits the marker.

9. **AC9** — Given `/doctor` runs after this item, when it completes, then it has
   created, edited, moved, or deleted no file and run no write command; its
   read-only guarantee is unchanged.

10. **AC10** — Given the doctor agent and command after this item, when their
    descriptions of the checked surfaces are compared, then they agree, the
    maintainer-only audience is unchanged, and the existing catalogue of checks is
    preserved with the new coverage added rather than replaced.

11. **AC11** — Given the repository after this item, when the committed suite
    `bash tests/run.sh` is run, then it exits 0, so no existing inventory, count,
    permission, packaging, or instruction agreement regresses.

## Edge cases

- **Expected placeholder profile.** The adopter template is *supposed* to carry
  the unfilled Project profile, so the diagnostic must not treat it as drift; only
  the surfaces it already audits (inventory, counts, permissions, ignore rules,
  temp paths) apply to the template.
- **Byte-identical pristine files.** `template/opencode.json` and
  `template/.gitignore` are currently identical to the framework's copies
  (`0001/design.md:43-49`); that is valid and must not be reported.
- **Missing or unreadable template surface.** `template/AGENTS.md` deleted or
  unreadable yields exactly one finding about the missing surface, not one per
  inventory item, and does not suppress findings from surfaces that do not depend
  on it.
- **Adopter context.** `/doctor` is maintainer-only and only authoritative in the
  framework repository, where `template/` exists; run elsewhere, the existing
  single-missing-surface behavior is preserved rather than a new cascade.
- **Layout block confusion.** The `template/` lines in the README `## Layout`
  block must not be mistaken for agent, command, or skill counts.
- **Drift in the adopter copy.** An on-disk agent or command added without
  updating the template's supporting lists, or a root `AGENTS.md` list updated
  without the template, is reported (the new coverage); the reverse — a template
  name with no on-disk item — is also reported.
- **Self-reference.** The diagnostic's own definition of the temp-path rule,
  wherever it describes the policy, must not be flagged as directing a write
  there (existing behavior preserved).
- **No new instruction file.** Adding the template to the diagnostic's inputs must
  not add a new file to the always-loaded instruction set in `opencode.json`.
- **Wrong working directory.** Invoked from a subdirectory, `/doctor` still
  resolves the framework root rather than the process working directory (existing
  behavior preserved).
- **Concurrent activity.** Running `/doctor` while another agent edits files
  neither corrupts state nor writes.

## Open questions

- [x] How far to extend the diagnostic's coverage of the split — **Resolved (user,
      2026-10-07):** extend the declared inputs, the temp-path scan, and the
      required-surface/completeness handling to the adopter-facing template; add no
      committed test (that remains child `0003`).
- [x] Whether to close the README Agents-table maintainer-only residual —
      **Resolved (user, 2026-10-07):** close it.
- [x] How to treat the adopter template's own `/doctor` and `doctor` references —
      **Resolved (user, 2026-10-07):** leave as-is.
- [ ] The exact placement and wording of the README Agents-table maintainer-only
      marker, such that it labels the surface without altering a capability cell
      the diagnostic compares — owner: architect, needed by: `/plan`.
      **Assumption:** a note below the table, as the shipped review recommended
      (`0004-doctor-scope/review.md:88-92`).
- [ ] Whether the adopter template's supporting lists are validated for full
      name coverage or only for surface presence — owner: architect, needed by:
      `/plan`. **Assumption:** full coverage, mirroring the rule already applied to
      root `AGENTS.md`, because the template is the adopter's copy of the same
      contract.
- [ ] Whether `template/opencode.json` and `template/.gitignore` need any coverage
      beyond the directory-level temp-path scan — owner: architect, needed by:
      `/plan`. **Assumption:** none; only documentation surfaces are scanned for
      temp paths.

## Dependencies and constraints

- **Parent roadmap.** Canonical reference
  `0004-adoption-template-split/0004-doctor-template-alignment`, `parent:
  0004-adoption-template-split`. Readiness holds: its `Depends on` cells name
  `0001-adopter-template-split` and `0002-bootstrap-quickstart-rework`, both
  satisfied by their `ship.md` files (PRs #13 and #14).
- **Consumed contract.** The split's per-file mapping
  (`docs/customization.md:21-40`) and the quickstart copy commands
  (`README.md:44-54`) define the adopter-facing sources this item teaches the
  diagnostic about.
- **Boundary with shipped `0004-doctor-scope`.** This item extends that work; it
  must not re-implement, fork, or re-open the audience, read-only, example, or
  completeness decisions. Closing the README Agents-table residual is the
  extension the shipped review itself recommended, not a re-open.
- **Boundary with `0003-split-guard-tests`.** Committed split guards belong to
  `0003`. This item changes no `tests/checks/**` file or committed guard and must
  keep the existing suite green (AC11).
- **Boundary with `0005-surface-consistency-sweep`.** The command-signature and
  usage-string sweep and the `ask.md` fix are out of scope; this item touches only
  the doctor surfaces and the README labeling.
- **Live contract location is fixed.** Root `AGENTS.md` stays the framework's
  loaded contract; the template is the adopter copy. The diagnostic reads both, but
  the template must never become the framework's instructions.
- **Scope.** Framework-internal prompt/doc only: the `doctor` agent and its
  command, and `README.md`. No installed runtime dependency, install step, or
  network access is introduced.
- **Read-only guard.** The product agent writes only under `work/**` (this
  specification) and changes no source, doc, config, or test.
