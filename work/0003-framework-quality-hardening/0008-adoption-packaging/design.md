---
feature: 0003-framework-quality-hardening/0008-adoption-packaging
phase: design
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "Resolves the spec's design-deferred questions: version manifest = root plain-text `VERSION` file; drift guard = new `tests/checks/90-packaging.sh` (tokens AC18–AC20). Copyright holder remains a user input needed by build."
---

# Design — Adoption packaging and versioning

## Summary

Add four framework-repo-only root files — `LICENSE` (MIT), `VERSION` (a single
SemVer line, the version source of truth), `CHANGELOG.md` (Keep a Changelog,
seeded at `1.0.0`), and `CONTRIBUTING.md` (contribution + release model) — and
teach the committed suite to guard the packaging surface. The guard is a new
`tests/checks/90-packaging.sh` area that asserts the manifest is one valid SemVer
which equals the changelog's newest released version, that all three copy-set
surfaces agree the four files are not copied, and that `README.md`'s `Layout`
block matches the on-disk root. No adopter-copied file changes behavior, so an
already-adopted repository needs no action.

## Approach

### New root files

- **`LICENSE`** — the full, unmodified MIT license text with a copyright notice
  `Copyright (c) <year> <holder>`. The holder is a user input (spec open
  question); until supplied, the build task uses the repository owner's name as
  directed and leaves the notice in the standard MIT form. No per-file headers,
  no dual licensing (spec non-goals).
- **`VERSION`** — root plain-text manifest: exactly one line holding a SemVer
  `MAJOR.MINOR.PATCH` string, initially `1.0.0`, with an optional trailing
  newline. Grammar (SemVer 2.0.0, pre-release/build optional):
  `^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$`. No leading
  `v`, no prose, case-sensitive. This is the single source of truth named by the
  release model (AC2, AC3).
- **`CHANGELOG.md`** — Keep a Changelog shape: a first heading naming the project
  (`# opencode-framework Changelog`), an `## [Unreleased]` section, and one
  released section `## [1.0.0] - 2026-10-06` whose entries sit under standard
  categories (`### Added`, …). Seeded forward only; no pre-`1.0.0` entries
  (AC4, AC5, AC6).
- **`CONTRIBUTING.md`** — the contribution and release guide (AC7, AC8): how to
  propose a change; the canonical test command `bash tests/run.sh`; commit and
  branch conventions (conventional commits, `type/short-description` branches);
  links to `docs/workflow.md` and `docs/customization.md`; and the ordered,
  manual release steps — classify the change as MAJOR/MINOR/PATCH, edit
  `VERSION`, move `Unreleased` entries into a dated `## [x.y.z]` section leaving
  `Unreleased` empty, commit, create an **annotated** tag (`git tag -a`), push
  the tag, and publish a GitHub Release (marked pre-release for a pre-release
  version). It states that tagging and publishing are manual, not CI-automated,
  that `VERSION` is the single source of truth, that the four packaging files are
  maintainer-only, and that existing adopters need take no action (AC15).

### Documentation reconciliation

- **`README.md`** — name MIT and link to `LICENSE`; state in the Quickstart that
  the license, contribution guide, changelog, and version manifest are
  framework-repo/maintainer-only and outside the copied set, and that already
  adopted repositories need no action. Extend the `## Layout` block with the four
  files (and the two other visible root entries currently missing, `README.md`
  and `tests/`) so it matches the on-disk root (AC1, AC9, AC10, AC14, AC15).
- **`tests/README.md`** — extend its existing maintainer-only paragraph to name
  the four packaging files, and add `90-packaging.sh` to the Checks table (AC9).
- **`docs/customization.md`** — add one sentence stating the four packaging files
  are framework-maintainer-only and not part of the copied set (AC9). This file
  is copied to adopters; the added sentence is informational and harmless, and it
  is the statement AC9 requires.

### The committed guard — `tests/checks/90-packaging.sh`

A new check file following the harness convention (sourced by `tests/run.sh`,
read-only, never reads `work/**`, `ok`/`FAIL`/`skip` reporters, one file per
agreement area). It labels its assertions with three new stable tokens, chosen to
extend the living suite's namespace without colliding with the existing `AC6`–`AC13`
areas:

- **`AC18` — manifest ↔ changelog agreement.** `VERSION` exists and parses as
  exactly one valid SemVer; `CHANGELOG.md`'s newest released heading
  (`^## [<version>] - <date>`) resolves; the two versions are equal; and
  `CONTRIBUTING.md` names `VERSION` as the single source of truth. A missing file,
  an invalid version, or a mismatch prints `FAIL` naming **both** surfaces
  (`VERSION`, `CHANGELOG.md`) — the spec's AC12 and the AC2/AC3 edge cases.
- **`AC19` — copy-set agreement.** The four filenames are maintained in one
  literal list in the check (the check *is* the guard for that set). For each of
  `README.md`, `tests/README.md`, and `docs/customization.md`, assert it names all
  four files and carries the maintainer-only/not-copied statement. Separately,
  assert the quickstart copy commands in `README.md`'s first ```` ```bash ````
  block never mention any of the four names, and that the copy-set sentences in
  `tests/README.md` and `docs/customization.md` do not list them. A surface that
  wrongly claims one is copied fails and names that surface — the spec's AC13,
  and the AC10/AC13 support.
- **`AC20` — `Layout` ↔ disk agreement.** Parse the first token of each entry in
  `README.md`'s `## Layout` fenced block. Assert (forward) every documented entry
  exists at the root, except lines whose inline comment is marked `git-ignored`
  and except `work/` (the mutation harness deliberately runs with no `work/`);
  and (reverse) every non-hidden root entry except the git-ignored `scratch/` is
  documented. Assert the four packaging files are documented. A stale entry, an
  undocumented root entry, or a missing packaging file fails — the spec's AC14.

The token numbers are deliberate: `AC6`–`AC13` already belong to the areas
introduced by child `0006-committed-tests-ci`; `AC14`–`AC17` describe harness
behaviors, not check areas. `AC18`–`AC20` extend the same monotonic namespace so
the living suite stays unambiguous. The mapping (spec AC12→suite AC18, AC13→AC19,
AC14→AC20) is recorded in `tests/README.md`.

### Mutation self-check

`tests/mutation.sh` stages a copy of the live surfaces and proves the suite is
mutation-sensitive. Its `stage()` currently copies neither the new root files nor
`tests/README.md`, so the new check would fail in the clean copy. The task updates
`stage()` to copy `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`, and
`tests/README.md`, and adds one mutation per new area: a manifest/changelog
divergence (expect `AC18` naming both), a copy-set surface change (expect `AC19`
naming the surface), and a `Layout` drift (expect `AC20`). The docstring's
"AC6–AC13" range is updated to include `AC18`–`AC20`.

## Alternatives considered

- **Version manifest: `VERSION` plain text (chosen) vs `version.json` /
  `opencode.json` key.** A JSON manifest needs a structured parser; the harness
  is deliberately dependency-free (`awk`/`grep` only, no `jq`/`python` in the
  minimal environment), and `opencode.json` is in the adopter copy set, so its
  version would travel into every adopted repo — contradicting
  maintainer-only packaging. A single-line `VERSION` is the simplest file that
  satisfies AC2/AC3 and parses with `tr` + a SemVer regex. Rejected.
- **Drift guard as an extension of `tests/checks/40-inventory.sh` (rejected) vs a
  new `90-packaging.sh` (chosen).** `40-inventory.sh` owns agent/command/skill
  inventory under its `AC9` token; mixing version/changelog/copy-set/Layout
  concerns into it would blur one agreement area and overload a stable token. The
  harness's documented model is "adding a check is adding a file", so a new area
  is the lower-risk extension. The spec explicitly left this to design.
- **Release model in `docs/releasing.md` (rejected) vs `CONTRIBUTING.md`
  (chosen).** `docs/*.md` is in the adopter copy set, so a maintainer-only release
  guide there would either leak into adopters or force new copy-set exclusions.
  `CONTRIBUTING.md` is already outside the copied set and is the natural home
  (AC7 links the two docs it may reference).
- **`Layout` check as presence-only (rejected) vs bidirectional (chosen).**
  AC14 says `Layout` "matches the on-disk root contents", so a presence-only check
  would miss an undocumented root entry. Bidirectional is stricter but bounded by
  an explicit exclusion set (`scratch/`, hidden entries, `work/` forward
  exemption) that keeps it deterministic on both a fresh clone and the mutation
  copy.

## Interfaces and data model

**`VERSION`** (new, root, plain text)

```
1.0.0
```

- Encoding: ASCII/UTF-8, one logical line, optional trailing newline (CRLF
  tolerated by trimming). No BOM, no leading `v`, no surrounding text.
- Consumer contract: `tr -d '\r\n' < VERSION` yields the version string; the
  committed suite validates it against the SemVer regex above. A reader needs no
  other repository file (AC2).

**`CHANGELOG.md` heading contract**

- Newest released version is the first heading matching `^## \[<x.y.z>\] - <YYYY-MM-DD>`,
  where the version equals `VERSION` and the date is a valid ISO-8601 calendar
  date. `## [Unreleased]` is always present.

**`tests/checks/90-packaging.sh`**

- Consumes relative paths `README.md`, `tests/README.md`, `docs/customization.md`,
  `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION` (run.sh `cd`s to the repo root).
- Emits stable labels `AC18 …`, `AC19 …`, `AC20 …` via the shared
  `ok`/`FAIL`/`skip` reporters from `tests/lib.sh`.
- Defines its path constants and the four-file packaging list locally; `lib.sh`
  is not modified (only this area consumes them).

No public interface, schema, migration, or runtime dependency changes. No file in
the adopter copy set (`.opencode/{agent,command,skill}`, `AGENTS.md`,
`opencode.json`, `.gitignore`, `docs/*.md`) is added or removed; only
`docs/customization.md` gains an informational sentence.

## Affected areas

New:

- `LICENSE`, `VERSION`, `CHANGELOG.md`, `CONTRIBUTING.md` (repository root).
- `tests/checks/90-packaging.sh`.

Modified:

- `README.md` (Quickstart copy-set statement, MIT link, `Layout` block).
- `tests/README.md` (maintainer-only statement, Checks table row).
- `docs/customization.md` (one maintainer-only sentence).
- `tests/mutation.sh` (`stage()` copies new files; new mutation cases).

Unchanged: `opencode.json`, `AGENTS.md`, `.gitignore`,
`.github/workflows/ci.yml`, and everything under `.opencode/**`.

## Risks and mitigations

- **Copyright holder is unspecified** — likelihood high / impact medium /
  mitigation: the `LICENSE` build task takes the holder from the user (spec open
  question, owner: user, needed by: build); until confirmed it uses the
  repository owner as directed. Flagged as a build-time blocker.
- **`Layout` check brittleness across a fresh clone and the mutation copy** — the
  copy deliberately has no `work/` and no hidden dirs — likelihood medium /
  impact medium / mitigation: forward existence exempts `git-ignored` lines and
  `work/`, reverse enumeration skips hidden entries and `scratch/`; the exclusion
  set is explicit and commented in the check. `stage()` is updated so all
  referenced root files exist in the copy.
- **Mutation self-check silently broken by missing staged files** — likelihood
  medium / impact medium / mitigation: the mutation task explicitly extends
  `stage()` and its `Verify:` runs `bash tests/mutation.sh` to exit 0.
- **Token collision (`AC18`–`AC20`) in suite output** — likelihood low / impact
  low / mitigation: the numbers are new, and the mapping from this item's ACs is
  documented in `tests/README.md`.
- **`Changelog` heading vs "project name" (AC4)** — likelihood low / impact low /
  mitigation: the title carries both (`# opencode-framework Changelog`).
- **A future edit adds a packaging file to the copied set** — likelihood medium /
  impact high / mitigation: `AC19` scans the quickstart copy commands and the two
  copy-set sentences and names the offending surface (spec AC13).
- **`docs/customization.md` is copied to adopters** — adding its sentence changes
  adopter-visible docs — likelihood certain / impact low / mitigation: the
  sentence is informational and consistent with the quickstart; no adopter action
  results (AC15).
- **Release date is seeded, not derived** — likelihood low / impact low /
  mitigation: AC4 requires only a valid ISO-8601 date; the maintainer sets the
  real date when cutting the first public release.

## Test strategy

| Criterion | Verification level | Where |
| --------- | ------------------ | ----- |
| AC1 | committed check + manual | `AC20`/`AC19` (names/links), tester reads `LICENSE` + README |
| AC2, AC3 | unit (committed) | `90-packaging.sh` `AC18` (existence, single SemVer, source-of-truth) |
| AC4, AC5, AC6 | unit (committed) + manual | `AC18` (`Unreleased`, dated released heading, version equality); tester reads categories / no pre-`1.0.0` entries |
| AC7, AC8 | manual | tester reads `CONTRIBUTING.md` against the criterion list |
| AC9 | unit (committed) | `AC19` all three surfaces |
| AC10 | unit (committed) | `AC19` quickstart command scan |
| AC11 | integration | `bash tests/run.sh` exits 0 after the change |
| AC12 | unit + mutation | `AC18`; `tests/mutation.sh` divergence case |
| AC13 | unit + mutation | `AC19`; `tests/mutation.sh` copy-set case |
| AC14 | unit (committed) | `AC20` `Layout` ↔ disk |
| AC15 | manual | tester reads README/CONTRIBUTING no-adopter-action statements |
