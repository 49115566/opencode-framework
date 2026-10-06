---
feature: 0003-framework-quality-hardening/0008-adoption-packaging
phase: test
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "All 15 acceptance criteria verified. Committed guard coverage: AC2/3/4/5/9/10/11/12/13/14. Manual coverage: AC1, AC4 (project heading + categories), AC6, AC7, AC8, AC15. Residual risks: AC18 date check is shape-only; AC19 README statement is loosely bound; CRLF manifest contradicts the design's tolerance note."
---

# Verification — Adoption packaging and versioning

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 182 passed, 0 failed, 0 skipped`; exit 0. Includes the new `AC18`–`AC20` packaging area. |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 25 checked passed, 0 failed`; exit 0. Includes one mutation each for `AC18`, `AC19`, `AC20`, with clean re-runs after restore. |
| `diff -u /tmp/canonical-mit.txt <(normalize copyright line of LICENSE)` | PASS | `LICENSE` is byte-identical to the canonical MIT text after normalizing the copyright line. |
| Edge-case probes (scratch copies, details below) | PASS | Guard catches every spec-listed negative case except the noted gaps. |

Edge-case probes were run with `tests/run.sh <copy>` against a staged copy of the
live surfaces (no `work/`), each check filtered to its `AC18`/`AC19`/`AC20` token.
The probe scripts lived under the git-ignored `scratch/` and were removed after
use; the results are recorded below.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 | manual: `LICENSE` byte-identical to canonical MIT (copyright notice `Copyright (c) 2026 Craig Truitt`); `README.md:303` `[MIT License](LICENSE)`; committed `AC20` documents `LICENSE`, `AC19` names it | PASS (manual) |
| AC2 | `tests/checks/90-packaging.sh` `AC18` (only reads `VERSION`); manual: `ls -A1` shows no other root version manifest (`opencode.json` has no version key) | PASS |
| AC3 | `90-packaging.sh` `AC18` (exactly one non-empty line matching SemVer); `CONTRIBUTING.md:85` names `VERSION` the single source of truth | PASS |
| AC4 | `AC18` asserts `## [Unreleased]` and a `## [<semver>] - <date>` released heading; manual: `CHANGELOG.md:1` `# opencode-framework Changelog`, `:12` `### Added` category | PASS |
| AC5 | `AC18` asserts `VERSION` equals the newest released version (`1.0.0`) | PASS |
| AC6 | manual: `CHANGELOG.md` contains only `## [Unreleased]` and `## [1.0.0] - 2026-10-06`; no earlier versions | PASS (manual) |
| AC7 | manual: `CONTRIBUTING.md` has Proposing a change, `bash tests/run.sh`, commit conventions (`:48`), branch conventions (`:66`), ordered release steps (`:80`), and links `docs/workflow.md`/`docs/customization.md` (`:6`,`:8`) | PASS (manual) |
| AC8 | manual: `CONTRIBUTING.md:90-92` MAJOR/MINOR/PATCH, `:104` `git tag -a`, `:114` GitHub Release, `:96` changelog entry required, `:82` manual not CI, `:114-116` pre-release marking | PASS (manual) |
| AC9 | `AC19` all three surfaces (`README.md`, `tests/README.md`, `docs/customization.md`) name all four files and carry a maintainer-only / not-copied statement | PASS |
| AC10 | `AC19` quickstart `bash` block scan; manual: block at `README.md:44-52` has no packaging file | PASS |
| AC11 | `bash tests/run.sh` exit 0 | PASS |
| AC12 | `AC18` + `tests/mutation.sh` AC18 case + probe: missing/empty/invalid manifest, missing changelog, and version mismatch all fail naming both surfaces | PASS |
| AC13 | `AC19` + `tests/mutation.sh` AC19 case + probes: a surface positively claiming a packaging file is copied fails naming that surface (README, tests/README, customization all verified) | PASS |
| AC14 | `AC20` bidirectional Layout ↔ on-disk root check; probes: dropped `VERSION`, stale entry, and undocumented root file all fail | PASS |
| AC15 | manual: `README.md:78-81` and `CONTRIBUTING.md:130-133` state already-adopted repositories need no action | PASS (manual) |

### Edge-case probe results

| Edge case | Probe | Result |
| --------- | ----- | ------ |
| Missing/unreadable manifest | delete `VERSION` | CAUGHT, names `VERSION` and `CHANGELOG.md` |
| Missing changelog | delete `CHANGELOG.md` | CAUGHT, names `CHANGELOG.md` |
| Invalid version | `v1.0.0`, `1.0`, `1.0.0.`, `1.0.0 extra prose` | CAUGHT, `AC18 VERSION is not a single valid SemVer` |
| Pre-release / build metadata | both surfaces `1.0.0-rc.1`, `1.0.0+build.5`, `1.0.0-rc.1+build.5` | PASS; model documents representation and pre-release marking |
| Version mismatch | `CHANGELOG` 2.0.0 vs `VERSION` 1.0.0 | CAUGHT, names both surfaces |
| Removed `Unreleased` | rewrite heading | CAUGHT |
| Copy-set wrong claim | packaging file added to a copy-set enumeration; README positive claim | CAUGHT, names the offending surface |
| Quickstart copies a packaging file | `cp "$FRAMEWORK/LICENSE" .` in the block | CAUGHT |
| Layout drift | drop `VERSION`; stale entry; undocumented root file | CAUGHT |
| Whitespace/encoding | `VERSION` with trailing LF | PASS (tolerated); CRLF rejected — see residual risk |

## Gaps and residual risk

No acceptance criterion fails. The following are coverage/robustness gaps that do
not change the verdict; they are follow-up suggestions, not defects.

- **`AC18` validates date *shape*, not calendar validity** — a heading such as
  `## [1.0.0] - 2026-13-45` or `2026-02-30` passes. The committed changelog uses
  the valid `2026-10-06`, and the spec's date-boundary edge case explicitly names
  only placeholder/empty dates, which the check does catch. Follow-up: validate
  the calendar date in `AC18` if a future maintainer wants that guard.
- **`AC19`'s README coverage is loosely bound** — deleting the entire README
  packaging paragraph (`README.md:73-81`) still passes, because `maintainer-only`
  also appears at `README.md:68` (tests/`.github`) and in the `Layout` comments,
  and the not-copied regex matches `README.md:61` ("never copies", about the
  doctor inventory). The current README satisfies AC9, and positive wrong claims
  are caught; the guard just does not detect removal of the *packaging-specific*
  README statement. Follow-up: bind the statement to the four filenames.
- **CRLF manifest contradicts the design note** — design §"Interfaces and data
  model" says a `VERSION` with CRLF is "tolerated by trimming" (`tr -d '\r\n'`),
  but `AC18`'s `awk` keeps the `\r`, so `1.0.0\r\n` fails. The spec requires only
  a tolerated trailing newline (LF), which works. Follow-up: either strip `\r` or
  correct the design note.
- **AC1's substantive content is manual-only** — the committed suite checks that
  `LICENSE` is named/documented (`AC19`/`AC20`), not that it holds the MIT text
  nor that `README.md` names MIT and links to it. The design assigns this to
  manual reading; the `design.md` test-strategy wording "AC20/AC19 (names/links)"
  slightly overstates what those tokens assert. Follow-up: add a committed AC1
  assertion if mechanical drift protection is wanted.
- **First-release "no earlier tag required" wording** — the release model defines
  the first version (`1.0.0`) and the tag step, but does not spell out that no
  earlier tag is required (spec edge case). This is guidance, not an acceptance
  criterion; recorded for completeness.
