---
feature: 0003-framework-quality-hardening/0006-committed-tests-ci
phase: spec
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
notes: "Roadmap evidence re-verified against current files: work/ is now committed (child 0001-state-model shipped the committed model), so the roadmap's 'git-ignored work/' premise is stale; relocation here means a stable, CI-runnable location, not escaping ignore rules. User framing decisions recorded under Dependencies and constraints. No dependency gate: this child's roadmap row is `—` (ready)."
---

# Committed test harness and CI

## Problem

The framework has no single, committed way to run its own tests, and its
verification coverage cannot see the failures that matter most.

Eight read-only static suites exist, but each lives inside the per-item artifact
directory of a shipped work item (`work/**/verify-tests.sh`, e.g.
`work/0002-agentic-roadmaps/verify-tests.sh`). There is no one command that runs
"the framework's tests"; a maintainer must know which item holds the relevant
suite. No CI workflow exists anywhere in the repository (confirmed: no `.github/`,
no runner config, no `tests/` or `scripts/` directory). The gap is recorded, not
hypothetical: `work/0002-agentic-roadmaps/verify.md:152-160` states the suite is
git-ignored and that "there is no single project test command to wire into CI,"
and `work/0001-framework-consistency-hardening/verify.md` records the same. Those
records predate the committed-model change, but the *runnability* gap they
describe remains: nothing committed is a canonical, CI-invocable entry point.

The existing suites also check presence and counts, not **agreement**. The same
fact is deliberately duplicated across surfaces — the readiness algorithm
(`docs/workflow.md:90-108`) restated in `.opencode/agent/status.md:97-118` and
`.opencode/command/status.md:17-30`; the lifecycle/derived-state mapping
(`docs/workflow.md:237-259`) mirrored in `README.md:107-148`, `AGENTS.md:33-46`,
and `.opencode/skill/workflow-lifecycle/SKILL.md:28-43`; the per-agent permission
table (`README.md:179-194`) independent of each agent's frontmatter; inventory
counts (`README.md:237-239`); the always-loaded instruction set (`opencode.json:6-10`,
`docs/customization.md:17-42`); the default agent (`opencode.json:5`,
`README.md:181,252-253`); and the pinned Playwright MCP version
(`opencode.json:37-45`, `docs/customization.md:186-188`). A change to one copy can
silently diverge from its counterparts; today's checks would miss it. The
roadmap cycle diagnostic (`CYCLIC-DEP`) is prose only (`docs/workflow.md:98,108,123`;
`.opencode/agent/status.md:105,117-118`) with no committed fixture; its only
behavioral evidence lived in the git-ignored `scratch/` and is unavailable on a
fresh clone. Finally, nothing states whether a test harness and CI are
framework-maintainer tooling or something adopters receive.

Affected: **framework maintainers**, who cannot regression-guard the framework
with one command or in CI and whose duplicated-fact drift is invisible; and
**adopters**, who have no documented boundary telling them tests/CI are
framework-only.

## Goals

- One canonical, documented command runs the framework's committed test suite,
  and its exit status is the pass/fail signal.
- The suite is committed in version control at a stable location independent of
  any per-item artifact directory, and a fresh clone can run it with no prior
  setup.
- A hosted CI check runs the suite on every push and pull request and reports
  pass/fail.
- The suite asserts that duplicated facts **agree** across surfaces for the
  seven required areas: readiness semantics, lifecycle/derived state, permission
  documentation versus declarations, inventory counts versus disk, always-loaded
  instruction set, default agent, and external-version pin.
- The suite is mutation-sensitive: making one copy of an agreed fact disagree
  with its counterparts fails the run and names the disagreement.
- The roadmap cycle rule is regression-guarded by a committed fixture plus static
  assertions, with the LLM behavioral residual explicitly documented.
- Checks that need an optional tool absent from CI report a visible skip and do
  not fail the run; only real assertion failures fail it.
- Tests and CI are documented as framework-maintainer-only and are excluded from
  what adopters copy.
- Existing shipped per-item suites and their owning artifacts remain untouched.

## Non-goals

- Relocating, rewriting, merging, or deleting the existing `work/**/verify-tests.sh`
  suites or any other shipped artifact. They are immutable evidence.
- Making LLM-driven agent behavior (a live `/status`, `/product`, or `/roadmap`
  run) deterministic or executable inside CI.
- Adding a general-purpose test runner, package manager, build system, or runtime
  dependency to the framework.
- Changing any agent, command, skill, lifecycle rule, permission, or artifact
  format; this item adds tests, CI, and documentation only.
- Filling the `AGENTS.md` Project profile (child `0009-surface-consistency` owns
  that) or extending `/doctor`'s audience and diagnostic catalogue (child
  `0004-doctor-scope` owns that).
- Coverage badges, test-result publishing, release automation, or scheduled runs.
- Providing an adopter-facing test command or shipping the harness to adopters.

## Users and stories

- **As a** framework maintainer, **I want** one command that runs the framework's
  whole committed test suite, **so that** I can verify the framework before
  shipping without knowing which per-item suite exists.
- **As a** framework maintainer, **I want** CI to run that suite on every push
  and pull request, **so that** drift is caught before merge rather than by a
  reader.
- **As a** framework maintainer, **I want** the suite to assert that facts
  duplicated across docs, config, and prompts agree, **so that** a stale
  restatement fails the build instead of misleading readers.
- **As a** framework maintainer, **I want** the documented roadmap cycle rule
  backed by a committed fixture, **so that** the detection contract is
  reproducible on a fresh clone instead of depending on a discarded scratch probe.
- **As a** framework maintainer, **I want** checks on optional tools to skip
  cleanly, **so that** CI is not red for a tool the assertion does not actually
  need.
- **As an** adopter, **I want** clear documentation that tests and CI are
  maintainer-only and not copied into my project, **so that** I do not expect a
  test command that is not there.

## Acceptance criteria

1. **AC1 — Canonical command.** Given a fresh clone of the framework, when the
   documented canonical test command is run, then it invokes the committed suite
   in one process and exits `0` when every executed assertion passes and non-zero
   when any executed assertion fails.

2. **AC2 — Committed and self-contained.** Given the committed tree on a fresh
   clone, when the suite and its CI definition are inspected, then both are
   tracked in version control at a location that is not a per-item artifact
   directory, and the suite runs successfully without requiring any `work/**`
   artifact to be present or unmodified.

3. **AC3 — Reported summary.** Given the canonical command is run, when it
   completes, then it prints a per-assertion result and a summary that
   distinguishes passed, failed, and skipped counts, and the summary is derivable
   from the machine-readable exit status.

4. **AC4 — CI on push.** Given a commit is pushed to any branch, when the
   repository's CI service runs, then it invokes the canonical command and
   reports the suite's pass/fail as a status for that commit.

5. **AC5 — CI on pull request.** Given a pull request is opened or updated, when
   the repository's CI service runs, then it invokes the canonical command and
   reports the suite's pass/fail on the pull request.

6. **AC6 — Readiness agreement.** Given the current framework files, when the
   suite runs, then it asserts that the readiness/dependency-satisfaction
   semantics — including approved-but-unshipped satisfaction and the
   shipped-signal precedence — are stated by exactly one authoritative source and
   that every other surface either defers to that source or agrees with it, and it
   fails if any surface contradicts the authority.

7. **AC7 — Lifecycle and derived-state agreement.** Given the current framework
   files, when the suite runs, then it asserts that the phase list, the
   derived-state mapping, and the command routing are consistent across the
   always-loaded contract, the workflow authority, the README, and the lifecycle
   skill, and it fails if a phase or transition exists in one surface but is
   missing from or contradicted by another.

8. **AC8 — Permission agreement.** Given each agent's declared capabilities, when
   the suite runs, then it asserts that every agent's documented edit and bash
   capability matches its declaration, and it fails when a documented capability
   and a declaration disagree.

9. **AC9 — Inventory agreement.** Given the files on disk, when the suite runs,
   then it asserts that every documented inventory count equals the number of
   corresponding files present and that every on-disk item is documented, and it
   fails on any mismatch.

10. **AC10 — Instruction-set agreement.** Given the configuration and docs, when
    the suite runs, then it asserts that the always-loaded instruction set named
    in configuration, customization documentation, and the README is the same set
    and that every named path exists, and it fails on any divergence.

11. **AC11 — Default-agent agreement.** Given the configuration and docs, when
    the suite runs, then it asserts that the default agent named in
    configuration, the README, and customization documentation is identical and
    resolves to an enabled agent, and it fails otherwise.

12. **AC12 — Pin agreement.** Given the configuration and docs, when the suite
    runs, then it asserts that the external MCP dependency is pinned to one exact
    published version named identically in every surface, and it fails on a
    floating tag or a divergent version string.

13. **AC13 — Cycle rule and fixture.** Given the committed suite, when it runs,
    then it asserts (a) that a committed fixture represents a roadmap whose
    dependency graph contains a cycle, and (b) that the documented rule states
    that cycle members are never reported ready and that a cycle is reported as a
    non-fatal integrity finding, and it fails if either the fixture is absent or
    the rule text or finding contract is removed.

14. **AC14 — Optional-tool skips.** Given CI lacks an optional tool (a scripting
    runtime, the opencode CLI, or network/registry access), when the suite runs,
    then each check depending on that tool is reported as explicitly skipped, the
    run continues, and the exit status reflects only real assertion failures; a
    missing optional tool never causes a failure.

15. **AC15 — Mutation sensitivity.** Given a working tree in which exactly one
    copy of an agreed fact in scope (AC6–AC12) is altered to disagree with its
    counterparts, when the suite runs, then it exits non-zero and names the
    specific disagreement; when the alteration is reverted, the suite passes
    again.

16. **AC16 — Maintainer-only boundary.** Given the adoption documentation, when
    the quickstart's copy set and the testing/CI guidance are inspected, then the
    committed suite and its CI definition are not part of what adopters copy, and
    tests and CI are documented as framework-maintainer-only.

17. **AC17 — Shipped artifacts untouched.** Given the committed tree before and
    after this item's changes, when the per-item verification scripts and their
    owning artifacts are compared, then none has been modified or deleted, and no
    agent, command, skill, lifecycle rule, permission, or artifact format has
    changed.

## Edge cases

- **No artifact tree present.** The suite runs on a clone with an empty or absent
  artifact root; it does not require any per-item artifact to exist (AC2).
- **No optional tools installed.** A minimal environment with only bash and git
  still runs the suite to completion; optional-tool checks skip (AC14).
- **Registry or network unreachable.** Checks whose only purpose is to confirm a
  pinned version is published skip, while the local pin-agreement assertion still
  runs and fails on a floating tag or divergent version.
- **Fork pull request without secrets.** CI must not require secrets or
  credentials; the suite runs with none (AC4, AC5).
- **A skip must be visible.** A skipped check is always printed as skipped; a
  silently dropped assertion that would otherwise pass is itself a defect.
- **Newly added agent, command, or skill.** An on-disk item with no documentation
  entry, or a documented count that no longer matches disk, fails AC9 rather than
  passing vacuously.
- **One surface moves a fact.** Moving or renaming a duplicated fact fails AC15
  until all surfaces agree; the failure names the disagreeing surfaces.
- **Cyclic fixture isolation.** The cycle fixture does not pollute the real
  artifact tree: it is separate from committed artifacts or created in an ignored
  temporary location and cleaned up, so repeated runs are idempotent.
- **Concurrent CI runs.** The suite is read-only against the repository; parallel
  runs do not interfere. Any temporary writes are confined to an ignored location
  and removed.
- **CI provider replaced.** The canonical command is provider-neutral; only the
  hosted wrapper is provider-specific, so the suite stays runnable if the CI
  provider changes.
- **Historical suites drift from today's facts.** Because they are left untouched
  and are not executed by the new suite, they may assert facts that later change;
  this is accepted — they are a record of their item, not a living test.
- **Framework evolves before the suite is extended.** A fact genuinely changes
  everywhere at once; the suite passes because it asserts agreement, not frozen
  values (except the exact pinned version, which must be updated in all surfaces
  together).

## Open questions

- [ ] Should the canonical test command also be exposed as a framework slash
      command, or remain a shell command? — owner: user, needed by: plan. Working
      assumption: shell command only; adding a slash command would change the
      published command inventory and README, which is out of scope here.
- [ ] Should CI run on a schedule in addition to push and pull request? — owner:
      user, needed by: plan. Working assumption: push and pull request only, per
      the framing decision; no scheduled run.
- [ ] The exact committed location and the split between one suite file and
      several — owner: architect, needed by: plan. Deferred to design; the spec
      fixes only the observable properties (one canonical command, outside
      per-item artifacts, fresh-clone runnable).

## Dependencies and constraints

- **Readiness:** this child's roadmap row declares no dependencies (`—`); it is
  `ready`. No upstream gate applies, and no override is recorded.
- **Stale roadmap premise (re-verified).** The roadmap cites a git-ignored `work/`
  (`work/0003-framework-quality-hardening/roadmap.md:64`). Child
  `0001-state-model` shipped the committed model (`.gitignore:5-6`; ship record at
  `work/0003-framework-quality-hardening/0001-state-model/ship.md`), so relocation
  here is about a stable, CI-runnable location rather than escaping ignore rules.
- **Framing decisions (user, 2026-10-06).** Fresh living suite that leaves the
  historical per-item suites untouched as immutable evidence; a hosted CI check on
  push and pull request; missing optional tools skip rather than fail; all seven
  agreement areas in scope (AC6–AC12); the cycle diagnostic gets a committed
  fixture plus static rule assertions with the LLM behavioral residual documented;
  tests/CI are framework-maintainer-only and documented as such; the canonical
  command is provided now and the `AGENTS.md` Project profile is filled by child
  `0009-surface-consistency`.
- **Platform.** The repository is hosted on GitHub and the ship phase uses `gh`
  (PRs such as `work/0003-framework-quality-hardening/0001-state-model/ship.md`),
  so the hosted CI service is GitHub Actions; the canonical command stays
  provider-neutral.
- **Existing suite conventions to follow** (grounding, not prescription):
  read-only bash with `set -u`, `ok`/`FAIL` line output, an optional repo-root
  argument, and non-zero exit on failure — e.g.
  `work/0002-agentic-roadmaps/verify-tests.sh:13-17,30-31,276-277`;
  `work/0003-framework-quality-hardening/0007-config-hardening/verify-tests.sh:25,297-298`
  (the only suite that already models skips and optional tools via `have_py`,
  `have_opencode`, and registry reachability).
- **Duplicated-fact locations to guard** (grounding; the suite asserts agreement
  among these, it does not freeze their content): `docs/workflow.md:90-108,237-259`;
  `.opencode/agent/status.md:97-118`; `.opencode/command/status.md:17-30`;
  `README.md:107-148,179-194,237-239,252-259`; `AGENTS.md:33-46`;
  `.opencode/skill/workflow-lifecycle/SKILL.md:28-43`; `opencode.json:5-10,37-45`;
  `docs/customization.md:17-42,129-176,186-188`.
- **Cycle prose and finding contract:** `docs/workflow.md:98,108,123`;
  `.opencode/agent/status.md:105,117-118`; `.opencode/command/status.md:28-30`.
- **Environment assumptions:** bash and git are required; python3, the opencode
  CLI, and network/registry access are optional and must skip when absent. No
  secrets. Temporary writes go under the ignored `scratch/` (`README.md:247`), which
  stays git-ignored (`.gitignore:20`).
- **Permission fit:** the `tester` agent's edit allowlist already covers the
  relative and `**/` forms of a committed `tests/` location
  (`.opencode/agent/tester.md:9-10`), so the framework's own test phase can author
  and run the suite; no permission change is in scope.
- **Adoption boundary:** the README quickstart copies only `.opencode/{agent,command,skill}`,
  `AGENTS.md`, `opencode.json`, `.gitignore`, and `docs/*.md` (`README.md:44-52`)
  and already excludes maintainer-only `/doctor` (`README.md:58-65`); tests and CI
  follow the same maintainer-only pattern.
- **Immutability:** historical `work/**` artifacts and their suites are not edited
  (`AGENTS.md` artifact contract; `work/0003-framework-quality-hardening/0001-state-model/spec.md`
  non-goals).
- **Out of scope / sibling owners:** `AGENTS.md` Project profile by `0009`;
  `/doctor` catalogue by `0004`; permission-model wording by `0003`;
  readiness/ship-state semantics by `0002`.
