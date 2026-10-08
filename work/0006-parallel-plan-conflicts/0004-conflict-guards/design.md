---
feature: 0006-parallel-plan-conflicts/0004-conflict-guards
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "Resolves the spec's two open questions: (1) fixture set — keep the cyclic fixture focused on AC1 (new 6-column header) and add a separate tests/fixtures/declared-conflicts/ fixture-local item tree for the declaration/check contract; the new area's stable suite token is AC23. (2) The live-model-run residual is recorded in tests/README.md, exactly as the cycle diagnostic's LLM-run residual is."
conflicts-with: "tests/checks, tests/fixtures, tests/mutation.sh, tests/README.md"
---

# Design — Committed guards for the declared-conflict model and check

## Summary

Add one committed agreement area, `tests/checks/85-conflict-guards.sh` (suite
token `AC23`), plus a new fixture-local item tree at
`tests/fixtures/declared-conflicts/`. The check parses the committed fixture data
with pure bash/awk and asserts the `conflicts-with` model, resolution
precedence, pair predicate, shipped exclusion, parent/own union and drift, and
the four reporting situations; it also asserts the shipped reporting vocabulary
on the live authority and skill. It also updates the cyclic fixture and its
check to the current 6-column `Children` layout (keeping `Depends on` at field
position 5), extends `tests/mutation.sh` to stage the new fixture and prove five
new guards caught and named, and documents the area in `tests/README.md`. No
production surface changes.

## Approach

### 1. Two fixtures, two concerns

- **Cyclic fixture (AC1) — keep it focused on the cycle.** Update
  `tests/fixtures/cyclic-roadmap/roadmap.md` to the current 6-column header
  `| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |`
  with `—` in each new `conflicts-with` cell, and update the exact-header
  assertion in `tests/checks/80-cycle-fixture.sh` to match. The `conflicts-with`
  column is inserted **after** `Depends on`, so the awk parser's `dep = a[5]`
  (`80-cycle-fixture.sh:50`) and the Kahn cycle proof are unchanged — this is the
  positional-parser invariant the spec calls out.
- **Declaration fixture (AC2–AC7) — a new fixture-local item tree.** Add
  `tests/fixtures/declared-conflicts/`, whose `items/` subtree shadows the live
  `work/` root: every item reference in the fixture resolves to
  `items/<NNNN-slug>[/<MMMM-slug>]/`, never to a live `work/` path. This is the
  only way to prove resolution offline while keeping the suite clear of live
  `work/**` (AC9). Surface targets resolve against the live repository **copy**
  root, and are limited to paths the mutation self-check stages (so the guard is
  exercised under `tests/mutation.sh`).

Splitting the two keeps the cycle agreement (`80`) from becoming a second home
for the declaration contract and prevents a duplicate cycle assertion (AC10).

### 2. The new check

`tests/checks/85-conflict-guards.sh` is sourced by `tests/run.sh` like every other
area. It is **prompt-contract test code over committed fixtures** — the same
pattern as `80-cycle-fixture.sh` pinning the prompt-only `CYCLIC-DEP` rule — not a
production checker. It implements no command, is invoked by no framework command,
and never reads live `work/**`.

It exposes four pure analyzers whose printed output is compared to expected
blocks (all Bash 3.2 compatible: no associative arrays, no `mapfile`; heavy
parsing in awk):

```
fixture_resolution   # "<owner-ref>|<token>|resolved|unresolved|<identity-kind>|<identity>"
fixture_conflicts    # "<A-ref>|<B-ref>|<class>"  (unordered pair printed once, A<B, sorted)
fixture_unresolved   # "<declaring-ref>|<token>"
fixture_drift        # "<child-ref>"
```

and assertion groups labelled by sub-area so a mutation names the guard it
trips: `AC23 column-layout`, `AC23 positional-parse`, `AC23 cell-resolution`,
`AC23 pair-predicate`, `AC23 reporting-vocabulary`, plus fixture-existence and
read-only-contract assertions.

**Parser rules** (fixture-scoped instantiation of
`docs/workflow.md` → "Declared conflicts (`conflicts-with`)" and
`## Declared-conflict check`; restated here only as test implementation detail):

- Discover roadmap parents (dir under `items/` with `roadmap.md`) and standalone
  items (top-level dir with `spec.md`, not a roadmap parent).
- Parse the `Children` table by header name, not fixed positions, so a 6-column
  header and a legacy 5-column header (no `conflicts-with`, all cells `—`) both
  parse. Assert separately that the 6-column header places `Depends on` at
  pipe-field 5.
- Child entity ref = `<parent>/<local-id>`; `own` = child `design.md`
  frontmatter `conflicts-with` (present-but-empty → malformed); `cell` = the
  row's cell. `declared = own ∪ cell`. `ship.md` present → excluded as a
  counterpart (still resolves as a target). Drift when both `own` and `cell`
  are present (non-`—`) and the sets are unequal.
- Token list split on comma, trimmed. `—` (or an absent field) declares nothing;
  an empty/whitespace-only value is malformed. A duplicate trimmed token, a
  token with a glob metacharacter, `..`, or a leading `/`, and a self-reference
  are unresolved.
- Resolution: bare `MMMM-slug` → sibling row first (`<parent>/<local-id>`), then
  `items/<token>/`; `NNNN-slug[/MMMM-slug]` → `items/<token>/`; anything else →
  exact repository-relative path (file or directory) under the copy root; no
  resolution → unresolved.

### 3. Fixture data and the expected outcomes

`tests/fixtures/declared-conflicts/items/`:

| Path | Role |
| ---- | ---- |
| `9001-roadmap-a/roadmap.md` | 6-column roadmap; exercises naming, surface share, drift, shipped row, self-reference, unspecced child |
| `9001-roadmap-a/{0001-shared,0002-sibling,0005-self,0006-unspecced}/.gitkeep` | child dirs represented by their rows |
| `9001-roadmap-a/0003-drift/design.md` | own `docs/customization.md` vs cell `docs/workflow.md` |
| `9001-roadmap-a/0004-shipped/ship.md` | shipped child (cell `docs/artifact-conventions.md`) |
| `9002-roadmap-b/roadmap.md` | cross-roadmap same-token control |
| `9003-roadmap-old/roadmap.md` | legacy 5-column header (absent column = `—`) |
| `0001-shared/spec.md` | top-level decoy for sibling-first precedence |
| `9010-surface-shared/` | shares surface with `9001-roadmap-a/0001-shared` |
| `9011-names-silent/` | names silent `9012-silent` |
| `9012-silent/spec.md` | silent unshipped counterpart |
| `9013-names-shipped/` | names shipped `9001-roadmap-a/0004-shipped` |
| `9014-dir-surface/` | surface target is a directory (`docs`) |
| `9015-bad-targets/` | malformed/non-existent targets |
| `9016-self/` | self-reference |
| `9017-duplicate/` | duplicate target |
| `9018-empty/` | present-but-empty value |
| `9019-none/` | `—` |
| `9020-shares-silent/` | second namer of `9012-silent` (shared `work/`-path target) |

**Expected conflict pairs** (each reported once; class in parentheses):

1. `9001-roadmap-a/0001-shared` ↔ `9010-surface-shared` — `(a)`, shared surface `docs/artifact-conventions.md`.
2. `9001-roadmap-a/0001-shared` ↔ `9001-roadmap-a/0002-sibling` — `(b)`, reciprocal naming → exactly one finding.
3. `9002-roadmap-b/0001-shared` ↔ `9002-roadmap-b/0002-sibling` — `(b)`, one-sided naming of a silent item.
4. `9011-names-silent` ↔ `9012-silent` — `(b)`, one-sided naming.
5. `9020-shares-silent` ↔ `9012-silent` — `(b)`, one-sided naming.
6. `9011-names-silent` ↔ `9020-shares-silent` — `(b)`, shared item target `9012-silent`.

**Expected negative controls (not conflicts):**
`9001-roadmap-a/0002-sibling` ↔ `9002-roadmap-b/0002-sibling` (equal token
`0001-shared` resolving to different items — cross-roadmap); any pair involving
shipped `9001-roadmap-a/0004-shipped`; `9013-names-shipped` ↔ its shipped target;
`9014-dir-surface` (`docs` ≠ `docs/...`); `9019-none`.

**Expected unresolved declarations** (`DANGLING-DEP`, class `(b)`):
`9001-roadmap-a/0005-self`→`0005-self`; `9015-bad-targets`→`docs/*.md`,
`../escape`, `/abs.md`, `9999-nope`; `9016-self`→`9016-self`;
`9017-duplicate`→`README.md, README.md`; `9018-empty`→`` (empty).

**Expected drift** (`DRIFT-FACT`, class `(d)`): `9001-roadmap-a/0003-drift`
(union includes both `docs/customization.md` and `docs/workflow.md`; a one-sided
record such as `9001-roadmap-a/0001-shared` is not drift).

**Resolution coverage (AC5):** sibling (`9001-roadmap-a/0002-sibling`→sibling,
proving sibling-first over the `0001-shared` decoy), canonical nested ref
(`9013-names-shipped`), canonical top-level ref (`9011-names-silent`), file
surface, directory surface (`9014-dir-surface`), `—`, absent field, and each
malformed/self/duplicate/empty/non-existent case above.

### 4. Reporting-vocabulary content agreement (AC8)

Assert on the live surfaces:
- `docs/workflow.md` → `## Declared-conflict check` exists and contains the four
  situation codes `TEXTUAL-CONFLICT`, `DANGLING-DEP`, `DRIFT-FACT` and their
  classes `(a)`, `(b)`, `(d)`, and the shipped finding-line grammar
  (`- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`).
- `.opencode/skill/merge-conflict/SKILL.md` contains the finding grammar
  `- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>`.
- `status`/`conflicts`/`build` operative prompts reference
  `docs/workflow.md` → `## Declared-conflict check` (vocabulary single-sourced).
- Negative controls: no `(e)` class and no new code prefixes (`DECLARED-`,
  `PLAN-`, `CONFLICT-`) in the authority section or the skill's planning-time
  block.

### 5. Mutation self-check (AC11)

`tests/mutation.sh` `stage()` gains
`cp -R tests/fixtures/declared-conflicts "$COPY/tests/fixtures/declared-conflicts"`
and five mutation blocks (each `run_absent`; the check is not optional-tool
dependent), targeting the copy only:

| # | Mutation (on the copy) | Expected named sub-area |
| - | ---------------------- | ----------------------- |
| 1 | rename `conflicts-with` → `conflicts` in the fixture roadmap header | `AC23 column-layout` |
| 2 | reorder the header so `Depends on` is not pipe-field 5 | `AC23 positional-parse` |
| 3 | change `9010-surface-shared` target to `docs/does-not-exist.md` | `AC23 cell-resolution` |
| 4 | change `9010-surface-shared` target to the resolving-but-unrelated `README.md` | `AC23 pair-predicate` |
| 5 | change the skill finding grammar `- [<CODE>] (<class>)` → `- [<CODE>] <class>` | `AC23 reporting-vocabulary` |

Mutations 3 and 4 differ in intent: 3 breaks resolution, 4 keeps resolution
valid and breaks only the pair predicate. Update the `mutation.sh` header comment
list of covered areas to include `AC23`.

### 6. Documentation (AC12)

`tests/README.md` gains: a Checks-table row for `85-conflict-guards.sh`; a
paragraph mapping stable token `AC23` to this item's acceptance criteria
(`spec AC1 → AC23`, …) like the `AC21`/`AC22` paragraphs; and a sentence
recording the manual residual — a live `/conflicts`, `/status`, or `/build`-gate
model run is not executable in CI, exactly as the cycle diagnostic's LLM-run
residual is.

## Alternatives considered

- **Reuse the cyclic fixture for the declaration contract (one fixture).**
  Pros: one committed fixture, less new data. Cons: couples the cycle agreement
  (`AC13`) with the declaration guard; the declaration rows would need
  conflict-bearing cells inside a fixture whose purpose is a cycle, and the new
  guard would either read the cyclic fixture (risking a duplicate cycle
  assertion, AC10) or the cyclic fixture would carry dead declaration data.
  **Rejected** for a separate `tests/fixtures/declared-conflicts/` tree.
- **Content assertions only (literal presence), no fixture parser.** Pros:
  smallest possible guard. Cons: cannot prove a genuine declared conflict exists
  (AC3), cannot exercise resolution outcomes (AC5), or uphold AC2/AC6/AC7
  behaviourally; it would pass vacuously if the fixture's declaration data were
  emptied. **Rejected** — the spec explicitly requires proof, and the user
  decision chose a fixture-driven parser.
- **A committed executable checker over live `work/`.** Pros: directly
  reproducible. Cons: explicitly forbidden by the spec's non-goals and the
  shipped prompt-only contract, and it would require the suite to read live
  `work/**`. **Rejected** for a fixture-scoped test parser.
- **Resolve fixture item references against the real `work/` tree.** Pros: no
  fixture-local item tree. Cons: makes the guard read live `work/**` and depend
  on per-item artifacts, breaking fresh-clone independence (AC9/AC13).
  **Rejected** for the fixture-local `items/` root.
- **A new fixture subdirectory per scenario (one roadmap each).** Pros:
  isolation. Cons: cross-item conflicts (the pair predicate, shipped exclusion,
  cross-roadmap identity) need one shared item root; N trees would duplicate the
  parser and multiply files without adding coverage. **Rejected** for one shared
  `items/` tree with a fully enumerated expected outcome set.

## Interfaces and data model

**New check file:** `tests/checks/85-conflict-guards.sh` (filename order between
`80-cycle-fixture.sh` and `90-packaging.sh`). Stable token `AC23`. Pure
bash/awk; no optional tool; sourced by `tests/run.sh` (must not call `exit`).

**Analyzer output contracts** (newline-delimited, `|`-separated, sorted):

```
fixture_resolution : <owner-ref>|<token>|resolved|unresolved|item|surface|<identity>
fixture_conflicts  : <A-ref>|<B-ref>|<class>            # A<B lexicographically
fixture_unresolved : <declaring-ref>|<token>
fixture_drift      : <child-ref>
```

**Fixture tree:** `tests/fixtures/declared-conflicts/items/**` as tabulated in
Approach §3; each fixture `design.md` carries a `conflicts-with` frontmatter
value per the `0002` home; each standalone item has a `spec.md`; child
directories carry `.gitkeep`; the shipped child carries `ship.md`.

**Canonical header constant** (asserted by the guard on the fixture, and by
`80-cycle-fixture.sh` on the cyclic fixture):

```
| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
```

**Changed surfaces:**

- `tests/fixtures/cyclic-roadmap/roadmap.md` — 6-column header + `—` cells.
- `tests/checks/80-cycle-fixture.sh` — exact-header literal updated; parser
  (`dep = a[5]`) and all other assertions unchanged.
- `tests/fixtures/declared-conflicts/**` — new fixture data.
- `tests/checks/85-conflict-guards.sh` — new agreement area (`AC23`).
- `tests/mutation.sh` — stage the new fixture; add five mutations; update the
  header comment's covered-area list.
- `tests/README.md` — Checks-table row, `AC23` mapping paragraph, manual
  residual sentence.

**Deliberately unchanged:** every production surface (`docs/**`,
`.opencode/{agent,command,skill}/**`, `README.md`, `AGENTS.md`,
`template/**`, `opencode.json`); `tests/checks/40-inventory.sh`;
`tests/fixtures/cyclic-roadmap`'s cycle data; the readiness, lifecycle,
signature, and inventory agreements; the roadmap parent `roadmap.md` for item
`0004` (back-filling declarations is a non-goal).

**Backward compatibility and migrations:** none required. The suite stays
read-only and fresh-clone-clean; no live `work/**` is read; the shipping
prompt-only check gains no executable tool; no command, agent, skill, phase,
artifact, frontmatter field, or inventory count changes.

## Affected areas

- `tests/fixtures/cyclic-roadmap/roadmap.md`, `tests/checks/80-cycle-fixture.sh`
  — column rollout (AC1).
- `tests/fixtures/declared-conflicts/**` — new fixture-local item tree
  (AC2–AC7, AC13).
- `tests/checks/85-conflict-guards.sh` — new area (AC2–AC9, AC13).
- `tests/mutation.sh` — staging + five mutations (AC11).
- `tests/README.md` — area documentation and token (AC12).

## Risks and mitigations

- **Fixture parser drifts from the `0001`/`0003` authority** — likelihood medium
  / impact high. Mitigation: the parser is fixture-scoped test detail that
  instantiates the authority; the guard asserts the authority's vocabulary and
  codes, and its expected blocks are the reviewed contract. Any future authority
  change must update the fixture and guard together.
- **Duplicate cycle/readiness/inventory assertion (AC10)** — likelihood medium /
  impact medium. Mitigation: the new check never reads the cyclic fixture, the
  readiness algorithm, or inventory counts; its column/positional assertions are
  scoped to the declaration fixture only.
- **Surface targets absent in the mutation copy** — likelihood high / impact
  high. Mitigation: use only staged paths (`docs/artifact-conventions.md`,
  `docs/workflow.md`, `docs/customization.md`, `docs`, `README.md`,
  `tests/fixtures`); the clean-copy mutation run is the gate.
- **New fixture not staged by `tests/mutation.sh`** — likelihood medium /
  impact high. Mitigation: add it to `stage()` in the same task as the
  mutations; the clean-copy run fails loudly if the fixture is absent.
- **Bash 4 syntax breaks the Bash 3.2 compatibility contract** — likelihood low
  / impact high. Mitigation: no associative arrays/mapfile; follow `lib.sh` and
  `80-cycle-fixture.sh` patterns; `bash tests/run.sh` is the gate.
- **A mutation trips more than one sub-area or another area first** — likelihood
  medium / impact low. Mitigation: `run.sh` runs every check and checks never
  `exit`, so all failures are logged; each mutation asserts its own sub-area
  substring, and the sub-area labels are chosen to be independently reachable.
- **The guard is mistaken for a production checker** — likelihood medium /
  impact low. Mitigation: name it an agreement area; document in the file header
  and `tests/README.md` that it is fixture-scoped test code, the analogue of the
  cycle fixture.
- **Live-model-run residual is untested (by design)** — likelihood certain /
  impact low. Mitigation: record it explicitly in `tests/README.md` as a manual
  residual, matching the cycle diagnostic's documented LLM-run residual.

## Test strategy

The deliverable is test fixtures and test code; the guard is itself the
verification, run by the canonical suite. Each acceptance criterion maps to a
concrete assertion group or a suite command.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | `80-cycle-fixture.sh` asserts the 6-column cyclic header and still proves the cycle (Kahn); `dep = a[5]` unchanged; `bash tests/run.sh` exit 0. |
| AC2 | Guard `fixture_resolution`: every cell/token is `—`, a resolved target, or an expected unresolved declaration; an unexpected malformed/unresolved token fails `AC23 cell-resolution`. |
| AC3 | Guard `fixture_conflicts` contains `9001-roadmap-a/0001-shared`↔`9010-surface-shared` (class `(a)`). |
| AC4 | Guard `fixture_conflicts` contains `9011-names-silent`↔`9012-silent` and `9002-roadmap-b/0001-shared`↔`0002-sibling` (named silent items). |
| AC5 | Guard `fixture_resolution` expected block covers sibling/canonical/surface file/surface dir/`—`/absent and every malformed/self/duplicate/empty/non-existent case; the sibling-first precedence is proven against the `0001-shared` decoy. |
| AC6 | Guard `fixture_drift` = {`9001-roadmap-a/0003-drift`}; the union includes both sets; a one-sided row is not drift. |
| AC7 | Guard asserts shipped `9001-roadmap-a/0004-shipped` is absent from the conflict set while `9013-names-shipped`→it resolves. |
| AC8 | Guard `AC23 reporting-vocabulary`: authority codes/classes/grammar, skill grammar, operative-prompt references, and negative controls. |
| AC9 | Guard reads only `tests/fixtures/**` + live surfaces; no live `work/**`; no committed executable checker added; `bash tests/run.sh <copy-without-work>` exit 0. |
| AC10 | `10-readiness`/`80-cycle-fixture`/`40-inventory` stay green; the new check reads none of their inputs; `bash tests/run.sh` exit 0. |
| AC11 | `bash tests/mutation.sh` exit 0: the new fixture is staged and each of the five mutations is caught and names `AC23 <sub-area>`. |
| AC12 | `tests/README.md` lists `85-conflict-guards.sh`, records token `AC23` and its criterion mapping, and the manual residual; `bash tests/run.sh` exit 0. |
| AC13 | Mutation's clean copy has no `work/`; `bash tests/run.sh <copy>` exit 0 with every `AC23` assertion satisfied from fixture/live-surface content. |
