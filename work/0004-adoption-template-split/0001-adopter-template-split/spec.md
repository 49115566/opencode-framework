---
feature: 0004-adoption-template-split/0001-adopter-template-split
phase: spec
status: final
created: 2026-10-06
updated: 2026-10-06
notes: ""
parent: 0004-adoption-template-split
---

# Adopter/maintainer template split

## Problem

`AGENTS.md` is simultaneously the framework repository's live, always-loaded
contract and the template the adoption quickstart copies into other repositories
(`README.md:49`, `.opencode/agent/bootstrap.md:70-73`, `opencode.json:6-10`). Its
`## Project profile` is the unfilled placeholder template (`AGENTS.md:11-24`);
filling it with the framework's verified values — the entire purpose of
`/bootstrap` — would ship the maintainers' bootstrapped configuration to every
adopter (`work/0003-framework-quality-hardening/0009-surface-consistency/spec.md:19-30`).

The same hazard applies to the other files the quickstart copies and `/bootstrap`
mutates: `opencode.json` and `.gitignore` (`.opencode/agent/bootstrap.md:86-100`).
Because there is currently no distinction between "the file the framework
repository uses" and "the file adopters receive," maintainers cannot bootstrap
their own repository without contaminating the adoption template, and adopters can
receive maintainer-specific configuration that `/bootstrap` was meant to fill in
fresh. The copy set is described only in prose and asserted only partially
(`tests/README.md:5-11`, `docs/customization.md:43-51`,
`tests/checks/90-packaging.sh:87-198`).

**Decision (user, 2026-10-06):** the adopter-pristine set is the
bootstrap-mutable set — `AGENTS.md`, `opencode.json`, `.gitignore` — while
`docs/*.md` stay shared verbatim. This child stands up the split only; rewiring
the quickstart and `/bootstrap` is child `0002-bootstrap-quickstart-rework`.

## Goals

- A designated adopter-pristine source of truth exists for each copied file
  `/bootstrap` mutates — `AGENTS.md`, `opencode.json`, `.gitignore` — separate
  from the framework repository's own maintainer-bootstrapped copies.
- The framework repository's own `AGENTS.md` Project profile is filled with
  verified framework values and contains no placeholder text, while the
  adopter-pristine `AGENTS.md` continues to present the unfilled placeholder
  template.
- The split is documented as an unambiguous per-file contract: for each of the
  three files, which copy is adopter-pristine and which is the framework's own
  maintainer copy, and that `docs/*.md` are shared verbatim.
- No maintainer-bootstrapped value is reachable through the adopter-pristine
  source for any of the three files.
- The framework repository's existing committed agreements remain green, so the
  split does not regress packaging, inventory, or instruction behavior.

## Non-goals

- Rewiring the quickstart's copy commands, `/bootstrap`'s detect/confirm/apply
  behavior, or the prose that describes the copied set — child
  `0002-bootstrap-quickstart-rework` consumes the split.
- Adding committed guard tests for the split — child `0003-split-guard-tests`.
- Aligning `/doctor` with the split — child `0004-doctor-template-alignment`.
- The command-signature/usage-string sweep and the `ask.md` description — child
  `0005-surface-consistency-sweep`.
- Templating `docs/*.md`; per the user decision they remain shared verbatim
  between the two audiences.
- Changing the lifecycle, artifact formats, permission model, or state model.
- Changing the framework's model, default-agent, or MCP policy, or re-opening the
  packaging/versioning decisions of `0003-framework-quality-hardening`.
- Introducing any runtime dependency, install step, or network access.

## Users and stories

- **As a** framework maintainer, **I want** to fill the framework repository's
  own Project profile without leaking it to adopters, **so that** `/bootstrap`
  works correctly for this repository too.
- **As an** adopting engineer, **I want** the quickstart to receive an
  unbootstrapped, placeholder template, **so that** I never inherit the
  maintainers' configuration.
- **As a** framework maintainer, **I want** one documented per-file split
  contract, **so that** `/bootstrap`, the quickstart, `/doctor`, and the tests
  all agree on which file adopters receive.

## Acceptance criteria

1. **AC1** — Given the framework repository after this item, when the
   adopter-pristine source for each of `AGENTS.md`, `opencode.json`, and
   `.gitignore` is inspected, then each source exists and contains no value
   bootstrapped for the framework repository (no filled Project profile, no
   framework-repo-specific configuration).

2. **AC2** — Given the framework repository's own `AGENTS.md` after this item,
   when its Project profile is inspected, then every profile field holds a
   verified framework value or an explicit `none`, and no placeholder or example
   text remains.

3. **AC3** — Given the adopter-pristine `AGENTS.md` after this item, when
   inspected, then its Project profile still presents the placeholder template
   with no framework values, so an adopter's `/bootstrap` fills it fresh.

4. **AC4** — Given the split-contract documentation after this item, when read,
   then for each of `AGENTS.md`, `opencode.json`, and `.gitignore` it names both
   the adopter-pristine source and the framework's own copy, and it states that
   `docs/*.md` are shared verbatim; no copied file is left ambiguous.

5. **AC5** — Given the adopter-pristine source for each of the three files, when
   it is compared against the framework's own copy, then no maintainer-bootstrapped
   value present in the framework copy appears in the pristine source.

6. **AC6** — Given the repository after this item, when the committed suite
   `bash tests/run.sh` is run, then it passes, so the existing packaging,
   inventory, and instruction agreements are not regressed.

7. **AC7** — Given the framework repository after this item, when opencode's
   configuration is loaded, then the configuration parses and the
   maintainer-bootstrapped `AGENTS.md` is the contract in effect, with the
   adopter-pristine source not loaded as the framework's own instructions.

## Edge cases

- **Byte-identical copies.** An adopter-pristine source may legitimately be
  identical to the framework's copy where nothing maintainer-specific exists;
  the split must still designate it explicitly so the mapping is unambiguous.
- **Prompt-only repository.** The framework repository has no conventional
  install/lint/typecheck/format/build stack; a filled profile whose fields are an
  explicit `none` (and whose Test field names the committed suite) is valid and
  must not be mistaken for a placeholder.
- **Unprotected intermediate window.** Until child `0002` rewires the quickstart,
  the documented copy path still names the framework's live files; this child's
  acceptance must hold without `0002`, and the contract must name the intended
  pristine target so `0002` has something to consume.
- **Ambiguous copy globs.** If a pristine source and a maintainer copy both fall
  under a copied glob, an adopter could receive both; the contract (AC4) must make
  the copy set unambiguous.
- **Already-adopted repositories.** The split must not change merge semantics for
  an existing `AGENTS.md`, `opencode.json`, or `.gitignore` in an adopter's repo.
- **Always-loaded instruction cost.** Designating the documentation surface for
  the contract must not silently add an always-loaded instruction file or change
  the documented token cost (`docs/customization.md:21-46`).
- **Root layout agreement.** If the split introduces a new top-level path, the
  README `## Layout` section must remain in agreement with disk
  (`tests/checks/90-packaging.sh:200-277`).
- **Partially filled profile.** Filling the framework profile must not leave it
  half-converted between placeholders and values.

## Open questions

- [x] Which copied files get an adopter-pristine source, and how do the
      framework's own copies diverge? **Resolved (user, 2026-10-06):** the
      bootstrap-mutable set — `AGENTS.md`, `opencode.json`, `.gitignore`;
      `docs/*.md` stay shared verbatim.
- [x] Does this child rewire the adoption copy path, or only stand up the split?
      **Resolved (user, 2026-10-06):** stand up the split only; quickstart and
      `/bootstrap` rework belongs to child `0002-bootstrap-quickstart-rework`.
- [ ] Where the adopter-pristine sources live and how they are represented
      (dedicated location vs. distinct naming) — owner: architect, needed by:
      `/plan`. **Deferred:** representation is a design decision; the roadmap
      flags it as a genuine fork
      (`work/0004-adoption-template-split/roadmap.md:120-124`).
- [ ] The exact verified values for the framework's own Project profile — owner:
      builder/architect, needed by: `/build`. **Assumption:** the framework is a
      prompt-only repository, so Test names the committed suite and
      install/lint/typecheck/format/build are `none`.
- [ ] Whether a single machine-readable copy-set definition is introduced —
      owner: architect, needed by: `/plan`. **Assumption:** this child must make
      the split unambiguous (AC4) but is not required to introduce a manifest.

## Dependencies and constraints

- **Parent roadmap.** Canonical reference
  `0004-adoption-template-split/0001-adopter-template-split`, `parent:
  0004-adoption-template-split`. Readiness is satisfied: the roadmap's
  `Depends on` cell is `—`.
- **Sibling boundaries.** `0002` consumes the split, `0003` guards it, `0004`
  aligns `/doctor`, and `0005` performs the surface sweep. This child must not
  pre-empt any of them.
- **Existing committed agreements.** `tests/checks/40-inventory.sh`,
  `tests/checks/50-instructions.sh`, and `tests/checks/90-packaging.sh` must stay
  green (AC6).
- **Live contract location is fixed.** `opencode.json:6-10` loads root
  `AGENTS.md` as the framework's instructions, so the framework's live contract
  remains at its current location; the adopter-pristine source is additional, not
  a replacement for the live file.
- **Scope.** Framework-internal and prompt/config/doc/test only: root `AGENTS.md`,
  `opencode.json`, `.gitignore`, `docs/`, `.opencode/agent/bootstrap.md` (context
  only), and `tests/`. No installed runtime dependency, install step, or network
  access is introduced.
- **Read-only guard.** The product agent writes only under `work/**` (this
  specification) and changes no source, doc, config, or test.
