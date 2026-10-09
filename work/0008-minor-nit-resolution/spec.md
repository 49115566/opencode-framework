---
feature: 0008-minor-nit-resolution
phase: spec
status: final
created: 2026-10-09
updated: 2026-10-09
notes: "Standalone item. No open /plan→/spec or /test→/spec finding: work/0008-minor-nit-resolution/backtracks.md does not exist, so this is ordinary forward progression. User resolved the two policy forks: (1) full parity — any surviving Minor or Nit forces request-changes and must be fixed or formally contested through the existing challenge loop, with no silent or author-only decline; (2) all review-derived gates use the all-severity bar, including the sustained-challenge verdict recompute."
---

# Minor and nit resolution routing

## Problem

Review findings come in four severities — Blocker, Major, Minor, Nit — but only
two of them have any consequence. The reviewer sets `request-changes` "if any
Blocker or Major finding survives scrutiny; otherwise `approve`"
(`.opencode/agent/reviewer.md:95-97`), the `code-review` skill states the same
rule (`.opencode/skill/code-review/SKILL.md:56`), and the workflow authority
derives `build (rework)` only from an item whose `review.md` verdict is
`request-changes` (`docs/workflow.md:1046`). A Minor or Nit therefore routes
nowhere: it is listed in `review.md` and then **backgrounded**, and the item is
free to advance to `/ship` and merge with it unresolved. The severity
definitions say so outright — Minor is "worth fixing; not merge-blocking" and
Nit is "style or preference; take it or leave it"
(`docs/artifact-conventions.md:446-447`), and a Nit "the author may decline"
(`.opencode/skill/code-review/SKILL.md:27-28`).

The result is a two-tier review. Blockers and Majors are fixed; Minors and Nits
accumulate silently and are re-discovered, re-raised, and re-backgrounded on
later items. The people affected are **framework maintainers**, who cannot make
a review's own findings binding short of inflating them to Major to get them
routed, and **adopters**, who inherit the same one-way gate and the same
documentation that says a finding's severity can make it inert. The gap is
narrow and mechanical: the routing already exists for Blocker/Major
(`request-changes` → `/build`, the `build (rework)` derived state), and it is
simply not applied to the other two severities.

## Goals

- Make **any** surviving finding of any severity — Blocker, Major, Minor, or Nit
  — force the `request-changes` verdict, so Minors and Nits route back to
  `/build` exactly as Blockers and Majors do.
- Define **resolution** for a Minor or Nit as either being fixed in `/build` and
  no longer surviving on re-review, or being overturned through the existing
  challenge/response loop. There is no third path: no silent and no author-only
  decline of an unresolved finding.
- Apply the **same all-severity bar** to every review-derived gate, including the
  verdict recompute after a sustained challenge, so no severity can reach ship
  through an alternative route.
- Keep the observable lifecycle **coherent across every duplicated authority
  surface** — the reviewer prompt, the `/review` command, the `code-review`
  skill, the workflow authority, the review artifact conventions, and the
  `workflow-lifecycle` skill — so no surface still calls a Minor or Nit
  non-blocking.
- Reuse the existing four-severity scale, the existing `approve` /
  `request-changes` verdict, the existing `build (rework)` route, and the
  existing challenge loop; introduce no new vocabulary, disposition, marker,
  state, command, agent, skill, or record.

## Non-goals

- Redefining what makes a finding a Blocker, Major, Minor, or Nit — only each
  severity's routing and blocking effect changes, not its definition.
- Adding a "declined", "accepted", or "waived" disposition, a follow-up/backlog
  artifact, or any way to ship an unresolved finding.
- Changing the finding format, the challenge/response record and its
  adjudication, the severity scale, or the `approve` / `request-changes` verdict
  vocabulary. This item extends their reach; it does not fork them.
- Changing `/test` defect handling. `verify.md` defects have no severity scale
  and are out of scope.
- Changing the `/fix` track, the roadmap/readiness model, the
  backtracking/recall model, the declared-conflict check, or the merge-conflict
  contract.
- Re-opening, re-deriving, or rewriting already-approved or already-shipped
  items. The change is forward-only.
- Changing `visual.md`'s own severity findings except that when they flow into a
  review they are classified and gated under the same bar as any other finding.
- Guaranteeing a minimum count of findings, penalizing a review with none, or
  otherwise incentivizing invented findings. A clean review still approves.

## Users and stories

- **As a** framework maintainer, **I want** Minor and Nit review findings to send
  the item back for resolution, **so that** they are actually addressed instead
  of being silently backgrounded and merged over.
- **As an** author whose Minor or Nit I believe is wrong, **I want** to use the
  same challenge route available for a Blocker or Major, **so that** I am not
  forced to make a change I believe is incorrect and am not able to silently
  ignore it either.
- **As an** adopter, **I want** every surface that describes the review gate to
  state the same rule, **so that** the documented behavior and the actual
  lifecycle agree and no severity is quietly inert.
- **As a** maintainer, **I want** the gate to hold on re-review and through the
  challenge path, **so that** a Minor or Nit cannot reach `/ship` by another
  route.

## Acceptance criteria

1. **AC1** — Given a review in which at least one Minor or Nit finding survives
   scrutiny and no Blocker or Major survives, when the reviewer sets the verdict,
   then the verdict is `request-changes`.

2. **AC2** — Given a review, when the verdict is set, then it is `approve` if and
   only if **no finding of any severity** (Blocker, Major, Minor, or Nit)
   survives; any single surviving finding of any severity yields
   `request-changes`.

3. **AC3** — Given a `review.md` verdict of `request-changes` produced solely by
   Minor and/or Nit findings, when the item's next step is derived, then the item
   is reported as `build (rework)` and routes to `/build` — the same route used
   for Blocker/Major — and cannot advance to `/ship`.

4. **AC4** — Given a Minor or Nit that forced `request-changes`, when the builder
   addresses it and `/review` is re-run and it no longer survives, then the
   finding no longer counts and the verdict is recomputed under AC2 (so the item
   approves when no finding of any severity remains). Fixing is one valid
   resolution.

5. **AC5** — Given an author who disputes a Minor or Nit, when they raise it
   through the existing challenge/response loop and the producing phase sustains
   the challenge and overturns the finding, then the finding no longer counts and
   the verdict is recomputed under AC2; overturning is the other valid
   resolution. A rejected challenge leaves the finding standing and the verdict
   `request-changes`, and routes to `/build`.

6. **AC6** — Given a sustained challenge, when the reviewer recomputes the
   verdict, then the recompute uses the mixed-severity bar of AC2 — `approve` if
   and only if no finding of any severity remains — so a surviving Minor or Nit
   keeps the item at `request-changes` even after a challenge is sustained
   against a different finding. The prior Blocker/Major-only recompute is
   replaced.

7. **AC7** — Given a Minor or Nit finding, when the item is reviewed, then there
   is no path to `approve` that leaves it unresolved: it must be fixed or
   overturned. The author cannot unilaterally decline it, and the reviewer cannot
   approve over it ("never approve to be agreeable" extends to every severity).

8. **AC8** — Given the all-severity bar, when a maintainer or adopter consults
   any surface that states the review gate, then it states the same bar and none
   states that a Minor or Nit is non-blocking or optionally declinable without
   resolution. The surfaces that must agree are the reviewer agent prompt, the
   `/review` command, the `code-review` skill's severity and verdict definitions,
   the workflow authority's Review phase and challenge-adjudication sections, the
   review artifact conventions' severity meanings, and the `workflow-lifecycle`
   skill's routing. Any surface that today says a Minor is "not merge-blocking"
   or a Nit "the author may decline" is corrected.

9. **AC9** — Given an item whose `review.md` carries a surviving Minor or Nit and
   no Blocker or Major, when the item's phase is derived for status, then the
   item is reported `build (rework)` and the recommended next command is
   `/build`, never `/ship`; the existing `request-changes` → `build (rework)`
   literal and its route are unchanged.

10. **AC10** — Given the change, when the lifecycle vocabulary and artifacts are
    inspected, then the four severity labels and the `approve` /
    `request-changes` verdicts are unchanged, and no new severity, disposition
    state, marker, record type, command, agent, or skill is introduced. The
    finding format and the challenge/response record are unchanged.

11. **AC11** — Given an item that was already `approve`d or already shipped before
    the change, when the change lands, then its recorded verdict, phase, and
    shipped state are not rewritten or re-derived as blocked; the new bar governs
    only reviews performed after it lands.

12. **AC12** — Given the repository after the change, when the project's
    configured test command (`bash tests/run.sh`) runs, then it passes; the six
    core phase commands, their command→agent pairings, and every documented
    inventory count are unchanged.

## Edge cases

- **A review whose only findings are Nits.** It yields `request-changes` and
  routes to `/build`; this is the sharpest boundary of the change and must be
  explicit, not accidental.
- **A review with no findings.** It approves; the bar is "no surviving finding",
  not "at least one finding passed".
- **Only a Nit survives after rework.** The item still does not approve; it
  routes back until the Nit is fixed or overturned.
- **A sustained challenge overturns the last finding.** The verdict recomputes to
  `approve` and the item may proceed to `/ship`.
- **A sustained challenge adjusts severity but does not overturn.** A finding
  adjusted to Minor or Nit still blocks, because every severity blocks; only an
  overturn removes it.
- **A rejected challenge to a Minor or Nit.** The finding stands, the verdict
  stays `request-changes`, and the item routes to `/build`.
- **Both a fixed Minor and an unresolved Nit.** The verdict remains
  `request-changes`; resolution is per finding, not per item.
- **A question rather than a finding.** The reviewer's existing route for genuine
  uncertainty — raising a question instead of classifying a finding — remains and
  does not block; using it to dodge a real finding is not a finding of this
  change but must not be presented as a decline path.
- **Legacy `review.md` recorded before the change.** An item already carrying an
  `approve` verdict with listed Minor/Nit findings is not retroactively
  re-blocked (AC11); an item carrying `request-changes` is unchanged.
- **`visual.md` Minor/Nit findings.** When a visual finding flows into a review
  and is classified there, it is gated under the same bar as any other finding.
- **An open challenge on a Minor or Nit.** The item stays blocked (challenged)
  until the challenge is adjudicated or withdrawn, consistent with the existing
  challenge contract; the disposition then follows AC5.
- **Parallel items.** The change alters no other item's readiness and adds no
  cross-item state; it is prompt/doc/test only.

## Open questions

- [x] **Resolution bar for Minors/Nits** — resolved (user): full parity. Any
  surviving Minor or Nit forces `request-changes` and must be fixed or formally
  contested through the existing challenge loop; no silent or author-only
  decline, and the item ships only with zero open findings of any severity.
- [x] **Gate scope** — resolved (user): all review-derived gates, including the
  sustained-challenge verdict recompute, use the all-severity bar.
- [ ] **Deferred — exact surfaces and wording.** Which passages carry the bar and
  how they are phrased (for example whether the Minor/Nit severity definitions
  keep a "worth fixing" flavor and how the challenge recompute sentence is
  rewritten) is a design choice; the observable behavior above is fixed.
  — owner: architect, needed by: design.
- [ ] **Assumption — the question escape hatch is not a decline path.** The
  reviewer may still record genuine uncertainty as a question rather than a
  finding, and a question does not block; this is for real ambiguity, not for
  avoiding classification of a Minor or Nit. Confirm, or define a stricter rule.
  — owner: user, needed by: design.
- [ ] **Assumption — the challenge loop is reused unchanged.** A disputed Minor or
  Nit uses the existing `challenges.md` challenge/response/adjudication record
  with no new disposition entry. Confirm. — owner: user, needed by: design.

## Dependencies and constraints

- **Framework-internal change only.** Docs, agent prompts, command prompts,
  skills, and tests. No runtime dependency, service, or new toolchain.
- **Extend, do not fork.** The change reuses the existing severity scale and
  finding format (`.opencode/skill/code-review/SKILL.md`,
  `docs/artifact-conventions.md` → `review.md`), the `approve` /
  `request-changes` verdict, the `request-changes` → `build (rework)` derived
  state (`docs/workflow.md:1046`), and the challenge/response loop
  (`docs/workflow.md` → "Findings challenge and adjudication"). It adds no second
  severity, verdict, or rework mechanism.
- **The rule spans duplicated surfaces.** The Blocker/Major-only verdict is
  currently restated in the reviewer prompt (`.opencode/agent/reviewer.md:74-75,95-97`),
  the `/review` command (`.opencode/command/review.md:17-18`), the `code-review`
  skill (`.opencode/skill/code-review/SKILL.md:27-28,56,70-71`), the workflow
  authority's Review phase and challenge adjudication
  (`docs/workflow.md:393-396,997-999`),
  the review conventions (`docs/artifact-conventions.md:446-447`), and the
  `workflow-lifecycle` skill (`.opencode/skill/workflow-lifecycle/SKILL.md:38,69-70`).
  Every one must state the all-severity bar, which is why AC8 is a first-class
  criterion and not a formatting detail.
- **Committed suite constraints.** `tests/checks/20-lifecycle.sh:75-76` pins the
  routing literals `` `review.md` verdict `request-changes` `` and
  `` `review.md` verdict `approve`, no `ship.md` `` and the command→agent pairs;
  `tests/checks/40-inventory.sh` pins the README Layout counts and inventory
  tables; `tests/checks/96-signature-sweep.sh` pins command signatures and the
  workflow numbered headings. Those literals remain valid under this change and
  must stay green. The suite is read-only and never reads live `work/**`
  (`tests/README.md:29`); any new guard is fixture-based and is this item's own
  test-phase work.
- **Forward-only.** Already-approved or already-shipped items are not re-opened;
  there is no migration and no rewrite of historical `review.md` verdicts
  (AC11). A shipped item whose PR is later denied is handled by the existing
  recall path, not by this change.
- **No open backtrack.** `work/0008-minor-nit-resolution/backtracks.md` does not
  exist, so this spec is ordinary forward progression and records no finding and
  no resolution.
- **Possible surface overlap with the remaining unshipped sibling.**
  `0007-phase-backtracking/0007-backtracking-guards` is still unshipped and,
  when authored, may pin the review routing and challenge-recompute surfaces this
  item changes. This item is standalone; a declared conflict, if any, belongs to
  its `design.md` `conflicts-with` value and is advisory only. This item must not
  re-open or edit the shipped `0007` children.
- **Assumption — naming surfaces for testability.** Because the deliverable is
  the framework's own prompts and documents, the acceptance criteria name the
  surfaces that must carry the contract and cite the current rule; they specify
  required content and behavior, not design choices such as the exact rewritten
  wording.
