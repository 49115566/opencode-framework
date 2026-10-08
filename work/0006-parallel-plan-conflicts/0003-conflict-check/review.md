---
feature: 0006-parallel-plan-conflicts/0003-conflict-check
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Review — Pre-development parallel-plan conflict check

## Verdict

**approve** — the prior review's [B1] (a one-sided declaration naming a silent
unshipped item was never evaluated) is resolved: the authority now considers
*every* unshipped item and the pair predicate explicitly reports a silent
counterpart, and every operative prompt references that authority rather than
restating the narrowed set; the remaining findings are non-blocking consistency
notes.

## Method and base

- Base ref: `git merge-base HEAD origin/main` → `c00f0045a146f38f626edc0d8b79dcdfbc1bb590`,
  which equals both `HEAD` and `origin/main`. All implementation work is
  uncommitted, so the reviewed range is the working tree against `HEAD`: the
  tracked diff plus the untracked `.opencode/command/conflicts.md`,
  `work/.../verify.md`, and `work/.../verify-tests.sh`.
- Commands: `git merge-base HEAD origin/main`, `git rev-parse HEAD`,
  `git rev-parse origin/main`, `git status --porcelain`, `git diff --stat HEAD`,
  `git diff HEAD -- <each changed surface>`, `git log --oneline`, and reads of
  the authority section, the new command, the status/builder prompts, the
  merge-conflict and workflow-lifecycle skills, `README.md`, both `AGENTS.md`
  files, `tests/checks/{10-readiness,20-lifecycle,30-permissions,40-inventory,96-signature-sweep}.sh`,
  and the item's `spec.md`/`design.md`/`tasks.md`/`verify.md`/`verify-tests.sh`.
- I could not execute `bash tests/run.sh` or `verify-tests.sh`: the review
  sandbox's bash allowlist denies non-git programs. AC15's "suite green" claim
  was checked statically (registry, required sets, inventory counts, table
  membership, signature parsing) rather than by execution; see "Not reviewed".

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 | met | `docs/workflow.md:443,532-533,543-546` (committed-`work/`-only, read-only, no-write, global mode); `.opencode/command/conflicts.md:6,13-14,21-24`; `.opencode/agent/status.md:31-34,105-111`. Live run not exercised. |
| AC2 | met | `docs/workflow.md:545-546`; `.opencode/command/conflicts.md:15-16`; `.opencode/agent/status.md:109-110`. Focused mode names each counterpart. |
| AC3 | met | `docs/workflow.md:451-453,462-464,470-472` (child/standalone `ship.md` exclusion; shipped still resolves but is not a counterpart). |
| AC4 | met | `docs/workflow.md:488-502`: shared resolved target or one-sided naming, one finding per unordered pair, and explicitly "an unshipped item with an empty declared set is still a counterpart under this clause" (`:499-502`) — the [B1] fix. Identity-by-resolution is a documented refinement — see [m2]. |
| AC5 | met | `docs/workflow.md:454-457` (`own ∪ cell`); one-sided record is the union (`:460-461`). |
| AC6 | met | `docs/workflow.md:511-523` (shipped grammar, `(a)`–`(d)`, no new code); `.opencode/skill/merge-conflict/SKILL.md:122-136`; `.opencode/agent/status.md:172-188`. |
| AC7 | met | `docs/workflow.md:474-484`; `DANGLING-DEP (b)` reused; skill/status carry the planning-time meaning. |
| AC8 | met | `docs/workflow.md:458-461`; `DRIFT-FACT (d)` at `:523`. |
| AC9 | met | `docs/workflow.md:537-539,549-552`; `.opencode/agent/builder.md:71-76`; `.opencode/command/build.md:27-32`; advisory, gate outcome unchanged. |
| AC10 | met | `.opencode/agent/status.md:31-34,105-111`; `.opencode/command/status.md:40-49`. Live run not exercised. |
| AC11 | met | `.opencode/agent/builder.md:71-76`; `.opencode/command/build.md:27-32`; `docs/workflow.md:549-552`. Live run not exercised. |
| AC12 | met | `docs/workflow.md:532-533`; `.opencode/command/conflicts.md:21-24`; no `git fetch`/`ls-remote`/`merge`/`gh` tokens present. |
| AC13 | met | `docs/workflow.md:534-537`; `.opencode/skill/merge-conflict/SKILL.md:125-127` scopes the pre-flight note to the detected case. |
| AC14 | met | `docs/workflow.md:466-472` (empty declared set yields no finding *from its own declaration*, historical items valid). |
| AC15 | met (static) | `.opencode/command/conflicts.md:2-3`; `README.md:204,273`; `AGENTS.md:47`; `template/AGENTS.md:49`; `.opencode/skill/workflow-lifecycle/SKILL.md:41`; `tests/checks/96-signature-sweep.sh:49,226,228,230,270`. On-disk commands = 13 = README `# 13 slash commands`; the registry, required sets, and `40-inventory` membership line up. Suite not executed here. |
| AC16 | met | Single authority `docs/workflow.md:430`; command/agent/build/skill surfaces reference it by name and the grammar/predicate are single-sourced. See [n2]. |

Acceptance criteria met: **16/16**.

### Spec edge cases

The authority covers the listed edge cases: empty/all-shipped compared set
(`docs/workflow.md:554-555`), shipped-target resolves (`:470-472`), sibling-first
precedence (`:475`), exact surface paths and glob/`..`/absolute malformation
(`:477-483`), `.gitkeep` child (`:450-451`), never-truncated / no-lock /
write-nothing (`:505-507`), cross-roadmap scan (`:543-544`), and the consumed
`0001` grammar edge cases (duplicate target, empty cell, existing directory path)
remain intact in `docs/workflow.md:139-177`. The one-sided/silent-counterpart
edge case — the prior [B1] — is now explicit at `:499-502`.

## Findings

### Blockers

- None. The prior review's [B1] is resolved: `docs/workflow.md:444` now states
  "It considers every **unshipped item**", `:468-470` says a no-declaration item
  "is still an unshipped item: a declared target that names it is a counterpart
  under the one-sided naming clause below", and `:499-502` restates the silent
  counterpart in the pair predicate. The operative prompt that previously
  restated the narrowed set — `.opencode/agent/status.md` step 8 — now reads
  "Run the declared-conflict check (`docs/workflow.md` → `## Declared-conflict
  check`) … Reference that authority — do not restate its compared set,
  resolution, or pair predicate here" (`:105-111`). The narrowing phrase is
  absent from every live surface (grep confirms only `work/` artifacts retain
  it).

### Major

- None.

### Minor

- **[m1] `design.md` §2 still documents the superseded, narrowed compared set** —
  `work/0006-parallel-plan-conflicts/0003-conflict-check/design.md:45-46`.
  It reads "It builds the set of **unshipped plans with a non-empty
  declaration**", which is exactly the narrowing that produced [B1] and now
  contradicts the shipped authority (`docs/workflow.md:444`, "every **unshipped
  item**"). The operative surfaces are corrected, but the committed plan record
  a maintainer consults still prescribes the bug; `verify-tests.sh` excludes
  `work/` from its negative control, so nothing pins the design. Recommended
  fix: have the architect republish/revise §2 to match the authority (or add a
  superseding note in the item's newest artifact frontmatter `notes`). Not a
  live-surface defect, hence Minor.

- **[m2] AC4's "equal after trimming" is implemented as identity-by-resolution** —
  spec `work/.../spec.md:90-91` vs `docs/workflow.md:491-496`. AC4 says a pair
  conflicts when the sets "share a target (equal after trimming)"; the authority
  instead defines identity by resolution, so two equal reference tokens that
  resolve to different items (the same `MMMM-slug` in two roadmaps) are
  deliberately not shared. The reading is defensible — it honours "share a
  target", matches the `0001` resolution grammar, and avoids a cross-roadmap
  false positive (documented in `design.md` → "Alternatives considered") — but
  it is a semantic narrowing of an acceptance criterion not among the
  user-resolved open questions. Recommended fix: align the AC4 wording with the
  authority, or record the interpretation in the spec; do not leave the two
  using "share a target" to mean different things. The tester already flags this
  (`verify.md` residual risk 2).

- **[m3] `tasks.md` T1's task text retains the old narrowing phrase** —
  `work/0006-parallel-plan-conflicts/0003-conflict-check/tasks.md:18`
  ("State: the compared set (unshipped plans with a non-empty declaration; …)").
  The task is ticked and the implementation is correct, but the committed task
  record now misdescribes what was built, reinforcing [m1]. Recommended fix:
  correct the T1 description to "every unshipped item" while completing the
  item (the builder owns `tasks.md`).

### Nits

- **[n1]** `.opencode/command/conflicts.md:26` says "If `work/` has no unshipped
  plan with a declaration, report no findings and do not error." This is
  behaviorally correct (with zero declarations there are no targets and thus
  nothing to report), but it is a narrowing-sounding paraphrase adjacent to the
  exact phrase the regression guard bans on operative surfaces. Consider
  rewording to the authority's "empty compared set" language
  (`docs/workflow.md:554-555`).
- **[n2]** `docs/workflow.md:432-433` opens "The `conflicts-with` declarations of
  the unshipped plans under `work/` are compared" while the detailed set is
  "every unshipped item" (`:444`). Harmless, but tightening the opening sentence
  would avoid a reader taking "plans that declare" as the set.
- **[n3]** The two new example finding lines in `.opencode/agent/status.md:222-223`
  join the existing examples in using `:` where the finding grammar uses `—`
  (`docs/workflow.md:512`). Pre-existing style, but the new lines perpetuate it.
- **[n4]** The three spec open questions remain unchecked `- [ ]`
  (`work/.../spec.md:171-188`) although `design.md` frontmatter records them as
  resolved. Cosmetic; the product agent's call.

## Scope, security, and regression

- **Scope:** every changed surface is named in `design.md` "Affected areas" —
  `docs/workflow.md`, the merge-conflict skill, status agent/command, builder
  agent/command, the new `conflicts.md`, `README.md`, both `AGENTS.md` files, the
  workflow-lifecycle skill, and the signature-sweep registry. No unrelated
  refactor, no new dependency, no new agent, and no deliberately-unchanged
  surface (`docs/artifact-conventions.md`, `opencode.json`,
  `tests/checks/40-inventory.sh`, `tests/fixtures/**`) touched. No scope creep
  found.
- **Security/secrets:** docs and prompts only; no secrets, credentials, network
  calls, or write capability added. `/conflicts` routes to the `status` agent,
  which keeps `edit: deny` and a read-only bash allowlist
  (`.opencode/agent/status.md:4-15`); the new command adds no git-write or `gh`
  instruction.
- **Regression (static):** the mechanical inventories agree — 13 command files on
  disk, README `# 13 slash commands`, the `## Commands` table has 13 rows
  including `/conflicts`; `AGENTS_REQUIRED`/`README_REQUIRED`/`SKILL_REQUIRED`
  and `ALL_COMMANDS` in `96-signature-sweep.sh` all include `/conflicts` and the
  new routing line parses to the canonical `/conflicts [item-ref]`;
  `40-inventory.sh` is generic and counts commands from disk. The status agent
  preserves the literals `10-readiness.sh` and `80-cycle-fixture.sh` require
  (`Dependencies and readiness`, `CYCLIC-DEP`, `informational and never fatal`,
  `members of a cycle are never reported`) and gained no
  `satisfied(dep_local_id):` marker. No regression found by inspection.

## Not reviewed

- Execution of `bash tests/run.sh` and `verify-tests.sh` (blocked by the review
  sandbox's command allowlist). AC15 and the "291 passed / 123 passed" claims are
  accepted on static consistency analysis, not on a run; a human or CI run should
  confirm before `/ship`.
- The live LLM behavior of `/conflicts`, `/status`, and the `/build`-gate
  surfacing (prompt behavior by design); the `verify.md` manual steps were read
  but not reproduced.
- `0004-conflict-guards` fixture/mutation coverage, deferred by the spec
  non-goals; not in scope here.
- No UI, so no `visual.md` applies.
