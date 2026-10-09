---
feature: 0008-mutation-test-friction
phase: spec
status: final
created: 2026-10-09
updated: 2026-10-09
notes: "User framing decisions: one standalone item covering both the harness-performance changes (subset runs, cheap restore, parallel workers, lazy optional-tool probes) and the mutation-policy documentation (out of CI, area-scoped, per-area cap norm); all four harness changes in scope; policy documented with no CI change; this item sequences after 0007-phase-backtracking/0007-backtracking-guards ships, which owns and extends tests/mutation.sh, tests/checks, tests/fixtures, and tests/README.md. Intended declared conflict targets for design: tests/mutation.sh, tests/run.sh, tests/lib.sh, tests/README.md."
---

# Reduce mutation-test harness friction

## Problem

Framework maintainers run the opt-in mutation self-check
(`bash tests/mutation.sh`) to prove the committed agreement suite is
mutation-sensitive. Today the self-check re-runs the **entire** agreement suite
**twice** per mutation — once to observe the mutation trip a guard, and once more
to confirm the scratch copy was restored — sequentially, against a single shared
scratch copy. Its cost is therefore proportional to `mutations × full-suite
runtime`, and it grows as both the number of agreement areas (and their mutations)
and the size of the suite grow.

The cost is real and already material on this checkout: `tests/mutation.sh`
carries 19 mutation blocks and each is followed by a full-suite restore run, so a
single full pass is roughly 40 whole-suite executions; the in-flight
`0007-phase-backtracking/0007-backtracking-guards` child adds eight more
mutations (`AC24`), pushing it toward 56 and an estimated wall time of 7–11
minutes on the development machine. In addition, the canonical suite
(`bash tests/run.sh`) eagerly probes optional tools (the `npm` registry and the
`opencode` CLI) at startup even when no executed area needs them, so every plain
run pays for network/CLI detection it may not use.

The consequence is not merely slow tests. A maintainer reliably pays the mutation
cost in the daily loop or during the test phase's evidence gathering — the
historical `verify.md` records show repeated ad-hoc mutation runs — which either
burns time or pressures the maintainer to skip the check, losing the very
guarantee (every guard actually bites) the suite exists to provide. There is no
subset capability, no isolation for concurrent work, no per-area bound on how
many mutations an area adds, and no documented statement of when the full pass
should run. The affected audience is **framework maintainers**; adopters are
unaffected because the suite and mutation self-check are maintainer-only tooling
(`tests/README.md:7-16`).

## Goals

- A caller can run a selected subset of agreement areas through the canonical
  suite command and receive the same pass/fail semantics as a full run, with
  unselected areas genuinely not executed.
- A mutation in the self-check is exercised against only the agreement area(s)
  needed to detect and name it, not the whole suite.
- Restore verification after a mutation no longer requires re-running the suite;
  the harness proves the mutated surface was restored directly, while keeping at
  least one end-to-end clean verification.
- Mutation checks execute concurrently across available CPU resources, with
  isolated scratch state, without changing the aggregate result.
- Optional-tool capability probes occur only when an executed area needs them, so
  a plain run is not taxed by probes it does not use.
- A full mutation pass executes a number of **whole-suite** runs that is bounded
  by a small constant independent of the mutation count, and its wall time is a
  small fraction of today's, while every existing mutation is still caught and
  named and every clean run still passes.
- Mutation policy is documented: the pass stays opt-in and out of CI; the full
  pass is a scheduled/milestone audit, area-scoped mutations are the development
  norm, and a new agreement area may add only a bounded number of mutations (one
  per distinct rule), so cost cannot grow without limit.

## Non-goals

- Weakening, dropping, or reordering the committed mutations, or changing what
  each agreement area asserts. Every mutation that exists after
  `0007/0007-backtracking-guards` lands must remain caught and named.
- Adding mutation to CI, or changing `.github/workflows/ci.yml` (which runs only
  the canonical suite).
- Adding or removing agreement areas, check files, or fixtures — that belongs to
  the items that own each contract (for example `0007/0007`).
- Restructuring the mutation self-check's current coverage/content; this item
  restructures its **execution model**, and sequences after `0007/0007` so that
  item's eight mutations are already present.
- Changing the canonical command's exit contract (`0`/`1`/`2`), its summary
  format, or the visible-skip policy.
- Changing the suite's read-only, provider-neutral, fresh-clone-runnable
  invariants or its rule that it never reads live `work/**`.
- Changing agent prompts, commands, skills, lifecycle rules, permissions,
  artifact formats, `docs/**`, `README.md`, `AGENTS.md`, `template/**`, or
  `opencode.json`.
- Optimizing assertion-level suite efficiency (for example the many shell forks
  inside individual checks) beyond the optional-tool probe change.
- Introducing any runtime dependency, package manager, build system, install
  step, or network requirement.

## Users and stories

- **As a** framework maintainer, **I want** to run only the agreement area I just
  changed, **so that** I get fast, relevant feedback during development instead
  of running the whole suite.
- **As a** framework maintainer, **I want** the mutation self-check to run each
  mutation against just its area and to verify restoration cheaply, **so that**
  the pass is fast enough to run at a checkpoint rather than skipped.
- **As a** framework maintainer, **I want** mutation checks to use the machine's
  cores, **so that** the pass completes in a fraction of its serial wall time.
- **As a** framework maintainer, **I want** the plain suite to probe an optional
  tool only when an executed area needs it, **so that** a normal run is not slowed
  by network/CLI detection it does not use.
- **As a** framework maintainer, **I want** a documented policy for when to run
  mutation and how many mutations an area may add, **so that** the cost stays
  bounded as the framework grows.
- **As a** framework maintainer, **I want** the fast path to preserve every
  existing guarantee, **so that** a quicker pass never means a weaker one.

## Acceptance criteria

1. **AC1 — Subset execution.** Given the canonical suite command, when it is
   invoked with a selection naming one or more agreement areas, then only the
   selected areas' assertions execute, the printed summary counts only those
   assertions, the exit status is `0` when all executed assertions pass and `1`
   when any fails (skips do not fail), and no unselected area's result is reported
   as if it had run.

2. **AC2 — Full run unchanged.** Given the canonical suite command is invoked
   with no selection, when it runs, then every agreement area executes exactly as
   it does today, with the same summary semantics and the same `0`/`1`/`2` exit
   contract.

3. **AC3 — Selection errors.** Given a selection that names an unknown or
   ambiguous area, or an explicitly empty selection, when the command runs, then
   it reports a setup error naming the offending selector, exits with the
   existing setup-error status (`2`), and does not silently fall back to a full
   run or report success.

4. **AC4 — Area isolation.** Given an agreement area that passes in a full run,
   when it is the only selected area, then it passes, sources the shared harness
   state it requires, and preserves its skip/execute behavior; selecting an area
   must not fail merely because a sibling area was not executed.

5. **AC5 — Area-scoped mutation.** Given a mutation targeting a specific
   agreement area, when the mutation self-check runs, then it executes only the
   agreement area(s) required to detect and name that mutation, and it asserts the
   mutation is caught and named; unaffected areas are not executed for that
   mutation.

6. **AC6 — Cheap restore verification.** Given a mutation has been applied and
   then restored, when the self-check verifies restoration, then it compares the
   restored surface directly to its original content and reports success or
   failure on that basis, without executing the agreement suite; a deliberately
   corrupted restore is reported as a failure that names the unrestored surface.

7. **AC7 — End-to-end clean runs retained.** Given a full mutation pass, when it
   completes, then it has run the clean copy end-to-end at least once with no
   `work/` directory present and at least once with every optional tool forced
   absent, and both report pass.

8. **AC8 — Mutation sensitivity preserved.** Given the full mutation pass against
   the current tree, when it completes, then every committed mutation is caught
   and named, the count of failed mutations is zero, and the pass exits `0`.

9. **AC9 — Parallel execution with isolation.** Given a machine with more than
   one available CPU, when the mutation pass runs, then mutation checks execute
   concurrently using isolated per-worker scratch state, no worker can observe
   another's mutation, every mutation is accounted for exactly once, and the
   aggregate pass/fail result and the set of named mutations equals those of a
   serial run.

10. **AC10 — Bounded whole-suite executions.** Given a full mutation pass, when
    it runs, then the number of **whole-suite** executions it performs is a small
    constant that does not scale with the mutation count (the per-mutation work is
    limited to the targeted area), and the item's verification records a measured
    wall-clock comparison showing a material reduction from the recorded
    baseline.

11. **AC11 — Mutation policy documented.** Given `tests/README.md` after this
    item, when read, then it states that the mutation self-check is opt-in and not
    run in CI, that the full pass is a scheduled/milestone audit rather than a
    per-task ritual with area-scoped mutations as the development norm, and that a
    new agreement area should add only a bounded number of mutations (one per
    distinct rule, with a stated norm cap), without displacing the existing
    mutation, check, and skip documentation.

12. **AC12 — Existing contract preserved.** Given the change, when the canonical
    full suite runs, then it exits `0`; the suite remains read-only,
    provider-neutral, fresh-clone runnable, and never reads live `work/**`; and the
    exit contract and visible-skip policy are unchanged.

13. **AC13 — Scope.** Given the item is complete, when the change surface is
    inspected, then only the test harness and its documentation changed; no CI
    workflow, agent, command, skill, lifecycle rule, permission, artifact format,
    or other production surface changed, and no runtime dependency was added.

## Edge cases

- **Selecting several areas at once.** All selected areas execute, in a
  deterministic order, and the counters aggregate; the exit status reflects the
  combined result.
- **Duplicate or overlapping selection.** A selector that resolves to the same
  area twice must not double-count or execute it twice.
- **Area that references a sibling area by name.** An area whose assertions name
  another area's contract (as the in-flight `AC24` guard references the
  readiness/cycle/conflict guards) must still pass when selected alone; selecting
  a subset must not break file-relative lookups inside an area.
- **Concurrent workers and scratch isolation.** Each worker uses its own scratch
  state and log; a mutation applied by one worker is never visible to another,
  and all worker scratch state is cleaned up on exit, including on failure.
- **One worker fails, others succeed.** A mutation that escapes or errors in one
  worker is reported and makes the aggregate exit non-zero, but does not abort or
  corrupt the other workers' results.
- **Restore is wrong or partial.** If a mutated surface is not restored
  byte-for-byte, the cheap restore check fails and names the surface; the pass is
  never reported green on an unrestored copy.
- **Optional tool present vs. forced absent.** A selection that needs an optional
  tool still executes or skips exactly as the full run would, depending on the
  tool's presence and the existing overrides; forcing a tool absent must not cause
  a failure.
- **Network unreachable but `npm` present.** The registry-reachability behavior is
  unchanged: the dependent area skips rather than fails.
- **No `work/` directory present.** The mutation copy and the clean pass still
  succeed, preserving fresh-clone behavior.
- **Very small mutation set / all areas selected.** Both extremes produce correct
  results; selecting every area must be equivalent to a full run.
- **Repeated runs.** Runs on an unchanged tree produce identical results and leave
  no residue; concurrent runs of the pass do not interfere.
- **Bash 3.2 / minimal environment.** The restructured harness keeps the suite's
  existing Bash 3.2 compatibility and its bash-plus-git minimum; no new tool is
  required.

## Open questions

- [ ] The subset selector's user-facing surface — a command argument, an
      environment variable, or both — and its exact matching rule (for example
      exact area name versus a prefix). Owner: architect, needed by: `/plan`. The
      observable behavior is fixed above (AC1–AC4); only the surface is open.
- [ ] The per-area mutation cap value (the spec fixes the rule "one mutation per
      distinct rule" and requires a stated norm cap; the numeric cap is a
      documentation choice). Owner: architect, needed by: `/plan`. Working
      assumption: no more than three committed mutations per area unless a
      distinct rule justifies another.

## Dependencies and constraints

- **Sequencing (user decision).** This item starts **after**
  `0007-phase-backtracking/0007-backtracking-guards` ships. That child is
  currently unshipped and adds eight `AC24` mutations and a new agreement area;
  it owns and declares a conflict on `tests/mutation.sh`, `tests/checks`,
  `tests/fixtures`, and `tests/README.md`. Building this item first would force a
  three-way reconcile on the same files. The architect should declare the matching
  `conflicts-with` targets in the design.
- **Consumed contract (shipped).** The committed harness established by
  `0003-framework-quality-hardening/0006-committed-tests-ci` — the canonical
  `bash tests/run.sh` entry point, the `0`/`1`/`2` exit contract, the visible-skip
  policy, the one-process `lib.sh` + `checks/*.sh` model, and the read-only /
  provider-neutral / no-`work/**` invariants (`tests/README.md:18-62`) — is the
  authority this item extends. It must not be forked.
- **In-flight content.** `0007/0007` adds the `AC24` guard; after it ships, this
  item's area-scoping must cover all existing areas including `AC24`, and the
  mutation-count bound must hold for its eight mutations.
- **CI (unchanged).** `.github/workflows/ci.yml` runs only `bash tests/run.sh` on
  push and pull request; mutation is not, and remains not, a CI job.
- **Optional-tool overrides.** The existing force-absent overrides
  (`FRAMEWORK_TEST_NO_PY`/`_OPENCODE`/`_NPM`) and their deterministic-skip purpose
  (`tests/README.md:46-62`) must keep working; lazy probing must not remove the
  ability to force a tool absent.
- **Portability.** The harness remains Bash 3.2 compatible and requires only bash
  and git at minimum; parallelism must degrade correctly when only one CPU is
  available.
- **Scope.** `tests/**` and `tests/README.md` only. No change to `docs/**`,
  `.opencode/**`, `.github/**`, `README.md`, `AGENTS.md`, `template/**`, or
  `opencode.json`.
- **Read-only guard.** The product agent writes only under `work/**` (this
  specification) and changes no source, doc, config, or test.
