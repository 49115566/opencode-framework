---
feature: 0003-framework-quality-hardening/0005-fix-landing
phase: design
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Design — Fix-track landing path

## Summary

Reuse the existing `/ship` command with a new sentinel argument —
`/ship fix [short description]` — as the one sanctioned way to land a verified
`/fix`. The shipper gains a documented **fix-landing mode** that, on the user's
explicit request, stages only the files the fix changed, confirms the regression
test / lint / typecheck bar, commits conventionally on a `fix/<description>`
branch, opens a PR carrying the reproduction, root cause, change, and check
evidence, and writes **no** `ship.md` because a fix consumes no work item. Every
surface that described a fix as un-landable is reconciled to state this path, and
no permission block, inventory count, or command set changes.

## Approach

The chosen path is **shipper-on-request landing with no fix artifact** (the
user decision recorded in `spec.md` notes). It splits cleanly into a producer
side and a consumer side, joined by a paste-ready handoff block.

**1. Producer side — `/fix` names its landing step.**
`.opencode/command/fix.md:24` currently ends with "Never commit." and gives no
next action. Replace that with the same prohibition plus the sanctioned exit: the
closing handoff keeps the reproduction, root cause, change, files, and check
results, and adds `Next: /ship fix` — presented only when every check passed and
the defect was reproduced (`spec.md` AC1, AC10). `.opencode/agent/builder.md`
(lines 26, 38, 77) keeps "never commit" and gains the same pointer to the
shipper-on-request path (`AC5`).

**2. Consumer side — the shipper's fix mode.**
`.opencode/agent/shipper.md` currently has a single set of preconditions keyed on
`work/<item-ref>/review.md`. Add a mode switch driven by the `/ship` argument:

- `item-ref` (`NNNN-slug` or `NNNN-slug/MMMM-slug`) → the existing work-item
  path, unchanged.
- `fix` (optional short description) → fix-landing mode.
- empty → existing behavior, unchanged: ask which work item to ship.

Fix mode preconditions (`AC2`, `AC3`, `AC4`, `AC10`):

- The user explicitly invoked `/ship fix` (the request itself is the consent).
- Reproduction was established and the regression test fails without the change
  and passes with it; test, lint, and typecheck pass for the touched scope. If the
  regression test is absent, landing is blocked unless the user explicitly accepts
  the gap, and the acceptance must be stated in the PR body.
- No independent review is required — a documented exception to the
  approved-work-item precondition (`AC4`).
- The tree contains only the fix's files; the shipper stages only those files and
  asks when the boundary is unclear (never `git add -A`).

Fix mode process (`AC3`, `AC7`): create a `fix/<short-description>` branch (never
the default branch); scan staged content for secrets and stop if any is found;
commit the change and its regression test as logical conventional commits; push
with approval; open a PR whose description carries reproduction, root cause,
change, and check results; **skip the `ship.md` write** and report the branch,
commits, and PR (or the exact push/PR commands when `gh` is unavailable).

**3. Contract surfaces state one path.**
`AGENTS.md:107` makes the fix case explicit while keeping the shipper as the only
git-writing agent (`AC9`); `docs/workflow.md` gains a short "## The fix track"
section and an updated routing heuristic (`AC6`, `AC8`, `AC11`); the
`workflow-lifecycle` skill gets a routing row (`AC12`); `README.md` corrects the
"only when you run `/ship`" claim and the `/fix` table row (`AC8`, `AC12`); the
`pr-workflow` skill gains a fix PR body template so the evidence is structured
(`AC7`); the `conventional-commits` skill notes the work-item-less `fix/…` branch
(`AC3`).

**4. What deliberately does not change.**
No new command, agent, skill, permission block, work-item directory, sequence
number, or artifact. Fixes produce no shipped-state signal. `ship.md` remains the
sole shipped signal for lifecycle work items (`AC6`, `AC11`).

## Alternatives considered

- **Auto-create a minimal work item for the fix** (the roadmap's first option).
  Pros: reuses readiness/derived state, gives the fix a normal artifact and
  shipped signal. Cons: consumes a sequence number and a `work/` directory,
  introduces a fix record and an artifact shape with no agreed template, and
  drags the full lifecycle (review, ship.md) in — all directly forbidden by
  `AC6`, `AC11`, and the spec's non-goals. Rejected as contradicting the settled
  decisions.
- **A new `/ship-fix` command, or a `--fix` flag on `/ship`.** Pros: an
  unambiguous entry point. Cons: a new command changes the documented command
  inventory and the README command table, which the existing static suite asserts
  (`work/0002-agentic-roadmaps/verify-tests.sh` AC13); a `--fix` flag invents a
  flag grammar the command surface has never had. Rejected: `/ship fix` conveys
  the same intent without adding a command or a flag.
- **`/ship` with no arguments auto-detects a pending fix.** Pros: shortest
  spelling. Cons: the shipper cannot reliably detect a fix — there is no fix
  artifact by design — so it would have to guess from the working tree; and it
  changes the documented empty-argument behavior ("ask which work item to ship"),
  which the spec's edge case pins as unchanged. Rejected.
- **Chosen: `/ship fix [short description]`.** The literal `fix` cannot be
  confused with an item-ref (the reference grammar requires a 4-digit prefix), it
  reuses the existing command and shipper agent, and it leaves both the
  item-ref and empty-argument behaviors untouched.

## Interfaces and data model

This item has no runtime code. Its "interfaces" are the command grammar, the
handoff/PR data that travels with a fix, and the artifact model.

**Ship command grammar** (`.opencode/command/ship.md`):

```
/ship [item-ref | fix [short description]]
  item-ref  -> work-item mode (unchanged)
  fix       -> fix-landing mode (new); optional description disambiguates
  (empty)   -> ask which work item to ship (unchanged)
```

**`/fix` closing handoff** (`.opencode/command/fix.md`, `.opencode/agent/builder.md`):

```
Done: <fix summary>; files changed (<paths>).
Checks: <test> -> PASS; <lint> -> PASS; <typecheck> -> PASS.
Root cause: <one sentence>
Reproduction: <failing test or exact repro>
Next: /ship fix   # only when reproduction and all checks succeeded
Blockers: <failure output and the reason landing is blocked, or none>
```

When any check fails or the defect could not be reproduced, `Next` is replaced by
the blocker and no landing is presented (`AC1`, `AC10`).

**Shipper fix-mode evidence requirement.** The shipper obtains reproduction, root
cause, change, files, and check results from the user's `/ship fix` request or the
preceding `/fix` handoff; if any is missing it asks before proceeding, so the PR
body can always satisfy `AC7`.

**Fix PR body** (`.opencode/skill/pr-workflow/SKILL.md`, new section):

```markdown
## Summary
<what changed and why, one or two sentences>
## Reproduction
<the failing test or exact repro>
## Root cause
<one sentence>
## Change
<notable changes>
## Testing
- `<command>` -> <result>
## Risks
<risk and mitigation, or "None identified.">
```

A fix PR has **no** `## Artifacts` section, because there is no work item.

**Artifact / state model.** A fix creates no directory under `work/`, consumes no
sequence number, and produces no `ship.md`. `ship.md` presence stays the sole
shipped signal, scoped to lifecycle work items (`AC6`, `AC11`).

**Invariants preserved (committed static suites).** The shipped suites under
`work/` assert exact literals and counts in the surfaces this change edits. The
design preserves every one; the build must not edit the suites (previously
authored artifacts are immutable):

| Surface | Literal/count that must survive | Asserted by |
| --- | --- | --- |
| `.opencode/agent/shipper.md` | frontmatter `edit`/`bash` blocks; `This is required, not optional`; `` `work/<item-ref>/` artifacts ``; `repository path`; `docs(work): record ship state`; `` no uncommitted `ship.md` ``; `NNNN-slug-MMMM-slug`; `committed working state` | `work/0002-agentic-roadmaps/verify-tests.sh`, `work/0003-.../0002-readiness-ship-state/verify-tests.sh`, `work/0003-.../0001-state-model/verify-tests.sh` |
| `.opencode/command/ship.md` | `This is required`; `` even when `gh` is unavailable ``; `docs(work): record ship state`; `` no uncommitted `ship.md` ``; `NNNN-slug/MMMM-slug`; `NNNN-slug-MMMM-slug` | same |
| `AGENTS.md` | `` branch, commits, PR, `ship.md` ``; `version-controlled so a fresh clone`; every agent/command named | `work/0003-.../0002-readiness-ship-state/verify-tests.sh`, `work/0003-.../0001-state-model/verify-tests.sh`, `work/0001-framework-consistency-hardening/verify-tests.sh` |
| `docs/workflow.md` | readiness algorithm and derived-state rows verbatim; `presence is the sole shipped signal`; `docs(work): record ship state`; `` no uncommitted `ship.md` ``; `committed working state` | same |
| `README.md` | `branch, commits, PR, ship.md`; `Ship: branch + PR + ship.md`; shipper row `` `work/**` + `**/work/**` `` (and not `none`); `# 14 role prompts` / `# 12 slash commands` / `# 10 knowledge skills`; every command/agent/skill documented | same |
| `.opencode/skill/workflow-lifecycle/SKILL.md` | `committed working state`; `no ship.md?` (and not `no PR?`) | `work/0003-.../0001-state-model/verify-tests.sh`, `work/0003-.../0002-readiness-ship-state/verify-tests.sh` |
| `.opencode/skill/pr-workflow/SKILL.md` | `committed working state`; `resolve for a reviewer who does not share`; `` work/<item-ref>/spec.md `` | `work/0003-.../0001-state-model/verify-tests.sh` |
| `.opencode/skill/conventional-commits/SKILL.md` | `NNNN-slug-MMMM-slug` | `work/0002-agentic-roadmaps/verify-tests.sh` |
| all surfaces | no `git-ignored` / `not deliverable` / `working state, not` persistence claim; no `PR detected` / `detected PR` / `no PR?` shipped-signal wording | `work/0003-.../0001-state-model/verify-tests.sh`, `work/0003-.../0002-readiness-ship-state/verify-tests.sh` |

These literals are raw `grep -F` matches: preserve exact capitalization and keep
each on a single line (the suites do not all normalise whitespace). No agent
frontmatter (permission) block changes. No agent, command, or skill is added or
removed, so all inventory/count assertions hold.

Backward compatibility: `/ship <item-ref>` and `/ship` with no arguments are
byte-for-byte behavior-identical; `item-ref` resolution, branch naming, artifact
staging, and the `ship.md` write are unchanged for lifecycle items.

## Affected areas

- `.opencode/command/fix.md` — replace the dead-end ending with the handoff that
  names `/ship fix`.
- `.opencode/agent/builder.md` — mission and `<lightweight_fix_mode>` state the
  shipper-on-request landing while keeping the no-commit rule.
- `.opencode/agent/shipper.md` — add fix-mode inputs, preconditions, process, and
  handoff; scope the `ship.md` write to work-item mode while preserving its
  literals.
- `.opencode/command/ship.md` — document the `fix` argument and its preconditions.
- `AGENTS.md` — guardrail at line 107 names the verified-fix exception; support
  text stays.
- `docs/workflow.md` — routing heuristic (lines 263-266) plus a new "## The fix
  track" section.
- `README.md` — lines 23, 88, and 156.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — rules and routing.
- `.opencode/skill/pr-workflow/SKILL.md` — fix PR body and the review-precondition
  exception.
- `.opencode/skill/conventional-commits/SKILL.md` — `fix/<short-description>`
  branch note for a work-item-less fix.

Not touched: `.opencode/agent/*` frontmatter, `docs/artifact-conventions.md`,
`opencode.json`, `.gitignore`, and any file under `work/` (immutable artifacts,
including the static suites).

## Risks and mitigations

- **The fix evidence is not visible to the shipper when `/ship fix` runs** (the
  shipper is a separate agent invocation and there is no fix artifact by design) —
  likelihood: medium / impact: high (PR violates `AC7`). Mitigation: `/fix` emits
  a paste-ready handoff; `/ship fix` tells the shipper to take the evidence from
  the request or the preceding handoff and to ask — never invent — if it is
  missing.
- **Wrong files staged in a shared working tree** (a pending work item plus a fix)
  — likelihood: medium / impact: high. Mitigation: fix mode stages only the paths
  the `/fix` handoff named and asks when the boundary is unclear; never
  `git add -A`; each fix is its own commit/PR.
- **A prose edit drops a literal the committed static suites assert**, turning a
  shipped suite red — likelihood: medium / impact: high. Mitigation: the
  "Invariants preserved" table is an explicit build checklist; T6 runs the
  inventory/permission suite (`work/0002-agentic-roadmaps/verify-tests.sh`) to
  zero failures and greps the other preserved literals.
- **`/ship fix` is used for something that is not a fix**, bypassing review —
  likelihood: low / impact: high. Mitigation: fix mode requires a reproduction and
  a passing regression test; a change that needs new behavior is routed back to
  `/spec`, and work items still require `review.md`.
- **A fix is mistaken for shippable while its checks are red** — likelihood:
  medium / impact: high. Mitigation: `/fix` omits the landing step when a check
  fails; the shipper independently requires green checks and blocks otherwise
  (`AC10`).
- **Someone expects a landed fix to leave shipped state or a `/status` phase** —
  likelihood: low / impact: medium. Mitigation: `docs/workflow.md` and the
  shipper state plainly that a fix creates no work item, no artifacts, and no
  `ship.md`; `ship.md` stays the sole signal for lifecycle items.
- **README wording drift reintroduces an un-landable claim** — likelihood: low /
  impact: medium. Mitigation: T6 sweeps every fix/commit surface and the final
  review checks the surfaces agree (`AC8`, `AC12`).

## Test strategy

This is a prompt/documentation change with no runtime code, so verification is
read-only shell assertions and inspection, matching the framework's existing
verification style. Each criterion maps to an observable check; the tester records
the results in `verify.md`. No assertion is added to a committed suite under
`work/` (those are immutable, and sibling `0006-committed-tests-ci` owns a
committed harness).

| Criterion | Verification level | Check |
| --- | --- | --- |
| AC1 | static (grep) | `.opencode/command/fix.md` and `.opencode/agent/builder.md` name `/ship fix` as the closing next action. |
| AC2 | static (grep) | `.opencode/command/ship.md` and `.opencode/agent/shipper.md` require the explicit request before any commit/push/PR. |
| AC3 | static (grep) | shipper fix mode names branch `fix/<description>`, conventional commits, push/PR, and the local-commit + exact-command fallback when `gh` is unavailable. |
| AC4 | static (grep) | shipper preconditions state the fix is landed without a `review.md`, as a documented exception. |
| AC5 | static (grep + diff) | `builder.md` still says never commit/push/PR; `AGENTS.md` still names the shipper as the only git writer; no agent frontmatter differs (`git diff` shows body only). |
| AC6 | static (grep + tree) | `docs/workflow.md` and shipper fix mode state no work item / sequence number / fix artifact / `ship.md`; no new path under `work/`. |
| AC7 | static (grep) | `pr-workflow` fix template and shipper fix mode name reproduction, root cause, change, and check results; secret scan precedes commit. |
| AC8 | static (grep sweep) | every surface naming `/fix` states or refers to the `/ship fix` path; no unconditional commit prohibition without it. |
| AC9 | static (grep) | `AGENTS.md` guardrail and `shipper.md` preconditions both permit the shipper to land a verified fix on explicit request while others never write. |
| AC10 | static (grep) | `/fix` and shipper fix mode both block landing on failed verification / no reproduction. |
| AC11 | manual + static | diff review shows prompt/doc prose only; no spec/design/tasks/verify/review artifact, no sequence number; `work/0002-agentic-roadmaps/verify-tests.sh` still passes. |
| AC12 | static (grep + diff) | the named surfaces (`docs/workflow.md`, `command/fix.md`, `builder.md`, `shipper.md`, `workflow-lifecycle` skill) describe one path and no longer contradict. |

Gates the tester runs: `bash work/0002-agentic-roadmaps/verify-tests.sh` (the
inventory/permission suite the spec's constraint names) plus targeted greps for
the preserved literals asserted by the other shipped suites. The full
`work/0003-.../0001-state-model/verify-tests.sh` is **not** used as a gate: its
AC1 `git status` assertions were authored pre-merge and are stale once the item is
committed; its preserved literals are checked directly instead.
