---
feature: 0007-phase-backtracking/0001-backtracking-model
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Review — Phase-backtracking and revision model

## Verdict

**approve** — the documentation-only deliverable faithfully defines the backtrack
model across the three named surfaces, ticks every acceptance criterion, changes
no phase value, command, inventory, or readiness contract; the findings below are
clarity and verification-accuracy nits, not defects.

## Diff under review

- Base: `git merge-base HEAD origin/main` → `1ca9c8d` (the merged plan PR #31).
- `git log --oneline -5`, `git status --porcelain`, `git diff` (working tree vs
  `HEAD`). The implementation is uncommitted; the plan artifacts (`spec.md`,
  `design.md`, `tasks.md`) are committed at `HEAD`, so the reviewed range is the
  working-tree change plus the untracked `verify.md`.
- Changed: `AGENTS.md` (+4), `docs/artifact-conventions.md` (+66),
  `docs/workflow.md` (+98/-8), `tasks.md` (box ticks). Untracked: `verify.md`,
  `roadmap.md`, sibling child dirs, `.gitkeep` (pre-existing roadmap-phase state,
  not this item's output).

The sandbox denied `bash tests/run.sh`, so AC12 was checked statically against
the pinned checks (`tests/checks/20-lifecycle.sh`, `40-inventory.sh`,
`96-signature-sweep.sh`) and against the tester's recorded run (334 passed /
0 failed); I did not independently re-execute the suite.

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[m1] "earliest `stale:` marker" is undefined** — `docs/workflow.md:640,655`.
  AC6 and the spec's sequential-backtracks edge case require the item to derive
  "the earliest outstanding target", but neither the row nor the precedence note
  defines "earliest" (lifecycle-phase order vs. record order). An implementer of
  `0006`/`0007` must guess, which is exactly the divergence the keystone item is
  supposed to eliminate. Recommendation: state the ordering explicitly, e.g.
  "the earliest target in lifecycle order (`spec` < `design` < `build` < `test`
  < `review`)", matching the spec's "earliest outstanding target".

- **[m2] Record requirement vs. the retained review-rework exemplar is not
  reconciled** — `docs/workflow.md:594` vs. `docs/workflow.md:650,662-666`. The
  model says "Every backtrack carries a committed finding before the reverse edge
  is taken; there is no unrecorded reversal", yet the retained
  `request-changes` → `build (rework)` path is presented as the pre-existing
  instance of the model with its "consumers unchanged" — i.e. it produces no
  `backtracks.md` finding entry. Recommendation: add one sentence stating that
  the `review.md` verdict (and its findings) satisfies the recorded-finding
  precondition for that path, so `0006`/`0007` do not create a second record
  requirement or a contradiction.

- **[m3] Sanctioned-edge table reads as exhaustive while the general rule is
  broader** — `docs/workflow.md:570-571,584`. The prose states a general
  "later phase may target an earlier phase" rule, then calls the table "The
  sanctioned edges". A reader can infer unlisted edges (e.g. `/review`→`/test`)
  are sanctioned by the general rule but absent from the table. Recommendation:
  say the table is the complete sanctioned set (the general rule is bounded by
  it) or label it as the minimum canonical set.

- **[m4] `verify.md`'s "no rival reverse-transition rule" grep evidence is
  inaccurate** — `work/0007-phase-backtracking/0001-backtracking-model/verify.md:35`.
  The recorded command
  `grep -rn -i 'route back\|reverse transition\|reverse edge\|backtrack' .`
  (excluding `work/`, `scratch/`) matches `.opencode/agent/builder.md:38`
  ("stop and route back") and `.opencode/agent/architect.md:106` ("route back"),
  so the claim that it finds only the three intended surfaces is not what the
  command returns. The residual-risk note (`:87-93`) does acknowledge these
  surfaces as deferred, so this is a verification-description error, not a hidden
  AC failure. Recommendation: correct the evidence line to say the prompt
  surfaces still carry generic "route back" wording that the model subsumes and
  that `0002` wires.

- **[m5] `stale`/`reopened` labels are not reflected in the status vocabulary**
  — `.opencode/agent/status.md:229-230` lists `rework` but not `backtracked` or
  `reopened`, while `docs/workflow.md:640-641` now derives those labels. This is
  explicitly `0006-status-and-derived-state`'s scope per `spec.md` non-goals, so
  it is not a defect in this item; flag it so `0006` does not miss it.
  Recommendation: carry this forward as an input to `0006` (no change now).

### Nits

- **[n1] Misplaced code span** — `docs/workflow.md:655`: "An `earliest stale:`
  marker names..." should read "An earliest `stale:` marker names...". The
  backticks currently wrap "earliest stale:".
- **[n2] Verification overstatement** — `tasks.md:31` (T6 verify) says
  `git diff --stat` lists only the three documentation surfaces; it also lists
  `tasks.md` (expected box ticks). Harmless.
- **[n3] Adopter copy not updated** — `template/AGENTS.md` does not receive the
  new backtracking bullet; only root `AGENTS.md` does. `design.md` defers the
  template/inventory surfaces, but confirm the intent so adopters get the
  reference once `0002` wires the prompts.

## Acceptance criteria

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 — backtrack defined, distinguished from forward progression and plan-publication revision | met | `docs/workflow.md:557-566` states both distinctions verbatim. |
| AC2 — general rule + table of all seven edges + every exception | met | `docs/workflow.md:570-597`: general rule, seven-row table (`:576-582`), six exception bullets. |
| AC3 — ownership returns to target; detector records but never edits; invariant unchanged | met | `docs/workflow.md:599-605`. |
| AC4 — append-only per-item record; not a phase artifact; no `phase` value | met | `docs/workflow.md:607-615`; `docs/artifact-conventions.md:451-500` (frontmatter `feature/record/created/updated` only; Finding/Resolution shapes; effective-status rule; "not a phase artifact"). |
| AC5 — downstream artifacts marked stale non-destructively; history recoverable | met | `docs/workflow.md:617-622`; marker rule `docs/artifact-conventions.md:46-52`. |
| AC6 — derived phase = target; stale never a prerequisite/current artifact | met | rows `docs/workflow.md:640-641`, precedence `:654-657`; ordering ambiguity noted in m1. |
| AC7 — six `phase` values unchanged; markers + derived labels, no new phase value | met | phase enumeration untouched (diff), `docs/artifact-conventions.md:25-26,46-59`, derived rows `docs/workflow.md:640-641`. (Spec's "six" vs the eight-token enumeration is a spec-count imprecision, not a new value.) |
| AC8 — `request-changes`→`/build` row retained, presented as an instance, no second mechanism | met | row untouched by the diff (`docs/workflow.md:650`); instance framing `:662-666`; pinned by `tests/checks/20-lifecycle.sh:75-76`. |
| AC9 — Failure-and-rollback route-back references the model; three rules intact | met | `docs/workflow.md:862-868`; report-failures and destructive-git-confirmation clauses unchanged. |
| AC10 — shipped item excluded; reopen separate; shipped signal/readiness unchanged | met | `docs/workflow.md:624-631`; readiness-presence statement `:659-662`. |
| AC11 — single authority; record/markers documented; `AGENTS.md` reference; no conflicting rule | met | `docs/workflow.md:557`; `docs/artifact-conventions.md`; `AGENTS.md:125-128`. Deferred prompt surfaces are consistent, not conflicting (m4). |
| AC12 — suite green; no new command/agent/skill; no inventory count change; six commands/phase set/readiness unchanged | met (static) | Suite not re-run here (sandbox); changes are additive docs and touch no `.opencode/`, `README.md`, `template/`, or `tests/` file — `git diff --stat HEAD -- .opencode template README.md tests opencode.json` is empty; `20-lifecycle.sh` literals and `40-inventory.sh` counts are unaffected. Tester records `bash tests/run.sh` → 334/0/0. |

## Scope and conventions

- Scope is exactly the three documentation surfaces the design named plus
  `tasks.md` box ticks. No source, config, test, agent, command, or skill changed;
  no scope creep. The untracked `roadmap.md` and sibling child directories are
  prior roadmap-phase state, not this item's build output.
- Convention fit is good: the new section sits immediately before
  `## Derived state`; the record template follows the existing `###` template
  format; `AGENTS.md` uses a Working-agreements bullet (not a lifecycle-table row
  or a `Supporting commands:` token), so `96-signature-sweep.sh` is unaffected.
- No secrets, credentials, or debug output introduced.

## Not reviewed

- Correctness of sibling surfaces (`0002` routing, `0003` challenge loop, `0004`
  roadmap revision, `0005` reopen, `0006` status vocabulary, `0007` fixtures) —
  explicitly out of this item's scope.
- Executed test results: `bash tests/run.sh` was blocked by the read-only
  sandbox; AC12 relies on static analysis plus the tester's recorded run.
