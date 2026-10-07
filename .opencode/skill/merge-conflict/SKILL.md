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

`TEXTUAL-CONFLICT` is pre-flight-only: `/status` performs no dry-run merge.

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
   Merge the default branch forward into the item branch (never rebase). A branch
   that is already up to date reports `no conflicts` and is a no-op: both
   reconcile and the integrity pass do nothing and do not error. Never resolve a
   conflict the pre-flight flagged as needing a judgment about intent; escalate
   it (Stop and escalate).

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
     user for explicit approval (step 7).

4. **Re-verify.** After any resolution, run `bash tests/run.sh` and the affected
   item's checks. Both must be green before the merge is recorded or shipped.
   A clean merge is not evidence of correctness: even a merge with no conflict
   markers still runs the suite, because derived-agreement drift is surfaced only
   there.

5. **Record** the resolved paths and the re-verification evidence (in the ship
   handoff and the PR description) so the reviewer can confirm what was resolved
   and that it was re-verified. Do not invent a new artifact or field for this.

6. **Post-merge integrity pass.** After a merge to the default branch, run this
   documented, shipper-owned checklist on the merged tree:
   - re-scan top-level and per-parent `work/` directories for duplicate 4-digit
     prefixes;
   - re-check every roadmap `Depends on` against its `Children` table for
     dangling, missing, unlisted, or cyclic references;
   - re-run `bash tests/run.sh` to surface derived-agreement drift.

7. **Stop and escalate.** If a conflict needs a judgment about intent, or an
   overlapping `work/` edit leaves the dependency graph dangling, duplicate, or
   cyclic and cannot be resolved mechanically, stop. Report the specific blocked
   path(s) and do not resolve silently to proceed. A ship blocked by escalation
   stays blocked until the user responds.

## Rules

- The pre-flight is read-only: it never merges, rebases, or force-pushes, and it
  never resolves a semantic conflict. Detection reports; the reconcile steps
  below resolve.
- Merge the default branch forward; never rebase a pushed branch, never
  force-push.
- Preserve both branches' intent; never drop one side's records.
- Auto-resolve only mechanical/structural conflicts, always subject to
  step 4's re-verification.
- Class (c) defers to "Renumbering after a parallel merge" in
  `docs/artifact-conventions.md`; this skill never defines a second rule.
