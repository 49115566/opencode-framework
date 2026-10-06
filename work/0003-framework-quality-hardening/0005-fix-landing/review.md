---
feature: 0003-framework-quality-hardening/0005-fix-landing
phase: review
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Review — Fix-track landing path

## Verdict

**approve** — the rework closes the prior review's M1 (the builder's handoff now
has a mode-aware fix block), no Blocker or Major survives scrutiny, and the
remaining items are two Minors and a discoverability Nit.

## Scope and method

The change is entirely in the working tree on `main`; the item's phase artifacts
are untracked. Commands run verbatim:

```
git merge-base HEAD origin/main   -> ff5a2faf3830d672d855fe7bbcd597a58ef568a0
git rev-parse HEAD origin/main    -> ff5a2fa... (both identical)
git status --porcelain -uall      -> 10 modified tracked files + 6 untracked work/ files
git diff --stat                   -> 10 files, +217/-24
git diff                          -> full body of the change
git diff --name-only              -> exactly the ten surfaces named in design.md
rg sweeps over .opencode, docs, AGENTS.md, README.md
```

Base ref is `HEAD`/`origin/main` (`ff5a2faf...`); there are no intervening
commits. Review scope is `git diff` plus the new
`work/0003-framework-quality-hardening/0005-fix-landing/` artifacts.

This is a prompt/documentation change. The sandbox denies executing arbitrary
scripts (`bash …/verify-tests.sh` was rejected, as it was for the prior review),
so I could not re-run the suites. Instead I read the new suite, the mutation
evidence in `verify.md`, and every sibling suite's assertions that touch the
changed files, and confirmed each asserted literal against the current files by
inspection and `rg`. I verified the counts directly (`ls`: 14 agents / 12
commands / 10 skills == `README.md:211-213`).

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — documented landing path in the closing handoff | **met** | `command/fix.md:24-42` defines the fix handoff ending `Next: /ship fix` and omits it on failure. The prior M1 is fixed: `builder.md:97-118` now has a mode-aware `<handoff>` with a distinct fix block (`:110-115`) that ends `Next: /ship fix`, forbids the work-item block, and drops `tasks.md`/`/test`. `builder.md:80-81` omits the landing on failure. |
| AC2 — landing requires an explicit user request | **met** | `shipper.md:88-89`; `command/ship.md:42-43`. |
| AC3 — a verified fix can land | **met** | `shipper.md:128-145` (fix branch, conventional commits, push/PR, `gh`-unavailable fallback); `ship.md:40-59`; `conventional-commits/SKILL.md:62-65`. |
| AC4 — no review artifact required | **met** | `shipper.md:96-97`; `ship.md:46-49`; `pr-workflow/SKILL.md:17-20`. |
| AC5 — only the shipper writes git | **met** | `builder.md:39,78-81`; `AGENTS.md:107`; `git diff` shows body-only edits for `builder.md`/`shipper.md` — no frontmatter/permission line changed (verified). |
| AC6 — the fix consumes no work item | **met** | `docs/workflow.md:261-286`; `shipper.md:142-145`; `ship.md:57-59`; `git diff --name-only` has no path under `work/`. |
| AC7 — evidence travels with the fix PR | **met** (Minor m1 caveat on scan wording) | `pr-workflow/SKILL.md:59-93` (Summary/Reproduction/Root cause/Change/Testing/Risks, no `## Artifacts`); `shipper.md:130-141`; `ship.md:50-56`. |
| AC8 — no surface still dead-ends the fix track | **met** | All ten edited surfaces reference `/ship fix`; `rg` finds no `Never commit. End with…`, dead-end, or `/ship`-only claim left. `product.md:104` / `command/spec.md:28` only *recommend* `/fix`; they do not describe its landing. |
| AC9 — guardrails and shipper preconditions agree | **met** | `AGENTS.md:107` vs `shipper.md:85-102`; `workflow-lifecycle/SKILL.md:62-67`. |
| AC10 — failed verification blocks landing | **met** | `fix.md:39-42`; `shipper.md:91-95`; `ship.md:44-49`; `builder.md:80-81,117-118`. |
| AC11 — the track stays lightweight | **met** | `docs/workflow.md:261-286` states the avoided artifacts; disk counts 14/12/10 match README; diff is prose-only across ten files, no agent/command/skill added. |
| AC12 — the documentation surfaces agree | **met** (Nit n1) | `ship.md:8-59`, `shipper.md:85-145`, `workflow-lifecycle/SKILL.md:40,62-67`, `docs/workflow.md:261-293`, `pr-workflow/SKILL.md:17-20,59-93`, `README.md:23-24,89-90,158`. Only the `/ship` usage signature lags (n1). |

Edge cases: `gh` unavailable, secret-in-diff, unrelated working-tree changes,
default-branch, fix-grows-to-new-behavior, unreproduced defect, missing
regression test, several pending fixes, concurrent work items, and empty `/ship`
are all addressed (`shipper.md:85-145`; `ship.md:40-66`; `docs/workflow.md`).
"Several independent fixes pending" remains implied rather than explicit, which
`verify.md:125-130` already records as an accepted Minor documentation gap; the
surfaces state "stage only the fix's files" and "one logical change per commit",
so I accept it as residual risk rather than a new finding.

## Findings

### Blockers

- None.

### Major

- None. The prior review's [M1] (the builder handoff routed a `/fix` run to
  `/test`) is resolved: `builder.md:105-118` scopes a fix to its own handoff and
  explicitly forbids the work-item block and `/test`, and the new suite asserts
  it (`verify-tests.sh:65-88`).

### Minor

- **[m1] Fix-mode secret scan wording is weaker than the design and codified in
  the suite** — `.opencode/agent/shipper.md:130`, `.opencode/command/ship.md:51`,
  `work/0003-framework-quality-hardening/0005-fix-landing/verify-tests.sh:155`
  Why it matters: `design.md:60-62` specifies fix mode "scan staged content for
  secrets"; `shipper.md:130` says scan "before staging", and `ship.md:51` says
  "before committing". A pre-staging scan of `git diff` cannot see an untracked
  new file (a new regression test), so a secret introduced there is only caught
  by the standing operating principle at `shipper.md:49` ("Scan staged content
  before committing") and the rule at `shipper.md:152`. The new suite now asserts
  the weaker "before staging" phrase, so a future alignment to the design would
  turn the suite red — the test locks in the divergence the prior review flagged.
  Recommended fix: change fix-mode step 2 to scan the *staged* content after
  staging and before committing, and update the assertion at `verify-tests.sh:155`
  to match (keeping the `shipper.md:49`/`shipper.md:156` checks).

- **[m2] Fix-mode precondition contradicts the shared-working-tree path** —
  `.opencode/agent/shipper.md:98-100`
  Why it matters: the precondition requires "The working tree contains only the
  fix's files", yet the same bullet then says to "ask the user when the boundary
  between the fix and unrelated changes is unclear". If the tree must contain only
  the fix's files there is never a boundary to ask about, so a literal reading
  blocks the very case the spec's edge case requires handling ("Unrelated
  pre-existing working-tree changes … stages only the fix's files … ambiguity is
  surfaced"). The wording mirrors the pre-existing work-item precedent, so it is
  Minor, not a blocker. Recommended fix: phrase the precondition as "no unrelated
  change will be staged" and keep the process-level "ask when the boundary is
  unclear" (as `command/ship.md:50-51` already does).

### Nits

- **[n1] `/ship` is not advertised as accepting `fix`** —
  `.opencode/command/ship.md:2`, `README.md:157`, `AGENTS.md:42`, and the
  `README.md:88` quickstart shows `/ship` with no `fix` signature. The command's
  `description:` still reads `Usage: /ship [item-ref]` and the command table row
  reads `/ship [item-ref]`, while the body documents
  `/ship [item-ref | fix [short description]]` and the `/fix` row at
  `README.md:158` points at `/ship fix`. Discoverability only; the landing path
  is reachable from `/fix`, `docs/workflow.md`, and the lifecycle skill. Consider
  updating the usage strings.
- **[n2] The `AGENTS.md:48` command inventory still reads `/fix <bug>
  (lightweight fix)`** with no landing mention. The critical guardrail at
  `AGENTS.md:107` carries the landing path, so this is not a dead end; optional
  to mention `/ship fix` there for symmetry with the README row.

## Checks performed

- **Backward compatibility:** work-item mode (`/ship <item-ref>`, `/ship` empty)
  is semantics-preserving. Every literal asserted by the shipped sibling suites is
  still present, verified by `rg`: `This is required, not optional`,
  `docs(work): record ship state`, `` no uncommitted `ship.md` ``,
  `NNNN-slug/MMMM-slug`, `NNNN-slug-MMMM-slug`, `work/<item-ref>/` artifacts`,
  `repository path`, `resolve for a reviewer who does not share`,
  `work/<item-ref>/spec.md`, and the readiness tokens in `docs/workflow.md`. The
  broad sweeps for a removed PR signal and for `work/<slug>` return no matches in
  the changed surfaces.
- **Security:** no secret in the diff; no permission/frontmatter change (verified
  with `git diff` on the two agent files); the shipper remains the only
  git-writing agent. See m1 for the scan-ordering nuance.
- **Tests:** the new `verify-tests.sh` is prompt/documentation-appropriate. It
  reads the changed facts as literals, scopes the builder-fix assertions to the
  fix block (`:65-88`) to avoid the false positive the mutation run exposed, and
  records mutation testing in `verify.md:57-71`. The prior [m2] `/tmp` issue is
  fixed: the temp file now lives under `scratch/` with an `EXIT` trap (`:147-149`).
  The one test weakness is m1's lock-in of the weaker scan wording.
- **Scope:** `git diff --name-only` is exactly the ten surfaces named in
  `design.md`; no path under `work/` is modified; no agent/command/skill added
  (14/12/10 counts intact).
- **Pre-existing failure:** `work/0003-.../0001-state-model/verify-tests.sh`'s 4
  reported failures are genuinely pre-existing. Its AC1 asserts that the item's
  `spec.md`/`design.md`/`tasks.md` and a nested `.gitkeep` "appear in `git status`"
  (`0001-state-model/verify-tests.sh:80-85,109-110`), but those files are tracked
  and clean at this base (`git status --porcelain -uall` lists no `0001-state-model`
  entry), so the assertion is stale independent of this diff. The design excludes
  that suite as a gate for this reason and directs checking its preserved literals
  directly, which the new suite does.

## Not reviewed

- Runtime LLM behavior: whether a live shipper actually executes fix mode as
  written. The item has no runtime code and `verify.md:107-114` documents this
  limitation; the mutation testing is the strongest available substitute and I did
  not re-run it (the sandbox denies script execution).
- Full pass/fail execution of the sibling suites; I verified their relevant
  assertions by inspection and `rg` rather than running them.
