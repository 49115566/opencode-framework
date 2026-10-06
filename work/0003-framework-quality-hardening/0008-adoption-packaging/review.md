---
feature: 0003-framework-quality-hardening/0008-adoption-packaging
phase: review
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "Reviewed the uncommitted 0008 change against HEAD c8ab834. All 15 ACs met; no Blockers/Majors. Residual test-robustness gaps (date shape, loose README statement binding, AC1 manual-only) are Minors."
---

# Review — Adoption packaging and versioning

## Verdict

**approve** — all 15 acceptance criteria are met, the committed guard implements
AC12–AC14 as designed, and the remaining findings are low-risk test-robustness
and documentation gaps that do not block merge.

## How the review range was determined

`$ARGUMENTS` was empty. Enumerating `work/` found exactly one item with
`verify.md` but no `review.md` — `0003-framework-quality-hardening/0008-adoption-packaging`
— so that is the item reviewed. (Sibling items `0001`–`0007` each already have a
`review.md` and, except `0001`, a `ship.md`.)

Commands run:

```
git rev-parse --abbrev-ref HEAD          # feat/0003-framework-quality-hardening-0006-committed-tests-ci
git merge-base HEAD origin/main          # 18fe4b906b54fddb94029b1b566df08f0798a0e6
git rev-parse HEAD                       # c8ab834b40af9f5846fd920a4bdf39ad58bb9921
git log --oneline --decorate -20
git status
git diff HEAD --stat                     # 4 tracked files, +69/-5
git diff HEAD                            # tracked diff
```

**Base = `HEAD` (`c8ab834`), not `origin/main`.** The whole 0008 change is
*uncommitted*: `git status` shows the four source files modified and the four new
root files plus `tests/checks/90-packaging.sh` untracked. `HEAD` is the shipped
`0006-committed-tests-ci` commit, which is itself ahead of `origin/main` and not
yet merged. Diffing `origin/main...HEAD` would mix in the already-reviewed 0006
work and show none of 0008; therefore the 0008 diff is `git diff HEAD` for the
tracked files, plus the untracked files read directly (`LICENSE`, `VERSION`,
`CHANGELOG.md`, `CONTRIBUTING.md`, `tests/checks/90-packaging.sh`).

No `visual.md` exists (no user-facing UI in this change); none is required.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — root MIT license + README names/links MIT | **met** | `LICENSE:1-21` is the standard MIT text with `Copyright (c) 2026 Craig Truitt`; `README.md:303` `Released under the [MIT License](LICENSE).` Verified independently against the canonical MIT text (`verify.md`). Substantive content is manual-only — see M3. |
| AC2 — exactly one root version manifest, no other file needed | **met** | `VERSION:1` `1.0.0`; `ls -A1` shows no other root version manifest; `opencode.json` has no version key (confirmed by reading it). |
| AC3 — one SemVer string, release model names manifest source of truth | **met** | `VERSION` is one line; `AC18` validates `^[0-9]+\.[0-9]+\.[0-9]+(...)?$` (`tests/checks/90-packaging.sh:36,44-50`); `CONTRIBUTING.md:84-85` names `VERSION` the single source of truth. |
| AC4 — project-named changelog, Unreleased, dated released section, categories | **met** | `CHANGELOG.md:1` `# opencode-framework Changelog`; `:8` `## [Unreleased]`; `:10` `## [1.0.0] - 2026-10-06`; `:12` `### Added`. Date is shape-checked only — see M1. |
| AC5 — newest released changelog version equals manifest | **met** | Both are `1.0.0`; `AC18` asserts equality and names both surfaces on mismatch (`90-packaging.sh:72-76`). |
| AC6 — no pre-introduction entries | **met** | `CHANGELOG.md` contains only `Unreleased` and `1.0.0`. |
| AC7 — contribution guide contents + links | **met** | `CONTRIBUTING.md` has Proposing a change, `bash tests/run.sh` (`:34`), commit conventions (`:48`), branch conventions (`:66`), ordered release steps (`:88`), and links `docs/workflow.md`/`docs/customization.md` (`:6,8`). |
| AC8 — SemVer classification, annotated tag, GitHub Release, changelog entry, manual | **met** | `CONTRIBUTING.md:90-92` (MAJOR/MINOR/PATCH), `:101-105` (`git tag -a`), `:114-116` (GitHub Release, pre-release marking), `:96-99` (changelog required), `:82-84` (manual, not CI). |
| AC9 — all three surfaces state maintainer-only/not copied | **met** | `README.md:73-81`, `tests/README.md:5-11`, `docs/customization.md:48-51`; asserted by `AC19` (`90-packaging.sh:98-117`). Binding is weak for README — see M2. |
| AC10 — quickstart copies none of the four | **met** | `README.md:44-52` copies `.opencode/{agent,command,skill}`, `AGENTS.md`, `opencode.json`, `.gitignore`, `docs/*.md`; `AC19` scans the first bash block (`90-packaging.sh:119-136`). |
| AC11 — committed suite exits 0 | **met** | `verify.md` records `bash tests/run.sh` → `TOTAL: 182 passed, 0 failed, 0 skipped`, exit 0. Not re-executed by review (read-only bash allowlist blocks `bash`); static analysis of `90-packaging.sh` and the mutation stage found no failing path. |
| AC12 — manifest/changelog drift fails naming both surfaces | **met** | `AC18` (`90-packaging.sh:40-76`) plus the `AC18` mutation (`tests/mutation.sh:250-258`). |
| AC13 — surface wrongly claiming a file is copied fails naming it | **met** | `AC19` copy-set enumeration + claim scan (`90-packaging.sh:143-198`) plus the `AC19` mutation (`tests/mutation.sh:261-266`). Heuristic coverage caveat — M2. |
| AC14 — README Layout matches on-disk root | **met** | Bidirectional `AC20` (`90-packaging.sh:206-277`); `README.md:249-270` documents every non-hidden root entry and the four packaging files. |
| AC15 — adoption docs state no adopter action | **met** | `README.md:78-81` and `CONTRIBUTING.md:130-133`. |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[m1] `AC18` validates the changelog date's shape, not calendar validity** — `tests/checks/90-packaging.sh:35,63`
  `RELEASED_HEADING_RE` accepts `[0-9]{4}-[0-9]{2}-[0-9]{2}`, so `## [1.0.0] - 2026-13-45` or `2026-02-30`
  passes, while the spec's "Date boundaries" edge case calls for a *valid* ISO-8601 calendar
  date. The shipped changelog has the valid `2026-10-06`, so AC4 is met; only the guard is
  weaker than the design's `AC18` mapping implies.
  Recommendation: either add a real calendar check (month 01–12, day within month) in `AC18`,
  or record in `design.md`/`tests/README.md` that calendar validity is out of the guard's scope.

- **[m2] `AC19` does not bind the four filenames to the not-copied statement, and the README prose
  claim is only heuristically scanned** — `tests/checks/90-packaging.sh:104-116,143-198`
  For each surface the check requires the four filenames *somewhere* (`:104-111`) and, *separately*,
  some maintainer-only/not-copied line (`:112-116`). In `README.md` the filenames also occur in the
  `Layout` block (`README.md:263-266`) and `maintainer-only`/`never copies` occur at `:61` and
  `:263-266`, so deleting the packaging paragraph (`README.md:73-81`) still passes — the tester
  records this in `verify.md`'s residual risks. Additionally the copy-set sentence scan (`:143`)
  deliberately covers only `tests/README.md` and `docs/customization.md`; a README phrasing such as
  "the copied set includes `LICENSE`" would match neither `CLAIMED_RE` alternative at `:95`
  (`cop(y|ies)` does not match "copied set"). Positive claims of the tested forms are caught.
  Recommendation: bind the filenames to a single not-copied sentence per surface (e.g. require the
  four names and the statement in one paragraph), and add one mutation that deletes the README
  packaging paragraph so the guard proves it is sensitive to removal.

- **[m3] AC1's substantive content is unguarded by the committed suite** — `tests/checks/90-packaging.sh`
  The suite asserts `LICENSE` is named/documented (`AC19`, `AC20`) but never that it holds the MIT
  text, that `README.md` names MIT, or that it links `](LICENSE)`. `design.md:233` describes AC1 as
  "committed check + manual | `AC20`/`AC19` (names/links)", which overstates those tokens.
  Recommendation: add a small `AC20`/`AC19` assertion for the MIT notice lines and the README
  `[MIT License](LICENSE)` link, or correct the design's test-strategy claim to "manual only".

- **[m4] The MIT copyright holder is an unresolved user decision** — `LICENSE:3`; `spec.md:179-180`; `tasks.md:8`
  The licence attributes copyright to `2026 Craig Truitt`. The spec lists the exact holder as an
  open question (`owner: user, needed by: build`), and `tasks.md` itself says "confirm before ship".
  Git history corroborates that `Craig Truitt` is the repository author/owner, and the design
  sanctions the repository-owner fallback, so this is a confirmation gate rather than a defect.
  Recommendation: `/ship` surfaces this for explicit confirmation before the license is published;
  changing the attribution later means rewriting a public `LICENSE`.

- **[m5] The 0008 change is uncommitted on the 0006 branch** — branch `feat/0003-framework-quality-hardening-0006-committed-tests-ci`, `HEAD` = `c8ab834`
  The branch already carries the unmerged `0006-committed-tests-ci` commits, and the entire 0008
  change sits on top of them uncommitted. Shipping 0008 from this state would produce a PR whose
  base (if `main`) also contains 0006, mixing two work items.
  Recommendation: before `/ship`, branch 0008 from the intended base — `main` after 0006 merges, or
  explicitly stack on the 0006 branch if 0006 is intended to land first — so the 0008 PR diff is
  exactly the packaging change.

### Nits

- **[n1] Design note contradicts the implementation on CRLF** — `design.md:157` vs `tests/checks/90-packaging.sh:44`
  The design says a `VERSION` with CRLF is "tolerated by trimming" via `tr -d '\r\n'`, but `AC18`
  reads the line with `awk`, which keeps the `\r`, so `1.0.0\r\n` fails. The spec requires only a
  tolerated trailing LF, which works. Take it or leave it: strip `\r` in the check or correct the
  design sentence.

- **[n2] First-release "no earlier tag required" guidance is absent** — `CONTRIBUTING.md:88-119`
  The spec's "First release, no prior tags" edge case is guidance, not an acceptance criterion, and
  `verify.md` records it. A single sentence ("the first release needs no earlier tag") would close it.

- **[n3] `CLAIMED_RE` is deliberately intricate** — `tests/checks/90-packaging.sh:95`
  The regex is hard to audit and silently misses some positive phrasings (see m2). A one-line comment
  enumerating the phrasings it intends (and does not) catch would keep future edits honest.

## Not reviewed

- The already-shipped sibling items `0001`–`0007` and the committed `0006` code now at `HEAD`, beyond
  the assumption that `tests/run.sh` / `tests/mutation.sh` still pass against them.
- The correctness of Keep a Changelog and Semantic Versioning conventions themselves; only the
  project's adherence to its declared formats was checked.
- Adopter-visible behavior of `docs/customization.md` beyond the new sentence (the file is in the
  copied set and its added sentence was reviewed for contradiction with the copy-set claims).
