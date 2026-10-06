---
feature: 0003-framework-quality-hardening/0008-adoption-packaging
phase: tasks
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "T1 needs the copyright holder from the user (spec open question). Tasks are ordered; T8 and T9 depend on all documentation surfaces. T1 built with the default holder (repository owner Craig Truitt); confirm before ship."
---

# Tasks — Adoption packaging and versioning

Ordered, dependency-aware. One task ≈ one focused commit. T8's `Verify:` is the
AC11 regression gate.

- [x] **T1** — Add root `LICENSE` with the full, unmodified MIT license text and a
      copyright notice `Copyright (c) <year> <holder>`; take the holder from the
      user's direction (default: the repository owner). No per-file headers.
      [AC1]
      Verify: `grep -q 'MIT License' LICENSE && grep -q 'Permission is hereby granted, free of charge' LICENSE && grep -qE '^Copyright \(c\) [0-9]{4} ' LICENSE` → exit 0.

- [x] **T2** — Add root `VERSION` containing exactly one line, `1.0.0`, with a
      trailing newline (single valid SemVer, no leading `v`, no prose). [AC2] [AC3]
      Verify: `[ "$(tr -d '\r\n' < VERSION)" = "1.0.0" ] && grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' VERSION` → exit 0.

- [x] **T3** — Add `CHANGELOG.md`: first heading names the project
      (`# opencode-framework Changelog`), an `## [Unreleased]` section, and one
      released section `## [1.0.0] - 2026-10-06` with entries under Keep a
      Changelog categories; seed forward only (no pre-`1.0.0` entries). [AC4]
      [AC5] [AC6] [depends: T2]
      Verify: `grep -q '^## \[Unreleased\]' CHANGELOG.md && grep -qE '^## \[1\.0\.0\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$' CHANGELOG.md && [ "$(sed -n 's/^## \[\([0-9][^]]*\)\].*/\1/p' CHANGELOG.md | head -n1)" = "$(tr -d '\r\n' < VERSION)" ]` → exit 0.

- [x] **T4** — Add `CONTRIBUTING.md`: how to propose a change; run the committed
      suite (`bash tests/run.sh`); commit/branch conventions; links to
      `docs/workflow.md` and `docs/customization.md`; and the ordered manual
      release model — classify MAJOR/MINOR/PATCH, edit `VERSION`, move `Unreleased`
      entries into a dated `## [x.y.z]` section, commit, create an annotated tag,
      push it, publish a GitHub Release (pre-release marked for a pre-release
      version), tagging/publishing manual not CI; name `VERSION` the single source
      of truth, state the four packaging files are maintainer-only, and state
      already-adopted repositories need no action. [AC7] [AC8] [AC15]
      [depends: T2, T3]
      Verify: `grep -q 'bash tests/run.sh' CONTRIBUTING.md && grep -q 'docs/workflow.md' CONTRIBUTING.md && grep -q 'docs/customization.md' CONTRIBUTING.md && grep -q 'single source of truth' CONTRIBUTING.md && grep -q 'MAJOR' CONTRIBUTING.md && grep -qi 'annotated' CONTRIBUTING.md && grep -qi 'GitHub Release' CONTRIBUTING.md && grep -qi 'manual' CONTRIBUTING.md` → exit 0.

- [x] **T5** — Update `docs/customization.md` with one sentence stating `LICENSE`,
      `CONTRIBUTING.md`, `CHANGELOG.md`, and `VERSION` are
      framework-repo/maintainer-only and not part of the adopted copied set. [AC9]
      [depends: T1, T2, T3, T4]
      Verify: `for f in LICENSE CONTRIBUTING.md CHANGELOG.md VERSION; do grep -q "$f" docs/customization.md || exit 1; done && grep -q 'not part of' docs/customization.md` → exit 0.

- [x] **T6** — Update `README.md`: name MIT and link to `LICENSE`; state in the
      Quickstart that the four packaging files are framework-maintainer-only and
      outside the copied set and that already-adopted repositories need no action;
      ensure no `cp` command copies any of them; and extend the `## Layout` block
      with `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`, `README.md`,
      and `tests/` so it matches the on-disk root. [AC1] [AC9] [AC10] [AC14] [AC15]
      [depends: T1, T2, T3, T4]
      Verify: `grep -qi 'MIT' README.md && grep -q '](LICENSE)' README.md && for f in LICENSE CONTRIBUTING.md CHANGELOG.md VERSION; do grep -q "$f" README.md || exit 1; done && ! grep -qE 'cp .*(LICENSE|CONTRIBUTING|CHANGELOG|VERSION)' README.md` → exit 0.

- [x] **T7** — Update `tests/README.md`: extend the maintainer-only paragraph to
      name the four packaging files, and add a `90-packaging.sh` row to the Checks
      table noting it covers this item's AC12–AC14 as suite tokens `AC18`–`AC20`.
      [AC9] [depends: T1, T2, T3, T4]
      Verify: `grep -q '90-packaging.sh' tests/README.md && for f in LICENSE CONTRIBUTING.md CHANGELOG.md VERSION; do grep -q "$f" tests/README.md || exit 1; done` → exit 0.

- [x] **T8** — Add `tests/checks/90-packaging.sh` (harness conventions; read-only;
      never reads `work/**`) implementing `AC18` (VERSION exists as exactly one
      valid SemVer; newest released `CHANGELOG.md` version equals it; names both
      surfaces on failure; `CONTRIBUTING.md` names VERSION the single source of
      truth), `AC19` (all three copy-set surfaces name the four files as
      maintainer-only/not copied, and no quickstart copy command or copy-set
      sentence lists them), and `AC20` (`README.md` `Layout` lists the four files
      and matches the on-disk root, exempting `git-ignored` lines, `work/`
      forward, and hidden/`scratch/` reverse). [AC2] [AC3] [AC4] [AC5] [AC6]
      [AC9] [AC10] [AC12] [AC13] [AC14] [AC11] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` → exit 0, and its output contains `ok` lines labelled `AC18`, `AC19`, and `AC20` (`out="$(bash tests/run.sh)"; printf '%s' "$out" | grep -q AC18 && printf '%s' "$out" | grep -q AC19 && printf '%s' "$out" | grep -q AC20`).

- [x] **T9** — Update `tests/mutation.sh`: extend `stage()` to copy `LICENSE`,
      `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`, and `tests/README.md` into the
      staged copy; add one mutation per new area — manifest/changelog divergence
      (expect `AC18` naming both), a copy-set surface change (expect `AC19` naming
      the surface), a `Layout` drift (expect `AC20`) — and update the docstring's
      agreement-area range to include `AC18`–`AC20`. [AC11] [AC12] [AC13]
      [depends: T8]
      Verify: `bash tests/mutation.sh` → exit 0 with `MUTATION TOTAL: … 0 failed`.
