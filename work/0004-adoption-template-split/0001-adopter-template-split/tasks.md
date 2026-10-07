---
feature: 0004-adoption-template-split/0001-adopter-template-split
phase: tasks
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0004-adoption-template-split
notes: "Ordered: T1 creates the pristine snapshot before T3 fills the framework profile. Between T1 and T2 the committed suite is red only on 90-packaging AC20 (template/ is on disk but not yet documented in README Layout); T2 closes it. T2 and T5 are the AC6 gates (bash tests/run.sh, bash tests/mutation.sh). No committed split guards are added here — child 0003 owns them."
---

# Tasks — Adopter/maintainer template split

Ordered, dependency-aware. One task ≈ one focused commit. The three pristine
files are snapshotted in T1 before T3 fills the framework's own profile, so the
template keeps its placeholders.

- [x] **T1** — Create the adopter-pristine source directory `template/` with
      byte-for-byte snapshots of the current root files: `template/AGENTS.md`
      (the unfilled placeholder template), `template/opencode.json`, and
      `template/.gitignore`. Do this before any edit to the root `AGENTS.md`.
      [AC1] [AC3]
      Verify: `for f in AGENTS.md opencode.json .gitignore; do test -f "template/$f" || exit 1; done && grep -q 'one or two sentences on what this project does' template/AGENTS.md && grep -q '_e.g. pnpm' template/AGENTS.md && grep -q '"enabled": false' template/opencode.json && grep -q 'scratch/' template/.gitignore && diff -q opencode.json template/opencode.json && diff -q .gitignore template/.gitignore` → exit 0.

- [x] **T2** — Update `README.md`'s `## Layout` block to document the new
      top-level `template/` directory and its three files (indented, matching the
      existing `docs/`/`.opencode/` style) so the `Layout` ↔ disk agreement holds.
      Do not touch the Quickstart copy commands or copy-set prose (child `0002`).
      [AC6] [depends: T1]
      Verify: `grep -q '^template/' README.md && grep -q 'template/AGENTS.md' README.md && bash tests/run.sh` → exit 0, and the output contains `ok` lines labelled `AC20`.

- [x] **T3** — Fill the framework's own `AGENTS.md` `## Project profile` with the
      design's exact verified values and remove the
      `<!-- /bootstrap replaces the placeholders below ... -->` comment; change
      nothing else in the file. Then confirm the always-loaded instruction set is
      unchanged and the config parses. [AC2] [AC5] [AC7] [depends: T1]
      Verify: `! grep -qE 'one or two sentences on what this project does|_e\.g\.|replaces the placeholders below' AGENTS.md && grep -q 'bash tests/run.sh' AGENTS.md && grep -q '\*\*Purpose\*\*' AGENTS.md && grep -q '\*\*Key directories\*\*' AGENTS.md && grep -q 'one or two sentences on what this project does' template/AGENTS.md && diff -q opencode.json template/opencode.json && diff -q .gitignore template/.gitignore && grep -q '"AGENTS.md"' opencode.json && ! grep -q 'template/AGENTS.md' opencode.json && { ! command -v opencode >/dev/null 2>&1 || opencode debug config >/dev/null; }` → exit 0.

- [x] **T4** — Add the split-contract section to `docs/customization.md`
      (after "Where things live"): for `AGENTS.md`, `opencode.json`, and
      `.gitignore`, name both the adopter-pristine source (`template/<file>`) and
      the framework's own copy (root `<file>`), state that `/bootstrap` mutates
      exactly those three, and state that `.opencode/{agent,command,skill}` and
      `docs/*.md` have a single source and are shared verbatim. Also refresh the
      "Always-loaded instructions" table's `AGENTS.md` row and total from the
      measured file size, keeping the three-path set unchanged. Do not rewrite
      the existing copy-set prose (lines 43-51) still owned by child `0002`.
      [AC4] [depends: T1, T3]
      Verify: `grep -q 'template/AGENTS.md' docs/customization.md && grep -q 'template/opencode.json' docs/customization.md && grep -q 'template/.gitignore' docs/customization.md && grep -qi 'shared verbatim' docs/customization.md` → exit 0.

- [x] **T5** — Update `tests/mutation.sh` `stage()` to copy the new `template/`
      directory into the staged copy (`cp -R "$REPO_ROOT/template"
      "$COPY/template"`) so the AC20 `Layout` forward check finds it; adjust the
      harness comment only if needed. This keeps the opt-in mutation self-check
      green and is not a new committed guard. [AC6] [depends: T1, T2]
      Verify: `bash tests/mutation.sh` → exit 0 with `MUTATION TOTAL: … 0 failed`.
