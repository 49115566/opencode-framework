---
feature: 0005-merge-conflict-workflow/0002-conflict-detection
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc only; no executable detection script and no new committed check (deferred to sibling 0005-merge-integrity-guards). Resolves the spec's two deferred questions: (1) finding vocabulary is DUPLICATE-PREFIX, DUPLICATE-CHILD, DRIFT-FACT (plus TEXTUAL-CONFLICT for the dry-run probe), each carrying its 0001 class label; (2) the pre-flight is a distinct read-only step ahead of the 0001 reconcile, not a read-only variant of the fused detect+merge step. docs/workflow.md is deliberately left unchanged."
parent: 0005-merge-conflict-workflow
---

# Design — Pre-flight conflict detection and classification

## Summary

Deliver detection as prompt and skill content only: the `merge-conflict` skill
gains a distinct **read-only pre-flight** that determines the merge base,
`git fetch`es, lists the paths each branch changed, runs a non-applying dry-run
merge probe (`git merge-tree`) and classifies each conflicting path as class (a)
or (b); the same skill gains **framework-integrity checks** for duplicate
sequence prefixes, roadmap graph faults, and duplicated-fact drift. The
`shipper` agent and `/ship` command wire the pre-flight in as a precondition
before any ship operation and record its result; the `status` agent and
`/status` command add the offline integrity findings; `pr-workflow` gains a
`## Conflict detection` PR section. The shipper's bash allowlist gains only
`git fetch*`, `git merge-tree*`, and `git ls-tree*`; no new command, agent,
artifact format, or committed check is added.

## Approach

**Delivery form — content, not code (resolves a spec fork).** The capability is
prose plus configuration, because the spec forbids an executable detection script
and the committed suite is read-only and never reads `work/**`
(`tests/README.md:29`). Verification therefore follows the `0001-conflict-model`
precedent: an item-level read-only `work/<item-ref>/verify-tests.sh` asserts the
required literals, while `bash tests/run.sh` covers the inventory, permission, and
lifecycle invariants. Committed merge-integrity guards are sibling `0005`.

**Two homes, one vocabulary.** The `merge-conflict` skill is the operational home
for the pre-flight (it is the shipper's procedure and is only loaded when
reconciling); the `status` agent is the operational home for the offline,
local-only integrity scan it already performs. Both consume the taxonomy already
fixed in `docs/workflow.md` → `## Merge conflicts` (`:337-398`) and define no
second policy. To prevent vocabulary drift, the finding grammar and the new codes
are specified once in this design and duplicated verbatim into both surfaces
(Risk R1).

**Pre-flight as a distinct read-only step (resolves a spec fork).** The `0001`
skill fuses detection with the merge in its step 1 ("Compare … Merge the default
branch forward"). This child splits that into an explicit, reportable,
**read-only** pre-flight ahead of any ship operation, then leaves the existing
resolve/re-verify/record/post-merge/escalate procedure intact. A distinct step is
required to make AC1 (no mutation), AC5 (runs *before* any ship operation), AC11
(up-to-date no-op), and AC12 (result recorded) observable rather than implicit.

**Read-only git, minimal permission delta.** Detection runs:

| Step | Command | Permission |
| ---- | ------- | ---------- |
| Default branch | `git symbolic-ref refs/remotes/origin/HEAD` or `gh repo view --json defaultBranchRef` | already allowed |
| Fetch remote-tracking refs | `git fetch <remote> <branch>` | **new `git fetch*`: allow** |
| Merge base | `git merge-base HEAD origin/<default>` | `git merge-base*`: already allowed |
| Per-side changed paths | `git diff --name-only <base>..HEAD` / `<base>..origin/<default>` | `git diff*`: already allowed |
| Dry-run merge probe | `git merge-tree --write-tree --name-only HEAD origin/<default>` | **new `git merge-tree*`: allow** |
| Default-branch `work/` listing | `git ls-tree --name-only origin/<default>:work` | **new `git ls-tree*`: allow** |

`git fetch` updates remote-tracking refs only — the `0001` contract already
sanctions it for reconcile (`docs/workflow.md:356-359`); `git merge-tree
--write-tree` writes no ref and no working-tree file (it may leave an unreachable
object), and `git ls-tree` is pure read. `git rebase*` stays absent and
`git push*` stays `ask`, so the never-rebase/never-force-push guardrails are
unchanged (AC7). The three additions are all inside the existing coarse
`git-gh` bash class (`tests/checks/30-permissions.sh:64-99`), so the README
Agents row and the permission-agreement check are untouched (AC13).

**Textual probe and classification (AC2).** `git merge-tree --write-tree
--name-only` prints the conflicted pathnames without applying anything to the
working tree. Each path is classified by surface: a shared framework file
(`README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`,
`template/**`, `tests/checks/**`) is class (a); a `work/**` path is class (b).
The probe is scoped by intersecting the conflicted set with the per-side changed
paths, so every reported path is genuinely a path both branches changed. Older
git without `--write-tree` falls back to the three-argument
`git merge-tree <base> <branch1> <branch2>`; if neither form is usable, the
textual comparison is reported as **skipped with its reason**, never run on a
stale base.

**Framework-integrity checks (AC3), local and cross-branch.** Two layers:

- *Local (skill pre-flight and `/status`)* — inspect the on-disk `work/` tree:
  duplicate top-level `NNNN` prefixes; duplicate per-parent `MMMM` numbers; each
  roadmap row's `Depends on` resolved against its `Children` table
  (dangling/missing/unlisted/cyclic); and the duplicated inventory/count facts —
  README Layout counts (`# N role prompts|slash commands|knowledge skills`) and
  the README Skills table membership against the on-disk `.opencode/`
  agent/command/skill sets.
- *Cross-branch (skill pre-flight only)* — a class (c) collision is inherently
  cross-branch: two branches can each add a distinct directory under the same
  `NNNN`. The pre-flight therefore compares the local `work/` directory names
  with `git ls-tree --name-only origin/<default>:work` (and per-parent for
  roadmap children) and reports a collision when a 4-digit prefix is shared by
  two *different* canonical references. `/status` stays offline and does not do
  this cross-branch read (AC9).

**Finding grammar and vocabulary (AC4, AC8, AC10).** Each finding is one line:

```
- [<CODE>] (<class>) <offender canonical reference(s)> — <specific detail>
```

with `<class>` one of `(a) (b) (c) (d)` and `<CODE>` from:

| Code | Class | Meaning / offender |
| ---- | ----- | ------------------ |
| `TEXTUAL-CONFLICT` | `(a)` or `(b)` | dry-run merge would leave markers on a path; offender is the path |
| `DANGLING-DEP` | `(b)` | `Depends on` names a local id with no directory or row |
| `MISSING-CHILD` | `(b)` | a Children-table row whose directory is absent |
| `UNLISTED-CHILD` | `(b)` | a child directory absent from the Children table |
| `CYCLIC-DEP` | `(b)` | a cycle in a dependency graph |
| `DUPLICATE-PREFIX` | `(c)` | two different top-level `work/` refs share an `NNNN` |
| `DUPLICATE-CHILD` | `(c)` | two different per-parent child refs share an `MMMM` |
| `DRIFT-FACT` | `(d)` | a duplicated count/table fact disagrees with disk or the other branch |

The existing four graph codes gain the `(b)` class annotation the taxonomy already
implies; that annotation is required so AC4's "every finding carries a class
label" holds uniformly. Textual conflicts use `TEXTUAL-CONFLICT` with class (a) or
(b); `TEXTUAL-CONFLICT` is pre-flight-only (status performs no dry-run merge).
Every finding names the offending path or canonical reference(s) and the detail;
none is silently dropped and the path list is never truncated (AC4, AC10).

**`/status` stays offline (AC8, AC9).** The status agent gains a read-only
consistency read of README.md's Layout counts and Skills table against the
on-disk `.opencode/` sets and emits `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, and
`DRIFT-FACT` alongside its existing findings. It uses only local inspection, adds
no bash permission (its `ls*`/`cat*`/`git diff|log|show` allowlist already
suffices), performs no fetch and no dry-run merge, takes no lock, and modifies no
file. This is the spec's sanctioned read-only scope extension
(`spec.md` → "Dependencies and constraints").

**Lifecycle wiring, not phase change.** The `shipper` preconditions and
`/ship` work-item process gain a pre-flight bullet before any ship operation; a
semantic finding is handed to the `0001` reconcile step, which escalates to the
user (AC5, AC6). The detection result — classes and paths, or an explicit "no
conflicts detected" — is recorded in the ship handoff (`Detected:` line) and the
PR description via a `## Conflict detection` section in the `pr-workflow` template
(AC12). Nothing in `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`,
`template/**`, `README.md`, `opencode.json`, or `tests/**` changes (AC14).

**Backward compatibility.** There is nothing to migrate. `.opencode/**` is copied
verbatim to adopters, so they receive the detection procedure on their next copy;
no `work/` artifact, frontmatter field, phase, or state/readiness rule changes.

## Alternatives considered

- **Executable detector (a script under `tests/` or a helper).** Pros: a
  deterministic, reusable, machine-parseable detector. Cons: an explicit spec
  non-goal ("no executable detection script or any runtime code"); the committed
  suite is read-only and never reads `work/**` (`tests/README.md:29`), so a
  live-tree detector cannot live there; and it adds a maintenance surface and a
  provider dependency the prompt-only model does not have. **Rejected** — it
  contradicts the user-resolved delivery fork and the suite contract.
- **New `/detect` command plus a `detector` agent.** Pros: directly invocable,
  with a dedicated owner. Cons: violates the non-goal and the `0001` ownership
  decision (reconcile — and therefore its pre-flight — is a step inside `/ship`
  owned by the shipper); forces edits to `.opencode/command/`, `.opencode/agent/`,
  `opencode.json`, the README Commands/Agents tables, and
  `tests/checks/40-inventory.sh`, enlarging exactly the shared surfaces parallel
  branches already collide on. **Rejected.**
- **Make the existing fused detect+merge step read-only and classify in place
  (no distinct pre-flight).** Pros: a smaller diff to the skill; no new ordered
  step. Cons: detection and mutation remain interleaved, so "the pre-flight runs
  before any ship operation" (AC5), "mutates neither branch nor working tree"
  (AC1), the up-to-date no-op (AC11), and the recorded result (AC12) are implicit
  and hard to verify by reading. **Rejected** — a distinct step is what makes the
  read-only guarantee auditable.
- **Write the detection contract normatively into `docs/workflow.md`.** Pros: one
  authoritative surface. Cons: `docs/workflow.md` carries the lifecycle and
  signature guards (`tests/checks/20-lifecycle.sh`, `96-signature-sweep.sh`) and is
  the largest shared-surface collision vector; the `0001` contract already fixes
  the pre-ship placement, and detection is operational detail that belongs in the
  skill. **Rejected** — smallest-change principle and collision avoidance; the
  skill's opening already declares `docs/workflow.md` the source of truth on any
  disagreement.

## Interfaces and data model

No runtime interfaces or schemas change. The concrete contract is the required
content of each edited surface (so the builder and tester can verify by reading).

### `.opencode/skill/merge-conflict/SKILL.md`

Insert a distinct **read-only pre-flight** ahead of the existing resolve
procedure, and split the existing step 1 so detection no longer merges. Required
literals:

| Region | Required literal(s) |
| ------ | ------------------- |
| Pre-flight purpose | `read-only`; `pre-flight`; `before` the ship operations |
| Default branch + base | `default branch`; `merge base`; `git fetch`; `git merge-base` |
| Changed paths | reports the paths each branch changed (`git diff --name-only`) |
| Textual probe | `git merge-tree`; `dry-run`; `does not apply to the working tree`; report the paths on which a merge would conflict; classify each conflicting path as class `(a)` or `(b)` |
| Read-only statement | `no merge applied`; `no rebase`; `no force-push`; `mutates neither the branch nor the working tree`; no commit, no branch change |
| Integrity checks | `duplicate top-level` `work/` sequence prefixes; `duplicate per-parent` roadmap child numbers; `Depends on` `dangling`/`missing`/`unlisted`/`cyclic`; `duplicated inventory/count` facts; cross-branch prefix comparison |
| Vocabulary | `TEXTUAL-CONFLICT`; `DUPLICATE-PREFIX`; `DUPLICATE-CHILD`; `DRIFT-FACT`; the four class labels `(a)`–`(d)` |
| No-loss rule | no finding `silently dropped`; report every conflicting path, never truncated |
| No-op | up to date → reports `no conflicts`; no-op; `does not error` |
| Degraded paths | fetch unavailable/denied → comparison `skipped` with the reason; default branch undeterminable → report, do not guess; empty `work/` → no findings |
| Edge semantics | both sides changed the same fact to the same value → `not` drift; overlapping classes reported under `each applicable class`; concurrent runs take no lock and `write nothing`; clean dry-run still leaves drift for the re-verification suite |
| Hand-off | a detected conflict is handed to the `0001` reconcile step; detection `never resolves` a semantic conflict itself; escalation per `docs/workflow.md` → `## Merge conflicts` |

The existing resolve/re-verify/record/post-merge/escalate steps remain unchanged
in substance so the `0001` procedure is not forked.

### `.opencode/agent/shipper.md`

- Frontmatter `permission.bash`: add `"git fetch*": allow`,
  `"git merge-tree*": allow`, `"git ls-tree*": allow`. Keep `"git push*": ask`;
  do not add `git rebase*`, `git merge*`, `git restore*`, or similar.
- `<preconditions>` (work-item mode): add that the read-only pre-flight has run
  **before any ship operation** and its result is recorded; fix-landing mode is
  unchanged.
- `<process>` (work-item mode): add a first step that runs the pre-flight per the
  merge-conflict skill (default branch, `git fetch`, merge base, changed paths,
  `git merge-tree` dry-run, classification, integrity checks), reports every
  finding, hands a semantic finding to the `0001` reconcile step for escalation,
  and records the result.
- `<rules>`: add that detection is read-only — detection never merges, rebases, or
  force-pushes, and never resolves a semantic conflict.
- `<handoff>`: add a `Detected:` line reporting the classes/paths found or
  `no conflicts detected`.

### `.opencode/command/ship.md`

Add one work-item-mode bullet: run the read-only pre-flight before any ship
operation, report its findings, escalate a semantic conflict at the reconcile step
rather than resolving it, and record the result in `ship.md` and the PR
description. No signature or usage-string change.

### `.opencode/agent/status.md`

- `<inputs>`: add README.md's Layout counts and Skills table, and the on-disk
  `.opencode/{agent,command,skill}/` sets.
- `<process>`: add steps for (i) duplicate top-level `NNNN` prefixes and
  duplicate per-parent `MMMM` numbers across the `work/` tree, and (ii) the
  duplicated inventory/count facts against disk.
- `<findings>`: add `DUPLICATE-PREFIX` (class c), `DUPLICATE-CHILD` (class c),
  `DRIFT-FACT` (class d); annotate all findings with their class label.
- `<output_format>`: extend the Findings example with the new codes.
- `<rules>`/`<quality_bar>`: state that detection is local-only — no fetch, no
  dry-run merge, no remote, no file modification — and that every finding names
  its code, class, and offending reference.

### `.opencode/command/status.md`

Add a bullet enumerating the duplicate-sequence and drift findings and restating
that `/status` detects locally, fetches nothing, and runs no dry-run merge.

### `.opencode/skill/pr-workflow/SKILL.md`

Add a `## Conflict detection` section to the work-item PR description template:
the detection classes and paths found, or an explicit `No conflicts detected`.
The fix PR template is unchanged.

### Finding vocabulary (canonical, repeated verbatim in the skill and status)

`TEXTUAL-CONFLICT` (a)/(b) · `DANGLING-DEP` (b) · `MISSING-CHILD` (b) ·
`UNLISTED-CHILD` (b) · `CYCLIC-DEP` (b) · `DUPLICATE-PREFIX` (c) ·
`DUPLICATE-CHILD` (c) · `DRIFT-FACT` (d); format
`- [<CODE>] (<class>) <offender(s)> — <detail>`.

## Affected areas

- `.opencode/skill/merge-conflict/SKILL.md` — new read-only pre-flight and
  framework-integrity sections; existing resolve procedure kept.
- `.opencode/agent/shipper.md` — allowlist (frontmatter), preconditions, process,
  rules, handoff.
- `.opencode/command/ship.md` — one work-item-mode bullet.
- `.opencode/agent/status.md` — inputs, process, findings, output example, rules,
  quality bar.
- `.opencode/command/status.md` — one findings bullet.
- `.opencode/skill/pr-workflow/SKILL.md` — PR description template section.

Read for context, not changed: `docs/workflow.md:337-398` (the `0001` contract),
`docs/artifact-conventions.md` (`### Renumbering after a parallel merge`),
`README.md:218,220,270-273` (Agents/Layout), `tests/checks/30-permissions.sh`,
`tests/checks/40-inventory.sh`, `tests/checks/20-lifecycle.sh`,
`tests/checks/96-signature-sweep.sh`, `tests/README.md:29`,
`work/0005-merge-conflict-workflow/0001-conflict-model/**`.

Explicitly **not** changed: `docs/workflow.md`, `docs/artifact-conventions.md`,
`AGENTS.md`, `template/**`, `README.md`, `opencode.json`, `tests/**`, and every
`work/` artifact format, phase, command, and agent inventory.

## Risks and mitigations

- **Vocabulary drift between the skill and the status agent.** Two surfaces
  restate the finding codes and grammar. Likelihood medium / impact medium.
  Mitigation: the table above is canonical; T2 and T4 copy it verbatim, and T6
  greps both surfaces for the same three new codes and the class grammar.
- **Permission-agreement regression.** Adding allow patterns could change the
  shipper's coarse bash class and fail `tests/checks/30-permissions.sh`/AC13.
  Likelihood low / impact high. Mitigation: the additions are `allow` read-only
  git patterns inside the existing `git-gh` class; T6 runs the suite and asserts
  the shipper is still `git-gh` and `status` still `read-only`.
- **`git merge-tree` variant unavailable on an adopter's git.** The probe fails
  or is absent. Likelihood medium / impact medium. Mitigation: the skill
  specifies the `--write-tree` form with a three-argument fallback and a
  "skipped with reason" path; T1's Verify greps the fallback and skip literals.
- **Detection mistaken for resolution.** A reader could think the pre-flight
  resolves or that `/status` fetches. Likelihood medium / impact high.
  Mitigation: the read-only statement and "detection never resolves a semantic
  conflict" are required literals (AC1, AC6, AC9), asserted in T1–T4.
- **Cross-branch class (c) is under-detected.** A local-only scan cannot see a
  collision that exists only after the merge. Likelihood medium / impact high.
  Mitigation: the pre-flight compares against `origin/<default>:work` via
  `git ls-tree` (T2); `/status` is explicitly local-only and reports only locally
  observable duplicates (AC9).
- **Collision with sibling `0003`/`0004` on shared surfaces.** All three edit
  `.opencode/agent/shipper.md`, the skill, and `/ship`. Likelihood high / impact
  medium. Mitigation: land in sequence (roadmap `## Sequencing`), touch only the
  detection regions, and leave `docs/workflow.md` untouched.
- **Editing `ship.md`/`status.md` body trips a signature guard.** Likelihood low /
  impact high. Mitigation: no command signature, usage string, `### N.` phase
  heading, or `Supporting commands:` line changes; T6 runs the full suite.

## Test strategy

Detection is prose, so ACs are verified by literal-presence assertions in the
item-level read-only suite (`verify-tests.sh`, per the `0001` precedent) plus the
committed suite for the inventory/permission/lifecycle invariants. No committed
check is added; committed guards are sibling `0005`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | content: skill greps `read-only`, `pre-flight`, `merge base`, changed paths, and the no-mutation literals |
| AC2 | content: skill greps `git merge-tree`, `dry-run`, `does not apply to the working tree`, class `(a)`/`(b)` classification |
| AC3 | content: skill greps the four integrity checks and the cross-branch comparison |
| AC4 | content: skill/status grep the finding grammar and each code; no-drop and no-truncation literals |
| AC5 | content: shipper `<preconditions>`/`<process>` and `/ship` grep the pre-flight-before-ship and record literals |
| AC6 | content: shipper/`/ship` grep "hand to the `0001` reconcile step" and "escalate"/"never resolves" |
| AC7 | content: shipper frontmatter greps `git fetch*`, `git merge-tree*`, `git ls-tree*`; absence of `git rebase*` and `git push*` remains `ask` |
| AC8 | content: status agent + `/status` grep `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DRIFT-FACT` alongside the four existing codes |
| AC9 | content: status greps local-only / no-fetch / no-dry-run literals |
| AC10 | content: grammar requires the offender reference; status example shows canonical refs |
| AC11 | content: skill/shipper grep the up-to-date no-op literals |
| AC12 | content: `pr-workflow` greps `## Conflict detection`; shipper `<handoff>` greps `Detected:` |
| AC13 | integration: `bash tests/run.sh` exits 0, `30-permissions.sh` green; `40-inventory.sh` counts unchanged |
| AC14 | integration: suite green + listing shows 12 commands / 14 agents / 11 skills and no new command or agent file; `git status` scoped to the affected surfaces |

`bash tests/run.sh` is the project's canonical command (`AGENTS.md:17`) and is run
after every task; the tester re-runs it independently for AC13/AC14.
