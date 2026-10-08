---
name: merge-conflict
description: Reconcile a work-item branch that has fallen behind the default branch, classify a merge conflict, and resolve or escalate it during /ship. Use when a branch is behind, git reports conflict markers, a merge must be reconciled, work/ artifacts collide, or two branches allocate the same sequence number. Triggers on "merge conflict", "reconcile", "conflict", "branch behind", "/ship".
---

# Merge conflict reconciliation

`docs/workflow.md` → `## Merge conflicts` is the source of truth; this skill is
the shipper's operational view. If they disagree, follow `docs/workflow.md` and
correct this file.

Reconciliation is a step inside `/ship`, owned by the `shipper`; it adds no new
command or agent. Never rebase a pushed branch and never force-push.

## When to use

- `/ship` is about to run and the item branch is behind the default branch.
- A merge into the item branch produces conflict markers.
- A merge to the default branch has just landed and the post-merge integrity pass
  must run.

## Pre-flight (read-only detection)

Reconciliation begins with a **read-only pre-flight** that runs **before any
ship operation**. It reports what a merge would collide on so the shipper can
assess the risk before mutating anything; it never applies the merge. The
pre-flight mutates neither the branch nor the working tree: no merge applied, no
rebase, no force-push, no commit, and no branch change. Two concurrent
pre-flights may run without interfering — they take no lock and write nothing.

1. **Determine the default branch and the merge base.** Resolve the default
   branch from `origin/HEAD` (`git symbolic-ref refs/remotes/origin/HEAD`) or
   `gh repo view --json defaultBranchRef`. If no remote or default-branch
   reference is available — `origin/HEAD` is unset, the remote is unreachable, or
   the repo is detached — report that the default branch cannot be determined
   instead of guessing one; that alone does not fail the ship. Fetch the latest
   remote-tracking refs with `git fetch <remote> <default-branch>`; `git fetch`
   updates remote-tracking refs only and changes no branch and no working-tree
   file. Then compute the merge base of the item branch and the default branch
   with `git merge-base HEAD origin/<default>`.

2. **Report the paths each branch changed.** For each side, list the paths it
   changed relative to the merge base: `git diff --name-only <base>..HEAD` for the
   item branch and `git diff --name-only <base>..origin/<default>` for the
   default branch. Report both lists.

3. **Dry-run textual probe.** Over the changed paths, run a non-applying dry-run
   merge with `git merge-tree --write-tree --name-only HEAD origin/<default>` and
   report the paths on which a merge would conflict. With `--write-tree`, exit
   status `1` means conflicts were found, not a command failure: report them and
   continue. Its output begins with the merged toplevel tree OID before the
   conflicted pathnames, so skip that OID line when extracting the paths.
   This probe does not apply to the working tree: `git merge-tree` writes no ref
   and no working-tree file. On an older git without `--write-tree`, fall back to
   the three-argument form `git merge-tree <base> <branch1> <branch2>`. If
   neither form is usable, report the textual comparison as `skipped` with the
   reason; never run it on a stale base. Classify each conflicting path as class
   `(a)` — a shared framework
   surface (`README.md`, `AGENTS.md`, `docs/*.md`,
   `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`) — or
   class `(b)` — a `work/` path — per the `0001` taxonomy in `docs/workflow.md` →
   `## Merge conflicts`. Scope the reported set to paths both branches changed.

4. **Framework-integrity checks.** Independently of the textual probe, inspect
   the `work/` tree and the duplicated inventory/count facts for collisions and
   drift. These checks are local and read-only: they take no lock and write
   nothing.

   - **Duplicate top-level sequence prefixes.** Any two top-level `work/`
     directories whose 4-digit `NNNN` prefix is equal are a duplicate top-level
     class `(c)` collision, even when their slugs differ. Compare the directory
     names under `work/` to find them.
   - **Duplicate per-parent roadmap child numbers.** Within each roadmap parent,
     any two child directories whose local 4-digit `MMMM` prefix is equal are a
     duplicate per-parent class `(c)` collision. Check every parent the same way.
   - **Roadmap graph faults.** For each `roadmap.md`, resolve every `Depends on`
     local id against the `Children` table and report each `dangling` reference
     (a dependency with no child directory or no table row), `missing` child (a
     Children-table row whose directory is absent), `unlisted` child (a child
     directory absent from the table), and `cyclic` dependency (a cycle in the
     graph). These are class `(b)`.
   - **Duplicated inventory/count facts.** Compare README.md's Layout counts
     (`# N role prompts`, `# N slash commands`, `# N knowledge skills`) and its
     Skills table membership with the on-disk `.opencode/{agent,command,skill}/`
     sets, and report any disagreement as class `(d)` drift.
   - **Cross-branch prefix collision.** A class `(c)` collision can exist only
     between the two branches: each may add a distinct directory under the same
     `NNNN`. Compare the local `work/` directory names with
     `git ls-tree --name-only origin/<default>:work` (and per-parent for roadmap
     children), and report a collision when a 4-digit prefix is shared by two
     different canonical references. `/status` stays offline and does not perform
     this cross-branch read.

### Finding grammar

Report every detection result as one line:

```
- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>
```

`<class>` is one of `(a)`, `(b)`, `(c)`, or `(d)` from the `0001` taxonomy, and
the offender is the exact path or canonical reference so a reader can locate it.
Every finding carries its class label. No finding is silently dropped, and every
conflicting path is reported — the path list is never truncated, even for a large
changed set. A path that qualifies under more than one class is reported under
each applicable class rather than collapsed to one.

The pre-flight vocabulary (canonical; the `status` agent repeats it) is:

| Code | Class | Finding |
| ---- | ----- | ------- |
| `TEXTUAL-CONFLICT` | `(a)` or `(b)` | the dry-run merge would leave conflict markers on the named path |
| `DANGLING-DEP` | `(b)` | a roadmap `Depends on` names a local id with no child directory or no table row |
| `MISSING-CHILD` | `(b)` | a Children-table row whose child directory is absent |
| `UNLISTED-CHILD` | `(b)` | a child directory absent from the Children table |
| `CYCLIC-DEP` | `(b)` | a cycle in a roadmap dependency graph |
| `DUPLICATE-PREFIX` | `(c)` | two different top-level `work/` references share an `NNNN` |
| `DUPLICATE-CHILD` | `(c)` | two different per-parent child references share an `MMMM` |
| `DRIFT-FACT` | `(d)` | a duplicated count/table fact disagrees with disk or the other branch |

`TEXTUAL-CONFLICT` is pre-flight-only for the `dry-run-detected` case: `/status`
performs no dry-run merge. That note scopes the detected case only.

Three of these codes also carry a **planning-time** meaning, stated once in
`docs/workflow.md` → `## Declared-conflict check`; their merge-time meanings
above are unchanged and no code is added:

- `TEXTUAL-CONFLICT` (`(a)` or `(b)`) — two unshipped plans **share a declared
  target**: a repository surface outside `work/` for `(a)`, or a `work/` path or a
  one-sided naming of the other item for `(b)`.
- `DANGLING-DEP` (`(b)`) — a declared `conflicts-with` target is malformed or
  resolves to no sibling row, no `work/<ref>/`, and no existing repository path.
- `DRIFT-FACT` (`(d)`) — a roadmap child's own `design.md` declaration and its
  parent `Children` `conflicts-with` cell are both present and their target sets
  disagree.

This vocabulary is canonical and is consumed unchanged by the merge-integrity
guard. `docs/workflow.md` → `### Merge-integrity guard` is the single statement
of the invariant set and its enforcement points; there is no second vocabulary,
no second policy, and the guard modifies no file.

Both sides changing the same duplicated fact to the same value is not drift:
report no class `(d)` finding.

### Up to date and degraded paths

- An item branch already up to date with the default branch reports `no
  conflicts`; the pre-flight is a no-op and does not error.
- If `git fetch` is unavailable or denied, report the comparison as `skipped`
  with the reason; never proceed on a stale or partial comparison without saying
  so.
- A clean dry-run merge (no conflict markers) is not proof of correctness:
  derived-agreement drift can merge cleanly, so still leave the re-verification
  step below to confirm it.

The pre-flight detects and reports only; it never resolves a conflict. It hands
every detected conflict to the reconcile procedure below, and a conflict that
needs a judgment about intent is escalated at the reconcile step (Stop and
escalate).

## Procedure

1. **Reconcile.** The read-only pre-flight above has already detected and
   classified what a merge would collide on, and it hands its findings here.
   Run the reconcile as this ordered, agent-executable sequence:

   1. **Determine the default branch and the merge base, then fetch.** First
      determine the default branch and the merge base exactly as the pre-flight
      does — `git symbolic-ref refs/remotes/origin/HEAD` (or
      `gh repo view --json defaultBranchRef`) for the default branch, then
      `git merge-base HEAD origin/<default>` — and fetch the latest
      remote-tracking refs with `git fetch <remote> <default>`. If the default
      branch cannot be determined, report that and do not mutate the branch.

   2. **Do not start a second merge.** If a merge is already in progress at
      start (`git rev-parse -q --verify MERGE_HEAD`), report it and do **not**
      start a second merge.

   3. **An already-up-to-date branch is a no-op.** If the default branch is
      already an ancestor of the item branch (the merge base equals
      `origin/<default>`), report `no conflicts`: the reconcile is a `no-op`, it
      creates `no merge commit`, and it `does not error`; continue with the
      remaining ship operations.

   4. **Merge the default branch forward.** Otherwise run
      `git merge --no-edit origin/<default>` to merge the default branch forward
      into the item branch. The rule is absolute — never rebase a pushed branch
      and never force-push. A merge that completes with no conflict markers,
      touched no `work/` path, and carries no pre-flight class (b) `work/`
      finding and no class (c) sequence collision has nothing to reconcile and
      proceeds directly to sub-step 1.8 — a clean merge is not evidence of
      correctness. A **clean merge that touched any `work/` path or carries a
      pre-flight class (b) or class (c) finding is not finished**, because the
      pre-flight ran before the merge: the merge can introduce or expose a
      `work/` graph fault or sequence collision the pre-flight could not see. A
      class (c) duplicate sequence number and a class (b) graph fault are
      precisely the clean-merge case, because the two branches add distinct
      directories and the merge produces no conflict. Continue to sub-step 1.6 to
      run the `work/` artifact reconcile on the already-merged tree, and re-verify
      (sub-step 1.8) after it.

   5. **List every conflicted path.** Enumerate the unmerged paths with
      `git status --short` and `git diff --name-only --diff-filter=U`. Report
      every conflicted path — the list is never truncated — and classify each as
      class (a) or class (b) per step 2.

   6. **Resolve.** Resolve the set per step 3: preserve **both** branches'
      changes, `drop neither side`; keep class (b) `work/` records from both
      branches rather than dropping one. For a class (b) `work/` path — and for a
      class (c) duplicate sequence number — run the `work/` artifact reconcile
      subsection below: it merges the colliding content preserving both branches'
      records, re-checks the roadmap dependency graph, and applies
      `Renumbering after a parallel merge` in `docs/artifact-conventions.md`
      (`git mv`). Auto-resolve only `mechanical or structural` conflicts that
      `does not require choosing between competing intents`, subject to
      sub-step 1.8. A conflict that requires a judgment between competing intents
      is a `semantic conflict`: do not resolve it — go to sub-step 1.9.

   7. **Assert no conflict markers remain.** Read each previously conflicted
      file and confirm that none of `<<<<<<<`, `=======`, `>>>>>>>` remains. A
      file that still contains markers is `unresolved` and must not be
      committed.

   8. **Re-verify.** After any resolution, run the repository's own configured
      test command — the Project profile `Test:` value — and the affected item's
      checks. Both must be `green` before the merge is
      recorded or shipped: a failing check is the blocker, and the resolution is
      not accepted until it passes. When the merge auto-committed cleanly
      (sub-step 1.4) the merge commit already exists, so do not rewrite an
      already-created merge commit without explicit user confirmation (the
      workflow's destructive-recovery rule) — hold the ship `blocked` instead.

   9. **Stop and escalate a semantic conflict.** On a `semantic conflict`, run
      `git merge --abort` to restore a clean working tree, report the specific
      blocked path(s) and the decision the user must make, and keep the ship
      `blocked until the user responds` (procedure step 7). If the conflict
      arrived on the clean-merge path there is no in-progress merge to abort: the
      merge already auto-committed, so report the blocked reference(s) and hold
      the ship `blocked` rather than rewriting the merge commit without user
      confirmation. Never commit, record, or ship a partial or unresolved merge;
      if the abort cannot complete, report that and stop rather than committing a
      partial merge.

2. **Classify** each conflicting path into one of the four classes from the
   `### Conflict taxonomy` in `docs/workflow.md`:
   - (a) shared-surface textual conflict — both branches edited the same
     framework file (`README.md`, `AGENTS.md`, `docs/*.md`,
     `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`).
   - (b) `work/` artifact conflict — both branches edited the same committed
     work artifact (roadmap `Children` / `Depends on` tables, artifact
     frontmatter, nested-child intersections).
   - (c) duplicate sequence number — both branches allocated the same `NNNN` or
     the same per-parent `MMMM`. Defer to "Renumbering after a parallel merge"
     in `docs/artifact-conventions.md`; do not invent a second renumbering rule.
   - (d) derived-agreement drift — a duplicated inventory or count fact merged
     cleanly but the two sides now disagree (README Layout counts, README Skills
     table). Surfaced only by the re-verification suite run.

3. **Resolve.**
   - **Mechanical or structural** conflicts that do not require choosing between
     competing intents may be auto-resolved. Preserve both branches' records and
     changes; never drop one side.
   - **Semantic** conflicts — any resolution that requires a judgment about
     competing intents — are never accepted silently. Stop and escalate to the
     user for explicit approval (sub-step 1.9).

4. **Re-verify.** After any resolution, run the repository's own configured test
   command — the Project profile `Test:` value — and the affected item's checks.
   Both must be green before the merge is recorded or shipped.
   A clean merge is not evidence of correctness: even a merge with no conflict
   markers still runs the suite, because derived-agreement drift is surfaced only
   there.

5. **Record.** Record the reconcile, the resolved paths, and the re-verification
   evidence in the `## Reconcile` section of `ship.md` and in the pull-request
   description, so the reviewer can confirm what was resolved and that it was
   re-verified. Record a renumber as a `Resolved paths` entry of the form
   `<old> → <new>`. Do not invent a new artifact or field for this beyond the
   documented `ship.md` `## Reconcile` record.

6. **Post-merge integrity pass.** After a merge to the default branch, run this
   documented, shipper-owned checklist on the merged tree:
   - re-scan top-level and per-parent `work/` directories for duplicate 4-digit
     prefixes;
   - re-check every roadmap `Depends on` against its `Children` table for
     dangling, missing, unlisted, or cyclic references;
   - re-run the repository's own configured test command — the Project profile
     `Test:` value — to surface derived-agreement drift.

   The pass is **report-only**: it reports every finding (the list is never
   truncated) and **modifies no file** — it never auto-repairs a violation. See
   `docs/workflow.md` → `### Merge-integrity guard` for the invariant set and
   the report-only contract.

7. **Stop and escalate.** If a conflict needs a judgment about intent, or an
   overlapping `work/` edit leaves the dependency graph dangling, duplicate, or
   cyclic and cannot be resolved mechanically, run `git merge --abort` to
   restore a clean working tree. Report the specific blocked path(s) and the
   decision the user must make, and do not resolve silently to proceed. A ship
   blocked by escalation stays blocked until the user responds. If the abort
   cannot complete, report that and stop rather than committing a partial merge.

### `work/` artifact reconcile

This is the class (b) `work/` and class (c) sequence-number half of the resolve
sequence above. It runs **after the conflict set is listed** (sub-step 1.5) and
**before the re-verification** (sub-step 1.8), so the merged tree is re-verified
after the `work/` repairs. It runs on a conflicted merge and also on any clean
merge that touched any `work/` path or carries a pre-flight class (b) or class (c)
finding (sub-step 1.4), because the pre-flight ran before the merge: a class (c)
duplicate sequence number and a class (b) graph fault can merge cleanly and
surface only on the merged tree. It consumes the read-only pre-flight's class
(b)/(c)
findings — `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`,
`MISSING-CHILD`, `UNLISTED-CHILD`, and `CYCLIC-DEP` — but because the pre-flight
ran **before the merge** it does not treat them as a post-merge picture: after
`git merge --no-edit origin/<default>` it `re-scan the merged tree` for the same
codes, since the merge can introduce or expose a collision the pre-flight could
not see. Report every colliding prefix and every fault; the list is never
truncated, even for a large collision set.

1. **Merge `work/` artifact content preserving both branches' records.** For a
   class (b) path, `preserve both branches' records` and `drop neither side`:
   - **Roadmap `Children` rows** — take the union of both branches' rows. A
     local id added by one branch survives; a row that both branches added
     identically is de-duplicated to one.
   - **`Depends on` cells** — never silently discard a branch's dependency:
     take the union of both branches' dependencies added by distinct rows; a
     dependency listed twice is collapsed to one. When both branches change the
     *same* row's `Depends on` to different values, that divergence is a
     `judgment about intent` rather than an additive union: never pick one
     silently — escalate to sub-step 1.9.
   - **artifact frontmatter** — merge field-by-field. Identical or single-sided
     fields keep their value; the mechanical reference fields (`feature`,
     `parent`) are handled by the renumber reference sweep in reconcile step 3. A
     scalar field on which the two branches genuinely disagree, or a duplicate
     `Children` row whose title/scope/intent differs, is a `judgment about
     intent`: never pick one silently — escalate to sub-step 1.9.

2. **Re-check the roadmap dependency graph.** In every `roadmap.md`, each
   `Depends on` local id `resolves to an existing row and child directory`, and
   the stored graph is `acyclic`. Classify each fault as a `structural fault`
   (auto-repaired mechanically) or a `judgment about intent` (escalated to
   sub-step 1.9):
   - **Structural, auto-repaired:** a `Depends on` cell, `Local id`, `Canonical
     reference`, `feature`, or `parent` value left stale by this reconcile's own
     renumber — updated to the new value by the same reference sweep that moves
     the item (reconcile step 3); a `Children` row duplicated because both
     branches added the identical row — keep one; a duplicated dependency entry —
     collapse to one. Repair only a fault with an unambiguous structural repair;
     never drop a branch's record.
   - **Intent, escalated to sub-step 1.9:** a `DANGLING-DEP` whose correct
     target is ambiguous; a `CYCLIC-DEP` cycle (cannot be mechanically broken); a
     `deliberately removed child`; an `UNLISTED-CHILD` whose row must be
     restored and whose title/scope/intent would have to be chosen; a
     `MISSING-CHILD` or duplicate local id whose intent is ambiguous.

3. **Sequence-prefix collisions.** A class (c) duplicate sequence number is not
   a new problem: apply `Renumbering after a parallel merge` in
   `docs/artifact-conventions.md` — the single normative definition — rather
   than inventing a rule. This skill `never defines a second renumbering rule`.
   The `work/` renumber procedure is:

   1. **Detect.** After the merge, scan the merged tree for two different
      top-level `work/` references that share an `NNNN` 4-digit prefix, and for
      two child references of one roadmap parent that share an `MMMM` 4-digit
      prefix. Include a collision that exists only between the item branch and
      the default branch: compare the local `work/` names with
      `git ls-tree --name-only origin/<default>:work` (and, for each roadmap
      parent, `git ls-tree --name-only origin/<default>:work/<parent>`). Two
      directories that share a prefix under different slugs are a class (c)
      collision too. Report each collision with its `canonical reference(s)`;
      report every colliding prefix, `never truncated`, even for a large set.

   2. **Choose the item to renumber by the existing rule**, in order. Renumber
      the item that is `not yet approved or shipped` — shipped is the presence
      of `work/<ref>/ship.md`, and approved is a `review.md` verdict of
      `approve`; if both are unshipped, renumber the one whose directory was
      `added later by commit time` (`git log --diff-filter=A --format=%ct --
      work/<ref>`, comparing the added commit times); break a tie by
      `slug order`. Allocate the `next number` from the sequence-allocation
      contract: for a top-level `NNNN` collision, the greatest 4-digit prefix
      that has ever appeared in the committed `work/` history plus one; for a
      per-parent `MMMM` collision, the greatest 4-digit prefix that has ever
      appeared in that parent's committed `work/<parent>/` history plus one.
      `never reuse` a spent number: never reallocate a number whose directory
      was deleted — allocate the next free number instead.

   3. **Move the chosen item and rewrite every reference `in the same change`.**
      Move it with `git mv work/<old> work/<new>`, and in the same change update
      the directory name; the artifact `feature` frontmatter; a nested child's
      `parent` value; the roadmap `Children` table's `Local id` and
      `Canonical reference` cells for the renumbered row; every `Depends on`
      cell that names the old local id; the `ship.md` record and the PR/handoff
      paths; and any `prose` naming the old reference. Assert that
      `no reference to the old canonical reference remains`, by scanning the
      repository for the old canonical reference.

   4. **Escalate an undecidable renumber rather than guess.** If the child
      cannot be distinguished (`both are already shipped`, or approval/shipped
      state `cannot be determined`, or git history is `unavailable`, for example
      a `shallow clone`, so `added later` cannot be established, or the two
      branches propose `two different new numbers` for one item), do not
      reassign a number arbitrarily — escalate to sub-step 1.9.

   5. **No-op.** When the branch is already up to date and there is no
      sequence-prefix collision between the branches and no graph fault, report
      `no conflicts`: there is `no renumber` and `no move`, the reconcile
      `does not error`, and it creates no merge commit.

4. **Escalate an intent fault or undecidable renumber, then hand back to
   re-verify and record.** A `judgment about intent` from step 1 or step 2, or
   an undecidable renumber from step 3, is never resolved silently: escalate it
   to the generic Stop-and-escalate step (sub-step 1.9). On a conflicted merge
   that step runs `git merge --abort`; on the clean-merge path the merge has
   already auto-committed, so it reports the blocked reference(s) and holds the
   ship `blocked` rather than rewriting the merge commit without user
   confirmation. Either way it reports the specific blocked reference(s) and the
   decision the user must make, and the ship stays `blocked until the user
   responds`. Otherwise, hand the resolved tree back to the generic Re-verify
   (sub-step 1.8) and Record (procedure step 5) steps instead of restating them:
   re-run the repository's own configured test command — the Project profile
   `Test:` value — and the affected item's checks, and record the
   `work/` paths resolved and any renumber chosen as a `Resolved paths` entry
   `<old> → <new>` in the existing `## Reconcile` record of `ship.md` and the
   pull-request description.

## Rules

- The pre-flight is read-only: it never merges, rebases, or force-pushes, and it
  never resolves a semantic conflict. Detection reports; the reconcile steps
  below resolve.
- Merge the default branch forward; never rebase a pushed branch, never
  force-push.
- Preserve both branches' intent; never drop one side's records.
- Auto-resolve only mechanical/structural conflicts, always subject to
  the procedure's Re-verify step.
- Class (c) defers to "Renumbering after a parallel merge" in
  `docs/artifact-conventions.md`; this skill never defines a second rule.
