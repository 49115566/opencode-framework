---
feature: 0005-merge-conflict-workflow/0002-conflict-detection
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc only. Every task edits prose or agent frontmatter; no new command, agent, skill, artifact format, committed check, or executable script. T6 is the item-level acceptance gate. AC map: AC1 T1; AC2 T1; AC3 T2; AC4 T1,T2,T4; AC5 T3; AC6 T3; AC7 T3; AC8 T4; AC9 T4; AC10 T1,T2,T4; AC11 T1,T3; AC12 T3,T5; AC13 T6; AC14 T6."
parent: 0005-merge-conflict-workflow
---

# Tasks — Pre-flight conflict detection and classification

Ordered, dependency-aware. One task ≈ one focused commit. The canonical finding
vocabulary is defined in `design.md` → "Finding vocabulary"; T2 and T4 copy it
verbatim. No task changes a command signature, a phase heading, an artifact
template, or an inventory count.

- [x] **T1** — In `.opencode/skill/merge-conflict/SKILL.md`, add a distinct
      **read-only pre-flight** ahead of the existing resolve procedure and split
      the current fused "Detect … Merge the default branch forward" step so
      detection no longer merges. The pre-flight must: determine the default
      branch and the merge base of the item branch and the default branch; run
      `git fetch`; report the paths each branch changed
      (`git diff --name-only <base>..HEAD` and `<base>..origin/<default>`); run a
      `git merge-tree` dry-run merge over the changed paths that `does not apply
      to the working tree`; and classify each conflicting path as class `(a)`
      (shared framework surface) or `(b)` (`work/` path) from the `0001`
      taxonomy. State that the pre-flight is `read-only`, `mutates neither the
      branch nor the working tree`, applies `no merge`, does `no rebase`, does
      `no force-push`, and creates no commit or branch change. Introduce the
      finding grammar `- [<CODE>] (<class>) <offender(s)> — <detail>`, the
      `TEXTUAL-CONFLICT` code, the no-drop/no-truncation rule, the up-to-date
      `no conflicts` no-op (`does not error`), the `skipped`-with-reason path for
      an unavailable `git fetch`, the report-don't-guess path when the default
      branch is undeterminable, and the clean-dry-run caveat. Keep the existing
      resolve/re-verify/record/post-merge/escalate steps intact. [AC1] [AC2]
      [AC4] [AC10] [AC11]
      Verify: `grep -nE 'read-only|pre-flight|merge base|git merge-tree|dry-run|does not apply to the working tree|no merge applied|no rebase|no force-push|mutates neither the branch' .opencode/skill/merge-conflict/SKILL.md` shows every literal; `grep -nE 'TEXTUAL-CONFLICT|does not error|skipped'` shows the vocabulary and degraded paths; `bash tests/run.sh` exits 0.

- [x] **T2** — In `.opencode/skill/merge-conflict/SKILL.md`, add the
      **framework-integrity checks** to the pre-flight: duplicate top-level
      `work/` sequence prefixes and duplicate per-parent roadmap child numbers;
      each roadmap `Depends on` resolved against its `Children` table for
      `dangling`/`missing`/`unlisted`/`cyclic` references; and `duplicated
      inventory/count` facts (README Layout counts and Skills table vs the
      on-disk `.opencode/` sets). Add the cross-branch comparison that reads
      `git ls-tree --name-only origin/<default>:work` (and per-parent) to catch a
      class `(c)` collision that exists only between the two branches. Add the
      integrity codes `DUPLICATE-PREFIX` `(c)`, `DUPLICATE-CHILD` `(c)`,
      `DRIFT-FACT` `(d)`, and annotate the existing four graph codes with class
      `(b)`. Record the edge semantics: both sides changed the same fact to the
      same value is `not` drift; an overlapping path is reported under `each
      applicable class`; concurrent runs take no lock and `write nothing`. [AC3]
      [AC4] [AC10] [depends: T1]
      Verify: `grep -nE 'duplicate top-level|duplicate per-parent|dangling|cyclic|duplicated inventory/count|git ls-tree|DUPLICATE-PREFIX|DUPLICATE-CHILD|DRIFT-FACT|not.*drift|each applicable class' .opencode/skill/merge-conflict/SKILL.md` shows every literal; `bash tests/run.sh` exits 0.

- [x] **T3** — In `.opencode/agent/shipper.md`, add `"git fetch*": allow`,
      `"git merge-tree*": allow`, and `"git ls-tree*": allow` to the
      `permission.bash` frontmatter; keep `"git push*": ask` and add no
      `git rebase*`/`git merge*`. In `<preconditions>` (work-item mode) add that
      the read-only pre-flight has run **before any ship operation** and its
      result is recorded. In `<process>` (work-item mode) add a first step that
      runs the pre-flight per the `merge-conflict` skill, reports every finding,
      hands a semantic finding to the `0001` reconcile step for escalation rather
      than resolving it, and records the result. Add a `<rules>` bullet that
      detection is read-only (never merges, rebases, or force-pushes). Add a
      `Detected:` line to the `<handoff>` block reporting the classes/paths found
      or `no conflicts detected`. In `.opencode/command/ship.md`, add one
      work-item-mode bullet doing the same before any ship operation; do not
      touch any signature or usage string. [AC5] [AC6] [AC7] [AC11] [AC12]
      [depends: T1, T2]
      Verify: `grep -nE '"git fetch\*": allow|"git merge-tree\*": allow|"git ls-tree\*": allow' .opencode/agent/shipper.md`; `grep -nE 'before any ship operation|semantic|escalat|Detected:|read-only' .opencode/agent/shipper.md .opencode/command/ship.md`; confirm no `git rebase*` line exists and `"git push*": ask` remains; `bash tests/run.sh` exits 0 with `30-permissions.sh` green.

- [x] **T4** — In `.opencode/agent/status.md`, add README.md's Layout counts and
      Skills table and the on-disk `.opencode/{agent,command,skill}/` sets to
      `<inputs>`; add `<process>` steps for duplicate top-level `NNNN` prefixes
      and duplicate per-parent `MMMM` numbers, and for the duplicated
      inventory/count facts against disk; add `DUPLICATE-PREFIX` (class c),
      `DUPLICATE-CHILD` (class c), and `DRIFT-FACT` (class d) to `<findings>`,
      annotating every finding with its class label; extend the
      `<output_format>` Findings example with the new codes; and state in
      `<rules>`/`<quality_bar>` that detection is local-only — no fetch, no
      dry-run merge, no remote, no file modification. In
      `.opencode/command/status.md`, add a bullet enumerating the new findings and
      restating the offline/local-only constraint. [AC4] [AC8] [AC9] [AC10]
      [depends: T2]
      Verify: `grep -nE 'DUPLICATE-PREFIX|DUPLICATE-CHILD|DRIFT-FACT' .opencode/agent/status.md .opencode/command/status.md`; `grep -niE 'no fetch|does not fetch|dry-run merge|local' .opencode/agent/status.md .opencode/command/status.md`; frontmatter still contains no git-write allow pattern (the bash class is `read-only`); `bash tests/run.sh` exits 0.

- [x] **T5** — In `.opencode/skill/pr-workflow/SKILL.md`, add a
      `## Conflict detection` section to the work-item PR description template:
      the detection classes and paths found, or an explicit
      `No conflicts detected`. Leave the fix PR template and the `## Commands`
      block unchanged. [AC12] [depends: T3]
      Verify: `grep -n '## Conflict detection' .opencode/skill/pr-workflow/SKILL.md`; `grep -n 'No conflicts detected' .opencode/skill/pr-workflow/SKILL.md`; `bash tests/run.sh` exits 0.

- [x] **T6** — Run the item-level acceptance gate: `bash tests/run.sh` must exit
      0 with no `FAIL` lines, including `tests/checks/30-permissions.sh` (the
      shipper stays `git-gh`, the status agent stays `read-only`) and
      `tests/checks/40-inventory.sh`; `.opencode/command/` still holds 12 files,
      `.opencode/agent/` 14, and `.opencode/skill/` 11, with no new command or
      agent file and no new skill; the phase list, derived-state table, and
      artifact templates in `docs/workflow.md` and `docs/artifact-conventions.md`
      are unchanged. Confirm no executable detection script is added and
      `git status --porcelain` touches only `.opencode/agent/shipper.md`,
      `.opencode/agent/status.md`, `.opencode/command/ship.md`,
      `.opencode/command/status.md`,
      `.opencode/skill/merge-conflict/SKILL.md`,
      `.opencode/skill/pr-workflow/SKILL.md`, and
      `work/0005-merge-conflict-workflow/0002-conflict-detection/`. [AC13] [AC14]
      [depends: T1, T2, T3, T4, T5]
      Verify: `bash tests/run.sh`; `ls .opencode/command/*.md | wc -l` is 12 and `ls .opencode/agent/*.md | wc -l` is 14 and `ls -d .opencode/skill/*/ | wc -l` is 11; `git status --porcelain` matches the allowed surface list.
