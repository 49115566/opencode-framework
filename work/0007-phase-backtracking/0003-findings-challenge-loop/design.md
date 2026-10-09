---
feature: 0007-phase-backtracking/0003-findings-challenge-loop
phase: design
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "Ordinary forward plan; no open finding in backtracks.md (none exists). Resolves the spec's deferred design choices: (1) the challenge record is a committed, append-only per-item `challenges.md` beside `backtracks.md`, not a phase artifact and carrying no `phase`; (2) its challenge-type vocabulary is `finding | severity | acceptance-criterion` and its decision vocabulary `sustained | rejected`, reusing the shipped severity scale and verdict vocabulary; (3) the challenged condition is the record's open-entry marker plus a derived `challenged` (blocked) label — no new `phase` value — evaluated with precedence over the forward-action rows; (4) adjudication re-enters the producing phase, which records a `Response` and, on a tie, escalates on the existing question surface to the user. A per-artifact `challenged:` frontmatter marker on the finding's artifact was considered and rejected: writing it would require the challenger to edit the producing phase's artifact, which AC1/AC9 forbid. Adopts the spec's two open assumptions as written (no unrecorded route; escalation uses the existing user-interaction surface). The `/test` reverse edges (`/test`→`/build`/`/plan`/`/spec`) are wired here; the parent-roadmap route stays 0004's and post-ship reopen stays 0005's. Committed fixtures/mutation coverage remain 0007's scope."
conflicts-with: "docs/workflow.md, .opencode/agent/builder.md, .opencode/agent/reviewer.md, 0002-reverse-phase-routing"
---

# Design — Contestable findings and adjudication loop

## Summary

Add a **findings challenge loop** on top of the shipped `0001` backtrack model
without a new command, phase value, agent, skill, or state file: a disputed
finding in `review.md` or defect in `verify.md` is contested by appending an
entry to a committed, append-only per-item `challenges.md` record; while any
challenge is open the item derives a `challenged` (blocked) condition and cannot
advance (including `/ship`); the phase that produced the challenged finding
re-evaluates it and records a `Response` (decision, basis, adjudicator), revising
its own artifact and recomputing the review verdict only when it sustains the
challenge, and escalating to the user on a tie. The same item wires the `/test`
reverse edges: a `/test` defect that is really a spec or design fault is routed
upstream through the backtrack model (`/test`→`/plan` or `/test`→`/spec`) with a
recorded finding and `stale:` markers, while an implementation defect still routes
to `/build` as today.

## Approach

### 1. The challenge contract is one new authority section in `docs/workflow.md`

Insert `## Findings challenge and adjudication` immediately after
`## Phase reversal (backtracking)` and before `## Derived state` (currently
`docs/workflow.md:797`), so the derived-state rows can reference it directly. It
states, once and as the single authority (AC1–AC6, AC9, AC12):

1. **What is challengeable.** A finding in `review.md` and a defect reported in
   `verify.md` are both challengeable, including a claimed defect that is really a
   spec or design fault; a challenge to a non-review finding is never silently
   dropped (AC2). No finding means nothing to challenge and nothing blocks.
2. **Raising a challenge.** The challenger appends a `Challenge <n>` entry to
   `work/<item-ref>/challenges.md` naming the challenged finding, the challenge
   type, the evidence, and the rationale. The challenger never edits the artifact
   owned by the phase that produced the finding (AC1, AC9). Raising happens on the
   existing phase surface — the author's current phase prompt (the `/build`
   prompt for a review finding or a verify defect) — so no command is added.
3. **The challenged (blocked) condition.** While `challenges.md` holds any
   challenge with no matching `Response`/`Withdrawal`, the item is **challenged**:
   it does not advance to its next forward phase, including `/ship`, and the open
   challenge escalates to the user (AC4). The condition is represented as the
   record's optional open-entry marker plus the derived label `challenged`; it adds
   no `phase` value (AC13).
4. **Adjudication.** The phase that produced the challenged finding re-evaluates
   it first on re-entry; if it cannot resolve the challenge it escalates to the
   user on the existing question surface, and the user decides. The challenger is
   never the adjudicator of its own challenge, and no adjudication completes
   without a `Response` entry recording the decision, its basis, and who made it
   (AC3).
5. **Outcomes and routing.** A sustained challenge overturns or re-severities the
   finding and, for a review finding, recomputes the review verdict (`approve` if
   and only if no Blocker or Major remains); the outcome and its evidence are
   recorded and the next command follows the recomputed verdict. A rejected
   challenge leaves the finding and verdict unchanged, records the rejection and
   its rationale, and resumes normal routing — the existing
   `review.md` `request-changes` → `/build` route (AC5, AC6). If a sustained
   challenge shows the acceptance criterion itself is wrong, the correction is
   routed upstream through the backtrack model rather than written into
   `review.md`.
6. **Ownership.** The challenger/detector records state and never edits the
   producing phase's artifact; the producing phase's owner revises its own
   artifact and appends the outcome. The "only the owning phase writes its
   artifact" invariant is unchanged (AC9).

### 2. State model: a per-item challenge record, not a new phase value

**Record — `work/<item-ref>/challenges.md`** (shape documented in
`docs/artifact-conventions.md`, mirroring `backtracks.md`):

- It is **not** a phase artifact: no `phase:` value, not an artifact-presence
  row, and it does not by itself determine the item's derived **phase** (it
  determines the blocked **condition**). Frontmatter is minimal and distinct:
  `feature`, `record: challenges`, `created`, `updated`.
- The body is append-only and numbered from `1`. Entry kinds:
  - `## Challenge <n> — YYYY-MM-DD` — `challenger` (the phase), `challenged`
    (artifact + finding id, e.g. `` `review.md` `[M1]` `` or `` `verify.md` `D1` ``),
    `type` (`finding | severity | acceptance-criterion`), `evidence`, `rationale`,
    `status: open`.
  - `## Response <n> — YYYY-MM-DD` — `resolves: Challenge <n>`, `adjudicator`
    (the producing phase command, or `user`), `decision` (`sustained | rejected`),
    `basis`, `outcome` (free text: overturned / severity adjusted to `<X>` /
    verdict recomputed to `<approve|request-changes>` / finding unchanged /
    reclassified as a spec or design fault).
  - `## Withdrawal <n> — YYYY-MM-DD` — `withdraws: Challenge <n>`, `reason`. The
    author may withdraw; the withdrawal is appended and the prior entry preserved.
  - `## Reversal <n> — YYYY-MM-DD` — `reverses: Response <n>`, `adjudicator`,
    `decision`, `basis`. A later decision supersedes an earlier one without
    rewriting it.
- Effective status of challenge `n` is `open` until a matching `Response n` or
  `Withdrawal n` exists, then `resolved`/`withdrawn`; a `Reversal n` supersedes
  the recorded decision but does not reopen. Entries are never edited, reordered,
  or removed; a `Response`/`Withdrawal`/`Reversal n` recorded before `Challenge n`
  is malformed and is reported, not reordered (AC10).
- Absent file = nothing challenged; historical items need no migration.

**The challenged condition — optional open-entry marker + derived label.** A
challenge is "open" purely from committed state: a `Challenge n` with no matching
`Response n`/`Withdrawal n`. The record is optional (absent = not challenged), and
that open entry is the marker; the derived label is `challenged`. Precedence is
stated once in `## Derived state`: the challenged condition is evaluated as a
blocked overlay before the forward-action rows (build/test/review/ship), so a
challenged item is never read as ready to advance or ship; `stale:`/`reopened:`
structural derivations are evaluated first and both conditions block. No new
`phase` value is introduced (AC4, AC13); the full `/status` vocabulary and
dependency-readiness reporting remain `0006`'s.

### 3. Adjudication is a re-entry to the producing phase

Mirroring `0001`'s re-entry:

- **Reviewer (`/review`).** Before ordinary forward work, read `challenges.md`
  for an open challenge against a `review.md` finding and re-evaluate it against
  the spec and the diff. On a decision, append a `Response` (adjudicator `/review`),
  and when sustained revise `review.md` — overturn or re-severity the finding and
  recompute the verdict. When it genuinely cannot decide, escalate on the
  question surface; the user's decision is recorded with `adjudicator: user`. The
  reviewer never adjudicates a challenge it raised.
- **Tester (`/test`).** The same for an open challenge against a `verify.md`
  defect. If a sustained challenge shows the defect is really a spec/design fault,
  the tester routes it upstream via the `/test` reverse edges (§4) rather than
  reclassifying it inside `verify.md`.
- Raising routes to the producing phase: a challenge to a `review.md` finding
  hands off `Next: /review <item-ref>`; a challenge to a `verify.md` defect hands
  off `Next: /test <item-ref>`.

### 4. Wire the `/test` reverse edges (`/test`→`/build`/`/plan`/`/spec`)

`0002` left the `/test` edges unwired (`docs/workflow.md:762-766`); this item
wires the two upstream ones and presents the third as the existing rework
instance:

- **`/test`→`/plan`** — the tester classifies a defect as a design fault, appends
  a `Backtracks.md` `Finding <n>` entry (detecting `/test`, target `/plan`,
  affected `design.md`/`tasks.md`, evidence), marks every existing artifact
  strictly downstream of `/plan` (`verify.md`, `review.md`) `stale: design`, does
  not edit `design.md`/`tasks.md`, and hands off `Next: /plan <item-ref>`.
- **`/test`→`/spec`** — the same with target `/spec`, affected `spec.md`, and
  `design.md`/`tasks.md`/`verify.md`/`review.md` marked `stale: spec`, handing off
  `Next: /spec <item-ref>`.
- **`/test`→`/build`** — an implementation defect routes to `/build` as today
  (the tester's existing "owns tests, not production code" rule is preserved);
  it is documented as the pre-existing rendered instance of the general model, so
  no forced finding record or `stale:` marker is added to it (AC8).
- When the tester cannot classify a defect as implementation vs upstream, it
  records the classification question and escalates rather than guessing, so the
  item is not pushed at the wrong phase.
- This updates only the operational text of `### The reverse-edge rule` and
  `### Taking an edge` (drop `/test` from the "not taken here" exception list; add
  the three rows to the concrete per-edge table) and the Test phase `Next`; the
  `0001` model, its marker vocabulary, and the Derived-state rows stay the single
  authority (AC7, AC8).

### 5. Reference, do not restate, from the prompts and the skill

The contract lives once in the authority. The affected surfaces reference it and
carry only the operational steps they own:

- `docs/artifact-conventions.md` documents the `challenges.md` record template
  and the challenged condition (AC12).
- `.opencode/agent/{builder,reviewer,tester}.md` and their command wrappers carry
  the raising, adjudication, and `/test` classification steps (AC12).
- `.opencode/skill/code-review/SKILL.md` references the challenge/adjudication
  route and the verdict-recomputation rule, reusing the existing severity and
  verdict vocabulary (AC11, AC12).
- `.opencode/skill/workflow-lifecycle/SKILL.md` adds the open-challenge and
  `/test` upstream routes with canonical signatures only (AC1, AC4, AC7).
- No surface states a conflicting challenge rule or leaves a disputed finding as
  obey-or-ignore (AC12). `AGENTS.md`/`template/AGENTS.md`, `README.md`,
  `.opencode/agent/status.md`, `docs/workflow.md`'s number-headed phase sections'
  signatures, and every inventory count are deliberately untouched (AC14).

## Alternatives considered

- **Chosen — a separate `challenges.md` record drives the blocked condition, with
  a new authority section and re-entry adjudication.** Pros: preserves the
  ownership invariant (the challenger never writes the producing phase's
  artifact); is append-only and auditable; adds no command, phase value, agent,
  skill, or state file; reuses the severity, finding, and verdict vocabulary;
  keeps `/ship` blocked through derived state. Cons: like every prompt-only
  contract, its correctness depends on agents following the authority, and the
  "challenged" marker is the record's open entry rather than a frontmatter field.
- **Rejected — a `challenged:` frontmatter marker on `review.md`/`verify.md`.**
  Pros: mirrors `0001`'s per-artifact `stale:` marker literally. Cons: only the
  finding's owning phase may write that artifact, so the challenger cannot set the
  marker when filing — the marker could not exist until adjudication, failing
  AC4's "an open challenge immediately blocks" and AC1/AC9's "the challenger
  never edits the producing phase's artifact". The record's open entry carries the
  same information without the ownership breach.
- **Rejected — a new `/challenge` (or `/dispute`) command.** Pros: one explicit
  entry point. Cons: adds a command, changing the README Layout count, the
  Commands table, the AGENTS `Supporting commands:` list, the command→agent
  pairings, and the `96-signature-sweep` registry/required sets — a direct
  violation of AC14 and the spec non-goal.
- **Rejected — reuse `backtracks.md` for challenges, or overload `review.md`'s
  finding status.** Pros: one record. Cons: the spec requires a challenge/response
  record *distinct from* `backtracks.md`; overloading the finding status rewrites
  a prior entry and cannot record who decided, the basis, or a withdrawal, failing
  AC3, AC5, and AC10.
- **Rejected — a new `challenged` `phase` value or a state file.** Forbidden by
  AC4/AC13 and `0001`; would break the phase-set/derived-state agreements and fork
  the vocabulary `0006` reports.

## Interfaces and data model

### `work/<item-ref>/challenges.md` (new committed record)

```markdown
---
feature: NNNN-slug
record: challenges
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## Challenge 1 — YYYY-MM-DD

- challenger: `/build`
- challenged: `review.md` [M1]
- type: severity
- evidence: <observable observation>
- rationale: <why the finding or its severity is disputed>
- status: open

## Response 1 — YYYY-MM-DD

- resolves: Challenge 1
- adjudicator: `/review` | `user`
- decision: sustained | rejected
- basis: <spec/criterion/diff evidence>
- outcome: severity adjusted to Minor | verdict recomputed to approve | finding unchanged | …
```

Sequential from `1`, append-only; `## Withdrawal <n>` and `## Reversal <n>`
append beside `## Response <n>`. Effective status `open` until a matching
`Response n`/`Withdrawal n`; a response/withdrawal/reversal before its challenge
is malformed and reported, not reordered.

### The challenged condition (derived-state shape fixed here; reporting is `0006`'s)

- **Predicate:** `challenges.md` contains a `Challenge <n>` with no matching
  `Response n`/`Withdrawal n`.
- **Label:** `challenged` (blocked). **Not** a `phase` value; the underlying phase
  is still derived from the artifact-presence/verdict rows below it.
- **Precedence:** evaluated as a blocked overlay before the forward-action rows
  (build/test/review/ship) and before the `ship.md`/verdict rows, so a challenged
  item never advances or ships. `stale:`/`reopened:` structural derivations are
  evaluated first; both block.
- **Effect:** the next forward phase (including `/ship`) refuses and reports the
  open challenge(s), which is the escalation surface; the producing phase
  adjudicates.

### New vocabulary (small, controlled; no fork of severity/verdict/finding format)

| Field | Values |
| ----- | ------ |
| challenge `type` | `finding` \| `severity` \| `acceptance-criterion` |
| `decision` | `sustained` \| `rejected` |
| `adjudicator` | the producing phase command (`/review`, `/test`) \| `user` |
| finding severity | reused `Blocker`/`Major`/`Minor`/`Nit` |
| verdict | reused `approve`/`request-changes` |

### Surfaces and routing

- **Raising:** append a `Challenge` entry; never touch the finding's artifact;
  hand off to the producing phase (`/review` for a review finding, `/test` for a
  verify defect).
- **Adjudicating:** producing-phase re-entry appends a `Response`; on a sustained
  review challenge the owner revises `review.md` and recomputes the verdict, and
  the next command follows the recomputed verdict (`/ship` if `approve`, `/build`
  if `request-changes`); on a rejected review challenge normal routing resumes.
- **`/test` upstream edges:** recorded `Finding` + downstream `stale:` markers +
  `Next: /plan <item-ref>` or `Next: /spec <item-ref>`; implementation defects to
  `/build` as today.

### Backward compatibility / migration

Additive documentation and prompts only. Items without `challenges.md` are
unaffected and need no migration; an unchallenged item behaves exactly as today.
No new `phase` value, state file, command, agent, or skill; the `0001` model, the
`backtracks.md` record, the `stale:`/`reopened:` markers, the `/review`→`/build`
rework row, the six `phase` values, and the `Depends on`/readiness contract are
unchanged.

## Affected areas

- `docs/workflow.md` —
  - New `## Findings challenge and adjudication` section before
    `## Derived state` (currently `:797`); `### <digit>.` headings untouched.
  - `## Derived state` (`:797-835`): add the challenged blocked condition and its
    precedence; change none of the seven route literals checked by
    `tests/checks/20-lifecycle.sh:58-78`.
  - `## Phase reversal (backtracking)` `### The reverse-edge rule` (`:671-700`)
    and `### Taking an edge` (`:727-766`): wire the `/test` edges and add their
    concrete rows; update the "not taken here" exception and the
    "only two edges are wired" note.
  - `### 4. Test` `Next` (`:365`) names the upstream classification route;
    `### 6. Ship` entry (`:388`) refuses a challenged item; optionally one
    `## Routing heuristics` (`:864`) bullet for the challenge route.
- `docs/artifact-conventions.md` — new `### `challenges.md` (challenges) —
  per-item challenge record` template after the `backtracks.md` template
  (`:471-520`), and the challenged condition documented alongside the markers.
- `.opencode/agent/builder.md` (`:38-44`, `:59-99`, `:117-123`) and
  `.opencode/command/build.md` — raise a challenge, never edit the finding's
  artifact, hand off to the producing phase.
- `.opencode/agent/reviewer.md` (`:65-77`, `:90-102`) and
  `.opencode/command/review.md` — adjudicate a challenge against a review
  finding, recompute the verdict, record the `Response`, escalate on a tie.
- `.opencode/agent/tester.md` (`:77-78`, `:94-105`, `:134-140`) and
  `.opencode/command/test.md` — classify `/test` defects and wire the upstream
  edges; adjudicate a challenge against a verify defect.
- `.opencode/skill/code-review/SKILL.md` — reference the challenge/adjudication
  route and the verdict-recomputation rule.
- `.opencode/skill/workflow-lifecycle/SKILL.md` `## Which command now?`
  (`:30-49`) — open-challenge and `/test` upstream routes with canonical
  signatures only.
- **Not touched:** `.opencode/agent/status.md` (`0006`), `README.md` and every
  inventory count (no file added), `AGENTS.md`/`template/AGENTS.md` (not an AC12
  surface; avoids split-guard parity churn), `.opencode/agent/{architect,product,
  shipper}.md` and `.opencode/command/{plan,ship}.md`, `tests/**` (`0007`), the
  parent `roadmap.md` (`0004`/`0007`), `opencode.json`, `template/**`.

## Risks and mitigations

- **Pinned suite literals** — `tests/checks/20-lifecycle.sh` byte-pins seven
  route literals and the derived-state artifact names; `96-signature-sweep.sh`
  parses workflow `### <digit>. ` headings and the skill routing block;
  `40-inventory.sh` pins README counts. *Likelihood high (we edit those surfaces)
  / impact high / mitigation:* add prose and rows only; keep the seven literals
  verbatim; add no `### <digit>.` heading, file, command, agent, or skill; use
  canonical signatures only in the skill block; run `bash tests/run.sh`.
- **AC13's "optional marker" interpretation** — a strict reading might expect a
  frontmatter field. *Likelihood medium / impact medium / mitigation:* define the
  open-entry marker and its precedence explicitly in the authority and
  `docs/artifact-conventions.md`, and record the rejected frontmatter alternative
  and the ownership reason so `0006` and the reviewer see the deliberate choice.
- **Ownership breach** — the challenger could write the finding's artifact.
  *Likelihood medium / impact high / mitigation:* the contract and every prompt
  state the never-edit rule; only the owner writes `review.md`/`verify.md` and
  appends the `Response`.
- **Model fork / second vocabulary** — a challenge-specific severity or verdict.
  *Likelihood medium / impact high / mitigation:* reuse `Blocker`/`Major`/
  `Minor`/`Nit` and `approve`/`request-changes`; the only new tokens are
  `type`/`decision`/`adjudicator`.
- **`/test` edge overlap with `0002`** — the shipped operational text says the
  `/test` edges are not wired. *Likelihood medium / impact medium / mitigation:*
  update only that operational text and the per-edge table; the `0001` model stays
  the single authority and its derived-state rows are unchanged.
- **Blocked `/ship` not enforced** — a challenge against a Minor with an
  `approve` verdict could ship. *Likelihood low / impact high / mitigation:* the
  authority's challenged condition and the Ship entry both refuse a challenged
  item; the derived-state overlay precedes the verdict/ship rows.
- **Scope creep into siblings** — roadmap revision, post-ship reopen, status
  reporting, committed guards. *Likelihood medium / impact medium / mitigation:*
  touch only the AC12 surfaces; leave `roadmap.md`, `status.md`, `ship.md`/
  shipper, and `tests/**` to `0004`/`0005`/`0006`/`0007`.
- **No committed guard for the loop** — deliberately `0007`'s scope.
  *Likelihood high / impact low / mitigation:* the test strategy maps every AC to
  a suite run or a recorded inspection command, and the residual is recorded.

## Test strategy

The deliverable is documentation and prompts; committed fixtures and mutation
coverage are `0007-backtracking-guards`. Verification is the existing suite plus
recorded inspection of the named surfaces in `verify.md`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Manual: authority defines the record, the three challenge types, the never-edit rule, and that it is not a phase artifact; `docs/artifact-conventions.md` carries the template. |
| AC2 | Manual: authority and prompts state both `review.md` findings and `verify.md` defects are challengeable and a non-review challenge is not dropped. |
| AC3 | Manual: authority + `/review`/`/test` prompts state producer-first re-evaluation, user escalation, challenger-never-adjudicator, and the `Response` fields. |
| AC4 | Manual: authority + Ship entry state the challenged block incl. `/ship` and escalation; no new `phase` value. |
| AC5 | Manual: sustained outcome recomputes the verdict and the next command follows it. |
| AC6 | Manual: rejected outcome leaves finding/verdict unchanged and resumes `request-changes` → `/build`. |
| AC7 | Manual: `### Taking an edge`/per-edge table list `/test`→`/plan` and `/test`→`/spec` with recorded finding, `stale:` markers, and handoffs; Test `Next` names them. |
| AC8 | Manual: `/test`→`/build` documented as the existing implementation-defect rework; tester rule preserved. |
| AC9 | Manual: challenger/detector records state and never edits the producing artifact; owner revises and appends. |
| AC10 | Manual: append-only entries incl. `Withdrawal`/`Reversal`; malformed out-of-order reported, not reordered. |
| AC11 | Manual: severity scale, finding format, and verdict vocabulary reused; `git diff --stat` shows no new state file. |
| AC12 | Manual grep of the six named surfaces; `bash tests/run.sh` green. |
| AC13 | Manual: challenged condition + precedence in the authority; `status.md` untouched (`0006` owns reporting). |
| AC14 | Suite + `git diff --stat`: `bash tests/run.sh` exit 0 / `0 failed`; no command/agent/skill added; counts and pairings unchanged. |

## Follow-ups (out of scope; no expansion without user approval)

- `0004-roadmap-revision` owns the parent-`roadmap.md` route; `0005-post-ship-pr-denial`
  the post-ship reopen; `0006-status-and-derived-state` the `/status` vocabulary
  and the challenged/reopened reporting implementation; `0007-backtracking-guards`
  the committed fixture and mutation coverage for the record, the challenged
  condition, and the `/test` edges. `AGENTS.md`/`template/AGENTS.md` are
  deliberately untouched; if a future item wants the challenge route in the
  always-loaded contract, it must update both copies together for split-guard
  parity.
