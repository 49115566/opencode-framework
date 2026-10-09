---
feature: 0007-phase-backtracking/0003-findings-challenge-loop
phase: test
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "Documentation/prompt-only deliverable. Per spec.md non-goals ('Committed fixtures, agreement areas, and mutation coverage for the challenge loop — owned by 0007-backtracking-guards') and design.md Test strategy ('The deliverable is documentation/prompts; committed fixtures and mutation coverage are 0007-backtracking-guards'), no new committed check area was added; committed guard coverage is 0007's scope. Verification is the existing suite plus recorded read-only content assertions over the named surfaces. No UI surface, so no /visual pass. One edge-case documentation gap is recorded (ship.md-present item not excluded in the challenge authority)."
---

# Verification — Contestable findings and adjudication loop

## Scope and approach

This item's deliverable is documentation and prompts: a new single-authority
section in `docs/workflow.md`, a `challenges.md` record template in
`docs/artifact-conventions.md`, and the raising/adjudication/`/test`-routing
steps in the `.opencode` builder, reviewer, and tester prompts, their command
wrappers, and the `code-review` and `workflow-lifecycle` skills.

The spec's Non-goals and the design's Test strategy explicitly assign
**committed fixtures, agreement areas, and mutation coverage for the challenge
loop** to the sibling `0007-backtracking-guards`. Adding a new
`tests/checks/*` agreement area here would violate that non-goal, overlap
`0007`, and contradict this item's own T9 acceptance gate ("`git diff --stat`
shows ... no `tests/**` change"). No test file was therefore added, weakened,
skipped, or deleted. Each criterion is verified below either by the existing
configured suite (`bash tests/run.sh`) or by a recorded read-only inspection
command with its observed result. This mirrors the sibling items
`0001-backtracking-model`, `0002-reverse-phase-routing`, and
`0004-roadmap-revision`, whose verification is likewise suite + inspection.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 344 passed, 0 failed, 0 skipped`; exit 0 (log `scratch/verify-suite.log`) |
| `grep -cE '^FAIL' scratch/verify-suite.log` | PASS | `0` failures; no skipped assertions |
| inline content-assertion harness over the named surfaces | PASS | `CONTENT CHECKS: 80 passed, 0 failed` (read-only `grep -F` assertions; see matrix) |
| `git diff --name-only` | PASS | only the 11 planned surfaces changed; no file added or removed |
| `git status --porcelain -- tests/ README.md AGENTS.md template/ .opencode/agent/status.md` | PASS | empty — the guard, inventory, and `0006` surfaces are untouched |
| `git ls-files --others --exclude-standard` | PASS | empty — no new untracked command/agent/skill/state file |
| `ls .opencode/command/*.md \| wc -l`; `ls .opencode/agent/*.md \| wc -l` | PASS | `13` commands, `14` agents — unchanged |
| `grep -c '^### [0-9]' docs/workflow.md` | PASS | `6` — no numbered phase heading added |
| `diff` of the derived-state table literals vs `HEAD` | PASS | identical except the added `challenged` row and its precedence paragraph |
| `diff` of `docs/workflow.md` `## Derived state`..`## The fix track` vs `HEAD`, excluding the challenge additions | PASS | only the challenged row/paragraph added; the seven route literals and phase enum are byte-unchanged |
| `grep -nF '\| `/test`→' docs/workflow.md` | PASS | the `/test`→`/plan`, `/test`→`/spec`, `/test`→`/build` rows are present (lines 773–775) |

## Acceptance coverage

| Criterion | Test(s) / inspection evidence | Result |
| --------- | ------------------------------ | ------ |
| AC1 (recorded append-only entry; type/evidence/rationale; challenger never edits the producing artifact; not a phase artifact) | `docs/workflow.md:835-850` — `## Challenge <n>` appended to `work/<item-ref>/challenges.md`, type `finding \| severity \| acceptance-criterion`, evidence, rationale, "never edits the artifact", "it adds no `phase` value", "does not determine the item's derived **phase**". `docs/artifact-conventions.md:522-613` — frontmatter `record: challenges` (no `phase:`), entry shapes/fields, `status: open`. Harness AC1 literals: 12/12. | PASS |
| AC2 (both `review.md` findings and `verify.md` defects challengeable; non-review not dropped) | `docs/workflow.md:827-833` — "A finding in `review.md` and a defect reported in `verify.md` are both challengeable, including a claimed defect that is really a spec or design fault. A challenge to a non-review finding is never silently dropped." No-finding case: "nothing to challenge: no challenge record is created and nothing blocks." | PASS |
| AC3 (producer re-evaluates first; user escalation; never self-adjudicate; `Response` records decision/basis/adjudicator) | `docs/workflow.md:862-873`. `.opencode/agent/reviewer.md:68-83` (step 1: adjudicate first; sustained/rejected/unresolved; `adjudicator: user`; "Never adjudicate a challenge you raised"); `.opencode/command/review.md:14-22`; `.opencode/agent/tester.md:103-117`; `.opencode/command/test.md:19-24`. Harness AC3: 10/10. | PASS |
| AC4 (open challenge blocks incl. `/ship`; escalates; no new `phase` value) | `docs/workflow.md:852-860` ("does not advance to its next forward phase, including `/ship`, and the open challenge escalates to the user"); Ship entry `:392-396`; derived-state row `:916`; precedence paragraph `:943-955`. Harness AC4: 5/5. | PASS |
| AC5 (sustained overturns/adjusts; verdict recomputed `approve` iff no Blocker/Major; outcome+evidence recorded; next command follows) | `docs/workflow.md:874-887`; `.opencode/agent/reviewer.md:74-79` ("Recompute the verdict: `approve` if and only if no `Blocker` or `Major` remains"). Harness AC5: 6/6. | PASS |
| AC6 (rejected leaves finding+verdict unchanged; rejection recorded; resumes `request-changes`→`/build`) | `docs/workflow.md:883-887`; `.opencode/agent/reviewer.md:80-82` ("**Rejected** — leave the challenged finding and the verdict unchanged ... resume normal routing"). Harness AC6: 4/4. | PASS |
| AC7 (`/test`→`/plan` and `/test`→`/spec` wired: recorded finding, `stale:` markers, upstream handoff) | `docs/workflow.md:773-774` (edge rows), `:365-371` (Test `Next`); `.opencode/agent/tester.md:103-133` (append `## Finding <n>` to `backtracks.md`, mark downstream `stale:`, never edit upstream, hand off `/plan`/`/spec`); `.opencode/command/test.md:25-31`. Harness AC7: 7/7. | PASS |
| AC8 (`/test`→`/build` preserved; tester owns tests, not production code) | `docs/workflow.md:775` (implementation-defect rework row, no forced record/marker); `.opencode/agent/tester.md:77` ("You own tests, not production code.") retained; `.opencode/command/test.md:25-26`. Harness AC8: 3/3. | PASS |
| AC9 (challenger/detector records state, never edits the producing artifact; owner revises and appends; ownership invariant unchanged) | `docs/workflow.md:889-895`; `.opencode/agent/builder.md:43-49,101-110,138`; `.opencode/agent/reviewer.md:114-117` ("Write only `review.md` and an appended `Response`"); `.opencode/agent/tester.md:84-85,169-172`. Harness AC9: 4/4. | PASS |
| AC10 (append-only; `Withdrawal`/`Reversal`; malformed out-of-order reported, not reordered) | `docs/workflow.md:897-905`; `docs/artifact-conventions.md:558-613` (`## Withdrawal <n>`, `## Reversal <n>`, `does not reopen the challenge`, "malformed and is reported, not reordered"). Harness AC10: 5/5. | PASS |
| AC11 (reuse severity scale, finding format, `approve`/`request-changes`; no second scale/grammar/verdict/state file) | `docs/workflow.md:820-825`; `.opencode/agent/reviewer.md:117-119`; `.opencode/skill/code-review/SKILL.md:60-73`; `docs/artifact-conventions.md:610-613`. No new file (`git ls-files --others` empty). Harness AC11: 5/5. | PASS |
| AC12 (workflow authority states contract once; conventions documents record+condition; `/review`,`/build`,`/test` prompts and code-review skill reference it; no conflicting rule) | Authority `docs/workflow.md:814-905`; template `docs/artifact-conventions.md:522-613`; refs in `.opencode/agent/{builder,reviewer,tester}.md`, `.opencode/command/{build,review,test}.md`, `code-review/SKILL.md:60`, `workflow-lifecycle/SKILL.md:44-47`. `code-review/SKILL.md:65-68` states "never leave it as obey-or-ignore". Harness AC12: 7/7. | PASS |
| AC13 (challenged condition consistent with the `0001` marker model + precedence; `/status`/readiness left to `0006`) | `docs/workflow.md:907-955` — derived row `:916`, precedence paragraph `:943-955` ("blocked overlay ... before the forward-action and `ship.md`/verdict rows", "introduces no new `phase` value", full `/status` vocabulary remains `0006`'s); `docs/artifact-conventions.md:606-613`. `.opencode/agent/status.md` untouched (`git diff --quiet` empty). Harness AC13: 5/5. | PASS |
| AC14 (`bash tests/run.sh` passes; six phase commands/pairings unchanged; no command/agent/skill add/remove; no inventory count/signature change) | `bash tests/run.sh` → `344 passed, 0 failed, 0 skipped`, exit 0 — includes `20-lifecycle.sh` (pairings/routes), `40-inventory.sh` (README counts), `96-signature-sweep.sh` (signatures/registry); `AGENTS.md`, `README.md`, `template/`, `tests/`, `.opencode/agent/status.md` byte-unchanged; 13 commands / 14 agents / no untracked file. Harness AC14: 3/3. | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| No findings | `docs/workflow.md:831-833` — no record created, nothing blocks. | PASS |
| Open challenge never adjudicated | `docs/workflow.md:858-860` — "Nothing resolves on its own ... keeps the escalation in place." | PASS |
| Withdrawn challenge | `docs/workflow.md:866-870`; `docs/artifact-conventions.md:584-591`. | PASS |
| Adjudication by the wrong party | `docs/workflow.md:865-866`; reviewer/tester "Never adjudicate a challenge you raised." | PASS |
| Sustained challenge reveals a wrong AC | `docs/workflow.md:880-883` — routed upstream through `## Phase reversal (backtracking)` rather than written into `review.md`. | PASS |
| Challenge to a non-blocking finding (Minor/Nit) | `docs/workflow.md:854-857` — "any challenge with no matching `Response` or `Withdrawal`" holds the item and escalates; `:874-879` — sustained "overturns ... or adjusts its severity". Not restricted to Blocker/Major (implied by "any"/"the challenged finding"). | PASS (implied) |
| **Challenge after the item shipped** | The authority does not state that a `ship.md`-present item is out of scope for a challenge, and the derived-state precedence (`docs/workflow.md:943-946`) puts the `challenged` overlay **before** the `ship.md` row. A hypothetical `challenges.md` with an open `Challenge` on a shipped item would derive `challenged`, contradicting the spec edge case "an item whose `ship.md` is present is out of scope; its reversal is the post-ship reopen path (`0005`)". See "Gaps and residual risk". | PARTIAL |
| Multiple open challenges | `docs/workflow.md:854-857` ("any challenge ... keeps the item challenged"), `:952-953` ("the open challenge(s)"); append-only order `:899-905`. Order preserved, nothing truncated. | PASS (implied) |
| `/test` fault cannot be classified | `docs/workflow.md:369-371`; `.opencode/agent/tester.md:120-122`; `.opencode/command/test.md:31` — record the question and escalate rather than guess. | PASS |
| Out-of-order record entries | `docs/artifact-conventions.md:611-613`; `docs/workflow.md:902-904` — malformed reported, not reordered. | PASS |
| Two items in parallel | Record is per-item (`work/<item-ref>/challenges.md`); advisory, adds no readiness edge (`docs/workflow.md:676-680` unchanged). | PASS (implied) |
| Shipped or missing upstream artifacts on a `/test` upstream route | `docs/workflow.md:773-774` marks only *existing* downstream artifacts `stale:`; derived state then names the target phase (per the `0001` model). | PASS |
| No unrecorded route | Raising is defined as appending a `Challenge` entry (`docs/workflow.md:835-843`); the `/test` upstream route requires the recorded `Finding` (`:773-774`, tester prompt). Implied by the procedure; no lightweight unrecorded route is offered. | PASS (implied) |

## Gaps and residual risk

- **No committed automated guard for the challenge loop (deliberate).** The
  spec's Non-goals and the design's Test strategy assign fixture-based agreement
  areas and mutation coverage to `0007-backtracking-guards`; T9 additionally
  requires `no tests/** change`. Verification here is the configured suite plus
  80 recorded read-only content assertions. The loop's literals can drift
  between this item and `0007`, which should pin the authority section (the
  `challenges.md` record shape, the challenged-condition precedence, the
  `/test` edge rows) when it lands. This is a scoped deferral, not a coverage
  claim.
- **`ship.md`-present item not excluded in the challenge authority — Minor,
  edge-case gap.** The spec's edge case "Challenge after the item shipped" says a
  shipped item is out of scope (post-ship reopen is `0005`'s). The authority
  (`docs/workflow.md:814-905`) never states the unshipped precondition, and the
  precedence paragraph (`:943-955`) deliberately places the `challenged` overlay
  before the `ship.md` row, so a post-ship `challenges.md` open entry would derive
  `challenged` rather than `shipped`. Minimal reproduction (documentation, not
  executable): add `work/<shipped-item>/challenges.md` with an open
  `## Challenge 1`, then derive state → `challenged`, where the spec edge case
  expects the shipped item to be out of scope. Recommended fix (a one-line
  clarification in the authority that challenges apply to unshipped items, since
  post-ship revert is `0005-post-ship-pr-denial`) or an explicit note that
  `0005` owns the interaction. This is not an acceptance criterion and the
  sibling `0005` owns the boundary, so it does not block; the reviewer should
  decide whether the clarification belongs here or in `0005`.
- **Framework-internal, prompt-only contract.** Like the `0001`/`0002` model,
  correctness ultimately depends on agents following the authority text; there
  is no runtime enforcement. Residual risk is the ordinary one for prompt-driven
  contracts and is unchanged from the siblings.
- **`AGENTS.md`/`template/AGENTS.md` deliberately untouched**, per the design's
  "Not touched" list and to avoid split-guard parity churn. A maintainer reading
  only the always-loaded contract would not see the challenge route until
  `0006`/a follow-up adds it; `AC12`'s named surfaces do not include `AGENTS.md`.
- **No UI surface**, so no `/visual` pass was required.

No acceptance criterion failed, no test was weakened, skipped, or deleted, and
the configured suite is green (`344 passed, 0 failed, 0 skipped`).
