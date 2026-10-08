---
feature: 0006-parallel-plan-conflicts/0001-conflict-declaration-model
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: ""
---

# Review — Declared planning-time conflict model and `conflicts-with` column

## Verdict

**approve** — all 12 acceptance criteria are met by the four changed surfaces, the
committed suite's only positional parser keeps `Depends on` at pipe-field 5, no
`tests/` file changed, and the two Minor findings are follow-up documentation
consistency items outside the AC-named surfaces, not blockers.

## Scope and base

The item is entirely uncommitted: `HEAD == origin/main == f16be1c`, the working
tree is dirty, and `work/0006-parallel-plan-conflicts/` is untracked. The review
range is therefore the working-tree diff plus the untracked item directory.

Commands used:

- `git status --porcelain` — 4 modified tracked files + untracked
  `work/0006-parallel-plan-conflicts/`; `tests/` clean.
- `git rev-parse --abbrev-ref HEAD origin/main` — `main`, `origin/main`.
- `git merge-base HEAD origin/main` — `f16be1ce6fd61c467353ce9ea58a6c45adcb4e23`.
- `git diff --stat` and `git diff --numstat HEAD -- <paths>` — 81 insertions, 5
  deletions across the four files.
- `git diff -- <path>` for each of `docs/workflow.md`,
  `docs/artifact-conventions.md`, `.opencode/agent/roadmap.md`,
  `.opencode/command/roadmap.md`.
- `git log --oneline --all -- work/0006-parallel-plan-conflicts/` — no output;
  the item has never been committed.
- Read of the full items under `work/0006-parallel-plan-conflicts/`, the parent
  `roadmap.md`, `verify-tests.sh`, and the affected committed surfaces.

I could not re-execute `bash tests/run.sh` or the item suite under the sandbox's
bash allowlist; the suite result is assessed by reading the changed files and the
committed checks (see "Not reviewed").

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — planning-time conflict defined as a declared, committed claim, distinct from merge-time and `Depends on`, referencing the shipped classes | met | `docs/workflow.md:110-120` states the definition, the two distinctions, and the advisory/one-sided rules; `:163-166` cites the `(a)`–`(d)` labels rather than restating a taxonomy. |
| AC2 — template includes `conflicts-with`; note explains meaning and empty value | met | `docs/artifact-conventions.md:110` 6-column header; `:112-113` example rows carry `—`; `:134-137` note states meaning, `—` empty value, and points to the workflow authority. |
| AC3 — three target kinds, comma-separated, `—` when none | met | `docs/workflow.md:131-136` grammar; `:139-150` names sibling local id, canonical work-item reference, and exact surface path, plus comma/`—` conventions. |
| AC4 — same grammar for a child/standalone, storage-independent | met | `docs/workflow.md:122-124`; no container/field or `phase` value is decided. |
| AC5 — one-sided declaration is a conflict | met | `docs/workflow.md:118-120`. |
| AC6 — advisory; no readiness change | met | `docs/workflow.md:116-118`; template note `:137`; agent `:85-87`; command `:23-24`. `### Dependencies and readiness` is unedited and carries no `conflicts-with` input. |
| AC7 — reuse `(a)`–`(d)` and the finding grammar; no new class/code/policy | met | `docs/workflow.md:163-166`; explicit "no new class, finding code, or policy defined for declarations". |
| AC8 — no self-reference; no duplicate target | met | `docs/workflow.md:157-158`; agent quality bar `:116-119`. |
| AC9 — roadmap agent prompt and command describe the column consistently | met | `.opencode/agent/roadmap.md:82-87,116-119`; `.opencode/command/roadmap.md:20-24`; neither restates the `ConflictTargetList` production. |
| AC10 — `Depends on` parsing/readiness unchanged; positional consumer intact if needed | met | `tests/checks/80-cycle-fixture.sh:50` still reads `dep = a[5]`; inserting `conflicts-with` after `Depends on` leaves pipe-field 5 as `Depends on` in both the 5-column fixture and the 6-column template; `tests/` diff is empty; fixture header assertion `:31` unchanged. |
| AC11 — malformed/unresolved target is a reported unresolved declaration, never dropped | met | `docs/workflow.md:159-162`. |
| AC12 — one authoritative grammar; others reference it | met | The production appears only in `docs/workflow.md:131-136`; `docs/artifact-conventions.md:135-137`, `.opencode/agent/roadmap.md:83-85`, and `.opencode/command/roadmap.md:21-24` reference it and state no conflicting grammar. |

Coverage: **12/12 met, 0 partial, 0 not met.**

Spec edge cases (`spec.md:126-150`) were each checked against the authority:
empty/whitespace malformed, absent column, unresolved sibling/top-level/surface,
self-reference, duplicate, one-sided, cross-roadmap, and comma separation are all
stated (`docs/workflow.md:122-162`).

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[M1] `/status` no longer enumerates the full `Children` table** —
  `.opencode/agent/status.md:80-82`
  The status agent's parse step lists "a local id, title, scope, `Depends on`
  local ids, and a canonical reference" and now omits `conflicts-with`. This is a
  live parsing surface introduced by the change, and the design's "Out-of-scope
  surfaces" recon (`design.md:126-132`) names `AGENTS.md`, `README.md`, and the
  `workflow-lifecycle` skill but not `status.md`; `verify.md:113-121` already
  records the omission. It violates no AC (AC9/AC12 name the roadmap
  agent/command and the authority/template, not `/status`), so it is not
  merge-blocking. Recommendation: assign the one-line enumeration update to
  sibling `0003-conflict-check` (which the roadmap already scopes to wire the
  pre-development check into `/status`) and record it there; do not expand this
  item.

- **[M2] The renumbering reference-update checklists do not name
  `conflicts-with` cells** — `docs/artifact-conventions.md:466-469`,
  `.opencode/skill/merge-conflict/SKILL.md:376-384`
  A `conflicts-with` cell may now carry a sibling local id or a canonical
  work-item reference. The renumber step enumerates `Local id`, `Canonical
  reference`, and "every `Depends on` cell that names the old local id", but not a
  `conflicts-with` target naming the renumbered row. The skill's repo-wide "no
  reference to the old canonical reference remains" assertion mitigates the
  canonical-reference case, but a bare sibling-local-id target (`MMMM-slug`) would
  not be matched by that scan. **Question, not a confirmed defect:** changing the
  shipped merge-time reconcile contract is an explicit non-goal of this item
  (`spec.md:51-52`), so this may be owned elsewhere. Recommendation: have
  `0004-conflict-guards` (or the renumbering owner) add `conflicts-with` cells to
  the update enumeration, or confirm the repo-wide scan/`git grep` covers bare
  local ids. Flagged here because no child in `0006` currently claims it.

### Nits

- **[N1] Grammar/discriminator spacing mismatch** — `docs/workflow.md:135` vs
  `:151-152`. The production writes the optional segment as `( /[0-9]{4}-... )?`
  with a surrounding space for readability, while the discriminator regex `:152`
  has none. Purely presentational; no semantic divergence.
- **[N2] Intentional template/fixture skew** — the template is now 6-column
  (`docs/artifact-conventions.md:110`) while the committed fixture
  (`tests/fixtures/cyclic-roadmap/roadmap.md:26`) and four live roadmaps remain
  5-column. This is explicitly designed (`design.md:214-251`) and deferred to
  `0004-conflict-guards`; noted so it is not mistaken for an oversight. No action
  for this item.

## Not reviewed

- **Live suite execution.** The sandbox's bash allowlist does not permit
  `bash tests/run.sh` or the item suite, so I did not re-run them. I verified by
  reading that `tests/` is unmodified, that no committed check reads `work/**`,
  that no check asserts the template header, and that the new `### Declared
  conflicts` heading is not matched by any extractor (e.g.
  `tests/checks/96-signature-sweep.sh:101` requires `### <digits>.`;
  `tests/checks/10-readiness.sh:19-32` counts only `satisfied(dep_local_id):`).
  The `verify.md` PASS claims are consistent with those facts but were not
  independently reproduced.
- **Children of this roadmap beyond `0001`** (`0002-plan-record`,
  `0003-conflict-check`, `0004-conflict-guards`) — not yet built; out of scope.
- **Pre-existing roadmap artifacts and historical `work/**`** — intentionally
  unchanged under the absence rule.

## Notes on scope and quality

- Scope is exactly the four design-named surfaces plus the item artifacts and its
  read-only `verify-tests.sh`; no unrelated code, test, or config change, and no
  `tests/` edit that would preempt `0004`. No secrets, no runtime, no dependency,
  no performance concern.
- The item suite (`verify-tests.sh`) is a literal-content harness, appropriate for
  a docs/prompts-only deliverable. It reads well and adds negative controls (no
  `(e)`, no new finding code, no restated grammar). Its main limitation — not
  wired into `tests/run.sh` — is acknowledged and correct for this item per the
  spec's deferral of committed guards to `0004`.
