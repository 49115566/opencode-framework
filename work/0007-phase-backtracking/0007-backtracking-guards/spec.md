---
feature: 0007-phase-backtracking/0007-backtracking-guards
phase: spec
status: final
created: 2026-10-09
updated: 2026-10-09
notes: "Nested roadmap child; the directory held only .gitkeep and its scope is the parent roadmap's 0007 row, so the roadmap supplies the requirements. Readiness: the declared dependencies 0001-backtracking-model, 0002-reverse-phase-routing, 0003-findings-challenge-loop, 0004-roadmap-revision, 0005-post-ship-pr-denial, and 0006-status-and-derived-state all carry a committed ship.md with no reopened: marker, so every dependency is satisfied under the readiness algorithm and no override is needed. No backtracks.md exists in this item, so no open finding targets /spec and this is ordinary forward progression. User resolved the three guard forks: (1) extend only — guard the not-yet-pinned contracts, reference the existing agreement areas by name, do not re-pin their literals; (2) one new fixture-based check file with named sub-areas and one stable AC token, mirroring the conflict-guards area; (3) both executable fixture analyzers that compute the mechanical rules and documented-contract phrase pins, mirroring the cycle and conflict-guards areas. This item freezes settled surfaces and edits no live docs or prompts; a contradiction a guard exposes is routed upstream via the backtrack model, not fixed here."
parent: 0007-phase-backtracking
stale: ""
---

# Committed backtracking and reopen guards

## Problem

The backtracking, findings-challenge, post-ship recall, and derived-state
contracts now exist as committed state shapes and documented prompt behavior:
the `backtracks.md` record and the `stale:` marker (`0001`), the reverse-edge
re-entry routing (`0002`), the `challenges.md` record and the `challenged`
condition (`0003`), parent-roadmap revision integrity (`0004`), the `reopened:`
recall marker and the recalled-item readiness revocation (`0005`), and the
derived-state labels and reporting (`0006`). All of that is shipped
(`work/0007-phase-backtracking/0001..0006-*/ship.md`), but none of it is pinned
by the committed suite: a later edit to `docs/workflow.md`,
`docs/artifact-conventions.md`, a prompt, a record shape, or an analyzer could
silently break the reverse-transition contract with no test failing.

The committed suite (`bash tests/run.sh`) is the repository's regression
backstop, and it is fixture-based and read-only: it never reads live `work/**`
(`tests/README.md:29`). Its existing agreement areas pin neighboring contracts —
readiness single-source phrases and the recalled-item branch, routing literals
and derived-state artifact names, inventory counts, the roadmap cycle rule, the
declared-conflict model, and every command signature — but nothing pins the new
backtracking/challenge/recall record shapes, the per-edge stale map, the
recalled-item readiness computation, roadmap-revision table integrity, or the
new derived-state labels. The result is that the entire backward lifecycle is
documented but unguarded, so it can regress unnoticed. Two audiences pay for
this: **framework maintainers**, who rely on the suite as their protection, and
**adopters**, who inherit the same suite and the same unguarded contract.

## Goals

- Add a committed, fixture-based agreement area that pins the backtracking and
  reopen contract its six sibling children shipped: reverse-edge recording, the
  per-edge stale-downstream marking, the challenge/response record and its
  adjudication outcome rules, parent-roadmap revision integrity, the post-ship
  recall signal and the recalled-item readiness revocation, and the new derived
  states.
- Verify each pinned rule by computing it over committed fixtures where the rule
  is mechanical, so a guard fails when the rule is broken rather than merely
  when a phrase is reworded.
- Keep the suite green and non-duplicative: extend the existing areas without
  re-asserting the contracts they own, and keep every existing area passing.
- Prove the new guards are mutation-sensitive: each named sub-area is caught and
  named by the opt-in mutation self-check.
- Stay fixture-based, read-only, provider-neutral, and runnable on a fresh
  clone with no live `work/**` present.
- Keep the change framework-internal and additive: no live doc or prompt change,
  no new command, agent, skill, `phase` value, state file, or production checker,
  and no runtime dependency, network access, or `gh` call.

## Non-goals

- Changing the contracts this item guards. `0001`–`0006` fixed the model,
  routing, challenge loop, roadmap revision, recall, and derived state; this item
  freezes them with tests and re-decides none of them.
- Re-pinning what the existing areas already own: the readiness single-source
  phrases and recalled-item branch, the routing literals, the core derived-state
  artifact names, the command signatures (including `/roadmap revise` and
  `/ship recall`), the inventory counts, the roadmap cycle rule, and the
  declared-conflict grammar. The new guards reference those areas by name and add
  no duplicate assertion.
- Editing any live surface — `docs/*.md`, `AGENTS.md`, `template/AGENTS.md`,
  `README.md`, or `.opencode/**`. If a guard exposes a contradiction in a settled
  surface, the finding is recorded and routed upstream through the backtrack
  model rather than fixed in this item.
- Adding a committed executable checker, script, helper, or production tool for
  any contract. The guards live only in the test suite; the workflow's own
  guard contracts remain prompt behavior with no committed checker.
- Executing the LLM phases in CI: no real `/status` render, no real backtrack, no
  `/ship recall`. Those remain documented manual residuals, consistent with the
  cycle and conflict-guards areas.
- Any visual, UI, frontend, or browser work; the deliverable has no user-facing
  surface.
- Redefining any finding code, class, severity, or verdict vocabulary; the
  existing grammar is reused.

## Users and stories

- **As a** framework maintainer, **I want** the backtracking, challenge, recall,
  and derived-state contracts pinned by committed fixture-based tests, **so that**
  an edit that breaks the reverse-transition model fails in CI instead of
  shipping silently.
- **As an** adopter, **I want** my inherited suite to guard the same
  reverse-transition contract, **so that** a framework upgrade cannot regress it
  unnoticed.
- **As a** maintainer of the mutation self-check, **I want** each new sub-area
  proven caught and named, **so that** a vacuous or unfalsifiable guard cannot
  pass as coverage.
- **As a** maintainer on a fresh clone, **I want** the guards to read only
  committed fixtures and live surfaces and never live `work/**`, **so that** the
  suite runs with no per-item artifacts present.
- **As a** maintainer, **I want** the new guards to extend rather than duplicate
  the existing agreement areas, **so that** a single contract has a single owning
  guard and the suite stays comprehensible.

## Acceptance criteria

1. **AC1 — Reverse-edge recording.** Given a committed fixture representing a
   sanctioned phase→earlier-phase reversal, when the committed suite runs, then
   it emits a passing assertion for the reverse-edge recording sub-area that
   verifies the item's append-only backtrack record carries a finding naming the
   detecting phase, the target phase, the affected artifact, and `status: open`;
   the assertion fails and names its sub-area when any of those is missing.

2. **AC2 — Record effective status.** Given a backtrack-record fixture holding a
   finding with and without a matching resolution, when the suite runs, then the
   record sub-area asserts the effective-status rule — a finding with no matching
   `Resolution <n>` is `open`; with a matching `Resolution <n>` it is `resolved`
   — and reports a resolution recorded before its finding as malformed without
   reordering the entries.

3. **AC3 — Per-edge stale-downstream marking.** Given a fixture for each
   sanctioned reverse edge, when the suite runs, then the stale-downstream
   sub-area asserts the exact marker token each edge applies — the design-target
   edges mark the downstream artifacts `stale: design`, the spec-target edges
   mark them `stale: spec`, and the pre-existing implementation-defect rework
   edge forces no `stale:` marker — and asserts the target phase's own artifact
   is not marked by the detecting phase.

4. **AC4 — Challenge/response record and adjudication.** Given a committed
   challenge-record fixture, when the suite runs, then the challenge sub-area
   asserts the four entry kinds (`Challenge`, `Response`, `Withdrawal`,
   `Reversal`), the `type` and `decision` token sets, the adjudicator values, and
   the effective-status rule — a challenge is `open` until a matching `Response`
   or `Withdrawal` exists, and a `Reversal` supersedes a decision without
   reopening the challenge — and reports a response recorded before its challenge
   as malformed.

5. **AC5 — Parent-roadmap revision integrity.** Given a committed fixture of a
   `Children` table after a revision that re-scopes, adds, withdraws, and
   re-sequences, when the suite runs, then the roadmap-revision sub-area asserts
   positionally (the dependency column and the `conflicts-with` column keep their
   required positions), that every dependency names a row and no row depends on
   itself, that the stored graph is acyclic, that every canonical reference
   resolves to a child directory and every active child appears as a row, that
   the sequencing section lists every active child after its dependencies, that a
   withdrawn child's directory is preserved but unlisted, and that a revision
   note records the date, the triggering child, the operations, and the
   invalidated children.

6. **AC6 — Recalled-item readiness revocation.** Given a fixture in which a
   dependency's ship record carries the recall marker, when the suite runs, then
   the readiness sub-area computes the recalled dependency as not satisfied and
   names it as the dependent's unsatisfied dependency, while a non-recalled ship
   record and a `review.md` verdict of `approve` still compute as satisfied; no
   stored readiness value is introduced.

7. **AC7 — Derived states.** Given fixtures exercising the derived-state rules,
   when the suite runs, then the derived-state sub-area asserts that the earliest
   `stale:` marker derives the backtracked label for its target phase, that a
   `reopened:` marker derives the reopened label for its named phase, that an
   unshipped item with an open challenge derives the challenged-and-blocked
   condition, and that a shipped item is never derived challenged; the labels
   match the derived-state authority.

8. **AC8 — Absent records are no-ops.** Given a fixture item with no backtrack
   record, no challenge record, and no markers, when the suite runs, then the
   derived-state sub-area asserts ordinary forward derivation and that neither a
   backtracked, challenged, nor reopened state is invented; historical items
   require no migration.

9. **AC9 — Documented-contract pins where the rule is not mechanical.** Given the
   contracts that cannot be computed from a fixture (each record's frontmatter
   and field shapes, the marker token sets, and the derived-state labels), when
   the suite runs, then the guards assert those documented shapes and tokens are
   present and consistent, referencing the single-source authorities by name and
   restating neither the readiness algorithm nor the command signatures.

10. **AC10 — Fixture-based and fresh-clone safe.** Given the committed suite run
    against a tree containing no live `work/**`, when it runs, then the new area
    passes using only committed fixtures and live surfaces, performs no write and
    no network or provider call, and fails rather than skips when a required
    fixture is missing.

11. **AC11 — Mutation coverage.** Given the opt-in mutation self-check, when it
    applies one mutation per new sub-area, then the suite exits non-zero and names
    that sub-area for each, and the unmutated copy passes again; every new
    sub-area declared by the guards is covered by at least one named mutation.

12. **AC12 — No duplication and existing areas stay green.** Given the change
    lands, when the committed suite runs, then every existing agreement area
    still passes and the new area states no duplicate of the routing literals,
    command signatures, or readiness single-source phrases those areas own,
    referencing them by name instead.

13. **AC13 — Documentation.** Given the change lands, when the suite
    documentation is read, then it names the new agreement area, its stable token,
    its declared sub-areas, its fixture-based and never-reads-`work/**` contract,
    and its mutation coverage, consistently with the existing area inventory and
    token mapping.

14. **AC14 — Scope and purity.** Given the item is complete, when the change is
    inspected, then only the committed test suite and its documentation are
    touched; no live doc or prompt, command, agent, skill, `phase` value, state
    file, or production checker is added or changed, and no runtime dependency,
    network access, or `gh` call is introduced.

## Edge cases

- **No live `work/**`.** The suite runs against a fresh clone with no per-item
  artifacts; every new guard reads only committed fixtures and live surfaces and
  never live `work/**`.
- **Missing fixture.** A required fixture that is absent fails and names its
  sub-area; it is never skipped, because a silently dropped guard is a defect.
- **Fixture self-containment.** The fixtures contain no live `work/` reference
  and no absolute or escaping path; the guards assert this rather than assuming
  it.
- **Malformed and out-of-order records.** A resolution before its finding, or a
  response/withdrawal/reversal before its challenge, is reported as malformed and
  never reordered or auto-repaired.
- **Deliberate withdrawal versus an accidental unlisted child.** A retained
  withdrawn child directory is report-only, not a graph fault; an unlisted child
  with no withdrawal record is a fault the guard names.
- **Cyclic or dangling dependency in a fixture.** A cyclic `Children` graph is
  never ready and is recorded rather than stored; a dangling dependency is named.
- **Empty and `.gitkeep`-only item.** An item with no phase artifacts derives
  `not started` and is not treated as backtracked, challenged, or reopened.
- **Backtrack and challenge both present.** The structural marker derivation is
  evaluated before the challenged condition, matching the authority's precedence;
  the guard checks the order, not a second mechanism.
- **Shipped item with an open challenge.** A shipped item is reported shipped and
  the open challenge is surfaced as out-of-scope; it is never guarded as
  challenged.
- **Repeat and parallel runs.** The guards are read-only and idempotent; repeated
  runs on unchanged fixtures yield identical results and take no lock.
- **Optional tools absent.** The new guards require only bash and git; if they
  ever need an optional tool it is skipped visibly, never failed.
- **Bash 3.2 compatibility.** The guards avoid associative arrays, `mapfile`, and
  empty-array expansion under `set -u`, matching the harness constraint.
- **LLM-run residual.** Behavior that requires running a phase (a real `/status`
  render, a real backtrack, a real recall) is documented as a manual residual and
  is not faked by a static assertion.

## Open questions

- [x] **Coverage boundary** — resolved (user): extend only; guard the
  not-yet-pinned contracts and reference the existing areas by name rather than
  re-pinning their literals.
- [x] **Guard organization** — resolved (user): one new fixture-based check file
  with named sub-areas and one stable suite token, mirroring the conflict-guards
  area.
- [x] **Verification depth** — resolved (user): both executable fixture analyzers
  that compute the mechanical rules and documented-contract phrase pins,
  mirroring the cycle and conflict-guards areas.
- [x] **Readiness** — resolved: all six declared dependencies carry a committed
  `ship.md`, so the child is ready and no override is needed; there is no
  `backtracks.md` in this item and no open finding targets `/spec`.
- [ ] **Deferred — exact token, sub-area names, fixture layout, and check
  filename.** The stable token number, the sub-area labels, the fixture directory
  shape, and the check filename are design choices; the observable content above
  is fixed. — owner: architect, needed by: design.
- [ ] **Assumption — settled surfaces are final.** The `0001`–`0006` contracts
  are final and this item changes none of them; if a guard exposes a contradiction
  in a live surface, it is recorded and routed upstream via the backtrack model
  rather than fixed here. Confirm. — owner: user, needed by: design.
- [ ] **Assumption — test-only, offline, no provider.** This item touches only the
  committed test suite and its documentation, adds no committed production
  checker, and introduces no runtime dependency, network access, or `gh` call.
  Confirm. — owner: user, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists `Depends on: 0001-backtracking-model,
  0002-reverse-phase-routing, 0003-findings-challenge-loop, 0004-roadmap-revision,
  0005-post-ship-pr-denial, 0006-status-and-derived-state`
  (`work/0007-phase-backtracking/roadmap.md:89`); all six carry a committed
  `ship.md`, so every declared dependency is satisfied under the readiness
  algorithm and no override is needed. `0004` and `0006` are reused unchanged.
- **Consumes the six sibling contracts.** It reads the `0001` record and marker
  model, the `0002` reverse-edge recording, the `0003` challenge record and
  blocked condition, the `0004` roadmap-revision integrity rules, the `0005`
  recall marker and readiness revocation, and the `0006` derived-state labels, and
  defines no second mechanism or vocabulary.
- **Existing areas that must stay green and must not be duplicated.** The
  readiness/dependency-satisfaction area, the lifecycle/derived-state area, the
  inventory area, the roadmap cycle area, the declared-conflict guards area, and
  the command-signature sweep. The new guards reference these by area name and
  re-assert none of their literals.
- **Fixture-based and read-only.** The suite never reads live `work/**` and runs
  on a fresh clone (`tests/README.md:29`); the new area must preserve that, using
  committed fixtures and the harness reporters and deferring optional tools to a
  visible skip.
- **Harness constraints.** A check file is sourced by the suite entry point and
  must not call `exit`; assertions are labelled with a stable token; the suite is
  Bash 3.2 compatible. The mutation self-check is opt-in maintainer tooling and is
  not part of the default suite run.
- **Declared conflicts.** The parent roadmap row declares the test surfaces
  (`tests/checks`, `tests/fixtures`, `tests/README.md`, `tests/mutation.sh`) in
  `conflicts-with`; this item's own declaration belongs in its `design.md`
  frontmatter. No sibling references those surfaces, so the declaration is
  advisory and blocks no phase.
- **Framework-internal change only.** Tests and test documentation; no runtime
  dependency, service, new toolchain, command, agent, skill, or state file.
- **Assumption — naming surfaces for testability.** Because the deliverable is
  the framework's own committed suite, the acceptance criteria describe required
  observable guard behavior and scope; exact token numbers, sub-area names,
  fixture layout, and filenames are design choices deferred to the architect.
