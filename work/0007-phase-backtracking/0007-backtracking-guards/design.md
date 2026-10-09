---
feature: 0007-phase-backtracking/0007-backtracking-guards
phase: design
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "Resolves the spec's deferred design choices: stable suite token AC24; check file tests/checks/87-backtrack-guards.sh; fixture tree tests/fixtures/backtracking/ with a fixture-local items/ root; eight declared sub-areas (reverse-edge, record-status, stale-downstream, challenge-loop, roadmap-revision, readiness-revocation, derived-state, contract-pins). Treats the spec's two design-blocking assumptions as confirmed by its own non-goals: the 0001-0006 contracts are final and only the committed test suite and its documentation are touched, offline with no provider. Re-entry revision: Finding 1 (recorded by /build) corrected the §5 mutation anchor for `challenge-loop` — it referenced a nonexistent `## Response 2`; the anchor is now the fixture's sole `## Reversal 3` header, which drops the Reversal entry and trips only `challenge-loop`. Resolution 1 appended to backtracks.md. Re-entry revision 2: Finding 2 (recorded by /build) corrected the §5 `record-status` mutation anchor — `fixture_backtrack_status` matches on the `## Resolution <n>` header number, not the `- resolves: Finding <n>` body field, so the anchor now renames the resolution header to `## Resolution 9`; §4 names the matching key explicitly. Resolution 2 appended to backtracks.md; `tasks.md` needed no edit because T5 delegates to design §5."
conflicts-with: "tests/checks, tests/fixtures, tests/README.md, tests/mutation.sh"
---

# Design — Committed backtracking and reopen guards

## Summary

Add one committed agreement area, `tests/checks/87-backtrack-guards.sh` (suite
token `AC24`), plus a new fixture-local item tree at
`tests/fixtures/backtracking/items/`. The check parses the committed fixture data
with pure bash/awk, computes the mechanical rules (reverse-edge finding fields,
record effective status, the per-edge `stale:` map, challenge-record effective
status, roadmap-revision integrity, the recalled-item readiness revocation, and
the derived-state labels), and pins the documented record/marker shapes that are
not computable from a fixture against the live authorities by name. It then
extends `tests/mutation.sh` so each of the eight sub-areas is proven caught and
named, and documents the area in `tests/README.md`. No production surface
changes.

## Approach

### 1. One new agreement area, fixture-scoped

`tests/checks/87-backtrack-guards.sh` is sourced by `tests/run.sh` like every
other area, is Bash 3.2 compatible, and never calls `exit`. It is
**prompt-contract test code over committed fixtures** — the exact analogue of
`80-cycle-fixture.sh` pinning the prompt-only `CYCLIC-DEP` rule and
`85-conflict-guards.sh` pinning the prompt-only declared-conflict check — not a
production checker. It implements no command, is invoked by no framework
command, and never reads live `work/**`. It is placed at filename position 87
(between `85-conflict-guards.sh` and `90-packaging.sh`), so `run.sh` needs no
edit and it sorts after the areas it references.

The file prints `ok`/`FAIL` lines labelled `AC24 <sub-area>` for the eight
declared sub-areas, so a mutation names the guard it trips. The sub-areas are the
mutated set (§5): `reverse-edge`, `record-status`, `stale-downstream`,
`challenge-loop`, `roadmap-revision`, `readiness-revocation`, `derived-state`,
`contract-pins`. Structural assertions (`fixture-existence`,
`read-only-contract`, `no-duplication`) are labelled with the area but are not
declared sub-areas and carry no mutation, matching the `85` precedent where
`fixture-existence`/`read-only-contract` are outside the mutated set.

### 2. Fixture-local `items/` root

`tests/fixtures/backtracking/items/` shadows the live `work/` root, exactly as
`tests/fixtures/declared-conflicts/items/` does: every fixture item reference
resolves inside that tree and the fixture contains no live `work/` path. Item
directories use a `91xx` top-level prefix so they never collide with the
`90xx`/`0001` numbers of the conflict fixture's own shadow root.

### 3. Fixture data

Record and reverse-edge items (each a "standalone" item: a top-level dir with a
`spec.md`, not a `roadmap.md`):

| Path | Contents | Exercises |
| ---- | -------- | --------- |
| `items/9101-build-design` | `spec.md`; `design.md`; `tasks.md`; `verify.md` (`stale: design`); `review.md` (`stale: design`); `backtracks.md` Finding 1 (detecting `/build`, target `/plan`, affected `design.md`, `tasks.md`, `status: open`) | design-target edge `/build`→`/plan`; target artifacts `design.md`/`tasks.md` unmarked |
| `items/9102-plan-spec` | `spec.md`; `design.md` (`stale: spec`); `tasks.md` (`stale: spec`); `verify.md` (`stale: spec`); `review.md` (`stale: spec`); `backtracks.md` Finding 1 (detecting `/plan`, target `/spec`, affected `spec.md`, `status: open`) | spec-target edge `/plan`→`/spec`; target artifact `spec.md` unmarked |
| `items/9103-test-plan` | `spec.md`; `design.md`; `tasks.md`; `verify.md` (`stale: design`); `review.md` (`stale: design`); `backtracks.md` Finding 1 (detecting `/test`, target `/plan`, affected `design.md`, `tasks.md`, `status: open`) | `/test`→`/plan` design-target edge |
| `items/9104-test-spec` | `spec.md`; `design.md` (`stale: spec`); `tasks.md` (`stale: spec`); `verify.md` (`stale: spec`); `review.md` (`stale: spec`); `backtracks.md` Finding 1 (detecting `/test`, target `/spec`, affected `spec.md`, `status: open`) | `/test`→`/spec` spec-target edge |
| `items/9105-test-build` | `spec.md`; `design.md`; `tasks.md` (unchecked); `verify.md`; **no** `review.md`; **no** `backtracks.md`; **no** `stale:` markers | `/test`→`/build` implementation-defect rework forces no finding and no marker; derives the ordinary forward `build` |
| `items/9106-review-build` | `spec.md`; `design.md`; `tasks.md`; `verify.md`; `review.md` (verdict `request-changes`); **no** `backtracks.md`; **no** `stale:` markers | `/review`→`/build` rework forces no finding and no marker; derives `build (rework)` |
| `items/9107-resolved` | `spec.md`; `design.md`; `tasks.md`; `backtracks.md` Finding 1 + matching Resolution 1 | finding effective status `resolved` |
| `items/9108-malformed` | `spec.md`; `design.md`; `tasks.md`; `backtracks.md` with `## Resolution 1` **before** `## Finding 1` | malformed order reported, not reordered |

Challenge-record items:

| Path | Contents | Exercises |
| ---- | -------- | --------- |
| `items/9109-challenge-open` | `spec.md`; `design.md`; `tasks.md`; `challenges.md` Challenge 1 (`type: severity`, `status: open`), no Response | open challenge on an unshipped item |
| `items/9110-challenge-mixed` | `spec.md`; `design.md`; `tasks.md`; `challenges.md` Challenge 1 (`type: severity`) + Response 1 (`adjudicator: /review`, `decision: sustained`); Challenge 2 (`type: finding`) + Withdrawal 2; Challenge 3 (`type: acceptance-criterion`) + Response 3 (`adjudicator: user`, `decision: rejected`) + Reversal 3 (`adjudicator: user`, `decision: sustained`) | all four entry kinds; all three `type` tokens; both `decision` tokens; both `adjudicator` values; Reversal supersedes without reopening |
| `items/9111-challenge-malformed` | `spec.md`; `design.md`; `tasks.md`; `challenges.md` with `## Response 1` before `## Challenge 1` | malformed order reported, not reordered |
| `items/9112-shipped-challenge` | `spec.md`; `design.md`; `tasks.md`; `review.md` (verdict `approve`); `ship.md`; `challenges.md` Challenge 1 open | a shipped item is never derived `challenged` |

Derived-state items:

| Path | Contents | Derived label |
| ---- | -------- | ------------- |
| `items/9113-reopened` | `spec.md`; `design.md`; `tasks.md`; `verify.md`; `review.md`; `ship.md` with `reopened: design`; **no** `stale:` markers | `design (reopened)` |
| `items/9114-forward` | `spec.md`; `design.md`; `tasks.md` (unchecked); no records, no markers | `build` (ordinary forward; no invented state) |

Roadmap-parent items (each a top-level dir with `roadmap.md`):

| Path | Contents | Exercises |
| ---- | -------- | --------- |
| `items/9120-revised-roadmap` | 6-column `roadmap.md`: active rows `0001-kept` (dep `—`), `0002-added` (dep `0001-kept`), `0003-dep` (dep `—`), `0004-dependent` (dep `0003-dep`); child dirs `0001-kept/`, `0002-added/`, `0003-dep/`, `0004-dependent/`, `0005-withdrawn/`; `## Open issues` carries a `**Withdrawn child — `0005-withdrawn`.**` record and a `**Revised 2026-10-09.**` revision note naming the triggering child, `Operations: re-scope/add/withdraw/re-sequence`, and `Invalidated:` | roadmap-revision integrity: positional columns, dep-names-a-row, no self-dep, acyclic, refs resolve, active children listed, sequencing order, withdrawal preserved-but-unlisted, revision-note fields |
| `items/9121-readiness` | 6-column `roadmap.md` rows `0001-recalled` (`ship.md` with `reopened: build`), `0002-approved` (`review.md` verdict `approve`), `0003-shipped` (`ship.md`, no marker), `0004-dependent` (dep `0001-recalled, 0002-approved, 0003-shipped`); no readiness column | recalled dependency computes not satisfied; approved-unshipped and shipped compute satisfied; the dependent is blocked by exactly `0001-recalled`; no stored readiness value |

No fixture file contains the literal `work/`; the roadmap fixtures name their
own children by their fixture-local canonical reference. The full fixture set is
the reviewed contract.

### 4. Analyzers and sub-areas

Pure bash/awk analyzers emit newline-delimited, `|`-separated, sorted output
compared to expected blocks. The parsers instantiate the live authorities as
fixture-scoped test detail (`docs/workflow.md` → "Phase reversal
(backtracking)", "Findings challenge and adjudication", "Roadmaps" → "Revising a
roadmap", "Dependencies and readiness", "Derived state"; and
`docs/artifact-conventions.md` → the `backtracks.md`/`challenges.md` templates).

- **`reverse-edge` (AC1).** `fixture_backtrack_findings` emits
  `<ref>|<finding-n>|<detecting>|<target>|<affected>|<effective>` for every
  finding entry in every item's `backtracks.md`, parsed from the entry's
  `- detecting phase:`, `- target phase:`, `- affected:`, `- status:` fields.
  Expected: `9101`–`9104` and `9107`/`9108` findings with the detecting/target
  phases tabulated above; a finding missing any field, or a sanctioned edge not
  represented in the expected set, fails and names the sub-area. Also asserts the
  live reverse-edge table exists in `docs/workflow.md` with the five sanctioned
  intra-item edges (`/build`→`/plan`, `/plan`→`/spec`, `/test`→`/plan`,
  `/test`→`/spec`, `/test`→`/build`).
- **`record-status` (AC2).** `fixture_backtrack_status` emits
  `<ref>|<finding-n>|<open|resolved>|<wellformed 0|1>`. A finding `n` is
  `resolved` when a `## Resolution <n>` entry exists; otherwise `open`. Matching
  is keyed on the resolution's `## Resolution <n>` **header number**, as the
  authority defines, not on the `- resolves: Finding <n>` body field (that
  literal is pinned separately by `contract-pins`). A resolution recorded before
  its finding sets `wellformed=0` and is listed in `fixture_backtrack_malformed`
  (expected `{9108-malformed}`); entries are never reordered. Expected status
  block: `9101`–`9104` open; `9107`/`9108` resolved.
- **`stale-downstream` (AC3).** `fixture_stale_map` emits
  `<ref>|<artifact>|<token|NONE>` for each present artifact's frontmatter
  `stale:` value. Expected: design-target edges (`9101`, `9103`) mark `verify.md`
  and `review.md` `stale: design` with `design.md`/`tasks.md`/`spec.md` `NONE`;
  spec-target edges (`9102`, `9104`) mark `design.md`, `tasks.md`, `verify.md`,
  `review.md` `stale: spec` with `spec.md` `NONE`; the rework items (`9105`,
  `9106`) mark nothing. The analyzer also asserts the target phase's own artifact
  (`design.md`/`tasks.md`; `spec.md`) is unmarked. The expected block is derived
  from the live per-edge marker table.
- **`challenge-loop` (AC4).** `fixture_challenge_entries` emits
  `<ref>|<kind>|<n>|<tokens>` for every `Challenge`/`Response`/`Withdrawal`/
  `Reversal` entry; `fixture_challenge_status` emits
  `<ref>|<challenge-n>|<open|resolved|withdrawn>|<wellformed 0|1>`; the observed
  `type` set must equal `{finding, severity, acceptance-criterion}`, the
  `decision` set `{sustained, rejected}`, and the adjudicator values
  `{/review, user}`. `fixture_challenge_malformed` is `{9111-challenge-malformed}`.
  The Reversal on `9110` leaves Challenge 3 `resolved` (it does not reopen it).
- **`roadmap-revision` (AC5).** `fixture_revision` parses
  `items/9120-revised-roadmap/roadmap.md` and emits one line per integrity
  check, expected empty (no fault): positional columns (`Depends on` pipe-field
  5, `conflicts-with` field 6); every `Depends on` names another row and no row
  self-depends; the graph is acyclic (Kahn, the same proof shape as
  `80-cycle-fixture.sh` but on this fixture); every canonical reference resolves
  to a child dir and every active child dir appears as a row; `## Sequencing`
  lists every active child after its dependencies; the withdrawn child's
  directory is preserved but unlisted. Positive assertions then require the
  revision note (`**Revised `, a `YYYY-MM-DD`, the triggering child,
  `Operations:`, `Invalidated:`) and the withdrawal record (`**Withdrawn child
  — `). This sub-area **references `80-cycle-fixture.sh` and
  `85-conflict-guards.sh` by name** and restates none of their authority phrases.
- **`readiness-revocation` (AC6).** `fixture_readiness` computes over
  `items/9121-readiness/`: for each child row, `satisfied` is 1 when the child
  dir has `ship.md` with no `reopened:` marker, or a `review.md` verdict
  `approve`; a `ship.md` carrying `reopened:` is 0. `fixture_readiness_blocked`
  emits the dependent's unsatisfied deps. Expected: `0001-recalled` 0,
  `0002-approved` 1, `0003-shipped` 1; `0004-dependent` blocked by
  `0001-recalled`. Asserts the fixture roadmap has no readiness column (no stored
  readiness value).
- **`derived-state` (AC7, AC8).** `fixture_derived` emits `<ref>|<label>` for
  each non-roadmap top-level fixture item, applying the derived-state precedence
  (earliest `stale:` marker → `<token> (backtracked)`; else `ship.md`
  `reopened:` → `<phase> (reopened)`; else an unshipped item with an open
  challenge → `challenged (blocked)`; else the artifact-presence/verdict rows).
  Expected block: `9101`→`design (backtracked)`, `9102`→`spec (backtracked)`,
  `9103`→`design (backtracked)`, `9104`→`spec (backtracked)`,
  `9105`/`9107`/`9108`/`9110`/`9111`/`9114`→`build`, `9106`→`build (rework)`,
  `9109`→`challenged (blocked)`, `9112`→`shipped`, `9113`→`design (reopened)`.
  Asserts `9112` (shipped with an open challenge) is never `challenged`, and
  `9114`/`9107`/`9108` invent no backtracked/challenged/reopened state.
- **`contract-pins` (AC9).** Content pins on the live authorities, referencing
  them by name and restating neither the readiness algorithm nor the command
  signatures. `docs/artifact-conventions.md`: `record: backtracks`,
  `record: challenges`, `- detecting phase:`, `- target phase:`, `- status: open`,
  `- resolves: Finding <n>`, `- revision:`, `## Challenge <n> — YYYY-MM-DD`,
  `## Withdrawal <n> — YYYY-MM-DD`, `## Reversal <n> — YYYY-MM-DD`,
  `- withdraws: Challenge <n>`, `- reverses: Response <n>`,
  `- adjudicator:`, `- decision:`, the `type` token set
  `finding | severity | acceptance-criterion`, the `stale` token set
  `spec | design | build | test | review`, and the `stale: ""`/`reopened: ""`
  frontmatter fields. `docs/workflow.md`: `` `P` (backtracked) ``,
  `` `P` (reopened) ``, `challenged (blocked)`, `build (rework)`,
  `stale: design`, `stale: spec`,
  `carrying a `reopened:` marker does not satisfy a dependent until the item
  re-ships`, and `forces no finding record or`.
- **Structural assertions.** `fixture-existence` fails (`bad`, never `skip`)
  when any required fixture path is absent; `read-only-contract` asserts the new
  fixture tree references no live `work/` path and that the check adds no
  committed executable production checker; `no-duplication` asserts the check
  file does not contain the exact literals owned by `10-readiness.sh`
  (`satisfied(dep_local_id):`, `presence is the sole shipped signal`),
  `20-lifecycle.sh` (`` `spec.md` missing ``, `No spec.md?`), or
  `96-signature-sweep.sh` (`` `/build [item-ref or task-id]` ``), and does
  reference those areas by name.

### 5. Mutation self-check (AC11)

`tests/mutation.sh` `stage()` gains
`cp -R "$REPO_ROOT/tests/fixtures/backtracking" "$COPY/tests/fixtures/backtracking"`
and eight mutation blocks (each `run_absent`; the check is not optional-tool
dependent), targeting the copy only:

| # | Mutation (on the copy) | Expected named sub-area |
| - | ---------------------- | ----------------------- |
| 1 | delete the `- target phase:` line from `items/9101-build-design/backtracks.md` | `AC24 reverse-edge` |
| 2 | rename `items/9107-resolved/backtracks.md` the resolution header `## Resolution 1` → `## Resolution 9` (Finding 1 is then unmatched and open) | `AC24 record-status` |
| 3 | change `items/9101-build-design/verify.md` `stale: design` → `stale: spec` | `AC24 stale-downstream` |
| 4 | change `items/9110-challenge-mixed/challenges.md` the Reversal header `## Reversal 3` → `## Ack 3` (the fixture's sole `Reversal`, so the entry drops and Challenge 3 stays `resolved`) | `AC24 challenge-loop` |
| 5 | reorder `items/9120-revised-roadmap/roadmap.md` Children header so `Depends on` is not pipe-field 5 | `AC24 roadmap-revision` |
| 6 | remove `reopened: build` from `items/9121-readiness/0001-recalled/ship.md` | `AC24 readiness-revocation` |
| 7 | change `items/9113-reopened/ship.md` `reopened: design` → `reopened: build` | `AC24 derived-state` |
| 8 | change `docs/artifact-conventions.md` `- resolves: Finding <n>` → `- resolves: <n>` | `AC24 contract-pins` |

Update the `mutation.sh` header comment's covered-area list to include `AC24`.

### 6. Documentation (AC13)

`tests/README.md` gains: a Checks-table row for `87-backtrack-guards.sh`; a
paragraph mapping stable token `AC24` to this item's acceptance criteria
(`spec AC1 → AC24 reverse-edge`, …, mirroring the `AC23` paragraph), declaring
the sub-areas, the `tests/fixtures/backtracking/` fixture root, the
fixture-based and never-reads-`work/**` contract, and the mutation coverage; and
a sentence recording the manual residual — a live `/status` render, a real
backtrack, or a `/ship recall` is not executable in CI, exactly as the cycle
diagnostic's LLM-run residual is.

## Alternatives considered

- **Extend `85-conflict-guards.sh` or `20-lifecycle.sh` in place instead of a
  new area.** Pros: no new file or token. Cons: couples two unrelated contracts
  under one token and one mutation namespace, contradicts the user's resolved
  "one new fixture-based check file with named sub-areas and one stable suite
  token", and makes the existing area's failure diagnosis ambiguous.
  **Rejected** for a dedicated `87-backtrack-guards.sh` with token `AC24`.
- **Reuse `tests/fixtures/declared-conflicts/items/` for the item tree.** Pros:
  no second fixture root. Cons: its items exist to exercise declarations, not
  backtrack records, and sharing the root would make each area's fixture a
  dumping ground and risk a duplicate cycle/positional assertion (AC12).
  **Rejected** for a separate `tests/fixtures/backtracking/items/` root.
- **Literal-presence pins only (no fixture analyzer).** Pros: smallest guard.
  Cons: it cannot prove that a genuine open finding, a per-edge marker, a
  recalled dependency, a revision, or a derived label exists — it would pass
  vacuously if the record data were emptied, failing the user's resolved
  "both executable fixture analyzers … and documented-contract phrase pins" and
  AC1–AC8. **Rejected** for a fixture-driven parser plus phrase pins.
- **Read live `work/**` to compute the rules instead of fixtures.** Pros:
  directly reproducible on the real artifacts. Cons: the suite is read-only and
  fresh-clone-clean (`tests/README.md:29`) and must never read live `work/**`;
  this would break AC10 and the roadmap assumption. **Rejected** for the
  fixture-local shadow root.
- **A committed executable production checker for the contracts.** Pros:
  runnable outside the suite. Cons: forbidden by the spec's non-goals; the
  workflow's guard contracts remain prompt behavior with no committed checker.
  **Rejected** for test-scoped code only.
- **One separate check file per sub-area.** Pros: isolation. Cons: multiplies
  suite tokens and filenames, contradicts the one-area-per-contract suite
  organization and the user's resolved single-file choice. **Rejected.**

## Interfaces and data model

**New check file:** `tests/checks/87-backtrack-guards.sh`, stable token `AC24`,
pure bash/awk, Bash 3.2 compatible (no associative arrays, no `mapfile`, no
empty-array expansion under `set -u`), sourced by `tests/run.sh` (must not call
`exit`).

**New fixture root:** `tests/fixtures/backtracking/items/**` as tabulated in
§3. Item dirs carry canonical fixture refs (`91xx-slug` or
`91xx-slug/0xxx-slug`); no fixture file references live `work/`.

**Analyzer output contracts** (newline-delimited, `|`-separated, sorted):

```
fixture_backtrack_findings : <ref>|<n>|<detecting>|<target>|<affected>|<status>
fixture_backtrack_status   : <ref>|<n>|<open|resolved>|<wellformed 0|1>
fixture_stale_map          : <ref>|<artifact>|<stale-token|NONE>
fixture_challenge_entries  : <ref>|<kind>|<n>|<tokens>
fixture_challenge_status   : <ref>|<n>|<open|resolved|withdrawn>|<wellformed 0|1>
fixture_revision           : <check-name>|<fault detail>   (empty when integral)
fixture_readiness          : <dep-ref>|<satisfied 0|1>
fixture_readiness_blocked  : <dependent-ref>|<blocked-by list>
fixture_derived            : <ref>|<label>
fixture_*_malformed        : <ref>
```

**Changed surfaces:**

- `tests/fixtures/backtracking/**` — new fixture data.
- `tests/checks/87-backtrack-guards.sh` — new agreement area (`AC24`).
- `tests/mutation.sh` — stage the new fixture; eight mutations; update the header
  comment's covered-area list.
- `tests/README.md` — Checks-table row, `AC24` mapping paragraph, manual
  residual sentence.

**Deliberately unchanged:** every production surface (`docs/**`,
`.opencode/{agent,command,skill}/**`, `README.md`, `AGENTS.md`, `template/**`,
`opencode.json`); the existing checks
(`10-readiness`, `20-lifecycle`, `40-inventory`, `80-cycle-fixture`,
`85-conflict-guards`, `96-signature-sweep`) and their fixtures; the parent
`roadmap.md`; and the `0001`–`0006` contracts.

**Backward compatibility and migrations:** none required. The suite stays
read-only and fresh-clone-clean; no live `work/**` is read; no command, agent,
skill, `phase` value, state file, frontmatter field, or inventory count changes;
no runtime dependency, network access, or `gh` call is introduced.

## Affected areas

- `tests/fixtures/backtracking/items/**` — new fixture-local item tree
  (AC1–AC8, AC10).
- `tests/checks/87-backtrack-guards.sh` — new area (AC1–AC10, AC12).
- `tests/mutation.sh` — staging + eight mutations (AC11).
- `tests/README.md` — area documentation and token (AC13).

## Risks and mitigations

- **Fixture parser drifts from the `0001`–`0006` authority** — likelihood medium
  / impact high. Mitigation: the parser is fixture-scoped test detail that
  instantiates the authority, the expected blocks are the reviewed contract, and
  the `contract-pins` sub-area pins the live shapes; any authority change must
  update the fixture and guard together.
- **Duplicate assertion of an existing area's contract (AC12)** — likelihood
  medium / impact medium. Mitigation: the new check reads none of the existing
  areas' inputs; its readiness computation is the recalled branch that
  `10-readiness.sh` does not own; its revision/positional checks run on a new
  fixture; and `no-duplication` negates the exact literals those areas own.
- **Fixture references a live `work/` path and breaks fresh-clone safety** —
  likelihood medium / impact high. Mitigation: the fixture-local `items/` root
  and the `read-only-contract` assertion (`grep -rq 'work/'` over the fixture
  root must be empty), mirroring `85`.
- **A mutation trips more than one sub-area or another area first** — likelihood
  medium / impact low. Mitigation: `run.sh` runs every check and checks never
  `exit`, so all failures are logged; each mutation asserts its own
  `AC24 <sub-area>` substring and the labels are independently reachable.
- **New fixture not staged by `tests/mutation.sh`** — likelihood medium /
  impact high. Mitigation: add it to `stage()` in the same task as the
  mutations; the clean-copy run fails loudly if the fixture is absent.
- **Bash 4 syntax breaks 3.2 compatibility** — likelihood low / impact high.
  Mitigation: no associative arrays/mapfile; follow `lib.sh`/`80`/`85` patterns;
  `bash tests/run.sh` is the gate.
- **The guard is mistaken for a production checker** — likelihood medium /
  impact low. Mitigation: name it an agreement area; document in the file header
  and `tests/README.md` that it is fixture-scoped test code, the analogue of the
  cycle and conflict guards.
- **Live-model-run residual is untested (by design)** — likelihood certain /
  impact low. Mitigation: record it explicitly in `tests/README.md` as a manual
  residual, matching the cycle diagnostic's documented LLM-run residual.

## Test strategy

The deliverable is test fixtures and test code; the guard is itself the
verification, run by the canonical suite. Each acceptance criterion maps to a
concrete assertion group or suite command.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | `fixture_backtrack_findings` expected block covers every edge fixture with detecting/target/affected/`status: open`; a dropped field fails `AC24 reverse-edge`; the live reverse-edge table is asserted. |
| AC2 | `fixture_backtrack_status` = the expected open/resolved block; `9108-malformed` is `wellformed 0` and named in `fixture_backtrack_malformed`; entries are never reordered. |
| AC3 | `fixture_stale_map` marks `9101`/`9103` downstream `stale: design`, `9102`/`9104` downstream `stale: spec`, `9105`/`9106` nothing, and asserts each target's own artifact unmarked. |
| AC4 | `fixture_challenge_entries`/`fixture_challenge_status` cover the four kinds, the three `type` tokens, both `decision` tokens, both adjudicator values, the `resolved`-after-Reversal fact, and `9111-challenge-malformed`. |
| AC5 | `fixture_revision` integrity block is empty on `9120-revised-roadmap`; the positional/no-self/acyclic/refs/active/sequencing/withdrawal/revision-note assertions pass. |
| AC6 | `fixture_readiness` = `0001-recalled` 0 / `0002-approved` 1 / `0003-shipped` 1; `fixture_readiness_blocked` names `0001-recalled` for `0004-dependent`; the fixture has no readiness column. |
| AC7 | `fixture_derived` labels the backtracked/reopened/challenged/shipped cases as tabulated; `9112-shipped-challenge` is `shipped`, never `challenged`. |
| AC8 | `fixture_derived` labels `9114-forward` `build` and invents no backtracked/challenged/reopened state for the absent-record items. |
| AC9 | `AC24 contract-pins` asserts the documented record/field/marker/token/label strings on `docs/artifact-conventions.md` and `docs/workflow.md`, referencing them by name. |
| AC10 | `fixture-existence` fails (never skips) on a missing fixture; `read-only-contract` proves no live `work/`; `bash tests/run.sh <copy-without-work>` exit 0. |
| AC11 | `bash tests/mutation.sh` exit 0: the fixture is staged and each of the eight mutations is caught and named `AC24 <sub-area>`. |
| AC12 | `AC24 no-duplication` negates the exact literals owned by `10`/`20`/`96`; `10-readiness`/`20-lifecycle`/`40-inventory`/`80-cycle-fixture`/`85-conflict-guards`/`96-signature-sweep` stay green; `bash tests/run.sh` exit 0. |
| AC13 | `tests/README.md` lists `87-backtrack-guards.sh`, records token `AC24` and its criterion mapping, the sub-areas, the fixture contract, and the manual residual; `bash tests/run.sh` exit 0. |
| AC14 | `git status --porcelain` shows only `tests/**`; no production surface, command, agent, skill, `phase`, state file, or checker added; the check makes no network/provider call. |
