---
feature: 0004-adoption-template-split/0001-adopter-template-split
phase: design
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0004-adoption-template-split
notes: "Resolves the spec's design-deferred open questions. Pristine representation = a visible root `template/` directory holding `AGENTS.md`, `opencode.json`, and `.gitignore`; the framework keeps its live copies at the root. No machine-readable copy-set manifest is introduced; the split is documented as a per-file contract and guarded later by child 0003. The framework's own Project profile values are fixed in 'Interfaces and data model'. The intermediate quickstart leak window is accepted and sequenced around child 0002."
---

# Design — Adopter/maintainer template split

## Summary

Stand up an adopter-pristine source for the three files `/bootstrap` mutates —
`AGENTS.md`, `opencode.json`, and `.gitignore` — in a new root `template/`
directory, leaving the framework repository's live copies at the root. Snapshot
the pristine `AGENTS.md` before filling the framework's own Project profile with
verified values, so the template keeps its placeholders while the maintainer copy
becomes a real bootstrapped contract. Document the per-file split contract in
`docs/customization.md`, and keep the committed packaging/inventory/instruction
agreements green by teaching `README.md`'s `Layout` block and the mutation
self-check about the new directory.

## Approach

### 1. Adopter-pristine sources in `template/`

Add a visible root directory `template/` containing:

- `template/AGENTS.md` — a byte-for-byte snapshot of the current root `AGENTS.md`
  (the unfilled placeholder template). Created **before** the root profile is
  filled, so it captures the pristine state.
- `template/opencode.json` — a byte-for-byte copy of the root `opencode.json`.
- `template/.gitignore` — a byte-for-byte copy of the root `.gitignore`.

The framework's own copies remain exactly where opencode loads them: root
`AGENTS.md` (named by `opencode.json:6-10`) and root `opencode.json` /
`.gitignore`. The split is a **designation plus a snapshot**, not a move: the
live contract stays at the fixed root location (spec "Live contract location is
fixed").

`opencode.json` and `.gitignore` currently hold only framework-wide defaults, not
maintainer-bootstrapped values, so their pristine copies are initially
byte-identical to the framework's copies. This is explicitly permitted by the
spec edge case "Byte-identical copies": the mapping is still designated, and the
two files diverge only if a future `/bootstrap` of this repository sets
`mcp.playwright.enabled` or changes an ignore rule. Only `AGENTS.md` diverges
today, because only its Project profile is bootstrapped.

`template/opencode.json` is not auto-loaded: opencode merges project config by
walking **up** from the cwd to the worktree root (`.opencode/opencode.json`,
`./opencode.json`), never recursively downward, and the `instructions` array
names root-relative paths. So the pristine copy cannot become the framework's
contract (AC7).

### 2. Fill the framework's own Project profile

Replace the placeholder body of the `## Project profile` section in the root
`AGENTS.md` with verified framework values, and remove the
`<!-- /bootstrap replaces the placeholders below ... -->` comment. Change
nothing else in the file: the template blockquote at lines 7-9 and the trailing
`project-discovery` guidance stay, matching `/bootstrap`'s documented
"change nothing else in the file" behavior (`bootstrap.md:88`) and the spec's
scope of AC2 (the Project profile only). The values are fixed below in
"Interfaces and data model".

### 3. Document the split contract

Add a new section to `docs/customization.md`, the canonical "where things live"
reference, stating for each bootstrap-mutable file both the adopter-pristine
source and the framework's own copy, and stating that the rest of the copied set
(`.opencode/{agent,command,skill}` and `docs/*.md`) has a single source and is
shared verbatim. This is the authority child `0002` consumes and child `0003`
guards. It is additive: the existing copy-set prose (lines 43-51) is left for
child `0002` to rewire.

Because filling the profile changes `AGENTS.md`'s size, refresh the
"Always-loaded instructions" table's `AGENTS.md` row and total from the measured
file size (the table's own instruction at lines 43-44), keeping the set of three
paths unchanged so `50-instructions.sh` stays green.

### 4. Keep the committed agreements green

- **`README.md` `## Layout`** must document the new top-level `template/`
  directory and its three files, or `tests/checks/90-packaging.sh` AC20 fails
  its reverse (undocumented root entry) or forward (missing documented entry)
  check. The spec edge case "Root layout agreement" anticipates this.
- **`tests/mutation.sh` `stage()`** must copy `template/` into the staged copy;
  otherwise the mutation self-check's AC20 forward check sees `template/`
  documented in `README.md` but absent from the copy. This is harness
  maintenance, not a new committed guard (which belongs to child `0003`).

The already-green agreements remain untouched: `40-inventory.sh` reads
`.opencode/{agent,command,skill}` counts, `50-instructions.sh` reads root
`opencode.json` and `docs/customization.md`, `70-pin.sh` reads root
`opencode.json`, and `90-packaging.sh`'s AC19 scans copy-set surfaces for
packaging filenames — none of which the new `template/` files enter.

### 5. Out of scope (sibling children)

Do not touch `.opencode/agent/bootstrap.md` (0002 reworks `/bootstrap`), the
quickstart copy commands or copy-set prose in `README.md`/`tests/README.md`
(0002), committed split guards (0003), `/doctor` (0004), or the command-signature
sweep and `ask.md` (0005).

## Alternatives considered

- **Pristine representation: visible root `template/` directory (chosen) vs.
  suffixed root siblings (`AGENTS.template.md`, `opencode.template.json`,
  `.gitignore.template`).** Siblings avoid a new directory but still add
  non-hidden root entries (so `Layout` and mutation staging change anyway); the
  on-disk names no longer match the destination names adopters receive; and a
  hidden `.gitignore.template` is skipped by the `Layout` reverse check, making
  the mapping harder to guard. Rejected — a single directory gives one
  unambiguous source path per file and a clean target for the 0002/0003/0004
  consumers.
- **Pristine under hidden `.opencode/template/`.** It would avoid the `README`
  `Layout` and mutation-staging edits, but hides the adopter source of truth in
  the framework's installed-config tree (where `/bootstrap`, `/doctor`, and the
  test inventory look for agents/commands/skills), and is easy for the sibling
  children to miss. Rejected — the spec anticipates a top-level path, and
  visibility is worth the small, bounded Layout/staging work.
- **Contract home: new section in `docs/customization.md` (chosen) vs. a new
  `template/README.md` vs. a paragraph in `tests/README.md`.** `docs/customization.md`
  is the canonical "where things live" authority, is the surface the roadmap
  names for the copy-set story, and is copied verbatim alongside the files it
  describes. A `template/README.md` is co-located but is not a canonical docs
  surface; `tests/README.md` is test-scoped and its copy-set prose is owned by
  child `0002`. Rejected.
- **Force `opencode.json`/`.gitignore` to diverge artificially (e.g. a marker
  key).** It would make the split visible in the files but adds config opencode
  may reject and contradicts "the pristine source is what adopters receive". The
  spec explicitly allows byte-identical copies. Rejected.
- **Generate the pristine files at release time from a manifest.** Introduces
  tooling, a build step, and a new failure mode for a three-file split; the
  spec's non-goals forbid new install/build steps. Rejected.

## Interfaces and data model

### Adopter-pristine source mapping

| Copied file | Adopter-pristine source | Framework repository's own copy |
| ----------- | ----------------------- | ------------------------------- |
| `AGENTS.md` | `template/AGENTS.md` (placeholder profile) | root `AGENTS.md` (bootstrapped profile) |
| `opencode.json` | `template/opencode.json` | root `opencode.json` (loaded by opencode) |
| `.gitignore` | `template/.gitignore` | root `.gitignore` (active) |
| `.opencode/{agent,command,skill}` | single source, shared verbatim | — (no split) |
| `docs/*.md` | single source, shared verbatim | — (no split) |

### Framework `AGENTS.md` Project profile (exact values)

```markdown
## Project profile

- **Purpose**: A portable, prompt-driven development workflow for opencode: agents, commands, and skills with committed lifecycle artifacts.
- **Primary language(s)**: none (opencode prompt/config files; the test harness is Bash)
- **Package manager**: none
- **Install**: none
- **Test**: `bash tests/run.sh`
- **Lint**: none
- **Typecheck**: none
- **Format**: none
- **Build**: none
- **Key directories**: `.opencode/`, `docs/`, `tests/`, `work/`
```

Every field is a verified value or an explicit `none`; the `Test` field names the
committed suite (`tests/README.md:13-17`). No placeholder or example text
remains in the root copy; the same section in `template/AGENTS.md` keeps the
original placeholders.

### Split-contract section in `docs/customization.md`

A new section (placed after "Where things live") with, at minimum:

- The mapping table above (both source paths and both copy names for all three
  bootstrap-mutable files).
- A sentence that `/bootstrap` mutates exactly those three files, so the
  framework's own copies must never be copied into an adopted repository.
- A sentence that `.opencode/{agent,command,skill}` and `docs/*.md` have a
  single source and are shared verbatim; `docs/*.md` are never templated.

### `README.md` `## Layout` addition

Document the new directory and its files (consistent with the existing
`docs/`/`.opencode/` indented style):

```
template/                   # adopter-pristine sources (maintainer-only)
  AGENTS.md                 # placeholder Project profile
  opencode.json             # config adopters receive
  .gitignore                # ignore rules adopters receive
```

### `tests/mutation.sh` `stage()` addition

Copy the directory into the staged tree so the AC20 `Layout` forward check finds
it:

```sh
cp -R "$REPO_ROOT/template" "$COPY/template"
```

No new dependency, runtime, schema, migration, or public interface. Existing
adopters need no action: no copied file changes behavior or merge semantics, and
the quickstart is unchanged by this child.

## Affected areas

New:

- `template/AGENTS.md`, `template/opencode.json`, `template/.gitignore`.

Modified:

- `AGENTS.md` (Project profile filled; placeholder comment removed).
- `docs/customization.md` (new split-contract section; refreshed always-loaded
  cost rows).
- `README.md` (`## Layout` documents `template/`).
- `tests/mutation.sh` (`stage()` copies `template/`).

Unchanged: `opencode.json`, `.gitignore`, everything under `.opencode/**`
(incl. `bootstrap.md`), `docs/workflow.md`, `docs/artifact-conventions.md`,
`tests/run.sh`, `tests/lib.sh`, `tests/checks/**`, `tests/README.md`, and
`.github/workflows/ci.yml`.

## Risks and mitigations

- **Intermediate quickstart leak window** — until child `0002` rewires the
  documented quickstart, running it literally would copy the now-bootstrapped
  root `AGENTS.md`. Likelihood certain / impact high / mitigation: accepted by
  the spec ("Unprotected intermediate window"); this child's AC1/AC5 are scoped
  to the pristine *source*, and the handoff flags that no release/cutover may
  happen between this child and `0002`, which is sequenced immediately next.
- **`README` `Layout` or mutation self-check regression** — likelihood medium /
  impact medium / mitigation: T4 documents `template/` and runs `bash
  tests/run.sh`; T5 copies `template/` in `stage()` and runs `bash
  tests/mutation.sh`, both to exit 0.
- **`template/AGENTS.md` loaded as the framework's instructions** — likelihood
  low / impact medium / mitigation: opencode discovers project config by walking
  up (not down) and `instructions` names root paths; T2 verifies with `opencode
  debug config` (or the static equivalent) that the resolved set still names root
  `AGENTS.md` and not the pristine copy.
- **`template/.gitignore` affecting the repository's ignore semantics** —
  likelihood low / impact low / mitigation: Git applies a nested `.gitignore`
  only to its own subtree; the pristine content is unchanged and its patterns are
  inert under `template/`. Documented in the contract section.
- **Contract section confuses adopters (docs are copied verbatim)** — likelihood
  medium / impact low / mitigation: phrase it as framework-repo organization,
  consistent with the existing maintainer-only statements in
  `docs/customization.md:48-51`; child `0002` reconciles the surrounding prose.
- **Stale always-loaded cost table** — likelihood low / impact low /
  mitigation: T3 re-measures `AGENTS.md` and refreshes the row/total per the
  table's own instruction; the path set is unchanged so `50-instructions.sh`
  stays green.
- **Pristine/maintainer drift after this child** — likelihood medium / impact
  high / mitigation: intentionally deferred to child `0003`'s committed guards;
  this child establishes the documented authority those guards will read.

## Test strategy

| Criterion | Verification level | Where |
| --------- | ------------------ | ----- |
| AC1 | unit (command comparison) | T1: `template/{AGENTS.md,opencode.json,.gitignore}` exist; pristine `AGENTS.md` holds placeholders |
| AC2 | unit (grep) | T2: no placeholder/example text remains in root `AGENTS.md`; all ten fields filled |
| AC3 | unit (grep) | T1: `template/AGENTS.md` still presents the placeholder template |
| AC4 | unit (grep) | T3: contract names all three pristine sources, both copies, and "shared verbatim" |
| AC5 | unit (diff + grep) | T2: pristine `AGENTS.md` retains placeholders, root does not; `opencode.json`/`.gitignore` copies carry no bootstrapped value; guarded later by child 0003 |
| AC6 | integration | T4: `bash tests/run.sh` exits 0 (AC20 green); T5: `bash tests/mutation.sh` exits 0 |
| AC7 | integration + static | T2: `opencode debug config` parses and names root `AGENTS.md`; `opencode.json` `instructions` does not reference `template/` |
