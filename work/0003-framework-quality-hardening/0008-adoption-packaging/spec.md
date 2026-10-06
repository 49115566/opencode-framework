---
feature: 0003-framework-quality-hardening/0008-adoption-packaging
phase: spec
status: final
created: 2026-10-06
updated: 2026-10-06
notes: "Roadmap child; dependencies=— (ready). User-resolved framing decisions: MIT license; SemVer + annotated tags + GitHub Releases + Keep a Changelog; dedicated root version manifest as the single source of truth; documentation-only release policy with a seeded changelog; packaging files are framework-repo/maintainer-only and not copied by the adopter quickstart."
parent: 0003-framework-quality-hardening
---

# Adoption packaging and versioning

## Problem

The framework is distributed by copying its files into arbitrary repositories
(`README.md:38-52`), but it ships no license, contribution guide, changelog, or
version identifier, and documents no versioning or release model. Without a
license, the repository is "all rights reserved" by default, so the copying
workflow the framework is built around is legally unresolved — a practical
blocker for the adopters this framework targets. Without a version identifier or
release history, an adopter cannot pin or compare a known-good revision, and a
maintainer has no documented, repeatable way to cut a release. Because the
quickstart's copied-file set is described in three surfaces — `README.md:44-52`,
`tests/README.md:5-8`, and `docs/customization.md:44-46` — adding root files
without stating their status would also let those surfaces drift.

## Goals

- The framework carries an explicit, OSI-approved open-source license, so it can
  be legally copied into arbitrary repositories.
- Exactly one authoritative framework version is discoverable at the repository
  root, and the versioning scheme that produces it is documented.
- A documented release model states how a version is cut, tagged, and published,
  consistent with the version identifier and the changelog.
- A changelog records changes from the introduced version forward in a standard,
  human-readable format; earlier history is not reconstructed.
- A contributor guide explains how to contribute, run the committed test suite,
  and perform a release.
- Every surface that describes the adopter quickstart or copied-file set agrees
  that the license, contribution guide, changelog, and version manifest are
  framework-repo/maintainer-only and are not copied into adopter repositories.
- The committed test suite stays green and guards the new agreements against
  drift.

## Non-goals

- Release automation. Tagging and publishing are manual maintainer actions; no
  tag-triggered CI release workflow is added.
- Backfilling changelog entries for releases before the version introduced here.
- Changing the adopter quickstart's copy mechanism, or adding any new file to
  the copied set.
- Package-registry distribution (for example, publishing the framework as an npm
  package) or any other consumption model beyond copy-the-files.
- Dual-licensing, per-file license headers, or per-component licensing.
- Changing the default agent, model, permissions, MCP configuration, or any
  other `opencode.json` behavior (owned by child `0007-config-hardening`).
- The framework's own project profile, command usage strings, and other surface
  inconsistencies (owned by child `0009-surface-consistency`).
- Introducing any new runtime dependency, install step, or network requirement.

## Users and stories

- **As an adopter**, I want an explicit license and a version identifier, so that
  I can legally copy the framework and pin a known-good revision.
- **As an adopter**, I want the quickstart to tell me clearly which files are
  mine to copy and which are framework-maintainer tooling, so that I do not copy
  files that do not belong in my repository.
- **As a framework maintainer**, I want a documented versioning and release
  model plus a changelog and contribution guide, so that I can cut consistent
  releases and review contributions predictably.
- **As a framework maintainer**, I want a committed check that fails when the
  version, changelog, and copy-set documentation disagree, so that the packaging
  surface cannot silently drift.

## Acceptance criteria

1. **AC1** — Given the framework repository root, when a reader inspects it, then
   it contains a license file holding the full, unmodified MIT license text
   including a copyright notice, and `README.md` names MIT as the license and
   links to that file.
2. **AC2** — Given the framework repository root, when a reader looks for the
   framework's version, then exactly one root-level version manifest holds the
   current version, and no other repository file is required to determine it.
3. **AC3** — Given the version manifest, when its contents are parsed, then it
   contains exactly one version string conforming to SemVer
   `MAJOR.MINOR.PATCH` (with optional pre-release and build metadata), and the
   documented release model names this manifest as the single source of truth.
4. **AC4** — Given the repository root, when a reader opens the changelog, then
   it is headed with the project name, contains an `Unreleased` section, and
   contains a released section whose heading carries a version and an
   ISO-8601 date and whose entries are grouped under Keep a Changelog
   categories.
5. **AC5** — Given the most recent released section of the changelog and the
   version in the manifest, when both are read, then the section's version equals
   the manifest version; the two may not disagree.
6. **AC6** — Given the changelog, when it is read, then it contains no entries
   for versions released before the version introduced by this change.
7. **AC7** — Given the contribution guide, when a maintainer reads it, then it
   states how to propose a change, how to run the committed test suite, the
   commit and branch conventions, and the ordered steps to cut a release, and it
   links to `docs/workflow.md` and `docs/customization.md`.
8. **AC8** — Given the documented release model, when a maintainer follows it,
   then it specifies how a release classifies its change as a SemVer
   MAJOR/MINOR/PATCH increment, that the release is captured by an annotated git
   tag, that it is published as a GitHub Release, and that it requires a
   changelog entry; and it states that tagging and publishing are manual, not CI
   automated.
9. **AC9** — Given each surface that describes the adopter quickstart or copied
   file set (`README.md`, `tests/README.md`, and `docs/customization.md`), when
   each is read, then all three state that the license, contribution guide,
   changelog, and version manifest are framework-repo/maintainer-only and are not
   part of the copied set, and none of them lists any of those files as copied.
10. **AC10** — Given the quickstart copy instructions in `README.md`, when a
    reader follows them literally, then no command copies the license,
    contribution guide, changelog, or version manifest into the target
    repository.
11. **AC11** — Given the pre-change repository, when the committed test suite is
    run after this change, then it exits 0.
12. **AC12** — Given the version manifest and the changelog can drift, when the
    changelog's most recent released version disagrees with the manifest, then a
    committed check fails and names both disagreeing surfaces.
13. **AC13** — Given a surface that wrongly claims a packaging file is part of
    the copied set, when the committed suite runs, then a check fails and names
    the offending surface.
14. **AC14** — Given `README.md`'s `Layout` block, when a reader reads it, then
    it lists the new root packaging files alongside the existing root entries and
    matches the on-disk root contents.
15. **AC15** — Given an already-adopted repository, when its owner reads the
    adoption documentation, then the documentation states that this change copies
    no files into such a repository and therefore requires no adopter action.

## Edge cases

- **Missing or unreadable manifest/changelog** — the drift check fails and names
  the missing file rather than passing silently.
- **Invalid version string** — a manifest value that is not valid SemVer (for
  example a leading `v`, a missing component, or trailing prose) fails AC3.
- **Pre-release and build metadata** — the versioning model states how a
  pre-release (for example `1.0.0-rc.1`) is represented and whether the
  corresponding GitHub Release is marked as a pre-release; AC5 applies to
  whichever version the manifest holds.
- **Date boundaries** — the released section's date is a valid ISO-8601 calendar
  date; a placeholder or empty date fails AC4.
- **First release, no prior tags** — the release model defines the first
  release's version and states that no earlier tag is required.
- **Adopter already has these files** — because they are never copied, an
  existing `LICENSE`, contribution guide, or changelog in the adopter's
  repository is never overwritten or conflicted with (AC9, AC10, AC15).
- **Whitespace/encoding in the manifest** — a trailing newline is tolerated; the
  parse is case-sensitive and rejects surrounding text (exact tolerance is a
  design decision).
- **Changelog with an empty newest released section** — allowed, but the heading
  must still carry the matching version and date (AC4, AC5).
- **Concurrent doc edits** — a change that updates the version or changelog
  without the other surfaces must fail the drift check rather than merge cleanly
  (AC12).

## Decisions

- **License — MIT** (user decision): permissive, minimal ceremony, and maximally
  copyable, matching the copy-the-files distribution model.
- **Versioning — Semantic Versioning** with annotated git tags and GitHub
  Releases, changelog in Keep a Changelog format (user decision).
- **Version source of truth — a dedicated root version manifest** (user
  decision); the exact file name and encoding are deferred to design.
- **Release automation — documentation and a seeded changelog only**; tagging and
  publishing remain manual (user decision), keeping the change dependency-free.
- **Changelog — seed forward** from the introduced version; past history is not
  reconstructed (user decision).
- **Copy set — the new packaging files are framework-repo/maintainer-only** and
  are not copied by the quickstart (user decision), so adopter repositories are
  untouched by this change.

## Open questions

- [ ] Literal initial release version — **Assumption**: `1.0.0`, as the first
  formally versioned, license-complete release. The acceptance criteria are
  independent of the literal value. — owner: user, needed by: design.
- [ ] Exact copyright holder for the MIT notice — **Assumption**: the repository
  owner as they direct. — owner: user, needed by: build.
- [ ] Exact file name and encoding of the version manifest — deferred to design
  (the outcome in AC2/AC3 constrains it: one root-level, SemVer-valid file named
  as the source of truth). — owner: architect, needed by: design.
- [ ] Whether the drift guard is a new committed check or an extension of the
  existing inventory check — deferred to design. — owner: architect, needed by:
  design.

## Dependencies and constraints

- Roadmap child `0003-framework-quality-hardening/0008-adoption-packaging`; its
  `Depends on` cell is `—`, so it is ready and runs in parallel with siblings.
- Must not regress the committed test suite established by child
  `0006-committed-tests-ci` (`bash tests/run.sh`; inventoried in
  `tests/README.md`).
- Must remain consistent with child `0001-state-model`'s committed-`work/`
  decision; this change adds only repository-root files and does not alter the
  artifact model.
- Must not duplicate or pre-empt child `0009-surface-consistency`; the
  framework's own `AGENTS.md` project profile and command usage strings are out
  of scope here.
- No new runtime dependency, install step, or network access; the MIT license
  text and Markdown documents are plain files.
- Package manager / stack commands for the framework repository remain as
  documented in `AGENTS.md` and `tests/README.md`; this item adds no build step.
