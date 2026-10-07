---
feature: 0004-adoption-template-split/0003-split-guard-tests
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Resolves the spec's design-deferred open question. New agreement area = a new check file `tests/checks/95-split-guard.sh` with one stable suite token `AC21` (the next free token; AC6-AC13, AC18-AC20 are taken). The area is one token, not one per guarded property, matching the spec's singular 'stable suite token' and its single-mutation requirement (AC8). No existing check, run.sh, or lib.sh changes. Scope is tests/** only."
---

# Design — Committed split guards

## Summary

Add one new committed agreement area, `tests/checks/95-split-guard.sh`, carrying
the next free stable suite token `AC21`. It statically asserts the split's five
observable properties — quickstart↔contract source mapping, the pristine
placeholder profile, the copy-set surfaces, the contract agreement, and the
`bootstrap` deny guard — document the area in `tests/README.md`, and add a single
`AC21` mutation to `tests/mutation.sh`. `tests/run.sh` auto-sources
`tests/checks/*.sh`, so adding the file needs no runner edit and no existing
check changes.

## Approach

### 1. One new check file, one stable area token (`AC21`)

`tests/run.sh:38-49` sources every `tests/checks/*.sh` in filename order in one
process, so a new file is the entire integration surface. Follow the existing
convention that **each check file is one agreement area with a stable `ACn`
token** (`tests/README.md:64-67`): `95-split-guard.sh` runs after
`90-packaging.sh` and labels every assertion `AC21`. `AC21` is free — the used
namespace is `AC6`–`AC13` (areas), `AC14`–`AC17` (harness behavior), and
`AC18`–`AC20` (packaging, `tests/checks/90-packaging.sh:22-24`).

A single area token for the whole split guard (rather than `AC21`–`AC25`, one per
property) is chosen because the spec names **one** new agreement area and
requires **one** mutation for it (spec AC8). Sub-assertions are distinguished by
their message text (`AC21 quickstart …`, `AC21 template/AGENTS.md …`,
`AC21 bootstrap …`), exactly as `90-packaging.sh` distinguishes sub-assertions
within `AC19`.

The file reuses `tests/lib.sh`'s reporters and path constants (`ok`, `bad`,
`flat`, `README`, `CUST`, `AGENT_DIR`; `tests/lib.sh:22-48`). It reads only live
surfaces, never `work/**`, and uses only bash/grep/awk/sed — no optional tool, so
it never skips (`tests/README.md:46-52`).

### 2. Quickstart copy-pair parser (AC2, AC5)

Extract the first ```bash block from `README.md` with the same awk that
`90-packaging.sh` AC19 uses (`tests/checks/90-packaging.sh:121-125`). Then parse
it into a list of `source<TAB>destination` **copy pairs** with a bounded,
line-oriented recognizer (awk, Bash 3.2 compatible):

- A copy command is a line whose first non-blank word is `cp` (optionally reached
  through a trailing `do`), possibly preceded on the same line by
  `for <var> in <words>; do`.
- Operands are read after the command word, skipping `-*` flags, honoring
  surrounding double quotes. The last operand is the destination; all preceding
  operands are sources.
- **Loop expansion.** A `for <var> in <w1> <w2> …; do` on the same line binds
  `<var>` to each word; `$<var>` and `${<var>}` in a `cp` operand are expanded.
  The expansion is applied on the **logical command line**, so the documented
  loop form
  `for f in AGENTS.md opencode.json .gitignore; do cp "$FRAMEWORK/template/$f" "./$f"; done`
  yields the same three pairs as the literal per-file commands.
- **Normalization.** Strip surrounding quotes; strip a leading `$FRAMEWORK/`,
  `${FRAMEWORK}/`, or `"$FRAMEWORK"/`. Leave the remainder verbatim
  (`template/AGENTS.md`, `./AGENTS.md`).
- Multi-line `for` lists (backslash-continued) are out of scope; only the
  same-line `for … in …; do … done` and literal forms are recognized. This is a
  bounded recognizer for the documented quickstart, not a shell evaluator.

Per file `f` in `AGENTS.md`, `opencode.json`, `.gitignore`:

- **AC2 source/destination.** Require a pair whose normalized source is
  `template/$f` and whose destination is `./$f` or `$f`. When absent, fail with
  the stable message `AC21 README.md quickstart does not source $f from
  template/$f` (single line; the mutation in Approach §7 greps exactly this with
  `$f=AGENTS.md`).
- **AC2 root re-point.** For every pair whose source basename is `f` and whose
  source does not contain `template/`, fail naming `README.md` and `f`.
- **AC2 whole-directory copy.** A pair whose source normalizes to `template`,
  `template/`, or `template/.` is not the documented per-file mapping; fail
  naming `README.md` (it copies more than the three named files).
- **Missing source.** If `template/$f` does not exist on disk, fail naming the
  missing `template/$f` (spec edge case: no vacuous pass).
- **No readable block.** If no ```` ```bash ```` block is found, fail naming
  `README.md`.

### 3. Quickstart ↔ contract agreement (AC5)

Parse the "Adopter-pristine sources and framework copies" table in
`docs/customization.md` (`docs/customization.md:30-34`): for each row whose first
cell (backticks stripped, trimmed) is one of the three files, the adopter-pristine
source is the first `` `template/…` `` token in the second cell. Assert it equals
the quickstart source for that file; a divergence fails naming the mismatched
`f`. This is the source-of-truth mapping the guard exists to keep in lockstep.

### 4. Pristine placeholder profile (AC3)

In `template/AGENTS.md`, require the `## Project profile` heading and, for each of
the ten documented field labels (`Purpose`, `Primary language(s)`,
`Package manager`, `Install`, `Test`, `Lint`, `Typecheck`, `Format`, `Build`,
`Key directories`; `template/AGENTS.md:15-24`), a line
`- **<label>**: _…_` whose value is a placeholder (matches `^_.*_$` after
trimming). Any field carrying a concrete value — e.g. the framework's
`bash tests/run.sh` or a filled Purpose — fails naming `template/AGENTS.md` and
the field. Only `template/AGENTS.md` is inspected, so the framework's own
bootstrapped root `AGENTS.md` is never flagged for containing values (spec edge
case: maintainer root copy present and bootstrapped).

### 5. Copy-set surfaces do not claim a root copy (AC4)

For each surface in `README.md`, `docs/customization.md`, `tests/README.md`,
`CONTRIBUTING.md`:

- **Positive anchor.** Require the surface to name all three pristine sources
  `template/AGENTS.md`, `template/opencode.json`, `template/.gitignore`. This is
  what makes the negative scan meaningful: a surface that stops describing the
  split cannot pass vacuously.
- **Wrong-claim scan.** Evaluate each line; flag a line that names one of the
  three files **and** contains a copy verb **and** a root marker **and** no
  negation. Patterns (case-insensitive, awk over lines):

  ```
  COPY_VERB  = cop(y|ies|ied)|receiv(e|es|ed)|give(s|n)?|get(s)?
  ROOT_MARKER= root|maintainer
  NEG        = never|not|no |outside|excluding|neither
  FILE       = AGENTS\.md|opencode\.json|\.gitignore
  ```

  This mirrors `90-packaging.sh` AC19's "a copy marker and a protected filename
  must not share a line" style (`tests/checks/90-packaging.sh:157-169`) while
  exempting the surfaces' correct negated statements ("never copied",
  "maintainer-bootstrapped and never copied"). It is line-scoped, not
  sentence-windowed over flattened text, to avoid bridging a root reference in one
  sentence with a filename in the next. A hit fails naming the surface and the
  offending line.

  Validation against today's live text (all must pass): `README.md:60-70`,
  `docs/customization.md:21-40`, `tests/README.md:5-16`,
  `CONTRIBUTING.md:121-136` each contain root references only inside negated
  statements, and the table row
  `| \`AGENTS.md\` | \`template/AGENTS.md\` … | root \`AGENTS.md\` … |`
  contains no copy verb, so it is not flagged.

### 6. Bootstrap deny guard (AC6)

Parse `.opencode/agent/bootstrap.md`'s frontmatter `permission.edit` map into an
**ordered** list of `pattern<TAB>action`, reusing the indentation-based scan style
of `tests/checks/30-permissions.sh:22-61`. Implement
`resolve_edit <path>` by walking the list in file order and remembering the last
pattern that matches via `case "$path" in $pattern)` — POSIX shell `case` pattern
matching, where `*` spans `/`, which is exactly the "last-match-wins" evaluation
the framework documents (`docs/customization.md:161-170`).

Assert:

- `template/AGENTS.md`, `template/opencode.json`, `template/.gitignore` resolve
  **deny**.
- `template/sub/AGENTS.md` resolves **deny** (catches narrowing `template/**` to a
  single level).
- `/repo/template/AGENTS.md` (absolute form, matching `**/template/**`) resolves
  **deny**.
- `AGENTS.md`, `opencode.json`, `.gitignore`, `/repo/AGENTS.md` resolve **allow**
  (the adopter's own root files stay editable).

Removing either deny, or reordering a broad root-file allow (`**/AGENTS.md`,
`**/opencode.json`, `**/.gitignore`) after the denies, flips a `template/` sample
to allow and fails, naming `bootstrap`. Because the samples are chosen so both
the relative and absolute forms are exercised, the check is stable under either
`*`-crosses-slash convention.

### 7. Documentation and mutation (AC7, AC8)

- `tests/README.md`: add a Checks-table row for `95-split-guard.sh` and a
  mapping paragraph after the existing `AC18`–`AC20` mapping
  (`tests/README.md:79-84`), leaving the packaging descriptions in place. Record
  the token `AC21` and the source-of-truth mapping it guards (quickstart sources,
  `docs/customization.md` split contract, `template/AGENTS.md`, copy-set surfaces,
  `bootstrap` permission map).
- `tests/mutation.sh`: add one section for the new area, applying exactly one
  mutation to the staged copy and asserting the suite catches and names it, then
  restoring the file and re-asserting the clean run (the existing
  `check_mutation`/`restore_file`/`assert_clean_absent` helpers,
  `tests/mutation.sh:84-133`):
  - Mutation: `replace_first "$COPY/README.md" 'template/AGENTS.md' 'AGENTS.md'`
    — re-points the first quickstart copy (block line, `README.md:49`) at the
    framework's root copy.
  - Expected substring: the AC2 missing-source message,
    `AC21 README.md quickstart does not source AGENTS.md from template/AGENTS.md`.
    The check emits this whenever a required `template/$f` pair is absent, which
    the mutation guarantees regardless of the separate root-offender message.
  - Also extend the file header comment's area list (AC6-AC13, AC18-AC20) with
    `AC21` (`tests/mutation.sh:15`).

`stage()` already copies every surface the new guard reads — `README.md`,
`CONTRIBUTING.md`, `docs/*.md`, `tests/README.md`, `template/`, and
`.opencode/agent` (`tests/mutation.sh:59-72`) — so no staging change is needed.
`run.sh` reads the new check from the real `tests/checks/` while pointed at the
staged copy, so the mutation exercises it without copying check files.

## Alternatives considered

- **Extend `90-packaging.sh` instead of a new file.** Pros: keeps all copy-set
  guards together; no new file. Cons: packaging is a distinct agreement area with
  its own tokens `AC18`–`AC20` and its own copy-set semantics (four packaging
  files, not the three bootstrap-mutable ones); folding the split in blurs the
  area, forces the tests/README mapping to interleave, and makes the single
  `AC21` mutation target ambiguous. Rejected — the runner explicitly treats "one
  file = one area" and needs no edit (`tests/README.md:26-27, 64-67`).
- **One token per guarded property (`AC21`–`AC25`).** Pros: finer mapping to the
  spec's five observable guarantees. Cons: the spec names **one** new area and one
  mutation; five tokens imply five mutation targets and contradict the resolved
  user decision. Rejected.
- **Exact-literal `cp` matching** (`grep -F 'cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md'`).
  Pros: trivial, no parser. Cons: fails the spec's "legitimate quickstart
  reformatting" edge case (whitespace/quoting/loop rewrites that preserve the
  mapping), which the spec requires to pass. Rejected.
- **Execute `opencode debug agent bootstrap` and inspect resolved permissions.**
  Pros: uses opencode's real matcher. Cons: the `opencode` CLI is optional and
  absent in the forced-absent mutation run; the spec fixes the guards as static
  assertions. Rejected for the committed guard; the optional CLI check remains
  available as a manual confirmation elsewhere.
- **AC4 as a positive-only assertion** (each surface names the pristine sources).
  Pros: no false-positive risk. Cons: does not fail on a *reintroduced* claim, as
  AC4 requires. Rejected in favour of the positive anchor plus the bounded
  wrong-claim scan.
- **Sentence-window scan over flattened surfaces.** Pros: catches claims split
  across wrapped lines. Cons: a flattened window bridges unrelated adjacent
  sentences and produced false positives against the current correct text.
  Rejected for the line-scoped scan with the positive anchor.

## Interfaces and data model

### New committed surface

| Artifact | Change |
| -------- | ------ |
| `tests/checks/95-split-guard.sh` | New agreement area; token `AC21` |
| `tests/README.md` | Checks-table row + `AC21` mapping paragraph |
| `tests/mutation.sh` | One `AC21` mutation section + header area list |

Unchanged: `tests/run.sh`, `tests/lib.sh`, all other `tests/checks/*.sh`, and every
non-`tests/` surface. No new file, dependency, install step, config key, or
interface outside `tests/`.

### Check helper contracts (internal to `95-split-guard.sh`)

```
quickstart_pairs <README>     # stdout: "source<TAB>destination" per copy pair,
                              # quotes stripped, "$FRAMEWORK/" stripped, loops expanded

contract_sources <CUST>       # stdout: "file<TAB>template/<file>" per contract row
                              # for the three bootstrap-mutable files

edit_rules <agent-file>       # stdout: "pattern<TAB>action" in file order from
                              # the frontmatter permission.edit map

resolve_edit <path>           # stdout: the action of the last matching pattern
                              # (or "unmatched"); uses case pattern matching
```

### Suite-token contract

- Area: adoption split guard.
- Token: `AC21` (next free after `AC18`–`AC20`).
- Sub-assertion message prefixes: `AC21 quickstart …`, `AC21 template/AGENTS.md …`,
  `AC21 <surface> …`, `AC21 bootstrap …`.
- Mapping documented in `tests/README.md`: spec AC2 → quickstart source/destination,
  AC3 → `template/AGENTS.md` placeholder profile, AC4 → copy-set surfaces,
  AC5 → quickstart↔contract agreement, AC6 → `bootstrap` deny guard.

### Compatibility and migration

None. No adopter-facing behavior, config, copied file, or existing suite token
changes; existing agreements (`AC6`–`AC20`) stay green. The mutation self-check is
opt-in and not in CI, so no CI change is introduced.

## Affected areas

New:

- `tests/checks/95-split-guard.sh`.

Modified:

- `tests/README.md` — Checks table row and `AC21` mapping paragraph.
- `tests/mutation.sh` — one `AC21` mutation section; header area list.

Read-only inputs the guard asserts against (never edited): `README.md`,
`docs/customization.md`, `tests/README.md`, `CONTRIBUTING.md`,
`template/AGENTS.md`, `template/opencode.json`, `template/.gitignore`, and
`.opencode/agent/bootstrap.md`.

## Risks and mitigations

- **AC4 wrong-claim scan false-positives on the correct surfaces** — likelihood
  medium / impact high (breaks AC1). Mitigation: line-scoped rather than
  flattened; negation exemption; validated against the live sentences listed in
  Approach §5; T3 runs `bash tests/run.sh` and the scan is tuned until the
  clean tree exits 0.
- **Quickstart parser rejects a legitimate loop rewrite** — likelihood medium /
  impact medium. Mitigation: loop expansion is built in for the same-line
  `for … in …; do` form; each required file fails independently and names
  `README.md` + the file, so a miss is visible rather than a silent pass.
- **Parser accepts a wholesale `template/` directory copy** — likelihood low /
  impact high (a real leak would pass). Mitigation: explicit directory-source
  rejection for `template`, `template/`, `template/.`, plus the per-file pair
  requirement that a directory source cannot satisfy.
- **Bootstrap resolution diverges from opencode's real matcher** — likelihood
  low / impact medium. Mitigation: behavioral last-match resolution rather than
  pattern-presence checks; samples are chosen so the relative and absolute
  outcomes are identical under either `*`-crosses-slash convention; ordering
  regressions (broad allow after deny) are caught by the `template/` samples.
- **Mutation literal edits prose, not the block** — likelihood low / impact low.
  Mitigation: `replace_first` targets the first `template/AGENTS.md`, which is
  `README.md:49` inside the bash block (prose follows at `README.md:62`); T6
  confirms the mutation is caught and named, and names the block-source file.
- **New token collides with a future area** — likelihood low / impact low.
  Mitigation: `AC21` is the greatest existing token plus one; T5 records it in
  `tests/README.md` so it is the documented next-free point.
- **`tests/README.md` edit displaces the packaging mapping** — likelihood low /
  impact low. Mitigation: T5 is additive and verifies the `AC18`–`AC20` text is
  still present.

## Test strategy

| Criterion | Verification level | Where |
| --------- | ------------------ | ----- |
| AC1 | integration | T7: `bash tests/run.sh` exits 0 and `bash tests/mutation.sh` exits 0 |
| AC2 | unit (static parser) | T1: quickstart pairs contain `template/<file>` → `./<file>` for all three; no root source; whole-dir copy rejected; missing block/source fails |
| AC3 | unit (grep/awk) | T2: `template/AGENTS.md` ten profile fields are placeholders |
| AC4 | unit (grep/awk) | T3: four surfaces name the pristine sources and have no wrong-claim line |
| AC5 | unit (parser compare) | T1: `docs/customization.md` source per file equals the quickstart source |
| AC6 | unit (ordered resolution) | T4: relative/absolute/nested `template/` paths deny; root files allow |
| AC7 | unit (grep) | T5: row + `AC21` mapping present; `AC18`–`AC20` retained |
| AC8 | integration (mutation) | T6: `bash tests/mutation.sh` reports `mutation AC21 caught and named` and `0 failed` |
