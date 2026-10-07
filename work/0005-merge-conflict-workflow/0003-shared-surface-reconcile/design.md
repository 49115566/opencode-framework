---
feature: 0005-merge-conflict-workflow/0003-shared-surface-reconcile
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc only; no new command, agent, skill, artifact format, committed check, or executable script. Resolves the spec's three deferred questions: (1) permission patterns and README-row wording — the shipper gains both path forms of the class (a) surfaces and `git merge*`, which moves its coarse edit class from work to tests+work, so the README Agents row moves with it; (2) the reconcile record is a distinct `## Reconcile` section in ship.md and the PR template, not a reuse of 0002's `## Conflict detection`; (3) exact git forms are fetch → merge-base → `git merge --no-edit origin/<default>` → conflict inspection → `git merge --abort` on escalation, with no rebase and push left ask. docs/workflow.md is deliberately left unchanged; the executable procedure lives in the merge-conflict skill and the shipper."
parent: 0005-merge-conflict-workflow
---

# Design — Reconcile workflow for shared framework surfaces

## Summary

Make the reconcile step the `0001` contract already specifies *executable*: encode
the ordered merge-forward procedure in `.opencode/skill/merge-conflict/SKILL.md`,
broaden the `shipper`'s declared permissions to perform it (bash `git merge*`; edit
the class (a) shared surfaces in both path forms), wire it into the shipper process
and `/ship`, and record the resolved paths and re-verification evidence in a new
`## Reconcile` section in `ship.md` and the PR description. No command, agent,
skill, artifact format, lifecycle phase, or committed check is added; the only
artifact-format change is the documented `ship.md` reconcile record.

## Approach

**The skill is the executable procedure; the shipper and `/ship` are the wiring.**
`0001-conflict-model` fixed the normative contract in `docs/workflow.md` →
`## Merge conflicts` and a `merge-conflict` skill; `0002-conflict-detection` added a
read-only pre-flight. The skill's `## Procedure` step 1 still says only "Merge the
default branch forward into the item branch (never rebase)"
(`.opencode/skill/merge-conflict/SKILL.md:143-151`) and names no command, and the
shipper's allowlist grants no `git merge` and its edit scope is `work/**` only
(`.opencode/agent/shipper.md:4-32`). This child rewrites that step into ordered,
agent-executable sub-steps and grants exactly the authority the skill needs.

**Ordered reconcile procedure (AC1, AC4, AC5, AC7, AC8, AC12).** The skill's
`## Procedure` step 1 becomes a self-contained sequence that consumes the pre-flight
that already ran:

1. **Determine and fetch.** Resolve the default branch and merge base as the
   pre-flight does; `git fetch <remote> <default>` (already allowed). If the default
   branch cannot be determined, report it and do not mutate the branch (edge case,
   inherited from `0002`).
2. **Already mid-merge?** If a merge is in progress at start
   (`git rev-parse -q --verify MERGE_HEAD`), report it and do **not** start a second
   merge (edge case).
3. **Up-to-date no-op.** If `git merge-base HEAD origin/<default>` equals
   `origin/<default>` (the default branch is already an ancestor of the item
   branch), report `no conflicts`, create **no merge commit**, do not error, and
   proceed to the remaining ship operations (AC12).
4. **Merge forward.** `git merge --no-edit origin/<default>`. Explicitly: **never
   rebase** a pushed branch and **never force-push** (AC1). A merge that completes
   without conflict markers has nothing to resolve, so it proceeds directly to
   step 8 — a clean merge is not evidence of correctness.
5. **Inspect and classify the conflict set.** List every unmerged path
   (`git status --short`, `git diff --name-only --diff-filter=U`) and classify it
   class (a) (shared framework surface) or class (b) (`work/` path) per the `0001`
   taxonomy. Report every path; the list is never truncated (edge case).
6. **Resolve.**
   - Class (a): edit the file to preserve **both** branches' changes, dropping
     neither side. `git checkout --ours/--theirs` and `git merge -X ours/theirs`
     are **not** used where both intents must be kept (AC4).
   - Class (b): preserve both branches' records (roadmap `Children` / `Depends on`
     rows and cells, artifact frontmatter, nested-child intersections).
   - Class (c) duplicate sequence numbers: apply the existing "Renumbering after a
     parallel merge" rule by hand (`git mv`, update the reference set); never invent
     a second rule. Automated renumbering and graph repair remain sibling `0004`
     (AC8).
   - Mechanical/structural conflicts that do not require choosing between competing
     intents are auto-resolved (AC5), subject to step 8.
   - **Semantic** conflicts — any resolution requiring a judgment between competing
     intents, including a delete/modify conflict or a binary file conflict — are
     **not** resolved: go to step 9 (AC7).
7. **Assert no markers remain (edge case).** Read each previously conflicted file
   and confirm none of `<<<<<<<`, `=======`, `>>>>>>>` remains. A file that still
   contains markers is unresolved: the merge must not be committed.
8. **Re-verify (AC6).** Run `bash tests/run.sh` and the affected item's checks.
   Both must be green before the resolved merge is committed, recorded, or shipped.
   A resolution whose re-verification fails is not accepted; report the failing
   check as the blocker.
9. **Stop and escalate (AC7).** On a semantic conflict, `git merge --abort` to
   restore a clean working tree, report the specific blocked path(s) and the
   decision the user must make, and keep the ship blocked until the user responds.
   Never commit, record, or ship a partial or unresolved merge. If the abort cannot
   complete, report that and stop rather than committing a partial merge.

Steps 2-7 of the existing `## Procedure` (re-verify, record, post-merge integrity
pass, stop-and-escalate) are retained in substance; step 1 is rewritten so detection
and mutation are separate and the resolve sequence is executable.

**Declared permissions (AC2, AC3, AC7).** Two frontmatter changes to
`.opencode/agent/shipper.md`:

- **bash** — add `"git merge*": allow`. This is the only new git write the reconcile
  needs: it covers `git merge --no-edit origin/<default>`, `git merge --continue`,
  and `git merge --abort`. Already allowed from `0002` and reused here:
  `git fetch*`, `git merge-base*`, `git status*`, `git diff*`, `git rev-parse*`,
  `git symbolic-ref*`. `"git push*"` stays `ask`; **no** `git rebase*` is added, so
  rebase remains impermissible and force-push remains confirmation-required through
  the global `opencode.json` `git push*: ask` baseline. `gh pr merge*` is not added,
  so merging a PR stays forbidden.
- **edit** — add both path forms of every class (a) surface the reconcile must
  resolve, keeping the existing `work/**` / `**/work/**`:

  | Surface | Patterns |
  | ------- | -------- |
  | root `README.md`, `AGENTS.md` | `README.md`, `**/README.md`, `AGENTS.md`, `**/AGENTS.md` |
  | `docs/*.md` | `docs/*.md`, `**/docs/*.md` |
  | `.opencode/{agent,command,skill}/**` | `.opencode/agent/**`, `.opencode/command/**`, `.opencode/skill/**`, `**/.opencode/agent/**`, `**/.opencode/command/**`, `**/.opencode/skill/**` |
  | `template/**` | `template/**`, `**/template/**` |
  | `tests/checks/**` | `tests/checks/**`, `**/tests/checks/**` |

  Both forms are declared because opencode passes tool paths relative *and* absolute
  (`docs/customization.md:178-189`), exactly as `work/**` + `**/work/**` already do.

**Permission-agreement consequence (AC3).** `tests/checks/30-permissions.sh:22-61`
derives a coarse edit class: any allowed pattern whose key matches
`test|spec|e2e|…` makes `hastest`, and `AGENTS.md`/`**/AGENTS.md` makes `hasconfig`;
with `work/**` present the class becomes `tests+work`
(`tests/checks/30-permissions.sh:55`). The shipper's coarse edit class therefore
moves from `work` to `tests+work`. The README Agents row's "Can edit" cell must move
with it: replace the shipper's `work/**` + `**/work/**` cell with one that names
`work/**` **and** a surface word containing the literal `test` (for example
`tests/checks`), so `readme_edit_class`
(`tests/checks/30-permissions.sh:137-152`) also yields `tests+work`. The "Can run
bash" cell stays `git/gh allowlist` (the bash class stays `git-gh`:
`tests/checks/30-permissions.sh:63-99`). `docs/customization.md` does not enumerate
the shipper's edit scope, so it needs no change.

**Record shape (AC9, AC10).** The reconcile is recorded as a **distinct**
`## Reconcile` section — not a reuse of `0002`'s `## Conflict detection`, because
detection records what *would* collide while reconcile records what *was* resolved
and the re-verification evidence, which is exactly what AC9 requires:

```markdown
## Reconcile

- Result: <reconciled | no-op (already up to date) | blocked: <reason>>
- Resolved paths:
  - `<path>` — <how both branches' intents were preserved>
- Re-verification: `bash tests/run.sh` → <result>; <item checks> → <result>
```

It is added to the `### `ship.md`` template in `docs/artifact-conventions.md`
(AC10) and to the work-item PR description template in
`.opencode/skill/pr-workflow/SKILL.md` (AC9). An up-to-date branch records
`Result: no-op (already up to date)` with empty resolved paths and the already-green
check evidence. Because readiness keys on `ship.md`'s **presence**, not its
contents (`docs/workflow.md` → "Dependencies and readiness"), this is additive and
changes no readiness rule.

**Shipper and `/ship` wiring (AC1, AC6, AC11).** The shipper's work-item
`<preconditions>` gains a reconcile precondition; `<process>` gains a reconcile
step immediately after the read-only pre-flight and before the other ship
operations, requiring re-verification before proceeding; `<rules>` states the
reconcile edit authority and restates never-rebase/never-force-push and
never-resolve-a-semantic-conflict; `<handoff>` gains a `Reconciled:` line (work-item
mode only, mirroring `0002`'s `Detected:` scoping). `.opencode/command/ship.md`
gains one work-item bullet placing reconcile after the pre-flight and before the
other ship operations. The command's usage string, the phase list, and the
guardrails never-merge-a-PR / never-force-push are untouched.

**Backward compatibility.** There is nothing to migrate. `.opencode/**` and
`docs/*.md` are shared verbatim with adopters (`README.md:69-70`), so they receive
the executable procedure, the broadened permissions, and the extended `ship.md`
template on their next copy. No `work/` artifact is rewritten; no frontmatter field,
phase, or state/readiness rule changes.

## Alternatives considered

- **New `/reconcile` command plus a `reconciler` agent.** Pros: a directly
  invocable reconcile surface with a dedicated owner. Cons: it contradicts the
  user-resolved policy fork and the `0001` ownership decision (reconcile is a step
  inside `/ship`, owned by the shipper); it adds a command and an agent, violating
  the spec non-goals and AC14, and forces edits to
  `.opencode/{command,agent}/`, `opencode.json`, the README Commands/Agents tables,
  and `tests/checks/40-inventory.sh` — enlarging exactly the shared surfaces that
  parallel branches already collide on. **Rejected.**
- **Resolve markers by taking one side (`git checkout --ours/--theirs`,
  `git merge -X ours/theirs`).** Pros: a one-command resolution for every conflicted
  file. Cons: it silently drops one branch's changes, directly violating AC4 and the
  `0001` "preserve both branches' intent; never drop one side" principle, and it
  removes the reviewer's ability to see both intents. **Rejected.**
- **Leave permissions unchanged and require the human to resolve conflicts.** Pros:
  no permission broadening; smallest diff. Cons: it leaves the exact gap the spec
  documents — the agent can detect but cannot act — failing AC1-AC3 and the
  `22d0b69` motivating case. **Rejected.**
- **Preserve the coarse `work` edit class by using non-literal patterns** (for
  example `**/checks/**` instead of `tests/checks/**`). Pros: the README row and
  permission check need no edit. Cons: it deliberately obscures the real capability,
  makes the grant narrower than AC3 names, and couples behavior to the check's
  substring heuristic. **Rejected** — declare the real surface and move the README
  row with it.
- **Fold the reconcile record into `0002`'s `## Conflict detection` section.**
  Pros: one section. Cons: detection and resolution are different facts recorded at
  different times; AC9 needs resolved paths plus re-verification evidence, which the
  detection result does not carry. **Rejected** — a distinct `## Reconcile` section.

## Interfaces and data model

No runtime interfaces or schemas change. The concrete contract is the required
content and configuration of each edited surface, so the builder and tester verify
by reading and by the committed suite.

### `.opencode/skill/merge-conflict/SKILL.md`

Rewrite `## Procedure` step 1 into the ordered sequence in "Approach", and keep the
remaining steps and `## Rules`. Required literals:

| Region | Required literal(s) |
| ------ | ------------------- |
| Ordering | `determine the default branch`; `merge base`; `git fetch`; `git merge --no-edit origin/<default>`; `merge the default branch forward`; `never rebase`; `never force-push` |
| Mode guards | in-progress merge reported, no second merge; up-to-date `no conflicts` `no-op`, `does not error`, `no merge commit` |
| Conflict set | `git diff --name-only --diff-filter=U`; report every conflicted path, `never truncated` |
| Resolve | preserve both branches' changes, `drop neither side`; class (a)/(b)/(c); class (c) defers to `Renumbering after a parallel merge`; `git mv`; automated renumbering is sibling `0004` |
| Marker check | `<<<<<<<`, `=======`, `>>>>>>>`; a file with markers is `unresolved`; do not commit it |
| Re-verify | `bash tests/run.sh`; the affected item's checks; `green` before committed/recorded/shipped |
| Escalate | `git merge --abort`; clean working tree; report blocked path(s) and the decision; `blocked until the user responds`; if abort fails, report and stop |
| Record | `## Reconcile`; resolved paths; re-verification evidence; `ship.md`; the PR description |

### `.opencode/agent/shipper.md`

- Frontmatter `permission.bash`: add `"git merge*": allow`. Keep `"git push*": ask`;
  add no `git rebase*`; add no `gh pr merge*`.
- Frontmatter `permission.edit`: add both path forms of the class (a) surfaces
  (the pattern table above: `README.md`, `AGENTS.md`, `docs/*.md`,
  `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`), keeping
  `"*": deny`, `work/**`, `**/work/**`.
- `<preconditions>` (work-item mode): add that the branch has been reconciled with
  the default branch (or an up-to-date no-op was reported) per the `merge-conflict`
  skill, and that a semantic conflict blocks the ship until the user responds.
- `<process>` (work-item mode): insert a reconcile step after the read-only
  pre-flight and before the other ship operations, containing the literals
  `Reconcile first`, `after the read-only pre-flight`, `before the other ship
  operations`, `git merge --no-edit`, `git merge --abort`, never rebase / never
  force-push, and re-run `bash tests/run.sh` and the item's checks; update the
  `ship.md` write step to include the `## Reconcile` section.
- `<rules>`: add the reconcile edit authority (class (a) surfaces + `work/**`),
  never rebase / never force-push, and never resolve a semantic conflict.
- `<handoff>`: add a `Reconciled:` line reporting resolved paths and re-verification,
  or `no conflicts` / `no-op`, or `blocked: <path>`; scope it to work-item mode
  (fix-landing mode omits it), as `0002` scoped `Detected:`.

### `.opencode/command/ship.md`

Add one work-item-mode bullet: reconcile first, after the read-only pre-flight and
before the other ship operations, per the `merge-conflict` skill; resolve class
(a)/(b) preserving both sides, apply the existing renumbering rule for class (c),
abort and escalate a semantic conflict, record the `## Reconcile` section in
`ship.md` and the PR, and never rebase / never force-push. No signature, usage
string, or phase change.

### `README.md`

Update the `shipper` Agents-table "Can edit" cell (line 218) from
`` `work/**` + `**/work/**` `` to a cell naming `work/**` and the class (a) surfaces
including `tests/checks`, so `readme_edit_class` yields `tests+work` and agrees with
the declaration. The "Can run bash" cell stays `git/gh allowlist`. No count changes.

### `docs/artifact-conventions.md`

Add a `## Reconcile` section to the `### `ship.md`` template (lines 397-413) with
the record shape above, documenting where resolved paths and re-verification
evidence belong. No other template heading changes.

### `.opencode/skill/pr-workflow/SKILL.md`

Add a `## Reconcile` section to the work-item PR description template (after the
existing `## Conflict detection` section, lines 43-47) with the same record shape.
The fix PR template is unchanged.

### Unchanged

`docs/workflow.md` (the normative `## Merge conflicts` contract is already correct
and is gated by `20-lifecycle.sh` / `96-signature-sweep.sh`); root and
`template/AGENTS.md`; `opencode.json`; `tests/**`; the phase list, derived-state
table, readiness/state models, and all artifact formats except the additive
`ship.md` reconcile record; `.opencode/` inventory counts.

## Affected areas

- `.opencode/skill/merge-conflict/SKILL.md` — `## Procedure` step 1 rewritten
  (lines 143-151); `## Rules` may gain the reconcile authority line (200-211).
- `.opencode/agent/shipper.md` — frontmatter `permission` (4-32); `<preconditions>`
  (80-112); `<process>` work-item mode (114-144); `<rules>` (166-179); `<handoff>`
  (181-193).
- `.opencode/command/ship.md` — work-item bullets (17-45).
- `README.md` — Agents table, shipper row (218).
- `docs/artifact-conventions.md` — `### `ship.md`` template (397-417).
- `.opencode/skill/pr-workflow/SKILL.md` — work-item PR description template
  (29-63).
- Read for context, not changed: `docs/workflow.md:340-410` (`## Merge conflicts`),
  `tests/checks/30-permissions.sh`, `tests/checks/40-inventory.sh`,
  `tests/checks/20-lifecycle.sh`, `tests/checks/96-signature-sweep.sh`,
  `tests/README.md:29`, `work/0005-merge-conflict-workflow/000{1,2}-*/**`.

## Risks and mitigations

- **Permission-agreement regression.** Broadening the shipper's edit scope moves its
  coarse class to `tests+work`, so a README row that still says `work` fails
  `tests/checks/30-permissions.sh` (AC3, AC13). Likelihood high / impact high.
  Mitigation: T2 changes the declaration and the README row in one commit and runs
  the suite; the T7 gate asserts `AC8 shipper: … edit=tests+work`.
- **Semantic conflict auto-resolved.** The agent could silently choose an intent
  instead of aborting (AC7). Likelihood medium / impact high. Mitigation: the skill
  names semantic conflicts, delete/modify, and binary conflicts as
  never-auto-resolved and requires `git merge --abort`; T1/T3/T6 assert the
  abort/escalate literals and the marker/unresolved rule.
- **Markers committed.** A resolved file could retain `<<<<<<<` markers. Likelihood
  medium / impact high. Mitigation: step 7 requires reading each file for the three
  marker literals and forbids committing a file that still contains them; asserted
  in T1.
- **Abort fails, leaving a dirty tree.** Likelihood low / impact high. Mitigation:
  the skill says report and stop rather than commit a partial merge; asserted in T1.
- **`git merge*` is broader than the one command.** Prefix matching also permits
  `git merge --abort`/`--continue` and a bare `git merge <x>`; opencode cannot
  distinguish them. Likelihood low / impact low. Mitigation: the skill names the
  exact forms and forbids rebase; no `git rebase*`/`git pull*` is granted.
- **Over-broad edit patterns.** The `**/…` forms grant a matching surface in any
  nested directory, not only the repository root. Likelihood low / impact low.
  Mitigation: each pattern names exactly a class (a) surface and both path forms
  are required for the grant to work at all; the residual is accepted and no broader
  `**/*.md` or `.opencode/**` grant is made.
- **Collision with sibling `0004`/`0005` on the same surfaces.** All three edit the
  `merge-conflict` skill, the shipper, and `/ship`. Likelihood high / impact medium.
  Mitigation: land in roadmap sequence (`0003` before `0004`); touch only the
  reconcile regions and leave `docs/workflow.md` untouched.
- **Stale sibling item suite.** `0001`'s `verify-tests.sh` asserts no agent edit and
  the fused detect step, both intentionally changed here. Likelihood high / impact
  low. Mitigation: expected drift like `0002`'s; the canonical `bash tests/run.sh`
  is the gate and stays green.

## Test strategy

The deliverable is prompt/config/document content, so the automatic level is
literal-presence assertions in an item-level read-only
`work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh`
(the `0001`/`0002` precedent), plus the canonical `bash tests/run.sh` for the
inventory, permission, lifecycle, and signature invariants. Where a behavior can be
exercised, the item suite adds a live probe: create a scratch git repo, branch the
default, make a conflicting shared-file edit, run the documented
fetch → `git merge --no-edit` → resolve → `git merge --abort` sequence, and assert
the merge applies/aborts with the working tree clean and no markers. No committed
check is added; committed merge-integrity guards are sibling `0005`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | content: skill + shipper process grep default branch, merge base, `git fetch`, `git merge --no-edit`, merge-forward, never-rebase, never-force-push |
| AC2 | content: shipper frontmatter greps `"git merge*": allow`; absence of `git rebase*`; `"git push*"` still `ask`; absence of `gh pr merge` |
| AC3 | integration + content: shipper frontmatter greps the class (a) patterns (both forms); README row greps `tests/checks`; `30-permissions.sh` green with `shipper … edit=tests+work` |
| AC4 | content: skill greps preserve both, drop neither, class (a); live probe resolves a shared-file conflict and asserts no `<<<<<<<`/`=======`/`>>>>>>>` remain |
| AC5 | content: skill greps mechanical/structural auto-resolve subject to re-verification |
| AC6 | content: skill + shipper grep `bash tests/run.sh` + item checks + green-before-record/ship |
| AC7 | content: skill greps semantic conflict, never resolve, `git merge --abort`, blocked paths, blocked until user responds; live probe asserts abort leaves a clean tree |
| AC8 | content: skill greps class (b) preserve both records, class (c) → `Renumbering after a parallel merge`, `git mv`, sibling `0004` |
| AC9 | content: `docs/artifact-conventions.md` and `pr-workflow` grep `## Reconcile`, resolved paths, re-verification |
| AC10 | content: `docs/artifact-conventions.md` `### `ship.md`` template carries the `## Reconcile` record |
| AC11 | content: shipper process + `/ship` grep reconcile first, after the read-only pre-flight, before the other ship operations; never-merge-a-PR / never-force-push retained |
| AC12 | content: skill greps up-to-date no-op, `no merge commit`, `does not error` |
| AC13 | integration: `bash tests/run.sh` exits 0, no `FAIL`, `30-permissions.sh` and `40-inventory.sh` green |
| AC14 | integration: counts 12/14/11, no new file, `docs/workflow.md` unchanged, artifact templates unchanged except the `ship.md` `## Reconcile` addition |

`bash tests/run.sh` is the project's canonical command (`AGENTS.md:17`) and is run
after every task; the tester re-runs it independently for AC13/AC14.
