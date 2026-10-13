---
feature: 0012-roadmap-deprecation/0002-command-retirement
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Review — Retire the `/roadmap` command and agent; `/plan` becomes the sole recursive writer

## Verdict

**approve** — the change deletes the retired command/agent pair, re-homes the
create mode into `/plan` + `architect` under the dual-form canonical signature,
and reconciles every in-scope surface to the `0001` manifest vocabulary, with no
surviving finding at any severity; the only observation is the spec-internal
tension between `AC5`'s broad wording and `AC14`'s explicit scope fence, which the
spec itself resolves.

## Base and diff

- Base ref: `git merge-base HEAD origin/main` → `d681251` (equivalently, `HEAD`;
  `git rev-parse HEAD` = `d681251c68357de4d4f6cd25630748f81c943db7`). `HEAD` is the
  committed plan record `docs(plan): record plan for
  0012-roadmap-deprecation/0002-command-retirement`; `origin/main` is `1bd3679`,
  ahead of `HEAD`.
- The work is **uncommitted** on the working tree (`/build` does not commit), so
  `git diff <base>...HEAD` is empty. The reviewed range is the unstaged working
  tree plus the new untracked `verify.md`:
  - `git diff --name-status` (10 implementation paths + `tasks.md`),
  - `git status --short` (adds untracked `verify.md`),
  - `git diff -- <path>` per file,
  - `git show HEAD:<path>` for the deleted pair.
- No `work/0012-roadmap-deprecation/0002-command-retirement/challenges.md` exists,
  so there was no open challenge to adjudicate. No `backtracks.md` exists for this
  item.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 command removed | **met** | `.opencode/command/roadmap.md` deleted (`git diff --name-status` shows `D`); no `agent: roadmap` remains (`grep` finds it only in `work/` history); `.opencode/command/` enumerates 12 entries, none `roadmap`. |
| AC2 agent removed | **met** | `.opencode/agent/roadmap.md` deleted; `.opencode/agent/` enumerates 13 entries, none `roadmap`; README Agents table has 13 rows, no `roadmap` (README.md:211-225). |
| AC3 create mode moved to `/plan` | **met** | `.opencode/command/plan.md:37-47` and `.opencode/agent/architect.md:100-140`: argument resolving to no `work/<item-ref>/` → reconnoitre, allocate next top-level `NNNN` + 2–4 word slug, author `manifest.md` `phase: manifest`, reserve child `.gitkeep`, write no child artifact, recommend `/spec` for a single feature. |
| AC4 canonical `/plan` signature | **met** | Dual form in AGENTS.md:36, template/AGENTS.md:38, docs/workflow.md:463, README.md:140 (mermaid) + README.md:197 (table), `.opencode/command/plan.md:2` (usage), skill routing (SKILL.md:33-50), and `tests/checks/96-signature-sweep.sh:40` (registry). |
| AC5 sole recursive writer | **met (in-scope)** | No `/roadmap` in any in-scope surface; the `roadmap` agent name is absent from `.opencode/agent` and `.opencode/command`. Read-side residue (`product.md`, `status.md`, `/status`) is explicitly deferred by Non-goals/AC14 — see Questions. |
| AC6 writer emits modern spelling | **met** | `plan.md`/`architect.md` use `manifest.md`, `phase: manifest`, mark `stale: manifest` (architect.md:148), and name "Revising a decomposition" (plan.md:18, architect.md:44,128); no `stale: roadmap` or "Revising a roadmap" remains in the writer. |
| AC7 command-alias prose retired, artifact alias retained | **met** | No `/roadmap` in `docs/workflow.md` or the skill; the legacy `roadmap.md`/`phase: roadmap` alias stays documented (docs/workflow.md:53-57,190-191; SKILL.md:23,66,91). |
| AC8 README inventory reconciled | **met** | Layout reads `13 role prompts` / `12 slash commands` / `11 knowledge skills` (README.md:272-274); Commands table has no `/roadmap` row and `/plan` is dual (README.md:197); Agents table has no `roadmap` row (README.md:211-225). |
| AC9 contracts reconciled, byte-parity held | **met** | `AGENTS.md` and `template/AGENTS.md` receive byte-identical body edits outside `## Project profile`; no `/roadmap` in either; Design row dual in both (AGENTS.md:36, template/AGENTS.md:38). |
| AC10 skill surfaces reconciled | **met** | SKILL.md:33-50 route `/plan <item-ref or initiative>`; decomposing-node/derived-state view uses `manifest.md` and container phase `manifest` (SKILL.md:22-28,61-69). |
| AC11 signature guard reconciled | **met** | `tests/checks/96-signature-sweep.sh` contains no `roadmap` literal; `/plan` registry entry is the dual form; `/roadmap` removed from `AGENTS_REQUIRED`, `README_REQUIRED`, `SKILL_REQUIRED`, `ALL_COMMANDS`. |
| AC12 suite stays green | **met (tester evidence)** | `verify.md` records `bash tests/run.sh` → 482 passed, 0 failed, 0 skipped, and focused areas green. Not independently re-run here (see Not reviewed); every touched guard was read and is consistent with the diff. |
| AC13 no behavior or contract fork | **met** | Diff touches only the allowed surfaces; `docs/artifact-conventions.md` untouched (six-column `Children` and `conflicts-with` grammar intact); no new command/agent/skill (13/12/11); no committed `work/` artifact or `ship.md` rewritten; no spent number reused. |
| AC14 scope fence | **met** | `git diff --name-status` lists exactly the removed pair plus `plan.md`, `architect.md`, `README.md`, `AGENTS.md`, `template/AGENTS.md`, `SKILL.md`, `docs/workflow.md`, `96-signature-sweep.sh`, plus this item's `tasks.md`; `verify.md` is the only untracked addition. Read-side prompts, fixtures, `tests/README.md`, `docs/artifact-conventions.md`, `CHANGELOG.md`, and `CONTRIBUTING.md` are untouched. |

### Edge cases

Covered by the writer prose or explicitly deferred:

- Empty argument → `plan.md:73-77` asks and creates nothing.
- Item-ref-shaped, non-resolving argument → create path with reconnoitre
  (plan.md:44-46; architect.md:136-138).
- Single-feature initiative → recommend `/spec` (plan.md:46-47; architect.md:139-140).
- Existing modern/legacy manifest → revise (plan.md:31-33; architect.md:104-105).
- `.gitkeep`-only / pure container / hybrid → author path (architect.md:141-158).
- Shipped node → revise refuses and surfaces (architect.md:149).
- Muscle-memory `/roadmap` → unknown command (AC1; no redirect).
- Contract parity drift → identical twin edits (AC9 / `95-split-guard`).

## Findings

### Blockers

None.

### Major

None.

### Minor

None.

### Nits

None.

### Questions

- **`AC5`'s "no documented surface" vs `AC14`'s scope fence.** `AC5` reads "no
  documented surface presents `/roadmap` … and no documented surface names the
  retired `roadmap` agent", but the spec's Non-goals, its "Deliverable surfaces"
  list, and `AC14` explicitly fence the read-side agent/command prose
  (`product.md`, `status.md`, `/status`, `merge-conflict` skill) out of this item
  and defer it to Roadmap 4. Those out-of-scope surfaces still contain `/roadmap
  revise` (`product.md:118`), the `roadmap.md`/container-phase `roadmap`
  vocabulary (`status.md:48-58,120`), and generic "roadmap child" phrasing.
  This is a spec-internal tension, not an implementation defect: the change
  follows the more specific and deliberate scope statements, and satisfying
  `AC5` literally would violate `AC14`. Recorded so a reviewer can decide whether
  a spec wording touch-up is warranted; it does not block this item. (The tester
  recorded the same observation in `verify.md` → "Gaps and residual risk" #2.)

## Not reviewed

- The committed suite was **not** independently executed: this read-only pass is
  restricted to `git`/`ls`/`cat` and cannot run `bash tests/run.sh`. `AC12`'s
  result is the tester's recorded evidence; I instead read `40-inventory`,
  `30-permissions`, `20-lifecycle`, `95-split-guard`, `87-backtrack-guards`,
  `90-packaging`, `70-pin`, and `96-signature-sweep` against the diff and found
  them consistent (in particular, `96`'s required sets, registry, and README/
  skill/mermaid extraction targets all match the edited surfaces).
- The `roadmap.md`-loading fixtures and `80`/`85`/`87` guards, `tests/README.md`,
  the seven existing decomposing parents, and the read-side prompt sweep — all
  explicitly `0003-parent-migration` / Roadmap 4 scope (AC14). Verified only that
  they were left untouched.
- The `0001` deprecation contract (modern spelling, legacy artifact alias,
  container phase, `stale: manifest` token) — consumed as fixed, cross-checked
  for consistency only.
- No UI surface: `/visual` is not applicable.
