---
feature: 0007-phase-backtracking/0003-findings-challenge-loop
phase: review
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "No challenges.md exists for this item, so there was no open challenge to adjudicate. The deliverable is documentation/prompts; committed fixtures/mutation coverage are 0007-backtracking-guards' scope. The configured suite could not be executed from this read-only review session (the bash allowlist permits only git/ls/cat), so AC14 was validated by static inspection of every pinned check rather than by a live run; the change touches no pinned literal, adds no file, and adds no ### <digit>. heading."
---

# Review — Contestable findings and adjudication loop

## Verdict

**approve** — all 14 acceptance criteria are met, no Blocker or Major finding
survives scrutiny; the one substantive issue is a narrow post-ship edge-case
clarification (Minor) that verify.md already recorded and that the sibling
`0005-post-ship-pr-denial` owns.

## Commands run

- `git status` / `git log --oneline -15` / `git branch -a`
- `git merge-base HEAD origin/main` → `f74fbdf2839ff36ebba1b7557dca5c5d1ce261d7`
- `git diff --stat` and `git diff` (the item's changes are **uncommitted** on
  `main`, so the review range is the working tree: `HEAD` = `origin/main` =
  `f74fbdf`)
- Read-only inspection of `tests/checks/{10,20,30,40,50,70,85,90,95,96}.sh`,
  `tests/README.md`, `docs/workflow.md`, `docs/artifact-conventions.md`, and the
  modified `.opencode` prompts/skills.

Base note: there is no feature branch and no committed diff for this item; the
builder's work is uncommitted on `main`. The base is therefore `HEAD` itself
(`f74fbdf`), and the diff under review is `git diff` plus the untracked
`verify.md`. This is unambiguous and is what the artifact claims.

## Acceptance criteria

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 — recorded append-only entry; type/evidence/rationale; challenger never edits the producing artifact; not a phase artifact | **met** | `docs/workflow.md:835-850` (record, `finding\|severity\|acceptance-criterion`, "never edits the artifact", "adds no `phase` value"); `docs/artifact-conventions.md:522-613` (minimal frontmatter `record: challenges`, no `phase:`). |
| AC2 — `review.md` findings and `verify.md` defects both challengeable; non-review not dropped | **met** | `docs/workflow.md:827-833`; `docs/workflow.md:831` ("never silently dropped"); tester adjudication step `:103-118`. |
| AC3 — producer re-evaluates first; user escalation; challenger never adjudicates; `Response` records decision/basis/adjudicator | **met** | `docs/workflow.md:862-873`; `.opencode/agent/reviewer.md:68-85`; `.opencode/agent/tester.md:103-118`; `.opencode/command/{review,test}.md`. |
| AC4 — open challenge blocks incl. `/ship`; escalates; no new `phase` value | **met** | `docs/workflow.md:852-860`; Ship entry `:394-396`; derived-state row `:916`; precedence `:943-955`. |
| AC5 — sustained overturns/adjusts; verdict recomputed `approve` iff no Blocker/Major; outcome recorded; next command follows | **met** | `docs/workflow.md:874-880`; `.opencode/agent/reviewer.md:73-78`; `.opencode/skill/code-review/SKILL.md:70-73`. |
| AC6 — rejected leaves finding+verdict; rejection recorded; resumes `request-changes`→`/build` | **met** | `docs/workflow.md:884-887`; `.opencode/agent/reviewer.md:79-80`. |
| AC7 — `/test`→`/plan` and `/test`→`/spec` wired: recorded finding, `stale:` markers, upstream handoff | **met** | `docs/workflow.md:744-748`, `:773-780`; Test `Next` `:365-371`; `.opencode/agent/tester.md:126-136`; `.opencode/command/test.md:25-31`. |
| AC8 — `/test`→`/build` preserved; tester owns tests, not production code | **met** | `docs/workflow.md:775`; `.opencode/agent/tester.md:77` retained. |
| AC9 — detector records state, never edits producing artifact; owner revises and appends; ownership invariant unchanged | **met** | `docs/workflow.md:889-895`; `.opencode/agent/builder.md:138-139`; `reviewer.md:114-120`; `tester.md:171-174`. |
| AC10 — append-only; `Withdrawal`/`Reversal`; malformed out-of-order reported, not reordered | **met** | `docs/workflow.md:897-905`; `docs/artifact-conventions.md:558-613`. |
| AC11 — reuse severity scale, finding format, `approve`/`request-changes`; no second scale/grammar/verdict/state file | **met** | `docs/workflow.md:820-825`; `.opencode/skill/code-review/SKILL.md:70-73`; `git status` shows no new file. |
| AC12 — authority states contract once; conventions documents record+condition; `/review`,`/build`,`/test` prompts and code-review skill reference it; no conflicting rule | **met** | Authority `docs/workflow.md:814-905`; template `docs/artifact-conventions.md:522-613`; refs in `.opencode/agent/{builder,reviewer,tester}.md`, `.opencode/command/{build,review,test}.md`, `code-review/SKILL.md:60-73`, `workflow-lifecycle/SKILL.md:44-47`. |
| AC13 — challenged condition consistent with `0001` marker model + precedence; `/status`/readiness left to `0006` | **met** | `docs/workflow.md:916`, `:943-955` ("blocked overlay … before the forward-action and `ship.md`/verdict rows", "introduces no new `phase` value"); `.opencode/agent/status.md` untouched. |
| AC14 — configured suite passes; six phase commands/pairings unchanged; no command/agent/skill add/remove; no inventory/signature change | **met** (by static inspection; suite not executable in this session) | `git status` shows only the 11 planned surfaces plus `verify.md`; no `.opencode` file added; `README.md`/`AGENTS.md`/`template/**`/`tests/**`/`status.md` untouched; `docs/workflow.md` gains no `### <digit>.` heading; the seven route literals in `tests/checks/20-lifecycle.sh:65-78` and the signature registry/required sets in `tests/checks/96-signature-sweep.sh:37-52,226-230` are unchanged; the four new skill route lines (`workflow-lifecycle/SKILL.md:44-47`) normalize to canonical signatures. |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] A `ship.md`-present item is not excluded from the challenge authority or its derived state** — `docs/workflow.md:854-860`, `docs/workflow.md:916`, `docs/workflow.md:943-948`.
  The spec's edge case "Challenge after the item shipped" says a `ship.md`-present
  item is out of scope (its reversal is the `0005-post-ship-pr-denial` reopen
  path), and the `0001` model states the same exclusion for backtracks
  (`docs/workflow.md:698-699`, `:807`). The new authority states no unshipped
  precondition, and the derived-state row places `challenged` (`:916`) *before*
  the `ship.md` row (`:924`) with prose that puts the overlay before the
  `ship.md`/verdict rows (`:943-946`). A `challenges.md` open entry on a shipped
  item therefore derives `challenged`, not `shipped`, contradicting the spec edge
  case. It is narrow (prompt-only, low likelihood, readiness still keys on
  `ship.md` presence) and the sibling `0005` owns the post-ship boundary, so it
  is not merge-blocking.
  Recommended fix: add "on an unshipped item" (or "while `ship.md` is absent") to
  the challenged-condition definition at `:854-860`, mirroring the backtrack
  model's "Shipped items are excluded" bullet, or record explicitly that `0005`
  owns the interaction.

### Nits

- **[N1] Table position vs. stated precedence is slightly ambiguous** — `docs/workflow.md:916` vs `docs/workflow.md:943-946`.
  The prose scopes the overlay to "before the forward-action and `ship.md`/verdict
  rows", while the table places the `challenged` row before the roadmap/spec/design
  rows too. Both readings block the item, so the observable outcome is the same,
  but "defined precedence" would be unambiguous if the row order and the prose
  agreed. Take or leave it.
- **[N2] The `challenged` field has no verify-defect identifier convention** — `docs/artifact-conventions.md:551-559`.
  `challenged: \`review.md\` [M1]` is well-defined for a review finding, but
  `verify.md` has no finding-id scheme, so naming "the artifact that produced the
  disputed item (… or a `verify.md` defect)" does not tell an adjudicator which
  defect is contested. A one-line convention (e.g., a defect label or "carried in
  `evidence`") would remove the guesswork.

## Scope and convention fit

- The diff touches exactly the surfaces the design named: `docs/workflow.md`,
  `docs/artifact-conventions.md`, `.opencode/agent/{builder,reviewer,tester}.md`,
  `.opencode/command/{build,review,test}.md`, and the `code-review` and
  `workflow-lifecycle` skills, plus `tasks.md` check boxes. No unrelated refactor,
  no new command/agent/skill/phase value/state file. No scope creep observed.
- Security/secret handling: no secrets, credentials, or `.env` content; no
  executable code changed. Nothing to flag.
- The design's `conflicts-with` declaration (`docs/workflow.md`,
  `.opencode/agent/{builder,reviewer}.md`, `0002-reverse-phase-routing`) is
  advisory plan state and is satisfied by this diff; it is not a defect.

## Not reviewed

- The configured suite (`bash tests/run.sh`) was **not executed** in this
  session: the review agent's bash allowlist permits only `git`/`ls`/`cat`, so
  AC14 was validated by reading every pinned check and confirming the change
  touches none of the pinned literals, adds no file, and adds no `### <digit>.`
  heading. verify.md records a live `344 passed, 0 failed, 0 skipped`; that claim
  is plausible against the static analysis but was not independently reproduced.
- `0004`/`0005`/`0006`/`0007` sibling scopes (roadmap revision, post-ship reopen,
  `/status` vocabulary, committed fixtures) were out of scope, as the spec
  requires.
- No `visual.md` exists and none is required (no UI surface).
