---
feature: 0003-framework-quality-hardening/0005-fix-landing
phase: test
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Verification — Fix-track landing path

## Summary

This item is a prompt/documentation change with no runtime code. Verification is
static: a focused read-only suite (`verify-tests.sh`, now 143 assertions) plus the
framework's existing suites as regression gates. Every acceptance criterion and
every testable edge case passes. No blocking defect was found; no test was
weakened, skipped, or deleted.

This pass re-verified the item after `/review` returned `request-changes` for
**[M1]**: the builder's own `<handoff>` block still routed a `/fix` run to the
work-item block's `Next: … else /test`, contradicting `command/fix.md`. The builder
prose now carries a mode-aware `<handoff>` (`.opencode/agent/builder.md:97-118`),
and this pass adds the missing coverage the review asked for — assertions scoped to
the builder's fix block — plus a test-hygiene fix for the review's **[m2]**
(`/tmp` temp file moved under the ignored `scratch/` with an `EXIT` trap).

**Coverage added this pass:** 8 assertions (builder fix-mode handoff: block
presence, `Next: /ship fix`, forbids the work-item block and `tasks.md`/`/test`,
does not route a fix to `/test`, drops the `tasks.md` requirement, omits the
landing on failure; plus "scan staged content before committing" for AC7).
Suite total 135 → 143; all green.

The implementation adds a `fix` mode to `/ship` (`/ship fix [short description]`)
and reconciles ten surfaces — `.opencode/command/fix.md`,
`.opencode/agent/builder.md`, `.opencode/agent/shipper.md`,
`.opencode/command/ship.md`, `AGENTS.md`, `docs/workflow.md`, `README.md`, and the
`workflow-lifecycle`, `pr-workflow`, and `conventional-commits` skills — onto that
one landing path.

## Commands run

Test-command discovery (confirmed with the `project-discovery` skill): the
repository has no root task runner, no CI workflow, and no
`package.json`/`pyproject.toml`/`Makefile`; `AGENTS.md` → Project profile is the
unfilled template. Consistent with every prior item, the framework's executable
verification is the committed `work/**/verify-tests.sh` suites.

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0003-framework-quality-hardening/0005-fix-landing/verify-tests.sh` | PASS | 143 passed, 0 failed — the focused suite for this item (all ACs + edge cases + preserved invariants) |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | 179 passed, 0 failed — inventory/count/permission gate named by the spec |
| `bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh` | PASS | 69 passed, 0 failed — readiness/shipped-signal agreement (sibling contract preserved) |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | 51 passed, 0 failed |
| `bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | FAIL (pre-existing) | 99 passed, 4 failed — stale pre-merge `git status` assertions in a shipped suite; see "Gaps and residual risk" |

### Mutation testing (proves the new assertions are not coverage theater)

Run against throwaway `git worktree` checkouts with the working diff applied; the
production tree was never modified. Each mutation was injected into a copied
`builder.md`:

| Injected defect | Result |
| --------------- | ------ |
| Remove the builder's whole fix-mode handoff block | 138 passed, **5 failed** (block presence, `Next: /ship fix`, work-item-block ban, `tasks.md`//test ban, omit-on-failure) |
| Change the fix handoff's `Next: /ship fix` to `Next: /test` | 141 passed, **2 failed** (`does not end Next: /ship fix`, `still routes a fix to /test`) |

The first mutation run also exposed that a `grep -F 'Next: /ship fix'` predicate was
matching the prose sentence "omit \`Next: /ship fix\`" rather than the handoff line;
that assertion was tightened to an anchored `^Next: /ship fix$` before the final
run, which is why the second mutation now trips two assertions.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — documented landing path in the closing handoff | `verify-tests.sh` AC1 (8 original: `command/fix.md` `Next: /ship fix`, summary/files/reproduction/root-cause, shipper actor, omit-on-failure; builder names the path) **plus 7 new builder-handoff assertions** covering the review-M1 fix block | PASS |
| AC2 — landing requires an explicit user request | `verify-tests.sh` AC2 (4: shipper + ship command each require the explicit invocation and state "without it, perform no git write") | PASS |
| AC3 — a verified fix can land | `verify-tests.sh` AC3 (10: `fix/<short-description>` branch, conventional commits, push/PR, and the local-commit + exact-command `gh`-unavailable fallback in shipper, ship command, and conventional-commits skill) | PASS |
| AC4 — no review artifact required | `verify-tests.sh` AC4 (5: shipper and ship command waive `review.md` as a documented exception; pr-workflow scopes the precondition out) | PASS |
| AC5 — only the shipper performs git writes | `verify-tests.sh` AC5 (6: builder still never commits, defers to the shipper; contract names the shipper as the sole git writer and bars all others; shipper + builder YAML frontmatter byte-identical to `HEAD`); gate suite AC11 (shipper `work/**` grants; read-only agents deny) | PASS |
| AC6 — the fix consumes no work item | `verify-tests.sh` AC6 (7: workflow states no work item/no sequence number/no record; shipper and ship command skip `ship.md`; no tracked `work/` file modified; no unexpected new path under `work/`) | PASS |
| AC7 — evidence travels with the fix PR | `verify-tests.sh` AC7 (12 original: fix PR template has Summary/Reproduction/Root cause/Change/Testing/Risks and no `## Artifacts`; secret scan precedes staging; PR carries the evidence; accepted gap recorded) **plus 1 new assertion** that the standing principle scans *staged* content before committing | PASS (with a documented scan-ordering risk — see gaps) |
| AC8 — no surface still dead-ends the fix track | `verify-tests.sh` AC8 (12: all ten surfaces reference `/ship fix`; `/fix` no longer ends with a bare prohibition; README no longer claims `/ship`-only landing) | PASS |
| AC9 — guardrails and shipper preconditions agree | `verify-tests.sh` AC9 (5: contract guardrail names the verified-fix exception and the explicit request; shipper agrees on consent and the single-writer boundary; lifecycle skill restates it); gate suite AC9 (exactly one readiness definition) | PASS |
| AC10 — failed verification blocks landing | `verify-tests.sh` AC10 (7: `/fix` drops the landing step and reports the blocker; shipper/ship command block on a failed check or unreproduced defect; builder presents no landing path) | PASS |
| AC11 — the track stays lightweight | `verify-tests.sh` AC11 (8: workflow names the avoided artifacts and `work/` directory; counts 14/12/10 match on-disk agents/commands/skills; diff touches only the ten surfaces named in design.md); manual diff review (prose only, no runtime code); gate suite 179/0 | PASS |
| AC12 — the documentation surfaces agree | `verify-tests.sh` AC12 (9: shipper, ship command, lifecycle skill, workflow, pr-workflow, README all state the no-review/no-`ship.md`/`/ship fix` contract; none re-requires `review.md` for a fix) | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| `gh` unavailable or unauthenticated | `verify-tests.sh` EDGE (shipper, ship command, pr-workflow skill all name the fallback) | PASS |
| A secret in the fix diff | `verify-tests.sh` EDGE ("commit nothing" on a secret; scan before committing) | PASS (scan-ordering caveat below) |
| Unrelated pre-existing working-tree changes | `verify-tests.sh` EDGE (shipper + ship command stage only the fix's files; both say never `git add -A`) | PASS |
| The current branch is the default branch | `verify-tests.sh` EDGE (fix branch used; never the default, both surfaces) | PASS |
| A fix that grows into new behavior | `verify-tests.sh` EDGE (`/fix` and builder route to `/spec`) | PASS |
| The defect cannot be reproduced | `verify-tests.sh` EDGE (`/fix` reports it as the blocker; no landing) | PASS |
| Untestable defect with no regression test | `verify-tests.sh` EDGE (landing blocked unless the user explicitly accepts; acceptance recorded in the PR) | PASS (partial — see gaps) |
| Several independent fixes pending at once | `verify-tests.sh` EDGE (stage only the named fix's files; one logical change per commit) | PASS (partial — see gaps) |
| Concurrent lifecycle work items | `verify-tests.sh` EDGE (no sequence number, so no collision/renumber) | PASS |
| `/ship` with neither a fix nor a work item | `verify-tests.sh` EDGE (empty argument still asks which work item; shipper input branch unchanged) | PASS |

## Gaps and residual risk

- **Static verification cannot prove runtime agent behavior.** This is a prompt
  and documentation change; the suite proves the ten surfaces *state* the correct
  contract, not that a live LLM agent follows it. A real end-to-end `/ship fix`
  run (creating a fix, letting the shipper branch/commit/push, opening a PR) was
  deliberately not performed: it requires git writes by the shipper on the user's
  explicit request and would leave a real branch/PR. This is inherent to the
  change and is what the design's test strategy accepts; the mutation testing above
  is the strongest available substitute.
- **Fix-mode secret scan is weaker than the design states** (review m1, Minor). The
  design says "scan *staged* content"; `.opencode/agent/shipper.md:130` scans
  "changed content … before staging", and `.opencode/command/ship.md:51` says
  "before committing". A pre-staging scan of `git diff` cannot see an untracked new
  file (a new regression test), so a secret introduced in a new file would only be
  caught by the standing operating principle at `shipper.md:49` ("Scan staged
  content before committing"), which this pass now asserts. AC7's observable
  outcome — no secret committed — is covered via that principle plus the
  ship-command wording; the step-level wording is a Minor inconsistency to align in
  a follow-up. Not a test failure, so not a landing blocker.
- **"Several independent fixes pending at once" is only implied.** The surfaces
  satisfy it through "stage only the fix's files", "one logical change per
  commit", and asking when the boundary is unclear, but none states explicitly
  that each fix is its own commit/PR or how the user's request selects among
  pending fixes. Minor documentation gap; a future surface-consistency pass could
  state it.
- **Missing regression test acceptance** is documented (blocked unless the user
  explicitly accepts, and the acceptance must be stated in the PR) but the
  "explicit acceptance" itself has no machine-checkable form — by design, since a
  fix creates no artifact where it could be recorded beyond the PR body.
- **`work/0003-.../0001-state-model/verify-tests.sh` still has 4 stale failures**
  (`AC1 … not listed by git status` for `spec.md`/`design.md`/`tasks.md`, and
  `AC3 nested child .gitkeep not in git status`). Those artifacts are tracked at
  `HEAD` (`git ls-files` confirms), so the failures are a pre-merge `git status`
  assumption in a shipped suite, reproducible with this change absent. The design
  excludes this suite as a gate for this reason and directs the tester to check its
  preserved literals directly instead; all of those literals are asserted in the
  new suite's "Preserved invariants" section. Not a defect of this item.
- **The new suite lives under `work/`.** That matches every prior item's executable
  evidence and does not modify a shipped suite. Sibling `0006-committed-tests-ci`
  owns relocating the framework harness out of `work/`; this file is a candidate to
  move with it.
- **`/ship` signature discoverability** (review n1, Nit). The command's
  `description:` frontmatter and the README command row still read
  `Usage: /ship [item-ref]`, while the body documents
  `/ship [item-ref | fix [short description]]`. The landing path is discoverable
  from `/fix`, `docs/workflow.md`, the README `/fix` row, and the lifecycle skill,
  so this is a nit, not a spec violation.
- **The `review.md` verdict is still `request-changes`.** It was authored before
  the builder's M1 rework and this verification; a fresh `/review` is required to
  clear it. The M1 behavior it asked for is present and now covered.

No defect in the implementation was found. All acceptance criteria and edge cases
are covered by passing assertions or documented above.
