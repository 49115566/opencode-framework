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

## Procedure

1. **Detect.** Compare the item branch against the default branch. Merge the
   default branch forward into the item branch (never rebase). A branch that is
   already up to date is a no-op: both reconcile and the integrity pass do
   nothing and do not error.

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

- Merge the default branch forward; never rebase a pushed branch, never
  force-push.
- Preserve both branches' intent; never drop one side's records.
- Auto-resolve only mechanical/structural conflicts, always subject to
  step 4's re-verification.
- Class (c) defers to "Renumbering after a parallel merge" in
  `docs/artifact-conventions.md`; this skill never defines a second rule.
