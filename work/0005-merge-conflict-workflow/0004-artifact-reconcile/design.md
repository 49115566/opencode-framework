---
feature: 0005-merge-conflict-workflow/0004-artifact-reconcile
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc only; no new command, agent, skill, artifact format, committed check, or executable script. Resolves the spec's four deferred questions: (1) exact sub-steps and git forms are in 'Approach → The `work/` reconcile procedure', with an escalate-not-guess fallback when history is unavailable; (2) the `work/` reconcile is a distinct subsection inside the existing merge-conflict resolve step (not a new step beside it) that consumes the 0002 pre-flight findings and re-scans the merged tree; (3) the record shape is the existing 0003 `## Reconcile` record, a renumber written as a `Resolved paths` entry `<old> → <new> — <reason>`, so no artifact template changes; (4) no shipper permission change is needed — git mv*, git ls-tree*, git log*, git merge*, and work/** edits are already granted, so 30-permissions.sh stays green. docs/workflow.md, docs/artifact-conventions.md, pr-workflow, README, AGENTS.md, and tests/** are deliberately left unchanged."
parent: 0005-merge-conflict-workflow
---

# Design — Reconcile workflow for `work/` artifacts and sequence numbers

## Summary

Make the `work/`-specific reconcile executable as a distinct subsection of the
existing `merge-conflict` skill resolve step: merge colliding artifact content
(frontmatter, roadmap `Children` rows, `Depends on` cells) preserving both
branches' records, re-check the roadmap dependency graph (auto-repair structural
faults, escalate intent faults), detect top-level/per-parent and cross-branch
sequence-prefix collisions, apply the existing "Renumbering after a parallel
merge" rule to choose and `git mv` one item, and rewrite every reference in one
change. Wire it into the `shipper` process and `/ship`, record the resolved
`work/` paths and any renumber in the existing `## Reconcile` record, and escalate
an undecidable renumber or intent fault by aborting the merge. No new command,
agent, skill, artifact format, lifecycle phase, committed check, or executable
script is added, and no permission changes.

## Approach

**One operational procedure, inside the existing reconcile; the normative rule is
untouched.** `0001-conflict-model` fixed the contract in `docs/workflow.md` →
`## Merge conflicts` and a `merge-conflict` skill; `0002-conflict-detection` added
a read-only pre-flight that reports class (b)/(c) findings; `0003-shared-surface-reconcile`
made the class (a) reconcile executable and left an explicit deferral:
"automated renumbering and graph repair remain sibling `0004`"
(`.opencode/skill/merge-conflict/SKILL.md:179-188`). This child replaces that
deferral with the `work/`-specific procedure. The normative
"Renumbering after a parallel merge" text in `docs/artifact-conventions.md` stays
byte-identical (AC12); the new procedure references and applies it and defines no
second rule. `docs/workflow.md` is also unchanged — the contract already places
reconciliation in `/ship` and defers class (c) to the renumbering rule.

**The `work/` reconcile procedure (resolves the spec's placement and command-form
questions).** The skill gains a new subsection, ``### `work/` artifact reconcile``,
positioned within `## Procedure` step 1's resolve sequence — it runs **after the
conflict set is listed** (sub-step 5) and **before the re-verification sub-step**
(sub-step 8). It is a distinct subsection rather than a new top-level step so the
generic resolve/re-verify/escalate rules stay single-sourced (avoiding the `0003`
review [m1] duplication risk), and so it consumes the pre-flight that already ran.
Its ordered steps:

1. **Consume the pre-flight findings, then re-scan the merged tree.** Read the
   class (b)/(c) findings the read-only pre-flight handed over —
   `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `MISSING-CHILD`,
   `UNLISTED-CHILD`, `CYCLIC-DEP` (`.opencode/skill/merge-conflict/SKILL.md:109-121`).
   Because the pre-flight ran **before the merge**, re-scan the merged tree for the
   same codes after `git merge --no-edit`: the merge can introduce or expose a
   collision the pre-flight could not see. Every colliding prefix and every fault
   is reported; the list is never truncated (edge case, large collision set).

2. **Merge `work/` artifact content preserving both branches' records** (AC1, AC2).
   For a class (b) path:
   - **Roadmap `Children` rows** — take the union of both branches' rows. A local
     id added by one branch survives; a row that both branches added **identically**
     is de-duplicated to one.
   - **`Depends on` cells** — take the union of the dependencies; never silently
     discard a branch's dependency. A dependency listed twice is collapsed to one.
   - **Artifact frontmatter** — merge field-by-field. Identical or single-sided
     fields keep their value; the mechanical reference fields (`feature`, `parent`)
     are handled by the renumber sweep below. A scalar field on which the two
     branches genuinely disagree, or a duplicate `Children` row whose
     title/scope/intent differs, is a **judgment about intent** → step 7
     (escalate), never a silent pick.
   The rule is absolute: `preserve both branches' records`, `drop neither side`.

3. **Re-check the roadmap dependency graph** (AC3). For every `roadmap.md`, verify
   that each `Depends on` local id `resolves to an existing row and child directory`
   and that the stored graph is `acyclic`; classify each fault as a
   `structural fault` (auto-repair) or a `judgment about intent` (escalate):
   - **Structural, auto-repaired mechanically:** a `Depends on` cell (or a
     `Local id` / `Canonical reference` / `feature` / `parent` value) left stale by
     this reconcile's own renumber — updated to the new local id/number as part of
     the reference sweep (AC6); a `Children` row duplicated because both branches
     added the identical row — keep one; a duplicated dependency entry — collapse;
     a `MISSING-CHILD` whose directory was renamed by this reconcile so the intent
     is unambiguous — resolved by the same reference sweep.
   - **Intent, escalated (step 7):** a dangling dependency whose correct target is
     **ambiguous**; a `cycle` (cannot be mechanically broken); a
     `deliberately removed child`; an `unlisted child` whose row must be restored
     and whose title/scope/intent would have to be chosen; a duplicate local id
     with differing content; two branches that renumbered the same item
     differently.

4. **Detect sequence-prefix collisions** (AC4). After the merge, detect equal
   top-level 4-digit `NNNN` prefixes and equal per-parent `MMMM` prefixes across
   the merged tree, **including a collision that exists only between the item
   branch and the default branch** — compare the local `work/` names with
   `git ls-tree --name-only origin/<default>:work` and, for each roadmap parent,
   `git ls-tree --name-only origin/<default>:work/<parent>`. Report each collision
   with its `canonical reference(s)`; if two directories share a prefix under
   different slugs, that is a class (c) collision too.

5. **Choose the item to renumber, applying the existing rule** (AC5). Apply
   "Renumbering after a parallel merge" verbatim: renumber the item that is
   `not yet approved or shipped` (shipped signal = presence of `work/<ref>/ship.md`;
   approved = `review.md` verdict `approve`); if both are unshipped, renumber the
   one whose directory was `added later by commit time`
   (`git log --diff-filter=A --format=%ct -- work/<ref>`, comparing the added
   commit times); break a tie by `slug order`. Allocate the `next number` from the
   existing sequence-allocation contract
   (`docs/artifact-conventions.md:426-443`): the greatest 4-digit prefix that has
   **ever** appeared in the committed `work/` history plus one. A number is
   `never reuse`d, even if its directory was deleted — allocate the next free
   number instead.

6. **Move the chosen item and rewrite every reference in the same change** (AC6):
   `git mv work/<old> work/<new>`, and in the same change update — the directory
   name; the artifact `feature` frontmatter; a nested child's `parent` value; the
   roadmap `Children` table's `Local id` and `Canonical reference` cells for the
   renumbered row; every `Depends on` cell that names the old local id; the
   `ship.md` record and the PR/handoff paths; and any `prose` naming the old
   reference. Assert that `no reference to the old canonical reference remains`
   (a repository-wide scan for the old canonical reference).

7. **Undecidable or intent-dependent → escalate** (AC7, AC8). Do **not** guess.
   Escalate an undecidable renumber — `both are already shipped`, or each item's
   approval/shipped state `cannot be determined`, or git history is `unavailable`
   (for example a shallow clone) so "added later" cannot be established, or the
   two branches propose `two different new numbers` for one item. Escalate an
   intent fault from step 2/3. Escalation is the generic step 7: `git merge --abort`
   to restore a clean working tree, report the specific blocked reference(s) and
   the decision the user must make, and stay `blocked until the user responds`
   (AC8).

8. **Hand back to re-verification, then record** (AC9, AC10). After any `work/`
   resolution, re-run `bash tests/run.sh` and `the affected item's checks`; both
   must be `green` before the resolved merge is committed, recorded, or shipped.
   Record the `work/` paths resolved and any renumber in the existing `## Reconcile`
   record of `ship.md` and the `pull-request` description (see "Record shape").

**No-op (AC11).** When the branch is already up to date and there is no
`work/` sequence collision between the branches and no graph fault, the procedure
reports `no conflicts`, performs `no renumber` and `no move`, `does not error`,
and creates no merge commit. This is the resolve-sequence up-to-date no-op already
present (`.opencode/skill/merge-conflict/SKILL.md:161-165`) extended to the
`work/` scan.

**Record shape (resolves the spec's record-shape question).** No artifact format
changes: the renumber is recorded *inside the existing* `## Reconcile` record that
sibling `0003` added (`docs/artifact-conventions.md:414-419`;
`.opencode/skill/pr-workflow/SKILL.md:49-54`), as a `Resolved paths` entry of the form
`<old canonical reference> → <new canonical reference> — renumbered: <reason (not shipped / added later / slug order)>; feature/parent frontmatter, Children Local id/Canonical reference, Depends on cells, and ship.md/PR paths updated`.
This satisfies AC10 (the resolved `work/` paths, the renumber(s) chosen, and the
re-verification evidence are all present) while leaving the record's shape,
`Result` vocabulary, and readiness (which keys on `ship.md` presence, not contents)
untouched (AC14).

**Shipper and `/ship` wiring (AC1, AC11).** The shipper's `<preconditions>`
work-item reconcile clause is extended to name a `work/` sequence collision or
graph fault as resolved-or-escalated. `<process>` step 2 is expanded from the
generic "apply the existing renumbering rule" to run the `work/` artifact
reconcile per the skill. `<rules>` gains the reference-sweep authority and the
never-reuse-a-spent-number / never-resolve-a-cycle-or-undecidable-renumber
constraint. `<handoff>`'s existing `Reconciled:` line reports any renumbered
reference. `.opencode/command/ship.md`'s reconcile bullet is expanded with the
same mechanics. The `never merge a PR` / `never force-push` guardrails are
unchanged.

**Permissions: no change required (resolves the spec's permission question).** The
procedure's commands are all already granted to the shipper
(`.opencode/agent/shipper.md:25-52`): `git mv*` (`:42`), `git ls-tree*` (`:41`,
from `0002`), `git log*` (`:29`), `git merge*` (`:39`, from `0003`), `git status*`
/ `git diff*` / `git rev-parse*` / `git merge-base*` / `git symbolic-ref*`
(`:27-37`), `bash tests/run.sh*` and both item-check forms (`:49-51`), plus edit
`work/**` / `**/work/**` (`:7-8`) and the class (a) surfaces (`:9-24`). No
frontmatter change is made, so the documented-vs-declared permission agreement
(`tests/checks/30-permissions.sh`) stays green and the agent remains
`edit=tests+work bash=git-gh`.

**Backward compatibility.** There is nothing to migrate. `.opencode/**` is copied
verbatim to adopters, so they receive the procedure on their next copy. No `work/`
artifact is rewritten, and no frontmatter field, phase, derived-state rule, or
readiness rule changes (AC14). `docs/artifact-conventions.md` — including the
normative renumbering text — is unchanged (AC12).

## Alternatives considered

- **An executable reconcile script** (a helper under `tests/` or `work/`). Pros: a
  deterministic, reusable, machine-parseable renumber. Cons: an explicit spec
  non-goal and the user-resolved delivery fork (a documented, agent-executable
  procedure); the committed suite is read-only and never reads `work/**`
  (`tests/README.md:29`), so it cannot live there and still operate on the live
  tree; it adds a maintenance surface and a provider dependency the prompt-only
  model does not have. **Rejected.**
- **A new `/reconcile` command plus a `reconciler` agent, or a new skill.** Pros:
  a directly invocable surface with a dedicated owner. Cons: contradicts the
  `0001` ownership decision (reconcile is a step inside `/ship`, owned by the
  shipper) and the spec non-goals; adds an inventory entry and forces edits to
  `.opencode/{command,agent}/`, `opencode.json`, the README tables, and
  `tests/checks/40-inventory.sh` — enlarging exactly the shared surfaces this
  initiative exists to reconcile. **Rejected.**
- **Extend the normative "Renumbering after a parallel merge" text** with the
  `Local id`/`Depends on` cells and the detection/choice automation. Pros: one
  authoritative surface for the whole rule. Cons: the spec keeps that text
  unchanged and forbids a second rule (AC12); AC6's `Local id`/`Depends on`
  additions are *applications* of its "update every reference" step, and the
  automation is operational detail that belongs in the shipper's skill.
  **Rejected.**
- **A new `## Renumbered` artifact record or a new field in `## Reconcile`.**
  Pros: an explicit, machine-readable renumber record. Cons: AC14 says the only
  artifact-record change is the additive reconcile record already defined by
  `0003`; a new field/section is an artifact-format change and a new
  derived-agreement surface. **Rejected** — record the renumber as a `Resolved
  paths` entry in the existing record.
- **Fold the `work/` mechanics into the existing resolve sub-step inline** rather
  than a named subsection. Pros: no new skill section. Cons: the resolve sub-step
  already carries class (a)/(b) generic rules; inlining a long class (c)/graph
  procedure there makes the ordering unverifiable and duplicates re-verify/escalate
  rules (the `0003` review [m1] risk). **Rejected** — a named subsection the
  resolve step references.

## Interfaces and data model

No runtime interfaces or schemas change. The concrete contract is the required
content of each edited surface, so the builder and tester verify by reading and by
the committed suite.

### `.opencode/skill/merge-conflict/SKILL.md`

Add the ``### `work/` artifact reconcile`` subsection after the `## Procedure`
step-1 sequence (currently ends at `:206`) and rewire the generic steps to
reference it. Replace the sibling `0004` deferral at `:179-188`. Required
literals:

| Region | Required literal(s) |
| ------ | ------------------- |
| Placement | ``### `work/` artifact reconcile``; runs `after the conflict set is listed` and `before the re-verification`; consumes the pre-flight findings; `the pre-flight ran before the merge` → `re-scan the merged tree` |
| Codes consumed | `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, `CYCLIC-DEP` |
| Content merge (AC1, AC2) | `preserve both branches' records`; `drop neither side`; `artifact frontmatter`; roadmap `Children` rows; `Depends on` cells; `never silently discard a branch's dependency`; union of rows/dependencies; identical duplicate row → keep one; differing scalar frontmatter / differing duplicate row → `judgment about intent` |
| Graph re-check (AC3) | every `Depends on` local id `resolves to an existing row and child directory`; `acyclic`; `structural fault` (auto-repaired); `judgment about intent` (escalated); `MISSING-CHILD` / `UNLISTED-CHILD` / `DANGLING-DEP` / `Cyclic` named |
| Structural repairs | stale `feature` / `parent` / `Local id` / `Canonical reference` / `Depends on` updated by the renumber sweep; identical duplicate row collapsed; duplicated dependency collapsed |
| Collision detect (AC4) | equal top-level 4-digit `NNNN`; equal per-parent `MMMM`; cross-branch `git ls-tree --name-only origin/<default>:work`; report each with its `canonical reference(s)`; every colliding prefix reported, `never truncated` |
| Choose (AC5) | `not yet approved or shipped`; `approved` = `review.md` verdict `approve`; shipped = `ship.md`; `added later by commit time`; `git log --diff-filter=A`; `slug order`; `next number` from the allocation contract; `never reuse` a spent number |
| Move/rewrite (AC6) | `git mv work/<old> work/<new>`; `feature` frontmatter; nested child's `parent`; `Children` `Local id` and `Canonical reference`; every `Depends on` cell naming the old local id; `ship.md` and PR/handoff paths; any `prose` naming the old reference; `no reference to the old canonical reference remains`; `in the same change` |
| No-op (AC11) | no collision and no graph fault → `no conflicts`; `no renumber`; `no move`; `does not error` |
| Escalate (AC7, AC8) | undecidable: `both are already shipped`; state `cannot be determined`; history `unavailable` / `shallow clone`; `two different new numbers`; intent: ambiguous dangling target, `cycle`, `deliberately removed child`, `unlisted child` needing title/scope; `git merge --abort`; report blocked reference(s) and the decision; `blocked until the user responds` |
| Re-verify/record (AC9, AC10) | `bash tests/run.sh`; `the affected item's checks`; `green` before committed/recorded/shipped; `## Reconcile`; renumber as a `Resolved paths` entry `<old> → <new>`; `pull-request` |
| No second rule (AC12) | `Renumbering after a parallel merge`; `never defines a second renumbering rule` |

The existing pre-flight, generic resolve/re-verify/record/post-merge/escalate steps,
and `## Rules` are retained in substance so the `0001` procedure is not forked.

### `.opencode/agent/shipper.md`

- Frontmatter `permission`: **unchanged**. `git mv*`, `git ls-tree*`, `git log*`,
  `git merge*`, `work/**`, and the class (a) surfaces already cover every command
  the procedure runs; no new grant and no guardrail change.
- `<preconditions>` (work-item mode, `:114-116`): extend the reconcile clause so a
  `work/` sequence collision or roadmap graph fault is resolved or escalated, not
  shipped unresolved.
- `<process>` (work-item mode, step 2, `:149-161`): expand the class (c) sentence
  to run the `work/` artifact reconcile per the `merge-conflict` skill — merge
  `work/` content preserving both records; re-check the roadmap graph; detect
  top-level, per-parent, and cross-branch collisions; choose and `git mv` per the
  existing rule; rewrite every reference in one change; and escalate an undecidable
  renumber or intent fault by aborting rather than guessing.
- `<rules>` (`:211-215`): add the reference-sweep authority (a renumber updates
  frontmatter, `Children` `Local id`/`Canonical reference`, `Depends on` cells,
  `ship.md`/PR paths, and prose), `never reuse` a spent number, and never resolve a
  cycle or an undecidable renumber — abort and escalate.
- `<handoff>` (`:230-231`): the `Reconciled:` line reports any renumbered reference
  (`<old> → <new>`); work-item mode only, as today.

### `.opencode/command/ship.md`

Expand the work-item reconcile bullet (`:32-39`) with the `work/`-specific
mechanics: merge `work/` artifact content preserving both sides, re-check the
roadmap graph, apply the existing "Renumbering after a parallel merge" rule to a
top-level/per-parent number collision, update every reference in one change,
escalate an undecidable renumber or intent fault, and record the result in the
`## Reconcile` section of `ship.md` and the PR. No signature, usage string, phase
heading, or closing guardrail changes.

### Unchanged (explicit)

`docs/workflow.md` (normative contract already correct); `docs/artifact-conventions.md`
(the normative "Renumbering after a parallel merge" text stays byte-identical, and
no template changes — AC12, AC14); `.opencode/skill/pr-workflow/SKILL.md` (the
existing `## Reconcile` section already carries `Resolved paths`, which hold the
renumber entries); `README.md`; `AGENTS.md` / `template/AGENTS.md`; `opencode.json`;
`tests/**`; the shipper permission frontmatter; every artifact format, lifecycle
phase, derived-state rule, and inventory count.

## Affected areas

- `.opencode/skill/merge-conflict/SKILL.md` — add the ``### `work/` artifact reconcile``
  subsection; rewire the resolve sub-step 6 and record step 5;
  replace the sibling `0004` deferral (`:179-188`).
- `.opencode/agent/shipper.md` — preconditions (`:114-116`), process step 2
  (`:149-161`), rules (`:211-215`), handoff (`:230-231`). No frontmatter change.
- `.opencode/command/ship.md` — work-item reconcile bullet (`:32-39`).
- Read for context, not changed: `docs/workflow.md:337-397` (`## Merge
  conflicts`), `docs/artifact-conventions.md:426-476` (sequence allocation +
  renumbering), `tests/checks/30-permissions.sh`, `tests/checks/40-inventory.sh`,
  `tests/checks/80-cycle-fixture.sh`, `tests/README.md:29`,
  `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh:236-271`
  (the single-scenario fixture this child generalizes), and
  `work/0005-merge-conflict-workflow/000{1,2,3}-*/**`.

## Risks and mitigations

- **A renumber misses a reference, leaving a dangling reference.** Likelihood
  medium / impact high. Mitigation: step 6 enumerates the full reference set and
  requires `no reference to the old canonical reference remains`, asserted by a
  repository scan; the item suite's live probe renumbers a two-branch collision and
  greps for the old reference (AC6).
- **Structural vs intent misclassification silently drops a record.** Likelihood
  medium / impact high. Mitigation: step 3 gives an explicit structural list
  (renumber-sweep staleness, identical duplicate row, duplicated dependency) and
  routes everything else — ambiguous target, cycle, removed child, unlisted child,
  differing row, differing scalar — to escalate (AC3, AC8).
- **Rule/skill drift or duplication with `0003`.** Likelihood medium / impact
  medium. Mitigation: a distinct subsection that references the generic
  resolve/re-verify/escalate steps instead of restating them; land after `0003`
  (already shipped) and touch only the `work/` regions.
- **A spent number is reused.** Likelihood low / impact high. Mitigation: allocate
  from the ever-committed history plus one and never the deleted number; the item
  suite's live probe includes a deleted-number fixture (AC5).
- **History unavailable (shallow clone) makes the choice undecidable.** Likelihood
  medium / impact medium. Mitigation: escalate rather than guess; the choice order
  falls back to slug order only when both are unshipped and commit time cannot be
  compared, and escalates when even that cannot distinguish (AC7, AC8).
- **An unintended artifact-format or permission change.** Likelihood low / impact
  high. Mitigation: no frontmatter and no `docs/artifact-conventions.md` change;
  the gate asserts the renumbering text and `docs/workflow.md` are byte-identical,
  counts are 12/14/11, and `30-permissions.sh` reports
  `edit=tests+work bash=git-gh` (AC13, AC14).
- **Collision with sibling `0005` on the same surfaces.** Likelihood medium /
  impact medium. Mitigation: `0005` adds committed `tests/**` guards only; this
  child edits the skill, shipper, and `/ship` and leaves `tests/**` untouched, so
  the two do not overlap.
- **Stale sibling item suites.** `0001`/`0002`/`0003` item-level `verify-tests.sh`
  snapshots constrain surfaces this child intentionally edits. Likelihood high /
  impact low. Mitigation: expected drift, as `0002`/`0003` already recorded; the
  canonical `bash tests/run.sh` is the gate and stays green.

## Test strategy

The deliverable is prompt/config/document content, so the automatic level is
literal-presence assertions in an item-level read-only
`work/0005-merge-conflict-workflow/0004-artifact-reconcile/verify-tests.sh` (the
`0001`/`0002`/`0003` precedent) plus the canonical `bash tests/run.sh` for the
inventory, permission, lifecycle, and signature invariants. Where behavior can be
exercised, the item suite adds live probes in scratch git repos: (i) two branches
each allocate the same `NNNN`, merge, apply the documented detect → choose →
`git mv` → reference-sweep sequence, and assert no duplicate prefix remains and no
old reference survives; (ii) a roadmap `Children`/`Depends on` merge that unions
both branches' rows and a graph re-check; (iii) a structural renumber-sweep repair
versus an ambiguous dangling dependency that must abort; (iv) the up-to-date no-op.
No committed check is added; committed merge-integrity guards are sibling `0005`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | content: skill greps the ordered `work/` reconcile subsection and the content-merge literals (frontmatter, `Children` rows, `Depends on` cells, preserve both, drop neither) |
| AC2 | content + live probe: skill greps the `Children` union and no-discard rule; probe unions two branches' rows and asserts both survive |
| AC3 | content + live probe: skill greps graph re-check, structural repair, intent escalate; probe asserts a sweep repair resolves and an ambiguous dangling dep aborts |
| AC4 | content: skill greps top-level `NNNN`, per-parent `MMMM`, cross-branch `git ls-tree origin/<default>:work`, canonical reference(s), never truncated |
| AC5 | content + live probe: skill greps the choice order and allocation/never-reuse; probe renumbers a two-branch collision and a deleted-number case |
| AC6 | content + live probe: skill greps the full reference set and `no reference to the old canonical reference remains`; probe greps for the old reference after the sweep |
| AC7 | content: skill greps both-shipped, cannot-be-determined, shallow clone, two-different-new-numbers, and never-guess |
| AC8 | content + live probe: skill/shipper grep `git merge --abort`, blocked reference(s), decision, blocked until the user responds; probe asserts abort leaves a clean tree |
| AC9 | content: skill greps `bash tests/run.sh` + item checks + green-before-committed/recorded/shipped |
| AC10 | content: skill/shipper grep the `## Reconcile` record and the `<old> → <new>` renumber notation in `ship.md` and the PR |
| AC11 | content + live probe: skill/shipper/`/ship` grep the no-conflict no-op (`no renumber`, `no move`, `does not error`); probe asserts an up-to-date merge creates no commit |
| AC12 | content + integration: skill greps `Renumbering after a parallel merge` and `never defines a second renumbering rule`; `git diff --quiet` over the section |
| AC13 | integration: `bash tests/run.sh` exits 0, no `FAIL`, `30-permissions.sh` and `40-inventory.sh` green |
| AC14 | integration: counts 12/14/11, no new command/agent/skill/executable, `docs/workflow.md` and every artifact template unchanged, permission frontmatter unchanged |

`bash tests/run.sh` is the project's canonical command (`AGENTS.md:17`) and is run
after every task; the tester re-runs it independently for AC13/AC14.
