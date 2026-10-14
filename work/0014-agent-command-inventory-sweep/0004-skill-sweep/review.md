---
feature: 0014-agent-command-inventory-sweep/0004-skill-sweep
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Review — Skill-surface recursive sweep

## Verdict

**approve** — every acceptance criterion is met, the substantive stale-spelling
bug in `merge-conflict/SKILL.md` is fixed without changing any pinned fixture
literal, and the change set is exactly the three in-scope skill files (plus this
item's `work/` artifacts).

## Base and commands

- Base ref: `git merge-base HEAD origin/main` → `efe1782da5a78d0161d30378ea5ca707f7dcacfd`.
- `HEAD` and `origin/main` are both `efe1782`, and the change is uncommitted
  working-tree state (`/build` does not commit), so the reviewed range is
  `git diff` (working tree vs `efe1782`) plus the untracked `verify.md`.
- Commands run: `git status`, `git merge-base HEAD origin/main`,
  `git rev-parse HEAD origin/main`, `git diff`, `git diff --stat`,
  `git diff -- .opencode/skill/`,
  `git diff -- work/0014-agent-command-inventory-sweep/0004-skill-sweep/tasks.md`.
- `challenges.md` and `backtracks.md` do not exist for this item, so there was no
  open challenge to adjudicate and no open finding targeting its phases.
- **Not independently executed:** `bash tests/run.sh` (and its `FRAMEWORK_TEST_AREAS`
  variants) — the review bash allowlist is read-only git/`ls`/`cat`, so the suite
  could not be re-run. AC13 below therefore rests on the tester's recorded PASS
  plus this pass's independent static confirmation that no fixture-pinned literal
  changed (see AC6/AC9/AC13).

## Acceptance criteria

| AC | Verdict | Evidence (working tree) |
| -- | ------- | ----------------------- |
| AC1 | met | `merge-conflict/SKILL.md:80` heading is now `**Manifest graph faults.**`; `:80-82` names each node's `manifest.md` (or the legacy alias) and resolves every `Depends on` local id in **its own** `Children` table. Old `Roadmap graph faults` is gone (`grep` census, AC12). |
| AC2 | met | `:121` `DANGLING-DEP (b)` → "a manifest `Depends on`"; `:124` `CYCLIC-DEP (b)` → "a cycle in a manifest dependency graph"; `:127` `DRIFT-FACT (d)` unchanged. Codes and class labels `(b)`/`(d)` intact. |
| AC3 | met | `:141-143` planning-time `DRIFT-FACT` now reads "a decomposing child's own `design.md` declaration and its parent `Children` `conflicts-with` cell"; `a roadmap child's own` absent. |
| AC4 | met | `:220` "re-checks the manifest dependency graph"; `:258` "manifest `Children` / `Depends on` tables"; `:333` "**Manifest `Children` rows**". Old roadmap phrasings absent; procedure behaviour otherwise unchanged. |
| AC5 | met | `:349-351` "**Re-check the manifest dependency graph.** For every decomposing node at any depth — its `manifest.md`, or the clearly-labelled legacy `roadmap.md` alias — each `Depends on` local id …". No bare `In every \`roadmap.md\`` remains. The silent-skip bug for `manifest.md`-spelled nodes is fixed. |
| AC6 | met | Diff touches no finding-code, class label, or the grammar line `:106` `- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>`. All eight codes still present; matches `docs/workflow.md` "Merge conflicts" / "Declared-conflict check". `tests/checks/85-conflict-guards.sh:626-637` and `88-renumber-sweep.sh` pins are structurally unaffected. |
| AC7 | met | `workflow-lifecycle/SKILL.md:25-29`: "A decomposing node and its descendants nest to **arbitrary depth**, and a child may itself decompose — any node may hold a manifest and its own children at once"; child canonical reference extended "one further `/<MMMM-slug>` segment per nesting level". |
| AC8 | met | `:23` "the legacy `roadmap.md` is the recognized deprecated alias"; `:68` "legacy `roadmap.md` alias"; `:93` "a legacy `stale: roadmap` is accepted as the deprecated equivalent". All explicitly labelled. |
| AC9 | met | `git diff -U0 .opencode/skill/workflow-lifecycle/SKILL.md` changes only `:25-30`; the `## Which command now?` fenced block (`:34-58`) is byte-identical. `tests/checks/96-signature-sweep.sh` extracts routes from that block only. |
| AC10 | met | `conventional-commits/SKILL.md` has zero `roadmap` occurrences; `:80` `0002-billing/0001-invoice-model` → `0002-billing+0001-invoice-model`; `:83-86` `feat/` / `plan/` examples; `:88-89` superseded `0002-billing-0001-invoice-model`. Flatten (`split("/").join("+")`) and un-flatten (`split("+")`) round-trip; `work/0002-billing/` does not exist (glob, no collision). |
| AC11 | met | `:81` retains "its `manifest.md`, or the legacy `roadmap.md` alias" inside the `Manifest graph faults` bullet, manifest primary. |
| AC12 | met | Case-insensitive census over `.opencode/skill/`: exactly 5 hits — `merge-conflict:81,350` and `workflow-lifecycle:23,68,93` — each a `roadmap.md` or `stale: roadmap` mention labelled `legacy`/`deprecated`. No bare current-concept term remains. |
| AC13 | met (not re-executed) | No fixture-pinned literal changed (verified against `85`, `88`, `96`, `20`, `25`, `10`, `40`, plus `tests/mutation.sh` jobs 19/30), and the diff adds no file. Tester records `503 passed, 0 failed, 0 skipped`, exit 0. Review could not re-run the suite (allowlist). |
| AC14 | met | `git status` shows exactly the three `.opencode/skill/**/SKILL.md` files modified, plus this item's `tasks.md` (checkboxes) and untracked `verify.md`. No agent, command, README, docs, test, or other skill file changed. |

Edge cases: both manifest spellings (`:349-350`), nested depth "at any depth"
(`:80`,`:349`), routing-block fixture parsing (byte-identical), example
round-trip and no real-item collision, substring classification, and the no-op
case are all handled as the spec requires. Cross-child consistency: the swept
`DRIFT-FACT` rationale matches `docs/workflow.md` "Declared-conflict check";
`.opencode/agent/status.md` (sibling `0002`) is left untouched as scoped.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None.

### Nits

- None.

## Security, scope, and convention checks

- **Security / secrets.** Text-only prose edits to three Markdown prompts; no
  executable content, credentials, tokens, or environment data introduced.
- **Scope.** Diff is confined to `.opencode/skill/{merge-conflict,
  workflow-lifecycle,conventional-commits}/SKILL.md` plus this item's `tasks.md`;
  `CONTRIBUTING.md:77` and `.opencode/agent/status.md` (which still carry retired
  wording) are correctly left out of scope — the design records them as
  follow-ups. No unrelated refactor or reformat.
- **Convention fit.** The swept wording defers to the authority
  (`docs/workflow.md` / `docs/artifact-conventions.md`) rather than restating it,
  per the spec's non-goals; frontmatter `name`/`description` of all skills are
  untouched, so the inventory stays 11 skills.
- **Tests.** `tasks.md` changed only `[ ]`→`[x]`; no task text was rewritten to
  fit the implementation. The committed fixture pins that touch these files were
  read and are unaffected.

## Not reviewed

- `design.md` is not part of the diff, but one of its citations is imprecise:
  `design.md:49` cites `docs/artifact-conventions.md:98` for the
  `0002-billing/0001-invoice-model` example, while that line actually shows
  `work/0007-billing/` (the nested example lives at `:99`). The chosen
  replacement is still a valid, non-colliding authority-style slug
  (`docs/workflow.md:146` uses `0002-billing/`), so this is a non-blocking
  documentation observation, not a defect in the delivered change.
- `.opencode/agent/status.md`, other agent/command prompts, the
  inventories/doctor surfaces, `CONTRIBUTING.md`, README, and `docs/**` — out of
  scope; verified only that they are untouched.
- `tests/mutation.sh` was not executed (mutation coverage is not part of this
  item's verification plan); its jobs that mutate `merge-conflict/SKILL.md`
  (grammar line, renumber `conflicts-with` bullet) target text this change leaves
  unchanged.
