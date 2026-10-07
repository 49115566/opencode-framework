---
feature: 0005-merge-conflict-workflow/0003-shared-surface-reconcile
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/config/doc only. T1 rewrites the merge-conflict skill reconcile step; T2 changes the shipper's declared permissions and the README Agents row together (the two sides of the permission agreement, so T2's suite Verify passes standalone); T3 wires the shipper body; T4/T5 add the `## Reconcile` record to ship.md and the PR template; T6 wires /ship; T7 is the item-level acceptance gate. AC map: AC1 T1,T3; AC2 T2; AC3 T2; AC4 T1; AC5 T1; AC6 T1,T3; AC7 T1; AC8 T1; AC9 T4,T5; AC10 T4; AC11 T3,T6; AC12 T1; AC13 T7; AC14 T7."
parent: 0005-merge-conflict-workflow
---

# Tasks — Reconcile workflow for shared framework surfaces

Ordered, dependency-aware. One task ≈ one focused commit. Every task edits prose or
agent frontmatter; no task adds a command, agent, skill, artifact format, committed
check, or executable script, and no task changes a command signature, a phase
heading, an inventory count, or `docs/workflow.md`.

- [x] **T1** — Rewrite `## Procedure` step 1 in
      `.opencode/skill/merge-conflict/SKILL.md` into the ordered, agent-executable
      reconcile sequence from `design.md` → "Ordered reconcile procedure":
      determine the default branch and merge base and `git fetch`; report and stop on
      an in-progress merge; treat an already-up-to-date branch as a `no conflicts`
      `no-op` that creates `no merge commit` and `does not error`; otherwise
      `git merge --no-edit origin/<default>` (merge the default branch forward;
      `never rebase`, `never force-push`); list every conflicted path
      (`git diff --name-only --diff-filter=U`), `never truncated`; resolve class (a)
      preserving both branches' changes and `drop neither side`, class (b)
      preserving both records, and class (c) by the existing `Renumbering after a
      parallel merge` rule (`git mv`; automated renumbering is sibling `0004`);
      auto-resolve mechanical/structural conflicts subject to re-verification; check
      each resolved file for `<<<<<<<`, `=======`, `>>>>>>>` and treat any that
      remains as `unresolved` (do not commit it); re-run `bash tests/run.sh` and the
      affected item's checks and require both green before the merge is committed,
      recorded, or shipped; on a semantic conflict run `git merge --abort`, report
      the blocked path(s) and the decision, keep the branch `blocked until the user
      responds`, and if the abort cannot complete report it and stop. Add the
      `## Reconcile` record to step 5 (resolved paths + re-verification evidence in
      `ship.md` and the PR description). Keep the remaining procedure steps and
      `## Rules` in substance. [AC1] [AC4] [AC5] [AC6] [AC7] [AC8] [AC12]
      Verify: `grep -nE 'git merge --no-edit origin/<default>|never rebase|never force-push|git merge --abort|--diff-filter=U|Renumbering after a parallel merge|<<<<<<<|>>>>>>>|no merge commit|does not error|## Reconcile' .opencode/skill/merge-conflict/SKILL.md` shows every literal; `bash tests/run.sh` exits 0.

- [x] **T2** — In `.opencode/agent/shipper.md`, add `"git merge*": allow` to
      `permission.bash` (keep `"git push*": ask`, add no `git rebase*`, add no
      `gh pr merge*`), and add both path forms of the class (a) surfaces to
      `permission.edit` — `README.md` / `**/README.md`, `AGENTS.md` /
      `**/AGENTS.md`, `docs/*.md` / `**/docs/*.md`, `.opencode/agent/**` /
      `**/.opencode/agent/**`, `.opencode/command/**` /
      `**/.opencode/command/**`, `.opencode/skill/**` / `**/.opencode/skill/**`,
      `template/**` / `**/template/**`, `tests/checks/**` /
      `**/tests/checks/**` — keeping `"*": deny`, `work/**`, and `**/work/**`. In
      `README.md`, update the `shipper` Agents-table "Can edit" cell (line 218) to
      name `work/**` and the class (a) surfaces including `tests/checks`, so the
      documented coarse class matches the declared `tests+work`; leave the bash cell
      `git/gh allowlist`. This is the two sides of the permission agreement in one
      commit. [AC2] [AC3]
      Verify: `grep -nE '"git merge\*": allow|"tests/checks/\*\*": allow|"AGENTS.md": allow|"README.md": allow' .opencode/agent/shipper.md`; `grep -n '"git push\*": ask' .opencode/agent/shipper.md`; confirm no `git rebase` line exists; `grep -n 'tests/checks' README.md` shows the shipper row; `bash tests/run.sh` exits 0 with `30-permissions.sh` reporting `AC8 shipper: mode=primary edit=tests+work bash=git-gh`.

- [x] **T3** — Wire reconcile into `.opencode/agent/shipper.md`. In
      `<preconditions>` (work-item mode) add that the branch has been reconciled
      with the default branch (or an up-to-date no-op was reported) per the
      `merge-conflict` skill and that a semantic conflict blocks the ship until the
      user responds. In `<process>` (work-item mode) insert a reconcile step after
      the read-only pre-flight and before the other ship operations containing
      `Reconcile first`, `after the read-only pre-flight`, `before the other ship
      operations`, the resolve/escalation rules, and re-verification with
      `bash tests/run.sh` and the item's checks; update the `ship.md` write step to
      include the `## Reconcile` section. Add a `<rules>` bullet granting the
      reconcile edit authority (class (a) surfaces and `work/**`), forbidding rebase
      and force-push, and forbidding resolving a semantic conflict. Add a
      `Reconciled:` line to `<handoff>` (work-item mode only; fix-landing mode
      omits it). [AC1] [AC6] [AC11] [depends: T1, T2]
      Verify: `grep -nE 'Reconcile first|after the read-only pre-flight|before the other ship operations|Reconciled:|never rebase|semantic' .opencode/agent/shipper.md`; confirm step ordering (the reconcile step follows the pre-flight step and precedes branch creation); `bash tests/run.sh` exits 0.

- [x] **T4** — In `docs/artifact-conventions.md`, add the `## Reconcile` section to
      the `### `ship.md`` template (lines 397-413) with the record shape from
      `design.md` → "Record shape": `Result` (`reconciled` / `no-op (already up to
      date)` / `blocked: <reason>`), one bullet per resolved path describing how both
      branches' intents were preserved, and `Re-verification` naming
      `bash tests/run.sh` and the item checks. Change no other template heading, and
      leave `docs/workflow.md` untouched. [AC9] [AC10]
      Verify: `grep -nE '^### `ship.md`|^## Reconcile|Resolved paths|Re-verification' docs/artifact-conventions.md`; `git diff --quiet -- docs/workflow.md`; `bash tests/run.sh` exits 0.

- [x] **T5** — In `.opencode/skill/pr-workflow/SKILL.md`, add a `## Reconcile`
      section to the work-item PR description template (after the existing
      `## Conflict detection` section) with the same shape: `Result`, resolved paths,
      and re-verification evidence. Leave the fix PR template and the `## Commands`
      block unchanged. [AC9] [depends: T4]
      Verify: `grep -nE '^## Reconcile|Resolved paths|Re-verification' .opencode/skill/pr-workflow/SKILL.md`; confirm the fix PR template still has no `## Reconcile` or `## Artifacts` section; `bash tests/run.sh` exits 0.

- [x] **T6** — In `.opencode/command/ship.md`, add one work-item-mode bullet after
      the read-only pre-flight bullet: reconcile first, after the read-only
      pre-flight and before the other ship operations, per the `merge-conflict`
      skill; resolve class (a)/(b) preserving both sides, apply the existing
      renumbering rule for class (c), abort and escalate a semantic conflict, record
      the `## Reconcile` section in `ship.md` and the PR, and never rebase / never
      force-push. Change no signature, usage string, phase heading, or the
      never-merge / never-force-push closing line. [AC11] [depends: T3]
      Verify: `grep -nE 'Reconcile first|after the read-only pre-flight|before the other ship operations' .opencode/command/ship.md`; `grep -n 'Usage: /ship \[item-ref\]' .opencode/command/ship.md`; `bash tests/run.sh` exits 0 (96-signature-sweep green).

- [x] **T7** — Run the item-level acceptance gate: `bash tests/run.sh` must exit 0
      with no `FAIL` lines, including `tests/checks/30-permissions.sh` (shipper
      `edit=tests+work`, `bash=git-gh`) and `tests/checks/40-inventory.sh`; the
      `.opencode/` inventory is unchanged at 12 commands / 14 agents / 11 skills
      with no new file; `docs/workflow.md` is byte-identical; the phase list,
      derived-state table, readiness/status models, and every artifact template
      except the `ship.md` `## Reconcile` addition are unchanged; no executable
      script is added outside `work/`; and `git status --porcelain` touches only
      `.opencode/skill/merge-conflict/SKILL.md`, `.opencode/agent/shipper.md`,
      `.opencode/command/ship.md`, `.opencode/skill/pr-workflow/SKILL.md`,
      `README.md`, `docs/artifact-conventions.md`, and
      `work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/`.
      [AC13] [AC14] [depends: T1, T2, T3, T4, T5, T6]
      Verify: `bash tests/run.sh`; `git diff --quiet -- docs/workflow.md`; `ls .opencode/command/*.md | wc -l` is 12, `ls .opencode/agent/*.md | wc -l` is 14, `ls -d .opencode/skill/*/ | wc -l` is 11; `git status --porcelain` matches the allowed surface list.
