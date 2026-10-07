---
feature: 0004-adoption-template-split/0002-bootstrap-quickstart-rework
phase: spec
status: final
created: 2026-10-06
updated: 2026-10-06
notes: ""
parent: 0004-adoption-template-split
---

# Bootstrap and quickstart rework

## Problem

Child `0001-adopter-template-split` (shipped) separated adopter-pristine sources
from the framework repository's maintainer-bootstrapped copies and documented the
split contract, but the adoption path still consumes the maintainer copies.
`README.md:49` tells an adopter to copy the framework's root `AGENTS.md`,
`opencode.json`, and `.gitignore` — and root `AGENTS.md` now carries the
framework's own filled Project profile. Running the documented quickstart
therefore ships maintainer configuration into a downstream repository, the exact
hazard the split exists to prevent.

The `/bootstrap` agent that configures those copied files is likewise unaware of
the split: its edit permissions match the adopter-pristine `template/**` sources
as readily as the adopter's own files (`bootstrap.md:7-12`), so a maintainer-run
`/bootstrap` can silently overwrite the pristine sources, and its
detect/confirm/apply steps and quality bar do not say which copy it is meant to
fill. The surfaces that describe the copied set (`README.md:42-91`,
`docs/customization.md:64-67`, `tests/README.md:5-11`, `CONTRIBUTING.md:121-128`)
still present a single ambiguous copy story, so an adopter cannot tell which
files they receive and a maintainer cannot tell which are theirs.

**Decision (user, 2026-10-06):** the quickstart copies the adopter-pristine files
per-file to their destination names; the `/bootstrap` rework is instruction
changes plus a hard guard against editing the adopter-pristine sources; the
reconciled surfaces are the roadmap-named set plus `CONTRIBUTING.md`.

## Goals

- The documented quickstart copies the adopter-pristine source for each of the
  three bootstrap-mutable files — `AGENTS.md`, `opencode.json`, `.gitignore` — so
  no maintainer-bootstrapped value reaches an adopter.
- An adopted repository's root layout is unchanged and contains no `template/`
  directory after the quickstart runs.
- `/bootstrap` fills the adopter's own copies and cannot modify the framework
  repository's adopter-pristine sources.
- Every surface that enumerates the copy set states each file's source
  unambiguously and agrees with the `0001` split contract.
- The committed suite and the opt-in mutation self-check remain green.

## Non-goals

- Standing up or reshaping the split, the `template/` layout, or the framework
  repository's own bootstrapped Project profile — child `0001` (shipped).
- Adding committed split-guard tests — child `0003`.
- Aligning `/doctor` with the split — child `0004`.
- The command-signature/usage-string sweep and the `ask.md` description — child
  `0005`.
- Templating `docs/*.md`; per the `0001` decision they stay shared verbatim.
- Changing the destination membership of the copy set, the lifecycle, artifact
  formats, the state model, or the framework's model, default-agent, and MCP
  policy; and re-opening the packaging/versioning decisions of
  `0003-framework-quality-hardening`.
- Introducing any runtime dependency, install step, network access, or a
  post-copy migration/relocation tool.

## Users and stories

- **As an** adopting engineer, **I want** the documented quickstart to copy
  unbootstrapped, placeholder files, **so that** I never inherit the framework
  maintainers' configuration.
- **As a** framework maintainer, **I want** `/bootstrap` to be unable to
  overwrite the adopter-pristine sources, **so that** the adoption template
  cannot be silently corrupted.
- **As an** adopter, **I want** every surface that describes the copied set to
  agree, **so that** the quickstart, `/bootstrap`, and the documentation never
  contradict one another.

## Acceptance criteria

1. **AC1** — Given the framework repository after this item, when the quickstart
   copy commands in `README.md` are inspected, then each of `AGENTS.md`,
   `opencode.json`, and `.gitignore` is copied from its adopter-pristine source
   under `template/`, and none is copied from the framework repository's root
   copy.

2. **AC2** — Given the documented quickstart run in an otherwise empty adopting
   project, when it completes, then the project root has an `AGENTS.md` whose
   Project profile is the unfilled placeholder, an `opencode.json` and
   `.gitignore` equal to the adopter-pristine sources, and no `template/`
   directory.

3. **AC3** — Given the `bootstrap` agent after this item, when its resolved edit
   permissions are inspected, then an edit to any path under the adopter-pristine
   source directory (`template/`) is denied, while the adopter's own root
   `AGENTS.md`, `opencode.json`, and `.gitignore` remain editable.

4. **AC4** — Given the `bootstrap` agent and its command after this item, when
   their instructions are read, then they state that `/bootstrap` fills the
   adopter's own `AGENTS.md`, `opencode.json`, and `.gitignore` — the copies an
   adopter received from the adopter-pristine sources — and that it must never
   modify the framework repository's adopter-pristine sources.

5. **AC5** — Given each copy-set surface after this item — `README.md`,
   `docs/customization.md`, `tests/README.md`, and `CONTRIBUTING.md` — when read,
   then it names `template/` as the adopter's source for `AGENTS.md`,
   `opencode.json`, and `.gitignore`, distinguishes the framework repository's
   own copies, and states that `.opencode/{agent,command,skill}` and `docs/*.md`
   are shared verbatim.

6. **AC6** — Given any copy-set surface after this item, when compared with the
   split contract, then none claims or implies that an adopter receives the
   framework repository's root `AGENTS.md`, `opencode.json`, or `.gitignore`.

7. **AC7** — Given the repository after this item, when the committed suite
   `bash tests/run.sh` is run, then it exits 0, so the packaging, inventory,
   instruction, readiness, and lifecycle agreements are not regressed.

8. **AC8** — Given the repository after this item, when the opt-in mutation
   self-check `bash tests/mutation.sh` is run, then it reports zero failed
   mutations.

9. **AC9** — Given an adopting project that already has an `AGENTS.md`,
   `opencode.json`, or `.gitignore`, when the quickstart advisory after this item
   is read, then it still directs the adopter to merge rather than overwrite, and
   adds no migration or deletion step.

## Edge cases

- **Placeholder fidelity.** The `AGENTS.md` an adopter receives must present the
  placeholder Project profile, not the framework's filled profile, even though
  both files are named `AGENTS.md`; the source path is the sole discriminator.
- **Byte-identical pristine pair.** `template/opencode.json` and
  `template/.gitignore` are currently byte-identical to the framework's copies;
  they must still be sourced from `template/` so the contract holds once they
  diverge.
- **Already-adopted repositories.** Re-running the quickstart must not introduce,
  require, or conflict with a `template/` directory; existing root files are
  merged, never overwritten or deleted.
- **Framework-repo self-run.** A maintainer who runs `/bootstrap` in the
  framework repository must not modify the adopter-pristine sources, and the
  existing "the repository looks bootstrapped — ask before overwriting" behavior
  is preserved.
- **Context mismatch.** The bootstrap instructions are copied into adopter
  repositories, where no `template/` directory exists; wording must be truthful
  and non-misleading in both the framework repository and an adopted project.
- **Verbatim-copied docs.** `docs/customization.md` is copied to adopters, so any
  framework-repository-specific wording added must read as framework
  organization, not as an instruction to an adopter.
- **Copy globs.** The `docs/*.md` copy glob must not reach the `template/`
  sources, and no single copy step may capture both an adopter-pristine source
  and a maintainer copy.
- **Missing or renamed pristine source.** If a source named by the quickstart or
  the contract is absent, the failure must be evident rather than silently
  copying a maintainer file.
- **Guard over-reach.** The template guard must not deny the adopter's own root
  files when `/bootstrap` legitimately fills them.

## Open questions

- [x] How deep the `/bootstrap` rework goes — **Resolved (user, 2026-10-06):**
      instruction rework plus a hard guard that denies edits under the
      adopter-pristine source directory.
- [x] Which surfaces are reconciled — **Resolved (user, 2026-10-06):**
      `README.md`, `.opencode/agent/bootstrap.md` and its command,
      `docs/customization.md`, `tests/README.md`, and `CONTRIBUTING.md`.
- [x] How the quickstart consumes the pristine sources — **Resolved (user,
      2026-10-06):** per-file copy to destination names; no `template/`
      directory appears in an adopted repository.
- [ ] The exact instruction wording and guard placement that make an edit under
      `template/` resolve to deny while the adopter's own root files stay
      editable — owner: architect, needed by: `/plan`. **Assumption:** the
      guard is expressed in the bootstrap agent's resolved edit rules; the
      outcome in AC3 is fixed, its representation is not.
- [ ] Whether a committed guard proving the quickstart copies the pristine
      sources is added here or by child `0003` — owner: architect, needed by:
      `/plan`. **Assumption:** `0003` owns committed split guards; this item only
      keeps the existing agreements green (AC7).

## Dependencies and constraints

- **Parent roadmap.** Canonical reference
  `0004-adoption-template-split/0002-bootstrap-quickstart-rework`, `parent:
  0004-adoption-template-split`. Its dependency `0001-adopter-template-split` is
  satisfied: that child's `ship.md` exists (PR #13), so readiness holds and this
  item consumes the split rather than standing it up.
- **Consumed contract.** The split contract established by `0001` in
  `docs/customization.md:21-40` (per-file adopter-pristine source vs. framework
  copy; single-source shared-verbatim remainder) is the authority this item
  propagates; it is not rewritten here.
- **Existing committed agreements.** `tests/checks/90-packaging.sh` (AC18–AC20),
  `tests/checks/40-inventory.sh`, `tests/checks/50-instructions.sh`, and
  `tests/mutation.sh` must stay green (AC7, AC8). `tests/checks/**` is owned by
  child `0003` and must not be changed here; `tests/README.md` prose may be
  updated and must remain compliant with the copy-set agreement that scans it.
- **Live contract location is fixed.** Root `AGENTS.md` remains the framework
  repository's loaded contract; the adopter-pristine source is additional and
  must not become the framework's instructions.
- **No open leak window may ship.** This item closes the accepted intermediate
  quickstart leak window left by `0001`; no release or cutover may be published
  while the documented quickstart still names the framework's root copies.
- **Scope.** Framework-internal prompt/doc/config/test only: `README.md`,
  `CONTRIBUTING.md`, `docs/customization.md`, `.opencode/agent/bootstrap.md`,
  `.opencode/command/bootstrap.md`, and `tests/README.md`. No installed runtime
  dependency, install step, or network access is introduced.
- **Read-only guard.** The product agent writes only under `work/**` (this
  specification) and changes no source, doc, config, or test.
